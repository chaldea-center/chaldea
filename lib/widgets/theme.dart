import 'package:flutter/material.dart';

class AppTheme {
  final BuildContext context;
  AppTheme(this.context);
  ThemeData get themeData => Theme.of(context);
  ColorScheme get colorScheme => themeData.colorScheme;
  bool get useMaterial3 => themeData.useMaterial3;
  bool get isDark => themeData.brightness == Brightness.dark;

  Color get primary => useMaterial3 ? colorScheme.primary : colorScheme.primary;
  Color get secondary => useMaterial3 ? colorScheme.surfaceTint : colorScheme.secondary;
  Color get color => isDark ? colorScheme.errorContainer : colorScheme.error;
}
