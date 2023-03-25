import 'package:flutter/material.dart';

class CheckboxWithLabel extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Widget label;
  final EdgeInsetsGeometry? padding;

  const CheckboxWithLabel({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.padding = const EdgeInsets.only(right: 8),
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        label,
      ],
    );
    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: child,
    );
  }
}

class RadioWithLabel<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final Widget label;
  final EdgeInsetsGeometry? padding;

  const RadioWithLabel({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
    this.padding = const EdgeInsets.only(right: 8),
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        label,
      ],
    );
    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(value),
      child: child,
    );
  }
}
