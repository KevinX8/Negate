import 'dart:io';
import 'dart:developer';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift/isolate.dart';
import 'package:negate/sentiment_db.dart';

class SentenceLogger {
  static final SentenceLogger _instance = SentenceLogger.init();
  static final StringBuffer _sentence = StringBuffer();
  static late DriftIsolate _iso;
  static late TfParams _tfp;

  factory SentenceLogger() {
    return _instance;
  }

  SentenceLogger.init();

  Future<void> logScore() async {
    final String slog = _sentence.toString();
    log(slog);
    if (slog.length >= 6) {
      Isolate.spawn(SentimentDB.addSentiment, AddSentimentRequest(slog, _iso.connectPort, _tfp));
    }
    _sentence.clear();
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

  Future<void> startLogger(TfliteRequest request) async {
    var rPort = ReceivePort();
    await Isolate.spawn(
      _startBackground,
      IsolateStartRequest(sendDriftIsolate: rPort.sendPort, targetPath: request.targetPath),
    );

    _iso = await rPort.first as DriftIsolate;
    _tfp = request.tfp;
    request.sendDriftIsolate.send(_iso.connectPort);
  }

  Future<void> Function(TfliteRequest) getLogger() {
    throw UnsupportedError("Platform not supported");
  }

  String getSentence() {
    return SentenceLogger._sentence.toString();
  }

  void writeToSentence(Object? obj) {
    SentenceLogger._sentence.write(obj);
  }

  void clearSentence() {
    SentenceLogger._sentence.clear();
  }
}