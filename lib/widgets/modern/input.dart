// FormInput: a TextFormField wrapper that renders the label ABOVE the field
// (not as InputDecoration.labelText, which floats into the border). Styling
// (fill, border, radius) comes from InputDecorationTheme; this widget only
// adds the label-above layout and optional prefix/suffix icons.
//
// This widget encapsulates the "touched" mechanism: error display is
// controlled by [errorDisplayMode] and [forceShowError], so callers no
// longer need to track focus/blur state manually.

import 'package:flutter/material.dart';

/// Controls when [FormInput] displays validation errors.
enum ErrorDisplayMode {
  /// Show error after first blur, then on every change. (Default)
  onBlur,

  /// Show error only after [forceShowError] is set true (e.g., after submit).
  onSubmit,

  /// Show error on every change.
  onChange,
}

class FormInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final bool obscure;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final String? Function(String) validator;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool autocorrect;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;
  final ErrorDisplayMode errorDisplayMode;
  final bool forceShowError;

  const FormInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.obscure = false,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    required this.validator,
    this.keyboardType,
    this.enabled = true,
    this.autocorrect = true,
    this.focusNode,
    this.onChanged,
    this.decoration,
    this.errorDisplayMode = ErrorDisplayMode.onBlur,
    this.forceShowError = false,
  });

  @override
  State<FormInput> createState() => _FormInputState();
}

class _FormInputState extends State<FormInput> {
  late final FocusNode _focusNode;
  late bool _hasFocus;
  bool _touched = false;
  String? _error;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _hasFocus = _focusNode.hasFocus;
    _focusNode.addListener(_onFocusChange);
    _error = _computeError();
  }

  @override
  void didUpdateWidget(FormInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forceShowError && !oldWidget.forceShowError) {
      _error = _computeError();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    final hasFocus = _focusNode.hasFocus;
    if (_hasFocus && !hasFocus) {
      // Blurred — mark as touched and recompute error.
      _touched = true;
      _error = _computeError();
    }
    _hasFocus = hasFocus;
    setState(() {});
  }

  String? _computeError() {
    final value = widget.controller?.text ?? '';
    return widget.validator(value);
  }

  void _onChanged(String value) {
    if (widget.errorDisplayMode == ErrorDisplayMode.onChange) {
      _error = _computeError();
    } else if (_touched) {
      _error = _computeError();
    } else if (widget.forceShowError) {
      _error = _computeError();
    } else {
      _error = null;
    }
    setState(() {});
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseDecoration = (widget.decoration ?? const InputDecoration()).copyWith(
      hintText: widget.hint,
      helperText: widget.helperText,
      errorText: _error,
      prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
      suffixIcon: widget.suffixIcon,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.label!,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          obscureText: widget.obscure,
          autocorrect: widget.autocorrect,
          focusNode: _focusNode,
          onChanged: _onChanged,
          decoration: baseDecoration,
        ),
      ],
    );
  }
}
