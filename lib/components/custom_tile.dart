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
  final EdgeInsets? contentPadding;

  /// default: if leading is null, EdgeInsets.symmetric(horizontal: 6.0)
  /// if not null, EdgeInsets.zero
  final EdgeInsets? titlePadding;
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
      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
  static EdgeInsets defaultTitlePadding = EdgeInsets.symmetric(horizontal: 6.0);

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
    final ListTileTheme tileTheme = ListTileTheme.of(context);

    IconThemeData? iconThemeData;
    if (leading != null || trailing != null || trailingIcon != null)
      iconThemeData = IconThemeData(color: _iconColor(theme, tileTheme));

    Widget? leadingIcon;
    if (leading != null)
      leadingIcon = IconTheme.merge(data: iconThemeData!, child: leading!);

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
        data: iconThemeData!.copyWith(color: theme.buttonColor),
        child: trailing!,
      ));
    }
    if (trailingIcon != null) {
      trailingIcons.add(IconTheme.merge(
        data: iconThemeData!.copyWith(color: theme.buttonColor),
        child: trailingIcon!,
      ));
    }

    final EdgeInsetsGeometry resolvedContentPadding = contentPadding ??
        tileTheme.contentPadding ??
        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0);
    final EdgeInsets resolvedTitlePadding = titlePadding ??
        (leading == null
            ? EdgeInsets.zero
            : EdgeInsets.symmetric(horizontal: 6.0));
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

  Color? _iconColor(ThemeData theme, ListTileTheme? tileTheme) {
    if (!enabled) return theme.disabledColor;

    if (selected && tileTheme?.selectedColor != null)
      return tileTheme?.selectedColor;

    if (!selected && tileTheme?.iconColor != null) return tileTheme?.iconColor;

    switch (theme.brightness) {
      case Brightness.light:
        return selected ? theme.primaryColor : Colors.black45;
      case Brightness.dark:
        return selected
            ? theme.accentColor
            : null; // null - use current icon theme color
    }
  }

  Color? _textColor(
      ThemeData theme, ListTileTheme? tileTheme, Color? defaultColor) {
    if (!enabled) return theme.disabledColor;

    if (selected && tileTheme?.selectedColor != null)
      return tileTheme?.selectedColor;

    if (!selected && tileTheme?.textColor != null) return tileTheme?.textColor;

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

  TextStyle? _titleTextStyle(ThemeData theme, ListTileTheme? tileTheme) {
    TextStyle? style;
    if (tileTheme != null) {
      switch (tileTheme.style) {
        case ListTileStyle.drawer:
          style = theme.textTheme.bodyText1; //body2->bodyText1
          break;
        case ListTileStyle.list:
          style = theme.textTheme.subtitle1; //subhead->subtitle1
          break;
      }
    } else {
      style = theme.textTheme.headline6; //subhead->headline6
    }
    final Color? color = _textColor(theme, tileTheme, style?.color);
    return style?.copyWith(color: color);
  }

  TextStyle? _subtitleTextStyle(ThemeData theme, ListTileTheme tileTheme) {
    final TextStyle? style = theme.textTheme.bodyText2; //body1->bodyText2
    final Color? color =
        _textColor(theme, tileTheme, theme.textTheme.caption?.color);
    return style?.copyWith(color: color);
  }
}

class ImageWithText extends StatelessWidget {
  final Widget image;
  final String? text;
  final EdgeInsets padding;
  final double? width;
  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final AlignmentDirectional alignment;
  final VoidCallback? onTap;

  ImageWithText({
    Key? key,
    required this.image,
    this.text,
    this.padding = EdgeInsets.zero,
    this.width,
    this.alignment = AlignmentDirectional.bottomEnd,
    this.textAlign,
    this.textStyle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: fix image pos shift with different alignment
    return LayoutBuilder(
      builder: (context, constraints) {
//        print('${constraints.biggest},${constraints.smallest}');
        TextStyle _style = textStyle ?? TextStyle();
        _style =
            _style.copyWith(fontWeight: _style.fontWeight ?? FontWeight.bold);
        return GestureDetector(
          onTap: onTap,
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Stack(
              alignment: alignment,
              children: <Widget>[
                applyWidth(Padding(
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
                )),
                if (text?.isNotEmpty == true)
                  applyWidth(
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          max(0.0, padding.left),
                          max(0.0, padding.top),
                          max(0.0, padding.right),
                          max(0.0, padding.bottom)),
                      child: paintOutline(
                        text: text!,
                        textAlign: textAlign,
                        textStyle: textStyle,
                      ),
                    ),
                    boxFit: BoxFit.scaleDown,
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget applyWidth(Widget child, {BoxFit? boxFit}) {
    if (width != null && width! > 0.0) {
      if (boxFit != null) {
        return Container(
          constraints: BoxConstraints(maxWidth: width!),
          child: FittedBox(
            child: child,
            fit: boxFit,
          ),
        );
      } else {
        return Container(
          constraints: BoxConstraints(maxWidth: width!),
          child: child,
        );
      }
    } else {
      return child;
    }
  }

  static Widget paintOutline({
    required String text,
    TextAlign? textAlign,
    TextStyle? textStyle,
  }) {
    TextStyle _style = textStyle ?? TextStyle();
    return Stack(
      children: <Widget>[
        Text(
          text,
          textAlign: textAlign,
          style: _style.copyWith(
            foreground: _style.foreground ?? Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.white,
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          style: _style.foreground == null
              ? _style
              : _style.copyWith(foreground: null),
        )
      ],
    );
  }
}
