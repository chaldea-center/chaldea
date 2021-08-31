import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' show join;
import 'package:pool/pool.dart';

import 'config.dart' show db;
import 'constants.dart';
import 'json_store/json_store.dart';
import 'logger.dart';

class WikiUtil {
  static final CacheManager wikiFileCache = CacheManager(Config('wikiCache'));
  static late final JsonStore<String> wikiUrlCache;

  /// limit request frequency
  static Pool _pool = Pool(10);

  static String mcDomain = 'https://fgo.wiki';
  static String fandomDomain = 'https://fategrandorder.fandom.com';

  WikiUtil._();

  static Future<void> init() async {
    wikiUrlCache = JsonStore<String>(join(db.paths.configDir, 'wikiurl.json'));
  }

  static Future<void> clear() async {
    wikiUrlCache.clear();
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

  static String prefixKey(String filename) => 'wikiurl_$filename';

  /// parsing wiki file downloading url

  ///
  static String? getCachedUrl(String filename) {
    final key = prefixKey(filename);
    return wikiUrlCache.get(key);
  }

  static Map<String, Future<String?>> _resolvingUrlTasks = {};

  /// Don't keep trying resolving everytime. Once error, resolve it after 1 min
  /// key is [filename], value is [DateTime.millisecondsSinceEpoch]
  static Map<String, int> _errorTasks = {};

  /// If [savePath] is provided, the file will be downloaded
  static Future<String?> resolveFileUrl(String filename,
      [String? savePath]) async {
    String key = prefixKey(filename);
    String? url = wikiUrlCache.get(key);
    if (url != null) {
      print('wiki cache: $filename -> $url');
      return url;
    }
    if (_resolvingUrlTasks.containsKey(filename)) {
      return _resolvingUrlTasks[filename]!;
    }
    // don't fetch the same url in a short time
    if (_errorTasks[filename] != null &&
        DateTime.now().millisecondsSinceEpoch - _errorTasks[filename]! <
            60000) {
      return null;
    }
    // resolving
    if (!db.hasNetwork) return null;
    final future = _pool.withResource<String?>(() async {
      // print('resolving $filename');
      final _dio = HttpUtils.defaultDio;
      bool isFandomFile = filename.startsWith('fandom.');
      String api = isFandomFile
          ? 'https://fategrandorder.fandom.com/api.php'
          : 'https://fgo.wiki/api.php';
      Response? response;
      try {
        response = await _dio.get(
          api,
          queryParameters: {
            "action": "query",
            "format": "json",
            "prop": "imageinfo",
            "iiprop": "url",
            "titles":
                "File:" + (isFandomFile ? filename.substring(7) : filename)
          },
          options: Options(responseType: ResponseType.json),
        );
        final info = response.data['query']['pages'].values.first['imageinfo'];
        if (info == null) return null;
        final String? url = info[0]['url'];
        if (url?.isNotEmpty == true) {
          wikiUrlCache.set(key, url!);
          if (savePath != null) {
            /// directly save, don't use [wikiFileCache]
            Response fileResponse = await _dio.get(url,
                options: Options(responseType: ResponseType.bytes));
            if (fileResponse.statusCode == 200) {
              File file = File(savePath);
              await file.writeAsBytes(fileResponse.data, flush: true);
              // logger.i('downloaded $url to $savePath');
            } else {
              throw HttpException('HTTP ${fileResponse.statusCode}',
                  uri: Uri.tryParse(url));
            }
          }
        }
        // print('mc file: $filename -> $url');
        _errorTasks.remove(filename);
        return url;
      } catch (e, s) {
        _errorTasks[filename] = DateTime.now().millisecondsSinceEpoch;
        logger.d(response?.data);
        logger.e('error download $filename', e, s);
      } finally {
        _resolvingUrlTasks.remove(filename);
      }
    });
    _resolvingUrlTasks[filename] = future;
    return future;
  }

  static Future<File?> getWikiFile(String filename) async {
    final url = await resolveFileUrl(filename);
    if (url != null) return wikiFileCache.getSingleFile(url);
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
