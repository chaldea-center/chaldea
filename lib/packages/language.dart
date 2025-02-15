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
  static const chs = Language(
    'zh',
    '简体中文',
    'Simplified Chinese',
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'cn'),
  );
  static const cht = Language(
    'zh_Hant',
    '繁體中文',
    'Traditional Chinese',
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  );
  static const en = Language('en', 'English', 'English', Locale('en', ''));
  static const ko = Language('ko', '한국어', 'Korean', Locale('ko', ''));
  static const es = Language('es', 'Español', 'Spanish', Locale('es', ''));
  static const ru = Language('ru', 'Русский', 'Russian', Locale('ru', ''));
  static const ar = Language('ar', '\u0639\u0631\u0628\u064a', 'Arabic', Locale('ar', ''));

  // static const List<Language> supportLanguages = [jp, chs, cht, en, ko];
  static const List<Language> supportLanguages = [jp, chs, cht, en, ko, es, ru, ar];

  static const List<Language> officialLanguages = [jp, chs, cht, en, ko];

  static List<Language> getSortedSupportedLanguage(String? langCode) {
    final langs = switch (getLanguage(langCode)) {
      jp => [jp, chs, cht, en, ko, es, ru, ar],
      chs => [chs, cht, jp, en, ko, es, ru, ar],
      cht => [cht, chs, jp, en, ko, es, ru, ar],
      en => [en, jp, chs, cht, ko, es, ru, ar],
      ko => [ko, jp, chs, cht, en, es, ru, ar],
      es => [es, en, jp, chs, cht, ko, ru, ar],
      ru => [ru, en, jp, chs, cht, ko, es, ar],
      ar => [ar, en, jp, chs, cht, ko, es, ru],
      _ => [en, jp, chs, cht, ko, es, ru, ar],
    };
    return langs.where((lang) => supportLanguages.contains(lang)).toList();
  }

  /// warn that [Intl.canonicalizedLocale] cannot treat script code
  static Language? getLanguage(String? code) {
    code = Intl.canonicalizedLocale(code ??= systemLocale.toString());
    if (code.startsWith(cht.code)) {
      return cht;
    }
    return supportLanguages.firstWhereOrNull((lang) => code?.startsWith(lang.code) ?? false);
  }

  static Locale get systemLocale => WidgetsBinding.instance.platformDispatcher.locale;

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
