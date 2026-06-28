// ModernThemeData: a ThemeExtension that centralizes color tokens for the
// modern widget set (scaffold, app bar, card, input, profile card). Override
// via `ThemeData(extensions: [myModernTheme])` to restyle all modern widgets
// without touching their code. When absent, widgets fall back to defaults
// derived from ColorScheme, so they work out-of-the-box.

import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

@immutable
class ModernThemeData extends ThemeExtension<ModernThemeData> {
  final Color scaffoldBackground;
  final Color appBarBackground;
  final Color appBarForeground;
  final double appBarHeight;

  final Color cardBackground;
  final Color cardBorder;
  final Color divider;

  final Color inputBackground;
  final Color inputBorder;
  final Color inputFocusedBorder;
  final Color inputErrorBorder;
  final Color inputDisabledBackground;

  final Color profileGradientStart;
  final Color profileGradientEnd;
  final Color profileForeground;

  const ModernThemeData._({
    required this.scaffoldBackground,
    required this.appBarBackground,
    required this.appBarForeground,
    required this.appBarHeight,
    required this.cardBackground,
    required this.cardBorder,
    required this.divider,
    required this.inputBackground,
    required this.inputBorder,
    required this.inputFocusedBorder,
    required this.inputErrorBorder,
    required this.inputDisabledBackground,
    required this.profileGradientStart,
    required this.profileGradientEnd,
    required this.profileForeground,
  });

  /// Default tokens derived from ColorScheme. Works for both light and dark
  /// because ColorScheme already encodes brightness.
  factory ModernThemeData.fromColorScheme(ColorScheme cs) {
    return ModernThemeData._(
      scaffoldBackground: cs.surface,
      appBarBackground: cs.surface,
      appBarForeground: cs.onSurface,
      appBarHeight: 56,
      cardBackground: cs.surfaceContainer,
      // outlineVariant is darker than outline-with-low-alpha, so borders and
      // dividers stay visible in light mode (fixes the original bug).
      cardBorder: cs.outlineVariant,
      divider: cs.outlineVariant,
      inputBackground: cs.surfaceContainerHighest,
      inputBorder: cs.outlineVariant,
      inputFocusedBorder: cs.primary,
      inputErrorBorder: cs.error,
      inputDisabledBackground: cs.surfaceContainerHighest.withAlpha(100),
      profileGradientStart: cs.primary,
      profileGradientEnd: Color.lerp(cs.primary, cs.onPrimary, 0.25) ?? cs.primary,
      profileForeground: cs.onPrimary,
    );
  }

  /// Reads the extension from the active ThemeData; falls back to
  /// ColorScheme-derived defaults when no extension is registered.
  static ModernThemeData of(BuildContext context) {
    final ext = Theme.of(context).extension<ModernThemeData>();
    if (ext != null) return ext;
    return ModernThemeData.fromColorScheme(Theme.of(context).colorScheme);
  }

  @override
  ModernThemeData copyWith({
    Color? scaffoldBackground,
    Color? appBarBackground,
    Color? appBarForeground,
    double? appBarHeight,
    Color? cardBackground,
    Color? cardBorder,
    Color? divider,
    Color? inputBackground,
    Color? inputBorder,
    Color? inputFocusedBorder,
    Color? inputErrorBorder,
    Color? inputDisabledBackground,
    Color? profileGradientStart,
    Color? profileGradientEnd,
    Color? profileForeground,
  }) {
    return ModernThemeData._(
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      appBarBackground: appBarBackground ?? this.appBarBackground,
      appBarForeground: appBarForeground ?? this.appBarForeground,
      appBarHeight: appBarHeight ?? this.appBarHeight,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      divider: divider ?? this.divider,
      inputBackground: inputBackground ?? this.inputBackground,
      inputBorder: inputBorder ?? this.inputBorder,
      inputFocusedBorder: inputFocusedBorder ?? this.inputFocusedBorder,
      inputErrorBorder: inputErrorBorder ?? this.inputErrorBorder,
      inputDisabledBackground: inputDisabledBackground ?? this.inputDisabledBackground,
      profileGradientStart: profileGradientStart ?? this.profileGradientStart,
      profileGradientEnd: profileGradientEnd ?? this.profileGradientEnd,
      profileForeground: profileForeground ?? this.profileForeground,
    );
  }

  @override
  ModernThemeData lerp(ModernThemeData? other, double t) {
    if (other == null) return this;
    return ModernThemeData._(
      scaffoldBackground: Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      appBarBackground: Color.lerp(appBarBackground, other.appBarBackground, t)!,
      appBarForeground: Color.lerp(appBarForeground, other.appBarForeground, t)!,
      appBarHeight: lerpDouble(appBarHeight, other.appBarHeight, t) ?? appBarHeight,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputFocusedBorder: Color.lerp(inputFocusedBorder, other.inputFocusedBorder, t)!,
      inputErrorBorder: Color.lerp(inputErrorBorder, other.inputErrorBorder, t)!,
      inputDisabledBackground: Color.lerp(inputDisabledBackground, other.inputDisabledBackground, t)!,
      profileGradientStart: Color.lerp(profileGradientStart, other.profileGradientStart, t)!,
      profileGradientEnd: Color.lerp(profileGradientEnd, other.profileGradientEnd, t)!,
      profileForeground: Color.lerp(profileForeground, other.profileForeground, t)!,
    );
  }
}
