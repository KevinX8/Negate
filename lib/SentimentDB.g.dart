// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SentimentDB.dart';

// ignore_for_file: type=lint
class SentimentLog extends DataClass implements Insertable<SentimentLog> {
  final int id;
  final String sentence;
  final double score;
  const SentimentLog(
      {required this.id, required this.sentence, required this.score});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sentence'] = Variable<String>(sentence);
    map['score'] = Variable<double>(score);
    return map;
  }

  SentimentLogsCompanion toCompanion(bool nullToAbsent) {
    return SentimentLogsCompanion(
      id: Value(id),
      sentence: Value(sentence),
      score: Value(score),
    );
  }

  factory SentimentLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SentimentLog(
      id: serializer.fromJson<int>(json['id']),
      sentence: serializer.fromJson<String>(json['sentence']),
      score: serializer.fromJson<double>(json['score']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sentence': serializer.toJson<String>(sentence),
      'score': serializer.toJson<double>(score),
    };
  }

  SentimentLog copyWith({int? id, String? sentence, double? score}) =>
      SentimentLog(
        id: id ?? this.id,
        sentence: sentence ?? this.sentence,
        score: score ?? this.score,
      );
  @override
  String toString() {
    return (StringBuffer('SentimentLog(')
          ..write('id: $id, ')
          ..write('sentence: $sentence, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sentence, score);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SentimentLog &&
          other.id == this.id &&
          other.sentence == this.sentence &&
          other.score == this.score);
}

class SentimentLogsCompanion extends UpdateCompanion<SentimentLog> {
  final Value<int> id;
  final Value<String> sentence;
  final Value<double> score;
  const SentimentLogsCompanion({
    this.id = const Value.absent(),
    this.sentence = const Value.absent(),
    this.score = const Value.absent(),
  });
  SentimentLogsCompanion.insert({
    this.id = const Value.absent(),
    required String sentence,
    required double score,
  })  : sentence = Value(sentence),
        score = Value(score);
  static Insertable<SentimentLog> custom({
    Expression<int>? id,
    Expression<String>? sentence,
    Expression<double>? score,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sentence != null) 'sentence': sentence,
      if (score != null) 'score': score,
    });
  }

  SentimentLogsCompanion copyWith(
      {Value<int>? id, Value<String>? sentence, Value<double>? score}) {
    return SentimentLogsCompanion(
      id: id ?? this.id,
      sentence: sentence ?? this.sentence,
      score: score ?? this.score,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sentence.present) {
      map['sentence'] = Variable<String>(sentence.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SentimentLogsCompanion(')
          ..write('id: $id, ')
          ..write('sentence: $sentence, ')
          ..write('score: $score')
          ..write(')'))
        .toString();
  }
}

class $SentimentLogsTable extends SentimentLogs
    with TableInfo<$SentimentLogsTable, SentimentLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SentimentLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sentenceMeta =
      const VerificationMeta('sentence');
  @override
  late final GeneratedColumn<String> sentence = GeneratedColumn<String>(
      'sentence', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 6, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, sentence, score];
  @override
  String get aliasedName => _alias ?? 'sentiment_logs';
  @override
  String get actualTableName => 'sentiment_logs';
  @override
  VerificationContext validateIntegrity(Insertable<SentimentLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sentence')) {
      context.handle(_sentenceMeta,
          sentence.isAcceptableOrUnknown(data['sentence']!, _sentenceMeta));
    } else if (isInserting) {
      context.missing(_sentenceMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SentimentLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SentimentLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sentence: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sentence'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score'])!,
    );
  }

  @override
  $SentimentLogsTable createAlias(String alias) {
    return $SentimentLogsTable(attachedDatabase, alias);
  }
}

abstract class _$SentimentDB extends GeneratedDatabase {
  _$SentimentDB(QueryExecutor e) : super(e);
  _$SentimentDB.connect(DatabaseConnection c) : super.connect(c);
  late final $SentimentLogsTable sentimentLogs = $SentimentLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sentimentLogs];
}
