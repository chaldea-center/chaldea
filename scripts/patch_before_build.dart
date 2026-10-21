import 'dart:convert';
import 'dart:io';

/// `dart ./scripts/patch_before_build.dart ${{ matrix.target }} ${{ github.ref }}`
void main(List<String> args) {
  print('Patch before build, args=$args');

  _patchFlutter();

  final String target = args[0];
  final String? ref = args.length >= 2 ? args[1] : null;
  if (target == 'windows') {
    // _patchWindows();
    return;
  } else if (target == 'linux') {
    // _patchLinux();
  } else if (target == 'android' && ref == 'refs/heads/main') {
    // _patchAndroidPreview();
  } else if (target == 'fdroid' || target == 'android-play') {
    patchNoGromore();
  } else if (target == 'web') {
    patchWebIconKeepAlive();
  }
}

void _patchFlutter() {
  print('Dart: ${Platform.resolvedExecutable}');
  return;
}

void replaceFlutterFile(String fp, String s1, String s2) {
  final dartFp = Uri.file(Platform.resolvedExecutable);
  final targetFp = dartFp.replace(
    pathSegments: [...dartFp.pathSegments.sublist(0, dartFp.pathSegments.length - 5), ...fp.split('/')],
  );
  print(targetFp.toFilePath());
  final targetFile = File(targetFp.toFilePath());
  assert(targetFile.existsSync());
  String content = targetFile.readAsStringSync();
  assert(content.contains(s1));
  targetFile.writeAsStringSync(targetFile.readAsStringSync().replaceFirst(s1, s2));
  return;
}

void patchAndroidPreview() {
  final buildFile = File('android/app/build.gradle');
  print('Patching ${buildFile.path}...');
  String contents = buildFile.readAsStringSync();
  // all patches start with "// "
  List<String> patches = ['// applicationIdSuffix ".preview"', '// resValue "string", "app_name", "Chaldea Preview"'];
  for (final patch in patches) {
    if (!contents.contains(patch)) {
      throw "app/build.gradle doesn't contain '$patch'";
    }
    contents = contents.replaceFirst(patch, patch.substring(2));
  }
  buildFile.writeAsStringSync(contents);
  print('set applicationIdSuffix=.preview and app_name=Chaldea Preview');
}

/// Removes flutter_gromore_ads before building the Play App Bundle.
///
/// Pangle mediation-sdk 5.9.2.8 ships arm64 libraries whose PT_LOAD alignment
/// is 4 KB; Google Play rejects such bundles on 16 KB page-size devices.
/// F-Droid uses the same patch because the SDK is not FOSS-compatible.
///
/// Strict by design: an unexpected source layout or a stale reference fails
/// the build instead of silently producing a non-compliant bundle.
void patchNoGromore() {
  const packageName = 'flutter_gromore_ads';
  const adsPath = 'lib/packages/ads/ads.dart';
  const mobilePath = 'lib/packages/ads/ad_mobile.dart';

  final pubspec = File('pubspec.yaml');
  final ads = File(adsPath);
  final mobile = File(mobilePath);
  if (!pubspec.existsSync() || !ads.existsSync()) {
    throw 'Run from the repository root: pubspec.yaml or $adsPath is missing.';
  }

  final pubspecSource = pubspec.readAsStringSync();
  final adsSource = ads.readAsStringSync();
  final dependencyPattern = RegExp(r'^[ \t]*flutter_gromore_ads:[^\n]*\n?', multiLine: true);
  final importPattern = RegExp(
    r"import 'ad_stub\.dart' if \(dart\.library\.io\) 'ad_mobile\.dart' "
    r"if \(dart\.library\.js\) 'ad_web\.dart';",
  );
  final dependencies = dependencyPattern.allMatches(pubspecSource).toList();
  final imports = importPattern.allMatches(adsSource).toList();

  if (dependencies.isEmpty && imports.isEmpty && !mobile.existsSync()) {
    print('[patch-no-gromore] already applied');
    return;
  }
  if (dependencies.length != 1 || imports.length != 1 || !mobile.existsSync()) {
    throw '[patch-no-gromore] unexpected source layout: '
        'pubspec matches=${dependencies.length}, ads.dart matches=${imports.length}, '
        'ad_mobile.dart exists=${mobile.existsSync()}. Refusing a partial patch.';
  }

  // The only supported reference is the conditional import in ads.dart.
  final strayRefs = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart') && file.path != adsPath)
      .where((file) => file.readAsStringSync().contains('ad_mobile.dart'))
      .map((file) => file.path)
      .toList();
  if (strayRefs.isNotEmpty) {
    throw '[patch-no-gromore] unexpected ad_mobile.dart references: ${strayRefs.join(', ')}';
  }

  pubspec.writeAsStringSync(pubspecSource.replaceFirst(dependencyPattern, ''));
  ads.writeAsStringSync(
    adsSource.replaceFirst(importPattern, "import 'ad_stub.dart' if (dart.library.js) 'ad_web.dart';"),
  );
  mobile.deleteSync();
  print('[patch-no-gromore] removed $packageName and switched ads.dart to the stub');

  final flutter = Platform.isWindows ? 'flutter.bat' : 'flutter';
  final pubGet = Process.runSync(flutter, ['pub', 'get'], runInShell: true);
  stdout.write(pubGet.stdout);
  stderr.write(pubGet.stderr);
  if (pubGet.exitCode != 0) {
    throw '[patch-no-gromore] flutter pub get failed with exit code ${pubGet.exitCode}';
  }

  final stale = <String, bool>{
    'pubspec.yaml': File('pubspec.yaml').readAsStringSync().contains(packageName),
    'pubspec.lock': File('pubspec.lock').readAsStringSync().contains('  $packageName:'),
    '.flutter-plugins-dependencies': File('.flutter-plugins-dependencies').readAsStringSync().contains(packageName),
    '.dart_tool/package_config.json': File('.dart_tool/package_config.json')
        .readAsStringSync()
        .contains('"$packageName"'),
    'ads.dart': File(adsPath).readAsStringSync().contains('ad_mobile.dart'),
    'ad_mobile.dart': File(mobilePath).existsSync(),
  };
  final failed = stale.entries.where((entry) => entry.value).map((entry) => entry.key).toList();
  if (failed.isNotEmpty) {
    throw '[patch-no-gromore] stale references after pub get: ${failed.join(', ')}';
  }
  print('[patch-no-gromore] verified: no $packageName reference remains');
}

// ---------------------------------------------------------------------------
// Web font-awesome keep-alive patch (remove this whole section if no longer
// needed: also drop the `target == 'web'` branch in main()).
// ---------------------------------------------------------------------------

const _keepAliveBegin = '// >>> generated by scripts/patch_before_build.dart (web icon keep-alive) >>>';
const _keepAliveEnd = '// <<< end generated (web icon keep-alive) <<<';

/// Appends a top-level `const List<IconData>` with every used font-awesome code
/// point, so Flutter's icon tree shaker keeps those glyphs on web.
///
/// `font_awesome_flutter` wraps each icon in `FaIconData` inside a
/// `@staticIconProvider` class, so the inner `IconData` is never attributed to
/// app code and gets stripped (see font_awesome_flutter#301).
void patchWebIconKeepAlive() {
  final icons = _parseFontAwesomeIcons();
  final used = _collectUsedIconNames(Directory('lib'));

  final missing = used.where((name) => !icons.containsKey(name)).toList()..sort();
  if (missing.isNotEmpty) {
    throw 'font_awesome_flutter does not define: ${missing.join(', ')}. '
        'The package layout may have changed, update the parser in patch_before_build.dart.';
  }

  final names = used.toList()..sort();
  final buffer = StringBuffer()
    ..writeln(_keepAliveBegin)
    ..writeln('const List<IconData> kFaIconKeepAlive = <IconData>[');
  for (final name in names) {
    final (codePoint, fontFamily) = icons[name]!;
    buffer.writeln(
      "  IconData(0x${codePoint.toRadixString(16)}, "
      "fontFamily: '$fontFamily', fontPackage: 'font_awesome_flutter'), // $name",
    );
  }
  buffer
    ..writeln('];')
    ..writeln(_keepAliveEnd);

  final mainFile = File('lib/main.dart');
  final content = _stripKeepAliveBlock(mainFile.readAsStringSync()).trimRight();
  mainFile.writeAsStringSync('$content\n\n$buffer');
  print('[patch-before-build] injected ${names.length} font-awesome code points into lib/main.dart');
}

/// Reads name -> (codePoint, fontFamily) from the resolved font_awesome_flutter
/// package, so icon renames in a future upgrade fail loudly.
Map<String, (int, String)> _parseFontAwesomeIcons() {
  final packageConfig = File('.dart_tool/package_config.json');
  if (!packageConfig.existsSync()) {
    throw '${packageConfig.path} not found, run `flutter pub get` first.';
  }
  final config = jsonDecode(packageConfig.readAsStringSync()) as Map<String, dynamic>;
  final packages = (config['packages'] as List).cast<Map<String, dynamic>>();
  final faPackage = packages.firstWhere(
    (package) => package['name'] == 'font_awesome_flutter',
    orElse: () => throw 'font_awesome_flutter is not a resolved dependency.',
  );

  // `rootUri` is relative to the config file and may lack a trailing slash.
  final rootUri = faPackage['rootUri'] as String;
  final packageUri = packageConfig.parent.uri.resolve(rootUri.endsWith('/') ? rootUri : '$rootUri/');
  final source = File.fromUri(packageUri.resolve('lib/font_awesome_flutter.dart'));
  assert(source.existsSync(), '${source.path} not found');

  final pattern = RegExp(
    r"static const FaIconData (\w+) = FaIconData\(\s*IconData\(\s*"
    r"0x([0-9a-fA-F]+),\s*fontFamily: '([^']+)',\s*"
    r"fontPackage: 'font_awesome_flutter'",
  );
  return {
    for (final match in pattern.allMatches(source.readAsStringSync()))
      match.group(1)!: (int.parse(match.group(2)!, radix: 16), match.group(3)!),
  };
}

Set<String> _collectUsedIconNames(Directory libDir) {
  final pattern = RegExp(r'FontAwesomeIcons\.(\w+)');
  final names = <String>{};
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    for (final match in pattern.allMatches(entity.readAsStringSync())) {
      names.add(match.group(1)!);
    }
  }
  return names;
}

String _stripKeepAliveBlock(String content) {
  final begin = content.indexOf(_keepAliveBegin);
  if (begin < 0) return content;
  final end = content.indexOf(_keepAliveEnd);
  if (end < 0) throw 'Corrupted keep-alive block in lib/main.dart: end marker missing.';
  return content.substring(0, begin) + content.substring(end + _keepAliveEnd.length);
}
