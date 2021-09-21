import 'dart:async';
import 'dart:io';

import 'package:chaldea/platform_interface/platform/platform.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' show join;
import 'package:pool/pool.dart';

import 'config.dart' show db;
import 'constants.dart';
import 'json_store/json_store.dart';
import 'logger.dart';
import 'server_api.dart';

class WikiUtil {
  static final CacheManager wikiFileCache = CacheManager(Config('wikiCache'));
  static late final JsonStore<String> wikiUrlCache;

  /// limit request frequency
  static final Pool _pool = Pool(10);
  static final Pool _pool2 = Pool(10);

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

  /// parsing wiki file downloading url

  ///
  static String? getCachedUrl(String filename) {
    // final key = prefixKey(filename);
    return wikiUrlCache.get(filename);
  }

  static final Map<String, Future<String?>> _resolvingUrlTasks = {};

  /// Don't keep trying resolving everytime. Once error, resolve it after 1 min
  /// key is [filename], value is [DateTime.millisecondsSinceEpoch]
  static final Map<String, int> _errorTasks = {};

  /// If [savePath] is provided, the file will be downloaded
  static Future<String?> resolveFileUrl(String filename,
      [String? savePath]) async {
    if (_resolvingUrlTasks.containsKey(filename)) {
      return _resolvingUrlTasks[filename]!;
    }
    // don't fetch the same url in a short time
    if (_errorTasks[filename] != null &&
        DateTime.now().millisecondsSinceEpoch - _errorTasks[filename]! <
            60000) {
      print('error $filename');
      return null;
    }
    Future<String?> _download(String url) async {
      if (savePath == null || PlatformU.isWeb) return url;
      if (!await File(savePath).exists()) {
        return withPool(_pool2, 'download_$filename', () async {
          // don't use _dio.download and writeSync
          // avoid reading file when write not completed
          Response fileResponse = await HttpUtils.defaultDio
              .get(url, options: Options(responseType: ResponseType.bytes));
          if (fileResponse.statusCode == 200) {
            File file = File(savePath);
            file.writeAsBytesSync(fileResponse.data, flush: true);
            // logger.i('downloaded $url to $savePath');
          }
          return url;
        });
      }
    }

    Future<String?> _fullUrl() async {
      String? _trueUrl;
      if (PlatformU.isWeb) {
        final resp = ChaldeaResponse.fromResponse(await db.serverDio
            .get('/web/wikiurl', queryParameters: {'name': filename}));
        print(resp);
        if (resp.success) {
          _trueUrl = resp.body;
        }
      } else {
        final _dio = HttpUtils.defaultDio;
        bool isFandomFile = filename.startsWith('fandom.');
        String api = isFandomFile
            ? 'https://fategrandorder.fandom.com/api.php'
            : 'https://fgo.wiki/api.php';
        Response? response;
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
        _trueUrl = info[0]['url'];
      }
      if (_trueUrl != null) {
        print('wikiurl: $filename\n    ->$_trueUrl');
        wikiUrlCache.set(filename, _trueUrl);
        if (!PlatformU.isWeb) {
          await _download(_trueUrl).catchError((e, s) => Future.value(null));
        }
      }
      return _trueUrl;
    }

    String? url = wikiUrlCache.get(filename);
    if (!db.hasNetwork) return url;
    if (url != null && savePath != null) {
      return _download(url);
    }
    if (url == null) {
      final future = withPool<String?>(_pool, 'resolve_$filename', _fullUrl)
          .whenComplete(() {
        _resolvingUrlTasks.remove(filename);
      });
      _resolvingUrlTasks[filename] = future;
      return future;
    } else {
      return url;
    }
  }

  static Future<File?> getWikiFile(String filename) async {
    if (PlatformU.isWeb) return null;
    final url = await resolveFileUrl(filename);
    if (url != null) {
      return await wikiFileCache.getSingleFile(url);
    }
  }

  static Future<T?> withPool<T>(
      Pool pool, String key, FutureOr<T> Function() func) async {
    if (_errorTasks[key] != null &&
        DateTime.now().millisecondsSinceEpoch - _errorTasks[key]! < 60000) {
      return null;
    }
    return pool.withResource<T?>(() async {
      try {
        final v = await func();
        _errorTasks.remove(key);
        return v;
      } catch (e, s) {
        _errorTasks[key] = DateTime.now().millisecondsSinceEpoch;
        logger.e('withPool: $key', e, s);
      }
    });
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
