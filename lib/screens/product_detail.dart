import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/screens/checkout.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.dataId});
  final int dataId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

// TODO: use atypical design as reference
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
  bool isOnCart = false;

  Future<bool> checkIsAlreadyOnCart() async {
    final client = Supabase.instance.client;

    final response =
        await client
            .from('shopping_cart')
            .select()
            .eq('user_id', client.auth.currentUser!.id)
            .eq('item_id', dataId)
            .maybeSingle();

    return response != null;
  }

  void fetchAndSetData() async {
    dataId = widget.dataId;
    isOnCart = await checkIsAlreadyOnCart();

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

  void toggleCart() async {
    final client = Supabase.instance.client;
    setState(() {
      isLoading = true;
    });

    try {
      if (isOnCart) {
        await client
            .from('shopping_cart')
            .delete()
            .eq('item_id', dataId)
            .eq('user_id', client.auth.currentUser!.id);

        setState(() {
          isOnCart = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berhasil dihapus dari keranjang!")),
        );
      } else {
        await client.from('shopping_cart').insert({"item_id": dataId});

        setState(() {
          isOnCart = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berhasil ditambahkan ke keranjang!")),
        );
      }
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
    fetchAndSetData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // LATER: Use GestureDetector instead
              ElevatedButton(
                onPressed: toggleCart,
                child:
                    isOnCart ? Text("Sudah di Keranjang") : Text("Keranjang"),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CheckoutPage(dataId: dataId),
                      ),
                    ),
                child: Text("Pesan Langsung"),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          initialIndex: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top image
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    thumbnail,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "dari $vendorName",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Tab bar
              TabBar(
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.black,
                ),
                unselectedLabelStyle: const TextStyle(color: Colors.black),
                labelColor: Colors.white,
                isScrollable: true,
                dividerColor: Colors.transparent,
                tabs: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    child: Text("Deskripsi"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    child: Text("Galeri"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    child: Text("Behind the Scenes"),
                  ),
                ],
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  children: [
                    // Deskripsi
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Alamat : $address"),
                          SizedBox(height: 8),
                          Text(description),
                        ],
                      ),
                    ),

                    // Galeri
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          // TODO: Create an expandable image viewer widget
                          return Placeholder();
                        },
                      ),
                    ),

                    // Behind the Scene
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          // TODO: Create an expandable image and video viewer widget
                          return Placeholder();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
