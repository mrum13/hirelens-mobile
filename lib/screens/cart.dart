import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        .select('id, item_id(id,name,,description,thumbnail,address,price)');

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
          child: GridView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: items.length,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisSpacing: 12,
              childAspectRatio: 3,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return CartItem(
                itemAddress: item['item_id']['address'],
                itemId: item['item_id']['id'],
                itemName: item['item_id']['name'],
                itemPrice: item['item_id']['price'],
                itemThumbnail: item['item_id']['thumbnail'],
              );
            },
          ),
        ),
      ),
    );
  }
}

class CartItem extends StatefulWidget {
  final int itemId;
  final String itemName;
  final String itemThumbnail;
  final int itemPrice;
  final String itemAddress;

  const CartItem({
    super.key,
    required this.itemId,
    required this.itemName,
    required this.itemThumbnail,
    required this.itemPrice,
    required this.itemAddress,
  });

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: Row(
        children: [ClipRRect(child: Image.network(widget.itemThumbnail))],
      ),
    );
  }
}
