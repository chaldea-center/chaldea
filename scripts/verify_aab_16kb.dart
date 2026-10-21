import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Verifies that an Android App Bundle is safe for 16 KB page-size devices.
///
/// Usage:
///   dart run scripts/verify_aab_16kb.dart `<path-to-aab>`
///
/// Google Play requires every 64-bit native library to declare
/// `PT_LOAD p_align >= 0x4000`. The script also rejects leftover Gromore/Pangle
/// artifacts so a partially applied patch cannot reach the store.
void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run scripts/verify_aab_16kb.dart <path-to-aab>');
    exit(64);
  }
  final aab = File(args.single);
  if (!aab.existsSync()) {
    stderr.writeln('[verify-16kb] AAB not found: ${aab.path}');
    exit(66);
  }

  final temp = Directory.systemTemp.createTempSync('verify_aab_');
  final failures = <String>[];
  try {
    final extract = Platform.isWindows
        ? Process.runSync('tar', ['-xf', aab.absolute.path, '-C', temp.path])
        : Process.runSync('unzip', ['-q', aab.absolute.path, '-d', temp.path]);
    if (extract.exitCode != 0) {
      failures.add('failed to extract AAB: ${extract.stderr}');
    } else {
      _inspect(temp, failures);
    }
  } finally {
    temp.deleteSync(recursive: true);
  }

  if (failures.isEmpty) {
    stdout.writeln('[verify-16kb] PASS');
    return;
  }
  stderr.writeln('[verify-16kb] FAIL');
  for (final failure in failures) {
    stderr.writeln('  - $failure');
  }
  exit(1);
}

void _inspect(Directory root, List<String> failures) {
  final files = root.listSync(recursive: true).whereType<File>().toList();
  final names = files.map((file) => file.path.substring(root.path.length + 1)).toList();

  for (final name in names) {
    if (RegExp(r'gromore|pangle|bytedance|openadsdk', caseSensitive: false).hasMatch(name)) {
      failures.add('forbidden artifact: $name');
    }
  }

  for (final required in ['libapp.so', 'libflutter.so']) {
    if (!names.any((name) => name.endsWith('arm64-v8a/$required'))) {
      failures.add('missing required 64-bit library: arm64-v8a/$required');
    }
  }

  var checked64 = 0;
  var checked32 = 0;
  for (final file in files.where((file) => file.path.endsWith('.so'))) {
    final relative = file.path.substring(root.path.length + 1);
    final bytes = file.readAsBytesSync();
    if (bytes.length < 52 || bytes[0] != 0x7f || bytes[1] != 0x45 || bytes[2] != 0x4c || bytes[3] != 0x46) {
      failures.add('$relative: not an ELF file');
      continue;
    }

    final List<int> aligns;
    try {
      aligns = _elfLoadAligns(bytes);
    } on FormatException catch (error) {
      failures.add('$relative: ${error.message}');
      continue;
    }
    if (aligns.isEmpty) {
      failures.add('$relative: no PT_LOAD segments');
      continue;
    }

    final minAlign = aligns.reduce((a, b) => a < b ? a : b);
    if (bytes[4] == 2) {
      checked64++;
      if (minAlign < 0x4000) {
        failures.add('$relative: 64-bit p_align=0x${minAlign.toRadixString(16)} (< 0x4000)');
      }
    } else {
      checked32++;
      if (minAlign < 0x4000) {
        // 32-bit devices still use 4 KB pages; Play only enforces the 64-bit ABIs.
        stdout.writeln('[verify-16kb] WARN 32-bit $relative: p_align=0x${minAlign.toRadixString(16)}');
      }
    }
  }
  if (checked64 == 0) {
    failures.add('no 64-bit native libraries found');
  }
  stdout.writeln('[verify-16kb] checked $checked64 64-bit / $checked32 32-bit libraries');

  final manifest = File('${root.path}/base/manifest/AndroidManifest.xml');
  if (manifest.existsSync()) {
    final bytes = manifest.readAsBytesSync();
    for (final needle in ['TTFileProvider', 'openadsdk', 'bytedance']) {
      if (_containsEncoded(bytes, needle)) {
        failures.add('AndroidManifest.xml still contains "$needle"');
      }
    }
  }

  for (final dex in files.where((file) => file.path.endsWith('.dex'))) {
    final text = latin1.decode(dex.readAsBytesSync(), allowInvalid: true);
    if (text.contains('com/bytedance/sdk/openadsdk')) {
      failures.add('${dex.path.substring(root.path.length + 1)} still contains com/bytedance/sdk/openadsdk');
    }
  }
}

/// Returns the `p_align` value of every `PT_LOAD` program header.
List<int> _elfLoadAligns(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  final is64 = bytes[4] == 2;
  final little = bytes[5] == 1;
  int u16(int offset) => little ? data.getUint16(offset, Endian.little) : data.getUint16(offset, Endian.big);
  int u32(int offset) => little ? data.getUint32(offset, Endian.little) : data.getUint32(offset, Endian.big);
  int u64(int offset) => little ? data.getUint64(offset, Endian.little) : data.getUint64(offset, Endian.big);

  final phoff = is64 ? u64(32) : u32(28);
  final phentsize = u16(is64 ? 54 : 42);
  final phnum = u16(is64 ? 56 : 44);
  final result = <int>[];
  for (var i = 0; i < phnum; i++) {
    final offset = phoff + i * phentsize;
    if (offset + phentsize > bytes.length) {
      throw const FormatException('program header out of bounds');
    }
    if (u32(offset) != 1) continue; // PT_LOAD
    result.add(is64 ? u64(offset + 48) : u32(offset + 28));
  }
  return result;
}

/// Searches both ASCII and UTF-16LE, since Android binary XML stores strings
/// in either encoding.
bool _containsEncoded(List<int> bytes, String needle) {
  final ascii = latin1.decode(bytes, allowInvalid: true).toLowerCase();
  if (ascii.contains(needle.toLowerCase())) return true;

  final utf16 = <int>[];
  for (final unit in needle.codeUnits) {
    utf16
      ..add(unit & 0xff)
      ..add((unit >> 8) & 0xff);
  }
  for (var i = 0; i + utf16.length <= bytes.length; i++) {
    var match = true;
    for (var j = 0; j < utf16.length; j++) {
      if (bytes[i + j] != utf16[j]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}
