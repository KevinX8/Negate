import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:negate/logger/android_logger.dart';

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
                'negative effect on your mood in the past week, you can use this information'
                'to gauge which apps to avoid using, however this is only a recommendation.'),
          )),
      persistentFooterButtons: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text("Start"))
      ],
    );
  }

  static Future<void> showDisclosure(BuildContext context) async {
    Text endText = const Text('Do you accept these terms?');
    if (Platform.isAndroid) {
      endText = const Text(
          'Do you accept these terms and allow use of accessibility services?');
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
                const Text('This App makes use of sentences you type in apps.'),
                const Text(
                    'Sentence text is never stored, only the sentiment score produced is.'),
                const Text(
                    'None of this data is sent or received online, all processing'
                        ' is done locally on device. For more info tap the Policy button'),
                endText
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  if (Platform.isAndroid) {
                    SystemNavigator.pop();
                  } else {
                    exit(0);
                  }
                },
                child: const Text('Exit')),
            TextButton(
                onPressed: () {
                  final Uri url = Uri.parse(
                      'https://kevinx8.github.io/Negate/Privacy-Policy.md');
                  launchUrl(url);
                },
                child: const Text('Policy')),
            TextButton(
              child: const Text('Accept'),
              onPressed: () {
                final prefs = SharedPreferences.getInstance();
                prefs.then((pref) => pref.setBool('accepted_privacy', true));
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
}