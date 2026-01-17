import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/helper.dart';

class ItemCard extends StatefulWidget {
  final String id;
  final String name;
  final String vendor;
  final String vendorName;
  final num price;
  final String description;
  final String? thumbnail;
  final bool? showFavorite;
  final VoidCallback? onTapHandler;
  final bool isVendor;
  final bool isVerified;

  const ItemCard({
    super.key,
    required this.id,
    required this.name,
    required this.vendor,
    required this.vendorName,
    required this.price,
    required this.description,
    this.thumbnail,
    this.showFavorite = true,
    this.isVendor = false,
    this.isVerified = false,
    required this.onTapHandler,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool isLoading = false;
  late bool isFavorite;

  void checkIsFavorite() async {
    final client = Supabase.instance.client;

    final response = await client
        .from('shopping_cart')
        .select()
        .eq('user_id', client.auth.currentUser!.id)
        .eq('item_id', widget.id)
        .maybeSingle();

    setState(() {
      isFavorite = response != null;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    isFavorite = false;

    // checkIsFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? GestureDetector(
            onTap: widget.onTapHandler,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.onPrimaryFixedVariant),
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: widget.thumbnail != null
                          ? Image.network(
                              widget.thumbnail!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            // OUTLINE
                            Text(
                              widget.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 1.2
                                  ..color = Colors.black,
                              ),
                            ),
                            // FILL
                            Text(
                              widget.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          widget.vendorName,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, fontSize: 10),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatCurrency(
                                  widget.price), // Hilangkan .toInt()
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            widget.isVendor
                                ? (widget.isVerified
                                    ? Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.green,
                                      )
                                    : Icon(
                                        Icons.info_outline,
                                        color: Colors.amber,
                                      ))
                                : Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: Text(
                                      "Order",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.black87),
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceBright,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              widthFactor: double.infinity,
              heightFactor: double.infinity,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
  }
}
