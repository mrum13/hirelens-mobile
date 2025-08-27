// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:unsplash_clone/theme.dart';

String formatCurrency(int price) {
  final formatter = NumberFormat.simpleCurrency(
    locale: 'id_ID',
    decimalDigits: 0,
  );
  return formatter.format(price);
}

// URGENT: Apply what's in here to PesananCustomerPage with a bit of adjustment
class PesananVendorPage extends StatefulWidget {
  PesananVendorPage({super.key, this.filter});

  String? filter;

  @override
  State<PesananVendorPage> createState() => _PesananVendorPageState();
}

class _PesananVendorPageState extends State<PesananVendorPage> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

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

  // URGENT: Fix this if necessary and add trycatch block for it. Make sure it's able to utilize optional filter parameter
  Future<void> fetchDatas() async {
    final client = Supabase.instance.client;
    final vendorId = await fetchVendorId();

    final response = await client
        .from('transactions')
        .select("*, item_id(id, name)")
        .eq('vendor_id', vendorId);

    setState(() {
      transactions = response;
    });
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
      ),
      body: RefreshIndicator(
        onRefresh: fetchDatas,
        child: ListView.builder(
          itemCount: transactions.length,

          padding: EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final transaction = transactions[index];

            return GestureDetector(
              onTap:
                  () => GoRouter.of(
                    context,
                  ).push('/vendor/pesanan/${transaction['id']}'),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RecentOrderItem(
                  customerName: transaction['user_displayName'],
                  itemName: transaction['item_id']['name'],
                  duration: int.parse(transaction['durasi']),
                  paymentType: transaction['payment_type'],
                  amount: transaction['amount'],
                ),
              ),
            );
          },
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
