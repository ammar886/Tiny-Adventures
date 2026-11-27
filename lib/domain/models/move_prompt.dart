import 'package:flutter/material.dart';

/// Movement & real-world discovery actions for toddlers.
enum MoveAction {
  clapHands,
  jumpFrog,
  findBlue,
  waveHello,
  touchNose,
}

/// Immutable prompt shown in the Move & Find activity.
@immutable
class MovePrompt {
  const MovePrompt({
    required this.action,
    required this.promptText,
    required this.encouragementText,
    required this.cardColor,
    required this.accentColor,
  });

  final MoveAction action;
  final String promptText;
  final String encouragementText;
  final Color cardColor;
  final Color accentColor;
}
