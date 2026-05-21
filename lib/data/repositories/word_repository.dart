import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../models/word_definition.dart';
import '../../core/utils/sm2.dart';

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository(ref.watch(databaseProvider));
});

class WordRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  WordRepository(this._db);

  Stream<List<WordCardEntry>> watchAll() => _db.watchAllWordCards();

  Future<List<WordCardEntry>> getDueCards() => _db.getDueCards();

  Future<bool> wordExists(String word) => _db.wordExists(word);

  Future<String> saveWord({
    required String word,
    required WordDefinition definition,
    required String context,
    required String videoId,
    required String videoTitle,
    required int videoPositionMs,
    String? screenshotPath,
  }) async {
    final id = _uuid.v4();
    await _db.insertWordCard(WordCardsCompanion.insert(
      id: id,
      word: word.toLowerCase(),
      phonetic: Value(definition.phonetic),
      definitionJson: jsonEncode(definition.toJson()),
      context: context,
      videoId: videoId,
      videoTitle: videoTitle,
      videoPositionMs: videoPositionMs,
      screenshotPath: Value(screenshotPath),
    ));
    return id;
  }

  Future<void> recordReview({
    required WordCardEntry card,
    required int grade,
  }) async {
    final result = SM2.calculate(
      easeFactor: card.easeFactor,
      interval: card.interval,
      repetitions: card.repetitions,
      grade: grade,
    );

    await _db.updateWordCard(card.id, WordCardsCompanion(
      easeFactor: Value(result.easeFactor),
      interval: Value(result.interval),
      repetitions: Value(result.repetitions),
      nextReviewAt: Value(result.nextReview),
    ));

    await _db.insertReviewLog(ReviewLogsCompanion.insert(
      id: _uuid.v4(),
      wordId: card.id,
      grade: grade,
      intervalBefore: card.interval,
    ));
  }

  Future<void> deleteWord(String id) => _db.deleteWordCard(id);

  Future<int> getTotalCount() => _db.getCardCount();

  Future<int> getDueCount() => _db.getDueCount();

  WordDefinition parseDefinition(String json) {
    return WordDefinition.fromStoredJson(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }
}
