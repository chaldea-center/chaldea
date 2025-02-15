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
  } else if (target == 'fdroid') {
    patchFDroid();
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

void patchFDroid() {
  File('lib/packages/ads/ad_mobile.dart').deleteSync();

  File file = File('lib/packages/ads/ads.dart');
  file.writeAsStringSync(file.readAsStringSync().replaceAll('ad_mobile.dart', 'ad_stub.dart'));

  file = File('pubspec.yaml');
  file.writeAsStringSync(file.readAsLinesSync().where((e) => !e.trim().startsWith('google_mobile_ads:')).join('\n'));

  // ignore: unused_element
  void _removeLines(String fp, Pattern trailing) {
    final file = File(fp);
    List<String> lines = file.readAsLinesSync();
    lines = lines.map((line) => trailing.allMatches(line.trim()).isEmpty ? line : '').toList();
    file.writeAsStringSync(lines.join('\n'));
  }
}
