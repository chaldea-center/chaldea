// ModernActionRow: tappable 48px row with icon + label + chevron. The `error`
// variant renders icon + label + chevron in colorScheme.error (used for
// destructive actions like "Delete account").

import 'package:flutter/material.dart';

enum ModernActionRowVariant { defaultVariant, error }

class ModernActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final ModernActionRowVariant variant;
  final VoidCallback? onTap;

  const ModernActionRow({
    super.key,
    required this.icon,
    required this.label,
    this.variant = ModernActionRowVariant.defaultVariant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isError = variant == ModernActionRowVariant.error;
    final color = isError ? cs.error : cs.onSurface;
    final iconColor = isError ? cs.error : cs.onSurfaceVariant;
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color)),
          ),
          Icon(Icons.chevron_right, size: 18, color: isError ? cs.error : cs.onSurfaceVariant),
        ],
      ),
    );
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6), child: content);
  }
}
