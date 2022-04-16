import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart' as csv;

const langCodes = ['en', 'zh', 'zh_Hant', 'ja', 'ko', 'es', 'ar'];

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
  Map<String, Map<String, String?>> l10n = {};
  for (final lang in langCodes) {
    l10n[lang] = Map.from(jsonDecode(_getL10n(lang).readAsStringSync()));
  }

  List<List> rows = [];
  rows.add(['key', ...langCodes]);

  for (final key in l10n['en']!.keys) {
    rows.add([key, ...langCodes.map((e) => l10n[e]![key] ?? "")]);
  }

  const converter = csv.ListToCsvConverter(eol: '\n');
  File(target).writeAsStringSync(converter.convert(rows));
}

void _csv2l10n(String source) {
  Map<String, Map<String, String?>> l10n = {};
  for (final lang in langCodes) {
    l10n[lang] = Map.from(jsonDecode(_getL10n(lang).readAsStringSync()));
  }
  const converter = csv.CsvToListConverter(eol: '\r\n');
  final rows = converter.convert(File(source).readAsStringSync());
  assert(rows.first.skip(1).toList().toString() == langCodes.toString(),
      rows.first);
  final headers = rows.first.skip(1).toList();
  final langMap = {
    for (int i = 0; i < headers.length; i++) i + 1: headers[i],
  };
  print(rows.first.toList());
  for (final row in rows.skip(1)) {
    assert(row.length == langCodes.length + 1);
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
      l10n[lang]![key] = s;
    }
  }
  for (final lang in langCodes) {
    _getL10n(lang).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(l10n[lang]!) + '\n');
  }
}

File _getL10n(String lang) => File('lib/l10n/intl_$lang.arb');
