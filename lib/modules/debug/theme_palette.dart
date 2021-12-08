import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

class DarkLightThemePalette extends StatefulWidget {
  DarkLightThemePalette({Key? key}) : super(key: key);

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

class _PaletteForTheme extends StatelessWidget {
  const _PaletteForTheme({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    return Container(
      color: themeData.scaffoldBackgroundColor,
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
                  EnumUtil.titled(themeData.brightness),
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
          oneColor('colorScheme.primaryVariant', colorScheme.primaryVariant),
          oneColor('colorScheme.secondary', colorScheme.secondary),
          oneColor(
              'colorScheme.secondaryVariant', colorScheme.secondaryVariant),
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
          oneColor('bottomAppBarColor', themeData.bottomAppBarColor),
          oneColor('cardColor', themeData.cardColor),
          oneColor('dividerColor', themeData.dividerColor),
          oneColor('focusColor', themeData.focusColor),
          oneColor('hoverColor', themeData.hoverColor),
          oneColor('splashColor', themeData.splashColor),
          oneColor('selectedRowColor', themeData.selectedRowColor),
          oneColor('unselectedWidgetColor', themeData.unselectedWidgetColor),
          oneColor('disabledColor', themeData.disabledColor),
          // oneColor('text', themeData.buttonTheme),
          // oneColor('text', themeData.toggleButtonsTheme),
          oneColor('secondaryHeaderColor', themeData.secondaryHeaderColor),
          oneColor('backgroundColor', themeData.backgroundColor),
          oneColor('dialogBackgroundColor', themeData.dialogBackgroundColor),
          oneColor('indicatorColor', themeData.indicatorColor),
          oneColor('hintColor', themeData.hintColor),
          oneColor('errorColor', themeData.errorColor),
          oneColor('toggleableActiveColor', themeData.toggleableActiveColor),
          // oneColor('text', themeData.textTheme),
        ],
      ),
    );
  }

  Widget oneColor(String text, Color? color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          title: Center(
              child: AutoSizeText(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
          )),
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
    );
  }
}
