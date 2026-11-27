import 'package:flutter/material.dart';

/// Six core colors taught in the Color Matching activity.
enum LearningColor {
  red,
  blue,
  yellow,
  green,
  orange,
  purple,
}

/// An illustrated everyday object used as a color matching choice.
@immutable
class ColorObjectItem {
  const ColorObjectItem({
    required this.id,
    required this.name,
    required this.color,
    required this.displayColor,
    required this.spokenPhrase,
  });

  final String id;
  final String name;
  final LearningColor color;
  final Color displayColor;
  final String spokenPhrase;
}

/// A single Color Matching challenge with three distinct colored objects.
@immutable
class ColorChallenge {
  const ColorChallenge({
    required this.targetColor,
    required this.promptText,
    required this.options,
  }) : assert(options.length == 3);

  final LearningColor targetColor;
  final String promptText;
  final List<ColorObjectItem> options;
}
