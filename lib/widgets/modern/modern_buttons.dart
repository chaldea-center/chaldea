// Modern buttons: primary / secondary / text variants. All consume
// ColorScheme so they auto-flip in dark mode. 48px height.

import 'package:flutter/material.dart';

class ModernPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool danger;

  const ModernPrimaryButton({super.key, required this.label, this.onPressed, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: danger ? cs.error : cs.primary,
        foregroundColor: danger ? cs.onError : cs.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      child: Text(label),
    );
  }
}

class ModernSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const ModernSecondaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: cs.primary,
        side: BorderSide(color: cs.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      child: Text(label),
    );
  }
}

class ModernTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool danger;

  const ModernTextButton({super.key, required this.label, this.onPressed, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: danger ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      child: Text(label),
    );
  }
}
