import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';

/// Friendly original bear-cub mascot ("Pip") with gentle breathing, blinking,
/// and cheerful waving animation on tap.
class MascotWidget extends StatefulWidget {
  const MascotWidget({
    super.key,
    this.size = 112,
    this.onTap,
  });

  final double size;
  final VoidCallback? onTap;

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _idleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _waveController.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      label: 'Friendly bear mascot. Tap to say hello.',
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_idleController, _waveController]),
          builder: (context, _) {
            final bob = math.sin(_idleController.value * math.pi) * 3.5;
            final waveAngle = math.sin(_waveController.value * math.pi * 3) *
                (1 - _waveController.value * 0.3) *
                0.45;
            final bounceScale =
                1.0 + math.sin(_waveController.value * math.pi) * 0.06;

            return Transform.translate(
              offset: Offset(0, -bob),
              child: Transform.scale(
                scale: bounceScale,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CustomPaint(
                    painter: _BearMascotPainter(
                      waveAngle: waveAngle,
                      isBlinking: _idleController.value > 0.94,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BearMascotPainter extends CustomPainter {
  _BearMascotPainter({
    required this.waveAngle,
    required this.isBlinking,
  });

  final double waveAngle;
  final bool isBlinking;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final furPaint = Paint()..color = const Color(0xFFF3B882);
    final innerEarPaint = Paint()..color = const Color(0xFFFFD8BA);
    final bellyPaint = Paint()..color = const Color(0xFFFFEBD6);
    final scarfPaint = Paint()..color = AppTheme.skyAccent;
    final outlinePaint = Paint()
      ..color = const Color(0xFF8C5D3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Ears
    final leftEar = Offset(cx - w * 0.24, h * 0.21);
    final rightEar = Offset(cx + w * 0.24, h * 0.21);
    for (final center in [leftEar, rightEar]) {
      canvas.drawCircle(center, w * 0.11, furPaint);
      canvas.drawCircle(center, w * 0.11, outlinePaint);
      canvas.drawCircle(center, w * 0.06, innerEarPaint);
    }

    // Waving right paw (viewer's left)
    canvas.save();
    canvas.translate(cx - w * 0.26, h * 0.62);
    canvas.rotate(-0.4 + waveAngle);
    final leftArm = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(-w * 0.08, -h * 0.04), width: w * 0.16, height: h * 0.24),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(leftArm, furPaint);
    canvas.drawRRect(leftArm, outlinePaint);
    canvas.restore();

    // Resting right arm
    canvas.save();
    canvas.translate(cx + w * 0.27, h * 0.66);
    canvas.rotate(0.28);
    final rightArm = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.15, height: h * 0.22),
      Radius.circular(w * 0.075),
    );
    canvas.drawRRect(rightArm, furPaint);
    canvas.drawRRect(rightArm, outlinePaint);
    canvas.restore();

    // Body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.71), width: w * 0.46, height: h * 0.36),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(bodyRect, furPaint);
    canvas.drawRRect(bodyRect, outlinePaint);

    // Belly patch
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.73), width: w * 0.28, height: h * 0.23),
      bellyPaint,
    );

    // Cozy pastel scarf
    final scarfRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.56), width: w * 0.36, height: h * 0.09),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(scarfRect, scarfPaint);
    canvas.drawRRect(scarfRect, outlinePaint);

    // Head
    final headRect = Rect.fromCenter(
      center: Offset(cx, h * 0.36),
      width: w * 0.54,
      height: h * 0.44,
    );
    canvas.drawOval(headRect, furPaint);
    canvas.drawOval(headRect, outlinePaint);

    // Muzzle
    final muzzleRect = Rect.fromCenter(
      center: Offset(cx, h * 0.42),
      width: w * 0.25,
      height: h * 0.17,
    );
    canvas.drawOval(muzzleRect, bellyPaint);

    // Rosy cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFF9E9E).withValues(alpha: 0.55);
    canvas.drawCircle(Offset(cx - w * 0.16, h * 0.40), w * 0.048, cheekPaint);
    canvas.drawCircle(Offset(cx + w * 0.16, h * 0.40), w * 0.048, cheekPaint);

    // Eyes
    final eyePaint = Paint()
      ..color = AppTheme.inkText
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.024
      ..strokeCap = StrokeCap.round;
    final eyeFill = Paint()..color = AppTheme.inkText;
    final sparkle = Paint()..color = Colors.white;

    for (final dx in [-w * 0.10, w * 0.10]) {
      final eyeCenter = Offset(cx + dx, h * 0.33);
      if (isBlinking) {
        canvas.drawArc(
          Rect.fromCenter(center: eyeCenter, width: w * 0.06, height: h * 0.03),
          0,
          math.pi,
          false,
          eyePaint,
        );
      } else {
        canvas.drawCircle(eyeCenter, w * 0.029, eyeFill);
        canvas.drawCircle(
          eyeCenter + Offset(-w * 0.008, -h * 0.008),
          w * 0.01,
          sparkle,
        );
      }
    }

    // Nose & gentle smile
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.39), width: w * 0.075, height: h * 0.05),
      Paint()..color = const Color(0xFF6A412A),
    );
    final smilePath = Path()
      ..moveTo(cx - w * 0.05, h * 0.44)
      ..quadraticBezierTo(cx, h * 0.48, cx + w * 0.05, h * 0.44);
    canvas.drawPath(
      smilePath,
      Paint()
        ..color = const Color(0xFF6A412A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_BearMascotPainter oldDelegate) =>
      oldDelegate.waveAngle != waveAngle || oldDelegate.isBlinking != isBlinking;
}
