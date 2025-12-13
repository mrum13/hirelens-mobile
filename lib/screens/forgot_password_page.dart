import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> forgotPassword(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'hirelens://reset-password',
      );

      setState(() {
        _isLoading = false;
      });
      // pindah halaman (tanpa back)
      GoRouter.of(context).go('/login');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forgot Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                  hint: Text("Masukkan email"),
                  label: Text("Email"),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4))),
            ),
            const SizedBox(
              height: 24,
            ),
            _isLoading
            ? Center(child: CircularProgressIndicator(),) 
            : FilledButton(
                onPressed: () {
                  if (emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Isi email terlebih dahulu"),
                      backgroundColor: Colors.red,
                    ));
                  } else {
                    setState(() {
                      _isLoading = true;
                    });
                    forgotPassword(emailController.text);
                  }
                },
                child: Text("Kirim Email reset"))
          ],
        ),
      ),
    );
  }
}
