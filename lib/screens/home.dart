import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:unsplash_clone/screens/vendor/home_vendor.dart';
import 'package:unsplash_clone/screens/customer/home_customer.dart';
import 'package:unsplash_clone/screens/login.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key}); 

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    // 🔹 Jika belum login atau data user belum lengkap
    if (user == null || user.userMetadata == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in or missing data'),
        ),
      );
      // Atau arahkan ke halaman login:
      // return const LoginPage();
    }

    final role = user.userMetadata!['role'] ??
        'customer'; // 🔹 Default ke 'customer' jika null

    return role == 'customer'
        ? const CustomerHomePage()
        : const VendorHomePage();
  }
}
