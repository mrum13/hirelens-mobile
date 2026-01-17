import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:unsplash_clone/components/bottomnav.dart';
import 'package:unsplash_clone/helper.dart';
import 'package:unsplash_clone/main.dart' show routeObserver;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/theme.dart';

class VendorHomePage extends StatefulWidget {
  const VendorHomePage({super.key});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> with RouteAware {
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> upcomingShoots = [];
  bool isLoading = true;
  int? itemCount;

  User fetchUserData() {
    final client = Supabase.instance.client;
    return client.auth.currentUser!;
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
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<String?> fetchVendorId() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      debugPrint("❌ User not logged in");
      return null;
    }

    try {
      final response = await client
          .from('vendors')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) {
        debugPrint("⚠️ Tidak ada vendor untuk user ini");
        return null;
      }

      debugPrint("✅ Vendor ID found: ${response['id']}");
      return response['id'] as String;
    } catch (e) {
      debugPrint("❌ Error fetching vendor ID: $e");
      return null;
    }
  }

  Future<void> fetchItemCount() async {
    final client = Supabase.instance.client;

    try {
      final vendorId = await fetchVendorId();
      debugPrint("🔍 Fetching item count for vendor ID: $vendorId");

      if (vendorId == null) {
        debugPrint("⚠️ VendorId null, set item count to 0");
        if (mounted) {
          setState(() {
            itemCount = 0;
          });
        }
        return;
      }

      // ✅ FIX: Gunakan 'vendor_id' sesuai database aktual
      final response =
          await client.from('items').select('id').eq('vendor_id', vendorId);

      final int count = response.length;

      debugPrint("✅ Item count fetched: $count");

      if (mounted) {
        setState(() {
          itemCount = count;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching item count: $e");
      if (mounted) {
        setState(() {
          itemCount = 0;
        });
      }
    }
  }

  Future<void> fetchAllTransactions() async {
    final client = Supabase.instance.client;

    try {
      final vendorId = await fetchVendorId();
      debugPrint("🔍 Fetching transactions for vendor ID: $vendorId");

      if (vendorId == null) {
        debugPrint("⚠️ VendorId null, skip fetch transactions");
        if (mounted) {
          setState(() {
            transactions = [];
          });
        }
        return;
      }

      // ✅ FIX: Query tanpa JOIN karena tidak ada FK antara transactions->items
      // Kita ambil item_id sebagai UUID saja, lalu ambil nama item terpisah jika perlu
      final response = await client
          .from('transactions')
          .select("*")
          .eq('vendor_id', vendorId)
          .order('created_at', ascending: false);

      // Ambil item details secara terpisah jika diperlukan
      List<Map<String, dynamic>> enrichedTransactions = [];

      for (var transaction in response) {
        final itemId = transaction['item_id'];

        if (itemId != null) {
          try {
            final itemData = await client
                .from('items')
                .select('id, name, thumbnail')
                .eq('id', itemId)
                .maybeSingle();

            transaction['item_data'] = itemData;
          } catch (e) {
            debugPrint("⚠️ Failed to fetch item $itemId: $e");
            transaction['item_data'] = null;
          }
        }

        enrichedTransactions.add(transaction);
      }

      debugPrint(
          "✅ Transactions fetched: ${enrichedTransactions.length} items");

      if (mounted) {
        setState(() {
          transactions = enrichedTransactions;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching transactions: $e");
      if (mounted) {
        setState(() {
          transactions = [];
        });
      }
    }
  }

  List<Map<String, dynamic>> filterPendingOrder(
    List<Map<String, dynamic>> orders,
  ) {
    // final result = orders
    //     .where(
    //       (order) =>
    //           ['panjar_paid', 'complete'].contains(order['status_payment']),
    //     )
    //     .toList();

    final result = orders
        .where(
          (order) =>
            ['panjar_paid', 'complete'].contains(order['status_payment']) 
            &&
            ['pending'].contains(order['status_work']),
        )
        .toList();

    return result;
  }

  List<Map<String, dynamic>> filterProcessedOrder(
    List<Map<String, dynamic>> orders,
  ) {
    final result = orders
        .where((order) => ['waiting', 'editing', 'post_processing', 'complete']
            .contains(order['status_work']))
        .toList();

    return result;
  }

  List<Map<String, dynamic>> filterCompletedOrder(
    List<Map<String, dynamic>> orders,
  ) {
    final result =
        orders.where((order) => ['finish','cancel'].contains(order['status_work']) ).toList();

    return result;
  }

  List<Map<String, dynamic>> filterLatestOrder(
    List<Map<String, dynamic>> orders,
  ) {
    final tmp = orders
        .where(
          (order) =>
              ['panjar_paid', 'complete'].contains(order['status_payment']),
        )
        .toList();
    final result = tmp.getRange(0, tmp.length < 6 ? tmp.length : 5).toList();

    return result;
  }

  Future<void> fetchUpcomingTransaction() async {
    final client = Supabase.instance.client;

    try {
      final vendorId = await fetchVendorId();
      debugPrint("🔍 Fetching upcoming shoots for vendor ID: $vendorId");

      if (vendorId == null) {
        debugPrint("⚠️ VendorId null, skip fetch upcoming shoots");
        if (mounted) {
          setState(() {
            upcomingShoots = [];
          });
        }
        return;
      }

      // ✅ FIX: Query tanpa JOIN
      final response = await client
          .from('transactions')
          .select("*")
          .eq('vendor_id', vendorId)
          .or('status_payment.eq.panjar_paid,status_payment.eq.complete')
          .not('tgl_foto', 'is', null)
          .gte('tgl_foto', DateTime.now().toIso8601String())
          .order('tgl_foto', ascending: true)
          .limit(10);

      // Enrich dengan item data
      List<Map<String, dynamic>> enrichedShoots = [];

      for (var shoot in response) {
        final itemId = shoot['item_id'];

        if (itemId != null) {
          try {
            final itemData = await client
                .from('items')
                .select('id, name, thumbnail')
                .eq('id', itemId)
                .maybeSingle();

            shoot['item_data'] = itemData;
          } catch (e) {
            debugPrint("⚠️ Failed to fetch item $itemId: $e");
            shoot['item_data'] = null;
          }
        }

        enrichedShoots.add(shoot);
      }

      debugPrint("✅ Upcoming shoots fetched: ${enrichedShoots.length} items");

      if (mounted) {
        setState(() {
          upcomingShoots = enrichedShoots;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching upcoming shoots: $e");
      if (mounted) {
        setState(() {
          upcomingShoots = [];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final vendorId = await fetchVendorId();

    if (vendorId == null && mounted) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    await fetchItemCount();
    await fetchAllTransactions();
    await fetchUpcomingTransaction();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyBottomNavbar(curIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                elevation: 0,
                backgroundColor: themeFromContext(context).colorScheme.surface,
                expandedHeight: 160,
                surfaceTintColor: Colors.transparent,
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
                          (fetchUserData().userMetadata?['displayName'] ??
                                  'User')
                              .toString()
                              .split(" ")[0],
                          style:
                              themeFromContext(context).textTheme.displayLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    delegate: SliverChildListDelegate([
                      GestureDetector(
                        onTap: () => GoRouter.of(
                          context,
                        ).push('/vendor/kelola_item'),
                        child: _StatCard(
                          count: itemCount?.toString() ?? '-',
                          icon: Icons.view_module,
                          label: "Total Item",
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            GoRouter.of(context).push('/vendor/pesanan?filter=pending'),
                        child: _StatCard(
                          count: filterPendingOrder(
                            transactions,
                          ).length.toString(),
                          icon: Icons.receipt,
                          label: "Order Pending",
                        ),
                      ),
                      GestureDetector(
                        onTap: () => GoRouter.of(
                          context,
                        ).push('/vendor/pesanan?filter=processing'),
                        child: _StatCard(
                          count: filterProcessedOrder(
                            transactions,
                          ).length.toString(),
                          icon: Icons.movie_edit,
                          label: "Order Diproses",
                        ),
                      ),
                      GestureDetector(
                        onTap: () => GoRouter.of(
                          context,
                        ).push('/vendor/pesanan?filter=finish'),
                        child: _StatCard(
                          count: filterCompletedOrder(
                            transactions,
                          ).length.toString(),
                          icon: Icons.check_box,
                          label: "Order Selesai",
                        ),
                      ),
                    ]),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.15,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 32)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        "Order Terbaru",
                        style: themeFromContext(
                          context,
                        ).textTheme.displayMedium!.copyWith(fontSize: 20),
                      ),
                      SizedBox(height: 16),
                      transactions.isNotEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: filterLatestOrder(transactions)
                                  .map(
                                    (transaction) => _RecentOrderItem(
                                      customerName:
                                          transaction['user_displayName'] ??
                                              'Customer',
                                      itemName: transaction['item_data']
                                              ?['name'] ??
                                          'Item',
                                      duration: transaction['durasi'] != null
                                          ? int.tryParse(transaction['durasi']
                                                  .toString()) ??
                                              0
                                          : 0,
                                      paymentType:
                                          transaction['payment_type'] ??
                                              'panjar',
                                      amount: transaction['amount'] != null
                                          ? double.tryParse(
                                                  transaction['amount']
                                                      .toString()) ??
                                              0.0
                                          : 0.0,
                                    ),
                                  )
                                  .toList(),
                            )
                          : SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.receipt_long,
                                        size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text("Belum ada transaksi"),
                                  ],
                                ),
                              ),
                            ),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 32)),
                // SliverPadding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   sliver: SliverList(
                //     delegate: SliverChildListDelegate([
                //       Text(
                //         "Jadwal Terdekat",
                //         style: themeFromContext(
                //           context,
                //         ).textTheme.displayMedium!.copyWith(fontSize: 20),
                //       ),
                //       SizedBox(height: 16),
                //       upcomingShoots.isNotEmpty
                //           ? Column(
                //               mainAxisAlignment: MainAxisAlignment.start,
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               spacing: 8,
                //               children: upcomingShoots
                //                   .map(
                //                     (upcomingShot) => _UpcomingTransactionItem(
                //                       customerName:
                //                           upcomingShot['user_displayName'] ??
                //                               'Customer',
                //                       itemName: upcomingShot['item_data']
                //                               ?['name'] ??
                //                           'Item',
                //                       duration: upcomingShot['durasi'] != null
                //                           ? int.tryParse(upcomingShot['durasi']
                //                                   .toString()) ??
                //                               0
                //                           : 0,
                //                       tglFoto: upcomingShot['tgl_foto'] != null
                //                           ? DateTime.tryParse(
                //                                   upcomingShot['tgl_foto']) ??
                //                               DateTime.now()
                //                           : DateTime.now(),
                //                       waktuFoto: upcomingShot['tgl_foto'] !=
                //                                   null &&
                //                               upcomingShot['waktu_foto'] != null
                //                           ? DateTime.tryParse(
                //                                   "${upcomingShot['tgl_foto']} ${upcomingShot['waktu_foto']}") ??
                //                               DateTime.now()
                //                           : DateTime.now(),
                //                     ),
                //                   )
                //                   .toList(),
                //             )
                //           : SizedBox(
                //               height: 200,
                //               child: Center(
                //                 child: Column(
                //                   mainAxisAlignment: MainAxisAlignment.center,
                //                   children: [
                //                     Icon(Icons.calendar_today,
                //                         size: 48, color: Colors.grey),
                //                     SizedBox(height: 8),
                //                     Text("Belum ada jadwal"),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //     ]),
                //   ),
                // ),
                SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentOrderItem extends StatelessWidget {
  const _RecentOrderItem({
    required this.customerName,
    required this.itemName,
    required this.duration,
    required this.paymentType,
    required this.amount,
  });

  final String customerName;
  final String itemName;
  final int duration;
  final String paymentType;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: themeFromContext(context).colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName.length > 24
                          ? "${customerName.substring(0, 24)}..."
                          : customerName,
                      style: themeFromContext(context).textTheme.bodyMedium,
                    ),
                    Spacer(),
                    Opacity(
                      opacity: 0.65,
                      child: Text(
                        "${itemName.length > 20 ? "${itemName.substring(0, 20)}..." : itemName} | $duration jam",
                        style: themeFromContext(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text(
                formatCurrency(amount.round()),
                style: themeFromContext(context).textTheme.displayMedium,
              ),
            ],
          ),
        ),
        Positioned(
          top: 6,
          right: -4,
          child: Container(
            decoration: BoxDecoration(
              color: paymentType == 'panjar' ? Colors.orange : Colors.green,
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              paymentType == 'panjar' ? "Panjar" : "Full",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}

class _UpcomingTransactionItem extends StatelessWidget {
  const _UpcomingTransactionItem({
    required this.customerName,
    required this.itemName,
    required this.duration,
    required this.tglFoto,
    required this.waktuFoto,
  });

  final String customerName;
  final String itemName;
  final int duration;
  final DateTime tglFoto;
  final DateTime waktuFoto;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: themeFromContext(context).colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName.length > 24
                          ? "${customerName.substring(0, 24)}..."
                          : customerName,
                      style: themeFromContext(context).textTheme.bodyMedium,
                    ),
                    Spacer(),
                    Opacity(
                      opacity: 0.65,
                      child: Text(
                        "${itemName.length > 14 ? "${itemName.substring(0, 14)}..." : itemName} | $duration jam",
                        style: themeFromContext(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text(
                DateFormat(
                  'EEEE, dd MMM',
                  Locale('id', 'ID').scriptCode,
                ).format(tglFoto),
                style: themeFromContext(context).textTheme.displayMedium,
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
        Positioned(
          top: 6,
          right: -4,
          child: Container(
            decoration: BoxDecoration(
              color: themeFromContext(context).colorScheme.primaryContainer,
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 4,
              children: [
                Icon(
                  Icons.alarm,
                  size: 14,
                  color:
                      themeFromContext(context).colorScheme.onPrimaryContainer,
                ),
                Text(
                  DateFormat('HH:mm').format(waktuFoto),
                  style: TextStyle(
                    fontSize: 14,
                    color: themeFromContext(
                      context,
                    ).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: themeFromContext(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                count.toString(),
                style: themeFromContext(context).textTheme.displayLarge,
              ),
              Text(
                label,
                style: themeFromContext(context).textTheme.displayMedium,
              ),
            ],
          ),
          Positioned(
            right: -8,
            top: -20,
            child: Opacity(opacity: 0.075, child: Icon(icon, size: 80)),
          ),
        ],
      ),
    );
  }
}
