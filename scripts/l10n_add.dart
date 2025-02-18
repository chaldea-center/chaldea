/// Usage:
///   dart ./scripts/l10n_add.dart -k key_name --zh "zh" --ja "ja"
///   dart ./scripts/l10n_add.dart -d key_to_delete
import 'package:args/args.dart';

import 'shared.dart';
import 'sort_l10n.dart' as sort_l10n;

void main(List<String> args) async {
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

  for (final lang in [ArbLang.en, ArbLang.zh, ArbLang.zh_Hant, ArbLang.ja, ArbLang.ko]) {
    final data = loadArb(lang);
    if (removeKey != null) {
      data.remove(removeKey);
    } else if (addKey != null) {
      String? v = result[lang.name];
      if (v?.isEmpty == true) v = null;
      data[addKey] = v ?? data[addKey];
    } else if (result.arguments.isNotEmpty && result.arguments.first == 'replace') {
      final keys = result.arguments.sublist(1);
      assert(keys.length == 2, keys);
      data[keys[1]] = data.remove(keys[0]);
    } else {
      throw ArgumentError('Unknown arguments:${result.arguments}');
    }
    saveArb(lang, data);
    // dart run intl_utils:generate
    // await Process.run('dart', 'run intl_utils:generate'.split(' '));
  }

  sort_l10n.main();
}
