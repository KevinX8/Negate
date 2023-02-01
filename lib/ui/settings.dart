import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:negate/logger/logger_factory.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sentiment_db.dart';
import 'globals.dart';

class SettingsPage {
  static Widget build(BuildContext context, StateSetter setState) {
    var theme = SettingsThemeData(
      settingsListBackground: Theme.of(context).scaffoldBackgroundColor,
    );
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, prefs) {
              if (prefs.data == null) {
                return const Text('Loading...');
              }
              var textController = TextEditingController(
                  text: prefs.data!.getString('blacklist'));
              return SettingsList(
                lightTheme: theme,
                darkTheme: theme,
                platform: DevicePlatform.android,
                sections: [
                  SettingsSection(
                    title: const Text('Theme'),
                    tiles: <SettingsTile>[
                      SettingsTile.switchTile(
                          activeSwitchColor:
                              Theme.of(context).colorScheme.primary,
                          leading: const Icon(Icons.format_paint),
                          initialValue: prefs.data?.getBool('dynamic_theme'),
                          onToggle: (value) => setState(() {
                                prefs.data?.setBool('dynamic_theme', value);
                              }),
                          title: const Text('Use Dynamic Theme')),
                    ],
                  ),
                  SettingsSection(title: const Text('Database'), tiles: <
                      SettingsTile>[
                    SettingsTile.navigation(
                        title: const Text('Export'),
                        onPressed: (context) async {
                          if (Platform.isIOS ||
                              Platform.isAndroid ||
                              Platform.isMacOS) {
                            bool status = await Permission.storage.isGranted;

                            if (!status) await Permission.storage.request();
                          }
                          const String fileName = 'sentiment_logs';
                          var sdb = getIt<SentimentDB>.call();
                          var logs = await sdb.jsonLogs();
                          var logData = Uint8List.fromList(logs.codeUnits);
                          const MimeType mimeType = MimeType.JSON;
                          Future<String> file;
                          if (Platform.isAndroid) {
                            file = FileSaver.instance
                                .saveAs(fileName, logData, 'json', mimeType);
                          } else {
                            file = FileSaver.instance.saveFile(
                                fileName, logData, 'json',
                                mimeType: mimeType);
                          }
                          file.then((file) => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                                  content: Text('Database saved to: $file'))));
                        }),
                    SettingsTile.navigation(
                      title: const Text('Import'),
                      onPressed: (context) async {
                        var sdb = getIt<SentimentDB>.call();
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['json']);
                        if (result != null) {
                          File file = File(result.files.single.path!);
                          Uint8List json = file.readAsBytesSync();
                          bool res =
                              await sdb.jsonImport(String.fromCharCodes(json));
                          var resText = const Text('Imported Successfully!');
                          if (!res) {
                            resText = const Text('Invalid Database Logs!');
                          }
                          Future.sync(() => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: resText)));
                        }
                      },
                    )
                  ]),
                  SettingsSection(
                    title: const Text('DEVELOPER SETTINGS: Sentiment'),
                    tiles: <SettingsTile>[
                      SettingsTile(
                          title: TextFormField(
                            controller: textController,
                            onChanged: (regex) {
                              prefs.data?.setString('blacklist', regex);
                            },
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'App Blacklist Regex',
                            ),
                          ),
                          description: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                textController.text =
                                    LoggerFactory.getLoggerRegex().pattern;
                                prefs.data?.setString('blacklist',
                                    LoggerFactory.getLoggerRegex().pattern);
                              });
                            },
                            child: const Text('Reset Default'),
                          ))
                    ],
                  ),
                ],
              );
            }));
  }
}
