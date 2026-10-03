import 'package:material_ui/material_ui.dart';

import 'tile_items.dart';

/// A compact, reusable list section with caller-defined items and interactions.
///
/// The item builder receives a removal callback so the list can support
/// different affordances, such as long-pressing a game-card icon.
class AddRemoveList<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<T> items;
  final String? addTooltip;
  final VoidCallback onAdd;
  final ValueChanged<T> onRemove;
  final Widget Function(BuildContext context, T item, VoidCallback onRemove) itemBuilder;
  final Widget? emptyState;

  const AddRemoveList({
    super.key,
    required this.title,
    this.subtitle,
    required this.items,
    this.addTooltip,
    required this.onAdd,
    required this.onRemove,
    required this.itemBuilder,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    return TileGroup(
      padding: const EdgeInsets.symmetric(vertical: 2),
      children: [
        ListTile(
          dense: true,
          title: Text(title),
          subtitle: subtitle == null ? null : Text(subtitle!),
          trailing: IconButton(
            tooltip: addTooltip,
            visualDensity: VisualDensity.compact,
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ),
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final item in items) itemBuilder(context, item, () => onRemove(item))],
            ),
          )
        else if (emptyState != null)
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: emptyState!),
      ],
    );
  }
}
