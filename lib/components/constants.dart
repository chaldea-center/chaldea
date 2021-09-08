import 'package:chaldea/platform_interface/platform/platform.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'device_app_info.dart';
import 'extensions.dart';

//typedef
//const value
const String kAppName = 'Chaldea';
const String kPackageName = 'cc.narumi.chaldea';
const String kUserDataFilename = 'userdata.json';
const String kGameDataFilename = 'dataset.json';
const String kSupportTeamEmailAddress = 'chaldea@narumi.cc';
const String kDatasetAssetKey = 'res/data/dataset.zip';
const String kDatasetServerPath = '/chaldea/dataset.zip';
// String get kServerRoot => 'http://localhost:8083';
const String kServerRoot = 'http://chaldea.narumi.cc';
const String kAppStoreLink = 'itms-apps://itunes.apple.com/app/id1548713491';
const String kAppStoreHttpLink = 'https://itunes.apple.com/app/id1548713491';
const String kGooglePlayLink =
    'https://play.google.com/store/apps/details?id=cc.narumi.chaldea';
const String kProjectHomepage = 'https://github.com/chaldea-center/chaldea';
const String kDatasetHomepage =
    'https://github.com/chaldea-center/chaldea-dataset';

/// For **Tablet mode** and cross-count is 7,
/// grid view of servant and item icons won't fill full width
const double kGridIconSize = 110 * 0.5 + 6;

/// The global key passed to [MaterialApp], so you can access context anywhere
final kAppKey = GlobalKey<NavigatorState>();
const kDefaultDivider = Divider(height: 1, thickness: 0.5);
const kMonoFont = 'RobotoMono';
const kMonoStyle = TextStyle(fontFamily: kMonoFont);

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
    if (code == null) return null;
    Language? language =
        supportLanguages.firstWhereOrNull((lang) => lang.code == code);
    language ??= supportLanguages
        .firstWhereOrNull((lang) => code.startsWith(lang.locale.languageCode));
    return language;
  }

  static String get currentLocaleCode => Intl.getCurrentLocale();

  static bool get isCN => currentLocaleCode.startsWith('zh');

  static bool get isJP => currentLocaleCode.startsWith('ja');

  static bool get isEN => currentLocaleCode.startsWith('en');

  static Language get current => isJP
      ? jpn
      : isEN
          ? eng
          : chs;

  @override
  String toString() {
    return "$runtimeType('$code', '$name')";
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
        beast,
      ];
}

T localizeNoun<T>(T? nameCn, T? nameJp, T? nameEn,
    {T k()?, Language? primary}) {
  // convert '' to null
  if (nameJp is String && nameJp.isEmpty) {
    nameJp = null;
  }
  if (nameEn is String && nameEn.isEmpty) {
    nameEn = null;
  }

  primary ??= Language.current;
  List<T?> names = primary == Language.chs
      ? [nameCn, nameJp, nameEn]
      : primary == Language.eng
          ? [nameEn, nameJp, nameCn]
          : [nameJp, nameCn, nameEn];
  T? name = names[0] ?? names[1] ?? names[2] ?? k?.call();
  // assert(name != null,
  //     'null for every localized value: $nameCn,$nameJp,$nameEn,$k');
  if (T == String) {
    return name ?? '' as T;
  }
  return name!;
}

class Constants {
  Constants._();

  static int iconWidth = 132;
  static int iconHeight = 144;
  static double iconAspectRatio = iconWidth / iconHeight;
  static int skillIconSize = 110;
}

class EnumUtil {
  EnumUtil._();

  static String shortString(Object enumObj) {
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

class HttpUtils {
  HttpUtils._();

  static const usernameKey = 'username';
  static const passwordKey = 'password';
  static const newPasswordKey = 'newPassword';
  static const bodyKey = 'body';

  static Dio get defaultDio => Dio(BaseOptions(headers: headersWithUA()));

  static String get userAgentChaldea => 'Chaldea/${AppInfo.version}';

  static String get userAgentMacOS =>
      'Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.146 Safari/537.36 $userAgentChaldea';

  static String get userAgentWindows =>
      ' Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.54 $userAgentChaldea';

  static String get userAgentIOS =>
      'Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/69.0.3497.105 Mobile/15E148 Safari/605.1 $userAgentChaldea';

  static String get userAgentAndroid =>
      'Mozilla/5.0 (Linux; Android 8.0.0; SM-G960F Build/R16NW) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.84 Mobile Safari/537.36 $userAgentChaldea';

  static String get userAgentPlatform {
    if (PlatformU.isAndroid) return userAgentAndroid;
    if (PlatformU.isIOS) return userAgentIOS;
    if (PlatformU.isWindows) return userAgentWindows;
    if (PlatformU.isMacOS) return userAgentMacOS;
    return userAgentIOS;
  }

  static Map<String, dynamic> headersWithUA([String? ua]) {
    return {
      if (!PlatformU.isWeb) "user-agent": ua ?? userAgentPlatform,
    };
  }
}
