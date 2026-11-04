import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import '../widgets/appcolors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..forward().whenComplete(_next);
  }

  // TODO: check stored token here -> dashboard or login
  void _next() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: SizedBox.expand(
              child: Image.asset('assets/images/s2.png', fit: BoxFit.cover),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(size: 110),
                  const SizedBox(height: 16),
                  const BrandTitle(fontSize: 44),
                  const SizedBox(height: 8),
                  const Text('Inspect  •  Ensure  •  Stay Safe',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.navy)),
                  const SizedBox(height: 24),
                  const Text('Fire Safety Compliance\nMade Simple',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          color: AppColors.navy)),
                  const SizedBox(height: 48),
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                        strokeWidth: 4, color: AppColors.red),
                  ),
                  const SizedBox(height: 8),
                  const Text('Loading Application...',
                      style: TextStyle(fontSize: 12, color: AppColors.grey)),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _c,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _c.value,
                        minHeight: 8,
                        color: AppColors.red,
                        backgroundColor: AppColors.border,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder logo until you give me the real logo file.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 90});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(color: AppColors.navy, width: 4),
      ),
      child: Icon(Icons.local_fire_department,
          color: Colors.white, size: size * 0.6),
    );
  }
}

class BrandTitle extends StatelessWidget {
  final double fontSize;
  const BrandTitle({super.key, this.fontSize = 36});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: 'Fire ', style: TextStyle(color: AppColors.red)),
        TextSpan(text: 'Audit', style: TextStyle(color: AppColors.navy)),
      ]),
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800),
    );
  }
}