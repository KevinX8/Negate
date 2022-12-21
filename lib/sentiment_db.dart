import 'dart:isolate';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:negate/sentiment_analysis.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'sentiment_db.g.dart';

class SentimentLogs extends Table {

  TextColumn get name => text().withLength(min: 3, max: 20)();
  IntColumn get hour => integer()();
  IntColumn get timeUsed => integer()();
  RealColumn get avgScore => real()();

  @override
  Set<Column> get primaryKey => {name, hour};
}

@DriftDatabase(tables: [SentimentLogs])
class SentimentDB extends _$SentimentDB {
  // we tell the database where to store the data with this constructor
  SentimentDB() : super(_openConnection());
  //SentimentDB.ndb(NativeDatabase db): super(LazyDatabase(() async {return db;}));

  SentimentDB.connect(DatabaseConnection connection) : super.connect(connection);
  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 1;

  Future<SentimentLog> getLastSentiment() async {
    return await (select(sentimentLogs)..orderBy([(t) => OrderingTerm(expression: sentimentLogs.id, mode: OrderingMode.desc)])..limit(1)).getSingle();
  }

  static Future<void> addSentiment(AddSentimentRequest r) async {
    var analyser = SentimentAnalysis.isolate(r.tfp.iAddress, r.tfp.dict);
    double score = analyser.classify(r.sentence);
    log(score.toString());

    var entry = SentimentLogsCompanion(sentence: Value(r.sentence), score: Value(score));
    var isolate = DriftIsolate.fromConnectPort(r.iPort);
    var sdb = SentimentDB.connect(await isolate.connect());

    await sdb.into(sdb.sentimentLogs).insert(entry);
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
  final String sentence;
  final SendPort iPort;
  final TfParams tfp;

  AddSentimentRequest(this.sentence, this.iPort, this.tfp);
}