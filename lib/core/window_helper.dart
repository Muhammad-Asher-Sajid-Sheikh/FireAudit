import 'dart:ui';
import 'package:window_manager/window_manager.dart';

class WindowHelper {
  static Size _screen() {
    final display = PlatformDispatcher.instance.displays.first;
    return display.size / display.devicePixelRatio; // logical pixels
  }

  static Size _authSize() {
    final screen = _screen();
    final w = (screen.width * 0.65).clamp(900.0, 1200.0).toDouble();
    final h = (screen.height * 0.9).clamp(650.0, 900.0).toDouble();
    return Size(w, h);
  }

  /// Login / register window.
  static Future<void> authMode() async {
    await windowManager.unmaximize();
    await windowManager.setMinimumSize(const Size(800, 650));
    await windowManager.setSize(_authSize());
    await windowManager.center();
  }

  /// Dashboard window: bigger, and maximized.
  static Future<void> dashboardMode() async {
    await windowManager.setMinimumSize(const Size(1100, 700));
    await windowManager.maximize();
  }
}