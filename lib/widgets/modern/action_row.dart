// ActionRow: a tappable action row with leading icon, title, optional
// subtitle, and a trailing chevron (shown by default because action rows
// usually navigate). The `danger` variant colors the title with error — used
// for destructive actions like "Delete account". Kept as a custom widget
// (not ListTile) to share the InfoRow layout vocabulary and to support the
// danger variant cleanly.

import 'package:flutter/material.dart';

enum ActionRowVariant { normal, danger }

class ActionRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final ActionRowVariant variant;
  final bool showChevron;
  final VoidCallback? onTap;

  const ActionRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.variant = ActionRowVariant.normal,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bool danger = variant == ActionRowVariant.danger;

    final titleStyle = theme.textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.w600,
      color: danger ? cs.error : cs.onSurface,
    );
    final subtitleStyle = theme.textTheme.bodySmall!
        .copyWith(color: cs.onSurfaceVariant);

    final content = Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: titleStyle),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!, style: subtitleStyle),
                ),
            ],
          ),
        ),
        if (showChevron)
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
      ],
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: content,
      ),
    );
  }
}
