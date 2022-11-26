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

  static logScore() async {
    log(sentence.toString());
    double score = 0.5;
    if (sentence.toString().length >= 6) {
      db.addSentiment(sentence.toString(), score);
    }
    sentence.clear();
  }

  static Future<void> startLogger(SendPort iPort) async {
    var isolate = DriftIsolate.fromConnectPort(iPort);
    DatabaseConnection conn = await isolate.connect();
    db = SentimentDB.connect(conn);
    await db.addSentiment("yoooorooo", 0.612);
  }
}