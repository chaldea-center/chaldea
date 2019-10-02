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
  final int startInt;
  final int endInt;
  final int interval;

  int get nodeNum => (endInt - startInt) ~/ interval + 1;

  List<int> get nodeList =>
      List.generate(nodeNum, (index) => startInt + interval * index);

  int operator [](int index) {
    assert(index >= 0 && index <= endInt - startInt);
    return startInt + index;
  }

  IntRangeValues(this.startInt, endInt, {this.interval = 1})
      : assert(startInt != null &&
      endInt != null &&
      interval != null &&
      interval != 0),
        endInt = startInt + (endInt - startInt) ~/ interval,
        super(startInt.toDouble(), endInt.toDouble());

  factory IntRangeValues.fromRange(RangeValues values,
      {int interval = 1, int roundMethod = 0}) {
    return IntRangeValues(
        _toInt(values.start, roundMethod), _toInt(values.end, roundMethod),
        interval: interval);
  }

  RangeValues toRange() => RangeValues(startInt.toDouble(), endInt.toDouble());

  factory IntRangeValues.fromList(List<int> values, {int interval = 1}) {
    assert(values.length == 2);
    return IntRangeValues(values[0], values[1], interval: interval);
  }

  List<int> toList() => [startInt, endInt];

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
