import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:negate/sentiment_db.dart';
import 'package:negate/logger/android_logger.dart';
import 'package:negate/logger/win_logger.dart';

class LoggerFactory {
  // start the logger based on the platform
  @pragma('vm:entry-point')
  static Future<void> startLoggerFactory(TfliteRequest request) async {
    if (Platform.isWindows) {
      await WinLogger().startLogger(request);
    } else if (Platform.isAndroid) {
      await AndroidLogger().startLogger(request);
    } else {
      throw UnsupportedError("This platform is unsupported!");
    }
  }

  // return the default blacklist for the logger based on the platform
  static RegExp getLoggerRegex() {
    if (Platform.isWindows) {
      return RegExp(
          r".*system.*|.*keyboard.*|.*input.*|.*honeyboard.*|.*swiftkey.*|.*settings.*|.*explorer.*|.*host$|"
          r".*lockapp.*|.*widgets.*|.*setup.*|.*uninstall.*|.*taskmgr.*|.*openwith.*|.*msiexec.*");
    } else if (Platform.isAndroid) {
      return RegExp(r".*system.*|.*keyboard.*|.*input.*|"
          r".*honeyboard.*|.*swiftkey.*|.*lawnchair.*|.*launcher.*|.*settings.*");
    } else {
      throw UnsupportedError("This platform is unsupported!");
    }
  }

  // return the disclosure text for the logger based on the platform as the play store requires
  // a disclosure for the accessibility API, which is not available on Windows
  static Widget getDisclosureText(BuildContext context) {
    if (Platform.isAndroid) {
      return SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.7,
          child: const Markdown(
              data:
                  "It is important for you to understand how Negate makes use of your data. Below are the key points on why Negate must use the Accessibility API and what features it uses the Accessibility APi for.\n"
                  "# Accessibility API\n"
                  "## Listening for Text Changes\n"
                  "Negate listens for all text typed into textboxes on your device, features that require this access are:\n"
                  "* Generation of a positivity score using Artificial Intelligence based on the text received.\n"
                  "* Usage of the average of these scores over time for:\n"
                  "	* The Hourly Dashboard\n"
                  "	* The Daily Breakdown\n"
                  "	* The Weekly Recommendations\n\n"
                  "## Listening for Window State Changes\n"
                  "Negate listens for the current app that is in view for the features of:\n"
                  "* Seeing which apps have been used in the last 10 minutes that could have affected your mood and hence are factored into the positivity scoring for the current app as well.\n"
                  "* Getting the amount of time spent in each app and hence how much influence they have had on you in the past hour.\n\n"
                  "The next page details the app's privacy policy and how all user data is handled."));
    } else {
      return SingleChildScrollView(
          child: ListBody(children: const [
        Text('This app tracks the text of messages '
            'and what app is currently in use.'),
        Text(
            'The text is processed as specified in the privacy policy and used to generate '
            'sentiment scores for the apps currently in use. The details of the current app '
            'in use are required for the generation of a sentiment profile for each app as '
            'not every app that influences your mood contains messaging features.'),
        Text('None of this data is sent or received online, all processing'
            ' is done locally on device.'),
        Text(
            'The next page details the privacy policy on how your data is processed.')
      ]));
    }
  }
}
