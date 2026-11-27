import 'package:flutter/material.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/ui/core/illustrations/animal_illustrations.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';
import 'package:tiny_adventures/ui/core/widgets/gentle_back_button.dart';
import 'package:tiny_adventures/ui/core/widgets/toddler_card.dart';
import 'package:tiny_adventures/ui/features/animal_sounds/view_models/animal_sounds_view_model.dart';

/// Free-exploration Animal Sounds picture book screen.
class AnimalSoundsScreen extends StatefulWidget {
  const AnimalSoundsScreen({
    super.key,
    required this.dependencies,
    required this.onSessionEnded,
  });

  final AppDependencies dependencies;
  final VoidCallback onSessionEnded;

  @override
  State<AnimalSoundsScreen> createState() => _AnimalSoundsScreenState();
}

class _AnimalSoundsScreenState extends State<AnimalSoundsScreen> {
  late final AnimalSoundsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AnimalSoundsViewModel(
      audioService: widget.dependencies.audioService,
      narrationService: widget.dependencies.narrationService,
      settingsRepository: widget.dependencies.settingsRepository,
      sessionRepository: widget.dependencies.sessionRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _viewModel.start();
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_viewModel.shouldShowSessionEnding) {
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
            final active = _viewModel.activeAnimal;
            return Column(
              children: [
                ToddlerActivityHeader(
                  title: 'Animal Sounds',
                  onBack: _handleBack,
                  onReplayPrompt: _viewModel.replayPrompt,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: active?.cardColor ?? AppTheme.warmSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: active?.accentColor.withValues(alpha: 0.35) ??
                            const Color(0xFFEDE4D0),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      active != null
                          ? '${active.name} says ${active.soundText}'
                          : 'Tap an animal friend!',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const columns = 2;
                      const spacing = 14.0;
                      const horizontalPad = 40.0;
                      const verticalPad = 24.0;
                      final itemWidth =
                          (constraints.maxWidth - horizontalPad - spacing) /
                              columns;
                      final targetHeight =
                          ((constraints.maxHeight - verticalPad - spacing * 2) /
                                  3)
                              .clamp(124.0, 220.0);
                      final ratio = itemWidth / targetHeight;

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: ratio,
                        ),
                        itemCount: _viewModel.animals.length,
                        itemBuilder: (context, index) {
                          final animal = _viewModel.animals[index];
                          final isSelected = active?.id == animal.id;
                          return ToddlerCard(
                            backgroundColor: animal.cardColor,
                            borderColor: isSelected
                                ? animal.accentColor
                                : animal.accentColor.withValues(alpha: 0.35),
                            semanticLabel: '${animal.name}. Tap to hear sound',
                            padding: const EdgeInsets.all(12),
                            minHeight: 110,
                            onTap: () => _viewModel.onAnimalTapped(animal),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: AnimatedAnimalIllustration(
                                      animalId: animal.id,
                                      pulseTrigger:
                                          _viewModel.pulseCountFor(animal.id),
                                      size: 92,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  animal.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
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
