import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../sentiment_db.dart';

// this is the provider that will be used to access the database
// and update the UI every time it changes
final dbProvider = StateNotifierProvider((ref) {
  return DBMonitor();
});

// this holds the database instance and any other globals for the UI
final getIt = GetIt.instance;
// the date of the currently selected day in the UI
DateTime selectedDate = DateTime.now();

// underlying class for the provider which holds the logs from the database
// for the UI to display
class DBMonitor extends StateNotifier<List<SentimentLog>> {
  DBMonitor() : super(<SentimentLog>[]);

  void set(List<SentimentLog> logs) => state = logs;
}
