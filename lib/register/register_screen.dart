import 'package:flutter/material.dart';
import '../splash/splash_screen.dart' show AppLogo, BrandTitle;
import '../widgets/appcolors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // TODO: call register API from Postman collection
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created. Please login.')),
    );
    Navigator.of(context).pop();
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

  Widget _eye(bool obscure, VoidCallback onTap) => IconButton(
    icon: Icon(obscure
        ? Icons.visibility_off_outlined
        : Icons.visibility_outlined),
    onPressed: onTap,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: SizedBox.expand(
              child: Image.asset('assets/images/s3.png', fit: BoxFit.cover),
            ),
          ),
          Expanded(
            flex: 6,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogo(size: 70),
                        const SizedBox(height: 8),
                        const BrandTitle(fontSize: 36),
                        const Text('Inspect  •  Ensure  •  Stay Safe',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.navy)),
                        const SizedBox(height: 22),
                        const Text('Create Your Account',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navy)),
                        const SizedBox(height: 4),
                        const Text('Register to get started with Fire Audit',
                            style: TextStyle(color: AppColors.navy)),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _name,
                          decoration: _dec('Full Name', Icons.person),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter your full name'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _dec('Email Address', Icons.email),
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'Enter your email';
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(t)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _pass,
                          obscureText: _obscure1,
                          decoration: _dec('Password', Icons.lock,
                              suffix: _eye(_obscure1,
                                      () => setState(() => _obscure1 = !_obscure1))),
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Minimum 6 characters'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirm,
                          obscureText: _obscure2,
                          onFieldSubmitted: (_) => _register(),
                          decoration: _dec('Confirm Password', Icons.lock,
                              suffix: _eye(_obscure2,
                                      () => setState(() => _obscure2 = !_obscure2))),
                          validator: (v) =>
                          v != _pass.text ? 'Passwords do not match' : null,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _register,
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
                                : const Icon(Icons.person_add_alt_1),
                            label: const Text('Register',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('OR',
                            style: TextStyle(color: AppColors.navy)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: () {}, // TODO: Google sign-in (if backend supports it)
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.navy,
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.g_mobiledata, size: 30),
                            label: const Text('Continue with Google'),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account?',
                                style: TextStyle(fontSize: 13)),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Login',
                                  style: TextStyle(
                                      color: AppColors.red,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
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