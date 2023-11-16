import 'package:flutter/material.dart';

class SpecialTextSpan extends WidgetSpan {
  SpecialTextSpan(
    String data, {
    required Offset offset,
    double? textScaleFactor,
    super.style,
  }) : super(
          child: _TransformText(
            data: data,
            offset: offset,
            textScaleFactor: textScaleFactor,
            style: style,
          ),
        );

  SpecialTextSpan.superscript(
    String data, {
    Offset offset = const Offset(0, -5),
    double? textScaleFactor = 0.7,
    TextStyle? style,
  }) : this(data, offset: offset, textScaleFactor: textScaleFactor, style: style);

  SpecialTextSpan.subscript(
    String data, {
    Offset offset = const Offset(0, 1),
    double? textScaleFactor = 0.7,
    TextStyle? style,
  }) : this(data, offset: offset, textScaleFactor: textScaleFactor, style: style);
}

class _TransformText extends StatelessWidget {
  final Offset offset;
  final double? textScaleFactor;
  final String data;
  final TextStyle? style;
  const _TransformText({
    required this.data,
    required this.offset,
    this.textScaleFactor,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Text(
        data,
        textScaler: textScaleFactor == null ? null : TextScaler.linear(textScaleFactor!),
        style: DefaultTextStyle.of(context).style.merge(style),
      ),
    );
  }
}
