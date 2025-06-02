/// https://github.com/YeungKC/RubyText
/// v3.0.3 155725ef

import 'package:flutter/widgets.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tuple/tuple.dart';

class RubySpanWidget extends HookWidget {
  const RubySpanWidget(this.data, {super.key});

  final RubyTextData data;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.maybeOf(context);
    final defaultTextStyle = DefaultTextStyle.of(context).style;
    final boldTextOverride = MediaQuery.boldTextOf(context);

    final result = useMemoized(() {
      // text style
      var effectiveTextStyle = data.style;
      if (effectiveTextStyle == null || effectiveTextStyle.inherit) {
        effectiveTextStyle = defaultTextStyle.merge(effectiveTextStyle);
      }
      if (boldTextOverride) {
        effectiveTextStyle = effectiveTextStyle.merge(const TextStyle(fontWeight: FontWeight.bold));
      }
      assert(effectiveTextStyle.fontSize != null, 'must be has a font size.');
      final defaultRubyTextStyle = effectiveTextStyle.merge(TextStyle(fontSize: effectiveTextStyle.fontSize! / 1.5));

      // ruby text style
      var effectiveRubyTextStyle = data.rubyStyle;
      if (effectiveRubyTextStyle == null || effectiveRubyTextStyle.inherit) {
        effectiveRubyTextStyle = defaultRubyTextStyle.merge(effectiveRubyTextStyle);
      }
      if (boldTextOverride) {
        effectiveRubyTextStyle = effectiveRubyTextStyle.merge(const TextStyle(fontWeight: FontWeight.bold));
      }

      // spacing
      final ruby = data.ruby;
      final text = data.text;
      if (ruby != null &&
          effectiveTextStyle.letterSpacing == null &&
          effectiveRubyTextStyle.letterSpacing == null &&
          ruby.length >= 2 &&
          text.length >= 2) {
        final rubyWidth = _measurementWidth(
          ruby,
          effectiveRubyTextStyle,
          textDirection: data.textDirection ?? textDirection ?? TextDirection.ltr,
        );
        final textWidth = _measurementWidth(
          text,
          effectiveTextStyle,
          textDirection: data.textDirection ?? textDirection ?? TextDirection.ltr,
        );

        if (textWidth > rubyWidth) {
          final newLetterSpacing = (textWidth - rubyWidth) / ruby.length;
          effectiveRubyTextStyle = effectiveRubyTextStyle.merge(TextStyle(letterSpacing: newLetterSpacing));
        } else {
          final newLetterSpacing = (rubyWidth - textWidth) / text.length;
          effectiveTextStyle = effectiveTextStyle.merge(TextStyle(letterSpacing: newLetterSpacing));
        }
      }

      return Tuple2(effectiveTextStyle, effectiveRubyTextStyle);
    }, [defaultTextStyle, boldTextOverride, data]);

    final effectiveTextStyle = result.item1;
    final effectiveRubyTextStyle = result.item2;

    final texts = <Widget>[];
    if (data.ruby != null) {
      texts.add(Text(data.ruby!, textAlign: TextAlign.center, style: effectiveRubyTextStyle));
    }

    texts.add(Text(data.text, textAlign: TextAlign.center, style: effectiveTextStyle));

    return Column(children: texts);
  }
}

class RubyText extends StatelessWidget {
  const RubyText(
    this.data, {
    super.key,
    this.spacing = 0.0,
    this.style,
    this.rubyStyle,
    this.textAlign,
    this.textDirection,
    this.softWrap,
    this.overflow,
    this.maxLines,
  });

  final List<RubyTextData> data;
  final double spacing;
  final TextStyle? style;
  final TextStyle? rubyStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: data
          .map<InlineSpan>(
            (RubyTextData data) => WidgetSpan(
              child: RubySpanWidget(data.copyWith(style: style, rubyStyle: rubyStyle, textDirection: textDirection)),
            ),
          )
          .toList(),
    ),
    textAlign: textAlign,
    textDirection: textDirection,
    softWrap: softWrap,
    overflow: overflow,
    maxLines: maxLines,
  );
}

double _measurementWidth(String text, TextStyle style, {TextDirection textDirection = TextDirection.ltr}) {
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: textDirection,
    textAlign: TextAlign.center,
  )..layout();
  return textPainter.width;
}

// ruby text data

class RubyTextData extends Equatable {
  const RubyTextData(this.text, {this.ruby, this.style, this.rubyStyle, this.textDirection});

  final String text;
  final String? ruby;
  final TextStyle? style;
  final TextStyle? rubyStyle;
  final TextDirection? textDirection;

  @override
  List<Object?> get props => [text, ruby, style, rubyStyle, textDirection];

  RubyTextData copyWith({
    String? text,
    String? ruby,
    TextStyle? style,
    TextStyle? rubyStyle,
    TextDirection? textDirection,
  }) => RubyTextData(
    text ?? this.text,
    ruby: ruby ?? this.ruby,
    style: style ?? this.style,
    rubyStyle: rubyStyle ?? this.rubyStyle,
    textDirection: textDirection ?? this.textDirection,
  );
}
