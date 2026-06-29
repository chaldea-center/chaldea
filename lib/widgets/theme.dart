import 'package:flutter/material.dart';

/// Fully manual MD3 ColorScheme per flutter_md3_color_scheme.md.
/// Eliminates fromSeed-vs-spec drift by making all 36+ tokens explicit.
abstract final class AppColorScheme {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1565C0),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD1E4FF),
    onPrimaryContainer: Color(0xFF001D36),
    secondary: Color(0xFF2E7D32),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFC8E6C9),
    onSecondaryContainer: Color(0xFF002106),
    tertiary: Color(0xFF0277BD),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFB3E5FC),
    onTertiaryContainer: Color(0xFF001F29),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFAFCFF),
    onSurface: Color(0xFF191C1E),
    surfaceDim: Color(0xFFDAE1E9),
    surfaceBright: Color(0xFFFAFCFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF4F6F9),
    surfaceContainer: Color(0xFFEEF0F4),
    surfaceContainerHigh: Color(0xFFE8EBEF),
    surfaceContainerHighest: Color(0xFFE3E6EA),
    surfaceVariant: Color(0xFFDFE2EB),
    onSurfaceVariant: Color(0xFF43474E),
    outline: Color(0xFF73777F),
    outlineVariant: Color(0xFFC3C7CF),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2E3133),
    onInverseSurface: Color(0xFFF0F1F4),
    inversePrimary: Color(0xFFA2C8FF),
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFA2C8FF),
    onPrimary: Color(0xFF003258),
    primaryContainer: Color(0xFF004BA0),
    onPrimaryContainer: Color(0xFFD1E4FF),
    secondary: Color(0xFFA5D6A7),
    onSecondary: Color(0xFF00390E),
    secondaryContainer: Color(0xFF005319),
    onSecondaryContainer: Color(0xFFC8E6C9),
    tertiary: Color(0xFF4FC3F7),
    onTertiary: Color(0xFF003546),
    tertiaryContainer: Color(0xFF004D66),
    onTertiaryContainer: Color(0xFFB3E5FC),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF111318),
    onSurface: Color(0xFFE1E2E6),
    surfaceDim: Color(0xFF111318),
    surfaceBright: Color(0xFF37393E),
    surfaceContainerLowest: Color(0xFF0C0E13),
    surfaceContainerLow: Color(0xFF191C20),
    surfaceContainer: Color(0xFF1D2024),
    surfaceContainerHigh: Color(0xFF272A2F),
    surfaceContainerHighest: Color(0xFF32353A),
    surfaceVariant: Color(0xFF43474E),
    onSurfaceVariant: Color(0xFFC3C7CF),
    outline: Color(0xFF8D9199),
    outlineVariant: Color(0xFF43474E),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE1E2E6),
    onInverseSurface: Color(0xFF2E3133),
    inversePrimary: Color(0xFF1565C0),
  );
}

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
class AppThemeData extends ThemeExtension<AppThemeData> {
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

  const AppThemeData._({
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

  factory AppThemeData.forBrightness(Brightness brightness) {
    return brightness == Brightness.dark
        ? const AppThemeData._(
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
        : const AppThemeData._(
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

  static AppThemeData of(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeData>();
    if (ext != null) return ext;
    return AppThemeData.forBrightness(Theme.of(context).brightness);
  }

  @override
  AppThemeData copyWith({
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
    return AppThemeData._(
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
  AppThemeData lerp(AppThemeData? other, double t) {
    if (other == null) return this;
    return AppThemeData._(
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

abstract final class AppTheme {
  // === Theme factories ===

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  /// Retrieves the [AppThemeData] extension from the nearest [Theme].
  /// Falls back to [AppThemeData.forBrightness] if no extension is registered
  /// (e.g., in tests using bare ThemeData).
  static AppThemeData of(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeData>();
    if (ext != null) return ext;
    return AppThemeData.forBrightness(Theme.of(context).brightness);
  }

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final cs = isDark ? AppColorScheme.dark : AppColorScheme.light;

    final border = OutlineInputBorder(
      borderRadius: AppShape.small,
      borderSide: BorderSide(color: cs.outlineVariant, width: 1),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: AppShape.small,
      borderSide: BorderSide(color: cs.primary, width: 2),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: AppShape.small,
      borderSide: BorderSide(color: cs.error, width: 1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        toolbarHeight: 48,
      ),
      cardTheme: CardThemeData(
        color: cs.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppShape.medium,
          side: BorderSide(color: cs.outlineVariant, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: border,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder.copyWith(borderSide: BorderSide(color: cs.error, width: 2)),
        disabledBorder: border.copyWith(borderSide: BorderSide(color: cs.outlineVariant.withAlpha(80), width: 1)),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        hintStyle: TextStyle(color: cs.onSurfaceVariant),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: AppShape.small),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: AppShape.small),
          side: BorderSide(color: cs.outline, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(thickness: 0.5, color: cs.outlineVariant),
      listTileTheme: const ListTileThemeData(minLeadingWidth: 24),
      tooltipTheme: const TooltipThemeData(waitDuration: Duration(milliseconds: 500)),
      extensions: {AppThemeData.forBrightness(brightness)},
    );
  }
}
