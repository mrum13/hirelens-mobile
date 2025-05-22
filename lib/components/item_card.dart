import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String thumbnailUrl;
  final String title;
  final String subtitle;
  final String price;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;

  // ignore: use_super_parameters
  const ItemCard({
    Key? key,
    required this.thumbnailUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.isFavorite,
    required this.onFavoritePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container untuk gambar dengan ikon star
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFD1D5DB), // Warna abu-abu seperti di gambar
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  // Placeholder untuk gambar (bisa diganti dengan Image.network jika ada URL)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                  ),
                  // Ikon star di pojok kanan atas
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoritePressed,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color:
                              isFavorite ? Colors.amber : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Container untuk teks
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Contoh penggunaan dalam GridView
class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductGridState createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  List<bool> favorites = [false, false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.person_outline, color: Colors.black),
        title: Text(
          'Hello, User',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Icon(Icons.shopping_bag_outlined, color: Colors.black),
          SizedBox(width: 8),
          Icon(Icons.search, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            List<Map<String, String>> products = [
              {
                'title': 'foto wisuda',
                'subtitle': 'photoshoot graduation with properti',
                'price': '\$9.99',
              },
              {
                'title': 'foto wisuda',
                'subtitle':
                    'malam with the lamp and lens fish eye make your photo cool',
                'price': '\$59.99',
              },
              {
                'title': 'photobox',
                'subtitle': 'With your someone love make a moment',
                'price': '\$59.99',
              },
              {
                'title': 'photobooth',
                'subtitle': 'with your sirkel friend make your moment',
                'price': '\$59.99',
              },
              {
                'title': 'foto studio',
                'subtitle': 'take a moment with your family',
                'price': '\$59.99',
              },
              {
                'title': 'foto prewod',
                'subtitle': 'make your happy moment',
                'price': '\$59.99',
              },
            ];

            return ItemCard(
              thumbnailUrl: '',
              title: products[index]['title']!,
              subtitle: products[index]['subtitle']!,
              price: products[index]['price']!,
              isFavorite: favorites[index],
              onFavoritePressed: () {
                setState(() {
                  favorites[index] = !favorites[index];
                });
              },
            );
          },
        ),
      ),
    );
  }
}
