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
      bootstrapJs = _FileInfo('flutter_bootstrap.js'),
      sw = _FileInfo('flutter_service_worker.js');
  // jsMap = _FileInfo('main.dart.js.map');

  // change google fonts url for cn
  print('[patch-web] patching "${mainJs.fn}"');
  int patched = 0;
  // mainJs.content = mainJs.content.replaceAllMapped(
  //   RegExp(r'"https://fonts\.googleapis\.com|"https://fonts\.gstatic\.com'),
  //   (m) {
  //     final host = m.group(0)!;
  //     if (host == '"https://fonts.googleapis.com') {
  //       patched++;
  //       return '(window.isCNHost?"https://fonts.font.im":"https://fonts.googleapis.com")+"';
  //     } else if (host == '"https://fonts.gstatic.com') {
  //       patched++;
  //       return '(window.isCNHost?"https://fonts.gstatic.font.im":"https://fonts.gstatic.com")+"';
  //     } else {
  //       throw 'unknown host: <$host>';
  //     }
  //   },
  // );
  mainJs.updateHash();
  print('[patch-web] patched $patched google fonts code lines.');

  // replace all main.dart.js reference to new hashed filename
  bootstrapJs.content = bootstrapJs.content.replaceAll('MAIN_DART_JS_VERSION', mainJs.newHash.substring(0, 8));
  bootstrapJs.updateHash();

  indexHtml.content = indexHtml.content.replaceAll('BOOTSTRAP_VERSION', bootstrapJs.newHash.substring(0, 8));
  indexHtml.updateHash();

  // remove NOTICE from core cache, which needs to download before app start
  sw.content = sw.content.replaceFirst('"assets/NOTICES",\n', '');

  // update all cache hash
  final filesNeedUpdateHash = <String, _FileInfo>{
    "/": indexHtml,
    for (final f in [indexHtml, mainJs, bootstrapJs]) f.fn: f,
  };
  sw.content = sw.content.replaceAllMapped(RegExp(r'"([^"]+)":\s*"([0-9a-f]{32})"'), (match) {
    final fn = match.group(1)!;
    final oldHash = match.group(2)!;

    final fileinfo = filesNeedUpdateHash[fn];
    if (fileinfo != null) {
      if (oldHash == fileinfo.newHash) {
        print('"${fn.padRight(21)}": updating hash $oldHash -> unchanged');
      } else {
        print('"${fn.padRight(21)}": updating hash $oldHash -> ${fileinfo.newHash}');
        return '"$fn": "${fileinfo.newHash}"';
      }
      assert(oldHash == fileinfo.initHash);
    }

    return match.group(0)!;
  });

  indexHtml.save();
  bootstrapJs.save();
  mainJs.save();
  // jsMap.save();
  sw.save();
}
