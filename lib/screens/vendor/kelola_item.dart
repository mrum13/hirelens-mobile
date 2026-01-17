import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unsplash_clone/components/item_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/screens/vendor/create_item.dart';
import 'package:unsplash_clone/main.dart' show routeObserver;

class KelolaItemPage extends StatefulWidget {
  const KelolaItemPage({super.key});

  @override
  State<KelolaItemPage> createState() => _KelolaItemPageState();
}

class _KelolaItemPageState extends State<KelolaItemPage> with RouteAware {
  List<Map<String, dynamic>> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<String> fetchVendorId() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;

    final response = await client
        .from('vendors')
        .select('id')
        .eq('user_id', userId)
        .single();

    return response['id'] as String;
  }

  Future<void> fetchItems() async {
    setState(() => isLoading = true);
    final client = Supabase.instance.client;

    try {
      final vendorId = await fetchVendorId();
      final response = await client
          .from('items')
          .select('*, vendors(id,name)')
          .eq('vendor_id',
              vendorId) // pastikan kolomnya vendor_id, bukan vendor
          .order('created_at', ascending: false);

      setState(() {
        items = response;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching items: $e');
      setState(() => isLoading = false);
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
  didPopNext() {
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: Text(
          'Kelola Item',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Buat Item Baru'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateItemPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? const Center(child: Text('Belum ada item.'))
                      : GridView.builder(
                          itemCount: items.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ItemCard(
                              id: item['id'],
                              name: item['name'],
                              price: item['price'] is num
                                  ? item['price']
                                  : double.parse(item['price'].toString()),
                              vendor: item[
                                  'vendor_id'], 
                              vendorName: item['vendors']['name'],
                              thumbnail: item['thumbnail'],
                              description: item['description'] ?? '',
                              showFavorite: false,
                              onTapHandler: () => GoRouter.of(context).push(
                                "/vendor/kelola_item/edit/${item['id']}",
                              ),
                              isVendor: true,
                              isVerified: item['is_verified'],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
