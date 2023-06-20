import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../models/db.dart';
import '../../packages/logger.dart';

// ignore: unused_element
bool _defaultValidateStat(int? statusCode) {
  return statusCode != null && statusCode >= 200 && statusCode < 500;
}

class ChaldeaResponse {
  final Response? response;

  final dynamic error;

  ChaldeaResponse(this.response) : error = null;

  ChaldeaResponse.error(this.error) : response = null;

  int? get statusCode => response?.statusCode;

  Map? _cachedJson;

  Map? json() {
    if (_cachedJson != null) return _cachedJson;
    if (response?.data == null) return null;
    if (response!.data is Map) {
      return _cachedJson = response!.data;
    }
    try {
      var plain = response!.data is List<int> ? utf8.decode(response!.data) : response!.data;
      return _cachedJson = jsonDecode(plain);
    } catch (e) {
      return null;
    }
  }

  bool get success => error == null && json()?['success'] == true;

  String? get message => error?.toString() ?? json()?['message'];

  T? body<T>() {
    var _body = json()?['body'];
    if (_body is T) return _body;
    return null;
  }

  static Future<ChaldeaResponse> show(
    Future<ChaldeaResponse> future, {
    bool showError = true,
    bool showSuccess = false,
  }) async {
    EasyLoading.show();
    ChaldeaResponse result;
    try {
      result = await future;
    } catch (e, s) {
      logger.e('api failed', e, s);
      result = ChaldeaResponse.error(e);
    }
    EasyLoading.dismiss();
    if (result.success) {
      if (showSuccess) {
        await SimpleCancelOkDialog(
          title: Text(S.current.success),
          content: result.message == null ? null : Text(result.message!),
          scrollable: true,
        ).showDialog(null);
      }
    } else {
      if (showError) {
        await SimpleCancelOkDialog(
          title: Text(S.current.error),
          content: Text(result.message ?? result.body().toString()),
          scrollable: true,
        ).showDialog(null);
      }
    }
    return result;
  }

  @Deprecated('use ChaldeaResponse.show')
  static Future<ChaldeaResponse?> request({
    required Future<Response> Function(Dio dio) caller,
    void Function(ChaldeaResponse)? onSuccess,
    bool showSuccess = false,
  }) async {
    try {
      EasyLoading.show(maskType: EasyLoadingMaskType.clear);
      // print('apiWorkerDio: ${db.apiWorkerDio.options.baseUrl}');
      final resp = ChaldeaResponse(await caller(db.apiWorkerDio));
      EasyLoading.dismiss();
      if (resp.success) {
        onSuccess?.call(resp);
        if (showSuccess) {
          await SimpleCancelOkDialog(
            title: Text(S.current.success),
            content: resp.message == null ? null : Text(resp.message!),
            scrollable: true,
          ).showDialog(null);
        }
      } else {
        await SimpleCancelOkDialog(
          title: Text(S.current.failed),
          content: Text(resp.message ?? resp.body()),
          scrollable: true,
        ).showDialog(null);
      }
      return resp;
    } catch (e) {
      EasyLoading.dismiss();
      await SimpleCancelOkDialog(
        title: Text(S.current.failed),
        content: Text(escapeDioException(e)),
        scrollable: false,
      ).showDialog(null);
      return null;
    }
  }
}

class ChaldeaApi {
  ChaldeaApi._();

  static Future<ChaldeaResponse> wrap(Future<Response> Function() callback) async {
    try {
      return ChaldeaResponse(await callback());
    } catch (e, s) {
      logger.e('api failed', e, s);
      return ChaldeaResponse.error(e);
    }
  }

  static Future<ChaldeaResponse> sendFeedback({
    String? subject,
    String? senderName,
    String? html,
    String? text,
    // <filename, bytes>
    Map<String, Uint8List> files = const {},
  }) {
    var formData = FormData.fromMap({
      if (html != null) 'html': html,
      if (text != null) 'text': text,
      if (subject != null) 'subject': subject,
      if (senderName != null) 'sender': senderName,
      'files': [
        for (final file in files.entries) MultipartFile.fromBytes(file.value, filename: file.key),
      ]
    });
    return wrap(() => db.apiServerDio.post('/feedback', data: formData));
  }

  static Future<ChaldeaResponse> laplaceQueryTeamByUser({
    String? username,
    String? auth,
    int limit = 20,
    int offset = 0,
    Duration? expireAfter,
  }) {
    username ??= db.security.username;
    auth ??= db.security.userAuth;
    return _toResponse(cacheManager.request(
      "POST /laplace/quest/user/$username?limit=$limit&offset=$offset",
      () => createDio().post('/laplace/query/user', data: {
        'username': username,
        'auth': auth,
        'limit': limit,
        'offset': offset,
      }),
      expireAfter: expireAfter,
    ));
  }

  static Future<ChaldeaResponse> laplaceQueryTeamByQuest({
    required int questId,
    required int phase,
    required String? enemyHash,
    int limit = 20,
    int offset = 0,
    Duration? expireAfter,
  }) {
    return _toResponse(cacheManager.request(
      "POST /laplace/quest/quest/$questId/$phase/$enemyHash?limit=$limit&offset=$offset",
      () => createDio().post('/laplace/query/quest', data: {
        'questId': questId,
        'phase': phase,
        if (enemyHash != null) 'enemyHash': enemyHash,
        'limit': limit,
        'offset': offset,
      }),
      expireAfter: expireAfter,
    ));
  }

  static Future<ChaldeaResponse> laplaceDeleteTeam({
    required int id,
  }) {
    final username = db.security.username;
    final auth = db.security.userAuth;
    return _toResponse(createDio().post('/laplace/delete', data: {
      'username': username,
      'auth': auth,
      'id': id,
    }));
  }

  static Future<ChaldeaResponse> laplaceUploadTeam({
    required int ver,
    required int questId,
    required int phase,
    required String enemyHash,
    required String record,
  }) {
    final username = db.security.username;
    return _toResponse(createDio().post('/laplace/upload', data: {
      'username': username,
      'auth': db.security.userAuth,
      'ver': 1,
      'questId': questId,
      'phase': phase,
      'enemyHash': enemyHash,
      'record': record,
    }));
  }

  static Future<ChaldeaResponse> _toResponse(Future<Response?> rawResp) async {
    try {
      final resp = await rawResp;
      if (resp == null) return ChaldeaResponse.error("something went wrong");
      return ChaldeaResponse(resp);
    } catch (e, s) {
      logger.e('chaldea api error', e, s);
      return ChaldeaResponse.error(e);
    }
  }

  static Dio createDio() {
    return db.apiWorkerDio;
  }

  static final cacheManager = _MemoryCache<String, Response>();

  static void clearCache(bool Function(_CacheInfo<String, Response> cache) test) {
    cacheManager._caches.removeWhere((key, value) => test(value));
  }
}

class _MemoryCache<K, V> {
  final Map<K, _CacheInfo<K, V>> _caches = {};
  final Duration failExpire;
  _MemoryCache({this.failExpire = const Duration(seconds: 5)});

  Future<V?> request(K key, Future<V> Function() caller, {Duration? expireAfter}) async {
    final cache = _caches[key];
    if (cache != null) {
      if (cache.completer.isCompleted) {
        if (cache.failed) {
          if (DateTime.now().difference(cache.created) < failExpire) {
            return cache.data;
          }
        } else {
          if (expireAfter == Duration.zero) {
            // no cache
          } else if (expireAfter == null) {
            return cache.data;
          } else if (DateTime.now().difference(cache.created) < expireAfter) {
            return cache.data;
          }
        }
      } else {
        return cache.completer.future;
      }
    }
    final completer = Completer<V>();
    final cache2 = _caches[key] = _CacheInfo(key: key, completer: completer);
    try {
      final result = await caller();
      cache2.data = result;
      completer.complete(result);
    } catch (e, s) {
      cache2.failed = true;
      FlutterError.dumpErrorToConsole(FlutterErrorDetails(exception: e, stack: s));
      completer.completeError(e, s);
    }
    return completer.future;
  }
}

class _CacheInfo<K, V> {
  K key;
  Completer<V> completer;
  V? data;
  DateTime created;
  bool failed;

  _CacheInfo({
    required this.key,
    required this.completer,
    this.data,
    DateTime? created,
    this.failed = false,
  }) : created = created ?? DateTime.now();
}
