import 'package:flex_color_scheme/flex_color_scheme.dart';

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
          // RadioGroup<bool>(
          //   groupValue: db.settings.useMaterial3,
          //   onChanged: (v) {
          //     if (v != null && v != db.settings.useMaterial3) {
          //       db.settings.useMaterial3 = v;
          //       db.notifySettings();
          //       db.notifyAppUpdate();
          //     }
          //     setState(() {});
          //   },
          //   child: TileGroup(
          //     header: "Material Design",
          //     children: [
          //       for (final useM3 in [false, true])
          //         RadioListTile<bool>(value: useM3, title: Text(useM3 ? 'Material 3' : 'Material 2')),
          //     ],
          //   ),
          // ),
          if (1 > 2)
            TileGroup(
              header: 'Surface Mode',
              children: [
                DropdownButton<FlexSurfaceMode>(
                  padding: EdgeInsetsDirectional.only(start: 8),
                  isExpanded: true,
                  value: db.settings.flexSurfaceMode ?? FlexSurfaceMode.level,
                  items: [
                    for (final mode in FlexSurfaceMode.values)
                      DropdownMenuItem(
                        value: mode,
                        child: Text(mode.name, maxLines: 1, overflow: .ellipsis),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null && v != db.settings.flexSurfaceMode) {
                      db.settings.flexSurfaceMode = v;
                      db.notifyAppUpdate();
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
          if (1 > 2)
            TileGroup(
              header: 'Scheme Variant',
              children: [
                DropdownButton<FlexSchemeVariant>(
                  padding: EdgeInsetsDirectional.only(start: 8),
                  isExpanded: true,
                  value: db.settings.flexSchemeVariant,
                  hint: Text(S.current.general_default),
                  items: [
                    for (final variant in FlexSchemeVariant.values)
                      DropdownMenuItem(
                        value: variant,
                        child: Text(variant.name, maxLines: 1, overflow: .ellipsis),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null && v != db.settings.flexSchemeVariant) {
                      db.settings.flexSchemeVariant = v;
                      db.notifyAppUpdate();
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
          TileGroup(
            header: 'Blend Level: ${db.settings.flexBlendLevel ?? 0}',
            children: [
              Padding(
                padding: .symmetric(horizontal: 8),
                child: Slider(
                  value: db.settings.flexBlendLevel?.toDouble() ?? 0,
                  min: 0,
                  max: 40,
                  divisions: 40,
                  onChanged: (value) {
                    setState(() {
                      db.settings.flexBlendLevel = value.round().clamp(0, 40);
                    });
                  },
                  onChangeEnd: (value) {
                    Future.delayed(Duration(milliseconds: 100), db.notifyAppUpdate);
                  },
                ),
              ),
            ],
          ),
          RadioGroup<FlexScheme>(
            groupValue: db.settings.resolvedFlexScheme,
            onChanged: (v) {
              if (v != db.settings.flexScheme) {
                db.settings.flexScheme = v;
                db.notifySettings();
                db.notifyAppUpdate();
              }
              setState(() {});
            },
            child: TileGroup(
              header: 'Color Scheme',
              children: [
                for (final scheme in AppTheme.kFlexSchemes)
                  if (scheme != .custom)
                    RadioListTile<FlexScheme>(
                      value: scheme,
                      title: Text(scheme.data.name),
                      secondary: Row(
                        mainAxisSize: .min,
                        spacing: 4,
                        children: [
                          for (final isDark in [false, true])
                            FlexThemeModeOptionButton(
                              flexSchemeColor: isDark ? scheme.data.dark : scheme.data.light,
                              backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
                              selected: false,
                              optionButtonPadding: .zero,
                              optionButtonMargin: .all(2),
                              // optionButtonBorderRadius: optionButtonBorderRadius,
                              height: 12,
                              width: 12,
                              // borderRadius: borderRadius,
                              padding: .all(2),
                            ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
