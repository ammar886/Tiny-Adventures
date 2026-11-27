import 'package:flutter/material.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/domain/models/parent_settings.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';
import 'package:tiny_adventures/ui/features/parent_controls/view_models/parent_settings_view_model.dart';

/// Parent Controls screen for screen-time pacing, audio toggles, and privacy.
class ParentSettingsScreen extends StatefulWidget {
  const ParentSettingsScreen({
    super.key,
    required this.dependencies,
    this.onStartNewSession,
  });

  final AppDependencies dependencies;
  final VoidCallback? onStartNewSession;

  @override
  State<ParentSettingsScreen> createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends State<ParentSettingsScreen> {
  late final ParentSettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ParentSettingsViewModel(
      settingsRepository: widget.dependencies.settingsRepository,
      sessionRepository: widget.dependencies.sessionRepository,
      audioService: widget.dependencies.audioService,
      narrationService: widget.dependencies.narrationService,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _confirmResetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.creamBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Reset local progress?'),
        content: const Text(
          'This clears saved exploration counts on this device. Your sound and session settings stay the same.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _viewModel.resetProgress();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Local progress reset.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.creamBackground,
        title: const Text('Parent Controls'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final settings = _viewModel.settings;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _SectionCard(
                title: 'Gentle Session Duration',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When the session finishes, Tiny Adventures calmly invites your child to play offline together.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: ParentSettings.availableDurationsMinutes
                          .map((minutes) {
                        final selected =
                            settings.sessionDurationMinutes == minutes;
                        final label =
                            minutes == 0 ? 'No limit' : '$minutes min';
                        return ChoiceChip(
                          label: Text(label),
                          selected: selected,
                          selectedColor: AppTheme.skyCard,
                          onSelected: (_) =>
                              _viewModel.setSessionDurationMinutes(minutes),
                        );
                      }).toList(),
                    ),
                    if (widget.onStartNewSession != null) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          _viewModel.startNewSession();
                          widget.onStartNewSession?.call();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Start a New Session'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Audio & Voice',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Sound Effects & Animal Sounds'),
                      subtitle: const Text(
                        'Play animal sounds and gentle chimes',
                      ),
                      value: settings.soundEnabled,
                      onChanged: _viewModel.setSoundEnabled,
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Spoken Narration'),
                      subtitle: const Text(
                        'Read prompts and animal names aloud',
                      ),
                      value: settings.narrationEnabled,
                      onChanged: _viewModel.setNarrationEnabled,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Local Exploration Progress',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Animals discovered: ${settings.exploredAnimalIds.length} of 6\n'
                      'Color rounds completed: ${settings.completedColorRounds}\n'
                      'Move & Find prompts completed: ${settings.completedMovePrompts}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _confirmResetProgress,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset Local Progress'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'About & Privacy',
                child: Text(
                  'Tiny Adventures is built for toddlers (age 2+) and works 100% offline.\n\n'
                  '• No advertisements\n'
                  '• No external links, chat, or social features\n'
                  '• No analytics, tracking, or personal data collection\n'
                  '• No accounts or in-app purchases\n'
                  '• All settings and progress stay strictly on this device',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.warmSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFEDE4D0), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
