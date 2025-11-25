import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/theme.dart';

class OpeningPage extends StatefulWidget {
  const OpeningPage({super.key});

  @override
  State<OpeningPage> createState() => _OpeningPageState();
}

class _OpeningPageState extends State<OpeningPage> {
  int _currentIndex = 0;
  late Timer _timer;

  final List<String> _images = List.generate(
    5,
    (i) => 'assets/images/${i + 1}.jpg',
  );

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(seconds: 3),
              reverseDuration: const Duration(seconds: 3),
              child: Image.asset(
                _images[_currentIndex],
                key: ValueKey(_images[_currentIndex]),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                color: Colors.black54, // dark tint
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hirelens",
                  style: themeFromContext(
                    context,
                  ).textTheme.displayLarge!.copyWith(fontSize: 48),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 56,
            left: 0,
            height: 160,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                spacing: 8,
                children: [
                  MyFilledButton(
                    width: double.infinity,
                    height: 48,
                    borderRadius: 4,
                    variant: MyButtonVariant.primary,
                    onTap:
                        () => Future.microtask(
                          () => GoRouter.of(context).go('/register'),
                        ),
                    child: Text(
                      "Daftar",
                      style: TextStyle(
                        color: themeFromContext(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: Opacity(
                      opacity: 0.75,
                      child: Text(
                        "Dengan mendaftar, anda menyetujui syarat & ketentuan kami.",
                        style: themeFromContext(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  MyOutlinedButton(
                    width: double.infinity,
                    height: 48,
                    borderRadius: 4,
                    variant: MyButtonVariant.white,
                    onTap:
                        () => Future.microtask(
                          () => GoRouter.of(context).go('/login'),
                        ),
                    child: Text("Masuk"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
