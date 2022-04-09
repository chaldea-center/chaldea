import 'dart:io';

void main() {
  final buildFile = File('android/app/build.gradle');
  print('Patching ${buildFile.path}...');
  String contents = buildFile.readAsStringSync();
  // all patches start with "// "
  List<String> patches = [
    '// applicationIdSuffix ".preview"',
    '// resValue "string", "app_name", "Chaldea Preview"'
  ];
  for (final patch in patches) {
    if (!contents.contains(patch)) {
      throw "app/build.gradle doesn't contain '$patch'";
    }
    contents = contents.replaceFirst(patch, patch.substring(2));
  }
  buildFile.writeAsStringSync(contents);
  print('set applicationIdSuffix=.preview and app_name=Chaldea Preview');
}
