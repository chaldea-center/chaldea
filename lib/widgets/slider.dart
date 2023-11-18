import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'custom_dialogs.dart';

class SliderWithTitle extends StatelessWidget {
  final String leadingText;
  final int min;
  final int max;
  final int value;
  final String label;
  final ValueChanged<double> onChange;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  const SliderWithTitle({
    super.key,
    required this.leadingText,
    required this.min,
    required this.max,
    required this.value,
    required this.label,
    required this.onChange,
    this.padding = const EdgeInsets.only(top: 8),
    this.maxWidth = 360,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding,
          child: Text('$leadingText: $label'),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 24,
            maxWidth: maxWidth,
          ),
          child: Slider(
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max > min ? max - min : null,
            value: value.toDouble(),
            label: label,
            onChanged: (v) {
              onChange(v);
            },
          ),
        )
      ],
    );
  }
}

class SliderWithPrefix extends StatelessWidget {
  final bool titled;
  final String label;
  final String Function(int v)? valueFormatter;
  final int min;
  final int max;
  final int value;
  final ValueChanged<double> onChange;
  final ValueChanged<double>? onEdit;
  final int? division;
  final double leadingWidth;
  final double endOffset;
  final bool enableInput;

  const SliderWithPrefix({
    super.key,
    this.titled = false,
    required this.label,
    this.valueFormatter,
    required this.min,
    required this.max,
    required this.value,
    required this.onChange,
    this.onEdit,
    this.division,
    this.leadingWidth = 48,
    this.endOffset = 0,
    this.enableInput = true,
  });

  @override
  Widget build(BuildContext context) {
    Color? lableColor = enableInput ? Theme.of(context).colorScheme.primaryContainer : null;
    Widget header;
    final valueText = valueFormatter?.call(value) ?? value.toString();
    if (titled) {
      header = Text.rich(TextSpan(
        text: label,
        children: [
          const TextSpan(text: ': '),
          TextSpan(text: valueText, style: TextStyle(color: lableColor)),
        ],
      ));
    } else {
      header = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AutoSizeText(
            label,
            maxLines: 1,
            minFontSize: 10,
            maxFontSize: 16,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: valueText.isEmpty ? lableColor : null),
          ),
          AutoSizeText(
            valueText,
            maxLines: 1,
            minFontSize: 10,
            maxFontSize: 14,
            style: TextStyle(color: lableColor),
          ),
        ],
      );
    }

    if (enableInput) {
      header = InkWell(
        onTap: () {
          showDialog(context: context, useRootNavigator: false, builder: getInputDialog);
        },
        child: header,
      );
    }
    Widget slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8)),
      child: Slider(
        min: min.toDouble(),
        max: max.toDouble(),
        divisions: max > min ? (division ?? max - min) : null,
        value: value.toDouble(),
        label: valueText,
        onChanged: (v) {
          onChange(v);
        },
      ),
    );
    slider = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320, maxHeight: 24),
      child: Stack(
        children: [
          PositionedDirectional(
            start: -16,
            end: endOffset,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 24),
              child: slider,
            ),
          )
        ],
      ),
    );

    Widget child;
    if (titled) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          slider,
        ],
      );
    } else {
      child = Row(
        children: [
          if (!titled)
            SizedBox(
              width: leadingWidth,
              child: header,
            ),
          Flexible(child: slider)
        ],
      );
    }
    return child;
  }

  Widget getInputDialog(BuildContext context) {
    String helperText = '$min~$max';
    return InputCancelOkDialog(
      title: label,
      text: value.toString(),
      helperText: helperText,
      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
      validate: (s) {
        final v = int.tryParse(s);
        if (v == null) return false;
        return v >= min && v <= max;
      },
      onSubmit: (s) {
        final v = int.tryParse(s);
        if (v == null) return;
        if (v >= min && v <= max) {
          if (onEdit != null) {
            onEdit!(v.toDouble());
          } else {
            onChange(v.toDouble());
          }
        }
      },
    );
  }
}
