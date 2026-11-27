import 'package:flutter/material.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';

/// Accessibility-friendly large back button for toddler screens.
class GentleBackButton extends StatelessWidget {
  const GentleBackButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Back to Home',
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: AppTheme.warmSurface,
        shape: const CircleBorder(
          side: BorderSide(color: Color(0xFFE5DEC9), width: 2),
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 58,
            height: 58,
            child: Icon(
              Icons.arrow_back_rounded,
              size: 32,
              color: AppTheme.inkText,
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable top header for activity screens with large back and replay buttons.
class ToddlerActivityHeader extends StatelessWidget {
  const ToddlerActivityHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.onReplayPrompt,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onReplayPrompt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GentleBackButton(onPressed: onBack),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onReplayPrompt != null)
            Semantics(
              button: true,
              label: 'Hear again',
              child: Material(
                color: AppTheme.buttercupCard,
                shape: const CircleBorder(
                  side: BorderSide(color: Color(0xFFE5C878), width: 2),
                ),
                child: InkWell(
                  onTap: onReplayPrompt,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 58,
                    height: 58,
                    child: Icon(
                      Icons.volume_up_rounded,
                      size: 30,
                      color: AppTheme.inkText,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
