import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:negate/logger/logger.dart';
import 'package:negate/logger/logger_factory.dart';
import 'package:negate/sentiment_analysis.dart';
import 'package:negate/sentiment_db.dart';

import 'package:drift/isolate.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/src/painting/alignment.dart' as a;

final dbProvider = StateNotifierProvider((ref) {
  return DBMonitor();
});

final getIt = GetIt.instance;

class DBMonitor extends StateNotifier<List<SentimentLog>> {
  DBMonitor() : super(<SentimentLog>[]);

  void set(List<SentimentLog> logs) => state = logs;
}

Future<void> main() async {
  const loggerUI = KeyLog();
  WidgetsFlutterBinding.ensureInitialized();

  final dbFolder = await getApplicationSupportDirectory();
  final dbString = p.join(dbFolder.path, 'db.sqlite');
  final rPort = ReceivePort();

  var analyser = SentimentAnalysis();
  await analyser.init();
  var tfp = TfParams(analyser.sInterpreter.address, analyser.dictionary);

  if (Platform.isAndroid) {
    LoggerFactory.startLoggerFactory(
        TfliteRequest(rPort.sendPort, dbString, tfp));
  } else {
    await Isolate.spawn(LoggerFactory.startLoggerFactory,
        TfliteRequest(rPort.sendPort, dbString, tfp));
  }

  var iPort = await rPort.first as SendPort;
  var isolate = DriftIsolate.fromConnectPort(iPort);
  var sdb = SentimentDB.connect(await isolate.connect());
  getIt.registerSingleton<SentimentDB>(sdb);
  runApp(const ProviderScope(child: loggerUI));
}

class KeyLog extends StatelessWidget {
  const KeyLog({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

class Home extends ConsumerWidget {
  Home({super.key});
  DateTime _selectedDate = DateTime.now();
  int _selectedBar = DateTime.now().hour;

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
        color: Colors.black, fontWeight: FontWeight.normal, fontSize: 14);
    String text;
    if (value == 0) {
      text = '12 AM';
    } else if (value == 6) {
      text = '6 AM';
    } else if (value == 12) {
      text = '12 PM';
    } else if (value == 18) {
      text = '6 PM';
    } else if (value == 23){
      text = '11 PM';
    } else {
      text = '';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  BarTouchData barTouchData(WidgetRef ref) => BarTouchData(
    enabled: true,
    mouseCursorResolver: (barData, res) {
      if (res?.spot != null) {
        return SystemMouseCursors.click;
      }
      return SystemMouseCursors.basic;
    },
    handleBuiltInTouches: true,
    touchCallback: (event, res) {
      if (event.runtimeType == FlTapDownEvent) {
        if (res?.spot != null) {
          var hour = res!.spot!.touchedBarGroup.x;
          _selectedBar = hour;
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, hour);
          var sdb = getIt<SentimentDB>.call();
          var ret = sdb.getDaySentiment(_selectedDate);
          ret.then((slog) {
            ref.read(dbProvider.notifier).set(slog);
          }, onError: (err, stk) => log(err));
        }
      }
    },
    touchTooltipData: BarTouchTooltipData(
      tooltipBgColor: Colors.transparent,
      tooltipPadding: EdgeInsets.zero,
      tooltipMargin: 8,
      getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
          ) {
        return BarTooltipItem(
          rod.toY.round().toString(),
          const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    ),
  );

  Future<List<BarChartGroupData>> getHourBars() async {
    List<BarChartGroupData> bars = [];
    var sdb = getIt<SentimentDB>.call();
    var res = await sdb.getAvgHourlySentiment(_selectedDate);
    for (int i = 0; i < 24; i++) {
      List<int>? show;
      if (_selectedBar == i) {
        show = [0];
      }
      bars.add(BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
                toY: (res[i] * 100).roundToDouble(),
                width: 14,
                color: getBarColour(res[i]),
                borderRadius: const BorderRadius.all(Radius.zero))
          ],
          showingTooltipIndicators: show));
    }
    return bars;
  }

  Color getBarColour(double val) {
    if (val > 0.75) {
      return Colors.green[900]!;
    } else if (val > 0.65) {
      return Colors.green;
    } else if (val > 0.45) {
      return Colors.greenAccent;
    } else if (val > 0.35) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  /*
  LinearGradient get _barsGradient => LinearGradient(
    colors: [
      Colors.red,
      Colors.yellow,
Colors.greenAccent,
      Colors.green,
      Colors.green[900]!,
    ],
    begin: a.Alignment.bottomCenter,
    end: a.Alignment.topCenter,
  );*/

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var sdb = getIt<SentimentDB>.call();
    return MaterialApp(
      title: 'Negate Mental Health Tracker',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hourly Dashboard'),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 1));
                      var res = sdb.getDaySentiment(_selectedDate);
                      res.then((slog) {
                        ref.read(dbProvider.notifier).set(slog);
                      }, onError: (err, stk) => log(err));
                    },
                    child: const Text('<'),
                  ),
                  Text("${_selectedDate.toLocal()}".split(' ')[0]),
                  ElevatedButton(
                    onPressed: () {
                      var now = DateTime.now();
                      var midnight = DateTime(now.year, now.month, now.day);
                      if (_selectedDate
                              .add(const Duration(days: 1))
                              .difference(midnight) >
                          const Duration(days: 1)) {
                        return;
                      }
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                      var res = sdb.getDaySentiment(_selectedDate);
                      res.then((slog) {
                        ref.read(dbProvider.notifier).set(slog);
                      }, onError: (err, stk) => log(err));
                    },
                    child: const Text('>'),
                  ),
                ],
              ),
              Expanded(
                  child: FutureBuilder<List<BarChartGroupData>>(
                      future: getHourBars(),
                      builder: (context, averages) {
                        if (averages.hasData) {
                          return BarChart(BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              minY: 0,
                              baselineY: 50,
                              barTouchData: barTouchData(ref),
                              titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 25,
                                      getTitlesWidget: (value, meta) => const Text(""))),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
                                        getTitlesWidget: bottomTitles),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                        showTitles: true, reservedSize: 25,
                                        getTitlesWidget: (value, meta) => const Text("")),
                                  )),
                          barGroups: averages.data));
                        } else {
                          return const CircularProgressIndicator();
                        }
                      })),
              Expanded(
                  child: FutureBuilder<List<SentimentLog>>(
                      future: sdb.getDaySentiment(_selectedDate),
                      builder: (context, s) {
                        var logs = ref.watch(dbProvider) as List<SentimentLog>;
                        if (s.hasData) {
                          if (s.data!.isNotEmpty) {
                            logs = s.data!;
                          }
                        }
                        return ListView.separated(
                          itemCount: logs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                                height: 50,
                                child: ListTile(
                                  leading: FutureBuilder<Uint8List?>(
                                    future: sdb.getAppIcon(logs[index].name),
                                    builder: (ctx, ico) {
                                      if (ico.hasData) {
                                        return Image.memory(ico.data!);
                                      }
                                      return const ImageIcon(null);
                                    },
                                  ),
                                  trailing: Text(
                                      "${(logs[index].avgScore * 100).toStringAsFixed(2)}%"),
                                  title: Text(logs[index].name),
                                  subtitle:
                                      Text("Used ${logs[index].timeUsed}m"),
                                ));
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                        );
                      })),
            ]),
        persistentFooterButtons: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.all(16.0),
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              var res = sdb.getDaySentiment(_selectedDate);
              res.then((slog) {
                ref.read(dbProvider.notifier).set(slog);
              }, onError: (err, stk) => log(err));
            },
            child: const Text('Update logs'),
          ),
        ],
      ),
    );
  }
}
