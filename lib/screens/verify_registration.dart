import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/theme.dart';

class VerifyRegistrationPage extends StatefulWidget {
  final String email;

  const VerifyRegistrationPage({super.key, required this.email});

  @override
  State<VerifyRegistrationPage> createState() => _VerifyRegistrationPageState();
}

class _VerifyRegistrationPageState extends State<VerifyRegistrationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      _showError('Kode OTP tidak boleh kosong');
      return;
    }
    final email = widget.email;
    if (email.isEmpty) {
      _showError('Email tidak ditemukan. Silakan daftar ulang.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Verifikasi OTP menggunakan Supabase
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        token: otp,
        email: email,
      );
      if (response.user != null) {
        // Sukses, bisa navigate ke halaman login atau home
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verifikasi berhasil! Selamat Datang di Project Hirelens',
            ),
          ),
        );

        GoRouter.of(context).pushReplacement('/home');
      } else {
        _showError('Kode OTP salah atau sudah kadaluarsa.');
      }
    } catch (e) {
      _showError('Verifikasi gagal: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi OTP'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Masukkan kode OTP yang dikirim ke email Anda',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Kode OTP',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),
              MyFilledButton(
                isLoading: _isLoading,
                variant: MyButtonVariant.primary,
                onTap: !_isLoading ? _verifyOtp : null,
                child: Text(
                  "Verifikasi",
                  style: TextStyle(
                    color: themeFromContext(context).colorScheme.surface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
