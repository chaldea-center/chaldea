import 'dart:convert';

import 'package:crypto/crypto.dart';

class WikiTool {
  static String mcDomain = 'https://fgo.wiki';
  static String fandomDomain = 'https://fategrandorder.fandom.com';

  static String mcFullLink(String title) {
    return Uri.parse('$mcDomain/w/$title').toString();
  }

  static String mcFileUrl(String filename) => _fileUrl(filename, 'https://fgo.wiki/images');

  static String fandomFullLink(String title) {
    return Uri.parse('$fandomDomain/wiki/$title').toString();
  }

  static String fandomFileUrl(String filename) =>
      _fileUrl(filename, 'https://static.wikia.nocookie.net/fategrandorder/images');

  static String _fileUrl(String filename, String prefix) {
    if (filename.startsWith(RegExp(r'http(s)?://'))) {
      return filename;
    }
    filename = filename.replaceAll(' ', '_');
    bool isFandom = filename.startsWith('fandom.');
    if (isFandom) filename = filename.substring(7);
    final hash = md5.convert(utf8.encode(filename)).toString();
    final hash1 = hash.substring(0, 1), hash2 = hash.substring(0, 2);
    final url = '$prefix/$hash1/$hash2/$filename';
    return Uri.parse(url).toString();
  }
}
