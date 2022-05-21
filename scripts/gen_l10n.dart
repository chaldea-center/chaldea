import 'dart:io';

import 'shared.dart';

void main() async {
  final origin = ArbManager()..load();
  final temp = ArbManager()..load();
  temp.zh.forEach((key, value) {
    temp.zhHant[key] ??= value;
  });
  temp.save();
  // flutter pub run intl_utils:generate
  final result =
      await Process.run('flutter', ['pub', 'run', 'intl_utils:generate']);
  print(result.stderr);
  print(result.stderr);
  origin.save();
}
