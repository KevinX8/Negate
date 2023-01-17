import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../sentiment_db.dart';

final dbProvider = StateNotifierProvider((ref) {
  return DBMonitor();
});

final getIt = GetIt.instance;
DateTime selectedDate = DateTime.now();

class DBMonitor extends StateNotifier<List<SentimentLog>> {
  DBMonitor() : super(<SentimentLog>[]);

  void set(List<SentimentLog> logs) => state = logs;
}