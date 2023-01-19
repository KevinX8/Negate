import 'package:flutter/material.dart';
import 'package:negate/logger/logger_factory.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage {
  static int _sliderState = 75;

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
                  SettingsSection(
                    title: const Text('DEVELOPER SETTINGS: Sentiment'),
                    tiles: <SettingsTile>[
                      SettingsTile.switchTile(
                          activeSwitchColor:
                              Theme.of(context).colorScheme.primary,
                          initialValue:
                              prefs.data?.getBool('average_sentiment'),
                          onToggle: (value) => setState(() {
                                prefs.data?.setBool('average_sentiment', value);
                              }),
                          title: const Text('Use Average')),
                      SettingsTile(
                          description: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Slider(
                                min: 0,
                                max: 100,
                                divisions: 8,
                                label: "${_sliderState.toString()}%",
                                value: prefs.data?.getDouble(
                                            'multiplier_sentiment') !=
                                        null
                                    ? prefs.data!.getDouble(
                                            'multiplier_sentiment')! *
                                        100
                                    : 75,
                                onChanged: (double value) {
                                  setState(() {
                                    _sliderState = value.toInt();
                                    prefs.data!.setDouble(
                                        'multiplier_sentiment', value / 100);
                                  });
                                },
                              )),
                          title: const Text('Previous Sentiment Split:')),
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
