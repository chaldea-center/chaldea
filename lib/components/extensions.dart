import 'package:chaldea/components/components.dart' hide showDialog;
import 'package:flutter/material.dart' as material;

/// Some convenient extensions on build-in classes

extension GetOrNull<T> on List<T> {
  T? getOrNull(int index) {
    if (index >= 0 && index < length) {
      return elementAt(index);
    }
    return null;
  }
}

extension FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool test(E element)) {
    try {
      return firstWhere(test);
    } on StateError {
      return null;
    }
  }
}

extension DateTimeEnhance on DateTime {
  static DateTime? tryParse(String? formattedString) {
    if (formattedString == null) return null;
    var date = DateTime.tryParse(formattedString);
    if (date != null) return date;
    // replace 2020-2-2 to 2020-02-02
    final _reg = RegExp(r'^([+-]?\d{4})-?(\d{1,2})-?(\d{1,2})');
    final match = _reg.firstMatch(formattedString);
    if (match != null) {
      String year = match.group(1)!;
      String month = match.group(2)!.padLeft(2, '0');
      String day = match.group(3)!.padLeft(2, '0');
      // print('replace ${match.group(0)} to ${'$year-$month-$day'}');
      return DateTime.tryParse(
          formattedString.replaceFirst(match.group(0)!, '$year-$month-$day'));
    }
  }

  /// [this] is reference time, check [dateTime] outdated or not
  /// If [duration] is provided, compare [dateTime]-[duration] ~ this
  bool checkOutdated(DateTime? dateTime, [Duration? duration]) {
    if (dateTime == null) return false;
    if (duration != null) dateTime = dateTime.add(duration);
    return this.isAfter(dateTime);
  }
}

extension StringToDateTime on String {
  DateTime? toDateTime() {
    return DateTimeEnhance.tryParse(this);
  }
}

extension TrimString on String {
  String trimChar(String chars) {
    return this.trimCharLeft(chars).trimCharRight(chars);
  }

  String trimCharLeft(String chars) {
    String s = this;
    while (s.isNotEmpty && chars.contains(s[0])) {
      s = s.substring(1);
    }
    return s;
  }

  String trimCharRight(String chars) {
    String s = this;
    while (s.isNotEmpty && chars.contains(s[s.length - 1])) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }
}

extension DialogShowMethod on Widget {
  Future<T?> showDialog<T>([BuildContext? context]) {
    context ??= kAppKey.currentContext;
    if (context == null) return Future.value();
    return material.showDialog<T>(context: context, builder: (context) => this);
  }
}
