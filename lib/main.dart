import 'dart:developer';
import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:negate/logger/logger_factory.dart';
import 'package:negate/sentiment_analysis.dart';
import 'package:negate/sentiment_db.dart';

import 'package:drift/isolate.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;

final dbProvider = StateNotifierProvider((ref) {
  return DBMonitor();
});

final getIt = GetIt.instance;

class DBMonitor extends StateNotifier<String> {
  DBMonitor(): super("Refresh Logs Below!");

  void set(str) => state = str;
}

Future<void> main() async {
  const loggerUI = KeyLog();
  runApp(const ProviderScope(
    child: loggerUI
  ));

  final dbFolder = await getApplicationSupportDirectory();
  final dbString = p.join(dbFolder.path, 'db.sqlite');
  final rPort = ReceivePort();

  var analyser = SentimentAnalysis();
  await analyser.init();
  var tfp = TfParams(analyser.sInterpreter.address, analyser.dictionary);

  if (Platform.isAndroid) {
        LoggerFactory.startLoggerFactory(TfliteRequest(rPort.sendPort, dbString, tfp));
  } else {
    await Isolate.spawn(
        LoggerFactory.startLoggerFactory, TfliteRequest(rPort.sendPort, dbString, tfp));
  }

  var iPort = await rPort.first as SendPort;
  var isolate = DriftIsolate.fromConnectPort(iPort);
  var sdb = SentimentDB.connect(await isolate.connect());
  getIt.registerSingleton<SentimentDB>(sdb);
}

class KeyLog extends StatelessWidget {
  const KeyLog({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Home());
  }
}

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var sdb = getIt<SentimentDB>.call();
    var res = sdb.getLastSentiment();
    return MaterialApp(
      title: 'Negate Mental Health Tracker',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sentiment Log UI'),
        ),
        body: Center(
          child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 50,
                  child: ListTile(
                    leading: Icon(Icons.home),
                    title: Text(ref.),
                  )
                )
              }
          )
        ),
        persistentFooterButtons: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.all(16.0),
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              sdb = getIt<SentimentDB>.call();
              res = sdb.getLastSentiment();
              res.then((log) => ref.read(dbProvider.notifier).set(log.join("\n")), onError: (err, stk) => log(err));
            },
            child: const Text('Update logs'),
          ),
        ],
      ),
    );
  }
}