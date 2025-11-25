import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/router.dart';
import 'package:unsplash_clone/theme.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Coba load file .env
  await dotenv.load(fileName: 'assets/.env');

  // Ambil nilai dari .env
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  // Cegah error "Null is not a subtype of String"
  if (supabaseUrl == null ||
      supabaseAnonKey == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey.isEmpty) {
    runApp(const EnvErrorApp());
    return;
  }

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class EnvErrorApp extends StatelessWidget {
  const EnvErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            '⚠️ File .env tidak terbaca atau SUPABASE_URL / SUPABASE_ANON_KEY kosong.\n\n'
            'Periksa file: assets/.env\n'
            'Contoh isi:\n'
            'SUPABASE_URL=https://xxxxx.supabase.co\n'
            'SUPABASE_ANON_KEY=eyxxxxx',
            style: TextStyle(color: Colors.yellow, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'HireLens',
      routerConfig: router,
      theme: hirelensDarkTheme,
    );
  }
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
