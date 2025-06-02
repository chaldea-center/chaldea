import 'package:flutter/material.dart';

/// modified from [ListTile].
class CustomTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? trailingIcon;

  /// default: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0)
  final EdgeInsetsGeometry? contentPadding;

  /// default: if leading is non-null, EdgeInsets.symmetric(horizontal: 6.0)
  /// if null, EdgeInsets.zero
  final EdgeInsetsGeometry? titlePadding;
  final BoxConstraints? constraints;
  final Color? color;
  final CrossAxisAlignment alignment;
  final bool enabled;
  final bool selected;
  final GestureTapCallback? onTap;
  final FocusNode? focusNode;
  final GestureLongPressCallback? onLongPress;

  ///default values
  static EdgeInsets defaultContentPadding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
  static EdgeInsets defaultTitlePadding = const EdgeInsets.symmetric(horizontal: 6.0);

  const CustomTile({
    super.key,
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
    this.focusNode,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    final ThemeData theme = Theme.of(context);
    final ListTileThemeData tileTheme = ListTileTheme.of(context);

    IconThemeData? iconThemeData;
    if (leading != null || trailing != null || trailingIcon != null) {
      iconThemeData = IconThemeData(color: _iconColor(theme, tileTheme));
    }

    Widget? leadingIcon;
    if (leading != null) {
      leadingIcon = IconTheme.merge(data: iconThemeData!, child: leading!);
    }

    final TextStyle? titleStyle = _titleTextStyle(theme, tileTheme);
    final Widget titleText = titleStyle == null
        ? title ?? const SizedBox()
        : AnimatedDefaultTextStyle(style: titleStyle, duration: kThemeChangeDuration, child: title ?? const SizedBox());

    Widget? subtitleText;
    TextStyle? subtitleStyle;
    if (subtitle != null) {
      subtitleStyle = _subtitleTextStyle(theme, tileTheme);
      subtitleText = subtitleStyle == null
          ? subtitle!
          : AnimatedDefaultTextStyle(style: subtitleStyle, duration: kThemeChangeDuration, child: subtitle!);
    }

    List<Widget> trailingIcons = [];
    if (trailing != null) {
      trailingIcons.add(IconTheme.merge(data: iconThemeData!, child: trailing!));
    }
    if (trailingIcon != null) {
      trailingIcons.add(IconTheme.merge(data: iconThemeData!, child: trailingIcon!));
    }

    final EdgeInsetsGeometry resolvedContentPadding =
        contentPadding ?? tileTheme.contentPadding ?? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
    final EdgeInsetsGeometry resolvedTitlePadding =
        titlePadding ?? (leading == null ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 6.0));
    List<Widget> allElements = [
      if (leadingIcon != null) leadingIcon,
      Expanded(
        flex: 1,
        child: Padding(
          padding: resolvedTitlePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleText, if (subtitleText != null) subtitleText],
          ),
        ),
      ),
      ...trailingIcons,
    ];
    return InkWell(
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      canRequestFocus: enabled,
      focusNode: focusNode,
      child: Semantics(
        enabled: enabled,
        selected: selected,
        child: Container(
          color: color,
          constraints: constraints,
          child: Padding(
            padding: resolvedContentPadding,
            child: Row(crossAxisAlignment: alignment, mainAxisSize: MainAxisSize.max, children: allElements),
          ),
        ),
      ),
    );
  }

  Color? _iconColor(ThemeData theme, ListTileThemeData? tileTheme) {
    if (!enabled) return theme.disabledColor;

    if (selected && tileTheme?.selectedColor != null) {
      return tileTheme?.selectedColor;
    }

    if (!selected && tileTheme?.iconColor != null) return tileTheme?.iconColor;

    switch (theme.brightness) {
      case Brightness.light:
        return selected ? theme.primaryColor : Colors.black45;
      case Brightness.dark:
        return selected ? theme.colorScheme.tertiary : null; // null - use current icon theme color
    }
  }

  Color? _textColor(ThemeData theme, ListTileThemeData? tileTheme, Color? defaultColor) {
    if (!enabled) return theme.disabledColor;

    if (selected && tileTheme?.selectedColor != null) {
      return tileTheme?.selectedColor;
    }

    if (!selected && tileTheme?.textColor != null) return tileTheme?.textColor;

    if (selected) {
      switch (theme.brightness) {
        case Brightness.light:
          return theme.primaryColor;
        case Brightness.dark:
          return theme.colorScheme.tertiary;
      }
    }
    return defaultColor;
  }

  TextStyle? _titleTextStyle(ThemeData theme, ListTileThemeData? tileTheme) {
    TextStyle? style;
    if (tileTheme != null) {
      switch (tileTheme.style) {
        case ListTileStyle.drawer:
          style = theme.textTheme.bodyLarge; //body2->bodyText1
          break;
        case ListTileStyle.list:
          style = theme.textTheme.titleMedium; //subhead->subtitle1
          break;
        default:
          break;
      }
    } else {
      style = theme.textTheme.titleLarge; //subhead->headline6
    }
    final Color? color = _textColor(theme, tileTheme, style?.color);
    return style?.copyWith(color: color);
  }

  TextStyle? _subtitleTextStyle(ThemeData theme, ListTileThemeData tileTheme) {
    final TextStyle? style = theme.textTheme.bodyMedium; //body1->bodyText2
    final Color? color = _textColor(theme, tileTheme, theme.textTheme.bodySmall?.color);
    return style?.copyWith(color: color);
  }
}
