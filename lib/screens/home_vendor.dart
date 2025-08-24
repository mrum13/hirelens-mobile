import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:go_router/go_router.dart';
import 'package:unsplash_clone/components/bottomnav.dart';
import 'package:unsplash_clone/main.dart' show routeObserver;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/theme.dart';

String formatCurrency(int price) {
  final formatter = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );
  return formatter.format(price);
}

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

  Future<int> fetchVendorId() async {
    final client = Supabase.instance.client;
    final response =
        await client
            .from('vendors')
            .select('id')
            .eq('user_id', client.auth.currentUser!.id)
            .single();

    return response['id'] as int;
  }

  Future<void> fetchItemCount() async {
    final client = Supabase.instance.client;
    final vendorId = await fetchVendorId();
    final response = await client.from('items').count().eq('vendor', vendorId);

    setState(() {
      itemCount = response;
    });
  }

  Future<void> fetchAllTransactions() async {
    final client = Supabase.instance.client;
    final vendorId = await fetchVendorId();

    final response = await client
        .from('transactions')
        .select("*, item_id(id, name)")
        .eq('vendor_id', vendorId)
        .order('created_at', ascending: false);

    setState(() {
      transactions = response;
    });
  }

  List<Map<String, dynamic>> filterPendingOrder(
    List<Map<String, dynamic>> orders,
  ) {
    final result =
        orders.where((order) => order['status'] == 'pending').toList();

    return result;
  }

  List<Map<String, dynamic>> filterProcessedOrder(
    List<Map<String, dynamic>> orders,
  ) {
    final result =
        orders.where((order) => order['status'] == 'in_progress').toList();

    return result;
  }

  List<Map<String, dynamic>> filterCompletedOrder(
    List<Map<String, dynamic>> orders,
  ) {
    final result =
        orders.where((order) => order['status'] == 'completed').toList();

    return result;
  }

  List<Map<String, dynamic>> filterLatestOrder(
    List<Map<String, dynamic>> orders,
  ) {
    final result =
        orders.getRange(0, orders.length < 6 ? orders.length : 5).toList();

    return result;
  }

  Future<void> fetchUpcomingTransaction() async {
    final client = Supabase.instance.client;
    final vendorId = await fetchVendorId();

    final response = await client
        .from('transactions')
        .select("*, item_id(id, name)")
        .eq('vendor_id', vendorId)
        .order('created_at')
        .order('tgl_foto')
        .limit(10);

    setState(() {
      upcomingShoots = response;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchItemCount();
    fetchAllTransactions();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void didPopNext() {
    super.didPopNext();
    fetchItemCount();
    fetchAllTransactions();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyBottomNavbar(curIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              isLoading = true;
            });

            await fetchItemCount();
            await fetchAllTransactions();

            setState(() {
              isLoading = false;
            });
          },
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
                      _StatCard(
                        count: itemCount?.toString() ?? '-',
                        icon: Icons.view_module,
                        label: "Total Item",
                      ),
                      _StatCard(
                        count:
                            filterPendingOrder(transactions).length.toString(),
                        icon: Icons.receipt,
                        label: "Order Pending",
                      ),
                      _StatCard(
                        count:
                            filterProcessedOrder(
                              transactions,
                            ).length.toString(),
                        icon: Icons.movie_edit,
                        label: "Order Diproses",
                      ),
                      _StatCard(
                        count:
                            filterCompletedOrder(
                              transactions,
                            ).length.toString(),
                        icon: Icons.check_box,
                        label: "Order Selesai",
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

                // URGENT: Test this and make sure all features running normal
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
                            children:
                                filterLatestOrder(transactions)
                                    .map(
                                      // URGENT: Fill this with actual data from transaction
                                      (transaction) => _RecentOrderItem(
                                        customerName: "Muhammad Chandra Hasan",
                                        itemName: "Photobooth Pra-Wedding",
                                        duration: 2,
                                        paymentType: 'panjar',
                                        amount: 350000,
                                      ),
                                    )
                                    .toList(),
                          )
                          : SizedBox(
                            height: 200,
                            child: Center(child: Text("Belum ada transaksi")),
                          ),
                    ]),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 32)),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        "Jadwal Terdekat",
                        style: themeFromContext(
                          context,
                        ).textTheme.displayMedium!.copyWith(fontSize: 20),
                      ),
                      SizedBox(height: 16),

                      upcomingShoots.isNotEmpty
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children:
                                // [
                                //   _UpcomingTransactionItem(
                                //     customerName: "Muhammad Chandra Hasan",
                                //     itemName: "Photobooth Pra-Wedding",
                                //     duration: 2,
                                //     tglFoto: DateTime(2025, 08, 25, 12, 00),
                                //     waktuFoto: DateTime(2025, 08, 25, 12, 00),
                                //   ),
                                // ],
                                upcomingShoots
                                    .map(
                                      (
                                        upcomingShot,
                                      ) => _UpcomingTransactionItem(
                                        customerName: "Muhammad Chandra Hasan",
                                        itemName: "Photobooth Pra-Wedding",
                                        duration: 2,
                                        tglFoto: DateTime(2025, 08, 25, 12, 00),
                                        waktuFoto: DateTime(
                                          2025,
                                          08,
                                          25,
                                          12,
                                          00,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          )
                          : SizedBox(
                            height: 200,
                            child: Center(child: Text("Belum ada transaksi")),
                          ),
                    ]),
                  ),
                ),

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
            color: themeFromContext(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
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
              // Column(

              // ),
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
              color:
                  paymentType == 'panjar'
                      ? Colors.amberAccent
                      : Colors.lightGreenAccent,
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              paymentType == 'panjar' ? "Panjar" : "Full",
              style: TextStyle(
                fontSize: 12,
                color: themeFromContext(context).colorScheme.onPrimary,
              ),
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
            color: themeFromContext(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
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
                  Text(
                    DateFormat(
                      'EEEE, dd MMM',
                      Locale('in', 'ID').scriptCode,
                    ).format(tglFoto),
                    style: themeFromContext(context).textTheme.displayMedium,
                  ),
                ],
              ),
            ],
          ),
        ),

        Positioned(
          top: 6,
          right: -4,
          child: Container(
            decoration: BoxDecoration(color: Colors.lightGreenAccent),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              DateFormat('HH:mm').format(waktuFoto),
              style: TextStyle(
                fontSize: 14,
                color: themeFromContext(context).colorScheme.onPrimary,
              ),
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
