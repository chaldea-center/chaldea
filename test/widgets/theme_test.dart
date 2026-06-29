import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/widgets/theme.dart';

void main() {
  group('AppTheme', () {
    test('light() yields M3 light theme with light-blue seed', () {
      final theme = AppTheme.light();
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, const Color(0xFF1976D2));
      expect(theme.colorScheme.onPrimary, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.surface, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.surfaceContainerHighest, const Color(0xFFF5F5F5));
      expect(theme.colorScheme.outline, const Color(0xFFBDBDBD));
      expect(theme.colorScheme.outlineVariant, const Color(0xFFE0E0E0));
      expect(theme.colorScheme.onSurface, const Color(0xFF212121));
      expect(theme.colorScheme.onSurfaceVariant, const Color(0xFF757575));
      expect(theme.colorScheme.error, const Color(0xFFF44336));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFAFAFA));
    });

    test('light() registers AppThemeData extension with light values', () {
      final tokens = AppTheme.light().extension<AppThemeData>();
      expect(tokens, isNotNull);
      expect(tokens!.profileGradientStart, const Color(0xFF1976D2));
      expect(tokens.profileGradientEnd, const Color(0xFF2196F3));
      expect(tokens.profileForeground, const Color(0xFFFFFFFF));
      expect(tokens.stateSuccess, const Color(0xFF4CAF50));
      expect(tokens.stateWarning, const Color(0xFFFF9800));
      expect(tokens.stateInfo, const Color(0xFF2196F3));
      expect(tokens.accent, const Color(0xFF6750A4));
    });

    test('light() configures component themes', () {
      final theme = AppTheme.light();
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.filledButtonTheme.style?.minimumSize?.resolve({}), const Size(0, 48));
      expect(theme.dividerTheme.thickness, 0.5);
    });

    test('dark() yields M3 dark theme with brightened primary', () {
      final theme = AppTheme.dark();
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, const Color(0xFF90CAF9));
      expect(theme.colorScheme.surface, const Color(0xFF1E1E1E));
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
    });

    test('dark() registers AppThemeData with dark values', () {
      final tokens = AppTheme.dark().extension<AppThemeData>();
      expect(tokens, isNotNull);
      expect(tokens!.profileGradientStart, const Color(0xFF1976D2));
      expect(tokens.profileGradientEnd, const Color(0xFF42A5F5));
      expect(tokens.stateSuccess, const Color(0xFF66BB6A));
      expect(tokens.accent, const Color(0xFFD0BCFF));
    });
  });

  group('AppColorScheme', () {
    test('light has spec values', () {
      const cs = AppColorScheme.light;
      expect(cs.brightness, Brightness.light);
      expect(cs.primary, const Color(0xFF1565C0));
      expect(cs.onPrimary, const Color(0xFFFFFFFF));
      expect(cs.secondary, const Color(0xFF2E7D32));
      expect(cs.tertiary, const Color(0xFF0277BD));
      expect(cs.surface, const Color(0xFFFAFCFF));
      expect(cs.surfaceContainer, const Color(0xFFEEF0F4));
      expect(cs.outline, const Color(0xFF73777F));
      expect(cs.outlineVariant, const Color(0xFFC3C7CF));
      expect(cs.onSurface, const Color(0xFF191C1E));
      expect(cs.onSurfaceVariant, const Color(0xFF43474E));
      expect(cs.error, const Color(0xFFBA1A1A));
    });

    test('dark has spec values', () {
      const cs = AppColorScheme.dark;
      expect(cs.brightness, Brightness.dark);
      expect(cs.primary, const Color(0xFFA2C8FF));
      expect(cs.surface, const Color(0xFF111318));
      expect(cs.surfaceContainer, const Color(0xFF1D2024));
      expect(cs.outlineVariant, const Color(0xFF43474E));
      expect(cs.error, const Color(0xFFFFB4AB));
    });
  });

  group('AppShape', () {
    test('constants match MD3 shape scale', () {
      expect(AppShape.small, BorderRadius.circular(8));
      expect(AppShape.medium, BorderRadius.circular(12));
      expect(AppShape.large, BorderRadius.circular(16));
      expect(AppShape.full, BorderRadius.circular(9999));
    });
  });
}
