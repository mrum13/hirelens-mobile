import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          const SnackBar(content: Text('Verifikasi berhasil! Silakan login.')),
        );
        Navigator.of(context).pop();
      } else {
        _showError('Kode OTP salah atau sudah kadaluarsa.');
      }
    } catch (e) {
      _showError('Verifikasi gagal: e.toString()}');
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
                style: TextStyle(fontSize: 16, color: Colors.grey),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 41, 41, 41),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Verifikasi',
                            style: TextStyle(color: Colors.white70),
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
