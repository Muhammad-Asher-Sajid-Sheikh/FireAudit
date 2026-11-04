import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowHelper {
  /// Small fixed window for splash / login / register.
  static Future<void> authMode() async {
    await windowManager.unmaximize();
    await windowManager.setMinimumSize(const Size(760, 680));
    await windowManager.setSize(const Size(760, 680));
    await windowManager.setResizable(false);
    await windowManager.setMaximizable(false);
    await windowManager.center();
  }

  /// Full-screen window for the dashboard.
  static Future<void> dashboardMode() async {
    await windowManager.setResizable(true);
    await windowManager.setMaximizable(true);
    await windowManager.setMinimumSize(const Size(1100, 720));
    await windowManager.maximize();
  }
}