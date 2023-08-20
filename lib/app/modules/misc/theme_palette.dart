import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';

class DarkLightThemePalette extends StatefulWidget {
  DarkLightThemePalette({super.key});

  @override
  _DarkLightThemePaletteState createState() => _DarkLightThemePaletteState();
}

class _DarkLightThemePaletteState extends State<DarkLightThemePalette> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Palette'),
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
    final useM3 = db.settings.m3Color != null;
    final themeData = ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      useMaterial3: useM3,
      colorSchemeSeed: db.settings.m3Color?.color,
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
          oneColor('colorScheme.primary', colorScheme.primary),
          oneColor('colorScheme.onPrimary', colorScheme.onPrimary),
          oneColor('colorScheme.primaryContainer', colorScheme.primaryContainer),
          oneColor('colorScheme.onPrimaryContainer', colorScheme.onPrimaryContainer),
          oneColor('colorScheme.secondary', colorScheme.secondary),
          oneColor('colorScheme.onSecondary', colorScheme.onSecondary),
          oneColor('colorScheme.secondaryContainer', colorScheme.secondaryContainer),
          oneColor('colorScheme.onSecondaryContainer', colorScheme.onSecondaryContainer),
          oneColor('colorScheme.tertiary', colorScheme.tertiary),
          oneColor('colorScheme.onTertiary', colorScheme.onTertiary),
          oneColor('colorScheme.tertiaryContainer', colorScheme.tertiaryContainer),
          oneColor('colorScheme.onTertiaryContainer', colorScheme.onTertiaryContainer),
          oneColor('colorScheme.error', colorScheme.error),
          oneColor('colorScheme.onError', colorScheme.onError),
          oneColor('colorScheme.errorContainer', colorScheme.errorContainer),
          oneColor('colorScheme.onErrorContainer', colorScheme.onErrorContainer),
          oneColor('colorScheme.background', colorScheme.background),
          oneColor('colorScheme.onBackground', colorScheme.onBackground),
          oneColor('colorScheme.surface', colorScheme.surface),
          oneColor('colorScheme.onSurface', colorScheme.onSurface),
          oneColor('colorScheme.surfaceVariant', colorScheme.surfaceVariant),
          oneColor('colorScheme.onSurfaceVariant', colorScheme.onSurfaceVariant),
          oneColor('colorScheme.outline', colorScheme.outline),
          oneColor('colorScheme.outlineVariant', colorScheme.outlineVariant),
          oneColor('colorScheme.shadow', colorScheme.shadow),
          oneColor('colorScheme.scrim', colorScheme.scrim),
          oneColor('colorScheme.inverseSurface', colorScheme.inverseSurface),
          oneColor('colorScheme.onInverseSurface', colorScheme.onInverseSurface),
          oneColor('colorScheme.inversePrimary', colorScheme.inversePrimary),
          oneColor('colorScheme.surfaceTint', colorScheme.surfaceTint),
          const Divider(thickness: 2),
          oneColor('primaryColor', themeData.primaryColor),
          oneColor('primaryColorLight', themeData.primaryColorLight),
          oneColor('primaryColorDark', themeData.primaryColorDark),
          oneColor('canvasColor', themeData.canvasColor),
          oneColor('shadowColor', themeData.shadowColor),
          oneColor('scaffoldBackgroundColor', themeData.scaffoldBackgroundColor),
          oneColor('cardColor', themeData.cardColor),
          oneColor('dividerColor', themeData.dividerColor),
          oneColor('highlightColor', themeData.highlightColor),
          oneColor('focusColor', themeData.focusColor),
          oneColor('hoverColor', themeData.hoverColor),
          oneColor('splashColor', themeData.splashColor),
          oneColor('unselectedWidgetColor', themeData.unselectedWidgetColor),
          oneColor('disabledColor', themeData.disabledColor),
          // oneColor('text', themeData.buttonTheme),
          // oneColor('text', themeData.toggleButtonsTheme),
          oneColor('secondaryHeaderColor', themeData.secondaryHeaderColor),
          oneColor('dialogBackgroundColor', themeData.dialogBackgroundColor),
          oneColor('indicatorColor', themeData.indicatorColor),
          oneColor('hintColor', themeData.hintColor),
          // oneColor('text', themeData.textTheme),
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
          Container(
            color: color,
            child: const SizedBox(width: double.infinity, height: 50),
          )
        ],
      ),
    );
  }
}
