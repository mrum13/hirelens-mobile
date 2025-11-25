import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key, required this.keyword});

  final String keyword;

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

// URGENT: Test this page
class _SearchResultPageState extends State<SearchResultPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> results = [];

  Future<void> loadRelevantResult() async {
    final client = Supabase.instance.client;

    final response = await client
        .from('items')
        .select("*, vendor(id, name)")
        .like('name', "%${widget.keyword}%");

    setState(() {
      results = response;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadRelevantResult();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
