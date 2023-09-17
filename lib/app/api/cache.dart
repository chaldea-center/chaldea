import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:crclib/catalog.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import 'package:chaldea/packages/file_plus/file_plus.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/packages/rate_limiter.dart';
import 'package:chaldea/utils/hive_extention.dart';
import 'package:chaldea/utils/utils.dart';
import '../../models/models.dart';

const kExpireCacheOnly = Duration(days: -999);
typedef DispatchErrorCallback = void Function(
    RequestOptions options, Response? response, dynamic error, dynamic stackTrace);

extension _RequestOptionsX on RequestOptions {
  static String getHashKey(String method, String url, dynamic data) {
    final key = <String>[method, url, if (data != null) data.toString()].join(" ");
    return md5.convert(utf8.encode(key)).toString();
  }

  String hashKey() {
    return getHashKey(method, uri.toString(), data);
  }
}

class ApiCachedInfo {
  String key;
  String method;
  String url;
  int statusCode;
  String crc;
  int timestamp; // in seconds
  String? fp;

  ApiCachedInfo({
    required this.key,
    required this.method,
    required this.url,
    required this.statusCode,
    required this.crc,
    required this.timestamp,
    required this.fp,
  });

  factory ApiCachedInfo.fromJson(Map<String, dynamic> data) {
    return ApiCachedInfo(
      key: data['key'] as String,
      method: data['method'] as String,
      url: data['url'] as String,
      statusCode: data['statusCode'] as int,
      crc: data['crc'] as String,
      timestamp: data['timestamp'] as int,
      fp: data['fp'] as String,
    );
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'method': method,
        'url': url,
        'statusCode': statusCode,
        'crc': crc,
        'timestamp': timestamp,
        'fp': fp,
      };
}

class _DownloadingTask {
  String key;
  Completer<List<int>?> completer;
  DateTime startedAt;
  bool canceled;

  _DownloadingTask({
    required this.key,
    required this.completer,
    DateTime? startedAt,
  })  : startedAt = startedAt ?? DateTime.now(),
        canceled = false;

  void cancel() {
    canceled = true;
    completer.complete(null);
  }
}

class ApiCacheManager {
  bool _initiated = false;
  final String? cacheKey;
  final List<int> statusCodes = const [200];
  final Map<String, ApiCachedInfo> _data = {}; // key=hash
  final Map<String, List<int>> _memoryCache = {}; // key=hash
  final Map<String, _DownloadingTask> _downloading = {}; // key=hash
  final Map<String, DateTime> _failed = {}; // key=hash

  DispatchErrorCallback? dispatchError;
  static void _kDispatchError(RequestOptions options, Response? response, dynamic error, dynamic stackTrace) {
    return;
  }

  LazyBox<Uint8List>? _webBox;
  late final FilePlus? _infoFile = cacheKey == null
      ? null
      : FilePlus(kIsWeb ? 'api_cache/$cacheKey.json' : joinPaths(db.paths.tempDir, 'api_cache/$cacheKey.json'));

  ApiCacheManager(this.cacheKey);

  Dio Function() createDio = () => DioE();

  Completer? _initCompleter;

  void clearFailed() {
    _failed.clear();
  }

  Future<void> clearCache() async {
    _memoryCache.clear();
    _data.clear();
    _downloading.clear();
    _failed.clear();
    await _saveCacheInfo();
  }

  Future<void> init() async {
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer();
    try {
      _data.clear();
      if (kIsWeb) {
        _webBox = await Hive.openLazyBoxRetry('api_cache');
      }
      if (_infoFile != null && _infoFile!.existsSync()) {
        Map.from(jsonDecode(await _infoFile!.readAsString())).forEach((key, value) {
          _data[key] = ApiCachedInfo.fromJson(value);
        });
      }
    } catch (e, s) {
      logger.e('init api cache manager ($cacheKey)', e, s);
    } finally {
      _initCompleter!.complete();
    }
  }

  void saveCacheInfo() {
    EasyDebounce.debounce('_CacheManager_saveCacheInfo', const Duration(seconds: 10), _saveCacheInfo);
  }

  Future<void> _saveCacheInfo() async {
    final file = _infoFile;
    if (file == null) return;
    try {
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode(_data));
    } catch (e, s) {
      logger.e('Save Api Cache info failed', e, s);
    }
  }

  void _clearKey(String key) {
    _data.remove(key);
    _memoryCache.remove(key);
    _downloading.remove(key);
    _failed.remove(key);
  }

  Future<void> removeUrl2(String url, {HttpRequestMethod? method}) async {
    removeWhere((info) => info.url == url && (method == null || method.methodName == info.method));
  }

  void removeWhere(bool Function(ApiCachedInfo info) test) {
    _data.removeWhere((key, info) {
      final remove = test(info);
      if (remove) {
        _memoryCache.remove(info.key);
        _downloading.remove(info.key);
        _failed.remove(info.key);
      }
      return remove;
    });
  }

  final RateLimiter rateLimiter = RateLimiter();

  FilePlus? _getCacheFile(String key) {
    if (cacheKey == null) return null;
    return FilePlus(
      kIsWeb ? '$cacheKey/$key' : joinPaths(db.paths.tempDir, '$cacheKey/$key'),
      box: _webBox,
    );
  }

  Future<void> _saveEntry(String key, RequestOptions requestOptions, Response<List<int>> response) async {
    final bytes = response.data!;
    final file = _getCacheFile(key);

    final crc = Crc32Xz().convert(bytes).toString();
    _memoryCache[key] = bytes;

    await file?.create(recursive: true);
    await file?.writeAsBytes(bytes);
    final fp = _getCacheFile(key)?.path;
    if (!kReleaseMode && fp != null) print('caching api to $fp');
    _data[key] = ApiCachedInfo(
      key: key,
      method: requestOptions.method,
      url: requestOptions.uri.toString(),
      statusCode: response.statusCode!,
      crc: crc,
      timestamp: DateTime.now().timestamp,
      fp: fp,
    );
    saveCacheInfo();
  }

  /// [expireAfter]
  ///   * null: (default) use memory cache if possible
  ///   * 0: always fetch new
  ///   * >-: expiration in seconds
  bool _isExpired(RequestOptions options, int timestamp, Duration? expireAfter) {
    final key = options.hashKey();
    if (expireAfter == Duration.zero) {
      return true;
    }
    if (expireAfter == null) {
      if ((options.method == "GET" || options.method == "HEAD") && _memoryCache[key] != null) {
        return false;
      }
      return true;
    }
    return (DateTime.now().timestamp - timestamp) >= expireAfter.inSeconds;
  }

  bool isDownloading(String url, {HttpRequestMethod method = HttpRequestMethod.get, dynamic data}) {
    return _downloading.containsKey(_RequestOptionsX.getHashKey(method.methodName, url, data));
  }

  bool isFailed(String url, {HttpRequestMethod method = HttpRequestMethod.get, dynamic data}) {
    return _failed.containsKey(_RequestOptionsX.getHashKey(method.methodName, url, data));
  }

  Future<List<int>?> _fetch<T>(RequestOptions requestOptions, DispatchErrorCallback? onError) async {
    requestOptions.responseType = ResponseType.bytes;
    final uri = requestOptions.uri;
    final key = requestOptions.hashKey();
    if (!kReleaseMode) print('fetching API: ${requestOptions.method} $uri');
    final _t = StopwatchX(uri.toString());
    final response = await createDio().fetch<List<int>>(requestOptions);
    _t.log();
    if (statusCodes.contains(response.statusCode) && response.data != null) {
      try {
        await _saveEntry(key, requestOptions, response);
      } catch (e, s) {
        logger.e('save cache entry failed', e, s);
      }
      return response.data;
    } else {
      dynamic error = Exception("Invalid status code ${response.statusCode} or empty body");
      onError?.call(requestOptions, response, error, StackTrace.current);
      print('fetch api [${requestOptions.uri}] failed: $error');
    }
    return null;
  }

  // fetch
  Future<List<int>?> fetch(RequestOptions options,
      {Duration? expireAfter, bool cacheOnly = false, DispatchErrorCallback? onError}) async {
    onError ??= dispatchError;
    final key = options.hashKey();
    try {
      if (!_initiated) {
        await init();
        _initiated = true;
      }
      final entry = _data[key];
      if (entry != null) {
        bool fileExist = false;
        FilePlus? file = entry.fp == null ? null : FilePlus(entry.fp!, box: _webBox);
        if (!_isExpired(options, entry.timestamp, expireAfter) || expireAfter == kExpireCacheOnly) {
          List<int>? bytes = _memoryCache[key];
          if (bytes == null) {
            if (file != null) {
              fileExist = file.existsSync();
              if (fileExist) {
                bytes = await file.readAsBytes();
              }
            }
          }
          if (bytes != null && Crc32Xz().convert(bytes).toString() == entry.crc) {
            return SynchronousFuture(bytes);
          }
        }

        _data.remove(key);
        if (fileExist) {
          // may also exist even if it is false when file not checked
          await file?.deleteSafe();
        }
      }
      var prevTask = _downloading[key];
      if (prevTask != null) {
        if (DateTime.now().difference(prevTask.startedAt) < const Duration(seconds: 30)) {
          return prevTask.completer.future;
        }
        print('api cancel timeout: $key');
        _downloading.remove(key);
        prevTask.cancel();
      }

      if (cacheOnly || expireAfter == kExpireCacheOnly) return null;

      final task = _downloading[key] = _DownloadingTask(key: key, completer: Completer());
      _failed.remove(key);
      unawaited(rateLimiter.limited<List<int>?>(() => _fetch(options, onError)).then((value) {
        _downloading.remove(key);
        _failed.remove(key);
        if (!task.completer.isCompleted) task.completer.complete(value);
        return Future.value();
      }).catchError((e, s) {
        _downloading.remove(key);
        if (!task.canceled) _failed[key] = DateTime.now();
        if (!task.completer.isCompleted) task.completer.completeError(e, s);
        // if (kDebugMode) print(escapeDioException(e));
        return Future.value();
      }));
      return await task.completer.future;
    } catch (e, s) {
      _data.remove(key);
      _downloading.remove(key);
      _memoryCache.remove(key);
      logger.e('api fetch failed', e, s);
      onError?.call(options, e is DioException ? e.response : null, e, s);
    }
    return null;
  }

  Future<String?> fetchText(RequestOptions options,
      {Duration? expireAfter, bool cacheOnly = false, DispatchErrorCallback? onError}) async {
    onError ??= dispatchError;
    try {
      final data = await fetch(options, expireAfter: expireAfter, cacheOnly: cacheOnly, onError: onError);
      if (data == null) return null;
      return utf8.decode(data);
    } catch (e, s) {
      logger.e('fetch text failed ${options.uri}', e, s);
      _clearKey(options.hashKey());
      onError?.call(options, null, e, s);
      return null;
    }
  }

  Future<dynamic> fetchJson(RequestOptions options,
      {Duration? expireAfter, bool cacheOnly = false, DispatchErrorCallback? onError}) async {
    onError ??= dispatchError;
    dynamic result;
    try {
      result = await fetch(options, expireAfter: expireAfter, cacheOnly: cacheOnly, onError: onError);
      if (result != null) {
        String text = utf8.decode(result);
        text = kReplaceDWChars(text);
        if (options.uri.path.contains('/CN/')) {
          String cnText = text;
          db.gameData.mappingData.cnReplace.forEach((key, value) {
            cnText = cnText.replaceAll(key, value);
          });
          try {
            return jsonDecode(cnText);
          } catch (e) {
            //
          }
        }
        return jsonDecode(text);
      }
    } catch (e, s) {
      logger.e('fetch json failed ${options.uri}', e, s);
      _clearKey(options.hashKey());
      onError?.call(options, null, e, s);
      return result;
    }
  }

  Future<T?> fetchModelRaw<T>(RequestOptions options, T Function(String data) fromText,
      {Duration? expireAfter, bool cacheOnly = false, DispatchErrorCallback? onError}) async {
    onError ??= dispatchError;

    try {
      final text = await fetchText(options, expireAfter: expireAfter, cacheOnly: true, onError: _kDispatchError);
      if (text != null) return fromText(text);
    } catch (e, s) {
      _clearKey(options.hashKey());
      logger.e('load model($T) failed', e, s);
      cacheOnly = false;
    }
    if (cacheOnly) return null;
    try {
      final obj = await fetchText(options, expireAfter: Duration.zero, cacheOnly: cacheOnly, onError: onError);
      if (obj != null) return fromText(obj);
    } catch (e, s) {
      _clearKey(options.hashKey());
      logger.e('load model($T) failed', e, s);
      onError?.call(options, null, e, s);
    }
    return null;
  }

  Future<T?> fetchModel<T>(RequestOptions options, T Function(dynamic data) fromJson,
      {Duration? expireAfter, bool cacheOnly = false, DispatchErrorCallback? onError}) async {
    onError ??= dispatchError;
    dynamic obj;
    try {
      obj = await fetchJson(options, expireAfter: expireAfter, cacheOnly: true, onError: _kDispatchError);
      if (obj != null) return fromJson(obj);
    } catch (e, s) {
      _clearKey(options.hashKey());
      logger.e('load model($T) failed', e, s);
      print(obj);
      cacheOnly = false;
    }
    if (cacheOnly) return null;
    obj = null;
    try {
      obj = await fetchJson(options, expireAfter: Duration.zero, cacheOnly: cacheOnly, onError: onError);
      if (obj != null) return fromJson(obj);
    } catch (e, s) {
      _clearKey(options.hashKey());
      logger.e('load model($T) failed', e, s);
      print(obj.toString().substring2(0, 1000));
      onError?.call(options, null, e, s);
    }
    return null;
  }

  // GET
  Future<List<int>?> get(String url, {Duration? expireAfter, bool cacheOnly = false}) {
    return fetch(createDio().createRequest(HttpRequestMethod.get, url), expireAfter: expireAfter, cacheOnly: cacheOnly);
  }

  Future<String?> getText(String url, {Duration? expireAfter, bool cacheOnly = false}) {
    return fetchText(createDio().createRequest(HttpRequestMethod.get, url),
        expireAfter: expireAfter, cacheOnly: cacheOnly);
  }

  Future<dynamic> getJson(String url, {Duration? expireAfter, bool cacheOnly = false}) {
    return fetchJson(createDio().createRequest(HttpRequestMethod.get, url),
        expireAfter: expireAfter, cacheOnly: cacheOnly);
  }

  Future<T?> getModelRaw<T>(String url, T Function(String data) fromText,
      {Duration? expireAfter, bool cacheOnly = false}) async {
    return fetchModelRaw(createDio().createRequest(HttpRequestMethod.get, url), fromText,
        expireAfter: expireAfter, cacheOnly: cacheOnly);
  }

  Future<T?> getModel<T>(String url, T Function(dynamic data) fromJson,
      {Duration? expireAfter, bool cacheOnly = false}) {
    return fetchModel(createDio().createRequest(HttpRequestMethod.get, url), fromJson,
        expireAfter: expireAfter, cacheOnly: cacheOnly);
  }

  Future<T?> postModel<T>(
    String url, {
    required T Function(dynamic data) fromJson,
    Duration? expireAfter,
    bool cacheOnly = false,
    // dio
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return fetchModel(
      createDio()
          .createRequest(HttpRequestMethod.post, url, data: data, queryParameters: queryParameters, options: options),
      fromJson,
      expireAfter: expireAfter,
      cacheOnly: cacheOnly,
    );
  }
}
