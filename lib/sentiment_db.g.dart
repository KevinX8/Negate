// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sentiment_db.dart';

// ignore_for_file: type=lint
class SentimentLog extends DataClass implements Insertable<SentimentLog> {
  final String name;
  final DateTime hour;
  final int timeUsed;
  final double avgScore;
  const SentimentLog(
      {required this.name,
      required this.hour,
      required this.timeUsed,
      required this.avgScore});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['hour'] = Variable<DateTime>(hour);
    map['time_used'] = Variable<int>(timeUsed);
    map['avg_score'] = Variable<double>(avgScore);
    return map;
  }

  SentimentLogsCompanion toCompanion(bool nullToAbsent) {
    return SentimentLogsCompanion(
      name: Value(name),
      hour: Value(hour),
      timeUsed: Value(timeUsed),
      avgScore: Value(avgScore),
    );
  }

  factory SentimentLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SentimentLog(
      name: serializer.fromJson<String>(json['name']),
      hour: serializer.fromJson<DateTime>(json['hour']),
      timeUsed: serializer.fromJson<int>(json['timeUsed']),
      avgScore: serializer.fromJson<double>(json['avgScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'hour': serializer.toJson<DateTime>(hour),
      'timeUsed': serializer.toJson<int>(timeUsed),
      'avgScore': serializer.toJson<double>(avgScore),
    };
  }

  SentimentLog copyWith(
          {String? name, DateTime? hour, int? timeUsed, double? avgScore}) =>
      SentimentLog(
        name: name ?? this.name,
        hour: hour ?? this.hour,
        timeUsed: timeUsed ?? this.timeUsed,
        avgScore: avgScore ?? this.avgScore,
      );
  @override
  String toString() {
    return (StringBuffer('SentimentLog(')
          ..write('name: $name, ')
          ..write('hour: $hour, ')
          ..write('timeUsed: $timeUsed, ')
          ..write('avgScore: $avgScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, hour, timeUsed, avgScore);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SentimentLog &&
          other.name == this.name &&
          other.hour == this.hour &&
          other.timeUsed == this.timeUsed &&
          other.avgScore == this.avgScore);
}

class SentimentLogsCompanion extends UpdateCompanion<SentimentLog> {
  final Value<String> name;
  final Value<DateTime> hour;
  final Value<int> timeUsed;
  final Value<double> avgScore;
  const SentimentLogsCompanion({
    this.name = const Value.absent(),
    this.hour = const Value.absent(),
    this.timeUsed = const Value.absent(),
    this.avgScore = const Value.absent(),
  });
  SentimentLogsCompanion.insert({
    required String name,
    required DateTime hour,
    required int timeUsed,
    required double avgScore,
  })  : name = Value(name),
        hour = Value(hour),
        timeUsed = Value(timeUsed),
        avgScore = Value(avgScore);
  static Insertable<SentimentLog> custom({
    Expression<String>? name,
    Expression<DateTime>? hour,
    Expression<int>? timeUsed,
    Expression<double>? avgScore,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (hour != null) 'hour': hour,
      if (timeUsed != null) 'time_used': timeUsed,
      if (avgScore != null) 'avg_score': avgScore,
    });
  }

  SentimentLogsCompanion copyWith(
      {Value<String>? name,
      Value<DateTime>? hour,
      Value<int>? timeUsed,
      Value<double>? avgScore}) {
    return SentimentLogsCompanion(
      name: name ?? this.name,
      hour: hour ?? this.hour,
      timeUsed: timeUsed ?? this.timeUsed,
      avgScore: avgScore ?? this.avgScore,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (hour.present) {
      map['hour'] = Variable<DateTime>(hour.value);
    }
    if (timeUsed.present) {
      map['time_used'] = Variable<int>(timeUsed.value);
    }
    if (avgScore.present) {
      map['avg_score'] = Variable<double>(avgScore.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SentimentLogsCompanion(')
          ..write('name: $name, ')
          ..write('hour: $hour, ')
          ..write('timeUsed: $timeUsed, ')
          ..write('avgScore: $avgScore')
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<DateTime> hour = GeneratedColumn<DateTime>(
      'hour', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _timeUsedMeta =
      const VerificationMeta('timeUsed');
  @override
  late final GeneratedColumn<int> timeUsed = GeneratedColumn<int>(
      'time_used', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _avgScoreMeta =
      const VerificationMeta('avgScore');
  @override
  late final GeneratedColumn<double> avgScore = GeneratedColumn<double>(
      'avg_score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [name, hour, timeUsed, avgScore];
  @override
  String get aliasedName => _alias ?? 'sentiment_logs';
  @override
  String get actualTableName => 'sentiment_logs';
  @override
  VerificationContext validateIntegrity(Insertable<SentimentLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('hour')) {
      context.handle(
          _hourMeta, hour.isAcceptableOrUnknown(data['hour']!, _hourMeta));
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('time_used')) {
      context.handle(_timeUsedMeta,
          timeUsed.isAcceptableOrUnknown(data['time_used']!, _timeUsedMeta));
    } else if (isInserting) {
      context.missing(_timeUsedMeta);
    }
    if (data.containsKey('avg_score')) {
      context.handle(_avgScoreMeta,
          avgScore.isAcceptableOrUnknown(data['avg_score']!, _avgScoreMeta));
    } else if (isInserting) {
      context.missing(_avgScoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name, hour};
  @override
  SentimentLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SentimentLog(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      hour: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}hour'])!,
      timeUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_used'])!,
      avgScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}avg_score'])!,
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
