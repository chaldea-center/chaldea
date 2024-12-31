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
  // late bool useM3 = Theme.of(context).useMaterial3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Palette'),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     setState(() {
          //       useM3 = !useM3;
          //     });
          //   },
          //   icon: Icon(useM3 ? Icons.filter_3 : Icons.filter_2),
          //   tooltip: "Material 2/3",
          // ),
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
            for (final useM3 in [false, true])
              for (final dark in [false, true])
                Expanded(
                  child: Theme(
                    data: _getThemeData(dark: dark, useM3: useM3),
                    child: Builder(builder: (context) => const _PaletteForTheme()),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  ThemeData _getThemeData({required bool dark, required bool useM3}) {
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
                  '${themeData.brightness.name}(${themeData.useMaterial3 ? 3 : 2})',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const Divider(thickness: 2),
          oneColor('s.primary', colorScheme.primary),
          oneColor('s.onPrimary', colorScheme.onPrimary),
          oneColor('s.primaryContainer', colorScheme.primaryContainer),
          oneColor('s.onPrimaryContainer', colorScheme.onPrimaryContainer),
          oneColor('s.primaryFixed', colorScheme.primaryFixed),
          oneColor('s.primaryFixedDim', colorScheme.primaryFixedDim),
          oneColor('s.onPrimaryFixed', colorScheme.onPrimaryFixed),
          oneColor('s.onPrimaryFixedVariant', colorScheme.onPrimaryFixedVariant),
          oneColor('s.secondary', colorScheme.secondary),
          oneColor('s.onSecondary', colorScheme.onSecondary),
          oneColor('s.secondaryContainer', colorScheme.secondaryContainer),
          oneColor('s.onSecondaryContainer', colorScheme.onSecondaryContainer),
          oneColor('s.secondaryFixed', colorScheme.secondaryFixed),
          oneColor('s.secondaryFixedDim', colorScheme.secondaryFixedDim),
          oneColor('s.onSecondaryFixed', colorScheme.onSecondaryFixed),
          oneColor('s.onSecondaryFixedVariant', colorScheme.onSecondaryFixedVariant),
          oneColor('s.tertiary', colorScheme.tertiary),
          oneColor('s.onTertiary', colorScheme.onTertiary),
          oneColor('s.tertiaryContainer', colorScheme.tertiaryContainer),
          oneColor('s.onTertiaryContainer', colorScheme.onTertiaryContainer),
          oneColor('s.tertiaryFixed', colorScheme.tertiaryFixed),
          oneColor('s.tertiaryFixedDim', colorScheme.tertiaryFixedDim),
          oneColor('s.onTertiaryFixed', colorScheme.onTertiaryFixed),
          oneColor('s.onTertiaryFixedVariant', colorScheme.onTertiaryFixedVariant),
          oneColor('s.error', colorScheme.error),
          oneColor('s.onError', colorScheme.onError),
          oneColor('s.errorContainer', colorScheme.errorContainer),
          oneColor('s.onErrorContainer', colorScheme.onErrorContainer),
          oneColor('s.surface', colorScheme.surface),
          oneColor('s.onSurface', colorScheme.onSurface),
          oneColor('s.surfaceDim', colorScheme.surfaceDim),
          oneColor('s.surfaceBright', colorScheme.surfaceBright),
          oneColor('s.surfaceContainerLowest', colorScheme.surfaceContainerLowest),
          oneColor('s.surfaceContainerLow', colorScheme.surfaceContainerLow),
          oneColor('s.surfaceContainer', colorScheme.surfaceContainer),
          oneColor('s.surfaceContainerHigh', colorScheme.surfaceContainerHigh),
          oneColor('s.surfaceContainerHighest', colorScheme.surfaceContainerHighest),
          oneColor('s.onSurfaceVariant', colorScheme.onSurfaceVariant),
          oneColor('s.outline', colorScheme.outline),
          oneColor('s.outlineVariant', colorScheme.outlineVariant),
          oneColor('s.shadow', colorScheme.shadow),
          oneColor('s.scrim', colorScheme.scrim),
          oneColor('s.inverseSurface', colorScheme.inverseSurface),
          oneColor('s.onInverseSurface', colorScheme.onInverseSurface),
          oneColor('s.inversePrimary', colorScheme.inversePrimary),
          oneColor('s.surfaceTint', colorScheme.surfaceTint),
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
                  maxFontSize: 12,
                  style: TextStyle(
                    shadows: const [Shadow(offset: Offset(0, 0), blurRadius: 2, color: Colors.grey)],
                    color: color,
                  ),
                ),
              ),
              subtitle: Center(
                child: AutoSizeText(
                  color == null ? 'null' : 'Color(0x${color.intValue.toRadixString(16).padLeft(8, '0')})',
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
      ),
    );
  }
}
