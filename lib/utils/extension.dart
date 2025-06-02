import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../packages/app_info.dart';
import '../packages/platform/platform.dart';
import 'constants.dart';

// ignore: camel_case_types
typedef int32_t = int;
// ignore: camel_case_types
typedef int64_t = int;

class Ref<T> {
  T value;
  Ref(this.value);
}

extension NumX on num {
  String format({
    bool compact = true,
    bool percent = false,
    num base = 0.01, // 0.01: 0.87 -> 87%, 10: 200->20%
    bool omit = true,
    int precision = 3,
    String? groupSeparator,
    num? minVal = 10000,
    int? maxDigits,
  }) {
    num number = this;
    if (percent) {
      compact = false;
      number /= base;
    }
    if (number.isNaN) {
      return number.toString();
    }
    if (compact && (minVal == null || abs() >= minVal)) {
      return NumberFormat.compact(locale: 'en').format(number);
    }
    final pattern =
        [
          if (groupSeparator != null && groupSeparator.isNotEmpty && (minVal == null || abs() >= minVal))
            '###$groupSeparator',
          '###',
          if (precision > 0) '.${(omit ? '#' : '0') * precision}',
          // if (percent) '%'
        ].join();
    String s = NumberFormat(pattern, 'en').format(number);
    s = s.replaceFirstMapped(RegExp(r'^(\d+)\.(\d+)$'), (match) {
      String s1 = match.group(1)!, s2 = match.group(2)!;
      if (maxDigits != null) {
        if (s1.length < maxDigits) {
          s2 = s2.substring(0, min(s2.length, maxDigits - s1.length));
        } else {
          return s1;
        }
      } else if (percent && s1.length >= 3) {
        return s1;
      }
      return '$s1.$s2';
    });
    if (percent) s += '%';
    return s;
  }
}

extension IntX on int {
  DateTime sec2date() => DateTime.fromMillisecondsSinceEpoch(this * 1000);

  /// if [upperLimit]<[lowerLimit], then [lowerLimit] is used
  int clamp2(int? lowerLimit, [int? upperLimit]) {
    int result = this;
    if (upperLimit != null && upperLimit < result) result = upperLimit;
    if (lowerLimit != null && lowerLimit > result) result = lowerLimit;
    return result;
  }

  /// timestamp in seconds
  String toDateTimeString() => DateTime.fromMillisecondsSinceEpoch(this * 1000).toStringShort();

  String get padTwoDigit => toString().padLeft(2, '0');
}

extension DoubleX on double {
  /// if [upperLimit]<[lowerLimit], then [lowerLimit] is used
  double clamp2(double? lowerLimit, [double? upperLimit]) {
    double result = this;
    if (upperLimit != null && upperLimit < result) result = upperLimit;
    if (lowerLimit != null && lowerLimit > result) result = lowerLimit;
    return result;
  }
}

extension ListX<T> on List<T> {
  // add another method to support -1 index
  T? getOrNull(int index) {
    if (index >= length || index < 0) {
      return null;
    }
    // return elementAt(index % length);
    return elementAt(index);
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

  void sort2<V extends Comparable>(V Function(T e) compare, {bool reversed = false}) {
    if (reversed) {
      sort((a, b) => compare(b).compareTo(compare(a)));
    } else {
      sort((a, b) => compare(a).compareTo(compare(b)));
    }
  }

  void sortByList<V extends Comparable>(List<V> Function(T e) compare, {bool reversed = false}) {
    if (reversed) {
      sort((a, b) => compareByList(b, a, compare));
    } else {
      sort((a, b) => compareByList(a, b, compare));
    }
  }

  List<T> divided(T Function(int index) divider) {
    List<T> list2 = [];
    for (int index = 0; index < length; index++) {
      list2.add(this[index]);
      if (index != length - 1) {
        list2.add(divider(index));
      }
    }
    return list2;
  }

  static int compareByList<T, V extends Comparable>(T a, T b, List<V> Function(T v) test, [bool reversed = false]) {
    final la = test(reversed ? b : a), lb = test(reversed ? a : b);
    for (int index = 0; index < la.length; index++) {
      if (lb.length <= index) return 1;
      int r = la[index].compareTo(lb[index]);
      if (r != 0) return r;
    }
    if (la.length < lb.length) return -1;
    return 0;
  }

  List<T> sortReturn([int Function(T a, T b)? compare]) {
    sort(compare);
    return this;
  }
}

extension IterableX<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    try {
      return firstWhere(test);
    } on StateError {
      return null;
    }
  }

  E? lastWhereOrNull(bool Function(E element) test) {
    try {
      return lastWhere(test);
    } on StateError {
      return null;
    }
  }

  E? get firstOrNull => isNotEmpty ? first : null;

  E? get lastOrNull => isNotEmpty ? last : null;
}

extension SetX<E> on Set<E> {
  void toggle(E key, [bool? value]) {
    if (value == null) {
      if (contains(key)) {
        remove(key);
      } else {
        add(key);
      }
    } else {
      if (value) {
        add(key);
      } else {
        remove(key);
      }
    }
  }

  bool equalTo(Set<E> other) {
    return length == other.length && length == {...this, ...other}.length;
  }

  bool containSubset(Set<E> other) {
    return other.difference(this).isEmpty;
  }
}

extension MapX<K, V> on Map<K, V> {
  static Map<K1, V1> _deepCopy<K1, V1>(Map<K1, V1> src) {
    Map<K1, V1> result = {};
    for (final key in src.keys) {
      var v = src[key];
      if (v is Map) {
        v = _deepCopy(v) as V1;
      }
      result[key] = v as V1;
    }
    return Map.of(src);
  }

  Map<K, V> deepCopy() => _deepCopy(this);

  Iterable<(K key, V value)> get items sync* {
    for (final entry in entries) {
      yield (entry.key, entry.value);
    }
  }
}

extension NumMapDefault<K> on Map<K, int> {
  int get(K key) {
    return this[key] ?? 0;
  }

  int addNum(K key, int value) {
    return this[key] = get(key) + value;
  }

  void addDict(Map<K, int> other) {
    for (final entry in other.entries) {
      addNum(entry.key, entry.value);
    }
  }

  Map<K, int> multiple(int multiplier, {bool inplace = false}) {
    final d = inplace ? this : Map.of(this);
    for (final k in d.keys) {
      d[k] = d[k]! * multiplier;
    }
    return d;
  }
}

extension StringX on String {
  int count(String s) {
    return split(s).length - 1;
  }

  String substring2(int start, [int? end]) {
    if (start >= length) return '';
    if (end != null) {
      if (end <= start) end = start;
      if (end > length) end = length;
    }
    return substring(start, end);
  }

  DateTime? toDateTime() {
    return DateTimeX.tryParse(this);
  }

  String toTitle() {
    return replaceAllMapped(RegExp(r'\S+'), (match) {
      String s = match.group(0)!;
      return s.substring(0, 1).toUpperCase() + s.substring(1);
    });
  }

  /// for half-width ascii: 1 char=1 byte, for full-width cn/jp 1 char=3 bytes mostly.
  /// assume there is no half-width cn/jp char.
  int get charWidth {
    return (length + utf8.encode(this).length) ~/ 2;
  }

  String trimChar(String chars) {
    return trimCharLeft(chars).trimCharRight(chars);
  }

  String trimCharLeft(String chars) {
    String s = this;
    while (s.isNotEmpty && chars.contains(s.substring(0, 1))) {
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

  String setMaxLines([int n = 1]) {
    final lines = split('\n');
    if (lines.length <= n) return this;
    return [lines.sublist(0, n).join('\n'), ...lines.skip(n)].join(' ');
  }

  String get breakWord {
    String breakWord = '';
    for (final element in runes) {
      breakWord += String.fromCharCode(element);
      breakWord += '\u200B';
    }
    return breakWord;
  }

  List<int> get utf8Bytes => utf8.encode(this);

  Text toText({
    Key? key,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    TextScaler? textScaler,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
  }) {
    return Text(
      this,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}

extension DateTimeX on DateTime {
  static DateTime? tryParse(String? formattedString) {
    if (formattedString == null) return null;
    var date = DateTime.tryParse(formattedString);
    if (date != null) return date;
    // replace 2020-2-2 0:0 to 2020-02-02 00:00
    formattedString = formattedString.replaceFirstMapped(RegExp(r'^([+-]?\d{4})-?(\d{1,2})-?(\d{1,2})'), (match) {
      String year = match.group(1)!;
      String month = match.group(2)!.padLeft(2, '0');
      String day = match.group(3)!.padLeft(2, '0');
      return '$year-$month-$day';
    });
    formattedString = formattedString.replaceFirstMapped(RegExp(r'(\d{1,2}):(\d{1,2})$'), (match) {
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

  String toStringShort({bool omitSec = false}) {
    return toString().replaceFirstMapped(RegExp(r'(:\d+)(\.\d+)(Z?)'), (match) {
      return omitSec || match.group(1) == ":00" ? match.group(3)! : match.group(1)! + match.group(3)!;
    });
  }

  String toDateString([String sep = '-']) {
    return [year, month.toString().padLeft(2, '0'), day.toString().padLeft(2, '0')].join(sep);
  }

  String toTimeString({bool seconds = true, bool milliseconds = false}) {
    String output = [hour, minute, if (seconds) second].map((e) => e.toString().padLeft(2, '0')).join(":");
    if (milliseconds) {
      output += '.${millisecond.toString().padLeft(3, "0")}';
    }
    return output;
  }

  String toCustomString({bool year = true, bool second = true, bool millisecond = false}) {
    String output = [if (year) this.year, month.toString().padLeft(2, '0'), day.toString().padLeft(2, '0')].join('-');
    output += ' ';
    output += [hour, minute, if (second) this.second].map((e) => e.toString().padLeft(2, '0')).join(":");
    if (second && millisecond) {
      output += '.${this.millisecond.toString().padLeft(3, "0")}';
    }
    return output;
  }

  String toSafeFileName([Pattern? pattern]) {
    return toString().replaceAll(pattern ?? RegExp(r'[^\d]'), '_');
  }

  static int compare(DateTime? a, DateTime? b) {
    if (a != null && b != null) {
      return a.compareTo(b);
    } else if (a != null) {
      return 1;
    } else if (b != null) {
      return -1;
    } else {
      return 0;
    }
  }

  int get timestamp => millisecondsSinceEpoch ~/ 1000;
}

extension DurationX on Duration {
  String toStringX() {
    int microseconds = inMicroseconds.abs();
    bool negative = inMicroseconds < 0;
    String sign = negative ? "-" : "";

    int days = microseconds ~/ Duration.microsecondsPerDay;
    microseconds = microseconds.remainder(Duration.microsecondsPerDay);

    int hours = microseconds ~/ Duration.microsecondsPerHour;
    microseconds = microseconds.remainder(Duration.microsecondsPerHour);

    int minutes = microseconds ~/ Duration.microsecondsPerMinute;
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);

    int seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);

    int milliseconds = microseconds ~/ Duration.microsecondsPerMillisecond;

    // var microsecondsText = microseconds.toString().padLeft(6, "0");
    final buffer = StringBuffer(sign);
    if (days != 0) {
      buffer.write('${days}d ${hours}h${minutes}m${seconds}s');
    } else if (hours != 0) {
      buffer.write('${hours}h${minutes}m${seconds}s');
    } else if (minutes != 0) {
      buffer.write('${minutes}m${seconds}s');
    } else if (seconds != 0) {
      buffer.write('${seconds}s');
    } else {
      buffer.write('${milliseconds}ms');
    }
    return buffer.toString();
  }
}

/// This widget should not have any dependency of outer [context]
extension DialogShowMethod on material.Widget {
  /// Don't use this when dialog children depend on [context] or need [State.setState]
  Future<T?> showDialog<T>(
    material.BuildContext? context, {
    bool barrierDismissible = true,
    bool useRootNavigator = false,
  }) {
    context ??= kAppKey.currentContext;
    if (context == null || !context.mounted) return Future.value();
    return material.showDialog<T>(
      context: context,
      builder: (context) => this,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
    );
  }
}

extension ThemeDataX on ThemeData {
  bool get isDarkMode {
    return brightness == material.Brightness.dark;
  }
}

extension TargetPlatformX on TargetPlatform {
  bool get isMobile => const [TargetPlatform.iOS, TargetPlatform.android].contains(this);
  bool get isDesktop => !isMobile;
}

extension ColorX on Color {
  Color get inverted {
    return Color.from(alpha: a, red: a - r, green: a - g, blue: a - b);
  }

  String toCSSHex({bool omitAlpha = true}) {
    String hex = intValue.toRadixString(16).toUpperCase().padLeft(8, '0');
    if (omitAlpha && hex.startsWith('FF')) {
      hex = hex.substring(2);
    }
    return '#$hex';
  }

  int get intValue => _floatToInt8(a) << 24 | _floatToInt8(r) << 16 | _floatToInt8(g) << 8 | _floatToInt8(b) << 0;
  int get intAlpha => _floatToInt8(a);
  int get intRed => _floatToInt8(r);
  int get intGreen => _floatToInt8(g);
  int get intBlue => _floatToInt8(b);

  static int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }
}

extension ResponseX<T> on Response<T> {
  dynamic json() {
    if (data is Map) {
      return Map<String, dynamic>.from(data as Map);
    } else if (data is List) {
      return data as List<dynamic>;
    } else if (data is String) {
      return jsonDecode(data as String);
    } else {
      return null;
    }
  }
}

// ignore: non_constant_identifier_names
Dio DioE([BaseOptions? options]) {
  options ??= BaseOptions();
  final ver = AppInfo.versionString;
  final platform = PlatformU.operatingSystem;

  return Dio(
    options.copyWith(
      headers: {
        if (!kIsWeb) HttpHeaders.userAgentHeader: 'chaldea/$ver ($platform)',
        if (!kIsWeb) HttpHeaders.refererHeader: 'https://$platform.chaldea.app',
        ...options.headers,
      },
    ),
  );
}

enum HttpRequestMethod {
  put,
  get,
  post,
  delete,
  patch,
  head;

  String get methodName => name.toUpperCase();
}

extension DioX on Dio {
  RequestOptions createRequest(
    HttpRequestMethod method,
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    // ignore: invalid_use_of_internal_member
    return DioMixin.checkOptions(method.methodName, options ?? Options()).compose(
      this.options,
      path,
      data: data,
      queryParameters: queryParameters,
      onReceiveProgress: onReceiveProgress,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
      sourceStackTrace: StackTrace.current,
    );
  }
}

extension DioExceptionX on DioException {
  String _limit(String s) {
    if (s.length > 1000) return s.substring(0, 1000);
    return s;
  }

  String _tryDecodeData() {
    if (response?.data is List<int>) {
      try {
        return utf8.decode(response!.data);
      } catch (e) {
        return response!.data.toString();
      }
    } else {
      return (response?.data).toString();
    }
  }

  String messageWithData() {
    String msg = '[NetworkError] DioException [$type]: $message';
    if (response?.data != null) {
      msg += '\n${_limit(_tryDecodeData())}';
    }
    return msg;
  }
}

Future<T?> tryEasyLoading<T>(Future<T> Function() task) async {
  final mounted = EasyLoading.instance.overlayEntry?.mounted == true;
  if (mounted) return task();
  return null;
}

Future<T> showEasyLoading<T>(Future<T> Function() computation, {bool mask = false}) async {
  final mounted = EasyLoading.instance.overlayEntry?.mounted == true;
  if (!mounted) return computation();
  Widget? widget;
  try {
    await EasyLoading.dismiss();
    EasyLoading.show(maskType: mask ? EasyLoadingMaskType.clear : null);
    widget = EasyLoading.instance.w;
    return await computation();
  } finally {
    final widget2 = EasyLoading.instance.w;
    if (widget == null || widget == widget2) {
      EasyLoading.dismiss();
    } else {
      print(['easyloading container changed:', widget, widget2]);
    }
  }
}

Iterable<int> range(int a, [int? b, int? c]) sync* {
  if (c == 0) {
    throw ArgumentError.value(c, 'step', 'must not be 0');
  }
  int start, end, step;
  if (b == null) {
    start = 0;
    end = a;
    step = 1;
  } else {
    start = a;
    end = b;
    step = c ?? (end > start ? 1 : -1);
  }
  for (int i = start; (step > 0 ? i < end : i > end); i += step) {
    yield i;
  }
}
