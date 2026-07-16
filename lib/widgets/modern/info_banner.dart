// InfoBanner: card-style banner for info / success / warning / danger
// messages. Uses StateColors for semantic colors and ColorScheme.error
// for danger. Each variant gets a 4px left accent strip in its semantic
// color via AccentContainer, making the variant instantly recognizable.

import 'package:flutter/material.dart';

import 'accent_container.dart';
import 'state_colors.dart';

enum InfoBannerVariant { info, success, warning, danger }

class InfoBanner extends StatelessWidget {
  final InfoBannerVariant variant;
  final String text;
  final IconData? icon;

  const InfoBanner({super.key, required this.variant, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    final sc = StateColors.of(context);
    final (fg, bg, defaultIcon) = switch (variant) {
      InfoBannerVariant.info => (sc.infoFg, sc.infoBg, Icons.info_outline_rounded),
      InfoBannerVariant.success => (sc.successFg, sc.successBg, Icons.check_circle_outline_rounded),
      InfoBannerVariant.warning => (sc.warningFg, sc.warningBg, Icons.warning_amber_rounded),
      InfoBannerVariant.danger => (sc.dangerFg, sc.dangerBg, Icons.error_outline_rounded),
    };
    return AccentContainer(
      primary: true,
      accentColor: fg,
      borderColor: fg.withAlpha(40),
      backgroundColor: bg,
      borderRadius: 8,
      padding: const EdgeInsets.all(12),
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
