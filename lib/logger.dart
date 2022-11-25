import 'dart:io';
import 'dart:developer';

import 'package:hive_flutter/adapters.dart';
import 'package:negate/SentimentDB.dart';
import 'package:negate/logger.dart';

abstract class SentenceLogger {
  static StringBuffer sentence = StringBuffer();
  static late SentimentDB db;

  SentenceLogger();

  static logScore() async {
    log(sentence.toString());
    double score = 0.5;
    await db.into(db.sentimentLogs).insert(SentimentLog(id: 0, sentence: sentence.toString(), score: score));
    sentence.clear();
  }

  static Future<void> startLogger(SentimentDB sdb) async {
    db = sdb;
    log(db.toString());
  }
}