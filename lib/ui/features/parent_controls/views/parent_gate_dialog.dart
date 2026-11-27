import 'package:flutter/material.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';

/// Shows a calm parent gate requiring a 2-second press-and-hold so a toddler's
/// accidental tapping cannot unlock Parent Controls.
Future<bool> showParentGateDialog(BuildContext context) async {
  final unlocked = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => const _ParentGateDialog(),
  );
  return unlocked ?? false;
}

class _ParentGateDialog extends StatefulWidget {
  const _ParentGateDialog();

  @override
  State<_ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends State<_ParentGateDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _holdController;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_unlocked && mounted) {
          _unlocked = true;
          Navigator.of(context).pop(true);
        }
      });
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _startHold() {
    if (_unlocked) return;
    _holdController.forward(from: 0);
  }

  void _cancelHold() {
    if (_unlocked) return;
    if (_holdController.isAnimating || _holdController.value > 0) {
      _holdController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.creamBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      title: Text(
        'Parents Only',
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Press and hold the lock for 2 seconds to open Parent Controls.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Semantics(
            button: true,
            label: 'Hold for 2 seconds to unlock Parent Controls',
            child: Listener(
              key: const ValueKey('parent_gate_hold_button'),
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) => _startHold(),
              onPointerUp: (_) => _cancelHold(),
              onPointerCancel: (_) => _cancelHold(),
              child: AnimatedBuilder(
                animation: _holdController,
                builder: (context, _) {
                  return SizedBox(
                    width: 104,
                    height: 104,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: CircularProgressIndicator(
                            value: _holdController.value,
                            strokeWidth: 7,
                            backgroundColor: AppTheme.softSand,
                            color: AppTheme.skyAccent,
                          ),
                        ),
                        Container(
                          width: 78,
                          height: 78,
                          decoration: const BoxDecoration(
                            color: AppTheme.skyCard,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_open_rounded,
                            size: 34,
                            color: AppTheme.inkText,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
