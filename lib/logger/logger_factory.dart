import 'dart:io' show Platform;

import '../sentiment_db.dart';
import 'android_logger.dart';
import 'win_logger.dart';

class LoggerFactory {
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
}
