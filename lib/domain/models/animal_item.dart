import 'package:flutter/material.dart';

/// Identifiers for the six featured animals.
enum AnimalId {
  dog,
  cat,
  cow,
  duck,
  lion,
  elephant,
}

/// Immutable definition of an animal card in the Animal Sounds activity.
@immutable
class AnimalItem {
  const AnimalItem({
    required this.id,
    required this.name,
    required this.soundText,
    required this.audioAsset,
    required this.cardColor,
    required this.accentColor,
  });

  final AnimalId id;
  final String name;
  final String soundText;

  /// Path relative to `assets/`, e.g. `audio/dog.wav`.
  final String audioAsset;
  final Color cardColor;
  final Color accentColor;
}
