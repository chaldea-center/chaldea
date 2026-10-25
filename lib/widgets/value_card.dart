import 'package:auto_size_text/auto_size_text.dart';
import 'package:material_ui/material_ui.dart';

/// Compact tile for one value: a muted label above a larger value.
///
/// The value area is plain text by default; pass [options] plus [onSelected] to
/// turn it into a compact dropdown, which keeps an enum in one card instead of
/// spending a whole [ListTile] row on a trailing menu.
///
/// A card carries its own surface, so several of them can share a row without
/// the dividers a column of [ListTile]s would need.
class ValueCard<T> extends StatelessWidget {
  final String label;

  /// Text value, also used as the placeholder for a disabled dropdown.
  final String? value;
  final VoidCallback? onTap;

  /// Share of the row this card takes; 2 gives it twice the width of a 1.
  final int flex;

  /// Selectable values. A missing [onSelected] disables the dropdown, and
  /// [optionValue] marks the current one.
  final List<T>? options;
  final T? optionValue;
  final ValueChanged<T>? onSelected;
  final String Function(T option)? optionLabel;

  const ValueCard({
    super.key,
    required this.label,
    this.value,
    this.onTap,
    this.flex = 1,
    this.options,
    this.optionValue,
    this.onSelected,
    this.optionLabel,
  }) : assert(value != null || options != null, 'ValueCard needs a value or dropdown options');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final valueStyle = textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);
    final options = this.options;
    final onSelected = this.onSelected;

    final Widget valueWidget;
    if (options != null) {
      valueWidget = DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isDense: true,
          isExpanded: true,
          value: optionValue,
          style: valueStyle,
          disabledHint: value == null ? null : Text(value!, maxLines: 1, overflow: TextOverflow.ellipsis),
          items: [
            for (final option in options)
              DropdownMenuItem<T>(
                value: option,
                child: Text(optionLabel?.call(option) ?? '$option', maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onSelected == null || options.isEmpty
              ? null
              : (selected) {
                  if (selected != null) onSelected(selected);
                },
        ),
      );
    } else {
      // Long values shrink instead of ellipsizing so an id or a list of numbers
      // never loses its tail inside a narrow third of the row.
      valueWidget = AutoSizeText(value ?? '', maxLines: 1, maxFontSize: 16, minFontSize: 10, style: valueStyle);
    }

    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              valueWidget,
            ],
          ),
        ),
      ),
    );
  }
}

/// Lays [cards] out in one row, each taking [ValueCard.flex] shares.
class ValueCardRow extends StatelessWidget {
  final List<ValueCard> cards;
  final EdgeInsetsGeometry padding;

  const ValueCardRow({super.key, required this.cards, this.padding = const EdgeInsets.fromLTRB(8, 8, 8, 8)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          for (final (index, card) in cards.indexed) ...[
            if (index > 0) const SizedBox(width: 8),
            Expanded(flex: card.flex, child: card),
          ],
        ],
      ),
    );
  }
}
