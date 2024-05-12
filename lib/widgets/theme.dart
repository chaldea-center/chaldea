import 'package:flutter/material.dart';

class AppTheme {
  final BuildContext context;
  AppTheme(this.context);
  ThemeData get themeData => Theme.of(context);
  ColorScheme get colorScheme => themeData.colorScheme;
  bool get useMaterial3 => themeData.useMaterial3;
  bool get isDark => themeData.brightness == Brightness.dark;

  Color get primary => useMaterial3 ? colorScheme.primary : colorScheme.primary;
  Color get tertiary => useMaterial3 ? colorScheme.tertiary : colorScheme.tertiary;
  Color get tertiaryContainer => useMaterial3 ? colorScheme.tertiaryContainer : colorScheme.tertiaryContainer;
  Color get color => isDark ? colorScheme.errorContainer : colorScheme.error;
}
