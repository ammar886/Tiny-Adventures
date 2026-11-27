import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/ui/core/illustrations/move_character_illustrations.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';
import 'package:tiny_adventures/ui/core/widgets/gentle_back_button.dart';
import 'package:tiny_adventures/ui/core/widgets/toddler_card.dart';
import 'package:tiny_adventures/ui/features/move_and_find/view_models/move_and_find_view_model.dart';

/// Real-world physical play & discovery activity with animated demonstrations.
class MoveAndFindScreen extends StatefulWidget {
  const MoveAndFindScreen({
    super.key,
    required this.dependencies,
    required this.onSessionEnded,
    this.random,
  });

  final AppDependencies dependencies;
  final VoidCallback onSessionEnded;
  final math.Random? random;

  @override
  State<MoveAndFindScreen> createState() => _MoveAndFindScreenState();
}

class _MoveAndFindScreenState extends State<MoveAndFindScreen> {
  late final MoveAndFindViewModel _viewModel;
  bool _endedTriggered = false;

  @override
  void initState() {
    super.initState();
    _viewModel = MoveAndFindViewModel(
      audioService: widget.dependencies.audioService,
      narrationService: widget.dependencies.narrationService,
      settingsRepository: widget.dependencies.settingsRepository,
      sessionRepository: widget.dependencies.sessionRepository,
      random: widget.random,
    );
    _viewModel.addListener(_handleViewModelUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _viewModel.start();
      }
    });
  }

  void _handleViewModelUpdate() {
    if (_viewModel.shouldEndSession && !_endedTriggered && mounted) {
      _endedTriggered = true;
      Navigator.of(context).pop();
      widget.onSessionEnded();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleViewModelUpdate);
    _viewModel.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.dependencies.sessionRepository.isSessionComplete) {
      Navigator.of(context).pop();
      widget.onSessionEnded();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final prompt = _viewModel.currentPrompt;
            final isCelebrating = _viewModel.isCelebrating;

            return Column(
              children: [
                ToddlerActivityHeader(
                  title: 'Move & Find',
                  onBack: _handleBack,
                  onReplayPrompt: _viewModel.replayPrompt,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: prompt.cardColor,
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: prompt.accentColor.withValues(alpha: 0.4),
                                width: 2.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: AnimatedMoveCharacter(
                                      action: prompt.action,
                                      size: 210,
                                      onTap: _viewModel.replayPrompt,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  child: Text(
                                    isCelebrating
                                        ? prompt.encouragementText
                                        : prompt.promptText,
                                    key: ValueKey(
                                      '${prompt.action.name}-$isCelebrating',
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ToddlerCard(
                          backgroundColor: isCelebrating
                              ? AppTheme.sageCard
                              : AppTheme.buttercupCard,
                          borderColor: isCelebrating
                              ? AppTheme.sageAccent
                              : AppTheme.buttercupAccent.withValues(alpha: 0.55),
                          semanticLabel: 'I did it! Continue',
                          minHeight: 82,
                          onTap: isCelebrating ? null : _viewModel.completePrompt,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isCelebrating
                                    ? Icons.star_rounded
                                    : Icons.check_circle_rounded,
                                size: 34,
                                color: isCelebrating
                                    ? AppTheme.sageAccent
                                    : AppTheme.inkText,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isCelebrating ? 'Great job!' : 'I did it!',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
