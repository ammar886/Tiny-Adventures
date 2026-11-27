import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/ui/core/illustrations/mascot_painter.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';

/// Gentle, pressure-free ending screen encouraging real-world play together.
class SessionEndingScreen extends StatefulWidget {
  const SessionEndingScreen({
    super.key,
    required this.dependencies,
    required this.onParentUnlockedNewSession,
    this._random,
  });

  final AppDependencies dependencies;
  final VoidCallback onParentUnlockedNewSession;
  final math.Random? _random;

  @override
  State<SessionEndingScreen> createState() => _SessionEndingScreenState();
}

class _SessionEndingScreenState extends State<SessionEndingScreen> {
  static const List<String> _offlineIdeas = <String>[
    'Let’s read a favorite picture book together!',
    'Let’s build a tall tower with blocks or pillows!',
    'Let’s look out the window and spot clouds or birds!',
    'Let’s sing a favorite song and dance together!',
  ];

  late final String _offlineIdea;

  @override
  void initState() {
    super.initState();
    final rng = widget._random ?? math.Random();
    _offlineIdea = _offlineIdeas[rng.nextInt(_offlineIdeas.length)];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.dependencies.audioService.playGentleChime();
      widget.dependencies.narrationService.speak(
        'Great adventure! Let’s go play together! $_offlineIdea',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.buttercupCard,
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(
                      color: AppTheme.buttercupAccent.withValues(alpha: 0.4),
                      width: 2.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      const MascotWidget(size: 136),
                      const SizedBox(height: 18),
                      Text(
                        'Great adventure!',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Let’s go play together!',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.warmSurface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.wb_sunny_rounded,
                              size: 32,
                              color: AppTheme.buttercupAccent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _offlineIdea,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: widget.onParentUnlockedNewSession,
                  icon: const Icon(Icons.lock_outline_rounded, size: 18),
                  label: const Text('Parents: Start a new session'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.mutedText,
                    minimumSize: const Size(48, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
