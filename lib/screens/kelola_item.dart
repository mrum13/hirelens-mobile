import 'package:flutter/material.dart';
import 'package:unsplash_clone/components/item_card.dart';

class KelolaItemPage extends StatelessWidget {
  // TODO: Remove this and implement the actual data fetching logic
  final List<Map<String, dynamic>> items = const [
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

  const KelolaItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Kelola Item',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Buat Item Baru'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 41, 41, 41),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  // TODO: Implement create item action
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur buat item baru akan segera hadir.'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
                    showFavorite: false,
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
