// StateColors: semantic state colors (success/warning/info/danger) for
// banners and badges. ColorScheme has no semantic slots for these, so we use
// fixed Material palette colors with brightness-aware alpha for backgrounds.

import 'package:flutter/material.dart';

@immutable
class StateColors {
  final Color successFg;
  final Color successBg;
  final Color warningFg;
  final Color warningBg;
  final Color infoFg;
  final Color infoBg;
  final Color dangerFg;
  final Color dangerBg;

  const StateColors._({
    required this.successFg,
    required this.successBg,
    required this.warningFg,
    required this.warningBg,
    required this.infoFg,
    required this.infoBg,
    required this.dangerFg,
    required this.dangerBg,
  });

  factory StateColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgAlpha = isDark ? 40 : 25;
    final cs = Theme.of(context).colorScheme;
    return StateColors._(
      successFg: Colors.green,
      successBg: Colors.green.withAlpha(bgAlpha),
      warningFg: Colors.orange,
      warningBg: Colors.orange.withAlpha(bgAlpha),
      infoFg: Colors.blue,
      infoBg: Colors.blue.withAlpha(bgAlpha),
      dangerFg: cs.error,
      dangerBg: cs.errorContainer,
    );
  }
}
