// ModernDividerWithText: horizontal rule with a centered label.

import 'package:flutter/material.dart';

class ModernDividerWithText extends StatelessWidget {
  final String text;
  const ModernDividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: cs.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ),
        Expanded(child: Divider(color: cs.outlineVariant)),
      ],
    );
  }
}
