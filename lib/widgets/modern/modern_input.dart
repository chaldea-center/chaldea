// ModernInput: 48px-tall input with optional icon prefix, label, helper text,
// error text, and visibility toggle. Borders use ModernThemeData.inputBorder
// (outlineVariant by default) so they are clearly visible in both light and
// dark mode — the original AuthInput used outline.withAlpha(80) which was
// nearly invisible in light mode.

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'modern_theme.dart';

class ModernInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final String placeholder;
  final IconData? icon;
  final String? helperText;
  final String? errorText;
  final bool obscure;
  final VoidCallback? onToggleVisibility;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const ModernInput({
    super.key,
    this.label,
    this.hint,
    this.placeholder = '',
    this.icon,
    this.helperText,
    this.errorText,
    this.obscure = false,
    this.onToggleVisibility,
    this.controller,
    this.keyboardType,
    this.autocorrect = true,
    this.focusNode,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ModernThemeData.of(context);
    final cs = Theme.of(context).colorScheme;
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
          ),
        ],
        _buildField(context, theme, cs, hasError),
        if (hasError) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(errorText!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.error)),
          ),
        ] else if (helperText != null && helperText!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              helperText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildField(BuildContext context, ModernThemeData theme, ColorScheme cs, bool hasError) {
    final border = BorderSide(
      color: hasError ? theme.inputErrorBorder : theme.inputBorder,
      width: hasError ? 1.5 : 1,
    );
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: enabled ? theme.inputBackground : theme.inputDisabledBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.fromBorderSide(border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 20, color: cs.onSurfaceVariant), const SizedBox(width: 12)],
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscure,
              autocorrect: autocorrect,
              keyboardType: keyboardType,
              enabled: enabled,
              onChanged: onChanged,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant.withAlpha(180)),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (onToggleVisibility != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onToggleVisibility,
              icon: FaIcon(obscure ? FontAwesomeIcons.solidEyeSlash : FontAwesomeIcons.solidEye, size: 18),
              color: cs.onSurfaceVariant,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: obscure ? 'Show' : 'Hide',
            ),
          ],
        ],
      ),
    );
  }
}
