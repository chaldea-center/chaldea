// FormInput: a TextFormField wrapper that renders the label ABOVE the field
// (not as InputDecoration.labelText, which floats into the border). Styling
// (fill, border, radius) comes from InputDecorationTheme; this widget only
// adds the label-above layout and optional prefix/suffix icons.

import 'package:flutter/material.dart';

class FormInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool obscure;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool autocorrect;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;

  const FormInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.obscure = false,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.enabled = true,
    this.autocorrect = true,
    this.focusNode,
    this.onChanged,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseDecoration = (decoration ?? const InputDecoration()).copyWith(
      hintText: hint,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          enabled: enabled,
          obscureText: obscure,
          autocorrect: autocorrect,
          focusNode: focusNode,
          onChanged: onChanged,
          decoration: baseDecoration,
        ),
      ],
    );
  }
}
