import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to fetch item detail")));
    }

    selectedDuration = durations[0];

    setState(() {
      isLoading = false;
    });
  }

  void payPanjar() async {
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
          'price': calculatePanjar(currentPrice).round(),
          'itemName': name,
        },
      );

      final token = res.data['snapToken'];

      midtrans = await MidtransSDK.init(config: config);
      midtrans!.setTransactionFinishedCallback((result) {
        if (result.status == 'canceled') {
          GoRouter.of(context).pop();
        } else {
          while (GoRouter.of(context).canPop() == true) {
            GoRouter.of(context).pop();
          }

          GoRouter.of(context).pushReplacement('/home');
        }
      });

      await midtrans!.startPaymentUiFlow(token: token);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));

      setState(() {
        isLoading = false;
      });
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
        },
      );

      final token = res.data['snapToken'];

      midtrans = await MidtransSDK.init(config: config);
      midtrans!.setTransactionFinishedCallback((result) {
        if (result.status == 'canceled') {
          GoRouter.of(context).pop();
        } else {
          while (GoRouter.of(context).canPop() == true) {
            GoRouter.of(context).pop();
          }
          GoRouter.of(context).push('/home');
        }
      });

      await midtrans!.startPaymentUiFlow(token: token);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));

      setState(() {
        isLoading = false;
      });
    }
  }

  String formatCurrency(int price) {
    final formatter = NumberFormat.simpleCurrency(
      locale: 'id_ID',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  double calculatePanjar(int input) {
    return (input * 30) / 100;
  }

  void changeSelectedDuration(dynamic duration) {
    setState(() {
      currentPrice = price * (duration as int);
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
                      child: MyFilledButton(
                        variant: MyButtonVariant.neutral,
                        onTap: payPanjar,
                        child: Text(
                          "Bayar Panjar",
                          style: themeFromContext(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    Expanded(
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
                        Image.network(
                          thumbnail,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
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
                    const SizedBox(height: 16),
                    Text("Durasi"),
                    DropdownButtonFormField(
                      value: durations.isNotEmpty ? durations[0] : null,
                      items:
                          durations
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d.toString()),
                                ),
                              )
                              .toList(),
                      onChanged: changeSelectedDuration,
                    ),
                    const SizedBox(height: 16),
                    DatePickerTheme(
                      data: DatePickerThemeData(
                        dayStyle: TextStyle(fontSize: 16),
                        yearStyle: TextStyle(fontSize: 16),
                        weekdayStyle: TextStyle(fontSize: 16),
                        inputDecorationTheme: InputDecorationTheme(
                          labelStyle: TextStyle(fontSize: 16),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          DateTime? tmpSelectedDate;
                          tmpSelectedDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(DateTime.now().year + 2),
                          );

                          setState(() {
                            selectedDate = tmpSelectedDate;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(
                                  context,
                                ).buttonTheme.colorScheme!.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            selectedDate != null
                                ? "Pilih Tanggal : ${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"
                                : "Pilih Tanggal",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
