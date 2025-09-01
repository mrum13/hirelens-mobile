import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/helper.dart';
import 'package:unsplash_clone/midtrans.dart';
import 'package:unsplash_clone/theme.dart';

class CheckoutPage extends StatefulWidget {
  final int dataId;
  const CheckoutPage({super.key, required this.dataId});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String name = '';
  String thumbnail = '';
  String address = '';
  String description = '';
  String vendorName = '';
  int price = 0;
  int currentPrice = 0;
  List<dynamic> durations = [];
  bool isLoading = true;
  late dynamic selectedDuration;
  DateTime? selectedDate;
  DateTime? selectedTime;
  MidtransSDK? midtrans;

  Future<void> fetchData() async {
    final client = Supabase.instance.client;
    try {
      final response =
          await client
              .from('items')
              .select('*, vendor(id,name)')
              .eq('id', widget.dataId)
              .single();

      setState(() {
        name = response['name'];
        vendorName = response['vendor']['name'];
        thumbnail = response['thumbnail'];
        address = response['address'];
        price = response['price'];
        currentPrice = price;
        durations = response['durations'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to fetch item detail")));
      }
    }

    selectedDuration = durations[0];

    setState(() {
      isLoading = false;
    });
  }

  void payPanjar() async {
    try {
      if (selectedDate == null || selectedTime == null) {
        throw Exception("Harap pilih tanggal dan waktu foto!");
      }
      setState(() {
        isLoading = true;
      });

      final client = Supabase.instance.client;
      final res = await client.functions.invoke(
        'midtrans-merchant-backend',
        body: {
          'orderId': 'order-${DateTime.now().millisecondsSinceEpoch}',
          'price': calculatePanjar(currentPrice).round(),
          'itemName': name,
          'duration': selectedDuration,
        },
      );

      final token = res.data['snapToken'];

      GoRouter.of(context).push('/payment/$token');
      // midtrans = await MidtransSDK.init(config: config);
      // midtrans!.setTransactionFinishedCallback((result) async {
      //   if (result.status == 'canceled') {
      //     GoRouter.of(context).pop();
      //   } else if (result.status == 'pending') {
      //     while (GoRouter.of(context).canPop() == true) {
      //       GoRouter.of(context).pop();
      //     }

      //     await sendTransactionData(
      //       result.transactionId!,
      //       'panjar',
      //       result.paymentType!,
      //       (calculatePanjar(currentPrice) +
      //               (calculatePanjar(currentPrice) * 0.025))
      //           .round(),
      //       result.status,
      //     );

      //     if (mounted) {
      //       GoRouter.of(context).pushReplacement('/home');
      //     }
      //   } else {
      //     while (GoRouter.of(context).canPop() == true) {
      //       GoRouter.of(context).pop();
      //     }

      //     await sendTransactionData(
      //       result.transactionId!,
      //       'panjar',
      //       result.paymentType!,
      //       (calculatePanjar(currentPrice) +
      //               (calculatePanjar(currentPrice) * 0.025))
      //           .round(),
      //       result.status,
      //     );

      //     if (mounted) {
      //       GoRouter.of(context).pushReplacement('/home');
      //     }
      //   }
      // });

      // await midtrans!.startPaymentUiFlow(token: token);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void payFull() async {
    try {
      if (selectedDate == null) {
        throw Exception("Harap pilih tanggal foto!");
      }
      setState(() {
        isLoading = true;
      });

      final client = Supabase.instance.client;
      final res = await client.functions.invoke(
        'midtrans-merchant-backend',
        body: {
          'orderId': 'order-${DateTime.now().millisecondsSinceEpoch}',
          'price': currentPrice,
          'itemName': name,
          'duration': selectedDuration,
        },
      );

      final token = res.data['snapToken'];

      midtrans = await MidtransSDK.init(config: config);
      midtrans!.setTransactionFinishedCallback((result) async {
        if (result.status == 'canceled') {
          GoRouter.of(context).pop();
        } else if (result.status == 'pending') {
          while (GoRouter.of(context).canPop() == true) {
            GoRouter.of(context).pop();
          }
          await sendTransactionData(
            result.transactionId!,
            'full_paid',
            result.paymentType!,
            currentPrice + (currentPrice * 0.025).round(),
            result.status,
          );
          GoRouter.of(context).pushReplacement('/home');
        } else {
          while (GoRouter.of(context).canPop() == true) {
            GoRouter.of(context).pop();
          }
          await sendTransactionData(
            result.transactionId!,
            'full_paid',
            result.paymentType!,
            currentPrice + (currentPrice * 0.025).round(),
            result.status,
          );
          GoRouter.of(context).pushReplacement('/home');
        }
      });

      await midtrans!.startPaymentUiFlow(token: token);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<int> fetchVendorIdByItemId(int itemId) async {
    final client = Supabase.instance.client;

    final response =
        await client
            .from('items')
            .select('vendor(id)')
            .eq('id', itemId)
            .single();
    return response['vendor']['id'] as int;
  }

  Future<void> sendTransactionData(
    String transactionId,
    String paymentType,
    String paymentMethod,
    int amount,
    String transactionStatus,
  ) async {
    final client = Supabase.instance.client;
    final vendorId = await fetchVendorIdByItemId(widget.dataId);

    try {
      await client.from('transactions').insert({
        'user_id': client.auth.currentUser!.id,
        'item_id': widget.dataId,
        'payment_type': paymentType,
        'payment_method': paymentMethod,
        'durasi': selectedDuration,
        'tgl_foto': selectedDate!.toLocal().toString(),
        'waktu_foto':
            DateTime(
              selectedDate!.year,
              selectedDate!.month,
              selectedDate!.day,
              selectedTime!.hour,
              selectedTime!.minute,
            ).toLocal().toString(),
        'midtrans_order_id': transactionId,
        'amount': amount,
        'user_displayName':
            client.auth.currentUser!.userMetadata!['displayName'],
        "vendor_id": vendorId,
        "status_payment":
            transactionStatus == 'pending'
                ? 'pending'
                : paymentType == 'full_paid'
                ? 'complete'
                : 'panjar_paid',
        "status_work": 'pending',
        "status_payout": 'pending_work',
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi Kesalahan! $e")));
    }
  }

  double calculatePanjar(int input) {
    return (input * 30) / 100;
  }

  void changeSelectedDuration(dynamic duration) {
    setState(() {
      currentPrice = price * (duration as int);
      selectedDuration = duration;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar:
          !isLoading
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
                            style:
                                themeFromContext(context).textTheme.bodyLarge,
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
      body:
          isLoading
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
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style:
                                  themeFromContext(
                                    context,
                                  ).textTheme.displayMedium,
                            ),
                            Text(
                              "Dari $vendorName",
                              style:
                                  themeFromContext(
                                    context,
                                  ).textTheme.displaySmall,
                            ),
                            SizedBox(height: 32),
                            Row(
                              spacing: 4,
                              children: [
                                const Icon(Icons.pin_drop_outlined, size: 12),
                                Text(
                                  address,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    DropdownButtonFormField(
                      decoration: InputDecoration(label: Text("Durasi")),
                      value: durations.isNotEmpty ? durations[0] : null,
                      items:
                          durations
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

                        setState(() {
                          selectedDate = tmp!;
                        });
                      },
                      child: TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          label: Text(
                            selectedDate == null
                                ? "Tanggal Foto"
                                : DateFormat(
                                  'dd MMMM yyyy',
                                ).format(selectedDate!),
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

                        setState(() {
                          selectedTime = DateTime(
                            curTime.year,
                            curTime.month,
                            curTime.day,
                            tmp!.hour,
                            tmp.minute,
                          );
                        });
                      },
                      child: TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          label: Text(
                            selectedTime == null
                                ? "Waktu Foto"
                                : DateFormat(
                                  DateFormat.HOUR24_MINUTE,
                                ).format(selectedTime!),
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
                  ],
                ),
              ),
    );
  }
}
