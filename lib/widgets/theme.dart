import 'package:flutter/material.dart';

/// Thin ThemeExtension holding only tokens that ThemeData cannot represent:
/// profile gradient colors and state (success/warning/info) colors with their
/// background variants. All other styling lives in ThemeData component themes.
@immutable
class ModernTokens extends ThemeExtension<ModernTokens> {
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

  const ModernTokens._({
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
  });

  factory ModernTokens.forBrightness(Brightness brightness) {
    return brightness == Brightness.dark
        ? const ModernTokens._(
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
          )
        : const ModernTokens._(
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
          );
  }

  static ModernTokens of(BuildContext context) {
    final ext = Theme.of(context).extension<ModernTokens>();
    if (ext != null) return ext;
    return ModernTokens.forBrightness(Theme.of(context).brightness);
  }

  @override
  ModernTokens copyWith({
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
  }) {
    return ModernTokens._(
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
    );
  }

  @override
  ModernTokens lerp(ModernTokens? other, double t) {
    if (other == null) return this;
    return ModernTokens._(
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
    );
  }
}

class AppTheme {
  final BuildContext context;
  AppTheme(this.context);

  // === Theme factories ===

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2), brightness: brightness);

    // Targeted overrides for design-token fidelity. We override at ColorScheme
    // level only where fromSeed's tonal palette diverges meaningfully from the
    // chaldea-auth-ui-design token mapping.
    final cs = base.copyWith(
      primary: isDark ? const Color(0xFF90CAF9) : const Color(0xFF1976D2),
      onPrimary: isDark ? const Color(0xFF003258) : const Color(0xFFFFFFFF),
      surface: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
      surfaceContainerHighest: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
      outline: isDark ? const Color(0xFF424242) : const Color(0xFFBDBDBD),
      outlineVariant: isDark ? const Color(0xFF383838) : const Color(0xFFE0E0E0),
      onSurface: isDark ? const Color(0xFFECECEC) : const Color(0xFF212121),
      onSurfaceVariant: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF757575),
      error: isDark ? const Color(0xFFEF5350) : const Color(0xFFF44336),
    );

    final fillColor = cs.surfaceContainerHighest;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: cs.outlineVariant, width: 1),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: cs.primary, width: 2),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: cs.error, width: 1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA),
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        toolbarHeight: 48,
      ),
      cardTheme: CardThemeData(
        color: cs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cs.outlineVariant, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fillColor,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: cs.outline, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(thickness: 0.5, color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE)),
      listTileTheme: const ListTileThemeData(minLeadingWidth: 24),
      tooltipTheme: const TooltipThemeData(waitDuration: Duration(milliseconds: 500)),
      extensions: {ModernTokens.forBrightness(brightness)},
    );
  }

  // === Retained context shortcuts (used across non-auth pages) ===

  ThemeData get themeData => Theme.of(context);
  ColorScheme get colorScheme => themeData.colorScheme;
  bool get useMaterial3 => themeData.useMaterial3;
  bool get isDark => themeData.brightness == Brightness.dark;
  Color get primary => colorScheme.primary;
  Color get tertiary => colorScheme.tertiary;
  Color get tertiaryContainer => colorScheme.tertiaryContainer;
  Color get color => isDark ? colorScheme.errorContainer : colorScheme.error;
}
