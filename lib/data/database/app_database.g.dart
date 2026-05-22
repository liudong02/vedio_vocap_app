// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VideosTable extends Videos with TableInfo<$VideosTable, VideoEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VideosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subtitlePathMeta =
      const VerificationMeta('subtitlePath');
  @override
  late final GeneratedColumn<String> subtitlePath = GeneratedColumn<String>(
      'subtitle_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _thumbnailPathMeta =
      const VerificationMeta('thumbnailPath');
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
      'thumbnail_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subtitleOffsetMsMeta =
      const VerificationMeta('subtitleOffsetMs');
  @override
  late final GeneratedColumn<int> subtitleOffsetMs = GeneratedColumn<int>(
      'subtitle_offset_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _subtitlePositionYMeta =
      const VerificationMeta('subtitlePositionY');
  @override
  late final GeneratedColumn<double> subtitlePositionY =
      GeneratedColumn<double>('subtitle_position_y', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(-1));
  static const VerificationMeta _sourceUrlMeta =
      const VerificationMeta('sourceUrl');
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
      'source_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        filePath,
        subtitlePath,
        durationMs,
        thumbnailPath,
        subtitleOffsetMs,
        subtitlePositionY,
        sourceUrl,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'videos';
  @override
  VerificationContext validateIntegrity(Insertable<VideoEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('subtitle_path')) {
      context.handle(
          _subtitlePathMeta,
          subtitlePath.isAcceptableOrUnknown(
              data['subtitle_path']!, _subtitlePathMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
          _thumbnailPathMeta,
          thumbnailPath.isAcceptableOrUnknown(
              data['thumbnail_path']!, _thumbnailPathMeta));
    }
    if (data.containsKey('subtitle_offset_ms')) {
      context.handle(
          _subtitleOffsetMsMeta,
          subtitleOffsetMs.isAcceptableOrUnknown(
              data['subtitle_offset_ms']!, _subtitleOffsetMsMeta));
    }
    if (data.containsKey('subtitle_position_y')) {
      context.handle(
          _subtitlePositionYMeta,
          subtitlePositionY.isAcceptableOrUnknown(
              data['subtitle_position_y']!, _subtitlePositionYMeta));
    }
    if (data.containsKey('source_url')) {
      context.handle(_sourceUrlMeta,
          sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VideoEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VideoEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      subtitlePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtitle_path']),
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      thumbnailPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_path']),
      subtitleOffsetMs: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}subtitle_offset_ms'])!,
      subtitlePositionY: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}subtitle_position_y'])!,
      sourceUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_url']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $VideosTable createAlias(String alias) {
    return $VideosTable(attachedDatabase, alias);
  }
}

class VideoEntry extends DataClass implements Insertable<VideoEntry> {
  final String id;
  final String title;
  final String filePath;
  final String? subtitlePath;
  final int durationMs;
  final String? thumbnailPath;
  final int subtitleOffsetMs;
  final double subtitlePositionY;
  final String? sourceUrl;
  final DateTime createdAt;
  const VideoEntry(
      {required this.id,
      required this.title,
      required this.filePath,
      this.subtitlePath,
      required this.durationMs,
      this.thumbnailPath,
      required this.subtitleOffsetMs,
      required this.subtitlePositionY,
      this.sourceUrl,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || subtitlePath != null) {
      map['subtitle_path'] = Variable<String>(subtitlePath);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['subtitle_offset_ms'] = Variable<int>(subtitleOffsetMs);
    map['subtitle_position_y'] = Variable<double>(subtitlePositionY);
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VideosCompanion toCompanion(bool nullToAbsent) {
    return VideosCompanion(
      id: Value(id),
      title: Value(title),
      filePath: Value(filePath),
      subtitlePath: subtitlePath == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitlePath),
      durationMs: Value(durationMs),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      subtitleOffsetMs: Value(subtitleOffsetMs),
      subtitlePositionY: Value(subtitlePositionY),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      createdAt: Value(createdAt),
    );
  }

  factory VideoEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VideoEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      filePath: serializer.fromJson<String>(json['filePath']),
      subtitlePath: serializer.fromJson<String?>(json['subtitlePath']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      subtitleOffsetMs: serializer.fromJson<int>(json['subtitleOffsetMs']),
      subtitlePositionY: serializer.fromJson<double>(json['subtitlePositionY']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'filePath': serializer.toJson<String>(filePath),
      'subtitlePath': serializer.toJson<String?>(subtitlePath),
      'durationMs': serializer.toJson<int>(durationMs),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'subtitleOffsetMs': serializer.toJson<int>(subtitleOffsetMs),
      'subtitlePositionY': serializer.toJson<double>(subtitlePositionY),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VideoEntry copyWith(
          {String? id,
          String? title,
          String? filePath,
          Value<String?> subtitlePath = const Value.absent(),
          int? durationMs,
          Value<String?> thumbnailPath = const Value.absent(),
          int? subtitleOffsetMs,
          double? subtitlePositionY,
          Value<String?> sourceUrl = const Value.absent(),
          DateTime? createdAt}) =>
      VideoEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        filePath: filePath ?? this.filePath,
        subtitlePath:
            subtitlePath.present ? subtitlePath.value : this.subtitlePath,
        durationMs: durationMs ?? this.durationMs,
        thumbnailPath:
            thumbnailPath.present ? thumbnailPath.value : this.thumbnailPath,
        subtitleOffsetMs: subtitleOffsetMs ?? this.subtitleOffsetMs,
        subtitlePositionY: subtitlePositionY ?? this.subtitlePositionY,
        sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
        createdAt: createdAt ?? this.createdAt,
      );
  VideoEntry copyWithCompanion(VideosCompanion data) {
    return VideoEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      subtitlePath: data.subtitlePath.present
          ? data.subtitlePath.value
          : this.subtitlePath,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      subtitleOffsetMs: data.subtitleOffsetMs.present
          ? data.subtitleOffsetMs.value
          : this.subtitleOffsetMs,
      subtitlePositionY: data.subtitlePositionY.present
          ? data.subtitlePositionY.value
          : this.subtitlePositionY,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VideoEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('subtitlePath: $subtitlePath, ')
          ..write('durationMs: $durationMs, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('subtitleOffsetMs: $subtitleOffsetMs, ')
          ..write('subtitlePositionY: $subtitlePositionY, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, filePath, subtitlePath, durationMs,
      thumbnailPath, subtitleOffsetMs, subtitlePositionY, sourceUrl, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VideoEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.subtitlePath == this.subtitlePath &&
          other.durationMs == this.durationMs &&
          other.thumbnailPath == this.thumbnailPath &&
          other.subtitleOffsetMs == this.subtitleOffsetMs &&
          other.subtitlePositionY == this.subtitlePositionY &&
          other.sourceUrl == this.sourceUrl &&
          other.createdAt == this.createdAt);
}

class VideosCompanion extends UpdateCompanion<VideoEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> filePath;
  final Value<String?> subtitlePath;
  final Value<int> durationMs;
  final Value<String?> thumbnailPath;
  final Value<int> subtitleOffsetMs;
  final Value<double> subtitlePositionY;
  final Value<String?> sourceUrl;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VideosCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.subtitlePath = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.subtitleOffsetMs = const Value.absent(),
    this.subtitlePositionY = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VideosCompanion.insert({
    required String id,
    required String title,
    required String filePath,
    this.subtitlePath = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.subtitleOffsetMs = const Value.absent(),
    this.subtitlePositionY = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        filePath = Value(filePath);
  static Insertable<VideoEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<String>? subtitlePath,
    Expression<int>? durationMs,
    Expression<String>? thumbnailPath,
    Expression<int>? subtitleOffsetMs,
    Expression<double>? subtitlePositionY,
    Expression<String>? sourceUrl,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (subtitlePath != null) 'subtitle_path': subtitlePath,
      if (durationMs != null) 'duration_ms': durationMs,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (subtitleOffsetMs != null) 'subtitle_offset_ms': subtitleOffsetMs,
      if (subtitlePositionY != null) 'subtitle_position_y': subtitlePositionY,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VideosCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? filePath,
      Value<String?>? subtitlePath,
      Value<int>? durationMs,
      Value<String?>? thumbnailPath,
      Value<int>? subtitleOffsetMs,
      Value<double>? subtitlePositionY,
      Value<String?>? sourceUrl,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return VideosCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      subtitlePath: subtitlePath ?? this.subtitlePath,
      durationMs: durationMs ?? this.durationMs,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      subtitleOffsetMs: subtitleOffsetMs ?? this.subtitleOffsetMs,
      subtitlePositionY: subtitlePositionY ?? this.subtitlePositionY,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (subtitlePath.present) {
      map['subtitle_path'] = Variable<String>(subtitlePath.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (subtitleOffsetMs.present) {
      map['subtitle_offset_ms'] = Variable<int>(subtitleOffsetMs.value);
    }
    if (subtitlePositionY.present) {
      map['subtitle_position_y'] = Variable<double>(subtitlePositionY.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VideosCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('subtitlePath: $subtitlePath, ')
          ..write('durationMs: $durationMs, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('subtitleOffsetMs: $subtitleOffsetMs, ')
          ..write('subtitlePositionY: $subtitlePositionY, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WordCardsTable extends WordCards
    with TableInfo<$WordCardsTable, WordCardEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneticMeta =
      const VerificationMeta('phonetic');
  @override
  late final GeneratedColumn<String> phonetic = GeneratedColumn<String>(
      'phonetic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _definitionJsonMeta =
      const VerificationMeta('definitionJson');
  @override
  late final GeneratedColumn<String> definitionJson = GeneratedColumn<String>(
      'definition_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contextMeta =
      const VerificationMeta('context');
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
      'context', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _videoIdMeta =
      const VerificationMeta('videoId');
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
      'video_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _videoTitleMeta =
      const VerificationMeta('videoTitle');
  @override
  late final GeneratedColumn<String> videoTitle = GeneratedColumn<String>(
      'video_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _videoPositionMsMeta =
      const VerificationMeta('videoPositionMs');
  @override
  late final GeneratedColumn<int> videoPositionMs = GeneratedColumn<int>(
      'video_position_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _screenshotPathMeta =
      const VerificationMeta('screenshotPath');
  @override
  late final GeneratedColumn<String> screenshotPath = GeneratedColumn<String>(
      'screenshot_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _easeFactorMeta =
      const VerificationMeta('easeFactor');
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
      'ease_factor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2.5));
  static const VerificationMeta _intervalMeta =
      const VerificationMeta('interval');
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
      'interval', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _repetitionsMeta =
      const VerificationMeta('repetitions');
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
      'repetitions', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nextReviewAtMeta =
      const VerificationMeta('nextReviewAt');
  @override
  late final GeneratedColumn<DateTime> nextReviewAt = GeneratedColumn<DateTime>(
      'next_review_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        word,
        phonetic,
        definitionJson,
        context,
        videoId,
        videoTitle,
        videoPositionMs,
        screenshotPath,
        easeFactor,
        interval,
        repetitions,
        nextReviewAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_cards';
  @override
  VerificationContext validateIntegrity(Insertable<WordCardEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('phonetic')) {
      context.handle(_phoneticMeta,
          phonetic.isAcceptableOrUnknown(data['phonetic']!, _phoneticMeta));
    }
    if (data.containsKey('definition_json')) {
      context.handle(
          _definitionJsonMeta,
          definitionJson.isAcceptableOrUnknown(
              data['definition_json']!, _definitionJsonMeta));
    } else if (isInserting) {
      context.missing(_definitionJsonMeta);
    }
    if (data.containsKey('context')) {
      context.handle(_contextMeta,
          this.context.isAcceptableOrUnknown(data['context']!, _contextMeta));
    } else if (isInserting) {
      context.missing(_contextMeta);
    }
    if (data.containsKey('video_id')) {
      context.handle(_videoIdMeta,
          videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta));
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('video_title')) {
      context.handle(
          _videoTitleMeta,
          videoTitle.isAcceptableOrUnknown(
              data['video_title']!, _videoTitleMeta));
    } else if (isInserting) {
      context.missing(_videoTitleMeta);
    }
    if (data.containsKey('video_position_ms')) {
      context.handle(
          _videoPositionMsMeta,
          videoPositionMs.isAcceptableOrUnknown(
              data['video_position_ms']!, _videoPositionMsMeta));
    } else if (isInserting) {
      context.missing(_videoPositionMsMeta);
    }
    if (data.containsKey('screenshot_path')) {
      context.handle(
          _screenshotPathMeta,
          screenshotPath.isAcceptableOrUnknown(
              data['screenshot_path']!, _screenshotPathMeta));
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
          _easeFactorMeta,
          easeFactor.isAcceptableOrUnknown(
              data['ease_factor']!, _easeFactorMeta));
    }
    if (data.containsKey('interval')) {
      context.handle(_intervalMeta,
          interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta));
    }
    if (data.containsKey('repetitions')) {
      context.handle(
          _repetitionsMeta,
          repetitions.isAcceptableOrUnknown(
              data['repetitions']!, _repetitionsMeta));
    }
    if (data.containsKey('next_review_at')) {
      context.handle(
          _nextReviewAtMeta,
          nextReviewAt.isAcceptableOrUnknown(
              data['next_review_at']!, _nextReviewAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordCardEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordCardEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
      phonetic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phonetic']),
      definitionJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}definition_json'])!,
      context: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context'])!,
      videoId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_id'])!,
      videoTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_title'])!,
      videoPositionMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}video_position_ms'])!,
      screenshotPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}screenshot_path']),
      easeFactor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ease_factor'])!,
      interval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval'])!,
      repetitions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repetitions'])!,
      nextReviewAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_review_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $WordCardsTable createAlias(String alias) {
    return $WordCardsTable(attachedDatabase, alias);
  }
}

class WordCardEntry extends DataClass implements Insertable<WordCardEntry> {
  final String id;
  final String word;
  final String? phonetic;
  final String definitionJson;
  final String context;
  final String videoId;
  final String videoTitle;
  final int videoPositionMs;
  final String? screenshotPath;
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime nextReviewAt;
  final DateTime createdAt;
  const WordCardEntry(
      {required this.id,
      required this.word,
      this.phonetic,
      required this.definitionJson,
      required this.context,
      required this.videoId,
      required this.videoTitle,
      required this.videoPositionMs,
      this.screenshotPath,
      required this.easeFactor,
      required this.interval,
      required this.repetitions,
      required this.nextReviewAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['word'] = Variable<String>(word);
    if (!nullToAbsent || phonetic != null) {
      map['phonetic'] = Variable<String>(phonetic);
    }
    map['definition_json'] = Variable<String>(definitionJson);
    map['context'] = Variable<String>(context);
    map['video_id'] = Variable<String>(videoId);
    map['video_title'] = Variable<String>(videoTitle);
    map['video_position_ms'] = Variable<int>(videoPositionMs);
    if (!nullToAbsent || screenshotPath != null) {
      map['screenshot_path'] = Variable<String>(screenshotPath);
    }
    map['ease_factor'] = Variable<double>(easeFactor);
    map['interval'] = Variable<int>(interval);
    map['repetitions'] = Variable<int>(repetitions);
    map['next_review_at'] = Variable<DateTime>(nextReviewAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WordCardsCompanion toCompanion(bool nullToAbsent) {
    return WordCardsCompanion(
      id: Value(id),
      word: Value(word),
      phonetic: phonetic == null && nullToAbsent
          ? const Value.absent()
          : Value(phonetic),
      definitionJson: Value(definitionJson),
      context: Value(context),
      videoId: Value(videoId),
      videoTitle: Value(videoTitle),
      videoPositionMs: Value(videoPositionMs),
      screenshotPath: screenshotPath == null && nullToAbsent
          ? const Value.absent()
          : Value(screenshotPath),
      easeFactor: Value(easeFactor),
      interval: Value(interval),
      repetitions: Value(repetitions),
      nextReviewAt: Value(nextReviewAt),
      createdAt: Value(createdAt),
    );
  }

  factory WordCardEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordCardEntry(
      id: serializer.fromJson<String>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      phonetic: serializer.fromJson<String?>(json['phonetic']),
      definitionJson: serializer.fromJson<String>(json['definitionJson']),
      context: serializer.fromJson<String>(json['context']),
      videoId: serializer.fromJson<String>(json['videoId']),
      videoTitle: serializer.fromJson<String>(json['videoTitle']),
      videoPositionMs: serializer.fromJson<int>(json['videoPositionMs']),
      screenshotPath: serializer.fromJson<String?>(json['screenshotPath']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      interval: serializer.fromJson<int>(json['interval']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      nextReviewAt: serializer.fromJson<DateTime>(json['nextReviewAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'word': serializer.toJson<String>(word),
      'phonetic': serializer.toJson<String?>(phonetic),
      'definitionJson': serializer.toJson<String>(definitionJson),
      'context': serializer.toJson<String>(context),
      'videoId': serializer.toJson<String>(videoId),
      'videoTitle': serializer.toJson<String>(videoTitle),
      'videoPositionMs': serializer.toJson<int>(videoPositionMs),
      'screenshotPath': serializer.toJson<String?>(screenshotPath),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'interval': serializer.toJson<int>(interval),
      'repetitions': serializer.toJson<int>(repetitions),
      'nextReviewAt': serializer.toJson<DateTime>(nextReviewAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WordCardEntry copyWith(
          {String? id,
          String? word,
          Value<String?> phonetic = const Value.absent(),
          String? definitionJson,
          String? context,
          String? videoId,
          String? videoTitle,
          int? videoPositionMs,
          Value<String?> screenshotPath = const Value.absent(),
          double? easeFactor,
          int? interval,
          int? repetitions,
          DateTime? nextReviewAt,
          DateTime? createdAt}) =>
      WordCardEntry(
        id: id ?? this.id,
        word: word ?? this.word,
        phonetic: phonetic.present ? phonetic.value : this.phonetic,
        definitionJson: definitionJson ?? this.definitionJson,
        context: context ?? this.context,
        videoId: videoId ?? this.videoId,
        videoTitle: videoTitle ?? this.videoTitle,
        videoPositionMs: videoPositionMs ?? this.videoPositionMs,
        screenshotPath:
            screenshotPath.present ? screenshotPath.value : this.screenshotPath,
        easeFactor: easeFactor ?? this.easeFactor,
        interval: interval ?? this.interval,
        repetitions: repetitions ?? this.repetitions,
        nextReviewAt: nextReviewAt ?? this.nextReviewAt,
        createdAt: createdAt ?? this.createdAt,
      );
  WordCardEntry copyWithCompanion(WordCardsCompanion data) {
    return WordCardEntry(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      phonetic: data.phonetic.present ? data.phonetic.value : this.phonetic,
      definitionJson: data.definitionJson.present
          ? data.definitionJson.value
          : this.definitionJson,
      context: data.context.present ? data.context.value : this.context,
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      videoTitle:
          data.videoTitle.present ? data.videoTitle.value : this.videoTitle,
      videoPositionMs: data.videoPositionMs.present
          ? data.videoPositionMs.value
          : this.videoPositionMs,
      screenshotPath: data.screenshotPath.present
          ? data.screenshotPath.value
          : this.screenshotPath,
      easeFactor:
          data.easeFactor.present ? data.easeFactor.value : this.easeFactor,
      interval: data.interval.present ? data.interval.value : this.interval,
      repetitions:
          data.repetitions.present ? data.repetitions.value : this.repetitions,
      nextReviewAt: data.nextReviewAt.present
          ? data.nextReviewAt.value
          : this.nextReviewAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordCardEntry(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('phonetic: $phonetic, ')
          ..write('definitionJson: $definitionJson, ')
          ..write('context: $context, ')
          ..write('videoId: $videoId, ')
          ..write('videoTitle: $videoTitle, ')
          ..write('videoPositionMs: $videoPositionMs, ')
          ..write('screenshotPath: $screenshotPath, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('interval: $interval, ')
          ..write('repetitions: $repetitions, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      word,
      phonetic,
      definitionJson,
      context,
      videoId,
      videoTitle,
      videoPositionMs,
      screenshotPath,
      easeFactor,
      interval,
      repetitions,
      nextReviewAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordCardEntry &&
          other.id == this.id &&
          other.word == this.word &&
          other.phonetic == this.phonetic &&
          other.definitionJson == this.definitionJson &&
          other.context == this.context &&
          other.videoId == this.videoId &&
          other.videoTitle == this.videoTitle &&
          other.videoPositionMs == this.videoPositionMs &&
          other.screenshotPath == this.screenshotPath &&
          other.easeFactor == this.easeFactor &&
          other.interval == this.interval &&
          other.repetitions == this.repetitions &&
          other.nextReviewAt == this.nextReviewAt &&
          other.createdAt == this.createdAt);
}

class WordCardsCompanion extends UpdateCompanion<WordCardEntry> {
  final Value<String> id;
  final Value<String> word;
  final Value<String?> phonetic;
  final Value<String> definitionJson;
  final Value<String> context;
  final Value<String> videoId;
  final Value<String> videoTitle;
  final Value<int> videoPositionMs;
  final Value<String?> screenshotPath;
  final Value<double> easeFactor;
  final Value<int> interval;
  final Value<int> repetitions;
  final Value<DateTime> nextReviewAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WordCardsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.phonetic = const Value.absent(),
    this.definitionJson = const Value.absent(),
    this.context = const Value.absent(),
    this.videoId = const Value.absent(),
    this.videoTitle = const Value.absent(),
    this.videoPositionMs = const Value.absent(),
    this.screenshotPath = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.interval = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordCardsCompanion.insert({
    required String id,
    required String word,
    this.phonetic = const Value.absent(),
    required String definitionJson,
    required String context,
    required String videoId,
    required String videoTitle,
    required int videoPositionMs,
    this.screenshotPath = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.interval = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.nextReviewAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        word = Value(word),
        definitionJson = Value(definitionJson),
        context = Value(context),
        videoId = Value(videoId),
        videoTitle = Value(videoTitle),
        videoPositionMs = Value(videoPositionMs);
  static Insertable<WordCardEntry> custom({
    Expression<String>? id,
    Expression<String>? word,
    Expression<String>? phonetic,
    Expression<String>? definitionJson,
    Expression<String>? context,
    Expression<String>? videoId,
    Expression<String>? videoTitle,
    Expression<int>? videoPositionMs,
    Expression<String>? screenshotPath,
    Expression<double>? easeFactor,
    Expression<int>? interval,
    Expression<int>? repetitions,
    Expression<DateTime>? nextReviewAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (phonetic != null) 'phonetic': phonetic,
      if (definitionJson != null) 'definition_json': definitionJson,
      if (context != null) 'context': context,
      if (videoId != null) 'video_id': videoId,
      if (videoTitle != null) 'video_title': videoTitle,
      if (videoPositionMs != null) 'video_position_ms': videoPositionMs,
      if (screenshotPath != null) 'screenshot_path': screenshotPath,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (interval != null) 'interval': interval,
      if (repetitions != null) 'repetitions': repetitions,
      if (nextReviewAt != null) 'next_review_at': nextReviewAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordCardsCompanion copyWith(
      {Value<String>? id,
      Value<String>? word,
      Value<String?>? phonetic,
      Value<String>? definitionJson,
      Value<String>? context,
      Value<String>? videoId,
      Value<String>? videoTitle,
      Value<int>? videoPositionMs,
      Value<String?>? screenshotPath,
      Value<double>? easeFactor,
      Value<int>? interval,
      Value<int>? repetitions,
      Value<DateTime>? nextReviewAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return WordCardsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      definitionJson: definitionJson ?? this.definitionJson,
      context: context ?? this.context,
      videoId: videoId ?? this.videoId,
      videoTitle: videoTitle ?? this.videoTitle,
      videoPositionMs: videoPositionMs ?? this.videoPositionMs,
      screenshotPath: screenshotPath ?? this.screenshotPath,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (phonetic.present) {
      map['phonetic'] = Variable<String>(phonetic.value);
    }
    if (definitionJson.present) {
      map['definition_json'] = Variable<String>(definitionJson.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (videoTitle.present) {
      map['video_title'] = Variable<String>(videoTitle.value);
    }
    if (videoPositionMs.present) {
      map['video_position_ms'] = Variable<int>(videoPositionMs.value);
    }
    if (screenshotPath.present) {
      map['screenshot_path'] = Variable<String>(screenshotPath.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (nextReviewAt.present) {
      map['next_review_at'] = Variable<DateTime>(nextReviewAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordCardsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('phonetic: $phonetic, ')
          ..write('definitionJson: $definitionJson, ')
          ..write('context: $context, ')
          ..write('videoId: $videoId, ')
          ..write('videoTitle: $videoTitle, ')
          ..write('videoPositionMs: $videoPositionMs, ')
          ..write('screenshotPath: $screenshotPath, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('interval: $interval, ')
          ..write('repetitions: $repetitions, ')
          ..write('nextReviewAt: $nextReviewAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewLogsTable extends ReviewLogs
    with TableInfo<$ReviewLogsTable, ReviewLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<String> wordId = GeneratedColumn<String>(
      'word_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
      'grade', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _intervalBeforeMeta =
      const VerificationMeta('intervalBefore');
  @override
  late final GeneratedColumn<int> intervalBefore = GeneratedColumn<int>(
      'interval_before', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reviewedAtMeta =
      const VerificationMeta('reviewedAt');
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
      'reviewed_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, wordId, grade, intervalBefore, reviewedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_logs';
  @override
  VerificationContext validateIntegrity(Insertable<ReviewLogEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(_wordIdMeta,
          wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta));
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('interval_before')) {
      context.handle(
          _intervalBeforeMeta,
          intervalBefore.isAcceptableOrUnknown(
              data['interval_before']!, _intervalBeforeMeta));
    } else if (isInserting) {
      context.missing(_intervalBeforeMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
          _reviewedAtMeta,
          reviewedAt.isAcceptableOrUnknown(
              data['reviewed_at']!, _reviewedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewLogEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      wordId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word_id'])!,
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grade'])!,
      intervalBefore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval_before'])!,
      reviewedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}reviewed_at'])!,
    );
  }

  @override
  $ReviewLogsTable createAlias(String alias) {
    return $ReviewLogsTable(attachedDatabase, alias);
  }
}

class ReviewLogEntry extends DataClass implements Insertable<ReviewLogEntry> {
  final String id;
  final String wordId;
  final int grade;
  final int intervalBefore;
  final DateTime reviewedAt;
  const ReviewLogEntry(
      {required this.id,
      required this.wordId,
      required this.grade,
      required this.intervalBefore,
      required this.reviewedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['word_id'] = Variable<String>(wordId);
    map['grade'] = Variable<int>(grade);
    map['interval_before'] = Variable<int>(intervalBefore);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    return map;
  }

  ReviewLogsCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogsCompanion(
      id: Value(id),
      wordId: Value(wordId),
      grade: Value(grade),
      intervalBefore: Value(intervalBefore),
      reviewedAt: Value(reviewedAt),
    );
  }

  factory ReviewLogEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewLogEntry(
      id: serializer.fromJson<String>(json['id']),
      wordId: serializer.fromJson<String>(json['wordId']),
      grade: serializer.fromJson<int>(json['grade']),
      intervalBefore: serializer.fromJson<int>(json['intervalBefore']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'wordId': serializer.toJson<String>(wordId),
      'grade': serializer.toJson<int>(grade),
      'intervalBefore': serializer.toJson<int>(intervalBefore),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
    };
  }

  ReviewLogEntry copyWith(
          {String? id,
          String? wordId,
          int? grade,
          int? intervalBefore,
          DateTime? reviewedAt}) =>
      ReviewLogEntry(
        id: id ?? this.id,
        wordId: wordId ?? this.wordId,
        grade: grade ?? this.grade,
        intervalBefore: intervalBefore ?? this.intervalBefore,
        reviewedAt: reviewedAt ?? this.reviewedAt,
      );
  ReviewLogEntry copyWithCompanion(ReviewLogsCompanion data) {
    return ReviewLogEntry(
      id: data.id.present ? data.id.value : this.id,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
      grade: data.grade.present ? data.grade.value : this.grade,
      intervalBefore: data.intervalBefore.present
          ? data.intervalBefore.value
          : this.intervalBefore,
      reviewedAt:
          data.reviewedAt.present ? data.reviewedAt.value : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogEntry(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('grade: $grade, ')
          ..write('intervalBefore: $intervalBefore, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, wordId, grade, intervalBefore, reviewedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLogEntry &&
          other.id == this.id &&
          other.wordId == this.wordId &&
          other.grade == this.grade &&
          other.intervalBefore == this.intervalBefore &&
          other.reviewedAt == this.reviewedAt);
}

class ReviewLogsCompanion extends UpdateCompanion<ReviewLogEntry> {
  final Value<String> id;
  final Value<String> wordId;
  final Value<int> grade;
  final Value<int> intervalBefore;
  final Value<DateTime> reviewedAt;
  final Value<int> rowid;
  const ReviewLogsCompanion({
    this.id = const Value.absent(),
    this.wordId = const Value.absent(),
    this.grade = const Value.absent(),
    this.intervalBefore = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewLogsCompanion.insert({
    required String id,
    required String wordId,
    required int grade,
    required int intervalBefore,
    this.reviewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        wordId = Value(wordId),
        grade = Value(grade),
        intervalBefore = Value(intervalBefore);
  static Insertable<ReviewLogEntry> custom({
    Expression<String>? id,
    Expression<String>? wordId,
    Expression<int>? grade,
    Expression<int>? intervalBefore,
    Expression<DateTime>? reviewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wordId != null) 'word_id': wordId,
      if (grade != null) 'grade': grade,
      if (intervalBefore != null) 'interval_before': intervalBefore,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? wordId,
      Value<int>? grade,
      Value<int>? intervalBefore,
      Value<DateTime>? reviewedAt,
      Value<int>? rowid}) {
    return ReviewLogsCompanion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      grade: grade ?? this.grade,
      intervalBefore: intervalBefore ?? this.intervalBefore,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<String>(wordId.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (intervalBefore.present) {
      map['interval_before'] = Variable<int>(intervalBefore.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogsCompanion(')
          ..write('id: $id, ')
          ..write('wordId: $wordId, ')
          ..write('grade: $grade, ')
          ..write('intervalBefore: $intervalBefore, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DictionaryCacheTable extends DictionaryCache
    with TableInfo<$DictionaryCacheTable, DictionaryCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DictionaryCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
      'word', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _responseJsonMeta =
      const VerificationMeta('responseJson');
  @override
  late final GeneratedColumn<String> responseJson = GeneratedColumn<String>(
      'response_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [word, responseJson, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dictionary_cache';
  @override
  VerificationContext validateIntegrity(
      Insertable<DictionaryCacheEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('word')) {
      context.handle(
          _wordMeta, word.isAcceptableOrUnknown(data['word']!, _wordMeta));
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('response_json')) {
      context.handle(
          _responseJsonMeta,
          responseJson.isAcceptableOrUnknown(
              data['response_json']!, _responseJsonMeta));
    } else if (isInserting) {
      context.missing(_responseJsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {word};
  @override
  DictionaryCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DictionaryCacheEntry(
      word: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word'])!,
      responseJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}response_json'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $DictionaryCacheTable createAlias(String alias) {
    return $DictionaryCacheTable(attachedDatabase, alias);
  }
}

class DictionaryCacheEntry extends DataClass
    implements Insertable<DictionaryCacheEntry> {
  final String word;
  final String responseJson;
  final DateTime cachedAt;
  const DictionaryCacheEntry(
      {required this.word, required this.responseJson, required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['word'] = Variable<String>(word);
    map['response_json'] = Variable<String>(responseJson);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  DictionaryCacheCompanion toCompanion(bool nullToAbsent) {
    return DictionaryCacheCompanion(
      word: Value(word),
      responseJson: Value(responseJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory DictionaryCacheEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DictionaryCacheEntry(
      word: serializer.fromJson<String>(json['word']),
      responseJson: serializer.fromJson<String>(json['responseJson']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'word': serializer.toJson<String>(word),
      'responseJson': serializer.toJson<String>(responseJson),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  DictionaryCacheEntry copyWith(
          {String? word, String? responseJson, DateTime? cachedAt}) =>
      DictionaryCacheEntry(
        word: word ?? this.word,
        responseJson: responseJson ?? this.responseJson,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  DictionaryCacheEntry copyWithCompanion(DictionaryCacheCompanion data) {
    return DictionaryCacheEntry(
      word: data.word.present ? data.word.value : this.word,
      responseJson: data.responseJson.present
          ? data.responseJson.value
          : this.responseJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryCacheEntry(')
          ..write('word: $word, ')
          ..write('responseJson: $responseJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(word, responseJson, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DictionaryCacheEntry &&
          other.word == this.word &&
          other.responseJson == this.responseJson &&
          other.cachedAt == this.cachedAt);
}

class DictionaryCacheCompanion extends UpdateCompanion<DictionaryCacheEntry> {
  final Value<String> word;
  final Value<String> responseJson;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const DictionaryCacheCompanion({
    this.word = const Value.absent(),
    this.responseJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DictionaryCacheCompanion.insert({
    required String word,
    required String responseJson,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : word = Value(word),
        responseJson = Value(responseJson);
  static Insertable<DictionaryCacheEntry> custom({
    Expression<String>? word,
    Expression<String>? responseJson,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (word != null) 'word': word,
      if (responseJson != null) 'response_json': responseJson,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DictionaryCacheCompanion copyWith(
      {Value<String>? word,
      Value<String>? responseJson,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return DictionaryCacheCompanion(
      word: word ?? this.word,
      responseJson: responseJson ?? this.responseJson,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (responseJson.present) {
      map['response_json'] = Variable<String>(responseJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryCacheCompanion(')
          ..write('word: $word, ')
          ..write('responseJson: $responseJson, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VideosTable videos = $VideosTable(this);
  late final $WordCardsTable wordCards = $WordCardsTable(this);
  late final $ReviewLogsTable reviewLogs = $ReviewLogsTable(this);
  late final $DictionaryCacheTable dictionaryCache =
      $DictionaryCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [videos, wordCards, reviewLogs, dictionaryCache];
}

typedef $$VideosTableCreateCompanionBuilder = VideosCompanion Function({
  required String id,
  required String title,
  required String filePath,
  Value<String?> subtitlePath,
  Value<int> durationMs,
  Value<String?> thumbnailPath,
  Value<int> subtitleOffsetMs,
  Value<double> subtitlePositionY,
  Value<String?> sourceUrl,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$VideosTableUpdateCompanionBuilder = VideosCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> filePath,
  Value<String?> subtitlePath,
  Value<int> durationMs,
  Value<String?> thumbnailPath,
  Value<int> subtitleOffsetMs,
  Value<double> subtitlePositionY,
  Value<String?> sourceUrl,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$VideosTableFilterComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subtitlePath => $composableBuilder(
      column: $table.subtitlePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get subtitleOffsetMs => $composableBuilder(
      column: $table.subtitleOffsetMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtitlePositionY => $composableBuilder(
      column: $table.subtitlePositionY,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$VideosTableOrderingComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subtitlePath => $composableBuilder(
      column: $table.subtitlePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get subtitleOffsetMs => $composableBuilder(
      column: $table.subtitleOffsetMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtitlePositionY => $composableBuilder(
      column: $table.subtitlePositionY,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$VideosTableAnnotationComposer
    extends Composer<_$AppDatabase, $VideosTable> {
  $$VideosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get subtitlePath => $composableBuilder(
      column: $table.subtitlePath, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => column);

  GeneratedColumn<int> get subtitleOffsetMs => $composableBuilder(
      column: $table.subtitleOffsetMs, builder: (column) => column);

  GeneratedColumn<double> get subtitlePositionY => $composableBuilder(
      column: $table.subtitlePositionY, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VideosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VideosTable,
    VideoEntry,
    $$VideosTableFilterComposer,
    $$VideosTableOrderingComposer,
    $$VideosTableAnnotationComposer,
    $$VideosTableCreateCompanionBuilder,
    $$VideosTableUpdateCompanionBuilder,
    (VideoEntry, BaseReferences<_$AppDatabase, $VideosTable, VideoEntry>),
    VideoEntry,
    PrefetchHooks Function()> {
  $$VideosTableTableManager(_$AppDatabase db, $VideosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VideosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VideosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VideosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String?> subtitlePath = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<int> subtitleOffsetMs = const Value.absent(),
            Value<double> subtitlePositionY = const Value.absent(),
            Value<String?> sourceUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VideosCompanion(
            id: id,
            title: title,
            filePath: filePath,
            subtitlePath: subtitlePath,
            durationMs: durationMs,
            thumbnailPath: thumbnailPath,
            subtitleOffsetMs: subtitleOffsetMs,
            subtitlePositionY: subtitlePositionY,
            sourceUrl: sourceUrl,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String filePath,
            Value<String?> subtitlePath = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<String?> thumbnailPath = const Value.absent(),
            Value<int> subtitleOffsetMs = const Value.absent(),
            Value<double> subtitlePositionY = const Value.absent(),
            Value<String?> sourceUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VideosCompanion.insert(
            id: id,
            title: title,
            filePath: filePath,
            subtitlePath: subtitlePath,
            durationMs: durationMs,
            thumbnailPath: thumbnailPath,
            subtitleOffsetMs: subtitleOffsetMs,
            subtitlePositionY: subtitlePositionY,
            sourceUrl: sourceUrl,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VideosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VideosTable,
    VideoEntry,
    $$VideosTableFilterComposer,
    $$VideosTableOrderingComposer,
    $$VideosTableAnnotationComposer,
    $$VideosTableCreateCompanionBuilder,
    $$VideosTableUpdateCompanionBuilder,
    (VideoEntry, BaseReferences<_$AppDatabase, $VideosTable, VideoEntry>),
    VideoEntry,
    PrefetchHooks Function()>;
typedef $$WordCardsTableCreateCompanionBuilder = WordCardsCompanion Function({
  required String id,
  required String word,
  Value<String?> phonetic,
  required String definitionJson,
  required String context,
  required String videoId,
  required String videoTitle,
  required int videoPositionMs,
  Value<String?> screenshotPath,
  Value<double> easeFactor,
  Value<int> interval,
  Value<int> repetitions,
  Value<DateTime> nextReviewAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$WordCardsTableUpdateCompanionBuilder = WordCardsCompanion Function({
  Value<String> id,
  Value<String> word,
  Value<String?> phonetic,
  Value<String> definitionJson,
  Value<String> context,
  Value<String> videoId,
  Value<String> videoTitle,
  Value<int> videoPositionMs,
  Value<String?> screenshotPath,
  Value<double> easeFactor,
  Value<int> interval,
  Value<int> repetitions,
  Value<DateTime> nextReviewAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$WordCardsTableFilterComposer
    extends Composer<_$AppDatabase, $WordCardsTable> {
  $$WordCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phonetic => $composableBuilder(
      column: $table.phonetic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get definitionJson => $composableBuilder(
      column: $table.definitionJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get videoId => $composableBuilder(
      column: $table.videoId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get videoTitle => $composableBuilder(
      column: $table.videoTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get videoPositionMs => $composableBuilder(
      column: $table.videoPositionMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get screenshotPath => $composableBuilder(
      column: $table.screenshotPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextReviewAt => $composableBuilder(
      column: $table.nextReviewAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$WordCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordCardsTable> {
  $$WordCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phonetic => $composableBuilder(
      column: $table.phonetic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get definitionJson => $composableBuilder(
      column: $table.definitionJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get context => $composableBuilder(
      column: $table.context, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get videoId => $composableBuilder(
      column: $table.videoId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get videoTitle => $composableBuilder(
      column: $table.videoTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get videoPositionMs => $composableBuilder(
      column: $table.videoPositionMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get screenshotPath => $composableBuilder(
      column: $table.screenshotPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextReviewAt => $composableBuilder(
      column: $table.nextReviewAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$WordCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordCardsTable> {
  $$WordCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get phonetic =>
      $composableBuilder(column: $table.phonetic, builder: (column) => column);

  GeneratedColumn<String> get definitionJson => $composableBuilder(
      column: $table.definitionJson, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumn<String> get videoTitle => $composableBuilder(
      column: $table.videoTitle, builder: (column) => column);

  GeneratedColumn<int> get videoPositionMs => $composableBuilder(
      column: $table.videoPositionMs, builder: (column) => column);

  GeneratedColumn<String> get screenshotPath => $composableBuilder(
      column: $table.screenshotPath, builder: (column) => column);

  GeneratedColumn<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReviewAt => $composableBuilder(
      column: $table.nextReviewAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WordCardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WordCardsTable,
    WordCardEntry,
    $$WordCardsTableFilterComposer,
    $$WordCardsTableOrderingComposer,
    $$WordCardsTableAnnotationComposer,
    $$WordCardsTableCreateCompanionBuilder,
    $$WordCardsTableUpdateCompanionBuilder,
    (
      WordCardEntry,
      BaseReferences<_$AppDatabase, $WordCardsTable, WordCardEntry>
    ),
    WordCardEntry,
    PrefetchHooks Function()> {
  $$WordCardsTableTableManager(_$AppDatabase db, $WordCardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> word = const Value.absent(),
            Value<String?> phonetic = const Value.absent(),
            Value<String> definitionJson = const Value.absent(),
            Value<String> context = const Value.absent(),
            Value<String> videoId = const Value.absent(),
            Value<String> videoTitle = const Value.absent(),
            Value<int> videoPositionMs = const Value.absent(),
            Value<String?> screenshotPath = const Value.absent(),
            Value<double> easeFactor = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<int> repetitions = const Value.absent(),
            Value<DateTime> nextReviewAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WordCardsCompanion(
            id: id,
            word: word,
            phonetic: phonetic,
            definitionJson: definitionJson,
            context: context,
            videoId: videoId,
            videoTitle: videoTitle,
            videoPositionMs: videoPositionMs,
            screenshotPath: screenshotPath,
            easeFactor: easeFactor,
            interval: interval,
            repetitions: repetitions,
            nextReviewAt: nextReviewAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String word,
            Value<String?> phonetic = const Value.absent(),
            required String definitionJson,
            required String context,
            required String videoId,
            required String videoTitle,
            required int videoPositionMs,
            Value<String?> screenshotPath = const Value.absent(),
            Value<double> easeFactor = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<int> repetitions = const Value.absent(),
            Value<DateTime> nextReviewAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WordCardsCompanion.insert(
            id: id,
            word: word,
            phonetic: phonetic,
            definitionJson: definitionJson,
            context: context,
            videoId: videoId,
            videoTitle: videoTitle,
            videoPositionMs: videoPositionMs,
            screenshotPath: screenshotPath,
            easeFactor: easeFactor,
            interval: interval,
            repetitions: repetitions,
            nextReviewAt: nextReviewAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WordCardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WordCardsTable,
    WordCardEntry,
    $$WordCardsTableFilterComposer,
    $$WordCardsTableOrderingComposer,
    $$WordCardsTableAnnotationComposer,
    $$WordCardsTableCreateCompanionBuilder,
    $$WordCardsTableUpdateCompanionBuilder,
    (
      WordCardEntry,
      BaseReferences<_$AppDatabase, $WordCardsTable, WordCardEntry>
    ),
    WordCardEntry,
    PrefetchHooks Function()>;
typedef $$ReviewLogsTableCreateCompanionBuilder = ReviewLogsCompanion Function({
  required String id,
  required String wordId,
  required int grade,
  required int intervalBefore,
  Value<DateTime> reviewedAt,
  Value<int> rowid,
});
typedef $$ReviewLogsTableUpdateCompanionBuilder = ReviewLogsCompanion Function({
  Value<String> id,
  Value<String> wordId,
  Value<int> grade,
  Value<int> intervalBefore,
  Value<DateTime> reviewedAt,
  Value<int> rowid,
});

class $$ReviewLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get intervalBefore => $composableBuilder(
      column: $table.intervalBefore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnFilters(column));
}

class $$ReviewLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wordId => $composableBuilder(
      column: $table.wordId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get intervalBefore => $composableBuilder(
      column: $table.intervalBefore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnOrderings(column));
}

class $$ReviewLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get wordId =>
      $composableBuilder(column: $table.wordId, builder: (column) => column);

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<int> get intervalBefore => $composableBuilder(
      column: $table.intervalBefore, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => column);
}

class $$ReviewLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReviewLogsTable,
    ReviewLogEntry,
    $$ReviewLogsTableFilterComposer,
    $$ReviewLogsTableOrderingComposer,
    $$ReviewLogsTableAnnotationComposer,
    $$ReviewLogsTableCreateCompanionBuilder,
    $$ReviewLogsTableUpdateCompanionBuilder,
    (
      ReviewLogEntry,
      BaseReferences<_$AppDatabase, $ReviewLogsTable, ReviewLogEntry>
    ),
    ReviewLogEntry,
    PrefetchHooks Function()> {
  $$ReviewLogsTableTableManager(_$AppDatabase db, $ReviewLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> wordId = const Value.absent(),
            Value<int> grade = const Value.absent(),
            Value<int> intervalBefore = const Value.absent(),
            Value<DateTime> reviewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewLogsCompanion(
            id: id,
            wordId: wordId,
            grade: grade,
            intervalBefore: intervalBefore,
            reviewedAt: reviewedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String wordId,
            required int grade,
            required int intervalBefore,
            Value<DateTime> reviewedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewLogsCompanion.insert(
            id: id,
            wordId: wordId,
            grade: grade,
            intervalBefore: intervalBefore,
            reviewedAt: reviewedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReviewLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReviewLogsTable,
    ReviewLogEntry,
    $$ReviewLogsTableFilterComposer,
    $$ReviewLogsTableOrderingComposer,
    $$ReviewLogsTableAnnotationComposer,
    $$ReviewLogsTableCreateCompanionBuilder,
    $$ReviewLogsTableUpdateCompanionBuilder,
    (
      ReviewLogEntry,
      BaseReferences<_$AppDatabase, $ReviewLogsTable, ReviewLogEntry>
    ),
    ReviewLogEntry,
    PrefetchHooks Function()>;
typedef $$DictionaryCacheTableCreateCompanionBuilder = DictionaryCacheCompanion
    Function({
  required String word,
  required String responseJson,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});
typedef $$DictionaryCacheTableUpdateCompanionBuilder = DictionaryCacheCompanion
    Function({
  Value<String> word,
  Value<String> responseJson,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$DictionaryCacheTableFilterComposer
    extends Composer<_$AppDatabase, $DictionaryCacheTable> {
  $$DictionaryCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responseJson => $composableBuilder(
      column: $table.responseJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$DictionaryCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $DictionaryCacheTable> {
  $$DictionaryCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get word => $composableBuilder(
      column: $table.word, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responseJson => $composableBuilder(
      column: $table.responseJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$DictionaryCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $DictionaryCacheTable> {
  $$DictionaryCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get responseJson => $composableBuilder(
      column: $table.responseJson, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$DictionaryCacheTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DictionaryCacheTable,
    DictionaryCacheEntry,
    $$DictionaryCacheTableFilterComposer,
    $$DictionaryCacheTableOrderingComposer,
    $$DictionaryCacheTableAnnotationComposer,
    $$DictionaryCacheTableCreateCompanionBuilder,
    $$DictionaryCacheTableUpdateCompanionBuilder,
    (
      DictionaryCacheEntry,
      BaseReferences<_$AppDatabase, $DictionaryCacheTable, DictionaryCacheEntry>
    ),
    DictionaryCacheEntry,
    PrefetchHooks Function()> {
  $$DictionaryCacheTableTableManager(
      _$AppDatabase db, $DictionaryCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DictionaryCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DictionaryCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DictionaryCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> word = const Value.absent(),
            Value<String> responseJson = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DictionaryCacheCompanion(
            word: word,
            responseJson: responseJson,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String word,
            required String responseJson,
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DictionaryCacheCompanion.insert(
            word: word,
            responseJson: responseJson,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DictionaryCacheTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DictionaryCacheTable,
    DictionaryCacheEntry,
    $$DictionaryCacheTableFilterComposer,
    $$DictionaryCacheTableOrderingComposer,
    $$DictionaryCacheTableAnnotationComposer,
    $$DictionaryCacheTableCreateCompanionBuilder,
    $$DictionaryCacheTableUpdateCompanionBuilder,
    (
      DictionaryCacheEntry,
      BaseReferences<_$AppDatabase, $DictionaryCacheTable, DictionaryCacheEntry>
    ),
    DictionaryCacheEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VideosTableTableManager get videos =>
      $$VideosTableTableManager(_db, _db.videos);
  $$WordCardsTableTableManager get wordCards =>
      $$WordCardsTableTableManager(_db, _db.wordCards);
  $$ReviewLogsTableTableManager get reviewLogs =>
      $$ReviewLogsTableTableManager(_db, _db.reviewLogs);
  $$DictionaryCacheTableTableManager get dictionaryCache =>
      $$DictionaryCacheTableTableManager(_db, _db.dictionaryCache);
}
