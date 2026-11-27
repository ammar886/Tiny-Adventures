import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tiny_adventures/domain/models/color_challenge.dart';

/// Custom-drawn picture-book illustrations for Color Matching objects.
class ColorObjectIllustration extends StatelessWidget {
  const ColorObjectIllustration({
    super.key,
    required this.item,
    this.size = 96,
  });

  final ColorObjectItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ColorObjectPainter(item),
      ),
    );
  }
}

class _ColorObjectPainter extends CustomPainter {
  _ColorObjectPainter(this.item);

  final ColorObjectItem item;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = item.displayColor;
    final outline = Paint()
      ..color = Color.lerp(item.displayColor, Colors.black, 0.28)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (item.id) {
      case 'apple':
        _paintApple(canvas, size, fill, outline);
      case 'heart':
        _paintHeart(canvas, size, fill, outline);
      case 'ball':
        _paintBall(canvas, size, fill, outline);
      case 'whale':
        _paintWhale(canvas, size, fill, outline);
      case 'sun':
        _paintSun(canvas, size, fill, outline);
      case 'star':
        _paintStar(canvas, size, fill, outline);
      case 'leaf':
        _paintLeaf(canvas, size, fill, outline);
      case 'pear':
        _paintPear(canvas, size, fill, outline);
      case 'carrot':
        _paintCarrot(canvas, size, fill, outline);
      case 'tangerine':
        _paintTangerine(canvas, size, fill, outline);
      case 'grapes':
        _paintGrapes(canvas, size, fill, outline);
      case 'butterfly':
        _paintButterfly(canvas, size, fill, outline);
      default:
        canvas.drawCircle(
          Offset(size.width * 0.5, size.height * 0.5),
          size.width * 0.35,
          fill,
        );
    }
  }

  void _paintApple(Canvas canvas, Size size, Paint fill, Paint outline) {
    final w = size.width;
    final h = size.height;
    final body = Path()
      ..moveTo(w * 0.50, h * 0.32)
      ..cubicTo(w * 0.20, h * 0.22, w * 0.14, h * 0.64, w * 0.36, h * 0.82)
      ..quadraticBezierTo(w * 0.50, h * 0.88, w * 0.64, h * 0.82)
      ..cubicTo(w * 0.86, h * 0.64, w * 0.80, h * 0.22, w * 0.50, h * 0.32);
    canvas.drawPath(body, fill);
    canvas.drawPath(body, outline);

    // Stem & tiny leaf
    canvas.drawLine(
      Offset(w * 0.50, h * 0.32),
      Offset(w * 0.53, h * 0.17),
      Paint()
        ..color = const Color(0xFF7B5434)
        ..strokeWidth = w * 0.05
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.61, h * 0.22), width: w * 0.16, height: h * 0.09),
      Paint()..color = const Color(0xFF68B66F),
    );
  }

  void _paintHeart(Canvas canvas, Size size, Paint fill, Paint outline) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.50, h * 0.82)
      ..cubicTo(w * 0.12, h * 0.58, w * 0.16, h * 0.22, w * 0.36, h * 0.24)
      ..quadraticBezierTo(w * 0.48, h * 0.26, w * 0.50, h * 0.36)
      ..quadraticBezierTo(w * 0.52, h * 0.26, w * 0.64, h * 0.24)
      ..cubicTo(w * 0.84, h * 0.22, w * 0.88, h * 0.58, w * 0.50, h * 0.82);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, outline);
  }

  void _paintBall(Canvas canvas, Size size, Paint fill, Paint outline) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);
    final r = w * 0.35;
    canvas.drawCircle(center, r, fill);

    final stripe = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.72),
      -math.pi * 0.75,
      math.pi * 0.55,
      false,
      stripe,
    );
    canvas.drawCircle(center, r, outline);
  }

  void _paintWhale(Canvas canvas, Size size, Paint fill, Paint outline) {
    final w = size.width;
    final h = size.height;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.45, h * 0.56), width: w * 0.60, height: h * 0.42),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, outline);

    // Tail
    final tail = Path()
      ..moveTo(w * 0.73, h * 0.58)
      ..lineTo(w * 0.88, h * 0.42)
      ..lineTo(w * 0.86, h * 0.62)
      ..close();
    canvas.drawPath(tail, fill);
    canvas.drawPath(tail, outline);

    // Friendly eye
    canvas.drawCircle(Offset(w * 0.30, h * 0.52), w * 0.036, Paint()..color = const Color(0xFF2B2D42));
  }

  void _paintSun(Canvas canvas, Size size, Paint fill, Paint outline) {
    final w = size.width;
    final h = size.height;
    final c = Offset(w * 0.5, h * 0.5);
    final rayPaint = Paint()
      ..color = item.displayColor
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        Offset(c.dx + math.cos(a) * w * 0.29, c.dy + math.sin(a) * h * 0.29),
        Offset(c.dx + math.cos(a) * w * 0.41, c.dy + math.sin(a) * h * 0.41),
        rayPaint,
      );
    }
    canvas.drawCircle(c, w * 0.24, fill);
    canvas.drawCircle(c, w * 0.24, outline);
  }

  void _paintStar(Canvas canvas, Size size, Paint fill, Paint outline) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.52;
    final outer = w * 0.38;
    final inner = w * 0.17;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final pt = Offset(cx + math.cos(angle) * r, cy + math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, outline);
  }

  void _paintLeaf(Canvas canvas, Size size, Paint fill, Paint outline) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.22, h * 0.72)
      ..quadraticBezierTo(w * 0.24, h * 0.22, w * 0.78, h * 0.24)
      ..quadraticBezierTo(w * 0.76, h * 0.74, w * 0.22, h * 0.72);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, outline);
    canvas.drawLine(
      Offset(w * 0.20, h * 0.76),
      Offset(w * 0.68, h * 0.32),
      outline,
    );
  }

  void _paintPear(Canvas canvas, Size size, Paint fill, Paint outline) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.50, h * 0.24)
      ..cubicTo(w * 0.34, h * 0.24, w * 0.36, h * 0.44, w * 0.26, h * 0.58)
      ..cubicTo(w * 0.18, h * 0.74, w * 0.32, h * 0.86, w * 0.50, h * 0.86)
      ..cubicTo(w * 0.68, h * 0.86, w * 0.82, h * 0.74, w * 0.74, h * 0.58)
      ..cubicTo(w * 0.64, h * 0.44, w * 0.66, h * 0.24, w * 0.50, h * 0.24);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, outline);
    canvas.drawLine(
      Offset(w * 0.50, h * 0.24),
      Offset(w * 0.52, h * 0.14),
      Paint()
        ..color = const Color(0xFF7B5434)
        ..strokeWidth = w * 0.045
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintCarrot(Canvas canvas, Size size, Paint fill, Paint outline) {
    final w = size.width;
    final h = size.height;
    final greens = Paint()
      ..color = const Color(0xFF5FB46A)
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.50, h * 0.28), Offset(w * 0.40, h * 0.14), greens);
    canvas.drawLine(Offset(w * 0.50, h * 0.28), Offset(w * 0.50, h * 0.11), greens);
    canvas.drawLine(Offset(w * 0.50, h * 0.28), Offset(w * 0.60, h * 0.14), greens);

    final body = Path()
      ..moveTo(w * 0.32, h * 0.30)
      ..quadraticBezierTo(w * 0.50, h * 0.24, w * 0.68, h * 0.30)
      ..quadraticBezierTo(w * 0.62, h * 0.72, w * 0.50, h * 0.88)
      ..quadraticBezierTo(w * 0.38, h * 0.72, w * 0.32, h * 0.30);
    canvas.drawPath(body, fill);
    canvas.drawPath(body, outline);
  }

  void _paintTangerine(Canvas canvas, Size size, Paint fill, Paint outline) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.55);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.66, height: h * 0.58),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w * 0.66, height: h * 0.58),
      outline,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.57, h * 0.23), width: w * 0.18, height: h * 0.10),
      Paint()..color = const Color(0xFF5FB46A),
    );
  }

  void _paintGrapes(Canvas canvas, Size size, Paint fill, Paint outline) {
    final w = size.width;
    final h = size.height;
    canvas.drawLine(
      Offset(w * 0.50, h * 0.28),
      Offset(w * 0.53, h * 0.16),
      Paint()
        ..color = const Color(0xFF7B5434)
        ..strokeWidth = w * 0.045
        ..strokeCap = StrokeCap.round,
    );
    final berries = [
      Offset(w * 0.38, h * 0.38),
      Offset(w * 0.50, h * 0.36),
      Offset(w * 0.62, h * 0.38),
      Offset(w * 0.43, h * 0.53),
      Offset(w * 0.57, h * 0.53),
      Offset(w * 0.50, h * 0.69),
    ];
    for (final pt in berries) {
      canvas.drawCircle(pt, w * 0.115, fill);
      canvas.drawCircle(pt, w * 0.115, outline);
    }
  }

  void _paintButterfly(Canvas canvas, Size size, Paint fill, Paint outline) {
    final w = size.width;
    final h = size.height;
    final wings = [
      Rect.fromCenter(center: Offset(w * 0.33, h * 0.40), width: w * 0.28, height: h * 0.28),
      Rect.fromCenter(center: Offset(w * 0.67, h * 0.40), width: w * 0.28, height: h * 0.28),
      Rect.fromCenter(center: Offset(w * 0.36, h * 0.64), width: w * 0.22, height: h * 0.22),
      Rect.fromCenter(center: Offset(w * 0.64, h * 0.64), width: w * 0.22, height: h * 0.22),
    ];
    for (final wing in wings) {
      canvas.drawOval(wing, fill);
      canvas.drawOval(wing, outline);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.50, h * 0.54), width: w * 0.10, height: h * 0.46),
        Radius.circular(w * 0.05),
      ),
      Paint()..color = const Color(0xFF51416B),
    );
  }

  @override
  bool shouldRepaint(_ColorObjectPainter oldDelegate) =>
      oldDelegate.item != item;
}
