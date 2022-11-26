import 'dart:io';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift/isolate.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:negate/SentimentDB.dart';
import 'package:negate/logger.dart';
import 'package:negate/SentimentDB.dart';

abstract class SentenceLogger {
  static StringBuffer sentence = StringBuffer();
  static late SentimentDB db;

  SentenceLogger();

  static logScore() async {
    log(sentence.toString());
    double score = 0.5;
    try {
      await db.into(db.sentimentLogs).insert(SentimentLog(id: 0, sentence: sentence.toString(), score: score));
    } on DriftRemoteException catch (_, e) {
      log(e.toString());
    }
    sentence.clear();
  }

  static Future<void> startLogger(IsolateStartRequest request) async {
    var executor = NativeDatabase(File(request.targetPath));
    final driftIsolate = DriftIsolate.inCurrent(
        () => DatabaseConnection(executor),
    );

    try {
      db = SentimentDB.connect(await driftIsolate.connect());
    } on DriftRemoteException catch (_, e) {
      log(e.toString());
    }
    request.sendDriftIsolate.send(driftIsolate);
  }
}