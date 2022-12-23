import 'dart:collection';
import 'dart:io';
import 'dart:developer';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift/isolate.dart';
import 'package:negate/sentiment_db.dart';

import '../sentiment_analysis.dart';

class AppList {
  DateTime lastTimeUsed;
  double totalTimeUsed;
  double avgScore;
  int numCalled;

  AppList(this.lastTimeUsed, this.totalTimeUsed, this.avgScore, this.numCalled);
}

class SentenceLogger {
  static final SentenceLogger _instance = SentenceLogger.init();
  static final StringBuffer _sentence = StringBuffer();
  static final HashMap<String, AppList> _appMap = HashMap<String, AppList>();
  static late DriftIsolate _iso;
  static late TfParams _tfp;
  static const int _updateFreq = 1; //update db every 5 minutes
  String _lastUsedApp = "";
  bool _dbUpdated = false;

  factory SentenceLogger() {
    return _instance;
  }

  SentenceLogger.init();

  void logToDB() {
    Isolate.spawn(SentimentDB.addSentiments, AddSentimentRequest(_appMap, _iso.connectPort));
  }

  static void _startBackground(IsolateStartRequest request) {
    // this is the entry point from the background isolate! Let's create
    // the database from the path we received
    final executor = NativeDatabase(File(request.targetPath));
    // we're using DriftIsolate.inCurrent here as this method already runs on a
    // background isolate. If we used DriftIsolate.spawn, a third isolate would be
    // started which is not what we want!
    final driftIsolate = DriftIsolate.inCurrent(
          () => DatabaseConnection(executor),
    );
    // inform the starting isolate about this, so that it can call .connect()
    request.sendDriftIsolate.send(driftIsolate);
  }

  Future<void> startLogger(TfliteRequest request) async {
    var rPort = ReceivePort();
    await Isolate.spawn(
      _startBackground,
      IsolateStartRequest(sendDriftIsolate: rPort.sendPort, targetPath: request.targetPath),
    );

    _iso = await rPort.first as DriftIsolate;
    _tfp = request.tfp;
    request.sendDriftIsolate.send(_iso.connectPort);
  }

  Future<void> Function(TfliteRequest) getLogger() {
    throw UnsupportedError("Platform not supported");
  }

  String getSentence() {
    return SentenceLogger._sentence.toString();
  }

  void writeToSentence(Object? obj) {
    SentenceLogger._sentence.write(obj);
  }

  void clearSentence() {
    SentenceLogger._sentence.clear();
  }

  void addAppEntry
      () {
    log(getSentence());
    if (getSentence().length < 6) {
      clearSentence();
      return;
    }
    String name = _lastUsedApp;
    var analyser = SentimentAnalysis.isolate(_tfp.iAddress, _tfp.dict);
    double score = analyser.classify(getSentence());
    log(score.toString());
    clearSentence();
    if (_appMap.containsKey(name)) {
      int timeUsedSince = DateTime.now().difference(_appMap[name]!.lastTimeUsed).inMinutes;
      double totalTimeUsed = _appMap[name]!.totalTimeUsed + timeUsedSince;
      double avgScore = (_appMap[name]!.avgScore + score) / (_appMap[name]!.numCalled + 1);
      _appMap[name] = AppList(DateTime.now() , totalTimeUsed, avgScore, _appMap[name]!.numCalled + 1);
    } else {
      _appMap.putIfAbsent(name, () => AppList(DateTime.now(), 0, score, 1));
    }

    if (DateTime.now().minute % _updateFreq == 0 && !_dbUpdated) {
      logToDB();
      _dbUpdated = true;
    } else {
      _dbUpdated = false;
    }
  }

  String getFGAppName() {
    throw UnsupportedError("Platform not supported");
  }

  void updateFGApp(String name) {
    if (name == _lastUsedApp) {
      return;
    }
    if (_appMap.containsKey(name)) {
      DateTime now = DateTime.now();
      _appMap[name]!.totalTimeUsed += now
          .difference(_appMap[name]!.lastTimeUsed)
          .inMinutes;
      _appMap[name]!.lastTimeUsed = now;
    }
    _lastUsedApp = name;
  }
}