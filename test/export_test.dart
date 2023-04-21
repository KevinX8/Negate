import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:negate/sentiment_db.dart';

void main() {
  test('Database Export Test', () async {
    WidgetsFlutterBinding.ensureInitialized();

    SentimentDB sdb = SentimentDB();
    //export logs to json
    String logs = await sdb.jsonLogs();
    expect(logs, isNotEmpty);

    //import logs from json
    bool res = await sdb.jsonImport(logs);
    expect(res, true);

    //export logs to json again and compare
    String newLogs = await sdb.jsonLogs();
    expect(logs, newLogs);
  });
}