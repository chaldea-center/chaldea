import 'dart:convert';
import 'dart:io';

enum ArbLang {
  en,
  zh,
  // ignore: constant_identifier_names
  zh_Hant,
  ja,
  ko,
  es,
  ar,
}

ArbLang parseArbLang(String lang) {
  return {
    'en': ArbLang.en,
    'zh': ArbLang.zh,
    'zh_Hant': ArbLang.zh_Hant,
    'ja': ArbLang.ja,
    'ko': ArbLang.ko,
    'es': ArbLang.es,
    'ar': ArbLang.ar,
  }[lang]!;
}

Map<String, String?> loadArb(ArbLang lang) {
  return Map.from(jsonDecode(File('lib/l10n/intl_${lang.name}.arb').readAsStringSync()));
}

void saveArb(ArbLang lang, Map<String, String?> data) {
  File('lib/l10n/intl_${lang.name}.arb').writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(data)}\n');
}

class ArbManager {
  Map<ArbLang, Map<String, String?>> data = {};
  ArbManager();

  Map<String, String?> get en => data[ArbLang.en]!;
  Map<String, String?> get zh => data[ArbLang.zh]!;
  Map<String, String?> get zhHant => data[ArbLang.zh_Hant]!;
  Map<String, String?> get ja => data[ArbLang.ja]!;
  Map<String, String?> get ko => data[ArbLang.ko]!;
  Map<String, String?> get es => data[ArbLang.es]!;
  Map<String, String?> get ar => data[ArbLang.ar]!;

  void load() {
    for (final lang in ArbLang.values) {
      data[lang] = loadArb(lang);
    }
  }

  void save() {
    for (final lang in ArbLang.values) {
      saveArb(lang, data[lang]!);
    }
  }
}
