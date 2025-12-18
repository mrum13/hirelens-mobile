import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/components/item_card.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key, required this.keyword});

  final String keyword;

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

// URGENT: Test this page
class _SearchResultPageState extends State<SearchResultPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> results = [];
  String titleSearch = "-";

  Future<void> loadRelevantResult(String category) async {
    final client = Supabase.instance.client;
    final keyword = widget.keyword.trim();

    setState(() => isLoading = true);

    try {
      final query = client
          .from('items')
          .select('*, vendors(id, name)')
          .eq('is_verified', true);

      final List<Map<String, dynamic>> response = category == "product"
          ? (await query.ilike('name', '%$keyword%'))
              .map((e) => e as Map<String, dynamic>)
              .toList()
          : (await query.ilike('vendors.name', '%$keyword%'))
              .map((e) => e as Map<String, dynamic>)
              .toList();

      final resultsUnique =
          {for (var item in response) item['id']: item}.values.toList();

      setState(() {
        titleSearch = category=="product"?"Pencarian Produk":"Pencarian Vendor";
        results = resultsUnique;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showCustomMenu(
    BuildContext context,
    Offset offset,
  ) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final selectedValue = await showMenu<String>(
      context: context,
      // Position the menu relative to the global position of the tap
      position: RelativeRect.fromRect(
        Rect.fromPoints(offset, offset),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<String>(value: 'option1', child: Text('Produk')),
        PopupMenuItem(
          value: 'option2',
          child: Text('Vendor'),
        ),
      ],
      elevation: 8.0,
    );

    // Handle the selection
    if (selectedValue == "option1") {
      loadRelevantResult("product");
    } else if (selectedValue == "option2") {
      loadRelevantResult("vendor");
    }
  }

  @override
  void initState() {
    super.initState();
    loadRelevantResult("product");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleSearch),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                onTapDown: (details) {
                  _showCustomMenu(
                    context,
                    details.globalPosition,
                  );
                },
                child: Icon(Icons.more_vert)),
          )
        ],
      ),
      body: results.isEmpty
          ? const Center(child: Text('Belum ada item.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: results.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final item = results[index];
                  return ItemCard(
                    id: item['id'],
                    name: item['name'],
                    price: item['price'] is num
                        ? item['price']
                        : double.parse(item['price'].toString()),
                    vendor:
                        item['vendor_id'], // Ganti dari 'vendor' ke 'vendor_id'
                    thumbnail: item['thumbnail'],
                    description: item['description'] ?? '',
                    showFavorite: false,
                    onTapHandler: () =>
                        GoRouter.of(context).push("/item/detail/${item['id']}"),
                  );
                },
              ),
            ),
    );
  }
}
