import 'dart:io';

import 'shared.dart';

void main() async {
  final origin = ArbManager()..load();
  final temp = ArbManager()..load();
  temp.zh.forEach((key, value) {
    temp.zhHant[key] ??= value;
  });
  try {
    temp.save();
    // flutter pub run intl_utils:generate
    final result = await Process.run('flutter', ['pub', 'run', 'intl_utils:generate'], runInShell: true);
    print(result.stdout);
    if (result.exitCode != 0) {
      throw result.stderr;
    }
  } finally {
    origin.save();
  }
}
