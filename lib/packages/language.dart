import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/basic.dart';
import '../models/db.dart';
import '../utils/extension.dart';

class Language {
  final String code;
  final String name;
  final String nameEn;
  final Locale locale;

  const Language(this.code, this.name, this.nameEn, this.locale);

  static const jp = Language('ja', '日本語', 'Japanese', Locale('ja', ''));
  static const chs = Language('zh_Hans', '简体中文', 'Simplified Chinese',
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'));
  static const cht = Language('zh_Hant', '繁体中文', 'Traditional Chinese',
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
  static const en = Language('en', 'English', 'English', Locale('en', ''));
  static const ko = Language('ko', '한국어', 'Korean', Locale('ko', ''));
  static const ar = Language('ar', 'عربى', 'Arabic', Locale('ar', ''));
  static const es = Language('es', 'Español', 'Spanish', Locale('es', ''));

  static List<Language> get supportLanguages =>
      const [jp, chs, cht, en, ko, es, ar];

  static List<Language> get supportLanguagesLegacy =>
      const [jp, chs, cht, en, ko];

  static List<Language> get officialLanguages => const [jp, chs, cht, en, ko];

  /// warn that [Intl.canonicalizedLocale] cannot treat script code
  static Language? getLanguage(String? code) {
    code = Intl.canonicalizedLocale(code ??= systemLocale.toString());
    return (runChaldeaNext ? supportLanguages : supportLanguagesLegacy)
        .firstWhereOrNull((lang) => code?.startsWith(lang.code) ?? false);
  }

  static Locale get systemLocale =>
      WidgetsBinding.instance!.platformDispatcher.locale;

  /// used for 5 region game data
  static bool get isZH => isCHS || isCHT;

  static bool get isCHS => current == chs;

  static bool get isCHT => current == cht;

  static bool get isJP => current == jp;

  static bool get isEN => current == en;

  static bool get isKO => current == ko;

  static Language get current => getLanguage(db2.settings.language) ?? en;

  @override
  String toString() {
    return "$runtimeType('$code', '$name')";
  }

  // legacy
  static bool get isEnOrKr => isEN || isKO;
}
