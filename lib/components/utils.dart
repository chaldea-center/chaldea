import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show max, min;

import 'package:chaldea/generated/l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart' show db;
import 'constants.dart';
import 'custom_dialogs.dart';
import 'extensions.dart';
import 'logger.dart';

/// Math related
///

/// Format number
///
/// If [compact] is true, other parameters are not used.
String formatNumber(num? number,
    {bool compact = false,
    bool percent = false,
    bool omit = true,
    int precision = 3,
    String? groupSeparator = ',',
    num? minVal}) {
  assert(!compact || !percent);
  if (number == null || (minVal != null && number.abs() < minVal.abs())) {
    return number.toString();
  }

  if (compact) {
    return NumberFormat.compact(locale: 'en').format(number);
  }

  final pattern = [
    if (groupSeparator != null) '###' + groupSeparator,
    '###',
    if (precision > 0) '.' + (omit ? '#' : '0') * precision,
    if (percent) '%'
  ].join();
  return NumberFormat(pattern).format(number);
}

class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    int? value = int.tryParse(newValue.text);
    if (value == null) {
      return newValue;
    }
    String newText = formatNumber(value);
    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length));
  }
}

dynamic deepCopy(dynamic obj) {
  return jsonDecode(jsonEncode(obj));
}

/// Sum a list of number, list item defaults to 0 if null
T sum<T extends num>(Iterable<T?> x) {
  if (0 is T) {
    return x.fold(0 as T, (p, c) => (p + (c ?? 0)) as T);
  } else {
    return x.fold(0.0 as T, (p, c) => (p + (c ?? 0.0)) as T);
  }
}

/// Sum a list of maps, map value must be number.
/// iI [inPlace], the result is saved to the first map.
/// null elements will be skipped.
/// throw error if sum an empty list in place.
Map<K, V> sumDict<K, V extends num>(Iterable<Map<K, V>?> operands,
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
Map<K, V> multiplyDict<K, V extends num>(Map<K, V> d, V multiplier,
    {bool inPlace = false}) {
  Map<K, V> res = inPlace ? d : {};
  d.forEach((k, v) {
    res[k] = (v * multiplier) as V;
  });
  return res;
}

/// [reversed] is used only when [compare] is null for default num values sort
Map<K, V> sortDict<K, V>(Map<K, V> d,
    {bool reversed = false,
    int compare(MapEntry<K, V> a, MapEntry<K, V> b)?,
    bool inPlace = false}) {
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

/// If invalid index or null data passed, return default value.
T? getListItem<T>(List<T>? data, int index, [k()?]) {
  if (data == null || data.length <= index) {
    return k?.call();
  } else {
    return data[index];
  }
}

String b64(String source, [bool decode = true]) {
  if (decode) {
    return utf8.decode(base64Decode(source));
  } else {
    return base64Encode(utf8.encode(source));
  }
}

T fixValidRange<T extends num>(T value, [T? minVal, T? maxVal]) {
  if (minVal != null) {
    value = max(value, minVal);
  }
  if (maxVal != null) {
    value = min(value, maxVal);
  }
  return value;
}

void fillListValue<T>(List<T> list, int length, T fill(int index)) {
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

/// Flutter related
///

void showInformDialog(BuildContext context,
    {String? title,
    String? content,
    List<Widget> actions = const [],
    bool showOk = true,
    bool showCancel = false}) {
  assert(title != null || content != null);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: title == null ? null : Text(title),
      content: content == null ? null : Text(content),
      actions: <Widget>[
        if (showOk)
          TextButton(
            child: Text(S.of(context).confirm),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        if (showCancel)
          TextButton(
            child: Text(S.of(context).cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ...actions
      ],
    ),
  );
}

typedef SheetBuilder = Widget Function(BuildContext, StateSetter);

void showSheet(BuildContext context,
    {required SheetBuilder builder, double size = 0.65}) {
  assert(size >= 0.25 && size <= 1);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        return DraggableScrollableSheet(
          initialChildSize: size,
          minChildSize: 0.25,
          maxChildSize: 1,
          expand: false,
          builder: (context, scrollController) =>
              builder(sheetContext, setSheetState),
        );
      },
    ),
  );
}

double defaultDialogWidth(BuildContext context) {
  return min(420, MediaQuery.of(context).size.width * 0.8);
}

double defaultDialogHeight(BuildContext context) {
  return min(420, MediaQuery.of(context).size.width * 0.8);
}

/// other utils

class TimeCounter {
  String name;
  final Stopwatch stopwatch = Stopwatch();

  TimeCounter(this.name, {bool autostart = true}) {
    if (autostart) stopwatch.start();
  }

  void start() {
    stopwatch.start();
  }

  void elapsed() {
    final d = stopwatch.elapsed.toString();
    logger.d('Stopwatch - $name: $d');
  }
}

Future<void> jumpToExternalLinkAlert(
    {required String url, String? name}) async {
  return showDialog(
    context: kAppKey.currentContext!,
    builder: (context) => SimpleCancelOkDialog(
      title: Text(S.of(context).jump_to(name ?? S.of(context).link)),
      content:
          Text(url, style: TextStyle(decoration: TextDecoration.underline)),
      onTapOk: () async {
        final safeLink = Uri.tryParse(url).toString();
        if (await canLaunch(safeLink)) {
          launch(safeLink);
        } else {
          EasyLoading.showToast('Could not launch url:\n$url');
        }
      },
    ),
  );
}

bool checkEventOutdated(
    {DateTime? timeJp, DateTime? timeCn, Duration? duration}) {
  duration ??= Duration(days: 27);
  if (db.curUser.msProgress <= 0) {
    return DateTime.now().checkOutdated(timeCn, duration);
  } else {
    return DateTime.fromMillisecondsSinceEpoch(db.curUser.msProgress)
        .checkOutdated(timeJp, duration);
  }
}

String _fullChars =
    '０１２３４５６７８９ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ－、\u3000／';
String _halfChars =
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-, /';

Map<String, String> _fullHalfMap =
    Map.fromIterables(_fullChars.split(''), _halfChars.split(''));

String fullToHalf(String s) {
  String s2 = s.replaceAllMapped(RegExp(r'[０-９Ａ-Ｚ－／　]'),
      (match) => _fullHalfMap[match.group(0)!] ?? match.group(0)!);
  return s2;
}

void catchErrorSync(
  Function callback, {
  VoidCallback? onSuccess,
  void onError(e, s)?,
}) {
  try {
    callback();
    if (onSuccess != null) onSuccess();
  } catch (e, s) {
    if (onError != null) onError(e, s);
  }
}

Future<void> catchErrorAsync(
  Function callback, {
  VoidCallback? onSuccess,
  void onError(e, s)?,
}) async {
  try {
    await callback();
    if (onSuccess != null) onSuccess();
  } catch (e, s) {
    if (onError != null) onError(e, s);
  }
}

void copyOrMoveDirectory(
  Directory src,
  Directory dest, {
  bool move = false,
  bool test(FileSystemEntity entity)?,
}) {
  dest.createSync(recursive: true);
  for (FileSystemEntity entity in src.listSync()) {
    if (test != null && !test(entity)) continue;
    if (entity is Directory) {
      var newDirectory =
          Directory(join(dest.absolute.path, basename(entity.path)));
      newDirectory.createSync();
      copyOrMoveDirectory(entity.absolute, newDirectory,
          move: move, test: test);
    } else if (entity is File) {
      String newPath = join(dest.path, basename(entity.path));
      if (move) {
        entity.renameSync(newPath);
      } else {
        entity.copySync(newPath);
      }
    }
  }
}

class Utils {
  Utils._();

  static T? findNextOrPrevious<T>(List<T> list, T cur, bool next) {
    int curIndex = list.indexOf(cur);
    if (curIndex < 0) return null;
    int nextIndex = curIndex + (next ? 1 : -1);
    if (nextIndex >= 0 && nextIndex < list.length) {
      return list[nextIndex];
    }
  }

  static void addPostFrameCallback(VoidCallback callback) {
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      callback();
    });
  }

  static KanaKit kanaKit = KanaKit();

  /// To lowercase alphabet:
  ///   * Chinese->Pinyin
  ///   * Japanese->Romaji
  static String toAlphabet(String text, {Language? lang}) {
    lang ??= Language.current;
    if (lang == Language.chs) {
      return PinyinHelper.getPinyinE(text).toLowerCase();
    } else if (lang == Language.jpn) {
      return kanaKit.toRomaji(text).toLowerCase();
    } else {
      return text.toLowerCase();
    }
  }

  static List<String> getSearchAlphabets(String? textCn,
      [String? textJp, String? textEn]) {
    List<String> list = [];
    if (textEn != null) list.add(textEn);
    if (textCn != null)
      list.addAll([
        textCn,
        PinyinHelper.getPinyinE(textCn, separator: ''),
        PinyinHelper.getShortPinyin(textCn)
      ]);
    // kanji to Romaji?
    if (textJp != null) list.addAll([textJp, kanaKit.toRomaji(textJp)]);
    return list;
  }

  static List<String> getSearchAlphabetsForList(List<String>? textsCn,
      [List<String>? textsJp, List<String>? textsEn]) {
    List<String> list = [];
    if (textsEn != null) list.addAll(textsEn);
    if (textsCn != null)
      for (var text in textsCn) {
        list.addAll([
          text,
          PinyinHelper.getPinyinE(text, separator: ''),
          PinyinHelper.getShortPinyin(text)
        ]);
      }
    if (textsJp != null)
      for (var text in textsJp) {
        list.addAll([text, kanaKit.toRomaji(text)]);
      }
    return list;
  }
}

class DelayedTimer {
  Duration duration;

  Timer? _timer;

  Timer? get timer => _timer;

  DelayedTimer(this.duration);

  /// If want to call [setState], remember to check [mounted]
  Timer delayed(void Function() callback) {
    _timer?.cancel();
    return _timer = Timer(duration, callback);
  }
}
