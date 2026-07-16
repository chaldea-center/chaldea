import 'package:flutter/material.dart';

import 'controls_data_page.dart';
import 'surfaces_page.dart';
import 'typography_buttons_page.dart';

/// Entry page for the MD3 showcase. Lists 3 subpage entries.
///
/// [standalone] controls visibility of the theme-mode toggle in the AppBar:
/// - `true` (default when run via [ShowcaseApp]): AppBar action cycles light/dark/system
/// - `false` (when pushed from `theme_palette`): toggle hidden, host app controls theme
class ShowcaseHomePage extends StatelessWidget {
  final bool standalone;
  final VoidCallback? onModeToggle;
  final ThemeMode? currentMode;

  const ShowcaseHomePage({super.key, this.standalone = false, this.onModeToggle, this.currentMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: standalone ? null : const BackButton(),
        title: const Text('MD3 Showcase'),
        actions: [
          if (standalone && onModeToggle != null)
            IconButton(
              onPressed: onModeToggle,
              icon: Icon(_modeIcon(currentMode ?? ThemeMode.system)),
              tooltip: _modeTooltip(currentMode ?? ThemeMode.system),
            ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.layers_outlined),
            title: const Text('Surfaces & Layout'),
            subtitle: const Text('Scaffold, Card variants, AppBar, FAB, Divider'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SurfacesPage())),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Typography & Buttons'),
            subtitle: const Text('Type scale, text colors, button types, TextField states'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TypographyButtonsPage())),
          ),
          ListTile(
            leading: const Icon(Icons.toggle_on_outlined),
            title: const Text('Controls & Data'),
            subtitle: const Text('Checkbox, Radio, Switch, Slider, TabBar, Chips, DataTable'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ControlsDataPage())),
          ),
        ],
      ),
    );
  }

  IconData _modeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.settings_brightness_outlined;
    }
  }

  String _modeTooltip(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light (tap for dark)';
      case ThemeMode.dark:
        return 'Dark (tap for system)';
      case ThemeMode.system:
        return 'System (tap for light)';
    }
  }
}
