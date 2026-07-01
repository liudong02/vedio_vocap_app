import 'package:drift/drift.dart';

@DataClassName('VideoEntry')
class Videos extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get filePath => text()();
  TextColumn get subtitlePath => text().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get thumbnailPath => text().nullable()();
  IntColumn get subtitleOffsetMs => integer().withDefault(const Constant(0))();
  RealColumn get subtitlePositionY => real().withDefault(const Constant(-1))();
  TextColumn get sourceUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WordCardEntry')
class WordCards extends Table {
  TextColumn get id => text()();
  TextColumn get word => text()();
  TextColumn get phonetic => text().nullable()();
  TextColumn get definitionJson => text()();
  TextColumn get context => text()();
  TextColumn get videoId => text()();
  TextColumn get videoTitle => text()();
  IntColumn get videoPositionMs => integer()();
  TextColumn get screenshotPath => text().nullable()();
  // SM-2 scheduling fields
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get interval => integer().withDefault(const Constant(1))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextReviewAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReviewLogEntry')
class ReviewLogs extends Table {
  TextColumn get id => text()();
  TextColumn get wordId => text()();
  IntColumn get grade => integer()();
  IntColumn get intervalBefore => integer()();
  DateTimeColumn get reviewedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DictionaryCacheEntry')
class DictionaryCache extends Table {
  TextColumn get word => text()();
  TextColumn get responseJson => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {word};
}

@DataClassName('WordBankEntry')
class WordBankItems extends Table {
  IntColumn get wordIndex => integer()();
  TextColumn get word => text()();
  TextColumn get level => text()();
  IntColumn get status => integer().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get interval => integer().withDefault(const Constant(1))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextReviewAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {wordIndex};
}

@DataClassName('ChallengeProgressEntry')
class ChallengeProgress extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get totalScanned => integer().withDefault(const Constant(0))();
  IntColumn get totalMastered => integer().withDefault(const Constant(0))();
  IntColumn get todayLearned => integer().withDefault(const Constant(0))();
  IntColumn get streakDays => integer().withDefault(const Constant(0))();
  TextColumn get lastActiveDay => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
