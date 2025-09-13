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
      appBar: AppBar(title: Text(S.current.appearance)),
      body: ListView(
        children: [
          RadioGroup<ThemeMode>(
            groupValue: db.settings.themeMode,
            onChanged: (v) {
              if (v != null && v != db.settings.themeMode) {
                db.settings.themeMode = v;
                db.notifySettings();
                db.notifyAppUpdate();
              }
              setState(() {});
            },
            child: TileGroup(
              header: S.current.dark_mode,
              children: [
                for (final mode in ThemeMode.values)
                  RadioListTile<ThemeMode>(value: mode, title: Text(getThemeModeName(mode))),
              ],
            ),
          ),
          RadioGroup<bool>(
            groupValue: db.settings.useMaterial3,
            onChanged: (v) {
              if (v != null && v != db.settings.useMaterial3) {
                db.settings.useMaterial3 = v;
                db.notifySettings();
                db.notifyAppUpdate();
              }
              setState(() {});
            },
            child: TileGroup(
              header: "Material Design",
              children: [
                for (final useM3 in [false, true])
                  RadioListTile<bool>(value: useM3, title: Text(useM3 ? 'Material 3' : 'Material 2')),
              ],
            ),
          ),
          RadioGroup<ColorSeed?>(
            groupValue: db.settings.colorSeed,
            onChanged: (v) {
              if (v != db.settings.colorSeed) {
                db.settings.colorSeed = v;
                db.notifySettings();
                db.notifyAppUpdate();
              }
              setState(() {});
            },
            child: TileGroup(
              header: 'Theme Color',
              children: [
                for (final seed in [null, ...ColorSeed.values])
                  RadioListTile<ColorSeed?>(
                    value: seed,
                    title: Text(seed?.label ?? S.current.general_default),
                    secondary: seed == null ? null : Container(width: 24, height: 24, color: seed.color),
                  ),
              ],
            ),
          ),
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
