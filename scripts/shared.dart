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

Map<String, String?> loadArb(ArbLang lang) {
  return Map.from(
      jsonDecode(File('lib/l10n/intl_${lang.name}.arb').readAsStringSync()));
}

void saveArb(ArbLang lang, Map<String, String?> data) {
  File('lib/l10n/intl_${lang.name}.arb').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(data) + '\n');
}
