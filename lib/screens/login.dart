import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final client = Supabase.instance.client;

    setState(() => _isLoading = true);

    try {
      final response = await client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (response.user != null) {
        while (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
        }
        GoRouter.of(context).pushReplacement('/home');
      } else {
        _showError('Login gagal. Silakan coba lagi.');
      }
    } catch (e) {
      if (mounted) {
        if (e is AuthApiException) {
          if (e.code == 'email_not_confirmed') {
            GoRouter.of(context).push(
              '/verify_registration?email=${_emailController.text.trim()}',
            );

            await client.auth.resend(
              type: OtpType.signup,
              email: _emailController.text.trim(),
            );
          }
        } else {
          _showError('Terjadi kesalahan: ${e.toString()}');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(labelText: label);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text(
                  'HireLens',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Silahkan login untuk melanjutkan.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration('Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                MyFilledButton(
                  variant: MyButtonVariant.primary,
                  onTap: _isLoading ? null : _login,
                  isLoading: _isLoading,
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: themeFromContext(context).colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                MyFilledButton(
                  variant: MyButtonVariant.neutral,
                  onTap: () => GoRouter.of(context).go('/'),
                  isLoading: _isLoading,
                  child: Text(
                    "Kembali",
                    style: TextStyle(
                      color: themeFromContext(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
