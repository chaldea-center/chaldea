import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  String version = args[0];
  final String outPath = args[1];

  if (version == 'beta') {
    //
  } else if (RegExp(r'^v\d+\.\d+\.\d+$').hasMatch(version)) {
    version = version.substring(1);
  } else if (RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version)) {
    //
  } else {
    throw UnsupportedError('Unknown version: "$version"');
  }

  print('* ${Directory.current}');
  print('* Version: $version');
  final en = getReleaseNote('CHANGELOG.md', version) ?? "", zh = getReleaseNote('CHANGELOG_ZH.md', version) ?? "";
  final buffer = StringBuffer();
  if (en.isNotEmpty) {
    buffer.writeln("EN:");
    buffer.writeln(en.trim());
  }
  if (en.isNotEmpty && zh.isNotEmpty) {
    buffer.writeln();
  }
  if (zh.isNotEmpty) {
    buffer.writeln("ZH:");
    buffer.writeln(zh.trim());
  }
  if (buffer.isEmpty) {
    String time = DateTime.now().toUtc().toIso8601String();
    time = time.split('.').first.replaceFirst('T', ' ');
    buffer.writeln("Built at $time UTC");
  }
  final releaseFile = File(outPath);
  releaseFile.writeAsStringSync(buffer.toString());
  print("* Release Note($outPath):\n${'#' * 40}\n$buffer\n${'#' * 40}");
}

String? getReleaseNote(String fp, String version) {
  final contents = File(fp).readAsStringSync();
  final blocks = contents.split(RegExp(r'\n## ')).skip(1).toList();
  for (final block in blocks) {
    final lines = const LineSplitter().convert(block);
    final header = lines.first.trim();
    if (header == version) {
      return lines.skip(1).join('\n');
    }
  }
  if (version == 'beta') {
    final lastRelease = blocks.firstOrNull;
    if (lastRelease != null) {
      final lines = const LineSplitter().convert(lastRelease);
      final header = lines.first.trim();
      if (RegExp(r'^\d+\.\d+\.\d+$').hasMatch(header)) {
        return lines.skip(1).join('\n');
      }
    }
  }
  return null;
}
