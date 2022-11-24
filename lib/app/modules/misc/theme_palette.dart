import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

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
                data: ThemeData.light(),
                child: Builder(builder: (context) => const _PaletteForTheme()),
              ),
            ),
            Expanded(
              child: Theme(
                data: ThemeData.dark(),
                child: Builder(builder: (context) => const _PaletteForTheme()),
              ),
            ),
          ],
        ),
      ),
    );
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
          oneColor(
              'colorScheme.primaryContainer', colorScheme.primaryContainer),
          oneColor('colorScheme.secondary', colorScheme.secondary),
          oneColor(
              'colorScheme.secondaryContainer', colorScheme.secondaryContainer),
          oneColor('colorScheme.surface', colorScheme.surface),
          oneColor('colorScheme.background', colorScheme.background),
          oneColor('colorScheme.error', colorScheme.error),
          oneColor('colorScheme.onPrimary', colorScheme.onPrimary),
          oneColor('colorScheme.onSecondary', colorScheme.onSecondary),
          oneColor('colorScheme.onSurface', colorScheme.onSurface),
          oneColor('colorScheme.onBackground', colorScheme.onBackground),
          oneColor('colorScheme.onError', colorScheme.onError),
          const Divider(thickness: 2),
          oneColor('primaryColor', themeData.primaryColor),
          oneColor('primaryColorLight', themeData.primaryColorLight),
          oneColor('primaryColorDark', themeData.primaryColorDark),
          oneColor('canvasColor', themeData.canvasColor),
          oneColor('shadowColor', themeData.shadowColor),
          oneColor(
              'scaffoldBackgroundColor', themeData.scaffoldBackgroundColor),
          oneColor('cardColor', themeData.cardColor),
          oneColor('dividerColor', themeData.dividerColor),
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
                style: const TextStyle(shadows: [
                  Shadow(
                      offset: Offset(0, 0), blurRadius: 2, color: Colors.grey)
                ]),
              ),
            ),
            subtitle: Center(
              child: AutoSizeText(
                color == null
                    ? 'null'
                    : 'Color(0x${color.value.toRadixString(16).padLeft(8, '0')})',
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
