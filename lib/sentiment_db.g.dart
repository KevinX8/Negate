// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sentiment_db.dart';

// ignore_for_file: type=lint
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
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 256),
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

class $AppIconsTable extends AppIcons with TableInfo<$AppIconsTable, AppIcon> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppIconsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 256),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<Uint8List> icon = GeneratedColumn<Uint8List>(
      'icon', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [name, icon];
  @override
  String get aliasedName => _alias ?? 'app_icons';
  @override
  String get actualTableName => 'app_icons';
  @override
  VerificationContext validateIntegrity(Insertable<AppIcon> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  AppIcon map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppIcon(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}icon'])!,
    );
  }

  @override
  $AppIconsTable createAlias(String alias) {
    return $AppIconsTable(attachedDatabase, alias);
  }
}

class AppIcon extends DataClass implements Insertable<AppIcon> {
  final String name;
  final Uint8List icon;
  const AppIcon({required this.name, required this.icon});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<Uint8List>(icon);
    return map;
  }

  AppIconsCompanion toCompanion(bool nullToAbsent) {
    return AppIconsCompanion(
      name: Value(name),
      icon: Value(icon),
    );
  }

  factory AppIcon.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppIcon(
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<Uint8List>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<Uint8List>(icon),
    };
  }

  AppIcon copyWith({String? name, Uint8List? icon}) => AppIcon(
        name: name ?? this.name,
        icon: icon ?? this.icon,
      );
  @override
  String toString() {
    return (StringBuffer('AppIcon(')
          ..write('name: $name, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, $driftBlobEquality.hash(icon));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppIcon &&
          other.name == this.name &&
          $driftBlobEquality.equals(other.icon, this.icon));
}

class AppIconsCompanion extends UpdateCompanion<AppIcon> {
  final Value<String> name;
  final Value<Uint8List> icon;
  const AppIconsCompanion({
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
  });
  AppIconsCompanion.insert({
    required String name,
    required Uint8List icon,
  })  : name = Value(name),
        icon = Value(icon);
  static Insertable<AppIcon> custom({
    Expression<String>? name,
    Expression<Uint8List>? icon,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
    });
  }

  AppIconsCompanion copyWith({Value<String>? name, Value<Uint8List>? icon}) {
    return AppIconsCompanion(
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<Uint8List>(icon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppIconsCompanion(')
          ..write('name: $name, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }
}

abstract class _$SentimentDB extends GeneratedDatabase {
  _$SentimentDB(QueryExecutor e) : super(e);
  _$SentimentDB.connect(DatabaseConnection c) : super.connect(c);
  late final $SentimentLogsTable sentimentLogs = $SentimentLogsTable(this);
  late final $AppIconsTable appIcons = $AppIconsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sentimentLogs, appIcons];
}
