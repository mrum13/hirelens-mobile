import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Keranjang Belanja')),
      body: Center(
        child: Text(
          'Ini halaman keranjang belanja',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
