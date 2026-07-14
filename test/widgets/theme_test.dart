import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/widgets/theme.dart';

void main() {
  group('AppTheme', () {
    test('light() yields M3 light theme with light-blue seed', () {
      final theme = AppTheme.light();
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, const Color(0xFF1565C0));
      expect(theme.colorScheme.onPrimary, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.surface, const Color(0xFFFAFCFF));
      expect(theme.colorScheme.surfaceContainerHighest, const Color(0xFFE3E6EA));
      expect(theme.colorScheme.outline, const Color(0xFF73777F));
      expect(theme.colorScheme.outlineVariant, const Color(0xFFC3C7CF));
      expect(theme.colorScheme.onSurface, const Color(0xFF191C1E));
      expect(theme.colorScheme.onSurfaceVariant, const Color(0xFF43474E));
      expect(theme.colorScheme.error, const Color(0xFFBA1A1A));
      expect(theme.scaffoldBackgroundColor, theme.colorScheme.surface);
    });

    test('light() registers AppThemeData extension with light values', () {
      final tokens = AppTheme.light().extension<ExtraThemeData>();
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
      expect(theme.colorScheme.primary, const Color(0xFFA2C8FF));
      expect(theme.colorScheme.surface, const Color(0xFF111318));
      expect(theme.scaffoldBackgroundColor, theme.colorScheme.surface);
    });

    test('dark() registers AppThemeData with dark values', () {
      final tokens = AppTheme.dark().extension<ExtraThemeData>();
      expect(tokens, isNotNull);
      expect(tokens!.profileGradientStart, const Color(0xFF1976D2));
      expect(tokens.profileGradientEnd, const Color(0xFF42A5F5));
      expect(tokens.stateSuccess, const Color(0xFF66BB6A));
      expect(tokens.accent, const Color(0xFFD0BCFF));
    });

    test('light() component themes use cs.* per spec', () {
      final theme = AppTheme.light();
      final cs = theme.colorScheme;
      expect(theme.scaffoldBackgroundColor, cs.surface);
      expect(theme.appBarTheme.backgroundColor, cs.surface);
      expect(theme.dividerTheme.color, cs.outlineVariant);
      expect(theme.cardTheme.color, cs.surfaceContainer);
      expect(theme.cardTheme.shape, isA<RoundedRectangleBorder>());
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(cardShape.borderRadius, AppShape.medium);
    });

    test('dark() component themes use cs.* per spec', () {
      final theme = AppTheme.dark();
      final cs = theme.colorScheme;
      expect(theme.scaffoldBackgroundColor, cs.surface);
      expect(theme.appBarTheme.backgroundColor, cs.surface);
      expect(theme.dividerTheme.color, cs.outlineVariant);
      expect(theme.cardTheme.color, cs.surfaceContainer);
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

  group('AppTheme.of(context)', () {
    testWidgets('returns registered AppThemeData from theme', (tester) async {
      ExtraThemeData? captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) {
              captured = AppTheme.ofExtra(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured, isNotNull);
      expect(captured!.accent, const Color(0xFF6750A4));
    });

    testWidgets('falls back to AppThemeData.forBrightness when no extension', (tester) async {
      ExtraThemeData? captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
          home: Builder(
            builder: (context) {
              captured = AppTheme.ofExtra(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(captured, isNotNull);
      expect(captured!.accent, const Color(0xFF6750A4));
    });
  });
}
