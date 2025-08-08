import 'package:flutter/material.dart';
import 'package:unsplash_clone/components/item_card.dart';
import 'package:unsplash_clone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:unsplash_clone/screens/cart.dart';
import 'package:unsplash_clone/screens/profile.dart';
import 'package:unsplash_clone/screens/product_detail.dart';
import 'package:unsplash_clone/components/appbar.dart';
import 'package:unsplash_clone/components/search_bar_with_suggestions.dart';
import 'package:unsplash_clone/models/item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ItemModel> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() => isLoading = true);

    final response = (await Supabase.instance.client
        .from('items')
        .select()
        .filter('is_verified', 'neq', false)
        .order('created_at', ascending: false));

    setState(() {
      isLoading = false;
      items =
          (response as List)
              .map((json) => ItemModel.fromJson(json as Map<String, dynamic>))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (user == null) {
      return const Center(child: Text('Belum login'));
    }

    final List<String> suggestionTitles =
        items.map((item) => item.name).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HomeCustomAppBar(
        onCartPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartPage()),
          );
        },
        onProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        },
      ),
      // TODO: Refactor the whole UI
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Search bar with suggestions
              SearchBarWithSuggestions(
                suggestionsData: suggestionTitles,
                onSearch: (query) {
                  // You can implement actual filtering logic here if needed
                  debugPrint('Search: $query');
                },
              ),
              const SizedBox(height: 16),
              // Grid konten
              Expanded(
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : items.isEmpty
                        ? Container(
                          color: Colors.white,
                          child: RefreshIndicator(
                            onRefresh: fetchItems,
                            child: Center(child: Text('Belum ada item.')),
                          ),
                        )
                        : Container(
                          color: Colors.white,
                          child: RefreshIndicator(
                            onRefresh: fetchItems,
                            child: GridView.builder(
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: items.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 0.65,
                                  ),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return ItemCard(
                                  id: item.id,
                                  name: item.name,
                                  vendor: item.vendor,
                                  price: item.price,
                                  thumbnail: item.thumbnail,
                                  description: item.description ?? '',
                                  onTapHandler:
                                      () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ProductDetailPage(
                                                dataId: item.id,
                                              ),
                                        ),
                                      ),
                                );
                              },
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
