import 'dart:ffi';

import 'package:negate/SentimentDB.dart';
import 'package:negate/logger.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

  class WinLogger implements SentenceLogger {
    static int keyHook = 0;

    static Future<void> startLogger(IsolateStartRequest request) async {
      await SentenceLogger.startLogger(request);
      _setHook();
      final msg = calloc<MSG>();
      while (GetMessage(msg, NULL, 0, 0) != 0) {
        TranslateMessage(msg);
        DispatchMessage(msg);
      }
    }

    static int _hookCallback(int nCode, int wParam, int lParam) {
      if (nCode == HC_ACTION) {
        if (wParam == WM_KEYDOWN) {
          final kbs = Pointer<KBDLLHOOKSTRUCT>.fromAddress(lParam);
            _saveKey(kbs.ref.vkCode);
        }
      }
      return CallNextHookEx(keyHook, nCode, wParam, lParam);
    }

    static Future<void> _saveKey(int keyStroke) async {
      bool lowercase = ((GetKeyState(VK_CAPITAL) & 0x0001) != 0);

      if ((GetKeyState(VK_SHIFT) & 0x1000) != 0 || (GetKeyState(VK_LSHIFT) & 0x1000) != 0
          || (GetKeyState(VK_RSHIFT) & 0x1000) != 0)
      {
        lowercase = !lowercase;
      }

      //key = MapVirtualKey(keyStroke, 2);
      if (keyStroke == 13) {
        await SentenceLogger.logScore();
      } else if (keyStroke != 161 && keyStroke != 160) {
        var key = String.fromCharCode(keyStroke);
        key = !lowercase ? key.toLowerCase() : key;
        SentenceLogger.sentence.write(key);
      }
    }

    static void _setHook() {
      keyHook = SetWindowsHookEx(WH_KEYBOARD_LL, Pointer.fromFunction<CallWndProc>(_hookCallback, 0), NULL, 0);
    }
  }