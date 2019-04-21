import 'package:flutter/material.dart';

const String defaultAppDataFilename = 'userdata.json';

class LangCode {
  // code must match S.of(context).language in every .arb file
  static const String chs = 'chs';
  static const String cht = 'cht';
  static const String jpn = 'jpn';
  static const String eng = 'eng';
  static const _allLanguage = {
    chs: ['简体中文', const Locale('zh', '')],
    cht: ['繁體中文', const Locale('zh', 'TW')],
    jpn: ['日本語', const Locale('ja', '')],
    eng: ['English', const Locale('en', '')],
  };

  static String getName(String code) =>
      codes.contains(code) ? _allLanguage[code][0] as String : null;

  static Locale getLocale(String code) =>
      codes.contains(code) ? _allLanguage[code][1] as Locale : null;

  static List<String> get codes => _allLanguage.keys.toList();

  static List<String> get names =>
      _allLanguage.values.map((v) => v[0] as String).toList();
}

class AppColor{
  static const Color setting_bg=Color(0xFFF9F9F9);
  static const Color setting_tile=Colors.white;
}

