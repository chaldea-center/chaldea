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

  void fixLength(int length, T Function() k) {
    assert(length >= 0);
    if (this.length == length) return;
    if (this.length > length) {
      this.length = length;
    } else {
      addAll(List.generate(length - this.length, (index) => k()));
    }
  }
}

extension FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    try {
      return firstWhere(test);
    } on StateError {
      return null;
    }
  }
}

extension DateTimeX on DateTime {
  static DateTime? tryParse(String? formattedString) {
    if (formattedString == null) return null;
    var date = DateTime.tryParse(formattedString);
    if (date != null) return date;
    // replace 2020-2-2 0:0 to 2020-02-02 00:00
    formattedString = formattedString.replaceFirstMapped(
        RegExp(r'^([+-]?\d{4})-?(\d{1,2})-?(\d{1,2})'), (match) {
      String year = match.group(1)!;
      String month = match.group(2)!.padLeft(2, '0');
      String day = match.group(3)!.padLeft(2, '0');
      return '$year-$month-$day';
    });
    formattedString = formattedString
        .replaceFirstMapped(RegExp(r'(\d{1,2}):(\d{1,2})$'), (match) {
      String hour = match.group(1)!.padLeft(2, '0');
      String minute = match.group(2)!.padLeft(2, '0');
      return '$hour:$minute';
    });
    return DateTime.tryParse(formattedString);
  }

  /// [this] is reference time, check [dateTime] outdated or not
  /// If [duration] is provided, compare [dateTime]-[duration] ~ this
  bool checkOutdated(DateTime? dateTime, [Duration? duration]) {
    if (dateTime == null) return false;
    if (duration != null) dateTime = dateTime.add(duration);
    return isAfter(dateTime);
  }

  String toStringShort() {
    return toString().split('.').first;
  }

  String toDateString([String sep = '-']) {
    return [
      year,
      month.toString().padLeft(2, '0'),
      day.toString().padLeft(2, '0')
    ].join(sep);
  }
}

extension StringToDateTime on String {
  DateTime? toDateTime() {
    return DateTimeX.tryParse(this);
  }

  String toTitle() {
    return replaceAllMapped(RegExp(r'\S+'), (match) {
      String s = match.group(0)!;
      return s.substring(0, 1).toUpperCase() + s.substring(1);
    });
  }
}

extension TrimString on String {
  String trimChar(String chars) {
    return trimCharLeft(chars).trimCharRight(chars);
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
  /// Don't use this when dialog children depends on [context]
  Future<T?> showDialog<T>(BuildContext? context,
      {bool barrierDismissible = true}) {
    context ??= kAppKey.currentContext;
    if (context == null) return Future.value();
    return material.showDialog<T>(
      context: context,
      builder: (context) => this,
      barrierDismissible: barrierDismissible,
    );
  }
}

extension SafeSetState<T extends StatefulWidget> on State<T> {
  void safeSetState() {
    if (mounted) {
      setState(() {}); //ignore: invalid_use_of_protected_member
    }
  }
}
