import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

// should be same as [GameConstants._cvtKey]
String _toDartFieldName(String name) {
  final segments = name.split('_').map((e) => e.toLowerCase()).toList();
  for (int index = 1; index < segments.length; index++) {
    String s = segments[index];
    if (s.isNotEmpty) {
      segments[index] = s.substring(0, 1).toUpperCase() + s.substring(1);
    }
  }
  String key2 = segments.join('');
  if (key2.startsWith(RegExp(r'\d'))) {
    key2 = 'k$key2';
  }
  return key2;
}

List<String> disableFormat(List<String> lines) {
  const int kLineWidth = 120;
  if (lines.any((e) => e.length > kLineWidth)) {
    String getPad(String line) {
      return ' ' * (line.length - line.trimLeft().length);
    }

    return ['${getPad(lines.first)}// dart format off', ...lines, '${getPad(lines.first)}// dart format on'];
  }
  return lines;
}

Future<List<Map<String, Object>>> getRawData(Uri uri) async {
  List content;
  if (uri.isScheme('file')) {
    content = jsonDecode(await File.fromUri(uri).readAsString());
  } else if (uri.isScheme('https') || uri.isScheme('http')) {
    content = (await Dio().getUri(uri, options: Options(responseType: ResponseType.json))).data;
  } else {
    throw UnsupportedError(uri.toString());
  }

  return [for (final v in content) Map<String, Object>.from(v)];
}

Future<String> genConstIntCode() async {
  const String clsName = "GameConstants";
  final constInts = await getRawData(Uri.file("/Users/narumi/Projects/atlas/fgo-game-data-jp/master/mstConstant.json"));

  List<({String name, String dartName, int value})> entries = [
    for (final item in constInts)
      (name: item["name"] as String, dartName: _toDartFieldName(item["name"] as String), value: item["value"] as int),
  ];
  entries.sort((a, b) => a.name.compareTo(b.name));
  String code = """
@JsonSerializable()
class $clsName {""";
  for (final entry in entries) {
    code += "\n  final int ${entry.dartName}; // ${entry.value}";
  }
  code += "\n\n  const $clsName({";
  for (final entry in entries) {
    code += "\n    this.${entry.dartName} = ${entry.value},";
  }
  code += "\n  });";
  return code;
}

Future<String> genConstStrCode() async {
  const String clsName = "GameConstantStr";
  final rawEntries = await getRawData(
    Uri.file("/Users/narumi/Projects/atlas/fgo-game-data-jp/master/mstConstantStr.json"),
  );

  // need update chaldea-parser too
  const intListKeys = <String>[
    // INDIV
    "IGNORE_RESIST_FUNC_INDIVIDUALITY",
    "INVALID_SACRIFICE_INDIV",
    "NP_INDIVIDUALITY_DAMAGE_ALL",
    "NP_INDIVIDUALITY_DAMAGE_ONE",
    "NP_INDIVIDUALITY_NOT_DAMAGE",
    "SUB_PT_BUFF_INDIVI",
    "SVT_EXIT_PT_BUFF_INDIVI",
    // BUFF
    "EXTEND_TURN_BUFF_TYPE",
    "NOT_REDUCE_COUNT_WITH_NO_DAMAGE_BUFF",
    "STAR_REFRESH_BUFF_TYPE",
    // FUNC
    "FUNCTION_TYPE_NOT_NP_DAMAGE",
    // OTHERS
    "PLAYABLE_BEAST_CLASS_IDS",
    "ENABLE_OVERWRITE_CLASS_IDS",
    "OVERWRITE_TO_NP_INDIVIDUALITY_DAMAGE_ALL_BY_TREASURE_DEVICE_IDS",
    "OVERWRITE_TO_NP_INDIVIDUALITY_DAMAGE_ONE_BY_TREASURE_DEVICE_IDS",
  ];

  Object? parseValue(String name, String value) {
    if (intListKeys.contains(name)) {
      return value.split(",").map(int.parse).toList();
    }
    return null;
  }

  String toConstValue(Object value) {
    if (value is List || value is Map) {
      return "const $value";
    }
    return value.toString();
  }

  List<({String name, String dartName, Object value})> entries = [];
  for (final item in rawEntries) {
    final name = item["name"] as String;
    final dartName = _toDartFieldName(name);
    final value = parseValue(name, item["value"] as String);
    if (value == null) continue;
    entries.add((name: name, dartName: dartName, value: value));
  }
  entries.sort((a, b) => a.name.compareTo(b.name));

  List<String> codes = [
    """
@JsonSerializable()
class $clsName {""",
  ];

  codes.addAll(
    disableFormat([
      for (final entry in entries) "  final ${entry.value.runtimeType} ${entry.dartName}; // ${entry.value}",
    ]),
  );

  codes.add("");
  codes.add("  const $clsName({");
  codes.addAll(
    disableFormat([for (final entry in entries) "    this.${entry.dartName} = ${toConstValue(entry.value)},"]),
  );
  codes.add("  });");
  return codes.join('\n');
}

String replaceFlagContent(String content, String flag, String repl) {
  List<String> rows = LineSplitter().convert(content);
  int startIndex = rows.indexWhere((e) => e.trim() == "// $flag start");
  int endIndex = rows.indexWhere((e) => e.trim() == "// $flag end");
  if (startIndex < 0 || endIndex < 0) {
    throw FormatException('start/end flag not found: $startIndex, $endIndex');
  }
  rows.removeRange(startIndex + 1, endIndex);
  rows.insert(startIndex + 1, repl);
  return rows.join("\n");
}

Future<void> main() async {
  final file = File("lib/models/gamedata/const_data.dart");
  String content = file.readAsStringSync();
  content = replaceFlagContent(content, 'GameConstants', await genConstIntCode());
  content = replaceFlagContent(content, 'GameConstantStr', await genConstStrCode());
  file.writeAsStringSync(content);
  print('done');
}
