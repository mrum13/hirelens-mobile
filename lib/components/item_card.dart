import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/helper.dart';

class ItemCard extends StatefulWidget {
  final String id;
  final String name;
  final String vendor;
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
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
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
                                color:
                                    Theme.of(context).colorScheme.surfaceBright,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              child: Image.network(
                                widget.thumbnail!,
                                fit: BoxFit.cover,
                                height: 120,
                                width: double.infinity,
                              ),
                            ),
                      if (widget.showFavorite == true)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            size: 24,
                            color: isFavorite ? Colors.amber : Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 8,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4,),
                          widget.isVendor?(widget.isVerified?Icon(Icons.check_circle_outline, color: Colors.green,):Icon(Icons.info_outline,color: Colors.amber,)):const SizedBox(),
                          const Spacer(),
                          Text("Mulai dari", style: TextStyle(fontSize: 8)),
                          Text(
                            formatCurrency(widget.price), // Hilangkan .toInt()
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
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
