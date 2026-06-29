import 'package:flutter/material.dart';

import 'package:chaldea/widgets/theme.dart';

import 'showcase_home_page.dart';

/// Standalone MaterialApp wrapper for running the showcase in isolation
/// (e.g., via `flutter run -t lib/app/modules/misc/showcase/showcase_app.dart`).
///
/// When the showcase is opened in-app from `theme_palette.dart`, this wrapper
/// is not used — `ShowcaseHomePage(standalone: false)` is pushed directly.
class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode _nextMode(ThemeMode current) {
    switch (current) {
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
      case ThemeMode.system:
        return ThemeMode.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MD3 Showcase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _mode,
      home: ShowcaseHomePage(
        standalone: true,
        currentMode: _mode,
        onModeToggle: () => setState(() => _mode = _nextMode(_mode)),
      ),
    );
  }
}
