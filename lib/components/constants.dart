import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const bool kDebugMode_ = kDebugMode && false;

//typedef
//const value
const String kAppName = 'Chaldea';
const String kPackageName = 'cc.narumi.chaldea';
const String kUserDataFilename = 'userdata.json';
const String kGameDataFilename = 'dataset.json';
const String kSupportTeamEmailAddress = 'chaldea@narumi.cc';
const String kDatasetAssetKey = 'res/data/dataset.zip';
const String kDatasetServerPath = '/chaldea/dataset.zip';
const String kServerRoot = 'http://chaldea.narumi.cc:8083';
const String kAppStoreLink = 'itms-apps://itunes.apple.com/app/id1548713491';
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

String localizeNoun(String? nameCn, String? nameJp, String? nameEn,
    [String? k]) {
  String? name;
  name = Language.isCN
      ? nameCn
      : Language.isEN
          ? nameEn
          : nameJp;
  name ??= nameJp ?? nameCn ?? k;
  // assert(name != null,
  //     'null for every localized value: $nameCn,$nameJp,$nameEn,$k');
  return name ?? '';
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

  static shortString(Object enumObj) {
    assert(enumObj.toString().contains('.'),
        'The provided object "$enumObj" is not an enum.');
    return enumObj.toString().split('.').last;
  }

  static titled(Object enumObj) {
    String s = shortString(enumObj);
    if (s.length > 1) {
      return s[0].toUpperCase() + s.substring(1);
    } else {
      return s;
    }
  }
}
