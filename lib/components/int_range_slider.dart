import 'package:flutter/material.dart';

/// keep double pair([start], [end]) and int pair([startInt], [endInt]) at same time
class IntRangeSlider extends RangeSlider {
  IntRangeSlider(
      {Key key,
      @required RangeValues values,
      @required ValueChanged<IntRangeValues> onChanged,
      ValueChanged<IntRangeValues> onChangeStart,
      ValueChanged<IntRangeValues> onChangeEnd,
      int min = 0,
      int max = 10,
      int divisions,
      RangeLabels labels,
      Color activeColor,
      Color inactiveColor,
      RangeSemanticFormatterCallback semanticFormatterCallback})
      : super(
            key: key,
            values: values,
            onChanged: (RangeValues values) =>
                onChanged(IntRangeValues.fromRange(values)),
            onChangeStart: onChangeStart == null
                ? null
                : (RangeValues values) =>
                    onChangeStart(IntRangeValues.fromRange(values)),
            onChangeEnd: onChangeEnd == null
                ? null
                : (RangeValues values) =>
                    onChangeEnd(IntRangeValues.fromRange(values)),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: divisions,
            labels: labels,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            semanticFormatterCallback: semanticFormatterCallback);
}

class IntRangeValues extends RangeValues {
  /// Creates pair of start and end values.
  IntRangeValues(this.startInt, this.endInt)
      : super(startInt.toDouble(), endInt.toDouble());

  final int startInt;

  final int endInt;

  static int _toInt(double x, [int roundMethod = 0]) {
    switch (roundMethod) {
      case 1:
        return x.ceil();
      case -1:
        return x.floor();
      default:
        return x.round();
    }
  }

  IntRangeValues.fromRange(RangeValues values, [int roundMethod = 0])
      : startInt = _toInt(values.start, roundMethod),
        endInt = _toInt(values.end, roundMethod),
        super(values.start, values.end);

  RangeValues toRange() => RangeValues(start.toDouble(), end.toDouble());

  IntRangeValues.fromList(List<int> values)
      : assert(values.length == 2),
        startInt = values[0],
        endInt = values[1],
        super(values[0].toDouble(), values[1].toDouble());

  List<int> toList() => [startInt, endInt];

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    final IntRangeValues typedOther = other;
    return typedOther.startInt == startInt && typedOther.endInt == endInt;
  }

  @override
  int get hashCode => hashValues(startInt, endInt);

  @override
  String toString() {
    return '$runtimeType($startInt, $endInt)';
  }
}
