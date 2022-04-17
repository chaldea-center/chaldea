import 'shared.dart';

const _kFixedKeys = ['@@locale', 'language', 'language_en'];

void main([List<String> args = const []]) {
  final bool fillNull = args.contains('-f');

  Map<ArbLang, Map<String, String?>> translations = {};
  for (final lang in ArbLang.values) {
    translations[lang] = loadArb(lang);
  }

  List<String> keys = [];
  keys.addAll(translations[ArbLang.en]!.keys);
  keys.addAll(translations[ArbLang.zh]!.keys);
  keys = keys.toSet().toList();

  String _convertKey(String k) => _kFixedKeys.contains(k) ? '@$k' : k;
  keys.sort((a, b) => _convertKey(a).compareTo(_convertKey(b)));

  for (final lang in ArbLang.values) {
    final transl = translations[lang]!;
    Map<String, String?> newTransl = {};
    for (final key in keys) {
      if (fillNull || transl.containsKey(key)) {
        newTransl[key] = transl[key];
      }
    }
    saveArb(lang, newTransl);
  }
}
