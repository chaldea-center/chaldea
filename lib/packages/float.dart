import 'dart:math';
import 'dart:typed_data';

extension Num2FloatX on num {
  Float toFloat() => Float(this);
}

final class Float implements Comparable<Float> {
  static const int byteLength = 4;
  static const int _offset = 0;
  final double _value;

  const Float._(this._value);

  factory Float(num value) {
    final byteData = ByteData(byteLength);
    byteData.setFloat32(_offset, value.toDouble());
    return Float._(byteData.getFloat32(_offset));
  }

  double get value => _value;

  @override
  int compareTo(Float other) {
    return value.compareTo(other.value);
  }

  @override
  bool operator ==(Object other) {
    // web?
    return (other is num && value == other) || (other is Float && value == other.value);
  }

  @override
  int get hashCode => Object.hash('__Float__', value.hashCode);

  Float operator +(Float other) => Float(value + other.value);

  Float operator -(Float other) => Float(value - other.value);

  Float operator *(Float other) => Float(value * other.value);

  Float operator %(Float other) => Float(value % other.value);

  Float operator /(Float other) => Float(value / other.value);

  int operator ~/(Float other) => value ~/ other.value;

  Float operator -() => Float(-value);

  Float remainder(Float other) => Float(value.remainder(other.value));

  bool operator <(Float other) => value < other.value;

  bool operator <=(Float other) => value <= other.value;

  bool operator >(Float other) => value > other.value;

  bool operator >=(Float other) => value >= other.value;

  bool get isNaN => value.isNaN;

  bool get isNegative => value.isNegative;

  bool get isInfinite => value.isInfinite;

  bool get isFinite => value.isFinite;

  Float abs() => Float(value.abs());

  Float get sign => Float(value.sign);

  int round() => value.round();

  int floor() => value.floor();

  int ceil() => value.ceil();

  int truncate() => value.truncate();

  double roundToDouble() => value.roundToDouble();

  double floorToDouble() => value.floorToDouble();

  double ceilToDouble() => value.ceilToDouble();

  double truncateToDouble() => value.truncateToDouble();

  Float roundToFloat() => Float(value.roundToDouble());

  Float floorToFloat() => Float(value.floorToDouble());

  Float ceilToFloat() => Float(value.ceilToDouble());

  Float truncateToFloat() => Float(value.truncateToDouble());

  Float clamp(Float lowerLimit, Float upperLimit) => Float(value.clamp(lowerLimit.value, upperLimit.value));

  int toInt() => value.toInt();

  double toDouble() => value;

  @override
  String toString() => value.toString();

  Float ofMax(num other) {
    return Float(max(value, other));
  }

  Float ofMin(num other) {
    return Float(min(value, other));
  }
}
