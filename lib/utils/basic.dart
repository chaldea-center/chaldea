import 'dart:math' as math;

import 'package:path/path.dart' as pathlib;

String joinPaths(
  String part1, [
  String? part2,
  String? part3,
  String? part4,
  String? part5,
  String? part6,
  String? part7,
  String? part8,
]) {
  return pathlib.join(part1, part2, part3, part4, part5, part6, part7, part8);
}

/// [reversed] is used only when [compare] is null for default num values sort
Map<K, V> sortDict<K, V>(
  Map<K, V> d, {
  bool reversed = false,
  int Function(MapEntry<K, V> a, MapEntry<K, V> b)? compare,
  bool inPlace = false,
}) {
  List<MapEntry<K, V>> entries = d.entries.toList();
  entries.sort((a, b) {
    if (compare != null) return compare(a, b);
    if (a.value is num && b.value is num) {
      return (a.value as num).compareTo(b.value as num) * (reversed ? -1 : 1);
    }
    throw ArgumentError('must provide "compare" when values is not num');
  });
  final sorted = Map.fromEntries(entries);
  if (inPlace) {
    d.clear();
    d.addEntries(entries);
    return d;
  } else {
    return sorted;
  }
}

// TODO: change to List extension
void fillListValue<T>(List<T> list, int length, T Function(int index) fill) {
  if (length <= list.length) {
    list.length = length;
  } else {
    list.addAll(
        List.generate(length - list.length, (i) => fill(list.length + i)));
  }
  // fill null if T is nullable
  for (int i = 0; i < length; i++) {
    list[i] ??= fill(i);
  }
}

class Maths {
  static T _convertNum<T extends num>(num a) {
    if (T == int) {
      return a.toInt() as T;
    } else {
      return a.toDouble() as T;
    }
  }

  static T max<T extends num>(Iterable<T> iterable) {
    return iterable.fold<T>(_convertNum<T>(0), (p, c) => math.max(p, c));
  }

  static T min<T extends num>(Iterable<T> iterable) {
    return iterable.fold<T>(_convertNum<T>(0), (p, c) => math.min(p, c));
  }

  static T sum<T extends num>(Iterable<T?> iterable) {
    return iterable.fold<T>(
        _convertNum(0), (p, c) => (p + (c ?? _convertNum<T>(0))) as T);
  }

  static bool inRange<T extends Comparable>(T? value, T lower, T upper,
      [bool includeEnds = true]) {
    if (value == null) return false;
    if (includeEnds) {
      return value.compareTo(lower) >= 0 && value.compareTo(upper) <= 0;
    } else {
      return value.compareTo(lower) > 0 && value.compareTo(upper) < 0;
    }
  }

  static MapEntry<double, double>? fitSize(
      double? width, double? height, double? aspectRatio) {
    if (aspectRatio == null || (width == null && height == null)) return null;
    if (width != null && height != null) {
      if (width / aspectRatio < height) {
        return MapEntry(width, width / aspectRatio);
      } else {
        return MapEntry(height * aspectRatio, height);
      }
    }
    if (width != null) return MapEntry(width, width / aspectRatio);
    if (height != null) return MapEntry(height * aspectRatio, height);
  }

  static T fixValidRange<T extends num>(T value, [T? minVal, T? maxVal]) {
    if (minVal != null) {
      value = math.max(value, minVal);
    }
    if (maxVal != null) {
      value = math.min(value, maxVal);
    }
    return value;
  }

  /// Sum a list of maps, map value must be number.
  /// iI [inPlace], the result is saved to the first map.
  /// null elements will be skipped.
  /// throw error if sum an empty list in place.
  static Map<K, V> sumDict<K, V extends num>(Iterable<Map<K, V>?> operands,
      {bool inPlace = false}) {
    final _operands = operands.toList();

    Map<K, V> res;
    if (inPlace) {
      assert(_operands[0] != null);
      res = _operands.removeAt(0)!;
    } else {
      res = {};
    }

    for (var m in _operands) {
      m?.forEach((k, v) {
        res[k] = ((res[k] ?? 0) + v) as V;
      });
    }
    return res;
  }

  /// Multiply the values of map with a number.
  static Map<K, V> multiplyDict<K, V extends num>(Map<K, V> d, V multiplier,
      {bool inPlace = false}) {
    Map<K, V> res = inPlace ? d : {};
    d.forEach((k, v) {
      res[k] = (v * multiplier) as V;
    });
    return res;
  }
}

abstract class EnumUtil {
  static String shortString(Object? enumObj) {
    if (enumObj == null) return enumObj.toString();
    assert(enumObj.toString().contains('.'),
        'The provided object "$enumObj" is not an enum.');
    return enumObj.toString().split('.').last;
  }

  static String titled(Object enumObj) {
    String s = shortString(enumObj);
    if (s.length > 1) {
      return s[0].toUpperCase() + s.substring(1);
    } else {
      return s;
    }
  }
}
