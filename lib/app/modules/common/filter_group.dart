import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/userdata/filter_data.dart';
import '../../../widgets/widgets.dart';

// for filter items
typedef FilterCallBack<T> = bool Function(T data);

class FilterGroup<T> extends StatelessWidget {
  final Widget? title;
  final List<T> options;
  final FilterGroupData<T> values;
  final Widget Function(T value)? optionBuilder;
  final bool enabled;
  final bool showMatchAll;
  final bool showInvert;
  final bool shrinkWrap;
  final void Function(FilterGroupData<T> optionData, T? lastChanged)? onFilterChanged;

  final bool combined;
  final EdgeInsetsGeometry padding;
  final bool showCollapse;
  final BoxConstraints? constraints;
  final Size? minimumSize;
  final ButtonStyle? buttonStyle;

  const FilterGroup({
    super.key,
    this.title,
    required this.options,
    required this.values,
    this.optionBuilder,
    this.enabled = true,
    this.showMatchAll = false,
    this.showInvert = false,
    this.shrinkWrap = false,
    this.onFilterChanged,
    this.combined = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.showCollapse = false,
    this.constraints,
    this.minimumSize,
    this.buttonStyle,
  });

  static FilterGroup display({required bool useGrid, required ValueChanged<bool?> onChanged}) {
    return FilterGroup<bool>(
      padding: EdgeInsets.zero,
      options: const [false, true],
      values: FilterRadioData.nonnull(useGrid),
      optionBuilder:
          (v) => Text.rich(
            TextSpan(
              children: [
                CenterWidgetSpan(child: Icon(v ? Icons.grid_view_sharp : Icons.list, size: 16)),
                const TextSpan(text: ' '),
                TextSpan(text: v ? S.current.display_grid : S.current.display_list),
              ],
            ),
          ),
      combined: true,
      onFilterChanged: (v, _) {
        onChanged(v.radioValue);
      },
    );
  }

  Widget _buildCheckbox(BuildContext context, bool checked, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Row(
        children: <Widget>[
          Icon(checked ? Icons.check_box : Icons.check_box_outline_blank, color: Colors.grey),
          Text(text, textScaler: const TextScaler.linear(0.8)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _optionChildren = [];
    for (int index = 0; index < options.length; index++) {
      final key = options[index];
      _optionChildren.add(
        FilterOption(
          selected: values.options.contains(key),
          value: key,
          shrinkWrap: shrinkWrap,
          constraints: constraints,
          minimumSize: minimumSize,
          buttonStyle: buttonStyle,
          borderRadius:
              combined
                  ? BorderRadius.horizontal(
                    left: Radius.circular(index == 0 ? 3 : 0),
                    right: Radius.circular(index == options.length - 1 ? 3 : 0),
                  )
                  : BorderRadius.circular(3),
          onChanged: (v) {
            values.toggle(key);
            if (onFilterChanged != null) {
              onFilterChanged!(values, key);
            }
          },
          enabled: enabled,
          child: optionBuilder == null ? Text(key.toString()) : optionBuilder!(key),
        ),
      );
    }

    Widget child = Wrap(spacing: combined ? 0 : 6, runSpacing: 3, children: _optionChildren);

    Widget _getTitle([Widget? expandIcon]) {
      return CustomTile(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: DefaultTextStyle.merge(child: title!, style: const TextStyle(fontSize: 14)),
        ),
        contentPadding: EdgeInsets.zero,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (showMatchAll)
              _buildCheckbox(context, values.matchAll, S.current.filter_match_all, () {
                values.matchAll = !values.matchAll;
                if (onFilterChanged != null) {
                  onFilterChanged!(values, null);
                }
              }),
            if (showInvert)
              _buildCheckbox(context, values.invert, S.current.filter_revert, () {
                values.invert = !values.invert;
                if (onFilterChanged != null) {
                  onFilterChanged!(values, null);
                }
              }),
            if (expandIcon != null) expandIcon,
          ],
        ),
      );
    }

    Widget _wrapExpandIcon(Widget _child) {
      return ValueStatefulBuilder<bool>(
        initValue: true,
        builder: (context, value) {
          Widget? expandIcon;
          if (showCollapse) {
            expandIcon = ExpandIcon(
              isExpanded: value.value,
              onPressed: (v) {
                value.value = !value.value;
              },
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[_getTitle(expandIcon), if (value.value) _child],
          );
        },
      );
    }

    if (title != null) {
      if (showCollapse) {
        child = _wrapExpandIcon(child);
      } else {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[_getTitle(), child],
        );
      }
    }

    return Padding(padding: padding, child: child);
  }
}

class FilterOption<T> extends StatelessWidget {
  final bool selected;
  final T value;
  final Widget? child;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final BorderRadius borderRadius;
  final bool shrinkWrap;
  final BoxConstraints? constraints;
  final Size? minimumSize;
  final ButtonStyle? buttonStyle;

  const FilterOption({
    super.key,
    required this.selected,
    required this.value,
    this.child,
    this.onChanged,
    this.enabled = true,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(3)),
    this.shrinkWrap = false,
    this.constraints,
    this.minimumSize,
    this.buttonStyle,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    bool darkMode = themeData.brightness == Brightness.dark;
    final selectedColor =
        this.selectedColor ??
        (themeData.useMaterial3 && darkMode ? themeData.colorScheme.primaryContainer : themeData.colorScheme.primary);
    return ConstrainedBox(
      constraints: constraints ?? const BoxConstraints(maxHeight: 30),
      child: OutlinedButton(
        onPressed:
            enabled
                ? () {
                  if (onChanged != null) {
                    onChanged!(!selected);
                  }
                }
                : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: selected || darkMode ? Colors.white : Colors.black,
          backgroundColor:
              selected
                  ? (enabled ? selectedColor : selectedColor.withValues(alpha: selectedColor.a * 0.5))
                  : unselectedColor,
          minimumSize: minimumSize ?? (shrinkWrap ? const Size(2, 2) : const Size(48, 36)),
          padding: shrinkWrap ? const EdgeInsets.all(0) : null,
          textStyle: const TextStyle(fontWeight: FontWeight.normal),
          // tapTargetSize: shrinkWrap ? MaterialTapTargetSize.shrinkWrap : null,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: ContinuousRectangleBorder(borderRadius: borderRadius),
          side: themeData.useMaterial3 ? BorderSide(color: themeData.colorScheme.outline, width: 0.5) : null,
        ).merge(buttonStyle),
        child: child ?? Text(value.toString()),
        // shape: ,
      ),
    );
  }
}
