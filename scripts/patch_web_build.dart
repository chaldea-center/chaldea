import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

const _buildDir = 'build/web';

class _FileInfo {
  final String fn;
  final File file;
  late final String initHash;
  late String content;
  late String newHash;

  _FileInfo(this.fn) : file = File('$_buildDir/$fn') {
    final _bytes = file.readAsBytesSync();
    newHash = initHash = md5.convert(_bytes).toString();
    content = utf8.decode(_bytes);
  }

  String updateHash() {
    return newHash = md5.convert(utf8.encode(content)).toString();
  }

  void save() {
    file.writeAsStringSync(content);
  }
}

void main() {
  // if any library uses differ loading... wtf

  final mainJs = _FileInfo('main.dart.js'),
      indexHtml = _FileInfo('index.html'),
      // jsMap = _FileInfo('main.dart.js.map'),
      sw = _FileInfo('flutter_service_worker.js');

  final flutterVersion = Platform.environment['FLUTTER_VERSION'];
  if (flutterVersion != null && RegExp(r'').hasMatch(flutterVersion)) {
    indexHtml.content = indexHtml.content.replaceAll('?v=FLUTTER_VERSION', '?v=$flutterVersion');
  }

  // change google fonts url for cn
  print('[patch-web] patching "${mainJs.fn}"');
  int patched = 0;
  mainJs.content = mainJs.content.replaceAllMapped(
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
  mainJs.updateHash();
  print('[patch-web] patched $patched google fonts code lines.');

  // replace all main.dart.js reference to new hashed filename
  final mainjsHash = mainJs.newHash.substring(0, 8);

  indexHtml.content = indexHtml.content.replaceFirst('main.dart.js?v=VERSION', 'main.dart.js?v=$mainjsHash');
  indexHtml.updateHash();

  // remove NOTICE from core cache, which needs to download before app start
  sw.content = sw.content.replaceFirst('"assets/NOTICES",\n', '');

  // update all cache hash
  sw.content = sw.content.replaceAllMapped(RegExp(r'"([^"]+)":\s*"([0-9a-f]{32})"'), (match) {
    final fn = match.group(1)!;
    final oldHash = match.group(2)!;
    if (fn == 'index.html' || fn == '/') {
      print('Updating hash "${fn.padRight(21)}": $oldHash -> ${indexHtml.newHash}');
      assert(oldHash == indexHtml.initHash);
      return '"$fn": "${indexHtml.newHash}"';
    } else if (fn == mainJs.fn) {
      print('Updating hash "${fn.padRight(21)}": $oldHash -> ${mainJs.newHash}');
      assert(oldHash == mainJs.initHash);
      return '"$fn": "${mainJs.newHash}"';
    }
    return match.group(0)!;
  });

  indexHtml.save();
  mainJs.save();
  // jsMap.save();
  sw.save();
}
