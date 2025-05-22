import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String productName;
  final String productImage;
  final String productDescription;
  final double productPrice;

  const ProductDetailPage({
    super.key,
    required this.productName,
    required this.productImage,
    required this.productDescription,
    required this.productPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Produk'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              productImage,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                productName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Rp ${productPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                productDescription,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ditambahkan ke keranjang!')),
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Tambah ke Keranjang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
