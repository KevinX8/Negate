import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:negate/logger/logger.dart';
import 'package:negate/sentiment_db.dart';

class AndroidLogger extends SentenceLogger {
  static final AndroidLogger _instance = AndroidLogger.init();
  final _eventChannel = const EventChannel('platform_channel_events/logger');

  factory AndroidLogger() {
    return _instance;
  }

  AndroidLogger.init() : super.init();

  @override
  Future<void> startLogger(TfliteRequest request) async {
    await super.startLogger(request);
    _eventChannel.receiveBroadcastStream().listen((event) {
      log("event called");
      final String sentence = event.toString().split("<|>")[0];
      final String appName = event.toString().split("<|>")[1];
      AndroidLogger().updateFGApp(appName);
      AndroidLogger().writeToSentence(sentence);
      AndroidLogger().addAppEntry();
    });
  }
}