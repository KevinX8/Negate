import 'package:negate/logger/logger.dart';
import 'package:negate/sentiment_db.dart';

class AndroidLogger extends SentenceLogger {
  static final AndroidLogger _instance = AndroidLogger.init();

  factory AndroidLogger() {
    return _instance;
  }

  AndroidLogger.init() : super.init();

  @override
  Future<void> startLogger(TfliteRequest request) async {
    await super.startLogger(request);
  }

  @override
  Future<void> Function(TfliteRequest) getLogger() {
    return startLogger;
  }
}