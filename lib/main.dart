import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'core/window_helper.dart';
import 'splash/splash_screen.dart';
import 'widgets/appcolors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await windowManager.waitUntilReadyToShow(
    const WindowOptions(title: 'Fire Audit'),
        () async {
      await WindowHelper.authMode(); // size the window before showing it
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(const FireAuditApp());
}

class FireAuditApp extends StatelessWidget {
  const FireAuditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fire Audit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.red),
      ),
      home: const SplashScreen(),
    );
  }
}