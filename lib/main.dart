import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unsplash_clone/models/user_model.dart';
import 'package:unsplash_clone/providers/user_provider.dart';
import 'package:unsplash_clone/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/utils/auth_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lebuzerrmpjjugoxaaav.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxlYnV6ZXJybXBqanVnb3hhYWF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkzOTQ4NjAsImV4cCI6MjA2NDk3MDg2MH0.6yeXMi_H8NtqhvGGNGvEQi7lB78eJzqHwb9_AGGPi7Q',
  );

  final token = await getAuthToken();

  final userProvider = UserProvider();

  if (token != null) {
    // await Supabase.instance.client.auth.reauthenticate();
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      userProvider.setUser(
        UserModel(
          id: user.id,
          email: user.email!,
          displayName: user.userMetadata!['displayName'] ?? user.email!,
        ),
      );
    } else {
      await clearAuthToken();
    }
  }

  runApp(
    ChangeNotifierProvider(create: (_) => userProvider, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unsplash Clone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 41, 41, 41),
        ),
      ),

      home: LoginPage(),
    );
  }
}
