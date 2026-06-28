// AccentContainer: a card-like container with an optional thick accent border
// on the left side. Flutter's BoxDecoration requires uniform border colors
// when borderRadius is set, so this widget uses a LinearGradient to simulate
// non-uniform borders (4px accent on left, 1px outline on other sides).
// When primary is false, falls back to a simple uniform Border.all which
// works natively with borderRadius.

import 'package:flutter/material.dart';

class AccentContainer extends StatelessWidget {
  final bool primary;
  final Color? accentColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final double accentWidth;
  final double borderWidth;
  final EdgeInsets padding;
  final List<BoxShadow>? boxShadow;
  final Widget child;

  const AccentContainer({
    super.key,
    this.primary = false,
    this.accentColor,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = 12,
    this.accentWidth = 4,
    this.borderWidth = 1,
    this.padding = const EdgeInsets.all(16),
    this.boxShadow,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = accentColor ?? cs.primary;
    final border = borderColor ?? cs.outlineVariant;
    final bg = backgroundColor ?? cs.surfaceContainer;

    if (!primary) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: border, width: borderWidth),
          boxShadow: boxShadow,
        ),
        child: child,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final accentStop = width > 0 ? (accentWidth / width).clamp(0.0, 0.5) : 0.0;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [accent, accent, border, border],
              stops: [0.0, accentStop, accentStop, 1.0],
            ),
            boxShadow: boxShadow,
          ),
          child: Container(
            margin: EdgeInsets.only(
              left: accentWidth - borderWidth,
              top: 0,
              right: 0,
              bottom: 0,
            ),
            padding: padding,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(borderRadius - borderWidth),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
