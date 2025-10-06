import 'dart:math' as math;
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LensLoadingWidget extends StatefulWidget {
  bool isOpening;
  double size;
  double initialInnerRadius;
  double finalInnerRadius;
  Duration animationDuration;

  LensLoadingWidget({
    super.key,
    this.isOpening = false,
    this.size = 240,
    this.initialInnerRadius = 24,
    this.finalInnerRadius = 120,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<LensLoadingWidget> createState() => _LensLoadingWidgetState();
}

class _LensLoadingWidgetState extends State<LensLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> innerRAnim;
  late double innerR;

  @override
  void initState() {
    super.initState();
    innerR = widget.initialInnerRadius;
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    innerRAnim = Tween<double>(
        begin: innerR,
        end: widget.finalInnerRadius,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut))
      ..addListener(
        () => setState(() {
          innerR = innerRAnim.value;
        }),
      );
  }

  @override
  void didUpdateWidget(covariant LensLoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpening) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: OverflowBox(
        maxWidth: widget.size,
        maxHeight: widget.size,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: ClipOval(
            child: CustomPaint(
              painter: LensBladePainter(
                blades: 8,
                outerR: widget.size,
                innerR: innerR,
                skew: -3,
                color: Theme.of(context).colorScheme.primaryFixedDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LensBladePainter extends CustomPainter {
  final int blades;
  final double outerR, innerR, skew;
  final Color color;

  LensBladePainter({
    required this.innerR,
    required this.outerR,
    this.skew = 0,
    this.blades = 6,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    canvas.translate(cx, cy);

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    final bladeAngle = 2 * math.pi / blades;
    final half = bladeAngle / 2;

    for (var i = 0; i < blades; i++) {
      final angle = i * bladeAngle;
      final p1 = Offset(
        outerR * math.cos(angle - half),
        outerR * math.sin(angle - half),
      );
      final p2 = Offset(
        outerR * math.cos(angle + half),
        outerR * math.sin(angle + half),
      );
      final tip = Offset(
        innerR * math.cos(angle + skew * half),
        innerR * math.sin(angle + skew * half),
      );
      final path =
          Path()
            ..moveTo(p1.dx, p1.dy)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(p2.dx, p2.dy)
            ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant LensBladePainter old) {
    return old.innerR != innerR;
  }
}
