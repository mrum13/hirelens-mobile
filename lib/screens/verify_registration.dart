import 'dart:async';
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
  bool _isResending = false;
  int _secondsRemaining = 0;
  Timer? _timer;

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
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
      print('Verifying OTP for: $email');

      // Coba berbagai tipe OTP
      AuthResponse? response;

      try {
        // Try magiclink first
        response = await Supabase.instance.client.auth.verifyOTP(
          type: OtpType.magiclink,
          token: otp,
          email: email,
        );
      } catch (e) {
        print('⚠️ Magiclink failed, trying email type...');
        // Fallback to email type
        response = await Supabase.instance.client.auth.verifyOTP(
          type: OtpType.email,
          token: otp,
          email: email,
        );
      }

      if (response.user != null) {
        if (!mounted) return;
        print('✅ OTP verified successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verifikasi berhasil! Selamat datang di HireLens'),
          ),
        );
        GoRouter.of(context).pushReplacement('/home');
      } else {
        _showError('Kode OTP salah atau sudah kadaluarsa.');
      }
    } catch (e) {
      print('❌ Verify error: $e');
      _showError('Verifikasi gagal: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending || _secondsRemaining > 0) return;

    setState(() => _isResending = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Kode OTP baru telah dikirim ke ${widget.email}')),
      );
      _startCooldown();
    } catch (e) {
      _showError('Gagal mengirim ulang kode: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
              const SizedBox(height: 24),
              TextButton(
                onPressed: (_secondsRemaining == 0 && !_isResending)
                    ? _resendOtp
                    : null,
                child: _isResending
                    ? const Text('Mengirim ulang...')
                    : Text(
                        _secondsRemaining > 0
                            ? 'Kirim ulang kode dalam $_secondsRemaining detik'
                            : 'Kirim ulang kode OTP',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
