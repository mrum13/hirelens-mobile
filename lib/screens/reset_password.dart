import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/core/auth/auth_flags.dart';

// URGENT: Finish this page
// ignore: must_be_immutable
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController newPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> updatePassword() async {
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPasswordController.text),
      );

// logout session recovery
      await Supabase.instance.client.auth.signOut();

// reset flag
      isPasswordRecovery.value = false;

      setState(() {
        _isLoading = false;
      });
      context.go('/login');
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
        title: Text("Reset Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: newPasswordController,
              decoration: InputDecoration(
                  hint: Text("Masukkan password baru"),
                  label: Text("Password"),
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
                  if (newPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Isi email terlebih dahulu"),
                      backgroundColor: Colors.red,
                    ));
                  } else {
                    setState(() {
                      _isLoading = true;
                    });
                    updatePassword();
                  }
                },
                child: Text("Reset Password"))
          ],
        ),
      ),
    );
  }
}
