import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:github/github.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import '../../models/api/api.dart';
import 'cache.dart';

// ignore: unused_element
bool _defaultValidateStat(int? statusCode) {
  return statusCode != null && statusCode >= 200 && statusCode < 500;
}

class ChaldeaWorkerApi {
  ChaldeaWorkerApi._();

  static const v3Laplace = '/api/v3/laplace';

  static final cacheManager = ApiCacheManager(null)
    ..dispatchError = dispatchError
    ..createDio = createDio;

  static void dispatchError(RequestOptions options, Response? response, dynamic error, dynamic stackTrace) async {
    dynamic error2;
    if (response != null) {
      String? text;
      try {
        if (response.data is List<int>) {
          text = utf8.decode(response.data);
        } else if (response.data is String) {
          text = response.data;
        } else if (response.data is Map) {
          text = jsonEncode(response.data);
        }
      } catch (e) {
        //
      }
      if (text != null) {
        try {
          final resp = WorkerResponse.fromJson(jsonDecode(text));
          error2 = resp.error ?? resp.message ?? resp.body;
        } catch (e) {
          error2 = text;
        }
      }
    }
    error2 ??= error;
    logger.e("api error: ${options.uri}", error2);
    if (EasyLoading.instance.overlayEntry?.mounted != true) return;
    EasyLoading.showError(error2.toString());
  }

  static Dio createDio() {
    // return db.apiWorkerDio..options.baseUrl = 'http://127.0.0.1:8787';
    return db.apiWorkerDio;
  }

  static Options addAuthHeader([Options? options, bool verify = false]) {
    options ??= Options();
    final username = db.security.username ?? "", auth = db.security.userAuth ?? "";
    if (username.isEmpty || auth.isEmpty) {
      if (verify) {
        throw StateError("Not login");
      }
      return options;
    }
    final encoded = base64Encode(utf8.encode("$username:$auth"));
    options.headers = {
      ...?options.headers,
      "Authorization": "Basic $encoded",
    };
    return options;
  }

  static void clearCache(bool Function(ApiCachedInfo cache) test) {
    cacheManager.removeWhere(test);
  }

  // to chaldea server rather worker
  static Future<WorkerResponse> sendFeedback({
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
    return postCommon("${HostsX.apiHost}/feedback", formData);
  }

  static Future<WorkerResponse> postCommon(
    String url,
    dynamic data, {
    Options? options,
    bool addAuth = false,
  }) async {
    final result = await cacheManager.postModel(
      url,
      fromJson: (data) => WorkerResponse.fromJson(data),
      data: data,
      expireAfter: Duration.zero,
      options: addAuth ? addAuthHeader(options) : options,
    );
    return result ?? WorkerResponse(success: false, message: "Error");
  }

  static Future<UserBattleData?> laplaceQueryById(int id, {Duration? expireAfter}) {
    return cacheManager.getModel(
      '$v3Laplace/team/$id',
      (data) => UserBattleData.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<List<UserBattleData>?> teams({
    int? questId,
    int? phase,
    String? enemyHash,
    String? userId,
    int? ver,
    int limit = 20,
    int offset = 0,
    Duration? expireAfter = const Duration(minutes: 60),
  }) {
    if (questId == null && userId == null && ver == null) return Future.value([]);
    final query = _encodeQuery({
      'questId': questId,
      'phase': phase,
      'enemyHash': enemyHash,
      'userId': userId,
      'ver': ver,
      'limit': limit,
      if (offset != 0) 'offset': offset,
    });
    return cacheManager.getModel(
      "$v3Laplace/teams?$query",
      (data) => (data as List).map((e) => UserBattleData.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<UserBattleData>?> teamsByUser({
    String? userId,
    int limit = 20,
    int offset = 0,
    Duration? expireAfter,
  }) {
    userId ??= db.security.username;
    if (userId == null || userId.isEmpty) return Future.value();
    return teams(
      userId: userId,
      limit: limit,
      offset: offset,
      expireAfter: expireAfter,
    );
  }

  static Future<List<UserBattleData>?> teamsByQuest({
    required int questId,
    required int phase,
    required String? enemyHash,
    int limit = 20,
    int offset = 0,
    Duration? expireAfter,
  }) {
    return teams(
      questId: questId,
      phase: phase,
      enemyHash: enemyHash,
      limit: limit,
      offset: offset,
      expireAfter: expireAfter,
    );
  }

  static Future<WorkerResponse> teamDelete({required int id}) {
    return postCommon(
      "$v3Laplace/team/delete",
      {
        'id': id,
      },
      options: addAuthHeader(),
    );
  }

  static Future<WorkerResponse> teamUpload({
    required int ver,
    required int questId,
    required int phase,
    required String enemyHash,
    required List<int> svts,
    required String record,
  }) {
    return postCommon(
      "$v3Laplace/team/upload",
      {
        'ver': ver,
        'questId': questId,
        'phase': phase,
        'enemyHash': enemyHash,
        'svts': svts,
        'record': record,
      },
      options: addAuthHeader(),
    );
  }

  // debug/dev
  @visibleForTesting
  static Future<WorkerResponse> teamUpdate({
    required int id,
    required int ver,
    required int questId,
    required int phase,
    required String enemyHash,
    required List<int> svts,
    required String record,
  }) {
    return postCommon(
      "$v3Laplace/team/update",
      {
        'id': id,
        'ver': ver,
        'questId': questId,
        'phase': phase,
        'enemyHash': enemyHash,
        'svts': svts,
        'record': record,
      },
      options: addAuthHeader(),
    );
  }

  static GitHub get githubApiClient => GitHub(endpoint: '${HostsX.worker.cn}/proxy/github/api.github.com');

  static Future<Release?> githubRelease(
    String owner,
    String repo, {
    required String? tag, // null->latest release
    Duration? expireAfter,
  }) {
    // GitHub(endpoint: '${HostsX.worker.cn}/proxy/github/api.github.com')
    //     .repositories
    //     .getLatestRelease(RepositorySlug('chaldea-center', 'chaldea'));
    return cacheManager.getModel(
      '${HostsX.worker.cn}/proxy/github/api.github.com/repos/$owner/$repo/releases/${tag == null ? "latest" : "tags/$tag"}',
      (data) => Release.fromJson(data),
      expireAfter: expireAfter,
    );
  }
}

class CachedApi {
  const CachedApi._();
  // silent
  static final ApiCacheManager cacheManager = ApiCacheManager(null);

  static Future<RemoteConfig?> remoteConfig({Duration? expireAfter}) {
    return cacheManager.getModel(
      '${HostsX.dataHost}/config.json',
      (data) => db.runtimeData.remoteConfig = RemoteConfig.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<Map?> biliVideoInfo({int? aid, String? bvid, Duration? expireAfter}) async {
    if (aid == null && bvid == null) return null;
    String url = 'https://api.bilibili.com/x/web-interface/view?';
    if (aid != null) {
      url += 'aid=$aid';
    } else if (bvid != null) {
      url += 'bvid=$bvid';
    }
    return cacheManager.getModel(
      kIsWeb ? HostsX.corsProxy(url) : url,
      (data) => Map.from(data),
      expireAfter: expireAfter,
    );
  }
}

String _encodeQuery(Map<String, dynamic> parameters) {
  final list = <String>[];
  for (final key in parameters.keys) {
    final value = parameters[key];
    if (value == null || (value is List && value.isEmpty)) continue;

    if (value is List) {
      for (final v in value) {
        if (v != null) {
          list.add('$key=${Uri.encodeQueryComponent(v.toString())}');
        }
      }
    } else {
      list.add('$key=${Uri.encodeQueryComponent(value.toString())}');
    }
  }
  return list.join('&');
}
