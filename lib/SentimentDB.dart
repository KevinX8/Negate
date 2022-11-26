import 'dart:isolate';

import 'package:drift/drift.dart';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'SentimentDB.g.dart';

class SentimentLogs extends Table {

  IntColumn get id => integer().autoIncrement()();
  TextColumn get sentence => text().withLength(min: 6, max: 50)();
  RealColumn get score => real()();
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
    return await (select(sentimentLogs)..orderBy([(t) => OrderingTerm(expression: sentimentLogs.id)])..limit(1)).getSingle();
  }

  Future<int> addSentiment(String sentence, double score) async {
    var entry = SentimentLogsCompanion(sentence: Value(sentence), score: Value(score));
    return await into(sentimentLogs).insert(entry);
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

  IsolateStartRequest(this.sendDriftIsolate, this.targetPath);
}