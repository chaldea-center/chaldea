// ModernStepIndicator: numbered circles connected by a horizontal line.
// Active step (<=current) fills the circle with colorScheme.primary; future
// steps use outline.

import 'package:flutter/material.dart';

class ModernStepIndicator extends StatelessWidget {
  final int current;
  final int total;
  final List<String>? labels;

  const ModernStepIndicator({super.key, required this.current, required this.total, this.labels});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (var i = 1; i <= total; i++) ...[
          _circle(context, cs, i),
          if (i < total) ...[
            Expanded(child: Container(height: 1, color: i < current ? cs.primary : cs.outlineVariant)),
          ],
        ],
      ],
    );
  }

  Widget _circle(BuildContext context, ColorScheme cs, int step) {
    final done = step <= current;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? cs.primary : Colors.transparent,
        border: Border.all(color: done ? cs.primary : cs.outlineVariant, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$step',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: done ? cs.onPrimary : cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
