import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chaldea/packages/packages.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../packages/network.dart';
import 'constants.dart';

class WikiUtil {
  static final CacheManager wikiFileCache = CacheManager(Config('wikiCache'));

  static String mcDomain = 'https://fgo.wiki';
  static String fandomDomain = 'https://fategrandorder.fandom.com';

  WikiUtil._();

  static Future<void> init() async {
    // wikiUrlCache = JsonStore<String>(join(db.paths.configDir, 'wikiurl.json'));
  }

  static Future<void> clear() async {
    // wikiUrlCache.clear();
    await wikiFileCache.emptyCache();
  }

  static String mcFullLink(String title) {
    String link = '$mcDomain/w/$title';
    return Uri.parse(link).toString();
  }

  static String fandomFullLink(String title) {
    String link = '$fandomDomain/wiki/$title';
    return Uri.parse(link).toString();
  }

  static String filenameToUrl(String filename) {
    if (filename.startsWith(RegExp(r'http(s)?://'))) {
      return filename;
    }
    filename = filename.replaceAll(' ', '_');
    bool isFandom = filename.startsWith('fandom.');
    if (isFandom) filename = filename.substring(7);
    final prefix = isFandom
        ? 'https://static.wikia.nocookie.net/fategrandorder/images'
        : 'https://fgo.wiki/images';
    final hash = md5.convert(utf8.encode(filename)).toString();
    final hash1 = hash.substring(0, 1), hash2 = hash.substring(0, 2);
    final url = '$prefix/$hash1/$hash2/$filename';
    return Uri.parse(url).toString();
  }

  static Future<String?> saveImage(String filename, String savePath) {
    return _downloadImage(filenameToUrl(filename), savePath);
  }

  static final Map<String, Completer<String?>> _downloadTasks = {};

  static final RateLimiter _rateLimiter = RateLimiter();

  static Future<String?> _downloadImage(String url, String savePath) async {
    if (_downloadTasks[url] != null) return _downloadTasks[url]!.future;
    if (kIsWeb || network.unavailable) return null;
    final completer = _downloadTasks[url] = Completer();
    _rateLimiter
        .limited(() async {
          if (await File(savePath).exists()) return;
          // don't use _dio.download and writeSync
          // avoid reading file when write not completed
          Response fileResponse = await HttpUtils.defaultDio
              .get(url, options: Options(responseType: ResponseType.bytes));
          if (fileResponse.statusCode == 200) {
            File file = File(savePath);
            await file.writeAsBytes(fileResponse.data);
            // logger.i('downloaded $url to $savePath');
          }
        })
        .then((v) async => completer.complete(url))
        .catchError((e, s) async => completer.complete(null));
    return completer.future;
  }

  static Future<File?> getWikiFile(String filename) async {
    if (PlatformU.isWeb) return null;
    final url = filenameToUrl(filename);
    return await wikiFileCache.getSingleFile(url);
  }

  /// download wiki code
  static Future<String> pageContent(String title,
      {bool isFandom = false}) async {
    try {
      final _dio = HttpUtils.defaultDio;
      final response = await _dio.get(
        (isFandom ? fandomDomain : mcDomain) + '/api.php',
        queryParameters: {
          "action": "query",
          "format": "json",
          "prop": "revisions",
          "continue": "",
          "titles": title,
          "utf8": 1,
          "rvprop": "content"
        },
        options: Options(responseType: ResponseType.json),
      );
      String content =
          response.data['query']['pages'].values.first['revisions'][0]['*'];
      return content;
    } catch (e, s) {
      logger.e('failed to get wikitext', e, s);
    }
    return '';
  }
}
