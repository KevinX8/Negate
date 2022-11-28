import 'dart:io';
import 'dart:developer';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift/isolate.dart';
import 'package:negate/sentiment_db.dart';

abstract class SentenceLogger {
  static StringBuffer sentence = StringBuffer();
  static late DriftIsolate iso;
  static late TfParams tfp;

  SentenceLogger();

  static Future<void> logScore() async {
    final String slog = sentence.toString();
    log(slog);
    if (slog.length >= 6) {
      Isolate.spawn(SentimentDB.addSentiment, AddSentimentRequest(slog, iso.connectPort, tfp));
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

  static Future<void> startLogger(TfliteRequest request) async {
    var rPort = ReceivePort();
    await Isolate.spawn(
      _startBackground,
      IsolateStartRequest(sendDriftIsolate: rPort.sendPort, targetPath: request.targetPath),
    );

    iso = await rPort.first as DriftIsolate;
    tfp = request.tfp;
    request.sendDriftIsolate.send(iso.connectPort);
  }

  static Future<void> Function(TfliteRequest) getLoggerFactory() {
    throw UnsupportedError("Platform not supported");
  }
}