import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:negate/sentiment_db.dart';
import 'package:negate/logger/logger.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

class WinLogger extends SentenceLogger {
  static final WinLogger _instance = WinLogger.init();
  static int _keyHook = 0;
  static int _mouseHook = 0;
  static DateTime _lastLogged = DateTime.now();

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

  static int _mouseCallback(int nCode, int wParam, int lParam) {
    if (wParam == WM_LBUTTONDOWN) {
      var name = WinLogger()._getFGAppName();
      WinLogger().updateFGApp(name);
      if (!WinLogger().hasAppIcon(name)) {
        var icon = WinLogger().findAppIcon(GetForegroundWindow());
        if (icon != null) {
          WinLogger().addAppIcon(name, icon);
        }
      }
    }
    return CallNextHookEx(_mouseHook, nCode, wParam, lParam);
  }

  Future<void> _saveKey(int keyStroke) async {
    updateFGApp(_getFGAppName());
    bool lowercase = ((GetKeyState(VK_CAPITAL) & 0x0001) != 0);

    if ((GetKeyState(VK_SHIFT) & 0x1000) != 0 ||
        (GetKeyState(VK_LSHIFT) & 0x1000) != 0 ||
        (GetKeyState(VK_RSHIFT) & 0x1000) != 0) {
      lowercase = !lowercase;
    }

    if (keyStroke == 13) {
      if (_lastLogged.difference(DateTime.now()).inSeconds > 10) {
        clearSentence();
      } else {
        addAppEntry();
      }
    } else if (keyStroke == 8) {
      var temp = getSentence().substring(0, getSentence().length - 1);
      clearSentence();
      writeToSentence(temp);
    } else if (keyStroke != 161 && keyStroke != 160) {
      var key = String.fromCharCode(keyStroke);
      key = !lowercase ? key.toLowerCase() : key;
      writeToSentence(key);
    }
    _lastLogged = DateTime.now();
  }

  void _setHook() {
    _keyHook = SetWindowsHookEx(WH_KEYBOARD_LL,
        Pointer.fromFunction<CallWndProc>(_hookCallback, 0), NULL, 0);
    _mouseHook = SetWindowsHookEx(WH_MOUSE_LL,
        Pointer.fromFunction<CallWndProc>(_mouseCallback, 0), NULL, 0);
  }

  String _getFGAppName() {
    int nChar = 256;
    Pointer<Utf16> sPtr = malloc.allocate<Utf16>(nChar);
    Pointer<Uint32> iPtr = malloc.allocate<Uint32>(1);
    GetWindowThreadProcessId(GetForegroundWindow(), iPtr);
    int pid = iPtr.value;
    int op =
        OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pid);
    GetModuleBaseName(op, NULL, sPtr, nChar);
    return _formatName(
        sPtr.toDartString().substring(0, sPtr.toDartString().length - 4));
  }

  String _formatName(String name) {
    return name[0].toUpperCase() + name.toLowerCase().substring(1);
  }

  Uint8List? findAppIcon(int hWnd, {background = 0xffffff, hover = false}) {
    var icon =
        SendMessage(hWnd, WM_GETICON, 2, 0); // ICON_SMALL2 - User Made Apps
    if (icon == 0) {
      icon = GetClassLongPtr(hWnd, -14);
    } // GCLP_HICON - Microsoft Win Apps
    if (icon == 0) {
      return null;
    }

    final pIconInfo = calloc<ICONINFO>();

    GetIconInfo(icon, pIconInfo);
    final hICON = calloc<BITMAP>();
    GetObject(pIconInfo.ref.hbmColor, sizeOf<BITMAP>(), hICON);

    final int hScreen = GetDC(hWnd);
    final int hDC = CreateCompatibleDC(hScreen);
    final int hBitmap = CreateCompatibleBitmap(
        hScreen, GetSystemMetrics(SM_CXICON), GetSystemMetrics(SM_CYICON));
    SelectObject(hDC, hBitmap);
    final clientRect = calloc<RECT>()
      ..ref.left = 0
      ..ref.right = GetSystemMetrics(SM_CXICON)
      ..ref.bottom = GetSystemMetrics(SM_CYICON)
      ..ref.top = 0;
    FillRect(hDC, clientRect, CreateSolidBrush(background));
    DrawIcon(hDC, 0, 0, icon);

    final bmpScreen = calloc<BITMAP>();
    GetObject(hBitmap, sizeOf<BITMAP>(), bmpScreen);
    final bitmapFileHeader = calloc<BITMAPFILEHEADER>();
    final bitmapInfoHeader = calloc<BITMAPINFOHEADER>()
      ..ref.biSize = sizeOf<BITMAPINFOHEADER>()
      ..ref.biWidth = bmpScreen.ref.bmWidth
      ..ref.biHeight = bmpScreen.ref.bmHeight
      ..ref.biPlanes = 1
      ..ref.biBitCount = 32
      ..ref.biCompression = BI_RGB;

    final dwBmpSize =
        ((bmpScreen.ref.bmWidth * bitmapInfoHeader.ref.biBitCount + 31) /
                32 *
                4 *
                bmpScreen.ref.bmHeight)
            .toInt();

    final lpBitmap = calloc<Uint8>(dwBmpSize);
    GetDIBits(hDC, hBitmap, 0, bmpScreen.ref.bmHeight, lpBitmap,
        bitmapInfoHeader.cast(), DIB_RGB_COLORS);

    final dwSizeOfDIB =
        dwBmpSize + sizeOf<BITMAPFILEHEADER>() + sizeOf<BITMAPINFOHEADER>();
    bitmapFileHeader.ref.bfOffBits =
        sizeOf<BITMAPFILEHEADER>() + sizeOf<BITMAPINFOHEADER>();

    bitmapFileHeader.ref.bfSize = dwSizeOfDIB;
    bitmapFileHeader.ref.bfType = 0x4D42; // BM

    var b = BytesBuilder();
    b.add(Pointer<Uint8>.fromAddress(bitmapFileHeader.address)
        .asTypedList(sizeOf<BITMAPFILEHEADER>()));
    b.add(Pointer<Uint8>.fromAddress(bitmapInfoHeader.address)
        .asTypedList(sizeOf<BITMAPINFOHEADER>()));
    b.add(lpBitmap.asTypedList(dwBmpSize));
    DeleteDC(hDC);
    DeleteObject(hBitmap);
    ReleaseDC(NULL, hScreen);
    free(bmpScreen);
    free(bitmapFileHeader);
    free(bitmapInfoHeader);
    free(lpBitmap);
    free(pIconInfo);
    free(hICON);
    free(clientRect);
    Uint8List img = b.takeBytes();
    //log(base64Encode(img));
    return img;
  }
}
