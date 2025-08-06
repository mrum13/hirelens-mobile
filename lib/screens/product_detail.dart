import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.dataId});
  final int dataId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late int dataId;
  String name = '';
  String thumbnail = '';
  String description = '';
  String address = '';
  String vendorName = '';
  late int vendorId;
  double price = 0;
  bool isLoading = true;

  void checkIsAlreadyOnCart() async {
    // TODO: Finish this function
  }

  void fetchAndSetData() async {
    dataId = widget.dataId;

    final client = Supabase.instance.client;

    try {
      final data =
          await client
              .from('items')
              .select(
                'id, name, thumbnail, description, price, address, vendor(id, name)',
              )
              .eq('id', dataId)
              .single();

      if (data.isEmpty) {
        throw Exception('Product not found');
      }

      setState(() {
        name = data['name'] ?? '';
        thumbnail = data['thumbnail'] ?? '';
        description = data['description'] ?? '';
        address = data['address'] ?? '';
        vendorName = data['vendor']['name'] ?? '';
        vendorId = data['vendor']['id'] ?? '';
        price = (data['price'] as num).toDouble();

        isLoading = false;
      });
    } catch (e) {
      mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error while fetching product details: $e")),
          )
          : null;
    }
  }

  void addToCart() async {
    final client = Supabase.instance.client;
    setState(() {
      isLoading = true;
    });

    try {
      await client.from('shopping_cart').insert({"item_id": dataId});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil ditambahkan ke keranjang!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add item to shopping cart! $e")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // TODO: Use checkIsAlreadyOnCart method
    fetchAndSetData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detail Produk'),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Detail Produk'),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TODO: Refactor the whole layout
              Image.network(
                thumbnail,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "dari $vendorName",
                  style: const TextStyle(
                    fontSize: 16,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Rp ${price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(description, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  onPressed: addToCart,
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Tambah ke Keranjang',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
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
