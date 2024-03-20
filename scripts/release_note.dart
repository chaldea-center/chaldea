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
  final en = getReleaseNote('CHANGELOG.md', version) ?? "", zh = getReleaseNote('CHANGELOG.zh.md', version) ?? "";
  final buffer = StringBuffer();

  if (zh.isNotEmpty) {
    buffer.writeln("ZH:");
    buffer.writeln(zh);
  }
  if (en.isNotEmpty && zh.isNotEmpty) {
    buffer.writeln();
  }
  if (en.isNotEmpty) {
    buffer.writeln("EN:");
    buffer.writeln(en);
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
      return lines.skip(1).join('\n').trim();
    }
  }

  final fallbackVersion = version == 'beta' ? RegExp(r'^\d+\.\d+\.\d+$') : RegExp('beta');
  final lastRelease = blocks.firstOrNull;
  if (lastRelease != null) {
    final lines = const LineSplitter().convert(lastRelease);
    final header = lines.first.trim();
    if (fallbackVersion.hasMatch(header)) {
      return lines.skip(1).join('\n').trim();
    }
  }
  return null;
}
