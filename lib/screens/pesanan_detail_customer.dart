import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/helper.dart';
import 'package:unsplash_clone/theme.dart';

class PesananDetailCustomerPage extends StatefulWidget {
  const PesananDetailCustomerPage({super.key, required this.dataId});

  final int dataId;

  @override
  State<PesananDetailCustomerPage> createState() =>
      _PesananDetailCustomerPageState();
}

class _PesananDetailCustomerPageState extends State<PesananDetailCustomerPage>
    with RouteAware {
  bool isLoading = true;
  late Map<String, dynamic> data;

  Future<void> fetchAndSetData() async {
    final client = Supabase.instance.client;
    try {
      final response =
          await client
              .from('transactions')
              .select(
                "*, item_id(id, name, price, thumbnail, vendor(id, name))",
              )
              .eq('id', widget.dataId)
              .single();

      if (mounted) {
        setState(() {
          data = response;
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan! $e")));
    }
  }

  Future<void> _paySisa() async {}
  Future<void> _cancelPesanan() async {}
  Future<void> _payPesanan() async {}

  @override
  void initState() {
    super.initState();
    fetchAndSetData();
  }

  // FIXME: Why it's not refreshing the page
  @override
  void didPopNext() {
    super.didPopNext();
    fetchAndSetData();
  }

  int _calculateSisa(int price, int durasi, int payed, int transactionFee) {
    final subtotal = (price * durasi) + transactionFee;
    return subtotal - payed;
  }

  int _calculateTransactionFee(int price, int durasi, bool? isPanjar) {
    if (isPanjar == true) {
      return (((((price * durasi) * 0.3) + ((price * durasi) * 0.7)) * 0.025))
          .round();
    }

    return ((price * durasi) * 0.025).round();
  }

  Widget buildPaymentBar(String paymentStatus) {
    switch (paymentStatus) {
      case 'pending':
        return Row(
          spacing: 8,
          children: [
            Expanded(
              child: MyOutlinedButton(
                variant: MyButtonVariant.secondary,
                onTap: _cancelPesanan,
                child: Text("Cancel"),
              ),
            ),
            Expanded(
              child: MyFilledButton(
                variant: MyButtonVariant.primary,
                onTap: _payPesanan,
                child: Text("Bayar"),
              ),
            ),
          ],
        );
      case 'pending_full':
        return Expanded(
          child: MyFilledButton(
            variant: MyButtonVariant.primary,
            onTap: _paySisa,
            child: Text("Bayar Sisa Biaya"),
          ),
        );
      default:
        return Center(
          child: Text(
            "Dalam proses : ${(data['status_work'] as String).split("_").map((e) => e[0].toUpperCase() + e.substring(1, e.length)).join(" ")}",
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              "Rincian Pesanan",
              style: themeFromContext(context).textTheme.displayMedium,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => GoRouter.of(context).pop(),
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: 72,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: buildPaymentBar(data['status_work']),
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {},
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Text(
                                  "Tanggal Pesan : ${DateFormat('EEEE, dd MMMM yyyy, hh:mm').format(DateTime.parse(data['created_at'] as String))}",
                                ),
                                Text(
                                  "Tanggal Bayar : ${DateFormat('EEEE, dd MMMM yyyy, hh:mm').format(DateTime.parse(data['created_at'] as String))}",
                                ),
                              ],
                            ),
                            Divider(height: 32),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Text(
                                  "Tipe Pembayaran : ${data['payment_type']}",
                                ),
                                Text(
                                  "Metode Pembayaran : ${data['payment_method']}",
                                ),
                              ],
                            ),
                            Divider(height: 32),
                            _ItemDescription(
                              name: data['item_id']['name'],
                              vendor: data['item_id']['vendor']['name'],
                              price: data['item_id']['price'],
                              thumbnail: data['item_id']['thumbnail'],
                            ),
                            Divider(height: 32),
                            Text(
                              "Detail Pembayaran",
                              style:
                                  themeFromContext(
                                    context,
                                  ).textTheme.displayMedium,
                            ),
                            SizedBox(height: 32),
                            Column(
                              spacing: 16,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Harga Item :"),
                                    Text(
                                      "${formatCurrency(data['item_id']['price'])} x ${data['durasi']}",
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Transaction Fee (2,5%) :"),
                                    Text(
                                      formatCurrency(
                                        _calculateTransactionFee(
                                          data['item_id']['price'],
                                          int.parse(data['durasi']),
                                          data['payment_type'] != 'full_paid',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                if (data['status_payment'] != 'pending')
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Dibayar :"),
                                      Text(
                                        formatCurrency(
                                          (data['amount'] as double).round(),
                                        ),
                                      ),
                                    ],
                                  ),

                                SizedBox(height: 12),

                                if (data['status_payment'] != 'pending')
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Sisa :"),
                                      Text(
                                        formatCurrency(
                                          _calculateSisa(
                                            data['item_id']['price'],
                                            int.parse(data['durasi']),
                                            (data['amount'] as double).round(),
                                            _calculateTransactionFee(
                                              data['item_id']['price'],
                                              int.parse(data['durasi']),
                                              data['payment_type'] !=
                                                  'full_paid',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Subtotal :",
                                      style:
                                          themeFromContext(
                                            context,
                                          ).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      formatCurrency(
                                        (data['item_id']['price'] *
                                                int.parse(data['durasi'])) +
                                            _calculateTransactionFee(
                                              data['item_id']['price'],
                                              int.parse(data['durasi']),
                                              data['payment_type'] !=
                                                  'full_paid',
                                            ),
                                      ),
                                      style:
                                          themeFromContext(
                                            context,
                                          ).textTheme.displayLarge,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Note :",
                              style: themeFromContext(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: Colors.white54),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "\"Transaction Fee\" dihitung berdasarkan berapa jumlah transaksi yang akan dibayarkan. Jika anda membayar secara panjar, maka anda akan dikenakan 2 kali \"Transaction Fee\". Satu untuk 30% dari total Harga Item dan 70% dari total Harga Item.",
                              style: themeFromContext(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
            ),
          ),
        );
  }
}

class _ItemDescription extends StatelessWidget {
  const _ItemDescription({
    required this.name,
    required this.vendor,
    required this.price,
    required this.thumbnail,
  });

  final String name;
  final String vendor;
  final int price;
  final String thumbnail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      height: 120,
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              thumbnail,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name.length < 18 ? name : "${name.substring(0, 18)}...",
                style: themeFromContext(context).textTheme.displayMedium,
              ),
              Text(
                "Dari $vendor",
                style: themeFromContext(context).textTheme.bodyMedium,
              ),
              Spacer(),
              Text(
                formatCurrency(price),
                style: themeFromContext(context).textTheme.displayMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
