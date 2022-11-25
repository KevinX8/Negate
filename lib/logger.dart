import 'dart:io';
import 'dart:developer';

import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class SentimentLog {
  SentimentLog({required this.sentence, required this.score});

  @HiveField(0)
  String sentence;

  @HiveField(1)
  double score;


  @override
  String toString() {
    return '$sentence: $score';
  }
}

abstract class SentenceLogger {
  static StringBuffer sentence = StringBuffer();
  static String dbName = "";

  SentenceLogger();

  static logScore() async {
    log(sentence.toString());
    double score = 0.5;
    var slog = SentimentLog(
        sentence: sentence.toString(),
        score: score);
    var db = await Hive.openLazyBox(dbName);
    await db.put("testScore", slog);
    await db.close();
    sentence.clear();
  }

  static Future<void> startLogger(String boxName) async {
    dbName = boxName;
  }

}