import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:kana_kit/kana_kit.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/custom_dialogs.dart';
import 'config.dart' show db;
import 'constants.dart';

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

String b64(String source, [bool decode = true]) {
  if (decode) {
    return utf8.decode(base64Decode(source));
  } else {
    return base64Encode(utf8.encode(source));
  }
}

Future<dynamic> readAndDecodeJsonAsync({String? fp, String? contents}) async {
  assert(fp != null || contents != null);
  if (fp != null && await FilePlus(fp).exists()) {
    contents = await FilePlus(fp).readAsString();
  }
  if (contents == null) return null;
  return compute(jsonDecode, contents);
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
  return math.min(420, MediaQuery.of(context).size.width * 0.8);
}

double defaultDialogHeight(BuildContext context) {
  return math.min(420, MediaQuery.of(context).size.width * 0.8);
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
  String shownLink = url;
  String? safeLink = Uri.tryParse(url)?.toString();
  if (safeLink != null) {
    shownLink = Uri.decodeFull(safeLink);
  }

  return showDialog(
    context: kAppKey.currentContext!,
    builder: (context) => SimpleCancelOkDialog(
      title: Text(S.of(context).jump_to(name ?? S.of(context).link)),
      content: Text(shownLink,
          style: const TextStyle(decoration: TextDecoration.underline)),
      onTapOk: () async {
        String link = safeLink ?? url;
        if (await canLaunch(link)) {
          launch(link);
        } else {
          EasyLoading.showToast('Could not launch url:\n$link');
        }
      },
    ),
  );
}

bool checkEventOutdated(
    {DateTime? timeJp, DateTime? timeCn, Duration? duration}) {
  duration ??= const Duration(days: 27);
  if (db.curUser.msProgress == -1 || db.curUser.msProgress == -2) {
    return DateTime.now().checkOutdated(timeCn, duration);
  } else {
    int ms = db.curUser.msProgress == -3
        ? db.gameData.events.progressTW.millisecondsSinceEpoch
        : db.curUser.msProgress == -4
            ? db.gameData.events.progressNA.millisecondsSinceEpoch
            : db.curUser.msProgress;
    return DateTime.fromMillisecondsSinceEpoch(ms)
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

Future<void> catchErrorSync(
  Function callback, {
  VoidCallback? onSuccess,
  void Function(dynamic, StackTrace?)? onError,
}) async {
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
  void Function(dynamic, StackTrace)? onError,
  VoidCallback? whenComplete,
}) async {
  try {
    await callback();
    if (onSuccess != null) onSuccess();
  } catch (e, s) {
    if (onError != null) onError(e, s);
  } finally {
    if (whenComplete != null) whenComplete();
  }
}

class Utils {
  Utils._();

  static T? findNextOrPrevious<T>({
    required List<T> list,
    required T cur,
    bool reversed = false,
    bool defaultFirst = false,
  }) {
    int curIndex = list.indexOf(cur);
    if (curIndex >= 0) {
      int nextIndex = curIndex + (reversed ? -1 : 1);
      if (nextIndex >= 0 && nextIndex < list.length) {
        return list[nextIndex];
      }
    } else if (defaultFirst && list.isNotEmpty) {
      return list.first;
    }
  }

  static void scheduleFrameCallback(VoidCallback callback) {
    SchedulerBinding.instance!.scheduleFrameCallback((timeStamp) {
      callback();
    });
  }

  static KanaKit kanaKit = const KanaKit();

  /// To lowercase alphabet:
  ///   * Chinese->Pinyin
  ///   * Japanese->Romaji
  static String toAlphabet(String text, {Language? lang}) {
    lang ??= Language.current;
    if (lang == Language.chs || lang == Language.cht) {
      return PinyinHelper.getPinyinE(text).toLowerCase();
    } else if (lang == Language.jp) {
      return kanaKit.toRomaji(text).toLowerCase();
    } else {
      return text.toLowerCase();
    }
  }

  static List<String> getSearchAlphabets(String? textCn,
      [String? textJp, String? textEn]) {
    List<String> list = [];
    if (textEn != null) list.add(textEn);
    if (textCn != null) {
      list.addAll([
        textCn,
        PinyinHelper.getPinyinE(textCn, separator: ''),
        PinyinHelper.getShortPinyin(textCn)
      ]);
    }
    // kanji to Romaji?
    if (textJp != null && textJp.length < 100) {
      try {
        list.addAll([textJp, kanaKit.toRomaji(textJp)]);
      } catch (e, s) {
        logger.e(textJp, e, s);
        rethrow;
      }
    }
    return list;
  }

  static List<String> getSearchAlphabetsForList(List<String>? textsCn,
      [List<String>? textsJp, List<String>? textsEn]) {
    List<String> list = [];
    if (textsEn != null) list.addAll(textsEn);
    if (textsCn != null) {
      for (var text in textsCn) {
        list.addAll([
          text,
          PinyinHelper.getPinyinE(text, separator: ''),
          PinyinHelper.getShortPinyin(text)
        ]);
      }
    }
    if (textsJp != null) {
      for (var text in textsJp) {
        list.addAll([text, kanaKit.toRomaji(text)]);
      }
    }
    return list;
  }

  static void debugChangeDarkMode([ThemeMode? mode]) {
    if (db.appSetting.themeMode != null && mode == db.appSetting.themeMode) {
      return;
    }

    final t = DateTime.now().millisecondsSinceEpoch;
    final _last = db.runtimeData.tempDict['debugChangeDarkMode'] ?? 0;
    if (t - _last < 2000) return;
    db.runtimeData.tempDict['debugChangeDarkMode'] = t;

    if (mode != null) {
      db.appSetting.themeMode = mode;
    } else {
      // don't rebuild
      switch (db.appSetting.themeMode) {
        case ThemeMode.light:
          db.appSetting.themeMode = ThemeMode.dark;
          break;
        case ThemeMode.dark:
          db.appSetting.themeMode = ThemeMode.light;
          break;
        default:
          db.appSetting.themeMode =
              SchedulerBinding.instance!.window.platformBrightness ==
                      Brightness.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
          break;
      }
    }
    debugPrint('change themeMode: ${db.appSetting.themeMode}');
    db.notifyAppUpdate();
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

class EasyLoadingUtil {
  EasyLoadingUtil._();

  /// default 2s of EasyLoading
  static Future<void> dismiss(
      [Duration? duration = const Duration(milliseconds: 2200)]) {
    if (duration != null) {
      return Future.delayed(duration, () => EasyLoading.dismiss());
    } else {
      EasyLoading.dismiss();
      return Future.value();
    }
  }
}

class UndraggableScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        // PointerDeviceKind.touch,
        // PointerDeviceKind.mouse,
      };
}
