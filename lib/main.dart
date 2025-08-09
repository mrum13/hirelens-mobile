import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unsplash_clone/models/user_model.dart';
import 'package:unsplash_clone/providers/user_provider.dart';
import 'package:unsplash_clone/screens/login.dart';
import 'package:unsplash_clone/screens/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/utils/auth_storage.dart';
import 'dart:convert';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lebuzerrmpjjugoxaaav.supabase.co',
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxlYnV6ZXJybXBqanVnb3hhYWF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkzOTQ4NjAsImV4cCI6MjA2NDk3MDg2MH0.6yeXMi_H8NtqhvGGNGvEQi7lB78eJzqHwb9_AGGPi7Q',
    ),
  );
  runApp(
    ChangeNotifierProvider(create: (_) => UserProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unsplash Clone',
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 41, 41, 41),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final sessionJson = await getAuthSession();

    if (sessionJson != null) {
      final response = await Supabase.instance.client.auth.recoverSession(
        jsonEncode(sessionJson),
      );
      if (response.session != null && response.user != null) {
        userProvider.setUser(
          UserModel(
            id: response.user!.id,
            email: response.user!.email ?? '',
            displayName:
                response.user!.userMetadata?['displayName'] ??
                response.user!.email ??
                '',
            role: response.user!.userMetadata?['role'],
          ),
        );
        await saveAuthSession(response.session!.toJson());
        if (mounted) {
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
        }
        return;
      } else {
        await clearAuthSession();
      }
    }
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
