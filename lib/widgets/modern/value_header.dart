// ValueHeader: centered "large icon + label + value" block for the top
// of form pages (e.g. change-username, change-email). Replaces the old
// InfoBanner usage and fills the empty space with a meaningful visual anchor.

import 'package:flutter/material.dart';

class ValueHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const ValueHeader({super.key, required this.icon, required this.label, required this.value, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = iconColor ?? cs.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: fg.withAlpha(25), shape: BoxShape.circle),
            child: Icon(icon, size: 28, color: fg),
          ),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
