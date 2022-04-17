import 'package:args/args.dart';

import 'shared.dart';
import 'sort_l10n.dart' as sort_l10n;

void main(List<String> args) {
  final parser = ArgParser();
  parser.addOption('key', abbr: 'k');
  parser.addOption('delete', abbr: 'd');
  for (final lang in ArbLang.values) {
    parser.addOption(lang.name);
  }
  final result = parser.parse(args);
  print([result.arguments, result.rest]);

  String? removeKey = result['delete'];
  String? addKey = result['key'];
  assert(removeKey == null || addKey == null);
  assert(removeKey != null || addKey != null);

  for (final lang in ArbLang.values) {
    final data = loadArb(lang);
    if (removeKey != null) {
      data.remove(removeKey);
    } else if (addKey != null) {
      final v = result[lang.name];
      data[addKey] = v ?? data[addKey];
    } else if (result.arguments.isNotEmpty &&
        result.arguments.first == 'replace') {
      final keys = result.arguments.sublist(1);
      assert(keys.length == 2, keys);
      data[keys[1]] = data.remove(keys[0]);
    } else {
      throw ArgumentError('Unknown arguments:${result.arguments}');
    }
    saveArb(lang, data);
  }

  sort_l10n.main();
}
