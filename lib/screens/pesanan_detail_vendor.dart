import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PesananDetailVendorPage extends StatefulWidget {
  const PesananDetailVendorPage({super.key, required this.dataId});

  final int dataId;

  @override
  State<PesananDetailVendorPage> createState() =>
      _PesananDetailVendorPageState();
}

// URGENT: Work on this page's UI
class _PesananDetailVendorPageState extends State<PesananDetailVendorPage> {
  bool isLoading = true;
  late Map<String, dynamic> data;

  Future<void> fetchAndSetData() async {
    final client = Supabase.instance.client;
    final response =
        await client
            .from('transaction')
            .select("*, item_id(id, name)")
            .eq('id', widget.dataId)
            .single();

    data = response;

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAndSetData();
  }

  // URGENT: We need RefreshIndicator here too
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
