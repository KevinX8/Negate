import 'dart:ffi';

import 'package:negate/sentiment_db.dart';
import 'package:negate/logger/logger.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

  class WinLogger extends SentenceLogger {
    static final WinLogger _instance = WinLogger.init();
    static int _keyHook = 0;

    factory WinLogger() {
      return _instance;
    }

    WinLogger.init() : super.init();

    @override
    Future<void> startLogger(TfliteRequest request) async {
      await super.startLogger(request);
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
            WinLogger()._saveKey(kbs.ref.vkCode);
        }
      }
      return CallNextHookEx(_keyHook, nCode, wParam, lParam);
    }

    Future<void> _saveKey(int keyStroke) async {
      updateFGApp(_getFGAppName());
      bool lowercase = ((GetKeyState(VK_CAPITAL) & 0x0001) != 0);

      if ((GetKeyState(VK_SHIFT) & 0x1000) != 0 || (GetKeyState(VK_LSHIFT) & 0x1000) != 0
          || (GetKeyState(VK_RSHIFT) & 0x1000) != 0)
      {
        lowercase = !lowercase;
      }

      if (keyStroke == 13) {
        addAppEntry();
      } else if (keyStroke == 8) {
        var temp = getSentence().substring(0, getSentence().length - 1);
        clearSentence();
        writeToSentence(temp);
      } else if (keyStroke != 161 && keyStroke != 160) {
        var key = String.fromCharCode(keyStroke);
        key = !lowercase ? key.toLowerCase() : key;
        writeToSentence(key);
      }
    }

    void _setHook() {
      _keyHook = SetWindowsHookEx(WH_KEYBOARD_LL, Pointer.fromFunction<CallWndProc>(_hookCallback, 0), NULL, 0);
    }

    String _getFGAppName() {
      int nChar = 256;
      Pointer<Utf16> sPtr = malloc.allocate<Utf16>(nChar);
      Pointer<Uint32> iPtr = malloc.allocate<Uint32>(1);
      GetWindowThreadProcessId(GetForegroundWindow(), iPtr);
      int pid = iPtr.value;
      int op = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pid);
      GetModuleBaseName(op, NULL, sPtr, nChar);
      return sPtr.toDartString().substring(0,sPtr.toDartString().length-4);
    }
  }