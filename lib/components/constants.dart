// @dart=2.12
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';

import 'logger.dart';

const bool kDebugMode_ = kDebugMode && false;

//typedef
//const value
const String kAppName = 'Chaldea';
const String kPackageName = 'cc.narumi.chaldea';
const String kUserDataFilename = 'userdata.json';
const String kGameDataFilename = 'dataset.json';
const String kSupportTeamEmailAddress = 'chaldea-support@narumi.cc';
const String kDatasetAssetKey = 'res/data/dataset.zip';
const String kDatasetServerPath = '/chaldea/dataset.zip';
const String kServerRoot = 'http://localhost:8080';

/// For **Tablet mode** and cross-count is 7,
/// grid view of servant and item icons won't fill full width
const double kGridIconSize = 110 * 0.5 + 6;

/// PackageInfo: appName+version+buildNumber
///  - Android: support
///  - for iOS/macOS:
///   - if CF** keys not defined in info.plist, return null
///   - if buildNumber not defined, return version instead
///  - Windows: Not Support
class AppInfo {
  static PackageInfo? _info;
  static String? _uniqueId;

  /// resolve when init app, so no need to check null or resolve every time
  /// TODO: wait official support for windows
  static Future<PackageInfo> resolve() async {
    _info ??= await PackageInfo.fromPlatform().catchError((e) async {
      final versionString = await rootBundle.loadString('res/VERSION');
      final nameAndCode = versionString.split('+');
      PackageInfo packageInfo = PackageInfo(
        appName: kAppName,
        packageName: kPackageName,
        version: nameAndCode[0],
        buildNumber: nameAndCode[1],
      );
      logger.i('Fail to read package info, asset instead: $nameAndCode');
      return packageInfo;
    });
    final deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      _uniqueId = (await deviceInfoPlugin.androidInfo).androidId;
    } else if (Platform.isIOS) {
      _uniqueId = (await deviceInfoPlugin.iosInfo).identifierForVendor;
    } else if (Platform.isWindows) {
      // reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v "ProductId"
      // Output:
      // HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion
      //     ProductId    REG_SZ    XXXXX-XXXXX-XXXXX-XXXXX
      final result = await Process.run(
        'reg',
        [
          'query',
          r'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion',
          '/v',
          'ProductId'
        ],
        runInShell: true,
      );
      String resultString = result.stdout.toString().trim();
      print('Windows Product Id query:\n$resultString');
      if (resultString.contains('ProductId') &&
          resultString.contains('REG_SZ')) {
        _uniqueId = resultString.split(RegExp(r'\s+')).last;
      }
    } else if (Platform.isMacOS) {
      // https://stackoverflow.com/a/944103
      // ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/ { split($0, line, "\""); printf("%s\n", line[4]); }'
      // the filter is shell feature so it's not used
      // Output containing:
      //  "IOPlatformUUID" = "8-4-4-4-12 standard uuid"
      // need to parse output
      final result = await Process.run(
        'ioreg',
        [
          '-rd1',
          '-c',
          'IOPlatformExpertDevice',
        ],
        runInShell: true,
      );
      for (String line in result.stdout.toString().split('\n')) {
        if (line.contains('IOPlatformUUID')) {
          final _uuid =
              RegExp(r'[0-9a-zA-Z\-]{35,36}').firstMatch(line)?.group(0);
          if (_uuid != null && _uuid.isNotEmpty) {
            _uniqueId = _uuid;
            break;
          }
        }
      }
    } else {
      throw UnimplementedError(Platform.operatingSystem);
    }
    logger.i('Unique ID: $_uniqueId');
    return _info!;
  }

  static PackageInfo? get info => _info;

  static String get appName {
    if (_info?.appName?.isNotEmpty == true)
      return _info!.appName;
    else
      return kAppName;
  }

  static String get version => _info?.version ?? '';

  static int get buildNumber => int.tryParse(_info?.buildNumber ?? '0') ?? 0;

  static String get packageName => info?.packageName ?? kPackageName;

  static String get fullVersion {
    String s = '';
    s += version;
    if (buildNumber > 0) s += '($buildNumber)';
    return s;
  }

  static String? get uniqueId => _uniqueId;

  /// currently supported mobile or desktop
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static bool get isDesktop => Platform.isMacOS || Platform.isWindows;
}

/// The global key passed to [MaterialApp], so you can access context anywhere
final kAppKey = GlobalKey<NavigatorState>();

class Language {
  final String code;
  final String name;
  final Locale locale;

  const Language(this.code, this.name, this.locale);

  static const chs = Language('zh', '简体中文', Locale('zh', ''));
  static const jpn = Language('ja', '日本語', Locale('ja', ''));
  static const eng = Language('en', 'English', Locale('en', ''));

  static List<Language> get supportLanguages => const [chs, jpn, eng];

  static Language? getLanguage(String? code) {
    for (var lang in supportLanguages) {
      if (lang.code == code) {
        return lang;
      }
    }
  }

  static String get currentLocaleCode => Intl.getCurrentLocale();

  static bool get isCN => currentLocaleCode.startsWith('zh');

  static bool get isJP => currentLocaleCode.startsWith('ja');

  static bool get isEN => currentLocaleCode.startsWith('en');
}

enum GameServer { jp, cn }

extension EnumValueToString on GameServer {
  String toValueString() {
    return this.toString().split('.').last;
  }
}

class AppColors {
  static const Color setting_bg = Color(0xFFF9F9F9);
  static const Color setting_tile = Colors.white;
}

class ClassName {
  final String name;

  const ClassName(this.name);

  static const all = const ClassName('All');
  static const saber = const ClassName('Saber');
  static const archer = const ClassName('Archer');
  static const lancer = const ClassName('Lancer');
  static const rider = const ClassName('Rider');
  static const caster = const ClassName('Caster');
  static const assassin = const ClassName('Assassin');
  static const berserker = const ClassName('Berserker');
  static const shielder = const ClassName('Shielder');
  static const ruler = const ClassName('Ruler');
  static const avenger = const ClassName('Avenger');
  static const alterego = const ClassName('Alterego');
  static const mooncancer = const ClassName('MoonCancer');
  static const foreigner = const ClassName('Foreigner');
  static const beast = const ClassName('Beast');

  static List<ClassName> get values => const [
        saber,
        archer,
        lancer,
        rider,
        caster,
        assassin,
        berserker,
        ruler,
        avenger,
        alterego,
        mooncancer,
        foreigner,
        shielder,
        beast
      ];
}

String? localizeNoun(String? nameCn, String? nameJp, String? nameEn,
    [String? k]) {
  String? name;
  name = Language.isCN
      ? nameCn
      : Language.isEN
          ? nameEn
          : nameJp;
  return name ?? nameJp ?? nameCn ?? k;
}
