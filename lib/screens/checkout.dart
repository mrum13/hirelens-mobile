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

  // URGENT: Finish this function
  void payPanjar() async {}

  // URGENT: Finish this function
  void payFull() async {}

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // LATER: Use GestureDetector instead
              ElevatedButton(
                onPressed: payPanjar,
                child: Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Panjar"),
                    Text(
                      formatCurrency(calculatePanjar(currentPrice).round()),
                      style: TextStyle(fontSize: 8, color: Colors.black38),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: payFull,
                child: Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Bayar Full"),
                    Text(
                      formatCurrency(currentPrice),
                      style: TextStyle(fontSize: 8, color: Colors.black38),
                    ),
                  ],
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
                    DatePickerDialog(
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now(),
                    ),
                  ],
                ),
              ),
    );
  }
}
