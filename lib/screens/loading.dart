import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: Add animation here
    GoRouter.of(context).replace('/login');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Create splashscreen animation
    return SafeArea(child: Center(child: CircularProgressIndicator()));
  }
}
