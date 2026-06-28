// ModernSectionCard: elevated card container with optional caption title.
// Children are stacked with thin dividers between them when `divided` is true.
// Border and divider colors come from ModernThemeData (outlineVariant by
// default) so they are clearly visible in light mode — the original
// SectionCard used outline.withAlpha(40) which was nearly invisible.

import 'package:flutter/material.dart';

import 'modern_theme.dart';

class ModernSectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final bool divided;
  final EdgeInsets padding;

  const ModernSectionCard({
    super.key,
    this.title,
    required this.children,
    this.divided = true,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = ModernThemeData.of(context);
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.cardBorder),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null && title!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  title!,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
              ),
            ],
            if (divided) ..._withDividers(context, theme, children) else ...children,
          ],
        ),
      ),
    );
  }

  List<Widget> _withDividers(BuildContext context, ModernThemeData theme, List<Widget> items) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(Divider(height: 1, thickness: 0.5, color: theme.divider));
      }
    }
    return result;
  }
}
