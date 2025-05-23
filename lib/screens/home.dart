import 'package:flutter/material.dart';
import 'package:unsplash_clone/components/item_card.dart';
import 'package:unsplash_clone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:unsplash_clone/models/user_model.dart';
import 'package:unsplash_clone/screens/cart.dart'; // Pastikan path ini sesuai struktur project kamu

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0, // Sembunyikan AppBar asli
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Baris 1: Icon profil
            Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.person, size: 30, color: Colors.black),
            ),
            const SizedBox(height: 12),

            // Baris 2: Hello User + Icon keranjang + search
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hello, ${user.displayName ?? user.email}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_bag_outlined),
                      onPressed: () {
                        // Navigasi ke halaman keranjang
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        );
                      },
                      color: Colors.black,
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {},
                      color: Colors.black,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Grid konten
            Expanded(
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
          ],
        ),
      ),
    );
  }
}