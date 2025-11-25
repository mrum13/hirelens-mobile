import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:unsplash_clone/components/lens_loading.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool isOpening = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void simulateLoading() async {
    // Play sound saat loading dimulai
    try {
      await _audioPlayer
          .play(AssetSource('sounds/Sound_Camera _Flash 1 - Copy.wav'));
    } catch (e) {
      print('Error playing sound: $e');
    }

    await Future.delayed(Duration(milliseconds: 1100));
    setState(() {
      isOpening = true;
    });
    GoRouter.of(context).go('/opening');
  }

  @override
  void initState() {
    super.initState();
    simulateLoading();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LensLoadingWidget(
          isOpening: isOpening,
          size: MediaQuery.of(context).size.width * 2.4,
          initialInnerRadius: 24,
          finalInnerRadius: 280,
        ),
      ),
    );
  }
}
