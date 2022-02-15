import 'dart:io';

void main() {
  final mainJsFile = File('build/web/main.dart.js');
  print('[patch-web] patching "${mainJsFile.path}"');
  String content = mainJsFile.readAsStringSync();
  int patched = 0;
  content = content.replaceAllMapped(
    RegExp(r'"https://fonts\.googleapis\.com|"https://fonts\.gstatic\.com'),
    (m) {
      final host = m.group(0)!;
      if (host == '"https://fonts.googleapis.com') {
        patched++;
        return '(window.isCNHost?"https://fonts.font.im":"https://fonts.googleapis.com")+"';
      } else if (host == '"https://fonts.gstatic.com') {
        patched++;
        return '(window.isCNHost?"https://fonts.gstatic.font.im":"https://fonts.gstatic.com")+"';
      } else {
        throw 'unknown host: <$host>';
      }
    },
  );
  mainJsFile.writeAsStringSync(content);
  print('[patch-web] $patched patched');
}
