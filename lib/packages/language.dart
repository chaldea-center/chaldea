import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/basic.dart' show runChaldeaNext;
import '../models/db.dart' show db2;
import '../components/config.dart' show db;
import '../utils/extension.dart';

class Language {
  final String code;
  final String name;
  final String nameEn;
  final Locale locale;

  const Language(this.code, this.name, this.nameEn, this.locale);

  static const jp = Language('ja', '日本語', 'Japanese', Locale('ja', ''));
  static const chs = Language('zh', '简体中文', 'Simplified Chinese',
      Locale.fromSubtags(languageCode: 'zh'));
  static const cht = Language('zh_Hant', '繁体中文', 'Traditional Chinese',
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
  static const en = Language('en', 'English', 'English', Locale('en', ''));
  static const ko = Language('ko', '한국어', 'Korean', Locale('ko', ''));
  static const ar = Language('ar', 'عربي', 'Arabic', Locale('ar', ''));
  static const es = Language('es', 'Español', 'Spanish', Locale('es', ''));

  static List<Language> get supportLanguages =>
      const [jp, chs, cht, en, ko, es, ar];

  static List<Language> get supportLanguagesLegacy =>
      const [jp, chs, cht, en, ko];

  static List<Language> get officialLanguages => const [jp, chs, cht, en, ko];

  static List<Language> getSortedSupportedLanguage(String? langCode) {
    if (runChaldeaNext) {
      switch (getLanguage(langCode)) {
        case jp:
          return [jp, chs, cht, en, ko, ar, es];
        case chs:
          return [chs, cht, jp, en, ko, ar, es];
        case cht:
          return [cht, chs, jp, en, ko, ar, es];
        case en:
          return [en, jp, chs, cht, ko, ar, es];
        case ko:
          return [ko, jp, chs, cht, en, ar, es];
        case ar:
          return [ar, en, jp, chs, cht, ko, es];
        case es:
          return [es, en, jp, chs, cht, ko, ar];
        default:
          return [en, jp, chs, cht, ko, ar, es];
      }
    } else {
      switch (getLanguage(langCode)) {
        case jp:
          return [jp, chs, cht, en, ko];
        case chs:
          return [chs, cht, jp, en, ko];
        case cht:
          return [cht, chs, jp, en, ko];
        case en:
          return [en, jp, chs, cht, ko];
        case ko:
          return [ko, jp, chs, cht, en];
        default:
          return [en, jp, chs, cht, ko];
      }
    }
  }

  /// warn that [Intl.canonicalizedLocale] cannot treat script code
  static Language? getLanguage(String? code) {
    code = Intl.canonicalizedLocale(code ??= systemLocale.toString());
    Language? lang =
        (runChaldeaNext ? supportLanguages : supportLanguagesLegacy)
            .firstWhereOrNull((lang) => code?.startsWith(lang.code) ?? false);
    if (lang == null && code.startsWith('zh')) {
      return chs;
    }
    return lang;
  }

  static Locale get systemLocale =>
      WidgetsBinding.instance.platformDispatcher.locale;

  /// used for 5 region game data
  static bool get isZH => isCHS || isCHT;

  static bool get isCHS => current == chs;

  static bool get isCHT => current == cht;

  static bool get isJP => current == jp;

  static bool get isEN => current == en;

  static bool get isKO => current == ko;

  static Language get current =>
      getLanguage(
          runChaldeaNext ? db2.settings.language : db.appSetting.language) ??
      en;

  @override
  String toString() {
    return "$runtimeType('$code', '$name')";
  }

  // legacy
  static bool get isEnOrKr => isEN || isKO;
}
