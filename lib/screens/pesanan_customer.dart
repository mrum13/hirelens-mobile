// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PesananCustomerPage extends StatefulWidget {
  PesananCustomerPage({super.key, this.filter});

  String? filter;

  @override
  State<PesananCustomerPage> createState() => _PesananCustomerPageState();
}

// URGENT: Create PesananDetailCustomerPage
class _PesananCustomerPageState extends State<PesananCustomerPage> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  Future<int> fetchVendorId() async {
    final client = Supabase.instance.client;

    final response =
        await client
            .from('vendors')
            .select('id')
            .eq(
              'user_id',
              client.auth.currentUser!.userMetadata!['displayName'],
            )
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
      body: RefreshIndicator(
        onRefresh: fetchDatas,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [],
        ),
      ),
    );
  }
}
