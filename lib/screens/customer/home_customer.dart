import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unsplash_clone/components/bottomnav.dart';
import 'package:unsplash_clone/components/item_card.dart';
import 'package:unsplash_clone/main.dart' show routeObserver;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/theme.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> with RouteAware {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;
  int itemCartCount = 0;

  @override
  void initState() {
    super.initState();
    countCartItems();
    fetchItems();
  }

  User fetchUserData() {
    final client = Supabase.instance.client;
    return client.auth.currentUser!;
  }

  Future<void> fetchItems() async {
    setState(() => isLoading = true);

    final response = await Supabase.instance.client
        .from('items')
        .select('*,vendors(id, name)')
        .filter('is_verified', 'neq', false)
        .order('created_at', ascending: false);

    setState(() {
      isLoading = false;
      items = response;
    });
  }

  void countCartItems() async {
    final client = Supabase.instance.client;
    final response = await client
        .from('shopping_cart')
        .count()
        .eq('user_id', client.auth.currentUser!.id);

    itemCartCount = response;
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
    countCartItems();
    // fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyBottomNavbar(curIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchItems,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: themeFromContext(context).colorScheme.surface,
                expandedHeight: 240,
                surfaceTintColor: Colors.transparent,
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        itemCartCount > 0
                            ? Badge.count(
                                offset: Offset(-6, 8),
                                count: itemCartCount,
                                child: IconButton(
                                  icon: Icon(Icons.shopping_bag_outlined),
                                  onPressed: () =>
                                      GoRouter.of(context).push('/cart'),
                                ),
                              )
                            : IconButton(
                                icon: Icon(Icons.shopping_bag_outlined),
                                onPressed: () =>
                                    GoRouter.of(context).push('/cart'),
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
                          ((fetchUserData().userMetadata?['displayName']
                                      as String?) ??
                                  'Pengguna')
                              .split(" ")[0],
                          style:
                              themeFromContext(context).textTheme.displayLarge,
                        ),
                        Text("Temukan jasa foto terbaik hari ini 📸")
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
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.search),
                      ),
                      hintText: "Search...",
                      onSubmitted: (value) => GoRouter.of(
                        context,
                      ).push("/search?keyword=${value.trim()}"),
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
                MediaQuery.of(context).size.width < 720
                    ? SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final item = items[index];
                            return ItemCard(
                              id: item['id'],
                              name: item['name'] ?? 'Unnamed Item',
                              vendor: item['vendor_id'] ?? '',
                              vendorName: item['vendors']['name'],
                              price: item['price'] ?? 0,
                              thumbnail: item['thumbnail'],
                              description: item['description'] ?? '',
                              onTapHandler: () => GoRouter.of(
                                context,
                              ).push("/item/detail/${item['id']}"),
                            );
                          }, childCount: items.length),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.69,
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            final item = items[index];
                            return ItemCard(
                              id: item['id'],
                              name: item['name'],
                              vendor: item['vendor'],
                              vendorName: item['vendors']['name'],
                              price: item['price'],
                              thumbnail: item['thumbnail'],
                              description: item['description'] ?? '',
                              onTapHandler: () => GoRouter.of(
                                context,
                              ).push("/item/detail/${item['id']}"),
                            );
                          }, childCount: items.length),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                        ),
                      ),
              SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
