import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:github/github.dart';

import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import '../../models/api/api.dart';
import 'cache.dart';

// ignore: unused_element
bool _defaultValidateStat(int? statusCode) {
  return statusCode != null && statusCode >= 200 && statusCode < 500;
}

class ChaldeaWorkerApi {
  ChaldeaWorkerApi._();

  static const v3Laplace = '/api/v3/laplace';
  static const apiV4 = '/api/v4/';

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
    if (EasyLoading.instance.overlayEntry?.mounted != true) return;
    String msg = error2.toString();
    if (response?.statusCode == 500 && msg.contains('D1_ERROR: Error 9000: something went wrong')) {
      msg += Language.isZH ? '\n目前服务器不稳定，请稍后重试s' : '\nThe server is currently unstable, please try again later';
    }
    EasyLoading.showError(msg);
  }

  static Dio createDio() {
    // return db.apiWorkerDio..options.baseUrl = 'http://127.0.0.1:8787';
    return db.apiWorkerDio;
  }

  static Options addAuthHeader([Options? options, bool verify = false]) {
    options ??= Options();
    final secret = db.settings.secrets.user?.secret ?? "";
    if (secret.isEmpty) {
      if (verify) {
        throw StateError("Not login");
      }
      return options;
    }
    options.headers = {
      ...?options.headers,
      "Authorization": "Basic $secret",
    };
    return options;
  }

  static void clearCache(bool Function(ApiCachedInfo cache) test) {
    cacheManager.removeWhere(test);
  }

  // to chaldea server rather worker
  static Future<WorkerResponse?> sendFeedback({
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

  static Future<WorkerResponse?> postCommon(
    String url,
    dynamic data, {
    Options? options,
    bool addAuth = false,
  }) {
    return cacheManager.postModel(
      url,
      fromJson: (data) => WorkerResponse.fromJson(data),
      data: data,
      expireAfter: Duration.zero,
      options: addAuth ? addAuthHeader(options) : options,
    );
  }

  /// users part
  static Future<ChaldeaUser?> login({
    required String username,
    required String password,
  }) {
    return cacheManager.postModel(
      '$apiV4/user/login',
      fromJson: (data) => ChaldeaUser.fromJson(data),
      data: {
        'username': username,
        'password': password,
      },
    );
  }

  static Future<ChaldeaUser?> signup({
    required String username,
    required String password,
  }) {
    return cacheManager.postModel(
      '$apiV4/user/signup',
      fromJson: (data) => ChaldeaUser.fromJson(data),
      data: {
        'username': username,
        'password': password,
      },
    );
  }

  static Future<ChaldeaUser?> changePassword({
    required String username,
    required String password,
    required String newPassword,
  }) {
    return cacheManager.postModel(
      '$apiV4/user/change-password',
      fromJson: (data) => ChaldeaUser.fromJson(data),
      data: {
        'username': username,
        'password': password,
        'new_password': newPassword,
      },
    );
  }

  static Future<ChaldeaUser?> renameUser({
    required String username,
    required String password,
    required String newUsername,
  }) {
    return cacheManager.postModel(
      '$apiV4/user/change-password',
      fromJson: (data) => ChaldeaUser.fromJson(data),
      data: {
        'username': username,
        'password': password,
        'new_username': newUsername,
      },
    );
  }

  static Future<WorkerResponse?> deleteUser({
    required String username,
    required String password,
  }) {
    return cacheManager.postModel(
      '$apiV4/user/delete',
      fromJson: (data) => WorkerResponse.fromJson(data),
      data: {
        'username': username,
        'password': password,
      },
    );
  }

  static Future<WorkerResponse?> logout() {
    return cacheManager.postModel(
      '$apiV4/user/logout',
      fromJson: (data) => WorkerResponse.fromJson(data),
      options: addAuthHeader(),
    );
  }

  static Future<List<UserBackupData>?> listBackup() {
    return cacheManager.getModel(
      '$apiV4/user/backup/list',
      (data) => (data as List).map((e) => UserBackupData.fromJson(Map.from(e))).toList(),
      expireAfter: Duration.zero,
      options: addAuthHeader(),
    );
  }

  static Future<WorkerResponse?> uploadBackup({required String content}) {
    AppInfo.deviceParams;
    return cacheManager.postModel(
      '$apiV4/user/backup/new',
      fromJson: (data) => WorkerResponse.fromJson(data),
      options: addAuthHeader(),
      data: <String, String>{
        'content': content,
        'appVer': AppInfo.versionString,
        'os': <String?>[
          PlatformU.operatingSystem,
          if (kIsWeb) ...[
            AppInfo.deviceParams['browserName'],
            AppInfo.deviceParams['platform'],
          ],
          if (!kIsWeb) PlatformU.operatingSystemVersion,
        ].where((e) => e != null && e.isNotEmpty).join(' ').substring2(0, 60).trim(),
      },
    );
  }

  // teams

  static Future<UserBattleData?> team(int id, {Duration? expireAfter}) {
    return cacheManager.getModel(
      '$apiV4/team/$id',
      (data) => UserBattleData.fromJson(data),
      expireAfter: expireAfter,
      options: addAuthHeader(),
    );
  }

  static Future<TeamQueryResult?> teams({
    int? questId,
    int? phase,
    String? enemyHash,
    int? userId,
    int? ver,
    int limit = 20,
    int offset = 0,
    Duration? expireAfter = const Duration(minutes: 60),
  }) {
    if (questId == null && userId == null && ver == null) return Future.value();
    final query = _encodeQuery({
      'questId': questId,
      'phase': phase,
      'enemyHash': enemyHash,
      'userId': userId,
      'ver': ver,
      'limit': limit,
      if (offset > 0) 'offset': offset,
    });
    return cacheManager.getModel(
      "$apiV4/team/search?$query",
      (data) => TeamQueryResult.fromJson(data),
      expireAfter: expireAfter,
      options: addAuthHeader(),
    );
  }

  static Future<TeamQueryResult?> teamsByUser({
    int? userId,
    int limit = 20,
    int offset = 0,
    Duration? expireAfter,
  }) {
    userId ??= db.settings.secrets.user?.id;
    if (userId == null || userId == 0) return Future.value();
    return teams(
      userId: userId,
      limit: limit,
      offset: offset,
      expireAfter: expireAfter,
    );
  }

  static Future<TeamQueryResult?> teamsByQuest({
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

  static Future<WorkerResponse?> teamDelete({required int id}) {
    return cacheManager.deleteModel(
      '$apiV4/team/$id',
      fromJson: (data) => WorkerResponse.fromJson(data),
      options: addAuthHeader(),
    );
  }

  static Future<int?> teamUpload({
    required int ver,
    required int questId,
    required int phase,
    required String enemyHash,
    required List<int> svts,
    required String record,
  }) {
    return cacheManager.postModel(
      '$apiV4/team/new',
      fromJson: (data) => (data as Map)['id'] as int,
      options: addAuthHeader(),
      data: {
        'ver': ver,
        'questId': questId,
        'phase': phase,
        'enemyHash': enemyHash,
        'svts': svts,
        'record': record,
      },
    );
  }

  static Future<TeamVoteData?> teamVote({
    required int teamId,
    required int voteValue,
  }) {
    return cacheManager.postModel(
      '$apiV4/team/$teamId/vote',
      fromJson: (data) => TeamVoteData.fromJson(data),
      options: addAuthHeader(),
      data: {
        'value': voteValue,
      },
    );
  }

  // debug/dev
  @visibleForTesting
  static Future<WorkerResponse?> teamUpdate({required UserBattleData team}) {
    return cacheManager.putModel(
      '$apiV4/team/${team.id}',
      fromJson: (data) => WorkerResponse.fromJson(data),
      options: addAuthHeader(),
      data: {
        "id": team.id,
        "ver": team.ver,
        "userId": team.userId,
        "questId": team.questId,
        "phase": team.phase,
        "enemyHash": team.enemyHash,
        "createdAt": team.createdAt,
        "record": team.record,
      },
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
