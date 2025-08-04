import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatCurrency(int price) {
  final formatter = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );
  return formatter.format(price);
}

class ItemCard extends StatelessWidget {
  // TODO: Match the properties with your actual data model
  final String name;
  final String vendor;
  final int price;
  final String description;
  final String? thumbnail;
  final bool? showFavorite;
  final VoidCallback? onTapHandler;

  const ItemCard({
    super.key,
    required this.name,
    required this.vendor,
    required this.price,
    required this.description,
    this.thumbnail,
    this.showFavorite = true,
    required this.onTapHandler,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapHandler,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                if (showFavorite == true)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.star_border, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const Spacer(),
            Text(
              formatCurrency(price),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
