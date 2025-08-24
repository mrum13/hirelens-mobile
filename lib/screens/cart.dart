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
    final client = Supabase.instance.client;
    final results = await client
        .from('shopping_cart')
        .select(
          'id, item_id(id,name,description,thumbnail,address,price,vendor(id,name))',
        );

    setState(() {
      isLoading = false;
      items = results;
    });
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
          child:
              !isLoading
                  ? ListView(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    children:
                        items
                            .map(
                              ((item) => _CartItem(
                                itemAddress: item['item_id']['address'],
                                itemId: item['item_id']['id'],
                                itemName: item['item_id']['name'],
                                itemVendor: item['item_id']['vendor']['name'],
                                itemPrice: item['item_id']['price'],
                                itemThumbnail: item['item_id']['thumbnail'],
                              )),
                            )
                            .toList(),
                  )
                  : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _CartItem extends StatefulWidget {
  final int itemId;
  final String itemName;
  final String itemVendor;
  final String itemThumbnail;
  final int itemPrice;
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
                ),
                Text(widget.itemVendor, style: TextStyle(fontSize: 12)),
                Expanded(child: SizedBox(height: double.infinity)),
                Row(
                  spacing: 4,
                  children: [
                    Icon(Icons.location_on, size: 12),
                    Text(
                      widget.itemAddress.length > 16
                          ? "${widget.itemAddress.substring(0, 16)}..."
                          : widget.itemAddress,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // GestureDetector(
          //   onTap:
          //       () =>
          //           GoRouter.of(context).push("/item/detail/${widget.itemId}"),
          //   child: Container(
          //     width: 100,
          //     height: 32,
          //     alignment: Alignment.center,
          //     decoration: BoxDecoration(
          //       color: Theme.of(context).colorScheme.primary,
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Text(
          //       "Detail Item",
          //       style: TextStyle(
          //         color: Theme.of(context).colorScheme.onPrimary,
          //       ),
          //     ),
          //   ),
          // ),
          MyFilledButton(
            width: 100,
            height: 32,
            variant: MyButtonVariant.primary,
            padding: EdgeInsets.all(4),
            onTap:
                () =>
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
