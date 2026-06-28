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
