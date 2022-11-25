import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:negate/SentimentDB.dart';
import 'package:negate/WinLogger.dart';
import 'package:path_provider/path_provider.dart';
import 'logger.dart';
import 'dart:async';
import 'dart:isolate';

Future<void> main() async {
  const loggerUI = KeyLog();
  runApp(loggerUI);

  //var db = SentimentDB();
  Hive.initFlutter('negate');
  Isolate.spawn(WinLogger.startLogger, db);
}

Future<void> updateDB() async {

}

class KeyLog extends StatefulWidget {
  const KeyLog({super.key, required SentimentDB sdb});

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
    setState(() {
      _text = res.toString();
    });
  }
}