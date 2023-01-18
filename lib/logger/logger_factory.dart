import 'dart:io' show Platform;

import 'package:negate/logger/logger.dart';

import '../sentiment_db.dart';
import 'android_logger.dart';
import 'win_logger.dart';

class LoggerFactory {

  @pragma('vm:entry-point')
  static Future<void> startLoggerFactory(TfliteRequest request) async {
    if (Platform.isWindows) {
      await WinLogger().startLogger(request);
    } else if (Platform.isAndroid) {
      await AndroidLogger().startLogger(request);
    } else {
      throw UnsupportedError("This platform is unsupported!");
    }
  }

  static SentenceLogger getLogger() {
    if (Platform.isWindows) {
      return WinLogger();
    } else if (Platform.isAndroid) {
      return AndroidLogger();
    } else {
      throw UnsupportedError("This platform is unsupported!");
    }
  }
}