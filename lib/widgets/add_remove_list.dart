import 'package:material_ui/material_ui.dart';

import '../generated/l10n.dart';
import 'custom_dialogs.dart';
import 'tile_items.dart';

/// Which gesture removes an item in [AddRemoveList].
enum AddRemoveGesture { tap, longPress }

/// Builds the visual for one item of an [AddRemoveList].
typedef AddRemoveItemBuilder<T> = Widget Function(BuildContext context, T item);

/// A list section with caller-defined items and add/remove affordances.
///
/// Renders inside a [TileGroup] by default; set [inline] to emit only the header
/// row and item wrap so it can live in a parent that already provides a surface.
///
/// The builder only returns the item's visual: gestures are owned by this
/// widget so a child's own tap handler cannot swallow the removal tap.
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

  /// Gesture that removes an item. Tap is the default; long press remains
  /// available for lists where accidental taps are costly.
  final AddRemoveGesture removeGesture;

  /// Block child pointer gestures so taps always reach the removal layer.
  /// Disable when an item contains its own interactive widgets.
  final bool absorbChildGestures;

  /// Ask for confirmation before [onRemove], for every removal gesture.
  final bool confirmRemove;

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
    this.removeGesture = AddRemoveGesture.tap,
    this.absorbChildGestures = true,
    this.confirmRemove = true,
    this.onSecondary,
    this.spacing = 8,
    this.runSpacing = 8,
    this.contentPadding,
  });

  Widget _buildItem(BuildContext context, T item) {
    final removeOnTap = removeGesture == AddRemoveGesture.tap;
    final VoidCallback? secondary = onSecondary == null ? null : () => onSecondary!(item);
    void remove() => _remove(context, item);
    final child = itemBuilder(context, item);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: removeOnTap ? remove : secondary,
      onLongPress: removeOnTap ? secondary : remove,
      child: absorbChildGestures ? IgnorePointer(child: child) : child,
    );
  }

  Future<void> _remove(BuildContext context, T item) async {
    if (!confirmRemove) {
      onRemove(item);
      return;
    }
    final confirmed = await SimpleConfirmDialog(
      title: Text(S.current.remove),
      content: IgnorePointer(child: itemBuilder(context, item)),
    ).showDialog(context);
    if (confirmed == true && context.mounted) onRemove(item);
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
            children: [for (final item in items) _buildItem(context, item)],
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
