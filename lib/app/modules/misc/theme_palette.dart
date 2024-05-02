import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';
import '../home/subpage/theme_color.dart';

class DarkLightThemePalette extends StatefulWidget {
  DarkLightThemePalette({super.key});

  @override
  _DarkLightThemePaletteState createState() => _DarkLightThemePaletteState();
}

class _DarkLightThemePaletteState extends State<DarkLightThemePalette> {
  late bool useM3 = Theme.of(context).useMaterial3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Palette'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                useM3 = !useM3;
              });
            },
            icon: Icon(useM3 ? Icons.filter_3 : Icons.filter_2),
            tooltip: "Material 2/3",
          ),
          IconButton(
            onPressed: () async {
              await router.pushPage(const ThemeColorPage());
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.settings),
            tooltip: "Settings",
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Theme(
                data: _getThemeData(dark: false),
                child: Builder(builder: (context) => const _PaletteForTheme()),
              ),
            ),
            Expanded(
              child: Theme(
                data: _getThemeData(dark: true),
                child: Builder(builder: (context) => const _PaletteForTheme()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ThemeData _getThemeData({required bool dark}) {
    final themeData = ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      useMaterial3: useM3,
      colorSchemeSeed: db.settings.colorSeed?.color,
    );
    return themeData;
  }
}

class _PaletteForTheme extends StatefulWidget {
  const _PaletteForTheme();

  @override
  State<_PaletteForTheme> createState() => _PaletteForThemeState();
}

class _PaletteForThemeState extends State<_PaletteForTheme> {
  Color? bgColor;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    return Container(
      color: bgColor ?? themeData.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  themeData.brightness.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const Divider(thickness: 2),
          oneColor('scheme.primary', colorScheme.primary),
          oneColor('scheme.onPrimary', colorScheme.onPrimary),
          oneColor('scheme.primaryContainer', colorScheme.primaryContainer),
          oneColor('scheme.onPrimaryContainer', colorScheme.onPrimaryContainer),
          oneColor('scheme.secondary', colorScheme.secondary),
          oneColor('scheme.onSecondary', colorScheme.onSecondary),
          oneColor('scheme.secondaryContainer', colorScheme.secondaryContainer),
          oneColor('scheme.onSecondaryContainer', colorScheme.onSecondaryContainer),
          oneColor('scheme.tertiary', colorScheme.tertiary),
          oneColor('scheme.onTertiary', colorScheme.onTertiary),
          oneColor('scheme.tertiaryContainer', colorScheme.tertiaryContainer),
          oneColor('scheme.onTertiaryContainer', colorScheme.onTertiaryContainer),
          oneColor('scheme.error', colorScheme.error),
          oneColor('scheme.onError', colorScheme.onError),
          oneColor('scheme.errorContainer', colorScheme.errorContainer),
          oneColor('scheme.onErrorContainer', colorScheme.onErrorContainer),
          oneColor('scheme.background', colorScheme.background),
          oneColor('scheme.onBackground', colorScheme.onBackground),
          oneColor('scheme.surface', colorScheme.surface),
          oneColor('scheme.onSurface', colorScheme.onSurface),
          oneColor('scheme.surfaceVariant', colorScheme.surfaceVariant),
          oneColor('scheme.onSurfaceVariant', colorScheme.onSurfaceVariant),
          oneColor('scheme.outline', colorScheme.outline),
          oneColor('scheme.outlineVariant', colorScheme.outlineVariant),
          oneColor('scheme.shadow', colorScheme.shadow),
          oneColor('scheme.scrim', colorScheme.scrim),
          oneColor('scheme.inverseSurface', colorScheme.inverseSurface),
          oneColor('scheme.onInverseSurface', colorScheme.onInverseSurface),
          oneColor('scheme.inversePrimary', colorScheme.inversePrimary),
          oneColor('scheme.surfaceTint', colorScheme.surfaceTint),
          const Divider(thickness: 2),
          oneColor('canvasColor', themeData.canvasColor),
          oneColor('cardColor', themeData.cardColor),
          oneColor('dialogBackgroundColor', themeData.dialogBackgroundColor),
          oneColor('disabledColor', themeData.disabledColor),
          oneColor('dividerColor', themeData.dividerColor),
          oneColor('focusColor', themeData.focusColor),
          oneColor('highlightColor', themeData.highlightColor),
          oneColor('hintColor', themeData.hintColor),
          oneColor('hoverColor', themeData.hoverColor),
          oneColor('indicatorColor', themeData.indicatorColor),
          oneColor('primaryColor', themeData.primaryColor),
          oneColor('primaryColorDark', themeData.primaryColorDark),
          oneColor('primaryColorLight', themeData.primaryColorLight),
          oneColor('scaffoldBackgroundColor', themeData.scaffoldBackgroundColor),
          oneColor('secondaryHeaderColor', themeData.secondaryHeaderColor),
          oneColor('shadowColor', themeData.shadowColor),
          oneColor('splashColor', themeData.splashColor),
          oneColor('unselectedWidgetColor', themeData.unselectedWidgetColor),
        ],
      ),
    );
  }

  Widget oneColor(String text, Color? color) {
    return InkWell(
        onTap: () {
          setState(() {
            bgColor = color;
          });
        },
        onDoubleTap: () {
          setState(() {
            bgColor = null;
          });
        },
        child: SizedBox(
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListTile(
                title: Center(
                  child: AutoSizeText(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(shadows: [Shadow(offset: Offset(0, 0), blurRadius: 2, color: Colors.grey)]),
                  ),
                ),
                subtitle: Center(
                  child: AutoSizeText(
                    color == null ? 'null' : 'Color(0x${color.value.toRadixString(16).padLeft(8, '0')})',
                    maxLines: 1,
                    minFontSize: 2,
                    style: kMonoStyle,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: color,
                  child: const SizedBox.expand(),
                ),
              )
            ],
          ),
        ));
  }
}
