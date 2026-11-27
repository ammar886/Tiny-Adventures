import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tiny_adventures/domain/models/color_challenge.dart';

/// Offline catalog of colorful picture-book objects and challenge generator.
class ColorCatalog {
  ColorCatalog._();

  static const Map<LearningColor, List<ColorObjectItem>> objectsByColor = {
    LearningColor.red: [
      ColorObjectItem(
        id: 'apple',
        name: 'Apple',
        color: LearningColor.red,
        displayColor: Color(0xFFE75A5A),
        spokenPhrase: 'Red apple',
      ),
      ColorObjectItem(
        id: 'heart',
        name: 'Heart',
        color: LearningColor.red,
        displayColor: Color(0xFFE75A5A),
        spokenPhrase: 'Red heart',
      ),
    ],
    LearningColor.blue: [
      ColorObjectItem(
        id: 'ball',
        name: 'Ball',
        color: LearningColor.blue,
        displayColor: Color(0xFF4D96E8),
        spokenPhrase: 'Blue ball',
      ),
      ColorObjectItem(
        id: 'whale',
        name: 'Whale',
        color: LearningColor.blue,
        displayColor: Color(0xFF4D96E8),
        spokenPhrase: 'Blue whale',
      ),
    ],
    LearningColor.yellow: [
      ColorObjectItem(
        id: 'sun',
        name: 'Sun',
        color: LearningColor.yellow,
        displayColor: Color(0xFFF4C137),
        spokenPhrase: 'Yellow sun',
      ),
      ColorObjectItem(
        id: 'star',
        name: 'Star',
        color: LearningColor.yellow,
        displayColor: Color(0xFFF4C137),
        spokenPhrase: 'Yellow star',
      ),
    ],
    LearningColor.green: [
      ColorObjectItem(
        id: 'leaf',
        name: 'Leaf',
        color: LearningColor.green,
        displayColor: Color(0xFF5CB468),
        spokenPhrase: 'Green leaf',
      ),
      ColorObjectItem(
        id: 'pear',
        name: 'Pear',
        color: LearningColor.green,
        displayColor: Color(0xFF5CB468),
        spokenPhrase: 'Green pear',
      ),
    ],
    LearningColor.orange: [
      ColorObjectItem(
        id: 'carrot',
        name: 'Carrot',
        color: LearningColor.orange,
        displayColor: Color(0xFFF28C38),
        spokenPhrase: 'Orange carrot',
      ),
      ColorObjectItem(
        id: 'tangerine',
        name: 'Orange',
        color: LearningColor.orange,
        displayColor: Color(0xFFF28C38),
        spokenPhrase: 'Orange fruit',
      ),
    ],
    LearningColor.purple: [
      ColorObjectItem(
        id: 'grapes',
        name: 'Grapes',
        color: LearningColor.purple,
        displayColor: Color(0xFF9C72D8),
        spokenPhrase: 'Purple grapes',
      ),
      ColorObjectItem(
        id: 'butterfly',
        name: 'Butterfly',
        color: LearningColor.purple,
        displayColor: Color(0xFF9C72D8),
        spokenPhrase: 'Purple butterfly',
      ),
    ],
  };

  /// Generates a round for [targetColor] with three distinct colors.
  static ColorChallenge buildChallengeFor(
    LearningColor targetColor, {
    math.Random? random,
  }) {
    final rng = random ?? math.Random();
    final targetPool = objectsByColor[targetColor]!;
    final targetItem = targetPool[rng.nextInt(targetPool.length)];

    final otherColors = LearningColor.values
        .where((c) => c != targetColor)
        .toList()
      ..shuffle(rng);

    final distractorA = objectsByColor[otherColors[0]]!;
    final distractorB = objectsByColor[otherColors[1]]!;

    final options = <ColorObjectItem>[
      targetItem,
      distractorA[rng.nextInt(distractorA.length)],
      distractorB[rng.nextInt(distractorB.length)],
    ]..shuffle(rng);

    return ColorChallenge(
      targetColor: targetColor,
      promptText: 'Can you find something ${targetColor.name}?',
      options: options,
    );
  }
}
