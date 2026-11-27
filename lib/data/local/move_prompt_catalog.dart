import 'package:tiny_adventures/domain/models/move_prompt.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';

/// Offline catalog of real-world movement and discovery prompts.
class MovePromptCatalog {
  MovePromptCatalog._();

  static const List<MovePrompt> all = <MovePrompt>[
    MovePrompt(
      action: MoveAction.clapHands,
      promptText: 'Can you clap your hands?',
      encouragementText: 'Clap, clap, clap! Great job!',
      cardColor: AppTheme.buttercupCard,
      accentColor: AppTheme.buttercupAccent,
    ),
    MovePrompt(
      action: MoveAction.jumpFrog,
      promptText: 'Can you jump like a frog?',
      encouragementText: 'Ribbit, hop! Wonderful jumping!',
      cardColor: AppTheme.sageCard,
      accentColor: AppTheme.sageAccent,
    ),
    MovePrompt(
      action: MoveAction.findBlue,
      promptText: 'Can you find something blue?',
      encouragementText: 'Yay! You found something blue!',
      cardColor: AppTheme.skyCard,
      accentColor: AppTheme.skyAccent,
    ),
    MovePrompt(
      action: MoveAction.waveHello,
      promptText: 'Can you wave hello?',
      encouragementText: 'Hello friend! Nice waving!',
      cardColor: AppTheme.peachCard,
      accentColor: AppTheme.peachAccent,
    ),
    MovePrompt(
      action: MoveAction.touchNose,
      promptText: 'Can you touch your nose?',
      encouragementText: 'Boop! You found your nose!',
      cardColor: AppTheme.lavenderCard,
      accentColor: AppTheme.lavenderAccent,
    ),
  ];
}
