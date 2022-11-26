import 'dart:io';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift/isolate.dart';
import 'package:negate/SentimentDB.dart';

abstract class SentenceLogger {
  static StringBuffer sentence = StringBuffer();
  static late SentimentDB db;

  SentenceLogger();

  static logScore() async {
    log(sentence.toString());
    double score = 0.5;
    if (sentence.toString().length >= 6) {
      db.into(db.sentimentLogs).insert(SentimentLog(id: 0, sentence: sentence.toString(), score: score));
    }

    sentence.clear();
  }

  static Future<void> startLogger(IsolateStartRequest request) async {
    var executor = NativeDatabase(File(request.targetPath));
    final driftIsolate = DriftIsolate.inCurrent(
        () => DatabaseConnection(executor),
    );

    db = SentimentDB.connect(DatabaseConnection(executor));

    request.sendDriftIsolate.send(driftIsolate);
  }
}