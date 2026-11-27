import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tiny_adventures/domain/models/animal_item.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';

/// Animated picture-book illustration for each animal in Animal Sounds.
class AnimatedAnimalIllustration extends StatefulWidget {
  const AnimatedAnimalIllustration({
    super.key,
    required this.animalId,
    required this.pulseTrigger,
    this.size = 96,
  });

  final AnimalId animalId;

  /// Incrementing value triggers a gentle bounce/wiggle animation.
  final int pulseTrigger;
  final double size;

  @override
  State<AnimatedAnimalIllustration> createState() =>
      _AnimatedAnimalIllustrationState();
}

class _AnimatedAnimalIllustrationState extends State<AnimatedAnimalIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedAnimalIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulseTrigger != oldWidget.pulseTrigger &&
        widget.pulseTrigger > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final bounce = 1.0 + math.sin(t * math.pi) * 0.12;
        final wiggle = math.sin(t * math.pi * 2) * (1 - t) * 0.09;

        return Transform.scale(
          scale: bounce,
          child: Transform.rotate(
            angle: wiggle,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _AnimalPainter(
                  animalId: widget.animalId,
                  progress: t,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimalPainter extends CustomPainter {
  _AnimalPainter({
    required this.animalId,
    required this.progress,
  });

  final AnimalId animalId;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    switch (animalId) {
      case AnimalId.dog:
        _paintDog(canvas, size);
      case AnimalId.cat:
        _paintCat(canvas, size);
      case AnimalId.cow:
        _paintCow(canvas, size);
      case AnimalId.duck:
        _paintDuck(canvas, size);
      case AnimalId.lion:
        _paintLion(canvas, size);
      case AnimalId.elephant:
        _paintElephant(canvas, size);
    }
  }

  Paint _stroke(double w, [Color color = const Color(0xFF6B5344)]) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = w * 0.026
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _drawEyesAndCheeks(Canvas canvas, Size size, double eyeY, double spread) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final eyePaint = Paint()..color = AppTheme.inkText;
    final sparkle = Paint()..color = Colors.white;
    final cheek = Paint()..color = const Color(0xFFFF9B9B).withValues(alpha: 0.5);

    for (final dir in [-1.0, 1.0]) {
      final ex = cx + dir * w * spread;
      canvas.drawCircle(Offset(ex, h * eyeY), w * 0.036, eyePaint);
      canvas.drawCircle(
        Offset(ex - w * 0.01, h * eyeY - h * 0.01),
        w * 0.012,
        sparkle,
      );
      canvas.drawCircle(
        Offset(cx + dir * w * (spread + 0.08), h * (eyeY + 0.09)),
        w * 0.048,
        cheek,
      );
    }
  }

  void _paintDog(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final fur = Paint()..color = const Color(0xFFE9B178);
    final earColor = Paint()..color = const Color(0xFFB57242);
    final muzzle = Paint()..color = const Color(0xFFFFECD9);
    final stroke = _stroke(w);

    // Floppy ears
    final earLift = math.sin(progress * math.pi * 2) * 0.12;
    for (final dir in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(cx + dir * w * 0.25, h * 0.34);
      canvas.rotate(dir * (0.28 - earLift));
      final ear = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, h * 0.12), width: w * 0.17, height: h * 0.34),
        Radius.circular(w * 0.08),
      );
      canvas.drawRRect(ear, earColor);
      canvas.drawRRect(ear, stroke);
      canvas.restore();
    }

    // Head
    final head = Rect.fromCenter(center: Offset(cx, h * 0.48), width: w * 0.56, height: h * 0.52);
    canvas.drawOval(head, fur);
    canvas.drawOval(head, stroke);

    // Muzzle
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.58), width: w * 0.32, height: h * 0.22),
      muzzle,
    );

    _drawEyesAndCheeks(canvas, size, 0.43, 0.12);

    // Nose & happy tongue
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.53), width: w * 0.11, height: h * 0.075),
      Paint()..color = AppTheme.inkText,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.65), width: w * 0.08, height: h * 0.09),
      Paint()..color = const Color(0xFFF2858E),
    );
  }

  void _paintCat(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final fur = Paint()..color = const Color(0xFFF7C99E);
    final innerEar = Paint()..color = const Color(0xFFFFB2C1);
    final stroke = _stroke(w);

    // Pointed ears
    for (final dir in [-1.0, 1.0]) {
      final ear = Path()
        ..moveTo(cx + dir * w * 0.09, h * 0.30)
        ..lineTo(cx + dir * w * 0.28, h * 0.15)
        ..lineTo(cx + dir * w * 0.29, h * 0.42)
        ..close();
      canvas.drawPath(ear, fur);
      canvas.drawPath(ear, stroke);

      final inner = Path()
        ..moveTo(cx + dir * w * 0.13, h * 0.30)
        ..lineTo(cx + dir * w * 0.25, h * 0.20)
        ..lineTo(cx + dir * w * 0.25, h * 0.38)
        ..close();
      canvas.drawPath(inner, innerEar);
    }

    // Head
    final head = Rect.fromCenter(center: Offset(cx, h * 0.54), width: w * 0.60, height: h * 0.50);
    canvas.drawOval(head, fur);
    canvas.drawOval(head, stroke);

    _drawEyesAndCheeks(canvas, size, 0.49, 0.13);

    // Whiskers
    final whisker = _stroke(w * 0.75, const Color(0xFF7D6557));
    for (final dir in [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(cx + dir * w * 0.16, h * 0.57),
        Offset(cx + dir * w * 0.35, h * 0.54),
        whisker,
      );
      canvas.drawLine(
        Offset(cx + dir * w * 0.16, h * 0.62),
        Offset(cx + dir * w * 0.35, h * 0.64),
        whisker,
      );
    }

    // Triangle nose
    final nose = Path()
      ..moveTo(cx - w * 0.045, h * 0.55)
      ..lineTo(cx + w * 0.045, h * 0.55)
      ..lineTo(cx, h * 0.60)
      ..close();
    canvas.drawPath(nose, Paint()..color = const Color(0xFFEA7D92));
  }

  void _paintCow(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final body = Paint()..color = const Color(0xFFFFFBF4);
    final spot = Paint()..color = const Color(0xFF6B5344);
    final horn = Paint()..color = const Color(0xFFE7CA94);
    final snout = Paint()..color = const Color(0xFFFFC8D2);
    final stroke = _stroke(w);

    // Horns & ears
    for (final dir in [-1.0, 1.0]) {
      final hRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + dir * w * 0.18, h * 0.24), width: w * 0.09, height: h * 0.15),
        Radius.circular(w * 0.045),
      );
      canvas.drawRRect(hRect, horn);
      canvas.drawRRect(hRect, stroke);

      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + dir * w * 0.31, h * 0.36), width: w * 0.18, height: h * 0.11),
        spot,
      );
    }

    // Head
    final head = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.48), width: w * 0.56, height: h * 0.50),
      Radius.circular(w * 0.24),
    );
    canvas.drawRRect(head, body);
    // Spot
    canvas.drawCircle(Offset(cx - w * 0.14, h * 0.36), w * 0.09, spot);
    canvas.drawRRect(head, stroke);

    _drawEyesAndCheeks(canvas, size, 0.42, 0.12);

    // Big pink snout
    final snoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.63), width: w * 0.44, height: h * 0.24),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(snoutRect, snout);
    canvas.drawRRect(snoutRect, stroke);

    final nostril = Paint()..color = const Color(0xFFAD6C78);
    canvas.drawCircle(Offset(cx - w * 0.08, h * 0.61), w * 0.025, nostril);
    canvas.drawCircle(Offset(cx + w * 0.08, h * 0.61), w * 0.025, nostril);
  }

  void _paintDuck(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final feather = Paint()..color = const Color(0xFFFFDF6B);
    final wingColor = Paint()..color = const Color(0xFFF7C948);
    final billColor = Paint()..color = const Color(0xFFF38D43);
    final stroke = _stroke(w, const Color(0xFF9C7228));

    // Body
    final body = Rect.fromCenter(center: Offset(cx, h * 0.64), width: w * 0.50, height: h * 0.36);
    canvas.drawOval(body, feather);
    canvas.drawOval(body, stroke);

    // Flapping wing
    final flap = math.sin(progress * math.pi * 2) * 0.25;
    canvas.save();
    canvas.translate(cx - w * 0.12, h * 0.62);
    canvas.rotate(-flap);
    final wing = Rect.fromCenter(center: Offset.zero, width: w * 0.24, height: h * 0.18);
    canvas.drawOval(wing, wingColor);
    canvas.drawOval(wing, stroke);
    canvas.restore();

    // Head
    final head = Offset(cx + w * 0.04, h * 0.36);
    canvas.drawCircle(head, w * 0.21, feather);
    canvas.drawCircle(head, w * 0.21, stroke);

    // Bill
    final bill = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + w * 0.24, h * 0.41), width: w * 0.22, height: h * 0.11),
      Radius.circular(w * 0.055),
    );
    canvas.drawRRect(bill, billColor);
    canvas.drawRRect(bill, stroke);

    // Eye
    canvas.drawCircle(Offset(cx + w * 0.07, h * 0.33), w * 0.032, Paint()..color = AppTheme.inkText);
    canvas.drawCircle(Offset(cx + w * 0.06, h * 0.32), w * 0.011, Paint()..color = Colors.white);
  }

  void _paintLion(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.50;
    final mane = Paint()..color = const Color(0xFFD98236);
    final face = Paint()..color = const Color(0xFFF6C677);
    final muzzle = Paint()..color = const Color(0xFFFFECC4);
    final stroke = _stroke(w, const Color(0xFF8C5324));

    // Scalloped mane
    for (var i = 0; i < 10; i++) {
      final angle = (i / 10) * math.pi * 2 + progress * 0.2;
      final mx = cx + math.cos(angle) * w * 0.26;
      final my = cy + math.sin(angle) * h * 0.26;
      canvas.drawCircle(Offset(mx, my), w * 0.11, mane);
    }
    canvas.drawCircle(Offset(cx, cy), w * 0.26, face);
    canvas.drawCircle(Offset(cx, cy), w * 0.26, stroke);

    // Muzzle
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.58), width: w * 0.25, height: h * 0.16),
      muzzle,
    );

    _drawEyesAndCheeks(canvas, size, 0.45, 0.10);

    // Nose
    final nose = Path()
      ..moveTo(cx - w * 0.045, h * 0.52)
      ..lineTo(cx + w * 0.045, h * 0.52)
      ..lineTo(cx, h * 0.57)
      ..close();
    canvas.drawPath(nose, Paint()..color = const Color(0xFF7D4520));
  }

  void _paintElephant(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final skin = Paint()..color = const Color(0xFF9AC8EB);
    final earInner = Paint()..color = const Color(0xFFF4BAC8);
    final stroke = _stroke(w, const Color(0xFF4C7699));

    // Big flapping ears
    final earWiggle = math.sin(progress * math.pi * 2) * 0.08;
    for (final dir in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(cx + dir * w * 0.22, h * 0.44);
      canvas.rotate(dir * earWiggle);
      final ear = Rect.fromCenter(center: Offset(dir * w * 0.08, 0), width: w * 0.28, height: h * 0.40);
      canvas.drawOval(ear, skin);
      canvas.drawOval(ear, stroke);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(dir * w * 0.08, 0), width: w * 0.16, height: h * 0.25),
        earInner,
      );
      canvas.restore();
    }

    // Head
    final head = Offset(cx, h * 0.46);
    canvas.drawCircle(head, w * 0.25, skin);
    canvas.drawCircle(head, w * 0.25, stroke);

    _drawEyesAndCheeks(canvas, size, 0.40, 0.10);

    // Trunk
    final trunkLift = math.sin(progress * math.pi) * h * 0.07;
    final trunk = Path()
      ..moveTo(cx - w * 0.04, h * 0.50)
      ..quadraticBezierTo(cx - w * 0.03, h * 0.72 - trunkLift, cx + w * 0.09, h * 0.69 - trunkLift);
    canvas.drawPath(
      trunk,
      Paint()
        ..color = const Color(0xFF9AC8EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.11
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      trunk,
      Paint()
        ..color = const Color(0xFF4C7699)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.024
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_AnimalPainter oldDelegate) =>
      oldDelegate.animalId != animalId || oldDelegate.progress != progress;
}
