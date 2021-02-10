// @dart=2.12
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show max, min;

import 'package:chaldea/components/components.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'git_tool.dart';
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

VoidCallback showMyProgress(
    {Duration period = const Duration(seconds: 1),
    String? status,
    EasyLoadingMaskType maskType = EasyLoadingMaskType.clear}) {
  int counts = 0;
  Timer.periodic(Duration(milliseconds: 25), (timer) {
    counts += 1;
    var progress = counts * 25.0 / period.inMilliseconds % 1.0;
    if (counts < 0) {
      timer.cancel();
      EasyLoading.dismiss();
    } else {
      EasyLoading.showProgress(progress, status: status, maskType: maskType);
    }
  });
  return () => counts = -100;
}

Future<String?> resolveWikiFileUrl(String filename) async {
  if (db.prefs.containsKey(filename)) {
    return db.prefs.getString(filename);
  }
  final _dio = Dio();
  try {
    final response = await _dio.get(
      'https://fgo.wiki/api.php',
      queryParameters: {
        "action": "query",
        "format": "json",
        "prop": "imageinfo",
        "iiprop": "url",
        "titles": "File:$filename"
      },
      options: Options(responseType: ResponseType.json),
    );
    final String url =
        response.data['query']['pages'].values.first['imageinfo'][0]['url'];
    print('wiki image/file url=$url');
    db.prefs.setString(filename, url);
    return url;
  } catch (e) {
    print(e);
  }
}

void checkAppUpdate([bool background = true]) async {
  const ignoreUpdateKey = 'ignoreAppUpdateVersion';
  BuildContext context = kAppKey.currentContext!;
  String? versionString;
  String? releaseNote;
  String? launchUrl;
  try {
    if (Platform.isIOS || Platform.isMacOS) {
      launchUrl = 'itms-apps://itunes.apple.com/app/id1548713491';
      // use https and set UA, or the fetched info may be outdated
      final response = await Dio()
          .get('https://itunes.apple.com/lookup?bundleId=$kPackageName',
              options: Options(responseType: ResponseType.plain, headers: {
                'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
                    " AppleWebKit/537.36 (KHTML, like Gecko)"
                    " Chrome/88.0.4324.146"
                    " Safari/537.36 Edg/88.0.705.62"
              }));
      final jsonData = json.decode(response.data.toString().trim());
      // logger.d(jsonData);
      final result = jsonData['results'][0];
      versionString = result['version'];
      releaseNote = result['releaseNotes'];
    } else if (Platform.isAndroid || Platform.isWindows) {
      GitTool gitTool = GitTool.fromIndex(db.userData.appDatasetUpdateSource);
      final release = await gitTool.latestAppRelease();
      versionString = release?.name;
      if (versionString?.startsWith('v') == true)
        versionString = versionString!.substring(1);
      // v1.x.y+z
      releaseNote = release?.body;
      if (release?.targetAsset?.browserDownloadUrl.isNotEmpty == true) {
        launchUrl = release!.targetAsset!.browserDownloadUrl;
      } else {
        launchUrl =
            GitTool.getReleasePageUrl(db.userData.appDatasetUpdateSource, true);
      }
    }
  } catch (e) {
    logger.e('Query update failed: $e');
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
  bool isVersionEqual = version?.equalTo(AppInfo.fullVersion) == true;
  if (isVersionEqual && background) {
    logger.i('Already the latest version: ${version?.fullVersion}');
    return;
  }

  if (db.prefs.getString(ignoreUpdateKey) == versionString && background) {
    logger.i('Latest version: $versionString, ignore this update.');
    return;
  }
  logger.i('Release note:\n$releaseNote');
  SimpleCancelOkDialog(
    title: Text(S.of(context).about_update_app),
    content: Text(
      S.of(context).about_update_app_detail(
          AppInfo.fullVersion, versionString, releaseNote),
    ),
    hideOk: true,
    actions: [
      TextButton(
        child: Text(S.of(context).update),
        onPressed: isVersionEqual || launchUrl == null
            ? null
            : () => launch(launchUrl!),
      ),
      if (!isVersionEqual)
        TextButton(
          child: Text(S.of(context).ignore),
          onPressed: () {
            db.prefs.setString(ignoreUpdateKey, versionString);
            Navigator.of(context).pop();
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

String mooncellFullLink(String title, {bool encode = false}) {
  String link = 'https://fgo.wiki/w/$title';
  if (encode) link = Uri.encodeFull(link);
  return link;
}
