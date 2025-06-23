import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatCurrency(int price) {
  final formatter = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );
  return formatter.format(price);
}

// TODO: Add a onClick listener to navigate to product_detail.dart and carry the item id
class ItemCard extends StatelessWidget {
  // TODO: Match the properties with your actual data model
  final String name;
  final int price;
  final String desc;
  final String? thumbnail;
  final bool? showFavorite;

  const ItemCard({
    super.key,
    required this.name,
    required this.price,
    required this.desc,
    this.thumbnail,
    this.showFavorite = true,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          const Spacer(),
          Text(
            formatCurrency(price),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
