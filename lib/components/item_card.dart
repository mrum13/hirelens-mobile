import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatCurrency(int price) {
  final formatter = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );
  return formatter.format(price);
}

class ItemCard extends StatefulWidget {
  final String name;
  final int vendor;
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
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTapHandler,
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
                widget.thumbnail == null
                    ? Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )
                    : Image.network(
                      widget.thumbnail!,
                      fit: BoxFit.cover,
                      height: 120,
                      width: double.infinity,
                    ),
                if (widget.showFavorite == true)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.star_border, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.name, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              widget.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const Spacer(),
            Text(
              formatCurrency(widget.price),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
