// ignore_for_file: must_be_immutable

import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/helper.dart';
import 'package:unsplash_clone/theme.dart';

class PesananCustomerPage extends StatefulWidget {
  PesananCustomerPage({super.key, this.filter});

  String? filter;

  @override
  State<PesananCustomerPage> createState() => _PesananCustomerPageState();
}

class _PesananCustomerPageState extends State<PesananCustomerPage> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  Future<void> fetchDatas() async {
    final client = Supabase.instance.client;

    try {
      List<Map<String, dynamic>> responseData = [];

      if (widget.filter != null && widget.filter!.isNotEmpty) {
        switch (widget.filter) {
          case 'processing':
            responseData = await client
                .from('transactions')
                .select(
                    "*, items!inner(id, name)") // ✅ DIPERBAIKI: item_id -> items
                .eq('user_id', client.auth.currentUser!.id)
                .or('status_work.eq.pending,status_work.eq.waiting,status_work.eq.editing,status_work.eq.post_processing,status_work.eq.complete')
                .or('status_payment.eq.panjar_paid,status_payment.eq.complete');
            break;
          case 'finish':
            responseData = await client
                .from('transactions')
                .select(
                    "*, items!inner(id, name)") // ✅ DIPERBAIKI: item_id -> items
                .eq('user_id', client.auth.currentUser!.id)
                .or('status_work.eq.finish,status_work.eq.cancel');
            break;
          default:
            responseData = await client
                .from('transactions')
                .select(
                    "*, items!inner(id, name)") // ✅ DIPERBAIKI: item_id -> items
                .eq('user_id', client.auth.currentUser!.id)
                .eq('status_payment', 'panjar_paid')
                .neq('status_work', 'cancel');
            break;
        }
      }

      setState(() {
        transactions = responseData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan! $e")));
      }
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
      ),
      body: RefreshIndicator(
        onRefresh: fetchDatas,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : transactions.isEmpty
                ? Center(child: Text("Tidak ada pesanan"))
                : ListView.builder(
                    itemCount: transactions.length,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];

                      return GestureDetector(
                        onTap: () => GoRouter.of(
                          context,
                        ).push('/customer/pesanan/${transaction['id']}'),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _RecentOrderItem(
                            statusWork: transaction['status_work'] == 'waiting'?"Pesanan diterima":transaction['status_work'],
                            itemName: transaction['items']['name'] ??
                                '', // ✅ DIPERBAIKI: item_id -> items
                            duration: int.tryParse(
                                    transaction['durasi']?.toString() ?? '0') ??
                                0,
                            paymentType: transaction['payment_type'] ?? '',
                            amount: (transaction['amount'] ?? 0).toDouble(),
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
    required this.statusWork,
    required this.itemName,
    required this.duration,
    required this.paymentType,
    required this.amount,
  });

  final String statusWork;
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
                    itemName.length > 24
                        ? "${itemName.substring(0, 24)}..."
                        : "$itemName | $duration jam" ,
                    style: themeFromContext(context).textTheme.bodyMedium,
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Opacity(
                        opacity: 0.65,
                        child: Text(
                          "Status Pesanan : ",
                          style: themeFromContext(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                          statusWork,
                          style: themeFromContext(context).textTheme.bodyLarge,
                        ),
                    ],
                  ),
                ],
              ),
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
