import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

class ThemeColorPage extends StatefulWidget {
  const ThemeColorPage({super.key});

  @override
  State<ThemeColorPage> createState() => _ThemeColorPageState();
}

class _ThemeColorPageState extends State<ThemeColorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Theme Color"),
      ),
      body: ListView(
        children: [
          TileGroup(
            header: S.current.dark_mode,
            children: [
              for (final mode in ThemeMode.values)
                RadioListTile.adaptive(
                  value: mode,
                  groupValue: db.settings.themeMode,
                  title: Text(getThemeModeName(mode)),
                  onChanged: (v) {
                    if (v != null && v != db.settings.themeMode) {
                      db.settings.themeMode = v;
                      db.notifySettings();
                      db.notifyAppUpdate();
                    }
                    setState(() {});
                  },
                ),
            ],
          ),
          TileGroup(
            header: 'Material 3',
            children: [
              RadioListTile.adaptive(
                value: null,
                groupValue: db.settings.m3Color,
                title: const Text('Use Material 2'),
                onChanged: (v) {
                  if (v != db.settings.m3Color) {
                    db.settings.m3Color = v;
                    db.notifySettings();
                    db.notifyAppUpdate();
                  }
                  setState(() {});
                },
              ),
              for (final seed in ColorSeed.values)
                RadioListTile.adaptive(
                  value: seed,
                  groupValue: db.settings.m3Color,
                  title: Text(seed.label),
                  secondary: Container(width: 24, height: 24, color: seed.color),
                  onChanged: (v) {
                    if (v != null && v != db.settings.m3Color) {
                      db.settings.m3Color = v;
                      db.notifySettings();
                      db.notifyAppUpdate();
                    }
                    setState(() {});
                  },
                ),
            ],
          )
        ],
      ),
    );
  }

  String getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return S.current.dark_mode_system;
      case ThemeMode.light:
        return S.current.dark_mode_light;
      case ThemeMode.dark:
        return S.current.dark_mode_dark;
    }
  }
}
