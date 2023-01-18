import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:negate/sentiment_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:negate/logger/android_logger.dart';

import 'globals.dart';

class CommonUI {

  static Widget infoPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Info Page"),
      ),
      body: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: const Text('Welcome to Negate! This app uses sentiment analysis '
                'along with the messages you type to create a positivity profile '
                'for all the apps you use in your day to day life.\nThe hourly dashboard '
                'shows an hour by hour breakdown of each apps positivity scores, along '
                'with an overall average for that hour shown in the bar chart.\n'
                'The Recommendations section shows you the top 5 apps which have had the most '
                'negative effect on your mood in the past week and the top 5 with the most positive impact, you can use this information'
                'to gauge which apps to avoid using and which ones help improve your mood, however this is only a recommendation.'),
          )),
      persistentFooterButtons: [
        TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
              padding: const EdgeInsets.all(16.0),
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context), child: const Text("Start"))
      ],
    );
  }

  static Future<void> showDisclosure(BuildContext context, SharedPreferences pref) async {
    Text endText = const Text('Do you accept these terms?');
    Text startText = const Text('This app tracks the text of messages '
        'and what app is currently in use.');
    if (Platform.isAndroid) {
      endText = const Text(
          'Do you accept these terms and allow use of the Accessibility API?');
      startText = const Text('This app makes use of the Accessibility API, '
          'which allows it to track the text of messages and what app is currently in use.');
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Privacy Disclosure'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                startText,
                const Text(
                        'The text is processed as specified in the privacy policy and used to generate '
                        'sentiment scores for the apps currently in use. The details of the current app '
                        'in use are required for the generation of a sentiment profile for each app as '
                        'not every app that influences your mood contains messaging features.'),
                const Text(
                    'None of this data is sent or received online, all processing'
                        ' is done locally on device. For more info tap the Policy button'),
                endText
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else {
                    exit(0);
                  }
                },
                child: const Text('Exit')),
            TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  final Uri url = Uri.parse(
                      'https://kevinx8.github.io/Negate/Privacy-Policy.md');
                  launchUrl(url);
                },
                child: const Text('Policy')),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Accept'),
              onPressed: () {
                pref.setBool('accepted_privacy', true);
                Navigator.of(context).pop();
                if (Platform.isAndroid) {
                  AndroidLogger().startAccessibility();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static ButtonBar dateChanger(BuildContext context,SentimentDB sdb, WidgetRef ref, [StateSetter? setState]) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary)),
          onPressed: () {
            selectedDate =
                selectedDate.subtract(const Duration(days: 1));
            if (setState != null){
              setState(() => {});
            }
            var res = sdb.getDaySentiment(selectedDate);
            res.then((slog) {
              ref.read(dbProvider.notifier).set(slog);
            }, onError: (err, stk) => log(err));
          },
          child: Icon(Icons.chevron_left_rounded, color: Theme.of(context).primaryColor),
        ),
        Text(DateFormat.yMMMd().format(selectedDate)),
        ElevatedButton(
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary)),
          onPressed: () {
            var now = DateTime.now();
            var midnight = DateTime(now.year, now.month, now.day);
            if (selectedDate
                .add(const Duration(days: 1))
                .difference(midnight) >
                const Duration(days: 1)) {
              return;
            }
            selectedDate = selectedDate.add(const Duration(days: 1));
            if (setState != null){
              setState(() => {});
            }
            var res = sdb.getDaySentiment(selectedDate);
            res.then((slog) {
              ref.read(dbProvider.notifier).set(slog);
            }, onError: (err, stk) => log(err));
          },
          child: Icon(Icons.chevron_right_rounded, color: Theme.of(context).primaryColor),
        ),
      ],
    );
  }

  static Color getBarColour(double val) {
    int percent = (val * 100).round();
    if (percent >= 75) {
      return Colors.green[900]!;
    } else if (percent >= 65) {
      return Colors.green;
    } else if (percent >= 45) {
      return Colors.greenAccent;
    } else if (percent >= 35) {
      return Colors.yellow;
    } else if (percent > 0) {
      return Colors.red;
    } else {
      return Colors.blueGrey;
    }
  }

  static Widget appListView(List<MapEntry<String, List<double>>> logs, SentimentDB sdb) {
    return ListView.separated(
      itemCount: logs.length,
      itemBuilder: (BuildContext context, int index) {
        var timeUsed = Duration(
            minutes: logs[index].value[1].toInt());
        Text used = Text("Used for ${timeUsed.inMinutes} m");
        if (timeUsed.inHours != 0) {
          used = Text(
              "Used for ${timeUsed.inHours} h ${timeUsed.inMinutes % 60} m");
        }
        return Container(
            height: 50,
            child: ListTile(
              leading: FutureBuilder<Uint8List?>(
                future:
                sdb.getAppIcon(logs[index].key),
                builder: (ctx, ico) {
                  if (ico.hasData) {
                    return Image.memory(ico.data!);
                  }
                  return const ImageIcon(null);
                },
              ),
              trailing: Text(
                  "${(logs[index].value[0] * 100).toStringAsFixed(2)}%"),
              title: Text(logs[index].key),
              subtitle: used,
            ));
      },
      separatorBuilder: (BuildContext context, int index) =>
      const Divider(),
    );
  }
}