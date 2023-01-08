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
  static late final HashSet<String> _appIcons;
  static late DriftIsolate _iso;
  static late TfParams _tfp;
  static const int _updateFreq = 1; //update db every 5 minutes
  static final RegExp blacklist = RegExp(r".*system.*|.*keyboard.*|.*input.*|.*honeyboard.*|.*swiftkey.*");
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
    var sdb = SentimentDB.connect(await _iso.connect());
    _appIcons = await sdb.getListOfIcons();
    sdb.close();
    request.sendDriftIsolate.send(_iso.connectPort);
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

    var now = DateTime.now();
    //Update average score for all apps used in the last 10 minutes as well
    var appsInPeriod = _appMap.entries.where((element) => element.value.lastTimeUsed.difference(now).inMinutes <= 10);
    for (var app in appsInPeriod) {
      if (app.key == name) continue;
      app.value.avgScore = ((app.value.avgScore * app.value.numCalled) + score) / (++app.value.numCalled);
    }

    if (_appMap.containsKey(name)) {
      double timeUsedSince = now.difference(_appMap[name]!.lastTimeUsed).inSeconds.toDouble() / 60;
      double totalTimeUsed = _appMap[name]!.totalTimeUsed + timeUsedSince;
      double avgScore = ((_appMap[name]!.avgScore * _appMap[name]!.numCalled) + score) / (_appMap[name]!.numCalled + 1);

      //If the next hour has been reached reset the average score and time used
      if (now.hour != _appMap[name]!.lastTimeUsed.hour) {
        avgScore = score;
        if (timeUsedSince / now.minute > 1) {
          totalTimeUsed = now.minute.toDouble();
        } else {
          totalTimeUsed = timeUsedSince;
        }
        _appMap[name]!.numCalled = 0;
      }
      _appMap[name] = AppList(now, totalTimeUsed, avgScore, _appMap[name]!.numCalled + 1);
    } else {
      _appMap.putIfAbsent(name, () => AppList(now, 0, score, 1));
    }

    if (now.minute % _updateFreq == 0 && !_dbUpdated) {
      logToDB();
      _dbUpdated = true;
    } else {
      _dbUpdated = false;
    }
  }

  void updateFGApp(String name) {
    DateTime now = DateTime.now();
    if (blacklist.hasMatch(name)) {
      return;
    }
    if (_appMap.containsKey(name)) {
      double timeUsedSince = now.difference(_appMap[name]!.lastTimeUsed)
          .inSeconds.toDouble() / 60;
      if (name == _lastUsedApp) {
        if (now.hour != _appMap[name]!.lastTimeUsed.hour) {
          if (timeUsedSince / now.minute > 1) {
            _appMap[name]!.totalTimeUsed = now.minute.toDouble();
          } else {
            _appMap[name]!.totalTimeUsed = timeUsedSince;
          }
        } else {
          _appMap[name]!.totalTimeUsed += timeUsedSince;
        }
      }
      _appMap[name]!.lastTimeUsed = now;
    } else {
      _appMap.putIfAbsent(name, () => AppList(now, 0, 0.5, 1));
    }
    _lastUsedApp = name;
  }

  bool hasAppIcon(String name) {
    if (blacklist.hasMatch(name)) return true;
    return _appIcons.contains(name);
  }

  void addAppIcon(String name, Uint8List icon) {
    _appIcons.add(name);
    Isolate.spawn(SentimentDB.addAppIcon, AddAppIconRequest(name, icon, _iso.connectPort));
  }
}