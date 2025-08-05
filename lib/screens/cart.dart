import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class CartItemModel {
  final int id;
  final DateTime createdAt;
  final int item_id;
  final int user_id;

  CartItemModel({
    required this.id,
    required this.createdAt,
    required this.item_id,
    required this.user_id,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json['id'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
    item_id: json['item_id'] as int,
    user_id: json['user_id'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'item_id': item_id,
    'user_id': user_id,
  };
}

class _CartPageState extends State<CartPage> {
  List<CartItemModel> items = [];
  bool isLoading = true;

  void fetchDatas() async {
    final client = Supabase.instance.client;
    final results = await client.from('shopping_cart').select();

    setState(() {
      isLoading = false;
      items =
          (results as List)
              .map(
                (json) => CartItemModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
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
      body: Center(
        child: Text(
          'Ini halaman keranjang belanja',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
