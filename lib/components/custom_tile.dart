import 'dart:math';

import 'package:chaldea/components/components.dart';

/// modified from [ListTile].
class CustomTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;

  /// default: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0)
  final EdgeInsets contentPadding;

  /// default: EdgeInsets.symmetric(horizontal: 6.0)
  final EdgeInsets titlePadding;
  final Color color;
  final CrossAxisAlignment alignment;
  final bool enabled;
  final bool selected;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  ///default values
  static EdgeInsets defaultContentPadding =
      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
  static EdgeInsets defaultTitlePadding = EdgeInsets.symmetric(horizontal: 6.0);

  const CustomTile(
      {Key key,
      this.leading,
      this.title,
      this.subtitle,
      this.trailing,
      this.contentPadding,
      this.titlePadding,
      this.color,
      this.alignment = CrossAxisAlignment.center,
      this.enabled = true,
      this.selected = false,
      this.onTap,
      this.onLongPress})
      : assert(alignment != null),
        assert(enabled != null),
        assert(selected != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData theme = Theme.of(context);
    final ListTileTheme tileTheme = ListTileTheme.of(context);

    IconThemeData iconThemeData;
    if (leading != null || trailing != null)
      iconThemeData = IconThemeData(color: _iconColor(theme, tileTheme));

    Widget leadingIcon;
    if (leading != null)
      leadingIcon = IconTheme.merge(data: iconThemeData, child: leading);

    final TextStyle titleStyle = _titleTextStyle(theme, tileTheme);
    final Widget titleText = AnimatedDefaultTextStyle(
      style: titleStyle,
      duration: kThemeChangeDuration,
      child: title ?? const SizedBox(),
    );

    Widget subtitleText;
    TextStyle subtitleStyle;
    if (subtitle != null) {
      subtitleStyle = _subtitleTextStyle(theme, tileTheme);
      subtitleText = AnimatedDefaultTextStyle(
        style: subtitleStyle,
        duration: kThemeChangeDuration,
        child: subtitle,
      );
    }

    Widget trailingIcon;
    if (trailing != null) {
      trailingIcon = IconTheme.merge(
          data: iconThemeData.copyWith(color: theme.buttonColor),
          child: trailing);
    }

    final EdgeInsets resolvedContentPadding = contentPadding ??
        tileTheme?.contentPadding ??
        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
    final EdgeInsets resolvedTitlePadding =
        titlePadding ?? EdgeInsets.symmetric(horizontal: 6.0);
    List<Widget> allElements = [
      leadingIcon,
      Expanded(
        flex: 1,
        child: Padding(
            padding: resolvedTitlePadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subtitleText == null
                  ? [titleText]
                  : [titleText, subtitleText],
            )),
      ),
      trailingIcon
    ];
    allElements.removeWhere((item) => item == null);
    return InkWell(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      child: Semantics(
        enabled: enabled,
        selected: selected,
        child: Container(
          color: color,
          child: Padding(
            padding: resolvedContentPadding,
            child: Row(
                crossAxisAlignment: alignment,
                mainAxisSize: MainAxisSize.max,
                children: allElements),
          ),
        ),
      ),
    );
  }

  Color _iconColor(ThemeData theme, ListTileTheme tileTheme) {
    if (!enabled) return theme.disabledColor;

    if (selected && tileTheme?.selectedColor != null)
      return tileTheme.selectedColor;

    if (!selected && tileTheme?.iconColor != null) return tileTheme.iconColor;

    switch (theme.brightness) {
      case Brightness.light:
        return selected ? theme.primaryColor : Colors.black45;
      case Brightness.dark:
        return selected
            ? theme.accentColor
            : null; // null - use current icon theme color
    }
    assert(theme.brightness != null);
    return null;
  }

  Color _textColor(
      ThemeData theme, ListTileTheme tileTheme, Color defaultColor) {
    if (!enabled) return theme.disabledColor;

    if (selected && tileTheme?.selectedColor != null)
      return tileTheme.selectedColor;

    if (!selected && tileTheme?.textColor != null) return tileTheme.textColor;

    if (selected) {
      switch (theme.brightness) {
        case Brightness.light:
          return theme.primaryColor;
        case Brightness.dark:
          return theme.accentColor;
      }
    }
    return defaultColor;
  }

  TextStyle _titleTextStyle(ThemeData theme, ListTileTheme tileTheme) {
    TextStyle style;
    if (tileTheme != null) {
      switch (tileTheme.style) {
        case ListTileStyle.drawer:
          style = theme.textTheme.body2;
          break;
        case ListTileStyle.list:
          style = theme.textTheme.subhead;
          break;
      }
    } else {
      style = theme.textTheme.subhead;
    }
    final Color color = _textColor(theme, tileTheme, style.color);
    return style.copyWith(color: color);
  }

  TextStyle _subtitleTextStyle(ThemeData theme, ListTileTheme tileTheme) {
    final TextStyle style = theme.textTheme.body1;
    final Color color =
        _textColor(theme, tileTheme, theme.textTheme.caption.color);
    return style.copyWith(color: color);
  }
}

class ImageWithText extends StatelessWidget {
  final Image image;
  final String text;
  final EdgeInsets padding;

  final AlignmentDirectional alignment;
  final VoidCallback onTap;

  ImageWithText(
      {Key key,
      this.image,
      this.text,
      this.padding = EdgeInsets.zero,
      this.alignment = AlignmentDirectional.bottomEnd,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: fix image pos shift with different alignment
    return LayoutBuilder(
      builder: (context, constraints) {
//        print('${constraints.biggest},${constraints.smallest}');
        return GestureDetector(
          onTap: onTap,
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Stack(
              alignment: alignment,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      -min(0.0, padding.left),
                      -min(0.0, padding.top),
                      -min(0.0, padding.right),
                      -min(0.0, padding.bottom)),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: image,
                  ),
                ),
                if (text != null)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        max(0.0, padding.left),
                        max(0.0, padding.top),
                        max(0.0, padding.right),
                        max(0.0, padding.bottom)),
                    child: FittedBox(
                      fit: BoxFit
                          .fitWidth, //no effect is width is not constraint
                      child: Stack(
                        children: <Widget>[
                          Text(
                            text,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 3
                                ..color = Colors.white,
                            ),
                          ),
                          Text(
                            text,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
