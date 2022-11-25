import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as provider;
import 'package:negate/WinLogger.dart';
import 'package:negate/main.dart';
import 'logger.dart';
import 'dart:async';
import 'dart:isolate';

Future<void> main() async {
  Hive.initFlutter();
  String boxName = "test";
  //await Hive.openLazyBox(boxName);
  const loggerUI = KeyLog();
  runApp(loggerUI);
  Isolate.spawn(WinLogger.startLogger, boxName);
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
    var db = await Hive.openLazyBox("test");
    SentimentLog res = await db.get("testScore");
    db.close();
    setState(() {
      _text = res.toString();
    });
  }
}