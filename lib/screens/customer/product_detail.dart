import 'dart:ui';

import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/screens/vendor_detail_page.dart';
import 'package:unsplash_clone/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.dataId});
  final String dataId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  late String dataId;
  String name = '';
  String thumbnail = '';
  String description = '';
  String address = '';
  String vendorName = '';
  String vendorId = '';
  String vendorNumber = '';
  double price = 0;
  bool isLoading = true;
  bool isOnCart = false;
  List<String> galleryImages = [];
  List<String> btsImages = [];
  late final TabController _tabController;

  Future<bool> checkIsAlreadyOnCart() async {
    final client = Supabase.instance.client;

    final response = await client
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
      final data = await client
          .from('items')
          .select(
            'id, name, thumbnail, description, price, address, vendor_id(id, name, phone)', // ✅ UBAH: vendor -> vendor_id
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
        vendorNumber = data['vendor_id']['phone'];
        vendorName =
            data['vendor_id']['name'] ?? ''; // ✅ UBAH: vendor -> vendor_id
        vendorId = data['vendor_id']['id'] ?? ''; // ✅ UBAH: vendor -> vendor_id
        price = (data['price'] as num).toDouble();

        isLoading = false;
      });
    } catch (e) {
      mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Error while fetching product details: $e")),
            )
          : null;
    }
  }

  void fetchGalleryImages() async {
    final client = Supabase.instance.client;
    try {
      final response = await client
          .from('item_gallery')
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

  void fetchBtsImages() async {
    final client = Supabase.instance.client;
    try {
      final response = await client
          .from('item_bts')
          .select('image_url')
          .eq('item_id', dataId);

      if (response.isNotEmpty) {
        setState(() {
          btsImages = List<String>.from(
            response.map((item) => item['image_url']),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error while fetching product BTS: $e")),
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
        await client.from('shopping_cart').insert({
          "item_id": dataId,
          "user_id": client.auth.currentUser!.id,
        });

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

void openWhatsApp({required String phoneNumber}) async {
  final number = phoneNumber.startsWith('0')
      ? phoneNumber.replaceFirst('0', '62')
      : phoneNumber;

  final uri = Uri.parse('https://wa.me/$number');

  try {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    debugPrint('Gagal membuka WhatsApp: $e');
  }
}

  @override
  void initState() {
    super.initState();
    fetchAndSetData();
    fetchGalleryImages();
    fetchBtsImages();

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DMethod.log(galleryImages.length.toString(), prefix: "Gallery Length");
    return isLoading
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => GoRouter.of(context).pop(),
              ),
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.chat_outlined,
                      color: Colors.white,
                      size: 24,
                    ))
              ],
            ),
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => GoRouter.of(context).pop(),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      openWhatsApp(phoneNumber: vendorNumber);
                    },
                    icon: Icon(
                      Icons.chat_outlined,
                      color: Colors.white,
                      size: 24,
                    ))
              ],
            ),
            bottomNavigationBar: Container(
              // color: Colors.amber,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
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
                        onTap: () => GoRouter.of(
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
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: AspectRatio(
                      aspectRatio: 1 / 0.80,
                      child: Image.network(
                        thumbnail,
                      )),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(name),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: TabBarHeaderDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabs: const [
                        Tab(text: "Deskripsi"),
                        Tab(text: "Galeri"),
                        Tab(text: "Behind the Scene"),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  // Deskripsi
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                    padding: const EdgeInsets.all(8),
                    child: galleryImages.isNotEmpty
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
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  galleryImages[index],
                                  fit: BoxFit.cover,
                                ),
                              );
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
                    child: btsImages.isNotEmpty
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: btsImages.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  btsImages[index],
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              "Belum ada gambar untuk produk ini.",
                            ),
                          ),
                  ),
                ],
              ),
            )

            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       ClipRRect(
            //         borderRadius: BorderRadius.circular(12),
            //         child: Image.network(thumbnail, fit: BoxFit.cover, height: MediaQuery.of(context).size.height/2.5, width: double.infinity,) ,
            //       ),
            //       const SizedBox(
            //         height: 16,
            //       ),
            //       Text(
            //         name,
            //         maxLines: 1,
            //         overflow: TextOverflow.ellipsis,
            //         style: TextStyle(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //       InkWell(
            //         onTap: () => GoRouter.of(
            //           context,
            //         ).push('/vendor-detail-page/$vendorId'),
            //         child: Padding(
            //           padding: const EdgeInsets.only(top: 6),
            //           child: Text(
            //             vendorName,
            //             maxLines: 1,
            //             overflow: TextOverflow.ellipsis,
            //             style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            //           ),
            //         ),
            //       ),
            //       TabBar(
            //         controller: _tabController,
            //         tabAlignment: TabAlignment.start,
            //         isScrollable: true,
            //         tabs: [
            //           Tab(text: "Deskripsi"),
            //           Tab(text: "Galeri"),
            //           Tab(text: "Behind the Scene"),
            //         ],
            //       ),
            //       TabBarView(
            //         controller: _tabController,
            //         physics: AlwaysScrollableScrollPhysics(),
            //         children: [
            //           // Deskripsi
            //           Container(
            //             padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text("Alamat : $address"),
            //                 SizedBox(height: 8),
            //                 Text(description),
            //               ],
            //             ),
            //           ),

            //           // Galeri
            //           Container(
            //             padding: const EdgeInsets.all(8),
            //             child: galleryImages.isNotEmpty
            //                 ? GridView.builder(
            //                     shrinkWrap: true,
            //                     physics: NeverScrollableScrollPhysics(),
            //                     gridDelegate:
            //                         SliverGridDelegateWithFixedCrossAxisCount(
            //                       crossAxisCount: 2,
            //                       crossAxisSpacing: 8,
            //                       mainAxisSpacing: 8,
            //                     ),
            //                     itemCount: galleryImages.length,
            //                     itemBuilder: (context, index) {
            //                       return ClipRRect(
            //                         borderRadius: BorderRadius.circular(8),
            //                         child: Image.network(
            //                           galleryImages[index],
            //                           fit: BoxFit.cover,
            //                         ),
            //                       );
            //                     },
            //                   )
            //                 : Center(
            //                     child: Text(
            //                       "Belum ada gambar untuk produk ini.",
            //                     ),
            //                   ),
            //           ),

            //           // Behind the Scene
            //           Container(
            //             padding: const EdgeInsets.all(16),
            //             child: btsImages.isNotEmpty
            //                 ? GridView.builder(
            //                     shrinkWrap: true,
            //                     physics: NeverScrollableScrollPhysics(),
            //                     gridDelegate:
            //                         SliverGridDelegateWithFixedCrossAxisCount(
            //                       crossAxisCount: 2,
            //                       crossAxisSpacing: 8,
            //                       mainAxisSpacing: 8,
            //                     ),
            //                     itemCount: btsImages.length,
            //                     itemBuilder: (context, index) {
            //                       return ClipRRect(
            //                         borderRadius: BorderRadius.circular(8),
            //                         child: Image.network(
            //                           btsImages[index],
            //                           fit: BoxFit.cover,
            //                         ),
            //                       );
            //                     },
            //                   )
            //                 : Center(
            //                     child: Text(
            //                       "Belum ada gambar untuk produk ini.",
            //                     ),
            //                   ),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            );
  }
}

class CollapsibleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double maxExtentHeight;
  final double minExtentHeight;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String idVendor;

  CollapsibleHeaderDelegate(
      {required this.maxExtentHeight,
      required this.minExtentHeight,
      required this.imageUrl,
      required this.title,
      required this.subtitle,
      required this.idVendor});

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
    final endH = endW;

    final imageW = lerpDouble(startW, endW, curved)!;
    final imageH = lerpDouble(startH, endH, curved)!;

    final startLeft = (screenW - startW) / 2;
    final endLeft = horizontalPadding;
    final imageLeft = lerpDouble(startLeft, endLeft, curved)!;

    final startTop = 8.0;
    final endTop = (minExtent - imageH) / 2;
    final imageTop = lerpDouble(startTop, endTop, curved)!;

    final titleStartTop = startTop + startH + 12.0;
    final titleEndTop = (minExtent - 20.0) / 2;
    final titleTop = lerpDouble(titleStartTop, titleEndTop, curved)!;

    final titleStartLeft = 24;
    final titleEndLeft = imageLeft + imageW + 12.0;
    final titleLeft = lerpDouble(titleStartLeft, titleEndLeft, curved)!;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: Container()),
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
          Positioned(
            left: titleLeft,
            top: titleTop,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: lerpDouble(20, 16, curved),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                  onTap: () => GoRouter.of(
                    context,
                  ).push('/vendor-detail-page/$idVendor'),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
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
