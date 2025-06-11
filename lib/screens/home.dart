import 'package:flutter/material.dart';
import 'package:unsplash_clone/components/item_card.dart';
import 'package:unsplash_clone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:unsplash_clone/screens/cart.dart';
import 'package:unsplash_clone/screens/profile.dart';
import 'package:unsplash_clone/components/appbar.dart';

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {
      "title": "foto wisuda",
      "desc": "photoshoot graduation with property",
      "price": 1200000,
    },
    {
      "title": "foto wisuda malam",
      "desc": "with the lamp and lens fish eye make your photo cool",
      "price": 1500000,
    },
    {
      "title": "photobox",
      "desc": "With your someone love make a moment",
      "price": 800000,
    },
    {
      "title": "photobooth",
      "desc": "with your sister/friend make your moment",
      "price": 800000,
    },
    {
      "title": "foto studio",
      "desc": "take a moment with your family",
      "price": 750000,
    },
    {
      "title": "foto prewed",
      "desc": "make your happy moment",
      "price": 1200000,
    },
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return const Center(child: Text('Belum login'));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HomeCustomAppBar(
        onCartPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartPage()),
          );
        },
        onProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        },
        onSearchPressed: () {
          // TODO: Implement search action
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Grid konten
            Expanded(
              child: Container(
                color: Colors.white,
                child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ItemCard(
                      name: item['title'],
                      price: item['price'],
                      desc: item['desc'],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
