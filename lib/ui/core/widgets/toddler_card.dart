import 'package:flutter/material.dart';
import 'package:tiny_adventures/ui/core/theme/app_theme.dart';

/// Large, rounded, soft-pastel card with gentle spring feedback for toddlers.
class ToddlerCard extends StatefulWidget {
  const ToddlerCard({
    super.key,
    required this.backgroundColor,
    required this.onTap,
    required this.child,
    this.borderColor,
    this.semanticLabel,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = AppTheme.cardRadius,
    this.minHeight = 104,
  });

  final Color backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final Widget child;
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double minHeight;

  @override
  State<ToddlerCard> createState() => _ToddlerCardState();
}

class _ToddlerCardState extends State<ToddlerCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final border = widget.borderColor ??
        Color.lerp(widget.backgroundColor, Colors.black, 0.08)!;

    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _isPressed = true),
        onTapUp: widget.onTap == null
            ? null
            : (_) => setState(() => _isPressed = false),
        onTapCancel: widget.onTap == null
            ? null
            : () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: widget.minHeight),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(color: border, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: border.withValues(alpha: 0.28),
                    offset: Offset(0, _isPressed ? 2 : 6),
                    blurRadius: _isPressed ? 4 : 10,
                  ),
                ],
              ),
              child: Padding(
                padding: widget.padding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
