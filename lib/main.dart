import 'dart:developer';
import 'dart:io';

import 'package:drift/isolate.dart';
import 'package:flutter/material.dart';
import 'package:negate/SentimentDB.dart';
import 'package:negate/WinLogger.dart';
import 'package:path_provider/path_provider.dart';
import 'logger.dart';
import 'package:path/path.dart' as p;
import 'dart:async';
import 'dart:isolate';

late SentimentDB _sdb;

Future<void> main() async {
  const loggerUI = KeyLog();
  runApp(loggerUI);

  final dbFolder = await getApplicationSupportDirectory();
  final dbString = p.join(dbFolder.path, 'db.sqlite');
  final rPort = ReceivePort();
  final errPort = ReceivePort();
  var iso = await Isolate.spawn(WinLogger.startLogger, IsolateStartRequest(rPort.sendPort, dbString), errorsAreFatal: true);
  iso.addErrorListener(errPort.sendPort);
  log(await errPort.first);
  var isolate = await rPort.first as DriftIsolate;
  _sdb = SentimentDB.connect(await isolate.connect());
}

class KeyLog extends StatefulWidget {
  const KeyLog({super.key});

  @override
  State<KeyLog> createState() => _KeyLogState();
}

class _KeyLogState extends State<KeyLog> {
  var _text = "ded";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tutorial',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Text Widget Tutorial'),
        ),
        body: Center(
          child: Text(_text)
        ),
        persistentFooterButtons: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.all(16.0),
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: updateScreen,
            child: const Text('Gradient'),
          ),
        ],
      ),
    );
  }

  Future<void> updateScreen () async {
    final res = await _sdb.select(_sdb.sentimentLogs).get();
    log(res.toString());
    setState(() {
      _text = res.toString();
    });
  }
}