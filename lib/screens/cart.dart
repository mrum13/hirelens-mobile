import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;

  Future<void> fetchDatas() async {
    try {
      final client = Supabase.instance.client;
      final results = await client.from('shopping_cart').select(
            'id, items!inner(id,name,description,thumbnail,address,price,vendors!inner(id,name))',
          );

      setState(() {
        isLoading = false;
        items = results;
      });
    } catch (e) {
      print('Error fetching cart: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat keranjang: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDatas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Keranjang Belanja')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchDatas,
          child: !isLoading
              ? items.isNotEmpty
                  ? ListView(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      children: items
                          .map(
                            ((item) => _CartItem(
                                  itemAddress:
                                      item['items']['address']?.toString() ??
                                          '',
                                  itemId: item['items']['id']?.toString() ?? '',
                                  itemName:
                                      item['items']['name']?.toString() ?? '',
                                  itemVendor: item['items']['vendors']['name']
                                          ?.toString() ??
                                      '',
                                  itemPrice: item['items']['price'] ?? 0,
                                  itemThumbnail:
                                      item['items']['thumbnail']?.toString() ??
                                          '',
                                )),
                          )
                          .toList(),
                    )
                  : Center(child: Text("Belum ada item"))
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _CartItem extends StatefulWidget {
  final String itemId;
  final String itemName;
  final String itemVendor;
  final String itemThumbnail;
  final dynamic itemPrice;
  final String itemAddress;

  const _CartItem({
    required this.itemId,
    required this.itemName,
    required this.itemVendor,
    required this.itemThumbnail,
    required this.itemPrice,
    required this.itemAddress,
  });

  @override
  State<_CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<_CartItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      height: 80,
      child: Row(
        spacing: 8,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.itemThumbnail,
              fit: BoxFit.cover,
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image),
                );
              },
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.itemName,
                  style: Theme.of(context).textTheme.displaySmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.itemVendor,
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Expanded(child: SizedBox(height: double.infinity)),
                Row(
                  spacing: 4,
                  children: [
                    Icon(Icons.location_on, size: 12),
                    Expanded(
                      child: Text(
                        widget.itemAddress.length > 16
                            ? "${widget.itemAddress.substring(0, 16)}..."
                            : widget.itemAddress,
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          MyFilledButton(
            width: 100,
            height: 32,
            variant: MyButtonVariant.primary,
            padding: EdgeInsets.all(4),
            onTap: () =>
                GoRouter.of(context).push("/item/detail/${widget.itemId}"),
            child: Row(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.info, size: 14),
                Text(
                  "Detail Item",
                  style: TextStyle(
                    color: themeFromContext(context).colorScheme.onPrimary,
                    fontSize: 12,
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