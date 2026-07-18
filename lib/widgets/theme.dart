import 'package:flutter/material.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:chaldea/models/db.dart';

/// Centralized BorderRadius constants per MD3 shape scale.
/// Use these instead of raw BorderRadius.circular() in widget code.
abstract final class AppShape {
  // Use BorderRadius.all(Radius.circular(...)) because BorderRadius.circular
  // is not a const constructor in this Flutter version; values are equal at
  // runtime to BorderRadius.circular(N) so callers can compare directly.
  static const small = BorderRadius.all(Radius.circular(8));
  static const medium = BorderRadius.all(Radius.circular(12));
  static const large = BorderRadius.all(Radius.circular(16));
  static const full = BorderRadius.all(Radius.circular(9999));
}

/// Thin ThemeExtension holding only tokens that ThemeData cannot represent:
/// profile gradient colors and state (success/warning/info) colors with their
/// background variants. All other styling lives in ThemeData component themes.
@immutable
class ExtraThemeData extends ThemeExtension<ExtraThemeData> {
  final Color profileGradientStart;
  final Color profileGradientEnd;
  final Color profileForeground;

  final Color stateSuccess;
  final Color stateWarning;
  final Color stateInfo;
  final Color stateSuccessBg;
  final Color stateWarningBg;
  final Color stateInfoBg;
  final Color stateErrorBg;

  // Accent color used for game-mechanic key value highlights
  // (Lv6/Lv10 thresholds, rarity markers, planned status). Distinct from blue
  // primary AND from regular text. MD3 baseline tertiary tonal palette; AAA
  // contrast in both modes (light 7.6:1, dark 14.1:1).
  final Color accent;

  const ExtraThemeData._({
    required this.profileGradientStart,
    required this.profileGradientEnd,
    required this.profileForeground,
    required this.stateSuccess,
    required this.stateWarning,
    required this.stateInfo,
    required this.stateSuccessBg,
    required this.stateWarningBg,
    required this.stateInfoBg,
    required this.stateErrorBg,
    required this.accent,
  });

  factory ExtraThemeData.forBrightness(Brightness brightness) {
    return brightness == Brightness.dark
        ? const ExtraThemeData._(
            profileGradientStart: Color(0xFF1976D2),
            profileGradientEnd: Color(0xFF42A5F5),
            profileForeground: Color(0xFFFFFFFF),
            stateSuccess: Color(0xFF66BB6A),
            stateWarning: Color(0xFFFFA726),
            stateInfo: Color(0xFF64B5F6),
            stateSuccessBg: Color(0xFF1B3A1E),
            stateWarningBg: Color(0xFF3D2E00),
            stateInfoBg: Color(0xFF0D2744),
            stateErrorBg: Color(0xFF4C1B1B),
            accent: Color(0xFFD0BCFF),
          )
        : const ExtraThemeData._(
            profileGradientStart: Color(0xFF1976D2),
            profileGradientEnd: Color(0xFF2196F3),
            profileForeground: Color(0xFFFFFFFF),
            stateSuccess: Color(0xFF4CAF50),
            stateWarning: Color(0xFFFF9800),
            stateInfo: Color(0xFF2196F3),
            stateSuccessBg: Color(0xFFE8F5E9),
            stateWarningBg: Color(0xFFFFF3E0),
            stateInfoBg: Color(0xFFE3F2FD),
            stateErrorBg: Color(0xFFFFEBEE),
            accent: Color(0xFF6750A4),
          );
  }

  static ExtraThemeData of(BuildContext context) {
    final ext = Theme.of(context).extension<ExtraThemeData>();
    if (ext != null) return ext;
    return ExtraThemeData.forBrightness(Theme.of(context).brightness);
  }

  @override
  ExtraThemeData copyWith({
    Color? profileGradientStart,
    Color? profileGradientEnd,
    Color? profileForeground,
    Color? stateSuccess,
    Color? stateWarning,
    Color? stateInfo,
    Color? stateSuccessBg,
    Color? stateWarningBg,
    Color? stateInfoBg,
    Color? stateErrorBg,
    Color? accent,
  }) {
    return ExtraThemeData._(
      profileGradientStart: profileGradientStart ?? this.profileGradientStart,
      profileGradientEnd: profileGradientEnd ?? this.profileGradientEnd,
      profileForeground: profileForeground ?? this.profileForeground,
      stateSuccess: stateSuccess ?? this.stateSuccess,
      stateWarning: stateWarning ?? this.stateWarning,
      stateInfo: stateInfo ?? this.stateInfo,
      stateSuccessBg: stateSuccessBg ?? this.stateSuccessBg,
      stateWarningBg: stateWarningBg ?? this.stateWarningBg,
      stateInfoBg: stateInfoBg ?? this.stateInfoBg,
      stateErrorBg: stateErrorBg ?? this.stateErrorBg,
      accent: accent ?? this.accent,
    );
  }

  @override
  ExtraThemeData lerp(ExtraThemeData? other, double t) {
    if (other == null) return this;
    return ExtraThemeData._(
      profileGradientStart: Color.lerp(profileGradientStart, other.profileGradientStart, t)!,
      profileGradientEnd: Color.lerp(profileGradientEnd, other.profileGradientEnd, t)!,
      profileForeground: Color.lerp(profileForeground, other.profileForeground, t)!,
      stateSuccess: Color.lerp(stateSuccess, other.stateSuccess, t)!,
      stateWarning: Color.lerp(stateWarning, other.stateWarning, t)!,
      stateInfo: Color.lerp(stateInfo, other.stateInfo, t)!,
      stateSuccessBg: Color.lerp(stateSuccessBg, other.stateSuccessBg, t)!,
      stateWarningBg: Color.lerp(stateWarningBg, other.stateWarningBg, t)!,
      stateInfoBg: Color.lerp(stateInfoBg, other.stateInfoBg, t)!,
      stateErrorBg: Color.lerp(stateErrorBg, other.stateErrorBg, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

@immutable
class AppThemeData {
  final ThemeData themeData;
  final ExtraThemeData extra;
  const AppThemeData(this.themeData, this.extra);

  bool get isDark => themeData.brightness == .dark;
  Color get inlineLinkColor => themeData.colorScheme.secondary;
  Color get accentColor => themeData.colorScheme.primary;
}

abstract final class AppTheme {
  // === Theme factories ===

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  /// Retrieves the [ExtraThemeData] extension from the nearest [Theme].
  /// Falls back to [AppThemeData.forBrightness] if no extension is registered
  /// (e.g., in tests using bare ThemeData).
  static ExtraThemeData ofExtra(BuildContext context) {
    final ext = Theme.of(context).extension<ExtraThemeData>();
    if (ext != null) return ext;
    return ExtraThemeData.forBrightness(Theme.of(context).brightness);
  }

  static AppThemeData of(BuildContext context) {
    final themeData = Theme.of(context);
    final extra = themeData.extension<ExtraThemeData>() ?? ExtraThemeData.forBrightness(Theme.of(context).brightness);
    return AppThemeData(themeData, extra);
  }

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    ThemeData themeData = (isDark ? FlexThemeData.dark : FlexThemeData.light)(
      scheme: db.settings.flexScheme,
      subThemesData: FlexSubThemesData(
        //
        inputDecoratorBorderType: .outline,
        useInputDecoratorThemeInDialogs: true,
      ),
      extensions: {ExtraThemeData.forBrightness(brightness)},
    );
    final cs = themeData.colorScheme;
    themeData = themeData.copyWith(
      tooltipTheme: themeData.tooltipTheme.copyWith(waitDuration: const Duration(milliseconds: 500)),
      appBarTheme: themeData.appBarTheme.copyWith(
        titleSpacing: 0,
        toolbarHeight: 48, // kToolbarHeight=56,
      ),
      listTileTheme: themeData.listTileTheme.copyWith(minLeadingWidth: 24),
      cardTheme: themeData.cardTheme.copyWith(color: cs.surfaceContainer, elevation: 0),
    );
    return themeData;

    // final seedColor = db.settings.colorSeed;
    // // final cs = isDark ? AppColorScheme.dark : AppColorScheme.light;
    // final cs = seedColor == null
    //     ? (isDark ? ColorScheme.dark() : ColorScheme.light())
    //     : ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
    //     FlexThemeData.light();

    // return ThemeData(
    //   brightness: brightness,
    //   useMaterial3: true,
    //   extensions: {AppThemeData.forBrightness(brightness)},
    // );

    //  ThemeData(
    //   cardTheme: CardThemeData(
    //     color: cs.surfaceContainer,
    //     elevation: 0,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: AppShape.medium,
    //       side: BorderSide(color: cs.outlineVariant, width: 1),
    //     ),
    //   ),
    //   inputDecorationTheme: InputDecorationTheme(
    //     filled: true,
    //     fillColor: cs.surfaceContainerHighest,
    //     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    //     enabledBorder: border,
    //     focusedBorder: focusedBorder,
    //     errorBorder: errorBorder,
    //     focusedErrorBorder: errorBorder.copyWith(borderSide: BorderSide(color: cs.error, width: 2)),
    //     disabledBorder: border.copyWith(borderSide: BorderSide(color: cs.outlineVariant.withAlpha(80), width: 1)),
    //     labelStyle: TextStyle(color: cs.onSurfaceVariant),
    //     hintStyle: TextStyle(color: cs.onSurfaceVariant),
    //   ),
    //   filledButtonTheme: FilledButtonThemeData(
    //     style: FilledButton.styleFrom(
    //       minimumSize: const Size(0, 48),
    //       shape: RoundedRectangleBorder(borderRadius: AppShape.small),
    //     ),
    //   ),
    //   outlinedButtonTheme: OutlinedButtonThemeData(
    //     style: OutlinedButton.styleFrom(
    //       minimumSize: const Size(0, 48),
    //       shape: RoundedRectangleBorder(borderRadius: AppShape.small),
    //       side: BorderSide(color: cs.outline, width: 1),
    //     ),
    //   ),
    //   dividerTheme: DividerThemeData(thickness: 0.5, color: cs.outlineVariant),
    //   listTileTheme: const ListTileThemeData(minLeadingWidth: 24),
    //   tooltipTheme: const TooltipThemeData(waitDuration: Duration(milliseconds: 500)),
    //   extensions: {AppThemeData.forBrightness(brightness)},
    // );
  }
}
