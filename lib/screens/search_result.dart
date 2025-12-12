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

  Future<void> loadRelevantResult() async {
    final client = Supabase.instance.client;

    final response = await client
        .from('items')
        .select("*, vendors(id, name)")
        .like('name', "%${widget.keyword}%");

    setState(() {
      results = response;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadRelevantResult();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pencarian"),
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
                    vendor: item[
                        'vendor_id'], // Ganti dari 'vendor' ke 'vendor_id'
                    thumbnail: item['thumbnail'],
                    description: item['description'] ?? '',
                    showFavorite: false,
                    onTapHandler: () => GoRouter.of(context).push("/item/detail/${item['id']}"),
                  );
                },
              ),
          ),
    );
  }
}
