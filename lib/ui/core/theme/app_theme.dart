import 'package:flutter/material.dart';

/// Soft pastel picture-book theme designed for toddlers and calm parent oversight.
class AppTheme {
  AppTheme._();

  // Core pastel palette
  static const Color creamBackground = Color(0xFFFFFAF2);
  static const Color warmSurface = Color(0xFFFFFFFF);
  static const Color softSand = Color(0xFFF6EFE2);
  static const Color inkText = Color(0xFF3A3546);
  static const Color mutedText = Color(0xFF6B6578);

  // Activity & accent pastels
  static const Color peachCard = Color(0xFFFFDFC8);
  static const Color peachAccent = Color(0xFFE98A56);
  static const Color skyCard = Color(0xFFCDE8FF);
  static const Color skyAccent = Color(0xFF5B9FD6);
  static const Color sageCard = Color(0xFFD5F0C8);
  static const Color sageAccent = Color(0xFF5FA667);
  static const Color buttercupCard = Color(0xFFFFEBB0);
  static const Color buttercupAccent = Color(0xFFD99B26);
  static const Color lavenderCard = Color(0xFFE7DCF7);
  static const Color lavenderAccent = Color(0xFF8B6EC2);

  static const double minToddlerTouchTarget = 72.0;
  static const double cardRadius = 28.0;

  static ThemeData buildTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: creamBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: skyAccent,
        surface: warmSurface,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: inkText,
          letterSpacing: -0.3,
          height: 1.2,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: inkText,
          height: 1.25,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: inkText,
          height: 1.25,
        ),
        bodyLarge: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: inkText,
          height: 1.4,
        ),
        bodyMedium: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: mutedText,
          height: 1.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: warmSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: inkText,
          backgroundColor: buttercupCard,
          minimumSize: const Size(120, 64),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
