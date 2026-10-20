import 'package:material_ui/material_ui.dart';

import 'tile_items.dart';

/// Which gesture removes an item in [AddRemoveList].
enum AddRemoveGesture { tap, longPress }

/// Gesture callbacks for one item, already resolved against
/// [AddRemoveList.removeGesture] so a caller never branches on it. [remove]
/// always deletes the item; [tap] and [longPress] are null when no handler
/// applies to that gesture.
class AddRemoveHandle {
  final VoidCallback remove;
  final VoidCallback? tap;
  final VoidCallback? longPress;

  const AddRemoveHandle({required this.remove, this.tap, this.longPress});
}

/// Builds the visual for one item of an [AddRemoveList].
typedef AddRemoveItemBuilder<T> = Widget Function(BuildContext context, T item, AddRemoveHandle handle);

/// A list section with caller-defined items and add/remove affordances.
///
/// Renders inside a [TileGroup] by default; set [inline] to emit only the header
/// row and item wrap so it can live in a parent that already provides a surface.
class AddRemoveList<T> extends StatelessWidget {
  final Widget title;
  final String? subtitle;
  final List<T> items;
  final Widget? leading;
  final String? addTooltip;
  final VoidCallback? onAdd;
  final ValueChanged<T> onRemove;
  final AddRemoveItemBuilder<T> itemBuilder;
  final Widget? emptyState;

  /// Skip the surrounding [TileGroup] and emit bare content.
  final bool inline;

  /// Gesture that removes an item. Long press keeps the destructive action
  /// deliberate; tap suits pickers whose items are plain chips.
  final AddRemoveGesture removeGesture;

  /// Handler for the gesture not used for removal, e.g. jumping to the item's
  /// detail page or editing a per-item value.
  final ValueChanged<T>? onSecondary;

  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? contentPadding;

  const AddRemoveList({
    super.key,
    required this.title,
    this.subtitle,
    required this.items,
    this.leading,
    this.addTooltip,
    this.onAdd,
    required this.onRemove,
    required this.itemBuilder,
    this.emptyState,
    this.inline = false,
    this.removeGesture = AddRemoveGesture.longPress,
    this.onSecondary,
    this.spacing = 8,
    this.runSpacing = 8,
    this.contentPadding,
  });

  AddRemoveHandle _handle(T item) {
    void remove() => onRemove(item);
    final secondary = onSecondary == null ? null : () => onSecondary!(item);
    final bool removeOnTap = removeGesture == AddRemoveGesture.tap;
    return AddRemoveHandle(
      remove: remove,
      tap: removeOnTap ? remove : secondary,
      longPress: removeOnTap ? secondary : remove,
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      ListTile(
        dense: true,
        leading: leading,
        title: title,
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
          padding: contentPadding ?? const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
          child: Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: [for (final item in items) itemBuilder(context, item, _handle(item))],
          ),
        )
      else if (emptyState != null)
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: emptyState!),
    ];
    if (inline) {
      return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children);
    }
    return TileGroup(padding: const EdgeInsets.symmetric(vertical: 2), children: children);
  }
}
