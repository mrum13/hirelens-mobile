import 'package:flutter/material.dart';

// URGENT: Finish this page
// ignore: must_be_immutable
class ResetPasswordPage extends StatefulWidget {
  String? email;
  ResetPasswordPage({super.key, this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(),
      ),
    );
  }
}
