import 'dart:convert';

import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/helper.dart';
import 'package:unsplash_clone/theme.dart';
import 'package:http/http.dart' as http;

class PesananDetailCustomerPage extends StatefulWidget {
  const PesananDetailCustomerPage({super.key, required this.dataId});

  final String dataId;

  @override
  State<PesananDetailCustomerPage> createState() =>
      _PesananDetailCustomerPageState();
}

class _PesananDetailCustomerPageState extends State<PesananDetailCustomerPage>
    with RouteAware {
  bool isLoading = true;
  Map<String, dynamic> data = {};
  MidtransSDK? _midtrans;
  var midtransServerKey = dotenv.env['MIDTRANS_SERVER_KEY'];
  var midtransClientKey = dotenv.env['MIDTRANS_CLIENT_KEY'];
  var orderIdSupabase = "-";

  Future<void> fetchAndSetData() async {
    final client = Supabase.instance.client;
    try {
      final response = await client
          .from('transactions')
          .select(
            "*, item_id(id, name, price, thumbnail, vendors(id, name))",
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
      DMethod.log("Gagal ki $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan! $e")));
    }
  }

  // num calculateSisa(num itemPrice, num duration) {
  //   final sisa = (itemPrice * duration) * 0.03;

  //   return sisa.round();
  // }

  Future<String?> createSnapToken(
      String orderId, num amount, String itemName) async {
    try {
      final url = Uri.parse(
        'https://app.sandbox.midtrans.com/snap/v1/transactions',
      );

      final credentials = base64Encode(utf8.encode('$midtransServerKey:'));

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Basic $credentials',
        },
        body: json.encode({
          'transaction_details': {
            'order_id': orderId,
            'gross_amount': amount,
          },
          'item_details': [
            {
              'id': widget.dataId,
              'price': amount,
              'quantity': 1,
              'name': itemName,
            }
          ],
          'customer_details': {
            'first_name': Supabase.instance.client.auth.currentUser
                    ?.userMetadata?['displayName'] ??
                'Customer',
            'email': Supabase.instance.client.auth.currentUser?.email ?? '',
          },
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['token'];
      } else {
        throw Exception('Failed to create snap token: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating snap token: $e');
    }
  }

  Future<void> _paySisa() async {
    final client = Supabase.instance.client;
    try {
      final selectedTransaction = await client
          .from('transactions')
          .select("*, item_id(id, name, price)")
          .eq('id', widget.dataId)
          .single();

      final selectedMidtransOrderId =
          (selectedTransaction['midtrans_order_id'] as String).split(
        '-panjar',
      )[0];

      final orderIdMidtrans ="$selectedMidtransOrderId-fullpaid";
      orderIdSupabase = "${selectedTransaction['midtrans_order_id']}";

      // final res = await client.functions.invoke(
      //   'midtrans-merchant-backend',
      //   body: {
      //     'orderId': orderId,
      //     'price': _calculateSisa(
      //       data['item_id']['price'],
      //       data['durasi'],
      //       data['amount'].round(),
      //       _calculateTransactionFee(
      //         data['item_id']['price'],
      //         data['durasi'],
      //         data['payment_type'] != 'full_paid',
      //       ),
      //     ),
      //     'itemName': selectedTransaction['item_id']['name'],
      //     'duration': selectedTransaction['durasi'],
      //   },
      // );

      // DMethod.log(res.data.toString(), prefix: "response Invoke");

      // final token = res.data['snapToken'];
      final token = await createSnapToken(
          orderIdMidtrans,
          _calculateSisa(
            data['item_id']['price'],
            data['durasi'],
            data['amount'].round(),
            _calculateTransactionFee(
              data['item_id']['price'],
              data['durasi'],
              data['payment_type'] != 'full_paid',
            ),
          ),
          data['item_id']['name']);

      if (mounted) {
        _midtrans
            ?.startPaymentUiFlow(
          token: token,
        )
            .then(
          (value) {
            _midtrans!.setTransactionFinishedCallback((result) async {
              setState(() {
                isLoading = false;
              });
              DMethod.log(result.transactionId.toString(),
                  prefix: "Result Midtrans Transaction ID");
              DMethod.log(result.status.toString(),
                  prefix: "Result Midtrans Status");
              DMethod.log(result.message.toString(),
                  prefix: "Result Midtrans Message");
              DMethod.log(result.paymentType.toString(),
                  prefix: "Result Midtrans Payment Type");

              if (result.status == 'success') {
                await sendTransactionData(
                        orderId: orderIdSupabase,
                        paymentType: 'panjar',
                        amount: (data['item_id']['price'] * data['durasi']) +
                            _calculateTransactionFee(
                              data['item_id']['price'],
                              data['durasi'],
                              data['payment_type'] != 'full_paid',
                            ),
                        statusPayment: 'complete')
                    .then(
                  (value) {
                    if (!mounted) return;
                    GoRouter.of(context)
                        .go('/checkout_success?order_id=$orderIdSupabase');
                  },
                );
              }
            });
          },
        );
      }
    } catch (e) {
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi Kesalahan! $e")));
    }
  }

  Future<void> sendTransactionData({
    required String orderId,
    required String paymentType,
    required num amount,
    required String statusPayment,
  }) async {
    final client = Supabase.instance.client;
    DMethod.log("$orderId,$paymentType,$amount,$statusPayment",prefix: "Send Transaction Data");

    try {
      var res = await client.from('transactions').update({
        'payment_type': paymentType,
        'amount': amount,
        'status_payment': statusPayment,
      }).eq('midtrans_order_id', orderId);

      DMethod.log(res.toString(), prefix: "Update Response");
    } catch (e) {
      DMethod.log(e.toString(),prefix: "Error update data");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi Kesalahan! $e")),
        );
      }
    }
  }

  Future initSDK() async {
    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: dotenv.env['MIDTRANS_CLIENT_KEY'] ?? "",
        merchantBaseUrl: dotenv.env['MIDTRANS_MERCHANT_BASE_URL'] ?? "",
        enableLog: true,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initSDK();
    fetchAndSetData();
    DMethod.log("Pesanan Detail Customer");
  }

  // FIXME: Why it's not refreshing the page
  @override
  void didPopNext() {
    super.didPopNext();
    fetchAndSetData();
  }

  num _calculateSisa(num price, num durasi, num payed, num transactionFee) {
    final subtotal = (price * durasi) + transactionFee;
    return subtotal - payed;
  }

  num _calculateTransactionFee(num price, num durasi, bool? isPanjar) {
    if (isPanjar == true) {
      return (((((price * durasi) * 0.3) + ((price * durasi) * 0.7)) * 0.025))
          .round();
    }

    return ((price * durasi) * 0.025).round();
  }

  Widget buildPaymentBar(String paymentStatus) {
    DMethod.log(paymentStatus, prefix: "Payment Status");
    switch (paymentStatus) {
      case 'panjar_paid':
        return MyFilledButton(
          variant: MyButtonVariant.primary,
          onTap: _paySisa,
          child: Text("Bayar Sisa Biaya"),
        );

      // Row(
      //   spacing: 8,
      //   children: [
      //     Expanded(
      //       child: MyOutlinedButton(
      //         variant: MyButtonVariant.secondary,
      //         onTap: _cancelPesanan,
      //         child: Text("Cancel"),
      //       ),
      //     ),
      //     Expanded(
      //       child: MyFilledButton(
      //         variant: MyButtonVariant.primary,
      //         onTap: _payPesanan,
      //         child: Text("Bayar Sisa Biaya"),
      //       ),
      //     ),
      //   ],
      // );
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
              "Status Order : ${(data['status_work'] as String).split("_").map((e) => e[0].toUpperCase() + e.substring(1, e.length)).join(" ")}",
              style: themeFromContext(
                context,
              ).textTheme.displayMedium),
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
            bottomNavigationBar: SafeArea(
              child: SizedBox(
                height: 80,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: buildPaymentBar(data['status_payment']),
                ),
              ),
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {},
                child: isLoading
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
                              vendor: data['item_id']['vendors']['name'],
                              price: data['item_id']['price'],
                              thumbnail: data['item_id']['thumbnail'],
                            ),
                            Divider(height: 32),
                            Text(
                              "Detail Pembayaran",
                              style: themeFromContext(
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
                                          data['durasi'],
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
                                          data['amount'],
                                        ),
                                      ),
                                    ],
                                  ),
                                SizedBox(height: 12),
                                if (data['status_payment'] != 'complete')
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Sisa :"),
                                      Text(
                                          formatCurrency(
                                            _calculateSisa(
                                              data['item_id']['price'],
                                              data['durasi'],
                                              data['amount'].round(),
                                              _calculateTransactionFee(
                                                data['item_id']['price'],
                                                data['durasi'],
                                                data['payment_type'] !=
                                                    'full_paid',
                                              ),
                                            ),
                                          ),
                                          style: themeFromContext(
                                            context,
                                          ).textTheme.displayLarge),
                                    ],
                                  ),
                                if (data['status_payment'] == 'complete')
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Subtotal :",
                                        style: themeFromContext(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                      Text(
                                        formatCurrency(
                                          (data['item_id']['price'] *
                                                  data['durasi']) +
                                              _calculateTransactionFee(
                                                data['item_id']['price'],
                                                data['durasi'],
                                                data['payment_type'] !=
                                                    'full_paid',
                                              ),
                                        ),
                                        style: themeFromContext(
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
  final num price;
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
