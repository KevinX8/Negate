
import 'package:negate/logger/logger.dart';
import 'package:negate/sentiment_db.dart';

class AndroidLogger implements SentenceLogger {

  static Future<void> startLogger(TfliteRequest request) async {
    await SentenceLogger.startLogger(request);
  }

  static Future<void> Function(TfliteRequest) getLoggerFactory() {
    return AndroidLogger.startLogger;
  }
}