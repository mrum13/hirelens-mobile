import 'dart:developer';

import 'package:flutter/material.dart';

class CheckoutSuccessPage extends StatefulWidget {
  final String orderId;
  final String result;

  const CheckoutSuccessPage({
    super.key,
    required this.orderId,
    required this.result,
  });

  @override
  State<CheckoutSuccessPage> createState() => _CheckOutSuocessPageState();
}

class _CheckOutSuocessPageState extends State<CheckoutSuccessPage> {
  void simulateLoadAndRedirect() async {
    log("Order ID = ${widget.orderId}");
    log("Order Result = ${widget.result}");
    await Future.delayed(const Duration(seconds: 3));
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
        appBar: AppBar(title: Text("Pembayaran Berhasil!")),
        body: Center(
          child: Text(
            "Animasi dalam pengerjaan. Anda akan diarahkan kembali ke Halaman Utama dalam 3 detik",
          ),
        ),
      ),
    );
  }
}
