import 'dart:math' show max, min;

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
  static EdgeInsets defaultContentPadding =
      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
  static EdgeInsets defaultTitlePadding =
      const EdgeInsets.symmetric(horizontal: 6.0);

  const CustomTile(
      {Key? key,
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
      this.onLongPress})
      : super(key: key);

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
        : AnimatedDefaultTextStyle(
            style: titleStyle,
            duration: kThemeChangeDuration,
            child: title ?? const SizedBox(),
          );

    Widget? subtitleText;
    TextStyle? subtitleStyle;
    if (subtitle != null) {
      subtitleStyle = _subtitleTextStyle(theme, tileTheme);
      subtitleText = subtitleStyle == null
          ? subtitle!
          : AnimatedDefaultTextStyle(
              style: subtitleStyle,
              duration: kThemeChangeDuration,
              child: subtitle!,
            );
    }

    List<Widget> trailingIcons = [];
    if (trailing != null) {
      trailingIcons.add(IconTheme.merge(
        data: iconThemeData!,
        child: trailing!,
      ));
    }
    if (trailingIcon != null) {
      trailingIcons.add(IconTheme.merge(
        data: iconThemeData!,
        child: trailingIcon!,
      ));
    }

    final EdgeInsetsGeometry resolvedContentPadding = contentPadding ??
        tileTheme.contentPadding ??
        const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
    final EdgeInsetsGeometry resolvedTitlePadding = titlePadding ??
        (leading == null
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 6.0));
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
            )),
      ),
      ...trailingIcons
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
        return selected
            ? theme.colorScheme.secondary
            : null; // null - use current icon theme color
    }
  }

  Color? _textColor(
      ThemeData theme, ListTileThemeData? tileTheme, Color? defaultColor) {
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
          return theme.colorScheme.secondary;
      }
    }
    return defaultColor;
  }

  TextStyle? _titleTextStyle(ThemeData theme, ListTileThemeData? tileTheme) {
    TextStyle? style;
    if (tileTheme != null) {
      switch (tileTheme.style) {
        case ListTileStyle.drawer:
          style = theme.textTheme.bodyText1; //body2->bodyText1
          break;
        case ListTileStyle.list:
          style = theme.textTheme.subtitle1; //subhead->subtitle1
          break;
        default:
          break;
      }
    } else {
      style = theme.textTheme.headline6; //subhead->headline6
    }
    final Color? color = _textColor(theme, tileTheme, style?.color);
    return style?.copyWith(color: color);
  }

  TextStyle? _subtitleTextStyle(ThemeData theme, ListTileThemeData tileTheme) {
    final TextStyle? style = theme.textTheme.bodyText2; //body1->bodyText2
    final Color? color =
        _textColor(theme, tileTheme, theme.textTheme.caption?.color);
    return style?.copyWith(color: color);
  }
}

class ImageWithText extends StatelessWidget {
  final Widget image;
  final String? text;
  final Widget Function(TextStyle style)? textBuilder;
  final bool outlined;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final AlignmentDirectional alignment;
  final double? shadowSize;
  final Color? shadowColor;
  final VoidCallback? onTap;

  const ImageWithText({
    Key? key,
    required this.image,
    this.text,
    this.textBuilder,
    this.outlined = true,
    this.padding = EdgeInsets.zero,
    this.width,
    this.height,
    this.alignment = AlignmentDirectional.bottomEnd,
    this.textAlign,
    this.textStyle,
    this.shadowSize = 3,
    this.shadowColor,
    this.onTap,
  })  : assert(width == null || width > 0),
        assert(height == null || height > 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle _style = textStyle ?? const TextStyle();
    _style = _style.copyWith(fontWeight: _style.fontWeight ?? FontWeight.bold);
    Widget child = Stack(
      alignment: alignment,
      children: <Widget>[
        applyConstraints(Padding(
          // if pad < 0
          padding: EdgeInsets.fromLTRB(
              -min(0.0, padding.left),
              -min(0.0, padding.top),
              -min(0.0, padding.right),
              -min(0.0, padding.bottom)),
          child: image,
        )),
        if (text?.isNotEmpty == true || textBuilder != null)
          applyConstraints(
            Padding(
              padding: EdgeInsets.fromLTRB(
                  max(0.0, padding.left),
                  max(0.0, padding.top),
                  max(0.0, padding.right),
                  max(0.0, padding.bottom)),
              child: paintOutline(
                text: text,
                builder: textBuilder,
                textAlign: textAlign,
                textStyle: _style,
                shadowSize: shadowSize,
                shadowColor:
                    shadowColor ?? Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            boxFit: BoxFit.scaleDown,
          )
      ],
    );
    if (onTap != null) {
      child = GestureDetector(
        child: child,
        onTap: onTap,
      );
    }
    return child;
  }

  Widget applyConstraints(Widget child, {BoxFit? boxFit}) {
    if (boxFit != null) {
      child = FittedBox(fit: boxFit, child: child);
    }
    if (width != null || height != null) {
      return Container(
        constraints: BoxConstraints(
            maxWidth: width ?? double.infinity,
            maxHeight: height ?? double.infinity),
        child: child,
      );
    }
    return child;
  }

  static TextStyle toGlowStyle(
      [TextStyle? style, double? shadowSize, Color? shadowColor]) {
    style ??= const TextStyle();
    if (shadowSize == null) {
      return style;
    } else {
      return style.copyWith(
        foreground: style.foreground ?? Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = shadowSize
          ..color = shadowColor ?? Colors.white,
      );
    }
  }

  static Widget paintOutline({
    String? text,
    Widget Function(TextStyle style)? builder,
    TextAlign? textAlign,
    TextStyle? textStyle,
    double? shadowSize,
    Color? shadowColor,
  }) {
    assert(text != null || builder != null);
    assert(text == null || builder == null);
    TextStyle _style = textStyle ?? const TextStyle();
    List<Widget> children;
    if (builder != null) {
      children = [
        builder(toGlowStyle(_style, shadowSize, shadowColor)),
        builder(_style),
      ];
    } else {
      children = [
        Text(
          text!,
          textAlign: textAlign,
          style: toGlowStyle(textStyle, shadowSize, shadowColor),
        ),
        Text(
          text,
          textAlign: textAlign,
          style: _style.foreground == null
              ? _style
              : _style.copyWith(foreground: null),
        )
      ];
    }
    return Stack(children: children);
  }
}
