import 'package:flutter/material.dart';

class CheckboxWithText extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Widget label;

  const CheckboxWithText(
      {Key? key,
        required this.value,
        required this.onChanged,
        required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: value, onChanged: onChanged),
        GestureDetector(
          onTap: () {
            if (onChanged != null) {
              onChanged!(!value);
            }
          },
          child: label,
        )
      ],
    );
  }
}
