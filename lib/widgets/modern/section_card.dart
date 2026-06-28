// SectionCard: a Card wrapper that optionally renders a title above its
// children and inserts themed Dividers between them. Card shape/elevation/
// border come from cardTheme; this widget only adds title + divider layout.

import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final bool divided;
  final EdgeInsets padding;

  const SectionCard({
    super.key,
    this.title,
    required this.children,
    this.divided = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> content;
    if (divided && children.length > 1) {
      content = [children.first];
      for (var i = 1; i < children.length; i++) {
        content.add(const Divider(height: 1, thickness: 0.5));
        content.add(children[i]);
      }
    } else {
      content = children;
    }

    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  title!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ...content,
          ],
        ),
      ),
    );
  }
}
