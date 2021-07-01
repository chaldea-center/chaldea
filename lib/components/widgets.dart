import 'package:flutter/material.dart';

class CheckboxWithLabel extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Widget label;

  const CheckboxWithLabel({
    Key? key,
    required this.value,
    required this.label,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(value: value, onChanged: onChanged),
          label,
        ],
      ),
    );
  }
}

class RadioWithLabel extends StatelessWidget {
  final bool value;
  final bool? groupValue;
  final ValueChanged<bool?>? onChanged;
  final Widget label;

  const RadioWithLabel({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
          ),
          label,
        ],
      ),
    );
  }
}
