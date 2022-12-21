import 'dart:io' show Platform;

import '../sentiment_db.dart';
import 'android_logger.dart';
import 'win_logger.dart';
import 'logger.dart';

class LoggerFactory {

  static Future<void> Function(TfliteRequest) getLoggerFactory() {
    if (Platform.isWindows) {
      return WinLogger().getLogger();
    } else if (Platform.isAndroid) {
      return AndroidLogger().getLogger();
    }
    return SentenceLogger().getLogger();
  }
}