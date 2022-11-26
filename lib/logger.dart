import 'dart:io';
import 'dart:developer';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift/isolate.dart';
import 'package:negate/SentimentDB.dart';

abstract class SentenceLogger {
  static StringBuffer sentence = StringBuffer();
  static late SentimentDB db;

  SentenceLogger();

  static Future<void> logScore() async {
    log(sentence.toString());
    double score = 0.5;
    if (sentence.toString().length >= 6) {
      await db.addSentiment(sentence.toString(), score);
    }
    sentence.clear();
  }

  static void _startBackground(IsolateStartRequest request) {
    // this is the entry point from the background isolate! Let's create
    // the database from the path we received
    final executor = NativeDatabase(File(request.targetPath));
    // we're using DriftIsolate.inCurrent here as this method already runs on a
    // background isolate. If we used DriftIsolate.spawn, a third isolate would be
    // started which is not what we want!
    final driftIsolate = DriftIsolate.inCurrent(
          () => DatabaseConnection(executor),
    );
    // inform the starting isolate about this, so that it can call .connect()
    request.sendDriftIsolate.send(driftIsolate);
  }

  static Future<void> startLogger(IsolateStartRequest request) async {
    var rPort = ReceivePort();
    await Isolate.spawn(
      _startBackground,
      IsolateStartRequest(rPort.sendPort, request.targetPath),
    );

    var isolate = await rPort.first as DriftIsolate;
    request.sendDriftIsolate.send(isolate.connectPort);

    DatabaseConnection conn = await isolate.connect( isolateDebugLog: true);
    db = SentimentDB.connect(conn);
  }
}