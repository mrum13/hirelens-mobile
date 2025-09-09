import 'package:flutter/material.dart';
import 'package:animated_svg/animated_svg.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedLoader extends StatefulWidget {
  const AnimatedLoader({super.key});

  @override
  State<AnimatedLoader> createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<AnimatedLoader> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [SvgPicture.asset('assets/')]);
  }
}
