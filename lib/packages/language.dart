import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/db.dart' show db;
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

  static List<Language> get officialLanguages => const [jp, chs, cht, en, ko];

  static List<Language> getSortedSupportedLanguage(String? langCode) {
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
  }

  /// warn that [Intl.canonicalizedLocale] cannot treat script code
  static Language? getLanguage(String? code) {
    code = Intl.canonicalizedLocale(code ??= systemLocale.toString());
    if (code.startsWith(cht.code)) {
      return cht;
    }
    return supportLanguages
        .firstWhereOrNull((lang) => code?.startsWith(lang.code) ?? false);
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

  static Language get current => getLanguage(db.settings.language) ?? en;

  @override
  String toString() {
    return "$runtimeType('$code', '$name')";
  }
}
