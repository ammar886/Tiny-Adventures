import 'package:flutter/material.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';
import 'package:tiny_adventures/ui/features/animal_sounds/views/animal_sounds_screen.dart';
import 'package:tiny_adventures/ui/features/color_matching/views/color_matching_screen.dart';
import 'package:tiny_adventures/ui/features/home/view_models/home_view_model.dart';
import 'package:tiny_adventures/ui/features/home/views/home_screen.dart';
import 'package:tiny_adventures/ui/features/move_and_find/views/move_and_find_screen.dart';
import 'package:tiny_adventures/ui/features/parent_controls/views/parent_gate_dialog.dart';
import 'package:tiny_adventures/ui/features/parent_controls/views/parent_settings_screen.dart';
import 'package:tiny_adventures/ui/features/session_ending/views/session_ending_screen.dart';

/// Root widget that wires theme, lifecycle-aware audio/session state, and routing.
class TinyAdventuresApp extends StatefulWidget {
  const TinyAdventuresApp({
    super.key,
    required this.dependencies,
    this.homeOverride,
  });

  final AppDependencies dependencies;
  final Widget? homeOverride;

  @override
  State<TinyAdventuresApp> createState() => _TinyAdventuresAppState();
}

class _TinyAdventuresAppState extends State<TinyAdventuresApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.dependencies.audioService.setAppActive(true);
        widget.dependencies.narrationService.setAppActive(true);
        widget.dependencies.sessionRepository.resume();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        widget.dependencies.audioService.setAppActive(false);
        widget.dependencies.narrationService.setAppActive(false);
        widget.dependencies.sessionRepository.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiny Adventures',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      home: widget.homeOverride ??
          _HomeNavigator(dependencies: widget.dependencies),
    );
  }
}

class _HomeNavigator extends StatelessWidget {
  const _HomeNavigator({required this.dependencies});

  final AppDependencies dependencies;

  void _openSessionEnding(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (endingContext) => SessionEndingScreen(
          dependencies: dependencies,
          onParentUnlockedNewSession: () async {
            final unlocked = await showParentGateDialog(endingContext);
            if (!unlocked || !endingContext.mounted) return;
            dependencies.sessionRepository.startNewSession();
            Navigator.of(endingContext).pop();
          },
        ),
      ),
    );
  }

  Future<void> _openParentControls(BuildContext context) async {
    final unlocked = await showParentGateDialog(context);
    if (!unlocked || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (settingsContext) => ParentSettingsScreen(
          dependencies: dependencies,
          onStartNewSession: () => Navigator.of(settingsContext).pop(),
        ),
      ),
    );
  }

  void _openActivity(BuildContext context, HomeActivity activity) {
    final Widget destination = switch (activity) {
      HomeActivity.animalSounds => AnimalSoundsScreen(
          dependencies: dependencies,
          onSessionEnded: () => _openSessionEnding(context),
        ),
      HomeActivity.colorMatching => ColorMatchingScreen(
          dependencies: dependencies,
          onSessionEnded: () => _openSessionEnding(context),
        ),
      HomeActivity.moveAndFind => MoveAndFindScreen(
          dependencies: dependencies,
          onSessionEnded: () => _openSessionEnding(context),
        ),
    };

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      dependencies: dependencies,
      onSelectActivity: (activity) => _openActivity(context, activity),
      onOpenParentControls: () => _openParentControls(context),
      onSessionEnded: () => _openSessionEnding(context),
    );
  }
}
