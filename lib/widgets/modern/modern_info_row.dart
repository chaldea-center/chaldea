// ModernInfoRow: 48px-tall row with icon + label + value + optional chevron.
// Tappable when `onTap` is provided (renders chevron).

import 'package:flutter/material.dart';

class ModernInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool valueMono;
  final Widget? valueWidget;
  final VoidCallback? onTap;

  const ModernInfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.valueMono = false,
    this.valueWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tappable = onTap != null;
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface)),
          const Spacer(),
          if (valueWidget != null)
            valueWidget!
          else if (value != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontFamily: valueMono ? 'monospace' : null,
                      ),
                ),
                if (tappable) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
                ],
              ],
            ),
        ],
      ),
    );
    if (!tappable) return content;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6), child: content);
  }
}
