import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';

import 'package:negate/sentiment_db.dart';
import 'package:negate/sentiment_analysis.dart';

class AppList {
  DateTime lastTimeUsed;
  double totalTimeUsed;
  int numPositive = 0; // number of positive sentences
  int numNegative = 0; // number of negative sentences

  AppList(this.lastTimeUsed, this.totalTimeUsed, this.numPositive, this.numNegative);
}

class SentenceLogger {
  // Singleton
  static final SentenceLogger _instance = SentenceLogger.init();
  // sentence buffer for the current sentence being typed
  static final StringBuffer _sentence = StringBuffer();
  static final HashMap<String, AppList> _appMap = HashMap<String, AppList>();
  static late final HashSet<String> _appIcons;
  static late DriftIsolate _iso;
  static late TfParams _tfp;
  static const int _updateFreq = 1; //update db every 1 minute
  // default app blacklist
  RegExp blacklist =
      RegExp(r".*system.*|.*keyboard.*|.*input.*|.*honeyboard.*|.*swiftkey.*");
  // last app used
  String _lastUsedApp = "";
  // has the db just been updated? (to prevent race conditions)
  bool _dbUpdated = false;

  // Singleton
  factory SentenceLogger() {
    return _instance;
  }

  SentenceLogger.init();

  // Save the current sentiment logs to the database
  void logToDB() {
    Isolate.spawn(SentimentDB.addSentiments,
        AddSentimentRequest(_appMap, _iso.connectPort));
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

  // Entry point for the background isolate
  Future<void> startLogger(TfliteRequest request) async {
    var rPort = ReceivePort();
    // start the drift database in a background isolate
    await Isolate.spawn(
      _startBackground,
      IsolateStartRequest(
          sendDriftIsolate: rPort.sendPort, targetPath: request.targetPath),
    );

    var prefs = request.prefs;
    // get custom blacklist from preferences
    if (prefs.getString('blacklist') != null) {
      blacklist = RegExp(prefs.getString('blacklist')!);
    }

    _iso = await rPort.first as DriftIsolate;
    _tfp = request.tfp;
    var sdb = SentimentDB.connect(await _iso.connect());
    _appIcons = await sdb.getListOfIcons();
    // close connection to database and send the drift isolate back to the main isolate
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

  void _setAppValues(DateTime now, AppList app, double score, {bool used = true}) {
    double timeUsedSince =
        now.difference(app.lastTimeUsed).inSeconds.toDouble() / 60;
    double totalTimeUsed = app.totalTimeUsed + timeUsedSince;
    if (score > 0.45) {
      app.numPositive++;
    } else {
      app.numNegative++;
    }
    bool newHour = false;
    //If the next hour has been reached reset the average score and time used
    if (now.hour != app.lastTimeUsed.hour) {
      app.numNegative = 1;
      app.numPositive = 1;
      if (timeUsedSince / now.minute > 1) {
        totalTimeUsed = now.minute.toDouble();
      } else {
        totalTimeUsed = timeUsedSince;
      }
      newHour = true;
    }
    // used = false if the app was not used in the last 10 minutes,
    // but we still want to update the average score as it still affects the
    // user's mood
    if (used || newHour) {
      app.lastTimeUsed = now;
      app.totalTimeUsed = totalTimeUsed;
    }
  }

  void addAppEntry() async {
    log(getSentence());
    // if loggable sentence is too short, clear it and return
    if (getSentence().length < 6) {
      clearSentence();
      return;
    }
    String name = _lastUsedApp;
    var analyser = SentimentAnalysis.isolate(_tfp.iAddress, _tfp.dict, _tfp.translate);
    double score = await analyser.classify(getSentence());
    log(score.toString());
    clearSentence();

    var now = DateTime.now();
    //Update average score for all apps used in the last 10 minutes as well
    var appsInPeriod = _appMap.entries.where((element) =>
        element.value.lastTimeUsed.difference(now).inMinutes <= 10);
    for (var app in appsInPeriod) {
        if (app.key == name) continue;
        _setAppValues(now, app.value, score, used: false);
      }

    if (_appMap.containsKey(name)) {
      var app = _appMap[name]!;
      _setAppValues(now, app, score);
    } else {
      _appMap.putIfAbsent(name, () => AppList(now, 0, 1, 1));
    }

    //Update database every _updateFreq minutes
    if (now.minute % _updateFreq == 0 && !_dbUpdated) {
      logToDB();
      _dbUpdated = true;
    } else {
      _dbUpdated = false;
    }
  }

  void updateFGApp(String name) {
    DateTime now = DateTime.now();
    // ignore apps in blacklist
    if (blacklist.hasMatch(name.toLowerCase())) {
      return;
    }
    if (_appMap.containsKey(name)) {
      double timeUsedSince =
          now.difference(_appMap[name]!.lastTimeUsed).inSeconds.toDouble() / 60;
      if (name == _lastUsedApp) {
        if (now.hour != _appMap[name]!.lastTimeUsed.hour) {
          // if the next hour has been reached reset the time used
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
      _appMap.putIfAbsent(name, () => AppList(now, 0, 1, 1));
    }
    _lastUsedApp = name;
  }

  bool hasAppIcon(String name) {
    if (blacklist.hasMatch(name.toLowerCase())) return true;
    return _appIcons.contains(name);
  }

  void addAppIcon(String name, Uint8List icon) {
    _appIcons.add(name);
    Isolate.spawn(SentimentDB.addAppIcon,
        AddAppIconRequest(name, icon, _iso.connectPort));
  }
}
