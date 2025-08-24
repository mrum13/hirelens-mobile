import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:unsplash_clone/components/buttons.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/theme.dart';

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
  List<String> galleryImages = [];

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

  void fetchGalleryImages() async {
    final client = Supabase.instance.client;
    try {
      final response = await client
          .from('item_images')
          .select('image_url')
          .eq('item_id', dataId);

      if (response.isNotEmpty) {
        setState(() {
          galleryImages = List<String>.from(
            response.map((item) => item['image_url']),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error while fetching product galery: $e")),
      );
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
    fetchGalleryImages();
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
                spacing: 8,
                children: [
                  Expanded(
                    child: MyOutlinedButton(
                      height: 48,
                      borderRadius: 4,
                      variant: MyButtonVariant.white,
                      onTap: toggleCart,
                      child: Text(
                        isOnCart ? 'Sudah di Keranjang' : 'Keranjang',
                        style: TextStyle(
                          color:
                              themeFromContext(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: MyFilledButton(
                      height: 48,
                      borderRadius: 4,
                      variant: MyButtonVariant.primary,
                      onTap:
                          () => GoRouter.of(
                            context,
                          ).push('/checkout/${widget.dataId}'),
                      child: Text(
                        "Pesan Langsung",
                        style: TextStyle(
                          color:
                              themeFromContext(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
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
                  // URGENT: Fix the issue where SliverFillRemaining get covered by all the pinned Headers
                  SliverAppBar(
                    pinned: true,
                    surfaceTintColor: Colors.transparent,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => GoRouter.of(context).pop(),
                    ),
                  ),

                  SliverPersistentHeader(
                    pinned: true,
                    delegate: CollapsibleHeaderDelegate(
                      maxExtentHeight: 300,
                      minExtentHeight: 120,
                      imageUrl: thumbnail,
                      title: name,
                      subtitle: "Dari $vendorName",
                    ),
                  ),

                  SliverPersistentHeader(
                    pinned: true,
                    delegate: TabBarHeaderDelegate(
                      TabBar(
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        tabs: [
                          Tab(text: "Deskripsi"),
                          Tab(text: "Galeri"),
                          Tab(text: "Behind the Scene"),
                        ],
                      ),
                    ),
                  ),

                  SliverFillRemaining(
                    child: TabBarView(
                      children: [
                        // Deskripsi
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 32),
                              Text("Alamat : $address"),
                              SizedBox(height: 8),
                              Text(description),
                            ],
                          ),
                        ),

                        // Galeri
                        Container(
                          padding: const EdgeInsets.all(16),
                          child:
                              galleryImages.isNotEmpty
                                  ? GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                        ),
                                    itemCount: galleryImages.length,
                                    itemBuilder: (context, index) {
                                      // TODO: Create an expandable image viewer widget
                                      return Placeholder();
                                    },
                                  )
                                  : Center(
                                    child: Text(
                                      "Belum ada gambar untuk produk ini.",
                                    ),
                                  ),
                        ),

                        // Behind the Scene
                        Container(
                          padding: const EdgeInsets.all(16),
                          child:
                              galleryImages.isNotEmpty
                                  ? GridView.builder(
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
                                  )
                                  : Center(
                                    child: Text(
                                      "Belum ada media untuk produk ini.",
                                    ),
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

class CollapsibleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxExtentHeight;
  final double minExtentHeight;
  final String imageUrl;
  final String title;
  final String subtitle;

  CollapsibleHeaderDelegate({
    required this.maxExtentHeight,
    required this.minExtentHeight,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  @override
  double get maxExtent => maxExtentHeight;

  @override
  double get minExtent => minExtentHeight;

  @override
  bool shouldRebuild(covariant CollapsibleHeaderDelegate old) =>
      old.maxExtent != maxExtent ||
      old.minExtent != minExtent ||
      old.imageUrl != imageUrl ||
      old.title != title ||
      old.subtitle != subtitle;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final screenW = MediaQuery.of(context).size.width;
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final curved = Curves.easeInOut.transform(t);

    final startW = screenW - 36;
    final startH = startW * 10 / 16;

    final horizontalPadding = 24.0;
    final endW = 160 - (horizontalPadding * 2);
    final endH = endW; // 1:1

    final imageW = lerpDouble(startW, endW, curved)!;
    final imageH = lerpDouble(startH, endH, curved)!;

    final startLeft = (screenW - startW) / 2;
    final endLeft = horizontalPadding;
    final imageLeft = lerpDouble(startLeft, endLeft, curved)!;

    final startTop = 8.0;
    final endTop = (minExtent - imageH) / 2;
    final imageTop = lerpDouble(startTop, endTop, curved)!;

    // Title: below image when expanded (centered), moves to the right of image when collapsed
    final titleStartTop = startTop + startH + 12.0; // below the big image
    // when collapsed, keep it vertically centered in minExtent
    final titleEndTop = (minExtent - 20.0) / 2;
    final titleTop = lerpDouble(titleStartTop, titleEndTop, curved)!;

    // title left: centered -> to right of small image
    final titleStartLeft = 24;
    final titleEndLeft = imageLeft + imageW + 12.0;
    final titleLeft = lerpDouble(titleStartLeft, titleEndLeft, curved)!;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // background optional (blur/gradient) - tweak if desired
          Positioned.fill(child: Container()),

          // image
          Positioned(
            left: imageLeft,
            top: imageTop,
            width: imageW,
            height: imageH,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),

          // Title & subtitle
          Positioned(
            left: titleLeft,
            top: titleTop,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: lerpDouble(20, 16, curved),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// small helper to pin TabBar as its own sliver (prevents overlap)
class TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  TabBarHeaderDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant TabBarHeaderDelegate old) => false;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }
}
