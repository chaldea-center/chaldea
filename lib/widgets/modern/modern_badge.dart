// ModernBadge: pill badge with a light tint of colorScheme.primary as
// background. General-purpose — not restricted to role labels.

import 'package:flutter/material.dart';

class ModernBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;

  const ModernBadge({super.key, required this.label, this.color, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = color ?? cs.primary;
    final bg = backgroundColor ?? fg.withAlpha(30);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9999)),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
