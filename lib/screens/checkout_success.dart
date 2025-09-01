import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckoutSuccessPage extends StatefulWidget {
  const CheckoutSuccessPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<CheckoutSuccessPage> createState() => _CheckOutSuocessPageState();
}

class _CheckOutSuocessPageState extends State<CheckoutSuccessPage> {
  void simulateLoadAndRedirect() async {
    // URGENT: Create an Edge Function that can return data for the payment data (transaction ID, payment type, payment method, amount and transaction status)
    // URGENT: Implement the custom midtrans webview on some payment related widget/page
    // TODO: Drop usage midtrans_sdk
    log("Order Result = ${widget.orderId}");
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      GoRouter.of(context).go('/home');
    }
  }

  @override
  void initState() {
    super.initState();
    simulateLoadAndRedirect();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Pembayaran Berhasil!"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          // URGENT: Find stock SVG animation and sound for this
          child: Text(
            "Animasi dalam pengerjaan. Anda akan diarahkan kembali ke Halaman Utama dalam 3 detik",
          ),
        ),
      ),
    );
  }
}
