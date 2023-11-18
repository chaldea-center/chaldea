import 'dart:io';

import 'shared.dart';

void main() async {
  print('gen l10n...');
  final origin = ArbManager()..load();
  final temp = ArbManager()..load();
  temp.zh.forEach((key, value) {
    temp.zhHant[key] ??= value;
  });
  try {
    temp.save();
    // dart run intl_utils:generate
    final result = await Process.run('dart', ['run', 'intl_utils:generate'], runInShell: true);
    print(result.stdout);
    print(result.stderr);
    if (result.exitCode != 0) {
      throw result.stderr;
    }
  } finally {
    origin.save();
  }
}
