import 'dart:math';

import 'package:flutter/material.dart';

/// modified from [ListTile].
class CustomTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;
  final Widget trailingIcon;

  /// default: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0)
  final EdgeInsets contentPadding;

  /// default: if leading is null, EdgeInsets.symmetric(horizontal: 6.0)
  /// if not null, EdgeInsets.zero
  final EdgeInsets titlePadding;
  final BoxConstraints constraints;
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
      this.trailingIcon,
      this.contentPadding,
      this.titlePadding,
      this.constraints,
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
    if (leading != null || trailing != null || trailingIcon != null)
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

    List<Widget> trailingIcons = [];
    if (trailing != null) {
      trailingIcons.add(IconTheme.merge(
        data: iconThemeData.copyWith(color: theme.buttonColor),
        child: trailing,
      ));
    }
    if (trailingIcon != null) {
      trailingIcons.add(IconTheme.merge(
        data: iconThemeData.copyWith(color: theme.buttonColor),
        child: trailingIcon,
      ));
    }

    final EdgeInsets resolvedContentPadding = contentPadding ??
        tileTheme?.contentPadding ??
        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
    final EdgeInsets resolvedTitlePadding = titlePadding ??
        (leading == null
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: 6.0));
    List<Widget> allElements = [
      leadingIcon,
      Expanded(
        flex: 1,
        child: Padding(
            padding: resolvedTitlePadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [titleText, if (subtitleText != null) subtitleText],
            )),
      ),
      ...trailingIcons
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
          constraints: constraints,
          child: Padding(
            padding: resolvedContentPadding,
            child: Row(
              crossAxisAlignment: alignment,
              mainAxisSize: MainAxisSize.max,
              children: allElements,
            ),
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
          style = theme.textTheme.bodyText1; //body2->bodyText1
          break;
        case ListTileStyle.list:
          style = theme.textTheme.subtitle1;//subhead->subtitle1
          break;
      }
    } else {
      style = theme.textTheme.headline6;//subhead->headline6
    }
    final Color color = _textColor(theme, tileTheme, style.color);
    return style.copyWith(color: color);
  }

  TextStyle _subtitleTextStyle(ThemeData theme, ListTileTheme tileTheme) {
    final TextStyle style = theme.textTheme.bodyText2;//body1->bodyText2
    final Color color =
        _textColor(theme, tileTheme, theme.textTheme.caption.color);
    return style.copyWith(color: color);
  }
}

class ImageWithText extends StatelessWidget {
  final Image image;
  final String text;
  final double fontSize;
  final EdgeInsets padding;

  final AlignmentDirectional alignment;
  final VoidCallback onTap;

  ImageWithText(
      {Key key,
      this.image,
      this.text,
      this.fontSize,
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
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 3
                                ..color = Colors.white,
                            ),
                          ),
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                            ),
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
