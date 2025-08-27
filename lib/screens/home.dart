import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:unsplash_clone/screens/home_vendor.dart';
import 'package:unsplash_clone/screens/home_customer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // URGENT: Create a SearchResultPage
    final _client = Supabase.instance.client;
    final String _role = _client.auth.currentUser!.userMetadata!['role'];

    return _role == 'customer' ? CustomerHomePage() : VendorHomePage();
  }
}
