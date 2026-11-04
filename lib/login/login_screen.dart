import 'package:flutter/material.dart';
import '../splash/splash_screen.dart' show AppLogo, BrandTitle;
import '../widgets/appcolors.dart';
import '../register/register_screen.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _remember = true;
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // TODO: call login API from Postman collection
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  InputDecoration _dec(String hint, IconData icon, {Widget? suffix}) {
    OutlineInputBorder b(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c));
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.navy),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: b(AppColors.border),
      focusedBorder: b(AppColors.red),
      errorBorder: b(Colors.red),
      focusedErrorBorder: b(Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: SizedBox.expand(
              child: Image.asset('assets/images/s1.png', fit: BoxFit.cover),
            ),
          ),
          Expanded(
            flex: 6,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogo(size: 80),
                        const SizedBox(height: 8),
                        const BrandTitle(fontSize: 38),
                        const Text('Inspect  •  Ensure  •  Stay Safe',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.navy)),
                        const SizedBox(height: 28),
                        const Text('Login to Your Account',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy)),
                        const SizedBox(height: 4),
                        const Text('Access your fire audit dashboard',
                            style: TextStyle(color: AppColors.navy)),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _userCtrl,
                          decoration: _dec('Email or Username', Icons.person),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter your email or username'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          onFieldSubmitted: (_) => _login(),
                          decoration: _dec(
                            'Password',
                            Icons.lock,
                            suffix: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Enter your password'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: _remember,
                              activeColor: AppColors.red,
                              onChanged: (v) =>
                                  setState(() => _remember = v ?? false),
                            ),
                            const Text('Remember Me',
                                style: TextStyle(fontSize: 13)),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Forgot Password?',
                                  style: TextStyle(
                                      color: AppColors.red, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: _loading
                                ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.login),
                            label: const Text('Login',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('OR',
                            style: TextStyle(color: AppColors.navy)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 220,
                          height: 42,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen()),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.navy,
                              backgroundColor: const Color(0xFFF0F1F4),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.person_add_alt_1, size: 18),
                            label: const Text('Register'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}