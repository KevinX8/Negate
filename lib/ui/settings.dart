import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage {
  static bool test = false;

  static Widget build(BuildContext context, StateSetter setState) {
    var theme = SettingsThemeData(settingsListBackground: Theme.of(context).colorScheme.background);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: SettingsList(
          lightTheme: theme,
          darkTheme: theme,
          platform: DevicePlatform.android,
      sections: [
        SettingsSection(
          title: Text('Common'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: Icon(Icons.language),
              title: Text('Language'),
              value: Text('English'),
            ),
            SettingsTile.switchTile(
              onToggle: (value) {setState(() { test = !test;});},
              initialValue: test,
              leading: Icon(Icons.format_paint),
              title: Text('Enable custom theme'),
            ),
          ],
        ),
      ],
    )
    );
  }
  
}