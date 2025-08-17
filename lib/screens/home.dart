import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unsplash_clone/components/item_card.dart';
import 'package:unsplash_clone/main.dart' show routeObserver;
// import 'package:unsplash_clone/screens/cart.dart';
// import 'package:unsplash_clone/screens/profile.dart';
// import 'package:unsplash_clone/components/appbar.dart';
import 'package:unsplash_clone/components/search_bar_with_suggestions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  List<Map<String, dynamic>> items = [];
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
      items = response;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> suggestionTitles =
        items.map((item) => item['name'] as String).toList();

    return Scaffold(
      // URGENT: Re-create the custom appbar
      // URGENT: Re-create the search bar with suggestion that can fit as leading
      appBar: AppBar(
        leadingWidth: 120,
        leading: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: themeFromContext(context).colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.search),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintText: "Search...",
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              GoRouter.of(context).push('/cart');
            },
            icon: Icon(Icons.shopping_bag_outlined),
          ),
          IconButton(
            onPressed: () {
              GoRouter.of(context).push('/profile');
            },
            icon: Icon(Icons.person_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 16),

              // SearchBarWithSuggestions(
              //   suggestionsData: suggestionTitles,
              //   onSearch: (query) {
              //     debugPrint('Search: $query');
              //   },
              // ),
              const SizedBox(height: 16),
              // Grid konten
              Expanded(
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : items.isEmpty
                        ? Container(
                          child: RefreshIndicator(
                            onRefresh: fetchItems,
                            child: Center(child: Text('Belum ada item.')),
                          ),
                        )
                        : Container(
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
                                  id: item['id'],
                                  name: item['name'],
                                  vendor: item['vendor'],
                                  price: item['price'],
                                  thumbnail: item['thumbnail'],
                                  description: item['description'] ?? '',
                                  onTapHandler:
                                      () => GoRouter.of(
                                        context,
                                      ).push("/item/detail/${item['id']}"),
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
