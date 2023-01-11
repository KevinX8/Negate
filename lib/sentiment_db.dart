import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:negate/logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'sentiment_db.g.dart';

class SentimentLogs extends Table {
  TextColumn get name => text().withLength(min: 3, max: 256)();
  DateTimeColumn get hour => dateTime()();
  IntColumn get timeUsed => integer()();
  RealColumn get avgScore => real()();

  @override
  Set<Column> get primaryKey => {name, hour};
}

class AppIcons extends Table {
  TextColumn get name => text().withLength(min: 3, max: 256)();
  BlobColumn get icon => blob()();

  @override
  Set<Column> get primaryKey => {name};
}

@DriftDatabase(tables: [SentimentLogs, AppIcons])
class SentimentDB extends _$SentimentDB {
  // we tell the database where to store the data with this constructor
  SentimentDB() : super(_openConnection());
  //SentimentDB.ndb(NativeDatabase db): super(LazyDatabase(() async {return db;}));

  SentimentDB.connect(DatabaseConnection connection) : super.connect(connection);
  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 1;

  Future<Uint8List> getAppIcon(String name) async {
    var ico = await (select(appIcons)..where((tbl) => tbl.name.equals(name))).getSingle();
    return ico.icon;
  }

  Future<HashSet<String>> getListOfIcons() async {
    var set = HashSet<String>();
    var iconList = await (selectOnly(appIcons)..addColumns([appIcons.name])).get();
    for (var ico in iconList) {
      set.add(ico.read(appIcons.name)!);
    }
    return set;
  }

  Future<String> jsonLogs() async {
    var query = select(sentimentLogs);
    var res = await query.get();
    return jsonEncode(res);
  }

  Future<List<List<MapEntry<String, List<double>>>>> getRecommendations() async {
    var query = select(sentimentLogs)..where((tbl) =>
        tbl.hour.isBiggerOrEqualValue(DateTime.now().subtract(const Duration(days: 7))));
    Map<String, List<double>> weeklyAverage = <String, List<double>>{};
    Map<String, int> weeklyCount = <String, int>{};
    var res = await query.get();
    for (var log in res) {
      if (weeklyAverage.containsKey(log.name)) {
        weeklyAverage[log.name]![0] = ((weeklyAverage[log.name]![0] * weeklyCount[log.name]!) + log.avgScore) / (weeklyCount[log.name]! + 1);
        weeklyCount[log.name] = weeklyCount[log.name]! + 1;
        weeklyAverage[log.name]![1] = weeklyAverage[log.name]![1] + log.timeUsed;
      } else {
        weeklyAverage.putIfAbsent(log.name, () => [log.avgScore, log.timeUsed.toDouble()]);
        weeklyCount.putIfAbsent(log.name, () => 1);
      }
    }
    var sorted = weeklyAverage.entries.toList();
    //Ignore apps used for less than 10 minutes
    sorted.removeWhere((element) => element.value[1] < 10);
    sorted.sort((a, b) => a.value[0].compareTo(b.value[0]));
    var negative = sorted.sublist(0,5);
    var positive = sorted.reversed.toList().sublist(0, 5);
    return [negative, positive];
  }

  Future<List<double>> getAvgHourlySentiment(DateTime date) async {
    var query = (select(sentimentLogs)..where((tbl) => tbl.hour.year.equals(date.year)
        & tbl.hour.month.equals(date.month)
        & tbl.hour.day.equals(date.day)));
    var res = await query.get();
    var avgs = List<double>.filled(24, 0);
    var totalTime = List<int>.filled(24, 0);
    for (var i in res) {
      avgs[i.hour.hour] += i.avgScore * i.timeUsed;
      totalTime[i.hour.hour] += i.timeUsed;
    }
    for (int i = 0; i < 24;i++) {
      if (avgs[i] == 0) {
        continue;
      }
      avgs[i] /= totalTime[i];
    }
    return avgs;
  }

  Future<List<SentimentLog>> getDaySentiment(DateTime time) async {
    return await (select(sentimentLogs)..where((tbl) {
      return tbl.hour.equals(time.alignDateTime(const Duration(hours: 1)));
    })..orderBy(
        [(t) => OrderingTerm(expression: sentimentLogs.timeUsed, mode: OrderingMode.desc)]
    )).get();
  }

  static Future<void> addAppIcon(AddAppIconRequest r) async {
    var isolate = DriftIsolate.fromConnectPort(r.iPort);
    var sdb = SentimentDB.connect(await isolate.connect());
    var entry = AppIconsCompanion(name: Value(r.name), icon: Value(r.icon));
    sdb.into(sdb.appIcons).insert(entry);
  }

  static Future<void> addSentiments(AddSentimentRequest r) async {
    var isolate = DriftIsolate.fromConnectPort(r.iPort);
    var sdb = SentimentDB.connect(await isolate.connect());
    await sdb.batch((batch) {
      List<SentimentLogsCompanion> logs = <SentimentLogsCompanion>[];
      for (var log in r.sentiments.entries) {
        var entry = SentimentLogsCompanion(name: Value(log.key), hour: Value(
            log.value.lastTimeUsed.alignDateTime(const Duration(hours: 1))),
            timeUsed: Value(log.value.totalTimeUsed.ceil()), avgScore: Value(log.value.avgScore));
        logs.add(entry);
      }
      batch.insertAllOnConflictUpdate(sdb.sentimentLogs, logs);
    });
  }
}

extension Alignment on DateTime {
  DateTime alignDateTime(Duration alignment,
      [bool roundUp = false]) {
    assert(alignment >= Duration.zero);
    if (alignment == Duration.zero) return this;
    final correction = Duration(
        days: 0,
        hours: alignment.inDays > 0
            ? hour
            : alignment.inHours > 0
            ? hour % alignment.inHours
            : 0,
        minutes: alignment.inHours > 0
            ? minute
            : alignment.inMinutes > 0
            ? minute % alignment.inMinutes
            : 0,
        seconds: alignment.inMinutes > 0
            ? second
            : alignment.inSeconds > 0
            ? second % alignment.inSeconds
            : 0,
        milliseconds: alignment.inSeconds > 0
            ? millisecond
            : alignment.inMilliseconds > 0
            ? millisecond % alignment.inMilliseconds
            : 0,
        microseconds: alignment.inMilliseconds > 0 ? microsecond : 0);
    if (correction == Duration.zero) return this;
    final corrected = subtract(correction);
    final result = roundUp ? corrected.add(alignment) : corrected;
    return result;
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

class IsolateStartRequest {
  final SendPort sendDriftIsolate;
  final String targetPath;

  IsolateStartRequest({required this.sendDriftIsolate, required this.targetPath});
}

class TfParams {
  final int iAddress;
  final Map<String, int> dict;

  TfParams(this.iAddress, this.dict);
}

class TfliteRequest extends IsolateStartRequest {
  final TfParams tfp;

  TfliteRequest(SendPort sendDriftIsolate,String targetPath, this.tfp) : super(sendDriftIsolate: sendDriftIsolate, targetPath: targetPath);
}

class AddSentimentRequest {
  final HashMap<String, AppList> sentiments;
  final SendPort iPort;

  AddSentimentRequest(this.sentiments, this.iPort);
}

class AddAppIconRequest {
  final String name;
  final Uint8List icon;
  final SendPort iPort;

  AddAppIconRequest(this.name, this.icon, this.iPort);
}