import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tiny_adventures/domain/models/move_prompt.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';

/// Smooth, calming character animation demonstrating each Move & Find prompt.
class AnimatedMoveCharacter extends StatefulWidget {
  const AnimatedMoveCharacter({
    super.key,
    required this.action,
    this.size = 190,
    this.onTap,
  });

  final MoveAction action;
  final double size;
  final VoidCallback? onTap;

  @override
  State<AnimatedMoveCharacter> createState() => _AnimatedMoveCharacterState();
}

class _AnimatedMoveCharacterState extends State<AnimatedMoveCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _MoveCharacterPainter(
                action: widget.action,
                t: _controller.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MoveCharacterPainter extends CustomPainter {
  _MoveCharacterPainter({
    required this.action,
    required this.t,
  });

  final MoveAction action;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    switch (action) {
      case MoveAction.clapHands:
        _paintBearAction(canvas, size, MoveAction.clapHands);
      case MoveAction.jumpFrog:
        _paintFrogJump(canvas, size);
      case MoveAction.findBlue:
        _paintFindBlue(canvas, size);
      case MoveAction.waveHello:
        _paintBearAction(canvas, size, MoveAction.waveHello);
      case MoveAction.touchNose:
        _paintBearAction(canvas, size, MoveAction.touchNose);
    }
  }

  void _paintBearBase(
    Canvas canvas,
    Size size, {
    double yOffset = 0,
    required Paint stroke,
  }) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final fur = Paint()..color = const Color(0xFFF3B882);
    final belly = Paint()..color = const Color(0xFFFFEBD6);
    final innerEar = Paint()..color = const Color(0xFFFFD8BA);

    canvas.save();
    canvas.translate(0, yOffset);

    // Ears
    for (final dir in [-1.0, 1.0]) {
      final ear = Offset(cx + dir * w * 0.16, h * 0.20);
      canvas.drawCircle(ear, w * 0.08, fur);
      canvas.drawCircle(ear, w * 0.08, stroke);
      canvas.drawCircle(ear, w * 0.045, innerEar);
    }

    // Body
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.67), width: w * 0.36, height: h * 0.34),
      Radius.circular(w * 0.17),
    );
    canvas.drawRRect(body, fur);
    canvas.drawRRect(body, stroke);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.69), width: w * 0.22, height: h * 0.22),
      belly,
    );

    // Head
    final head = Rect.fromCenter(center: Offset(cx, h * 0.35), width: w * 0.38, height: h * 0.32);
    canvas.drawOval(head, fur);
    canvas.drawOval(head, stroke);

    // Muzzle & face
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.40), width: w * 0.18, height: h * 0.13),
      belly,
    );
    final eye = Paint()..color = AppTheme.inkText;
    canvas.drawCircle(Offset(cx - w * 0.075, h * 0.32), w * 0.022, eye);
    canvas.drawCircle(Offset(cx + w * 0.075, h * 0.32), w * 0.022, eye);

    // Nose
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.37), width: w * 0.055, height: h * 0.036),
      Paint()..color = const Color(0xFF6A412A),
    );

    canvas.restore();
  }

  void _paintBearAction(Canvas canvas, Size size, MoveAction bearAction) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final fur = Paint()..color = const Color(0xFFF3B882);
    final stroke = Paint()
      ..color = const Color(0xFF8C5D3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round;

    final bob = math.sin(t * math.pi * 2) * h * 0.015;
    _paintBearBase(canvas, size, yOffset: bob, stroke: stroke);

    if (bearAction == MoveAction.clapHands) {
      final clapProgress = (math.sin(t * math.pi * 2) + 1) * 0.5;
      final spread = w * (0.045 + 0.12 * clapProgress);
      for (final dir in [-1.0, 1.0]) {
        final handCenter = Offset(cx + dir * spread, h * 0.62 + bob);
        final paw = RRect.fromRectAndRadius(
          Rect.fromCenter(center: handCenter, width: w * 0.11, height: h * 0.11),
          Radius.circular(w * 0.055),
        );
        canvas.drawRRect(paw, fur);
        canvas.drawRRect(paw, stroke);
      }
      if (clapProgress < 0.25) {
        final spark = Paint()
          ..color = AppTheme.buttercupAccent
          ..strokeWidth = w * 0.016
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(cx, h * 0.52), Offset(cx, h * 0.47), spark);
        canvas.drawLine(Offset(cx - w * 0.05, h * 0.54), Offset(cx - w * 0.09, h * 0.50), spark);
        canvas.drawLine(Offset(cx + w * 0.05, h * 0.54), Offset(cx + w * 0.09, h * 0.50), spark);
      }
    } else if (bearAction == MoveAction.waveHello) {
      final wave = math.sin(t * math.pi * 4) * 0.35;
      // Resting left arm
      final leftArm = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - w * 0.22, h * 0.65 + bob), width: w * 0.11, height: h * 0.16),
        Radius.circular(w * 0.055),
      );
      canvas.drawRRect(leftArm, fur);
      canvas.drawRRect(leftArm, stroke);

      // Waving right arm
      canvas.save();
      canvas.translate(cx + w * 0.20, h * 0.56 + bob);
      canvas.rotate(-0.6 + wave);
      final rightArm = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.05, -h * 0.08), width: w * 0.11, height: h * 0.20),
        Radius.circular(w * 0.055),
      );
      canvas.drawRRect(rightArm, fur);
      canvas.drawRRect(rightArm, stroke);
      canvas.restore();
    } else if (bearAction == MoveAction.touchNose) {
      final reach = (math.sin(t * math.pi * 2) + 1) * 0.5;
      final pawX = cx + w * (0.20 - 0.16 * reach);
      final pawY = h * (0.64 - 0.24 * reach) + bob;

      final leftArm = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - w * 0.22, h * 0.65 + bob), width: w * 0.11, height: h * 0.16),
        Radius.circular(w * 0.055),
      );
      canvas.drawRRect(leftArm, fur);
      canvas.drawRRect(leftArm, stroke);

      final reachingArm = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(pawX, pawY), width: w * 0.11, height: h * 0.13),
        Radius.circular(w * 0.055),
      );
      canvas.drawRRect(reachingArm, fur);
      canvas.drawRRect(reachingArm, stroke);

      if (reach > 0.78) {
        canvas.drawCircle(
          Offset(cx, h * 0.37 + bob),
          w * 0.06,
          Paint()
            ..color = AppTheme.buttercupAccent.withValues(alpha: 0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.018,
        );
      }
    }
  }

  void _paintFrogJump(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final hop = math.max(0.0, math.sin(t * math.pi * 2)) * h * 0.17;
    final green = Paint()..color = const Color(0xFF7AD07D);
    final belly = Paint()..color = const Color(0xFFDDF7D6);
    final pad = Paint()..color = const Color(0xFF9EDB94);
    final stroke = Paint()
      ..color = const Color(0xFF3F7D43)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round;

    // Lily pad shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.84), width: w * 0.58, height: h * 0.14),
      pad,
    );

    canvas.save();
    canvas.translate(0, -hop);

    // Frog legs
    for (final dir in [-1.0, 1.0]) {
      final leg = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + dir * w * 0.21, h * 0.70), width: w * 0.14, height: h * 0.18),
        Radius.circular(w * 0.07),
      );
      canvas.drawRRect(leg, green);
      canvas.drawRRect(leg, stroke);
    }

    // Body
    final body = Rect.fromCenter(center: Offset(cx, h * 0.58), width: w * 0.44, height: h * 0.34);
    canvas.drawOval(body, green);
    canvas.drawOval(body, stroke);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.62), width: w * 0.26, height: h * 0.20),
      belly,
    );

    // Big frog eyes
    for (final dir in [-1.0, 1.0]) {
      final eyeCenter = Offset(cx + dir * w * 0.12, h * 0.39);
      canvas.drawCircle(eyeCenter, w * 0.085, green);
      canvas.drawCircle(eyeCenter, w * 0.085, stroke);
      canvas.drawCircle(eyeCenter, w * 0.055, Paint()..color = Colors.white);
      canvas.drawCircle(eyeCenter, w * 0.028, Paint()..color = AppTheme.inkText);
    }

    // Smile
    final smile = Path()
      ..moveTo(cx - w * 0.10, h * 0.54)
      ..quadraticBezierTo(cx, h * 0.61, cx + w * 0.10, h * 0.54);
    canvas.drawPath(smile, stroke);
    canvas.restore();
  }

  void _paintFindBlue(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final stroke = Paint()
      ..color = const Color(0xFF8C5D3B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round;

    final sweep = math.sin(t * math.pi * 2) * 0.14;
    _paintBearBase(canvas, size, stroke: stroke);

    // Blue star/toy object nearby
    final blueBall = Offset(cx + w * 0.26, h * 0.68);
    canvas.drawCircle(blueBall, w * 0.11, Paint()..color = const Color(0xFF4D96E8));
    canvas.drawCircle(
      blueBall,
      w * 0.11,
      Paint()
        ..color = const Color(0xFF2D65A8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.018,
    );

    // Magnifying glass moving gently
    canvas.save();
    canvas.translate(cx + w * 0.12, h * 0.54);
    canvas.rotate(sweep);
    canvas.drawLine(
      Offset(0, 0),
      Offset(w * 0.11, h * 0.11),
      Paint()
        ..color = const Color(0xFF7B5434)
        ..strokeWidth = w * 0.036
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(w * 0.14, h * 0.14),
      w * 0.095,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      Offset(w * 0.14, h * 0.14),
      w * 0.095,
      Paint()
        ..color = AppTheme.inkText
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MoveCharacterPainter oldDelegate) =>
      oldDelegate.action != action || oldDelegate.t != t;
}
