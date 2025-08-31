import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:unsplash_clone/screens/home_vendor.dart';
import 'package:unsplash_clone/screens/home_customer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final String role = client.auth.currentUser!.userMetadata!['role'];

    return role == 'customer' ? CustomerHomePage() : VendorHomePage();
  }
}
