import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  // final arbFp = args[0], libFolder = args[1];
  const arbFp = './lib/l10n/intl_en.arb', libFolder = './lib';
  final translations = Map<String, String>.from(jsonDecode(File(arbFp).readAsStringSync()));
  Set<String> unusedKeys = translations.keys.where((e) => !e.startsWith('@')).toSet();
  unusedKeys.removeAll(['language', 'language_en']);
  final files = Directory(libFolder).listSync(recursive: true, followLinks: false);
  final total = files.length;
  int index = 0;
  for (final file in files) {
    index++;
    stdout.write("\r\x1b[K\r$index/$total... ${file.path}");
    if (file is! File) continue;
    if (!file.path.endsWith('.dart')) continue;
    final contents = file.readAsStringSync();
    for (final reg in [RegExp(r"S\.current\.(\w+)\W"), RegExp(r"S\.of\(context\)\.(\w+)\W")]) {
      final foundKeys = reg.allMatches(contents).map((e) => e.group(1)!).toSet();
      unusedKeys.removeAll(foundKeys);
    }
  }
  print('\nDone');
  print(unusedKeys);
}

// dart ./scripts/l10n_add.dart -d
