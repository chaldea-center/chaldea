// ModernInfoBanner: card-style banner for info / success / warning / danger
// messages. Uses ModernStateColors for semantic colors and ColorScheme.error
// for danger.

import 'package:flutter/material.dart';

import 'modern_state_colors.dart';

enum ModernInfoBannerVariant { info, success, warning, danger }

class ModernInfoBanner extends StatelessWidget {
  final ModernInfoBannerVariant variant;
  final String text;
  final IconData? icon;

  const ModernInfoBanner({super.key, required this.variant, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    final sc = ModernStateColors.of(context);
    final (fg, bg, defaultIcon) = switch (variant) {
      ModernInfoBannerVariant.info => (sc.infoFg, sc.infoBg, Icons.info_outline_rounded),
      ModernInfoBannerVariant.success => (sc.successFg, sc.successBg, Icons.check_circle_outline_rounded),
      ModernInfoBannerVariant.warning => (sc.warningFg, sc.warningBg, Icons.warning_amber_rounded),
      ModernInfoBannerVariant.danger => (sc.dangerFg, sc.dangerBg, Icons.error_outline_rounded),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, size: 20, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: fg, height: 1.45)),
          ),
        ],
      ),
    );
  }
}
