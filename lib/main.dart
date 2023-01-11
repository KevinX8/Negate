import 'dart:developer';
import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:file_saver/file_saver.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:negate/logger/android_logger.dart';
import 'package:negate/logger/logger_factory.dart';
import 'package:negate/sentiment_analysis.dart';
import 'package:negate/sentiment_db.dart';

import 'package:drift/isolate.dart';
import 'package:flutter/material.dart' hide MenuItem;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_tray/system_tray.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'package:negate/ui/globals.dart';
import 'package:negate/ui/recommendations.dart';
import 'package:negate/ui/window_decorations.dart';
import 'package:negate/ui/common_ui.dart';

Future<void> main() async {
  const loggerUI = ThemedHourlyUI();
  WidgetsFlutterBinding.ensureInitialized();

  final dbFolder = await getApplicationSupportDirectory();
  final dbString = p.join(dbFolder.path, 'db.sqlite');
  final rPort = ReceivePort();

  var analyser = SentimentAnalysis();
  await analyser.init();
  var tfp = TfParams(analyser.sInterpreter.address, analyser.dictionary);

  if (Platform.isAndroid || Platform.isIOS) {
    LoggerFactory.startLoggerFactory(
        TfliteRequest(rPort.sendPort, dbString, tfp));
  } else {
    await loggerUI.initSystemTray();
    await Isolate.spawn(LoggerFactory.startLoggerFactory,
        TfliteRequest(rPort.sendPort, dbString, tfp));
  }

  var iPort = await rPort.first as SendPort;
  var isolate = DriftIsolate.fromConnectPort(iPort);
  var sdb = SentimentDB.connect(await isolate.connect());
  getIt.registerSingleton<SentimentDB>(sdb);
  runApp(const ProviderScope(child: loggerUI));
}

class ThemedHourlyUI extends StatelessWidget {
  const ThemedHourlyUI({super.key});

  Future<void> initSystemTray() async {
    String path =
        Platform.isWindows ? 'assets/app_icon.ico' : 'assets/app_icon.png';

    final AppWindow appWindow = AppWindow();
    final SystemTray systemTray = SystemTray();

    // We first init the systray menu
    await systemTray.initSystemTray(
      title: "system tray",
      iconPath: path,
    );

    // create context menu
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: 'Show', onClicked: (menuItem) => appWindow.show()),
      MenuItemLabel(label: 'Hide', onClicked: (menuItem) => appWindow.hide()),
      MenuItemLabel(label: 'Exit', onClicked: (menuItem) => appWindow.close()),
    ]);

    // set context menu
    await systemTray.setContextMenu(menu);

    // handle system tray event
    systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget home = HourlyDashboard();
    if (!Platform.isAndroid) {
      home = Column(
        children: [
          WindowButtons(),
          Expanded(child: home),
        ],
      );
    }

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme light;
        ColorScheme dark;
        if (lightDynamic != null && darkDynamic != null && !Platform.isWindows) {
          light = lightDynamic;
          dark = darkDynamic;
        } else {
          light = ColorScheme.fromSwatch(
              primarySwatch: Colors.deepPurple,
              primaryColorDark: Colors.deepPurpleAccent,
              accentColor: Colors.deepPurpleAccent,
              brightness: Brightness.light);
          dark = ColorScheme.fromSwatch(
              primarySwatch: Colors.deepPurple,
              primaryColorDark: Colors.deepPurpleAccent,
              cardColor: Colors.deepPurpleAccent,
              accentColor: Colors.deepPurpleAccent,
              brightness: Brightness.dark);
        }
        return MaterialApp(
            title: 'Negate Mental Health Tracker',
            theme: ThemeData(
                colorScheme: light,
              useMaterial3: true),
            darkTheme: ThemeData(
                colorScheme: dark,
                useMaterial3: true),
            themeMode: ThemeMode.system,
            home: home);
    });
  }
}

class HourlyDashboard extends ConsumerWidget {
  HourlyDashboard({super.key});
  DateTime _selectedDate = DateTime.now();
  bool _requested = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var sdb = getIt<SentimentDB>.call();
    SharedPreferences.getInstance().then((pref) {
      if ((pref.getBool('accepted_privacy') == null ||
          !pref.getBool('accepted_privacy')!) && !_requested) {
        _requested = true;
        CommonUI.showDisclosure(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CommonUI.infoPage(context)));
      } else {
        if (Platform.isAndroid && !_requested) {
          _requested = true;
          AndroidLogger().startAccessibility();
        }
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Dashboard'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CommonUI.infoPage(context)));
              },
              icon: const Icon(Icons.info_outline)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RecommendationsPage()));
              },
              icon: const Icon(Icons.analytics)),
          IconButton(
              onPressed: () {
                var snackBar =
                    const SnackBar(content: Text('Not Implemented Yet!'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              icon: const Icon(Icons.pie_chart)),
          PopupMenuButton<String>(
              onSelected: handleMenu,
              itemBuilder: (context) {
                return {'Export', 'Settings', 'Stop and Exit'}
                    .map((String choice) {
                  return PopupMenuItem<String>(
                      value: choice, child: Text(choice));
                }).toList();
              }),
        ],
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
                  child: Icon(Icons.chevron_left_rounded, color: Theme.of(context).primaryColor),
                ),
                Text(DateFormat.yMMMd().format(_selectedDate)),
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
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                    var res = sdb.getDaySentiment(_selectedDate);
                    res.then((slog) {
                      ref.read(dbProvider.notifier).set(slog);
                    }, onError: (err, stk) => log(err));
                  },
                  child: Icon(Icons.chevron_right_rounded, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
            const Expanded(
                child: Text("Average Positivity per Hour",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Expanded(
                flex: 9,
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
                                rightTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 25,
                                        getTitlesWidget: (value, meta) =>
                                            const Text(""))),
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: bottomTitles),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 25,
                                      getTitlesWidget: (value, meta) =>
                                          const Text("")),
                                )),
                            barGroups: averages.data));
                      } else {
                        return const CircularProgressIndicator();
                      }
                    })),
            Expanded(
                child: Text(
                    'Positivity scores for ${DateFormat.j().format(_selectedDate)}',
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            Expanded(
                flex: 9,
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
                                    Text("Used for ${logs[index].timeUsed} m"),
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
            foregroundColor: Theme.of(context).colorScheme.primary,
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
    );
  }


  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.normal, fontSize: 14);
    String text;
    if (value == 0) {
      text = '12 AM';
    } else if (value == 6) {
      text = '6 AM';
    } else if (value == 12) {
      text = '12 PM';
    } else if (value == 18) {
      text = '6 PM';
    } else if (value == 23) {
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
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month,
              _selectedDate.day, hour);
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
          '${rod.toY.round()}%',
          const TextStyle(
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
      if (_selectedDate.hour == i) {
        show = [0];
      }
      bars.add(BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
                toY: (res[i] * 100).roundToDouble(),
                width: 10,
                color: getBarColour(res[i]),
                borderRadius: const BorderRadius.all(Radius.zero))
          ],
          showingTooltipIndicators: show));
    }
    return bars;
  }

  Color getBarColour(double val) {
    int percent = (val * 100).round();
    if (percent >= 75) {
      return Colors.green[900]!;
    } else if (percent >= 65) {
      return Colors.green;
    } else if (percent >= 45) {
      return Colors.greenAccent;
    } else if (percent >= 35) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  void handleMenu(String value) async {
    switch (value) {
      case 'Export':
        if (Platform.isIOS || Platform.isAndroid || Platform.isMacOS) {
          bool status = await Permission.storage.isGranted;

          if (!status) await Permission.storage.request();
        }
        const String fileName = 'sentiment_logs';
        var sdb = getIt<SentimentDB>.call();
        var logs = await sdb.jsonLogs();
        var logData = Uint8List.fromList(logs.codeUnits);
        const MimeType mimeType = MimeType.JSON;
        String path = "";
        if (Platform.isAndroid) {
          path = await FileSaver.instance
              .saveAs(fileName, logData, 'json', mimeType);
        } else {
          path = await FileSaver.instance
              .saveFile(fileName, logData, 'json', mimeType: mimeType);
        }
        log(path);
        break;
      case 'Settings':
        break;
      case 'Stop and Exit':
        exit(0);
    }
  }
}
