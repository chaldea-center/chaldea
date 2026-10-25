import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/extension.dart';

class ImageWithTextOption {
  double? width;
  double? height;
  EdgeInsets? padding; // default zero
  AlignmentGeometry? alignment; //default [AlignmentDirectional.bottomEnd]

  bool? outlined; // default true
  double? fontSize;
  TextAlign? textAlign;
  TextStyle? textStyle;
  double? shadowSize;
  Color? shadowColor;

  // for cached image related
  WidgetBuilder? placeholder;
  LoadingErrorWidgetBuilder? errorWidget;

  ImageWithTextOption({
    this.width,
    this.height,
    this.padding,
    this.alignment,
    this.outlined,
    this.fontSize,
    this.textAlign,
    this.textStyle,
    this.shadowSize,
    this.shadowColor,
    this.placeholder,
    this.errorWidget,
  });

  ImageWithTextOption merge(ImageWithTextOption? other) {
    if (other == null) return this;
    return ImageWithTextOption(
      width: other.width ?? width,
      height: other.height ?? height,
      padding: other.padding ?? padding,
      alignment: other.alignment ?? alignment,
      outlined: other.outlined ?? outlined,
      fontSize: other.fontSize ?? fontSize,
      textAlign: other.textAlign ?? textAlign,
      textStyle: textStyle == null ? other.textStyle : textStyle?.merge(other.textStyle),
      shadowSize: other.shadowSize ?? shadowSize,
      shadowColor: other.shadowColor ?? shadowColor,
      placeholder: other.placeholder ?? placeholder,
      errorWidget: other.errorWidget ?? errorWidget,
    );
  }
}

class ImageWithText extends StatelessWidget {
  final Widget image;
  final String? text;
  final Widget Function(TextStyle style)? textBuilder;
  final VoidCallback? onTap;

  final ImageWithTextOption? option;

  const ImageWithText({super.key, required this.image, this.text, this.textBuilder, this.option, this.onTap});

  @override
  Widget build(BuildContext context) {
    TextStyle _style = const TextStyle(height: 1).merge(option?.textStyle);
    double? fontSize =
        option?.fontSize ??
        (option?.height != null && option!.height!.isFinite
            ? option!.height! * ((text?.split('\n').length ?? 1) > 1 ? 0.24 : 0.3)
            : null);
    _style = _style.copyWith(fontSize: fontSize, fontWeight: _style.fontWeight ?? FontWeight.w500);

    final padding = option?.padding ?? EdgeInsets.zero;

    Widget child = Stack(
      alignment: option?.alignment ?? AlignmentDirectional.bottomEnd,
      children: <Widget>[
        applyConstraints(
          Padding(
            padding: EdgeInsets.fromLTRB(
              -min(0.0, padding.left),
              -min(0.0, padding.top),
              -min(0.0, padding.right),
              -min(0.0, padding.bottom),
            ),
            child: image,
          ),
        ),
        if (text?.isNotEmpty == true || textBuilder != null)
          applyConstraints(
            Padding(
              padding: EdgeInsets.fromLTRB(
                max(0.0, padding.left),
                max(0.0, padding.top),
                max(0.0, padding.right),
                max(0.0, padding.bottom),
              ),
              child: paintOutline(
                context: context,
                text: text,
                builder: textBuilder,
                textAlign: option?.textAlign ?? TextAlign.end,
                textStyle: _style,
                shadowSize: (fontSize == null ? 4.0 : fontSize * 0.25).clamp(2, 4),
                shadowColor: option?.shadowColor,
              ),
            ),
            boxFit: BoxFit.scaleDown,
          ),
      ],
    );
    if (onTap != null) {
      child = GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: child);
    }
    return child;
  }

  Widget applyConstraints(Widget child, {BoxFit? boxFit}) {
    if (boxFit != null) {
      child = FittedBox(fit: boxFit, child: child);
    }
    if (option?.width != null || option?.height != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: option?.width ?? double.infinity,
          maxHeight: option?.height ?? double.infinity,
        ),
        child: child,
      );
    }
    return child;
  }

  static TextStyle toGlowStyle([TextStyle? style, double? shadowSize, Color? shadowColor]) {
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

  static TextStyle toShadowStyle([TextStyle? style, double? shadowSize, Color? shadowColor]) {
    style ??= const TextStyle();
    if (style.shadows?.isNotEmpty == true) return style;
    return style.copyWith(
      shadows: [
        BoxShadow(
          color: shadowColor ?? Colors.white,
          offset: Offset.zero,
          blurRadius: shadowSize ?? 3,
          blurStyle: BlurStyle.normal,
        ),
      ],
    );
  }

  static Widget paintOutline({
    BuildContext? context,
    String? text,
    Widget Function(TextStyle style)? builder,
    TextAlign? textAlign,
    TextStyle? textStyle,
    double? shadowSize,
    Color? shadowColor,
  }) {
    assert(text != null || builder != null);
    assert(text == null || builder == null);
    final isDark = context != null && Theme.of(context).brightness == Brightness.dark;
    final textColor = textStyle?.color ?? (isDark ? Colors.white : Colors.black);
    final outlineColor = shadowColor ?? _pickOutline(textColor);
    TextStyle _style = (textStyle ?? const TextStyle()).copyWith(color: textColor);

    List<Widget> children;
    if (builder != null) {
      children = [
        builder(toGlowStyle(_style, shadowSize, outlineColor)),
        builder(toShadowStyle(_style, shadowSize, outlineColor)),
      ];
    } else {
      children = [
        Text(text!, textAlign: textAlign, style: toGlowStyle(_style, shadowSize, outlineColor)),
        Text(text, textAlign: textAlign, style: toShadowStyle(_style, shadowSize, outlineColor)),
      ];
    }
    return Stack(children: children);
  }

  static Color _pickOutline(Color textColor) {
    return textColor.contrastRatio(Colors.black) >= textColor.contrastRatio(Colors.white) ? Colors.black : Colors.white;
  }
}
