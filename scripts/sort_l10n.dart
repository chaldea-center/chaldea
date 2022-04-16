import 'dart:convert';
import 'dart:io';

class _Language {
  final String code;

  const _Language(this.code);

  static const en = _Language('en');
  static const zh = _Language('zh');
  static const zhHant = _Language('zh_Hant');
  static const ja = _Language('ja');
  static const ko = _Language('ko');
  static const es = _Language('es');
  static const ar = _Language('ar');

  static List<_Language> values = [en, zh, zhHant, ja, ko, es, ar];

  File get file => File('lib/l10n/intl_$code.arb');
}

const _kFixedKeys = ['@@locale', 'language', 'language_en'];

void main([List<String> args = const []]) {
  final bool fillNull = args.contains('-f');

  Map<String, Map<String, String?>> translations = {};
  for (final lang in _Language.values) {
    if (lang.file.existsSync()) {
      translations[lang.code] =
          Map.from(jsonDecode(lang.file.readAsStringSync()));
    } else {
      translations[lang.code] = {for (final key in _kFixedKeys) key: lang.code};
    }
  }

  List<String> keys = [];
  keys.addAll(translations[_Language.en.code]!.keys);
  keys.addAll(translations[_Language.zh.code]!.keys);
  keys = keys.toSet().toList();

  String _convertKey(String k) => _kFixedKeys.contains(k) ? '@$k' : k;
  keys.sort((a, b) => _convertKey(a).compareTo(_convertKey(b)));

  const _encoder = JsonEncoder.withIndent('  ');
  for (final lang in _Language.values) {
    final transl = translations[lang.code]!;
    Map<String, String?> newTransl = {};
    for (final key in keys) {
      if (fillNull || transl.containsKey(key)) {
        newTransl[key] = transl[key];
      }
    }
    lang.file.writeAsStringSync(_encoder.convert(newTransl) + '\n');
  }
}
