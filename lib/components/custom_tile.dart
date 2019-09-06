import 'package:flutter/material.dart';

/// modified from [ListTile].
class CustomTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget subtitle;
  final Widget trailing;
  final EdgeInsets contentPadding;
  final titlePadding;
  final alignment;
  final bool enabled;
  final bool selected;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  const CustomTile(
      {Key key,
      this.leading,
      this.title,
      this.subtitle,
      this.trailing,
      this.contentPadding,
      this.titlePadding,
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
        child: Padding(
          padding: resolvedContentPadding,
          child: Row(
              crossAxisAlignment: alignment,
              mainAxisSize: MainAxisSize.max,
              children: allElements),
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
