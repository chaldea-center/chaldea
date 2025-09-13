import 'package:flutter/material.dart';

class CheckboxWithLabel extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Widget label;
  final EdgeInsetsGeometry? padding;
  final bool ink;

  const CheckboxWithLabel({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.padding = const EdgeInsets.only(right: 8),
    this.ink = true,
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
    if (ink) {
      child = InkWell(onTap: onChanged == null ? null : () => onChanged!(!value), child: child);
    }
    return child;
  }
}

class RadioWithLabel<T> extends StatelessWidget {
  final T value;
  final Widget label;
  final EdgeInsetsGeometry? padding;

  const RadioWithLabel({
    super.key,
    required this.value,
    required this.label,
    this.padding = const EdgeInsets.only(right: 8),
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<T>(
          value: value,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        label,
      ],
    );
    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }
    final groupRegistry = RadioGroup.maybeOf<T>(context);
    return InkWell(onTap: groupRegistry == null ? null : () => groupRegistry.onChanged(value), child: child);
  }
}
