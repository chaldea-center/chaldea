import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  // final arbFp = args[0], libFolder = args[1];
  const arbFp = './lib/l10n/intl_en.arb', libFolder = './lib';
  final translations = Map<String, String>.from(jsonDecode(File(arbFp).readAsStringSync()));
  Set<String> unusedKeys = translations.keys.where((e) => !e.startsWith('@')).toSet();
  final files = Directory(libFolder).listSync(recursive: true, followLinks: false);
  final total = files.length;
  int index = 0;
  for (final file in files) {
    index++;
    stdout.write("\r\x1b[K\r$index/$total... ${file.path}");
    if (file is! File) continue;
    if (!file.path.endsWith('.dart')) continue;
    final contents = file.readAsStringSync();
    for (final key in unusedKeys.toList()) {
      if (RegExp(r"S\.current\." + key + r"\W").hasMatch(contents) ||
          RegExp(r"S\.of\(context\)\." + key + r"\W").hasMatch(contents)) {
        unusedKeys.remove(key);
        continue;
      }
    }
  }
  print('\nDone');
  print(unusedKeys);
}

// dart ./scripts/l10n_add.dart -d
