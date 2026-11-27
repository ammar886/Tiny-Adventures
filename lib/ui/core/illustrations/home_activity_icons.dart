import 'package:flutter/material.dart';

/// Illustrated badges for the three home-screen activities so a 2-year-old
/// recognizes each activity visually without needing to read.
enum HomeActivityBadgeKind {
  animals,
  colors,
  moveAndFind,
}

class HomeActivityBadge extends StatelessWidget {
  const HomeActivityBadge({
    super.key,
    required this.kind,
    this.size = 78,
  });

  final HomeActivityBadgeKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HomeActivityBadgePainter(kind),
      ),
    );
  }
}

class _HomeActivityBadgePainter extends CustomPainter {
  _HomeActivityBadgePainter(this.kind);

  final HomeActivityBadgeKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    switch (kind) {
      case HomeActivityBadgeKind.animals:
        _paintAnimalBadge(canvas, size);
      case HomeActivityBadgeKind.colors:
        _paintColorsBadge(canvas, size);
      case HomeActivityBadgeKind.moveAndFind:
        _paintMoveBadge(canvas, size);
    }
  }

  void _paintAnimalBadge(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pawPaint = Paint()..color = const Color(0xFFCE7D4C);
    final highlight = Paint()..color = const Color(0xFFFFEFE3);

    // Main paw pad
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.62), width: w * 0.48, height: h * 0.36),
      pawPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.64), width: w * 0.24, height: h * 0.16),
      highlight,
    );
    // Four toe pads
    final toes = [
      Offset(w * 0.24, h * 0.37),
      Offset(w * 0.41, h * 0.27),
      Offset(w * 0.59, h * 0.27),
      Offset(w * 0.76, h * 0.37),
    ];
    for (final toe in toes) {
      canvas.drawCircle(toe, w * 0.09, pawPaint);
    }
  }

  void _paintColorsBadge(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04;

    final circles = [
      (Offset(w * 0.34, h * 0.40), const Color(0xFFEE6B6E)),
      (Offset(w * 0.66, h * 0.40), const Color(0xFFFFC94D)),
      (Offset(w * 0.50, h * 0.66), const Color(0xFF5DA9E9)),
    ];
    for (final (center, color) in circles) {
      canvas.drawCircle(center, w * 0.21, Paint()..color = color);
      canvas.drawCircle(center, w * 0.21, border);
    }
  }

  void _paintMoveBadge(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyPaint = Paint()..color = const Color(0xFF4CA45A);
    final starPaint = Paint()..color = const Color(0xFFFFD54F);

    // Cheerful jumping figure silhouette
    canvas.drawCircle(Offset(w * 0.5, h * 0.28), w * 0.12, bodyPaint);

    final limbPaint = Paint()
      ..color = const Color(0xFF4CA45A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.11
      ..strokeCap = StrokeCap.round;

    // Torso
    canvas.drawLine(
      Offset(w * 0.5, h * 0.40),
      Offset(w * 0.5, h * 0.62),
      limbPaint,
    );
    // Raised arms
    canvas.drawLine(
      Offset(w * 0.5, h * 0.46),
      Offset(w * 0.24, h * 0.30),
      limbPaint,
    );
    canvas.drawLine(
      Offset(w * 0.5, h * 0.46),
      Offset(w * 0.76, h * 0.30),
      limbPaint,
    );
    // Hopping legs
    canvas.drawLine(
      Offset(w * 0.5, h * 0.62),
      Offset(w * 0.32, h * 0.80),
      limbPaint,
    );
    canvas.drawLine(
      Offset(w * 0.5, h * 0.62),
      Offset(w * 0.68, h * 0.80),
      limbPaint,
    );

    // Little sparkle dots
    canvas.drawCircle(Offset(w * 0.20, h * 0.18), w * 0.05, starPaint);
    canvas.drawCircle(Offset(w * 0.82, h * 0.20), w * 0.045, starPaint);
  }

  @override
  bool shouldRepaint(_HomeActivityBadgePainter oldDelegate) =>
      oldDelegate.kind != kind;
}
