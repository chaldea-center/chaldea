import 'dart:io';

import 'package:csv/csv.dart' as csv;

import 'shared.dart';

/// Usage:
///   * dart l10n_csv.dart output.csv
///   * dart l10n_csv.dart -r input.csv
void main(List<String> args) {
  if (args[0] == '-r') {
    _csv2l10n(args[1]);
  } else {
    _l10n2csv(args[0]);
  }
}

void _l10n2csv(String target) {
  final manager = ArbManager()..load();

  List<List> rows = [];
  rows.add(['key', ...ArbLang.values.map((e) => e.name)]);

  for (final key in manager.en.keys) {
    rows.add([key, ...ArbLang.values.map((e) => manager.data[e]![key] ?? "")]);
  }

  const converter = csv.ListToCsvConverter(eol: '\n');
  File(target).writeAsStringSync(converter.convert(rows));
}

void _csv2l10n(String source) {
  final manager = ArbManager()..load();
  const converter = csv.CsvToListConverter(eol: '\r\n');
  final rows = converter.convert(File(source).readAsStringSync());
  assert(
      rows.first.skip(1).toList().toString() ==
          ArbLang.values.map((e) => e.name).toList().toString(),
      rows.first);
  final headers = rows.first.skip(1).toList().cast<String>();
  final langMap = {
    for (int i = 0; i < headers.length; i++) i + 1: headers[i],
  };
  print(rows.first.toList());
  for (final row in rows.skip(1)) {
    assert(row.length == ArbLang.values.length + 1);
    final key = row[0];
    for (int col = 1; col < row.length; col++) {
      String s = row[col];
      if (s.trim().isEmpty) continue;
      final lang = langMap[col];
      if (lang == null) continue;
      s = s.replaceAll('""', '"');
      s = s.replaceAllMapped(RegExp(r'^"(.+)"$'), (m) => m.group(1)!);
      if (s.contains('"')) {
        print(s);
      }
      manager.data[lang]![key] = s;
    }
  }
  manager.save();
}
