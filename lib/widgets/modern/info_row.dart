// InfoRow: a custom info-display row with leading icon, title, subtitle,
// right-aligned value, and optional chevron. Kept as a custom widget (not
// ListTile) because ListTile's title/subtitle styling is fixed and cannot be
// inverted. The `prominence` field swaps which line is large/bright vs.
// small/grey — used in profile/admin pages where sometimes the value should
// dominate (e.g. email shown large with a small "Email" label).

import 'package:flutter/material.dart';

enum InfoRowProminence { title, subtitle }

class InfoRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final String? value;
  final bool valueMono;
  final Widget? valueWidget;
  final bool showChevron;
  final InfoRowProminence prominence;
  final bool danger;
  final VoidCallback? onTap;

  const InfoRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.value,
    this.valueMono = false,
    this.valueWidget,
    this.showChevron = false,
    this.prominence = InfoRowProminence.title,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bool titleProminent = prominence == InfoRowProminence.title;
    // Match ListTile's M3 styling: bodyLarge (w400) for title, bodySmall (w400)
    // for subtitle. The prominence distinction is purely size-based, not weight.
    final TextStyle prominentStyle = theme.textTheme.bodyLarge!.copyWith(color: danger ? cs.error : cs.onSurface);
    final TextStyle mutedStyle = theme.textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant);

    final TextStyle titleStyle = titleProminent ? prominentStyle : mutedStyle;
    final TextStyle subtitleStyle = titleProminent ? mutedStyle : prominentStyle;

    final content = Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
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
        if (valueWidget != null) ...[
          const SizedBox(width: 12),
          DefaultTextStyle.merge(
            child: valueWidget!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontFamily: valueMono ? 'monospace' : null,
            ),
          ),
        ] else if (value != null) ...[
          const SizedBox(width: 12),
          Text(
            value!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontFamily: valueMono ? 'monospace' : null,
            ),
          ),
        ],
        if (showChevron) ...[
          const SizedBox(width: 4),
          Icon(
            Directionality.maybeOf(context) == .rtl ? Icons.chevron_left : Icons.chevron_right,
            color: cs.onSurfaceVariant,
            size: 20,
          ),
        ],
      ],
    );

    if (onTap == null) {
      return Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), child: content);
    }
    return InkWell(
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), child: content),
    );
  }
}
