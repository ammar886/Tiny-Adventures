import 'package:flutter/material.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';
import 'package:tiny_adventures/ui/core/illustrations/home_activity_icons.dart';
import 'package:tiny_adventures/ui/core/illustrations/mascot_painter.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';
import 'package:tiny_adventures/ui/core/widgets/toddler_card.dart';
import 'package:tiny_adventures/ui/features/home/view_models/home_view_model.dart';

/// Calm, picture-book home screen understandable without reading.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.dependencies,
    required this.onSelectActivity,
    required this.onOpenParentControls,
    required this.onSessionEnded,
  });

  final AppDependencies dependencies;
  final ValueChanged<HomeActivity> onSelectActivity;
  final VoidCallback onOpenParentControls;
  final VoidCallback onSessionEnded;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(
      audioService: widget.dependencies.audioService,
      narrationService: widget.dependencies.narrationService,
      sessionRepository: widget.dependencies.sessionRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _viewModel.playWelcomeGreeting();
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleActivityTap(HomeActivity activity) async {
    await _viewModel.onActivityCardTapped();
    if (!mounted) return;
    if (_viewModel.shouldShowSessionEnding) {
      widget.onSessionEnded();
      return;
    }
    widget.onSelectActivity(activity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 36,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopBar(onOpenParentControls: widget.onOpenParentControls),
                    const SizedBox(height: 12),
                    _MascotGreetingBanner(viewModel: _viewModel),
                    const SizedBox(height: 22),
                    _ActivityCard(
                      title: 'Animal Sounds',
                      subtitle: 'Tap & listen',
                      backgroundColor: AppTheme.peachCard,
                      accentColor: AppTheme.peachAccent,
                      badgeKind: HomeActivityBadgeKind.animals,
                      onTap: () => _handleActivityTap(HomeActivity.animalSounds),
                    ),
                    const SizedBox(height: 16),
                    _ActivityCard(
                      title: 'Color Matching',
                      subtitle: 'Find the color',
                      backgroundColor: AppTheme.skyCard,
                      accentColor: AppTheme.skyAccent,
                      badgeKind: HomeActivityBadgeKind.colors,
                      onTap: () =>
                          _handleActivityTap(HomeActivity.colorMatching),
                    ),
                    const SizedBox(height: 16),
                    _ActivityCard(
                      title: 'Move & Find',
                      subtitle: 'Jump & play',
                      backgroundColor: AppTheme.sageCard,
                      accentColor: AppTheme.sageAccent,
                      badgeKind: HomeActivityBadgeKind.moveAndFind,
                      onTap: () => _handleActivityTap(HomeActivity.moveAndFind),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onOpenParentControls});

  final VoidCallback onOpenParentControls;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.buttercupCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Tiny Adventures',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                ),
          ),
        ),
        const Spacer(),
        Semantics(
          button: true,
          label: 'Parent controls',
          child: Material(
            color: AppTheme.softSand,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: onOpenParentControls,
              borderRadius: BorderRadius.circular(22),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 20,
                      color: AppTheme.mutedText,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Parents',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MascotGreetingBanner extends StatelessWidget {
  const _MascotGreetingBanner({required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.warmSurface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFEDE4D0), width: 2),
          ),
          child: Row(
            children: [
              MascotWidget(
                size: 96,
                onTap: viewModel.onMascotTapped,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GestureDetector(
                  onTap: viewModel.onMascotTapped,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.greetingText,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap Pip to say hi',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.accentColor,
    required this.badgeKind,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color accentColor;
  final HomeActivityBadgeKind badgeKind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ToddlerCard(
      backgroundColor: backgroundColor,
      borderColor: accentColor.withValues(alpha: 0.45),
      semanticLabel: '$title. $subtitle',
      minHeight: 118,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: AppTheme.warmSurface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: HomeActivityBadge(kind: badgeKind, size: 70),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.mutedText,
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              size: 30,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
