import 'package:flutter/material.dart';
import 'package:unsplash_clone/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:unsplash_clone/theme.dart';

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Project Hirelens',
      theme:
          HirelensTheme(
            TextTheme(
              bodyLarge: TextStyle(fontSize: 32),
              bodyMedium: TextStyle(fontSize: 16),
              bodySmall: TextStyle(fontSize: 12),
              displayLarge: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 48,
              ),
              displayMedium: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
              displaySmall: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ).light(),
    );
  }
}
