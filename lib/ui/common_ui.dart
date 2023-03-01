import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:negate/logger/android_logger.dart';
import 'package:negate/logger/logger_factory.dart';
import 'package:negate/sentiment_db.dart';
import 'package:negate/ui/globals.dart';

class CommonUI {
  // check if the user has moved to he next page
  static bool _firstPage = true;

  static Widget infoPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Info Page"),
      ),
      body: Center(
          child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(children: const <Widget>[
                Text('\nWelcome to Negate! This app uses sentiment analysis '
                    'along with the messages you type to create a positivity profile '
                    'for all the apps you use in your day to day life.\n'),
                Text('Dashboard',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 38)),
                Text(
                    '\nThe hourly dashboard shows an hour by hour breakdown of each apps positivity scores, along '
                    'with an overall average for that hour shown in the bar chart.\n'),
                Icon(Icons.analytics),
                Text(
                    '\nThe recommendations section shows you the top 5 apps which have had the most '
                    'negative effect on your mood in the past week and the top 5 with the most positive impact, you can use this information'
                    'to gauge which apps to avoid using and which ones help improve your mood, however this is only a recommendation.\n'),
                Icon(Icons.pie_chart),
                Text(
                    '\nThe daily breakdown shows an overall breakdown of each day summarised by how each app affected you throughout the day.'),
              ]))),
      persistentFooterButtons: [
        TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Start"))
      ],
    );
  }

  static Future<void> showDisclosure(
      BuildContext context, SharedPreferences pref) async {
    var firstPage = LoggerFactory.getDisclosureText(context);
    var secondPage = SingleChildScrollView(
        child: ListBody(
      children: const [
        Text("Privacy Policy",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        Text(
            "This is the privacy policy applicable to all platform versions of the Negate Application. "
            "Data collection is defined as the transmission of any user data off of the user's device to a remote server. "
            "All data used in the application is stored on device in a secure location and is never transmitted or collected."),
        Text("Logging of Message Sentiment Scores",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        Text(
            "Negate (The application) and I (The Developer) do not collect any data while the application is in use. "
            "Messages are defined as all sentences typed in any application while Negate is running. "
            "Your messages are processed on device using TensorFlow lite without the use of any online resources. "
            "The sentiment scores produced by TensorFlow lite are stored in a local database only accessible by the application itself. "
            "The text of the messages is never stored and disposed of as soon as the score is generated. "),
        Text("Logging of Applications Used",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        Text(
            "The applications you have used are also logged for the purposes of tracking what applications have influenced your mood. "),
      ],
    ));
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Privacy Disclosure'),
            content: CommonUI._firstPage ? firstPage : secondPage,
            actions: <Widget>[
              TextButton(
                  style: TextButton.styleFrom(
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
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: CommonUI._firstPage
                    ? const Text('Next')
                    : const Text('Accept'),
                onPressed: () {
                  if (CommonUI._firstPage) {
                    setState(() {
                      CommonUI._firstPage = false;
                    });
                    return;
                  }
                  pref.setBool('accepted_privacy', true);
                  if (Platform.isAndroid) {
                    AndroidLogger().startAccessibility();
                  }
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommonUI.infoPage(context)));
                },
              ),
            ],
          );
        });
      },
    );
  }

  static ButtonBar dateChanger(
      BuildContext context, SentimentDB sdb, WidgetRef ref,
      [StateSetter? setState]) {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        FilledButton(
          onPressed: () {
            selectedDate = selectedDate.subtract(const Duration(days: 1));
            if (setState != null) {
              setState(() => {});
            }
            var res = sdb.getDaySentiment(selectedDate);
            res.then((slog) {
              ref.read(dbProvider.notifier).set(slog);
            }, onError: (err, stk) => log(err));
          },
          child: const Icon(Icons.chevron_left_rounded),
        ),
        Text(DateFormat.yMMMd().format(selectedDate)),
        FilledButton(
          onPressed: () {
            var now = DateTime.now();
            var midnight = DateTime(now.year, now.month, now.day);
            if (selectedDate.add(const Duration(days: 1)).difference(midnight) >
                const Duration(days: 1)) {
              return;
            }
            selectedDate = selectedDate.add(const Duration(days: 1));
            if (setState != null) {
              setState(() => {});
            }
            var res = sdb.getDaySentiment(selectedDate);
            res.then((slog) {
              ref.read(dbProvider.notifier).set(slog);
            }, onError: (err, stk) => log(err));
          },
          child: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  // colours the bar based on the positivity of the value
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

  // creates a listview of the app sentiment logs passed in including the app icon
  static Widget appListView(
      List<MapEntry<String, List<double>>> logs, SentimentDB sdb) {
    return ListView.separated(
      itemCount: logs.length,
      itemBuilder: (BuildContext context, int index) {
        var timeUsed = Duration(minutes: logs[index].value[1].toInt());
        Text used = Text("Used for ${timeUsed.inMinutes} m");
        if (timeUsed.inHours != 0) {
          used = Text(
              "Used for ${timeUsed.inHours} h ${timeUsed.inMinutes % 60} m");
        }
        return SizedBox(
            height: 50,
            child: ListTile(
              leading: FutureBuilder<Uint8List?>(
                future: sdb.getAppIcon(logs[index].key),
                builder: (ctx, ico) {
                  if (ico.hasData) {
                    return Image.memory(ico.data!);
                  }
                  return const ImageIcon(null);
                },
              ),
              trailing:
                  Text("${(logs[index].value[0] * 100).toStringAsFixed(2)}%"),
              title: Text(logs[index].key),
              subtitle: used,
            ));
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
