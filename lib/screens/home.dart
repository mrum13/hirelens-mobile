import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unsplash_clone/components/item_card.dart';
import 'package:unsplash_clone/main.dart' show routeObserver;
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

  User fetchUserData() {
    final client = Supabase.instance.client;
    return client.auth.currentUser!;
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

  String getTimedMessage() {
    final curTime = DateTime.now();

    if (curTime.hour >= 2 && curTime.hour <= 9) {
      return "Selamat Pagi";
    } else if (curTime.hour >= 10 && curTime.hour <= 14) {
      return "Selamat Siang";
    } else if (curTime.hour >= 15 && curTime.hour <= 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
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
    // URGENT: Recreate the suggestion box functionality
    // final List<String> suggestionTitles =
    //     items.map((item) => item['name'] as String).toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchItems,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                elevation: 0,
                backgroundColor: themeFromContext(context).colorScheme.surface,
                expandedHeight: 240,
                surfaceTintColor: Colors.transparent,
                // leadingWidth: double.infinity,
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => GoRouter.of(context).push('/profile'),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                              'https://ui-avatars.com/api/?background=6777cc&color=fff&name=${fetchUserData().userMetadata!['displayName'].toUpperCase()}',
                              scale: 1,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.shopping_bag_outlined),
                          onPressed: () => GoRouter.of(context).push('/cart'),
                        ),
                      ],
                    ),
                  ],
                ),

                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${getTimedMessage()},",
                          style: themeFromContext(context).textTheme.bodyMedium,
                        ),
                        Text(
                          (fetchUserData().userMetadata!['displayName']!
                                  as String)
                              .split(" ")[0],
                          style:
                              themeFromContext(context).textTheme.displayLarge,
                        ),
                      ],
                    ),
                  ),
                ),

                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SearchBar(
                      leading: Icon(Icons.search),
                      hintText: "Search...",
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 16)),

              if (isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('Belum ada item.')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
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
                    }, childCount: items.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.65,
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
