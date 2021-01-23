// @dart=2.12
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';

const bool kDebugMode_ = kDebugMode && false;

//typedef
//const value
const String kAppName = 'Chaldea';
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
///  TODO: how to retrieve correct value of windows ?
class AppInfo {
  static PackageInfo? _info;

  /// resolve when init app, so no need to check null or resolve every time
  static Future<PackageInfo> resolve() async {
    _info ??= await PackageInfo.fromPlatform().catchError((e) => PackageInfo());
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

  static String get fullVersion {
    String s = '';
    s += version;
    if (buildNumber > 0) s += '($buildNumber)';
    return s;
  }

  /// currently supported mobile or desktop
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static bool get isDesktop => Platform.isMacOS || Platform.isWindows;
}

/// The global key passed to [MaterialApp], so you can access context anywhere
final kAppKey = GlobalKey<NavigatorState>();

//const value in class
class Language {
  final String code;
  final String name;
  final Locale locale;

  const Language(this.code, this.name, this.locale);

  static const chs = Language('chs', '简体中文', Locale('zh', ''));
  static const cht = Language('cht', '繁體中文', Locale('zh', 'TW'));
  static const jpn = Language('jpn', '日本語', Locale('ja', ''));
  static const eng = Language('eng', 'English', Locale('en', ''));

  static List<Language> get languages => const [chs, cht, jpn, eng];

  static Language? getLanguage([String? code]) {
    if (code == null) {
      return languages.first;
    } else {
      for (final c in languages) {
        if (c.code == code) {
          return c;
        }
      }
    }
  }
}

class MyLocale {
  MyLocale._();

  static String get locale => Intl.getCurrentLocale();

  static bool get isCN => locale.toLowerCase().startsWith('zh');

  static bool get isTW => locale == 'zh_TW';

  static bool get isJP => locale.toLowerCase().startsWith('ja');

  static bool get isEN => locale.toLowerCase().startsWith('en');
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

String localizeGameNoun(String nameCn, String? nameJp, String? nameEn) {
  final locale = Intl.getCurrentLocale().toLowerCase();
  if (locale.startsWith('zh')) return nameCn;
  if (locale.startsWith('en')) return nameEn ?? nameJp ?? nameCn;
  return nameJp ?? nameCn;
}
