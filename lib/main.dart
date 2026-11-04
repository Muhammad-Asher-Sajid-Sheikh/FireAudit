import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'splash/splash_screen.dart';
import 'widgets/appcolors.dart';
import 'core/window_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const options = WindowOptions(
    size: Size(760, 680),
    minimumSize: Size(760, 680),
    center: true,
    title: 'Fire Audit',
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

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