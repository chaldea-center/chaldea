// PrimaryButton / SecondaryButton: thin wrappers around FilledButton /
// OutlinedButton that bake in the 48px height + 8px radius (matching the
// design tokens). A `danger` flag swaps to error/onError. The `style` param
// merges over defaults for per-call overrides.

import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool danger;
  final ButtonStyle? style;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.danger = false,
    this.style,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseStyle = FilledButton.styleFrom(
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: danger ? cs.error : null,
      foregroundColor: danger ? cs.onError : null,
    );
    final merged = style == null ? baseStyle : baseStyle.merge(style);
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: merged,
      child: loading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: danger ? cs.onError : cs.onPrimary),
            )
          : Text(label),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool danger;
  final ButtonStyle? style;
  final bool loading;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.danger = false,
    this.style,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      foregroundColor: danger ? cs.error : cs.primary,
      side: BorderSide(color: danger ? cs.error : cs.outline),
    );
    final merged = style == null ? baseStyle : baseStyle.merge(style);
    return OutlinedButton(
      onPressed: loading ? null : onPressed,
      style: merged,
      child: loading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: danger ? cs.error : cs.primary),
            )
          : Text(label),
    );
  }
}
