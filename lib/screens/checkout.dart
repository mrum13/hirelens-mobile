import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/helper.dart';
import 'package:unsplash_clone/main.dart';
import 'package:unsplash_clone/theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CheckoutPage extends StatefulWidget {
  final String dataId;
  const CheckoutPage({super.key, required this.dataId});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  MidtransSDK? _midtrans;
  String name = '';
  String thumbnail = '';
  String address = '';
  String description = '';
  String vendorName = '';
  num price = 0;
  num currentPrice = 0;
  List<dynamic> durations = [];
  bool isLoading = true;
  late dynamic selectedDuration;
  DateTime? selectedDate;
  DateTime? selectedTime;

  // ✅ GANTI DENGAN KEY MIDTRANS ANDA
  var midtransServerKey = dotenv.env['MIDTRANS_SERVER_KEY'];
  var midtransClientKey = dotenv.env['MIDTRANS_CLIENT_KEY'];
  final bool isProduction = false; // Set true untuk production

  Future<void> fetchData() async {
    final client = Supabase.instance.client;
    try {
      final response = await client
          .from('items')
          .select('*, vendors!inner(id,name)')
          .eq('id', widget.dataId)
          .single();

      setState(() {
        name = response['name'];
        vendorName = response['vendors']['name'];
        thumbnail = response['thumbnail'];
        address = response['address'];
        price = (response['price'] as num).toInt();
        currentPrice = price;
        durations = response['durations'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to fetch item detail: $e")));
      }
    }

    if (durations.isNotEmpty) {
      selectedDuration = durations[0];
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String?> createSnapToken(
      String orderId, num amount, String itemName) async {
    try {
      final url = Uri.parse(
        isProduction
            ? 'https://app.midtrans.com/snap/v1/transactions'
            : 'https://app.sandbox.midtrans.com/snap/v1/transactions',
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

  void payPanjar() async {
    try {
      if (selectedDate == null || selectedTime == null) {
        throw Exception("Harap pilih tanggal dan waktu foto!");
      }
      setState(() {
        isLoading = true;
      });

      final orderId = 'order-${DateTime.now().millisecondsSinceEpoch}-panjar';
      final amount = (calculatePanjar(currentPrice) +
              (calculatePanjar(currentPrice) * 0.025))
          .round();

      final token = await createSnapToken(orderId, amount, name);

      if (token == null) {
        throw Exception("Gagal membuat token pembayaran");
      }

            if (mounted) {
        DMethod.log(token, prefix: "Snap Token");
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
              
              if (result.status=='success') {
                await sendTransactionData(orderId, 'panjar', amount, 'panjar_paid').then(
                  (value) {
                    if (!mounted) return;
                    GoRouter.of(context).go('/checkout_success?order_id=$orderId');
                  },
                );
                
              }

              
            });
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void payFull() async {
    try {
      if (selectedDate == null || selectedTime == null) {
        throw Exception("Harap pilih tanggal dan waktu foto!");
      }
      setState(() {
        isLoading = true;
      });

      final orderId = 'order-${DateTime.now().millisecondsSinceEpoch}-fullpaid';
      final amount = (currentPrice + (currentPrice * 0.025)).round();

      final token = await createSnapToken(orderId, amount, name);

      if (token == null) {
        DMethod.log("Gagal buat token");
        throw Exception("Gagal membuat token pembayaran");
      }

      if (mounted) {
        DMethod.log(token, prefix: "Snap Token");
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
              
              if (result.status=='success') {
                await sendTransactionData(orderId, 'full', amount, 'complete').then(
                  (value) {
                    if (!mounted) return;
                    GoRouter.of(context).go('/checkout_success?order_id=$orderId');
                  },
                );
                
              }

              
            });
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<String> fetchVendorIdByItemId(String itemId) async {
    final client = Supabase.instance.client;

    final response = await client
        .from('items')
        .select('*, vendors!inner(id,name)')
        .eq('id', itemId)
        .single();
    return response['vendors']['id'] as String;
  }

  Future<void> sendTransactionData(
    String orderId,
    String paymentType,
    num amount,
    String statusPayment,
  ) async {
    final client = Supabase.instance.client;
    final vendorId = await fetchVendorIdByItemId(widget.dataId);

    try {
      await client.from('transactions').insert({
        'user_id': client.auth.currentUser!.id,
        'item_id': widget.dataId,
        'payment_type': paymentType,
        'durasi': selectedDuration.toString(),
        'tgl_foto': selectedDate!.toLocal().toString(),
        // 'waktu_foto': DateTime(
        //   selectedDate!.year,
        //   selectedDate!.month,
        //   selectedDate!.day,
        //   selectedTime!.hour,
        //   selectedTime!.minute,
        // ).toLocal().toString(),
        'midtrans_order_id': orderId,
        'amount': amount,
        'user_displayname':
            client.auth.currentUser!.userMetadata?['displayName'] ?? 'Customer',
        "vendor_id": vendorId,
        "status_payment": statusPayment,
        "status_work": 'pending',
        "status_payout": 'pending',
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi Kesalahan! $e")),
        );
      }
    }
  }

  double calculatePanjar(num input) {
    return (input * 30) / 100;
  }

  void changeSelectedDuration(dynamic duration) {
    setState(() {
      currentPrice = price * num.parse(duration);
      selectedDuration = duration;
    });
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
    fetchData();
  }

  @override
  void dispose() {
    _midtrans?.removeTransactionFinishedCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DMethod.log("Checkout Page -");
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: !isLoading
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: 112,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  Expanded(
                    child: Badge(
                      backgroundColor: Colors.white,
                      offset: Offset(-64, -8),
                      label: Text(
                        formatCurrency(
                          calculatePanjar(currentPrice).round() +
                              (calculatePanjar(currentPrice).round() * 0.025)
                                  .round(),
                        ),
                      ),
                      child: MyFilledButton(
                        variant: MyButtonVariant.neutral,
                        onTap: payPanjar,
                        child: Text(
                          "Bayar Panjar",
                          style: themeFromContext(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Badge(
                      backgroundColor: Colors.white,
                      offset: Offset(-64, -8),
                      label: Text(
                        formatCurrency(
                          currentPrice + (currentPrice * 0.025).round(),
                        ),
                      ),
                      child: MyFilledButton(
                        variant: MyButtonVariant.primary,
                        onTap: payFull,
                        child: Text(
                          "Bayar Full",
                          style: themeFromContext(
                            context,
                          ).textTheme.bodyLarge!.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 12,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          thumbnail,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 96,
                              height: 96,
                              color: Colors.grey[300],
                              child: Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: themeFromContext(
                                context,
                              ).textTheme.displayMedium,
                            ),
                            Text(
                              "Dari $vendorName",
                              style: themeFromContext(
                                context,
                              ).textTheme.displaySmall,
                            ),
                            SizedBox(height: 32),
                            Row(
                              spacing: 4,
                              children: [
                                const Icon(Icons.pin_drop_outlined, size: 12),
                                Expanded(
                                  child: Text(
                                    address,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  DropdownButtonFormField(
                    decoration: InputDecoration(label: Text("Durasi")),
                    value: durations.isNotEmpty ? durations[0] : null,
                    items: durations
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text("${d.toString()} Jam"),
                          ),
                        )
                        .toList(),
                    onChanged: changeSelectedDuration,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final curTime = DateTime.now();

                      final tmp = await showDatePicker(
                        context: context,
                        firstDate: curTime,
                        lastDate: DateTime(
                          curTime.year + 1,
                          curTime.month,
                          curTime.day,
                        ),
                      );

                      if (tmp != null) {
                        setState(() {
                          selectedDate = tmp;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          label: Text(
                            selectedDate == null
                                ? "Tanggal Foto"
                                : DateFormat('dd MMMM yyyy')
                                    .format(selectedDate!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final curTime = DateTime.now();
                      final tmp = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (tmp != null) {
                        setState(() {
                          selectedTime = DateTime(
                            curTime.year,
                            curTime.month,
                            curTime.day,
                            tmp.hour,
                            tmp.minute,
                          );
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          label: Text(
                            selectedTime == null
                                ? "Waktu Foto"
                                : DateFormat(DateFormat.HOUR24_MINUTE)
                                    .format(selectedTime!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Rincian Tagihan",
                    style: themeFromContext(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 32),
                  Column(
                    spacing: 4,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Harga Item :"),
                          Text(
                            "${formatCurrency(price)} x $selectedDuration",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Harga Item :"),
                          Text(formatCurrency(currentPrice)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Transaction Fee :"),
                          Text("2,5%/transaksi"),
                        ],
                      ),
                      SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Subtotal :",
                            style:
                                themeFromContext(context).textTheme.bodyLarge,
                          ),
                          Text(
                            formatCurrency(
                              (currentPrice + (currentPrice * 0.025)).round(),
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
                    style: themeFromContext(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.white54),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "\"Transaction Fee\" dihitung berdasarkan berapa jumlah transaksi yang akan dibayarkan. Jika anda membayar secara panjar, maka anda akan dikenakan 2 kali \"Transaction Fee\". Satu untuk 30% dari total Harga Item dan 70% dari total Harga Item.",
                    style: themeFromContext(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.white54),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
