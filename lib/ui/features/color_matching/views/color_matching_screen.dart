import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/domain/models/color_challenge.dart';
import 'package:tiny_adventures/ui/core/illustrations/color_object_illustrations.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';
import 'package:tiny_adventures/ui/core/widgets/gentle_back_button.dart';
import 'package:tiny_adventures/ui/core/widgets/toddler_card.dart';
import 'package:tiny_adventures/ui/features/color_matching/view_models/color_matching_view_model.dart';

/// Tap-only Color Matching screen with large touch targets and gentle feedback.
class ColorMatchingScreen extends StatefulWidget {
  const ColorMatchingScreen({
    super.key,
    required this.dependencies,
    required this.onSessionEnded,
    this.random,
  });

  final AppDependencies dependencies;
  final VoidCallback onSessionEnded;
  final math.Random? random;

  @override
  State<ColorMatchingScreen> createState() => _ColorMatchingScreenState();
}

class _ColorMatchingScreenState extends State<ColorMatchingScreen> {
  late final ColorMatchingViewModel _viewModel;
  bool _endedTriggered = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ColorMatchingViewModel(
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

  Color _hintDotColor(LearningColor color) {
    return switch (color) {
      LearningColor.red => const Color(0xFFE75A5A),
      LearningColor.blue => const Color(0xFF4D96E8),
      LearningColor.yellow => const Color(0xFFF4C137),
      LearningColor.green => const Color(0xFF5CB468),
      LearningColor.orange => const Color(0xFFF28C38),
      LearningColor.purple => const Color(0xFF9C72D8),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final challenge = _viewModel.challenge;
            final options = challenge.options;
            final targetSwatch = _hintDotColor(challenge.targetColor);

            return Column(
              children: [
                ToddlerActivityHeader(
                  title: 'Color Matching',
                  onBack: _handleBack,
                  onReplayPrompt: _viewModel.replayPrompt,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _viewModel.isMatched
                          ? AppTheme.sageCard
                          : AppTheme.warmSurface,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: targetSwatch.withValues(alpha: 0.45),
                        width: 2.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: targetSwatch,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _viewModel.feedbackText ?? challenge.promptText,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _ColorChoiceCard(
                                  item: options[0],
                                  isMatchedTarget: _viewModel.isMatched &&
                                      options[0].id ==
                                          _viewModel.selectedOptionId,
                                  onTap: () =>
                                      _viewModel.onOptionTapped(options[0]),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _ColorChoiceCard(
                                  item: options[1],
                                  isMatchedTarget: _viewModel.isMatched &&
                                      options[1].id ==
                                          _viewModel.selectedOptionId,
                                  onTap: () =>
                                      _viewModel.onOptionTapped(options[1]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _ColorChoiceCard(
                            item: options[2],
                            isMatchedTarget: _viewModel.isMatched &&
                                options[2].id == _viewModel.selectedOptionId,
                            onTap: () => _viewModel.onOptionTapped(options[2]),
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

class _ColorChoiceCard extends StatelessWidget {
  const _ColorChoiceCard({
    required this.item,
    required this.isMatchedTarget,
    required this.onTap,
  });

  final ColorObjectItem item;
  final bool isMatchedTarget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pastelBg = Color.lerp(item.displayColor, Colors.white, 0.84)!;
    return AnimatedScale(
      scale: isMatchedTarget ? 1.04 : 1.0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutBack,
      child: ToddlerCard(
        backgroundColor: isMatchedTarget
            ? Color.lerp(item.displayColor, Colors.white, 0.72)!
            : pastelBg,
        borderColor: isMatchedTarget
            ? item.displayColor
            : item.displayColor.withValues(alpha: 0.4),
        semanticLabel: item.spokenPhrase,
        minHeight: 140,
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: ColorObjectIllustration(item: item, size: 112),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
