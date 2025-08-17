import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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
  int price = 0;
  int currentPrice = 0;
  List<dynamic> durations = [];
  bool isLoading = true;
  late dynamic selectedDuration;
  DateTime? selectedDate;

  Future<void> fetchData() async {
    final client = Supabase.instance.client;
    try {
      final response =
          await client.from('items').select().eq('id', widget.dataId).single();

      setState(() {
        name = response['name'];
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
    setState(() {
      isLoading = true;
    });
  }

  void payFull() async {
    // URGENT: Finish this function
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
          isLoading
              ? null
              : SizedBox(
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: payPanjar,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            spacing: 16,
                            children: [
                              Text("Panjar"),
                              Text(
                                formatCurrency(
                                  calculatePanjar(currentPrice).round(),
                                ),
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceBright,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: payFull,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            spacing: 16,
                            children: [
                              Text("Full"),
                              Text(
                                formatCurrency(currentPrice),
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceBright,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          thumbnail,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
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
                                ).buttonTheme.colorScheme!.tertiary,
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
