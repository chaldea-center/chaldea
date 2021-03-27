import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show max, min;

import 'package:chaldea/generated/l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart' show db;
import 'constants.dart';
import 'custom_dialogs.dart';
import 'device_app_info.dart';
import 'extensions.dart';
import 'git_tool.dart';
import 'logger.dart';
import 'shared_prefs.dart';

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

void safeSetState(VoidCallback callback) {
  SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
    callback();
  });
}

void checkAppUpdate([bool background = true]) async {
  BuildContext context = kAppKey.currentContext!;
  String? versionString;
  String? releaseNote;
  String? launchUrl;

  GitTool gitTool = GitTool.fromDb();
  try {
    if (Platform.isAndroid || Platform.isWindows || kDebugMode) {
      final release =
          await gitTool.latestAppRelease(kDebugMode ? (asset) => true : null);
      versionString = release?.name;
      if (versionString?.startsWith('v') == true)
        versionString = versionString!.substring(1);
      // v1.x.y+z
      releaseNote = release?.body;
      // launchUrl = release!.htmlUrl
      // launchUrl = release!.targetAsset!.browserDownloadUrl;
      launchUrl = gitTool.appReleaseUrl;
    } else if (Platform.isIOS) {
      // use https and set UA, or the fetched info may be outdated
      // this http request always return iOS version result
      final response = await Dio()
          .get('https://itunes.apple.com/lookup?bundleId=$kPackageName',
              options: Options(responseType: ResponseType.plain, headers: {
                'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
                    " AppleWebKit/537.36 (KHTML, like Gecko)"
                    " Chrome/88.0.4324.146"
                    " Safari/537.36 Edg/88.0.705.62"
              }));
      // print(response.data);
      final jsonData = json.decode(response.data.toString().trim());
      // logger.d(jsonData);
      final result = jsonData['results'][0];
      versionString = result['version'];
      releaseNote = result['releaseNotes'];
    } else if (Platform.isMacOS) {
      // not supported yet
    }
  } catch (e, s) {
    logger.e('Query update failed: $e', e, s);
  }
  if (versionString == null) {
    logger.w('Failed to query app updates');
    if (!background) {
      SimpleCancelOkDialog(
        title: Text(S.of(context).about_update_app),
        content: Text(S.of(context).query_failed),
        hideOk: true,
      ).show(context);
    }
    return;
  }

  Version? version = Version.tryParse(versionString);
  Version? curVer = Version.tryParse(AppInfo.fullVersion);
  bool appUpgradable = version != null && curVer != null && version > curVer;
  db.runtimeData.upgradableVersion = appUpgradable ? version : null;
  if (!kDebugMode && (Platform.isIOS || Platform.isMacOS)) {
    // Guideline 2.4.5(vii) - Performance
    // The Mac App Store provides customers with notifications of updates
    // pending for all apps delivered through the App Store, and allows the
    // user to update applications through the Mac App Store app. You should
    // not provide additional update checks or updates through your app.
    if (!background) {
      launch(kAppStoreLink);
    }
    return;
  }

  // android & windows
  // no update
  if (background && !appUpgradable) {
    logger.i('No update: fetched=${version?.fullVersion}, '
        'cur=${curVer?.fullVersion}');
    return;
  }
  // upgradable, ignore
  if (background &&
      db.prefs.instance.getString(SharedPrefs.ignoreAppVersion) ==
          versionString) {
    logger.i('Latest version: $versionString, ignore this update.');
    return;
  }

  releaseNote = releaseNote?.replaceAll('\r\n', '\n');
  logger.i('Release note:\n$releaseNote');

  // background&&upgradable, user-click
  SimpleCancelOkDialog(
    title: Text(S.of(context).about_update_app),
    content: SingleChildScrollView(
      child: Text(
        S.of(context).about_update_app_detail(
            AppInfo.fullVersion, versionString, releaseNote ?? '-'),
      ),
    ),
    hideOk: true,
    actions: [
      TextButton(
        child: Text(S.of(context).update),
        onPressed: !appUpgradable || launchUrl == null
            ? null
            : () => launch(launchUrl!),
      ),
      if (appUpgradable)
        TextButton(
          child: Text(S.of(context).ignore),
          onPressed: () {
            db.prefs.instance
                .setString(SharedPrefs.ignoreAppVersion, versionString!);
            Navigator.of(context).pop();
          },
        ),
      if (Platform.isAndroid)
        TextButton(
          child: Text('Google Play'),
          onPressed: () {
            launch(kGooglePlayLink);
          },
        ),
      if (Platform.isIOS || Platform.isMacOS)
        TextButton(
          child: Text('App Store'),
          onPressed: () {
            launch(kAppStoreLink);
          },
        ),
      if (Platform.isWindows)
        TextButton(
          child: Text('${gitTool.source.toTitleString()} Release'),
          onPressed: () {
            launch(gitTool.appReleaseUrl);
          },
        ),
    ],
  ).show(context);
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
        final safeLink = Uri.encodeFull(url);
        if (await canLaunch(safeLink)) {
          launch(safeLink);
        } else {
          EasyLoading.showToast('Could not launch url:\n$safeLink');
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
