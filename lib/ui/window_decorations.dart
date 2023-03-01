import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';

class WindowButtons extends StatelessWidget {
  WindowButtons({Key? key}) : super(key: key);

  final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: Colors.white,
      iconMouseOver: Colors.white);

  @override
  Widget build(BuildContext context) {
    var buttonColors = WindowButtonColors(
        iconNormal: Colors.white,
        mouseOver: Theme.of(context).colorScheme.primary,
        mouseDown: Theme.of(context).scaffoldBackgroundColor,
        iconMouseOver: Colors.black,
        iconMouseDown: Theme.of(context).colorScheme.primary);
    return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(child: WindowTitleBarBox(child: MoveWindow())),
            MinimizeWindowButton(colors: buttonColors),
            MaximizeWindowButton(colors: buttonColors),
            CloseWindowButton(
              colors: closeButtonColors,
              onPressed: () {
                appWindow.hide();
                LocalNotification notification = LocalNotification(
                  title: "Negate",
                  body: "running in the background",
                );
                notification.show();
              },
            ),
          ],
        ));
  }
}
