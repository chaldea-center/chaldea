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

    test('light() registers ModernTokens extension with light values', () {
      final tokens = AppTheme.light().extension<ModernTokens>();
      expect(tokens, isNotNull);
      expect(tokens!.profileGradientStart, const Color(0xFF1976D2));
      expect(tokens.profileGradientEnd, const Color(0xFF2196F3));
      expect(tokens.profileForeground, const Color(0xFFFFFFFF));
      expect(tokens.stateSuccess, const Color(0xFF4CAF50));
      expect(tokens.stateWarning, const Color(0xFFFF9800));
      expect(tokens.stateInfo, const Color(0xFF2196F3));
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

    test('dark() registers ModernTokens with dark values', () {
      final tokens = AppTheme.dark().extension<ModernTokens>();
      expect(tokens, isNotNull);
      expect(tokens!.profileGradientStart, const Color(0xFF1976D2));
      expect(tokens.profileGradientEnd, const Color(0xFF42A5F5));
      expect(tokens.stateSuccess, const Color(0xFF66BB6A));
    });
  });
}
