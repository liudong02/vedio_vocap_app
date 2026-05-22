import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Videos, WordCards, ReviewLogs, DictionaryCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await customStatement(
              'ALTER TABLE videos ADD COLUMN subtitle_position_y REAL NOT NULL DEFAULT -1',
            );
          }
          if (from < 3) {
            await customStatement(
              'ALTER TABLE videos ADD COLUMN source_url TEXT',
            );
          }
        },
      );

  // ── Videos ─────────────────────────────────────────────────────────────────

  Stream<List<VideoEntry>> watchAllVideos() =>
      (select(videos)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Future<List<VideoEntry>> getAllVideos() =>
      (select(videos)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Future<VideoEntry?> getVideo(String id) =>
      (select(videos)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertVideo(VideosCompanion entry) => into(videos).insert(entry);

  Future<void> updateVideo(String id, VideosCompanion entry) =>
      (update(videos)..where((t) => t.id.equals(id))).write(entry);

  Future<void> deleteVideo(String id) =>
      (delete(videos)..where((t) => t.id.equals(id))).go();

  // ── Word Cards ──────────────────────────────────────────────────────────────

  Stream<List<WordCardEntry>> watchAllWordCards() =>
      (select(wordCards)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Future<List<WordCardEntry>> getDueCards() =>
      (select(wordCards)
            ..where((t) => t.nextReviewAt.isSmallerOrEqualValue(DateTime.now())))
          .get();

  Future<void> insertWordCard(WordCardsCompanion entry) =>
      into(wordCards).insert(entry);

  Future<void> updateWordCard(String id, WordCardsCompanion entry) =>
      (update(wordCards)..where((t) => t.id.equals(id))).write(entry);

  Future<void> deleteWordCard(String id) =>
      (delete(wordCards)..where((t) => t.id.equals(id))).go();

  Future<bool> wordExists(String word) async {
    final result = await (select(wordCards)
          ..where((t) => t.word.equals(word.toLowerCase())))
        .getSingleOrNull();
    return result != null;
  }

  Future<int> getCardCount() async {
    final count = countAll();
    final query = selectOnly(wordCards)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> getDueCount() async {
    final count = countAll();
    final query = selectOnly(wordCards)
      ..addColumns([count])
      ..where(wordCards.nextReviewAt.isSmallerOrEqualValue(DateTime.now()));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  // ── Dictionary Cache ────────────────────────────────────────────────────────

  Future<DictionaryCacheEntry?> getCachedDefinition(String word) =>
      (select(dictionaryCache)..where((t) => t.word.equals(word))).getSingleOrNull();

  Future<void> cacheDefinition(String word, String json) =>
      into(dictionaryCache).insertOnConflictUpdate(
        DictionaryCacheCompanion.insert(word: word, responseJson: json),
      );

  // ── Review Logs ─────────────────────────────────────────────────────────────

  Future<void> insertReviewLog(ReviewLogsCompanion entry) =>
      into(reviewLogs).insert(entry);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'video_vocab.db'));
    return NativeDatabase.createInBackground(file);
  });
}
