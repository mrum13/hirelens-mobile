import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    return isLoading
        ? Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => GoRouter.of(context).pop(),
            ),
          ),
          body: Center(child: CircularProgressIndicator()),
        )
        : Scaffold(
          bottomNavigationBar: SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // LATER: Use GestureDetector instead
                  ElevatedButton(
                    onPressed: toggleCart,
                    child:
                        isOnCart
                            ? Text("Sudah di Keranjang")
                            : Text("Keranjang"),
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
              child: CustomScrollView(
                slivers: [
                  // URGENT: Find out why it's still overflowing
                  SliverAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    expandedHeight: 440,
                    pinned: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => GoRouter.of(context).pop(),
                    ),
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        final percent = ((constraints.maxHeight -
                                    kToolbarHeight) /
                                (240 - kToolbarHeight))
                            .clamp(0.0, 1.0);

                        final imageSize = 80 + (160 * percent);
                        final titleSize = 18 + (14 * percent);

                        return Padding(
                          padding: EdgeInsets.only(
                            top:
                                percent > 0.5
                                    ? MediaQuery.of(context).padding.top + 8
                                    : 0,
                            left: percent > 0.5 ? 16 : 0,
                            right: percent > 0.5 ? 16 : 0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  thumbnail,
                                  width: double.infinity,
                                  height: imageSize,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "dari $vendorName",
                                style: TextStyle(
                                  fontSize: 12 + (4 * percent),
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    bottom: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        Tab(text: "Deskripsi"),
                        Tab(text: "Galeri"),
                        Tab(text: "Behind the Scenes"),
                      ],
                    ),
                  ),

                  SliverFillRemaining(
                    child: TabBarView(
                      children: [
                        // Deskripsi
                        Container(
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
