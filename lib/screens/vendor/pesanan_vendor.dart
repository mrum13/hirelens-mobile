// ignore_for_file: must_be_immutable

import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:unsplash_clone/helper.dart';
import 'package:unsplash_clone/theme.dart';

class PesananVendorPage extends StatefulWidget {
  PesananVendorPage({super.key, this.filter});

  String? filter;

  @override
  State<PesananVendorPage> createState() => _PesananVendorPageState();
}

class _PesananVendorPageState extends State<PesananVendorPage> with RouteAware {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String? errorMessage;

  Future<String?> fetchVendorId() async {
    final client = Supabase.instance.client;

    try {
      final userId = client.auth.currentUser?.id;

      debugPrint("🔍 Current User ID: $userId");

      if (userId == null) {
        debugPrint("❌ User tidak terautentikasi");
        return null;
      }

      var response = await client
          .from('vendors')
          .select('id, user_id, name')
          .eq('user_id', userId)
          .maybeSingle();

      debugPrint("✅ Vendor response: $response");

      if (response == null) {
        debugPrint("⚠️ Vendor tidak ditemukan, membuat vendor baru...");

        final userEmail = client.auth.currentUser?.email;
        final displayName =
            client.auth.currentUser?.userMetadata?['display_name'] ??
                client.auth.currentUser?.userMetadata?['full_name'] ??
                userEmail?.split('@')[0] ??
                'Vendor';

        try {
          response = await client
              .from('vendors')
              .insert({
                'user_id': userId,
                'name': displayName,
                'email': userEmail,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select('id, name')
              .single();

          debugPrint("✅ Vendor baru berhasil dibuat: ${response['id']}");

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text("Akun vendor '${response['name']}' berhasil dibuat!"),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (insertError) {
          debugPrint("❌ Gagal membuat vendor: $insertError");
          return null;
        }
      }

      return response['id'] as String;
    } catch (e, stackTrace) {
      debugPrint("❌ Error fetching vendor ID: $e");
      debugPrint("📍 StackTrace: $stackTrace");
      return null;
    }
  }

  Future<void> fetchDatas() async {
    final client = Supabase.instance.client;

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final vendorId = await fetchVendorId();

      if (vendorId == null) {
        if (mounted) {
          setState(() {
            transactions = [];
            isLoading = false;
            errorMessage =
                "Vendor tidak ditemukan untuk akun Anda. Pastikan Anda terdaftar sebagai vendor.";
          });
        }
        return;
      }

      debugPrint("✅ Vendor ID found: $vendorId");

      List<Map<String, dynamic>> responseData = [];

      switch (widget.filter) {
        case 'pending':
          responseData = await client
              .from('transactions')
              .select("*")
              .eq('vendor_id', vendorId)
              .or('status_payment.eq.panjar_paid,status_payment.eq.complete')
              .or('status_work.eq.pending');
        case 'processing':
          responseData = await client
              .from('transactions')
              .select("*")
              .eq('vendor_id', vendorId)
              .or('status_work.eq.waiting,status_work.eq.editing,status_work.eq.post_processing,status_work.eq.complete')
              .or('status_payment.eq.panjar_paid,status_payment.eq.complete');
          break;
        case 'finish':
          responseData = await client
              .from('transactions')
              .select("*")
              .eq('vendor_id', vendorId)
              .or('status_work.eq.cancel,status_work.eq.finish');
          break;
      }

      debugPrint("📦 Transactions fetched: ${responseData.length}");

      // ✅ FIX: Enrich data dengan item details secara terpisah
      List<Map<String, dynamic>> enrichedTransactions = [];

      for (var transaction in responseData) {
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
        } else {
          transaction['item_data'] = null;
        }

        enrichedTransactions.add(transaction);
      }

      setState(() {
        transactions = enrichedTransactions;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint("❌ Error in fetchDatas: $e");
      debugPrint("📍 StackTrace: $stackTrace");

      if (mounted) {
        setState(() {
          isLoading = false;
          transactions = [];
          errorMessage = "Terjadi kesalahan: ${e.toString()}";
        });
      }
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    if (mounted) {
      fetchDatas();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDatas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: Text(widget.filter != null
            ? 'Order ${widget.filter![0].toUpperCase()}${widget.filter!.substring(1)}'
            : 'Order Pending'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchDatas,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchDatas,
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memuat data...'),
                  ],
                ),
              )
            : errorMessage != null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: fetchDatas,
                            child: Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : transactions.isNotEmpty
                    ? ListView.builder(
                        itemCount: transactions.length,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];

                          return GestureDetector(
                            onTap: () {
                              DMethod.log(
                                  "ID Transactions = ${transaction['id']}");
                              GoRouter.of(
                                context,
                              ).push('/vendor/pesanan-detail/${transaction['id']}');
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _RecentOrderItem(
                                customerName: transaction['user_displayName'] ??
                                    'Customer',
                                itemName:
                                    transaction['item_data']?['name'] ?? 'Item',
                                duration: transaction['durasi'] != null
                                    ? int.tryParse(
                                            transaction['durasi'].toString()) ??
                                        0
                                    : 0,
                                paymentType:
                                    transaction['payment_type'] ?? 'full',
                                amount: transaction['amount'] != null
                                    ? double.tryParse(
                                            transaction['amount'].toString()) ??
                                        0.0
                                    : 0.0,
                              ),
                            ),
                          );
                        },
                      )
                    : ListView(
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  "Tidak ada transaksi...",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
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
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: themeFromContext(context).colorScheme.surfaceBright,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName.length > 24
                          ? "${customerName.substring(0, 24)}..."
                          : customerName,
                      style: themeFromContext(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Opacity(
                      opacity: 0.65,
                      child: Text(
                        "${itemName.length > 20 ? "${itemName.substring(0, 20)}..." : itemName} | $duration jam",
                        style: themeFromContext(context).textTheme.bodySmall,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      formatCurrency(amount.round()),
                      style: themeFromContext(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: paymentType == 'panjar' ? Colors.orange : Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              paymentType == 'panjar' ? "Panjar" : "Full",
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
