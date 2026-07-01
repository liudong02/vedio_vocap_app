import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../../core/utils/sm2.dart';

final wordBankRepositoryProvider = Provider<WordBankRepository>((ref) {
  return WordBankRepository(ref.watch(databaseProvider));
});

class WordBankWord {
  final int index;
  final String word;
  final String level;
  final String phonetic;
  final String audioUrl;
  final String translation;
  final String pos;
  final List<String> examples;

  WordBankWord({
    required this.index,
    required this.word,
    required this.level,
    required this.phonetic,
    required this.audioUrl,
    required this.translation,
    required this.pos,
    required this.examples,
  });

  factory WordBankWord.fromJson(Map<String, dynamic> json) {
    return WordBankWord(
      index: json['i'] as int,
      word: json['w'] as String,
      level: json['l'] as String? ?? '',
      phonetic: json['p'] as String? ?? '',
      audioUrl: json['au'] as String? ?? '',
      translation: json['t'] as String? ?? '',
      pos: json['pos'] as String? ?? '',
      examples: (json['ex'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class ChallengeStats {
  final int totalWords;
  final int totalScanned;
  final int totalMastered;
  final int todayLearned;
  final int streakDays;
  final int dueReviewCount;

  ChallengeStats({
    required this.totalWords,
    required this.totalScanned,
    required this.totalMastered,
    required this.todayLearned,
    required this.streakDays,
    required this.dueReviewCount,
  });
}

class WordBankRepository {
  final AppDatabase _db;
  List<WordBankWord>? _wordCache;

  WordBankRepository(this._db);

  Future<void> initializeWordBank() async {
    final count = await _db.getWordBankCount();
    if (count > 0) return;

    final jsonStr = await rootBundle.loadString('assets/data/wordbank.json');
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final words = data['words'] as List<dynamic>;

    await _db.batch((batch) {
      for (final w in words) {
        batch.insert(
          _db.wordBankItems,
          WordBankItemsCompanion(
            wordIndex: Value(w['i'] as int),
            word: Value(w['w'] as String),
            level: Value(w['l'] as String? ?? ''),
          ),
        );
      }
    });

    await _db.upsertChallengeProgress(
      const ChallengeProgressCompanion(
        id: Value(1),
        totalScanned: Value(0),
        totalMastered: Value(0),
        todayLearned: Value(0),
        streakDays: Value(0),
        lastActiveDay: Value(''),
      ),
    );
  }

  Future<List<WordBankWord>> _loadWordData() async {
    if (_wordCache != null) return _wordCache!;
    final jsonStr = await rootBundle.loadString('assets/data/wordbank.json');
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final words = (data['words'] as List<dynamic>)
        .map((w) => WordBankWord.fromJson(w as Map<String, dynamic>))
        .toList();
    _wordCache = words;
    return words;
  }

  Future<WordBankWord?> getWordData(int wordIndex) async {
    final words = await _loadWordData();
    if (wordIndex < 0 || wordIndex >= words.length) return null;
    return words[wordIndex];
  }

  Future<List<WordBankWord>> getWordDataBatch(List<int> indices) async {
    final words = await _loadWordData();
    return indices
        .where((i) => i >= 0 && i < words.length)
        .map((i) => words[i])
        .toList();
  }

  Future<List<WordBankEntry>> getNextScanBatch(int batchSize) async {
    final progress = await _db.getChallengeProgress();
    final startIndex = progress?.totalScanned ?? 0;
    return _db.getWordBankBatch(startIndex, batchSize);
  }

  Future<void> recordScanResult(int wordIndex, bool known) async {
    final now = DateTime.now();
    if (known) {
      await _db.updateWordBankItem(
        wordIndex,
        const WordBankItemsCompanion(
          status: Value(1),
        ),
      );
    } else {
      await _db.updateWordBankItem(
        wordIndex,
        WordBankItemsCompanion(
          status: const Value(2),
          nextReviewAt: Value(now.add(const Duration(days: 1))),
        ),
      );
    }
    await _updateProgress(scanned: 1, mastered: known ? 1 : 0);
  }

  Future<List<WordBankEntry>> getDueReviews() => _db.getWordBankDueReviews();

  Future<int> getDueReviewCount() => _db.getWordBankDueCount();

  Future<void> recordReview(WordBankEntry entry, int grade) async {
    final result = SM2.calculate(
      easeFactor: entry.easeFactor,
      interval: entry.interval,
      repetitions: entry.repetitions,
      grade: grade,
    );

    int newStatus = entry.status;
    if (grade >= 4 && result.repetitions >= 3) {
      newStatus = 4;
    }

    await _db.updateWordBankItem(
      entry.wordIndex,
      WordBankItemsCompanion(
        easeFactor: Value(result.easeFactor),
        interval: Value(result.interval),
        repetitions: Value(result.repetitions),
        nextReviewAt: Value(result.nextReview),
        status: Value(newStatus),
      ),
    );

    if (newStatus == 4 && entry.status != 4) {
      await _updateProgress(mastered: 1);
    }
  }

  Future<ChallengeStats> getChallengeStats() async {
    final progress = await _db.getChallengeProgress();
    final dueCount = await _db.getWordBankDueCount();
    final totalCount = await _db.getWordBankCount();
    final learnedCount = await _db.getWordBankLearnedCount();

    return ChallengeStats(
      totalWords: totalCount,
      totalScanned: learnedCount,
      totalMastered: progress?.totalMastered ?? 0,
      todayLearned: progress?.todayLearned ?? 0,
      streakDays: progress?.streakDays ?? 0,
      dueReviewCount: dueCount,
    );
  }

  Stream<ChallengeProgressEntry?> watchProgress() =>
      _db.watchChallengeProgress();

  Future<void> _updateProgress({int scanned = 0, int mastered = 0}) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var progress = await _db.getChallengeProgress();

    int todayLearned = (progress?.todayLearned ?? 0) + scanned;
    int streakDays = progress?.streakDays ?? 0;
    final lastDay = progress?.lastActiveDay ?? '';

    if (lastDay != today) {
      final yesterday = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1)));
      if (lastDay == yesterday) {
        streakDays += 1;
      } else if (lastDay.isEmpty) {
        streakDays = 1;
      } else {
        streakDays = 1;
      }
      todayLearned = scanned;
    }

    await _db.upsertChallengeProgress(
      ChallengeProgressCompanion(
        id: const Value(1),
        totalScanned: Value((progress?.totalScanned ?? 0) + scanned),
        totalMastered: Value((progress?.totalMastered ?? 0) + mastered),
        todayLearned: Value(todayLearned),
        streakDays: Value(streakDays),
        lastActiveDay: Value(today),
      ),
    );
  }
}
