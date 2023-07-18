import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/packages/logger.dart';
import '../../models/api/api.dart';
import '../../models/db.dart';
import 'cache.dart';
import 'hosts.dart';

// ignore: unused_element
bool _defaultValidateStat(int? statusCode) {
  return statusCode != null && statusCode >= 200 && statusCode < 500;
}

class ChaldeaWorkerApi {
  ChaldeaWorkerApi._();

  static final cacheManager = ApiCacheManager(null)
    ..dispatchError = dispatchError
    ..createDio = createDio;

  static void dispatchError(RequestOptions options, Response? response, dynamic error, dynamic stackTrace) async {
    dynamic error2;
    if (response != null) {
      String? text;
      try {
        text = utf8.decode(response.data);
      } catch (e) {
        //
      }
      if (text != null) {
        try {
          final resp = WorkerResponse.fromJson(jsonDecode(text));
          error2 = resp.message ?? resp.body;
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
    return db.apiWorkerDio;
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
    return postCommon("${Hosts.apiHost}/feedback", formData);
  }

  static Future<WorkerResponse> postCommon(String url, dynamic data) async {
    final result = await cacheManager.postModel(
      url,
      (data) => WorkerResponse.fromJson(data),
      data: data,
      expireAfter: Duration.zero,
    );
    return result ?? WorkerResponse(success: false, message: "Unknown Error");
  }

  static Future<UserBattleData?> laplaceQueryById(
    int id, {
    Duration expireAfter = const Duration(minutes: 60),
  }) {
    return cacheManager.getModel(
      '/laplace/v2/query/id?id=$id',
      (data) => UserBattleData.fromJson(data),
      expireAfter: expireAfter,
    );
  }

  static Future<List<UserBattleData>?> laplaceQueryTeamByUser({
    String? username,
    String? auth,
    int limit = 20,
    int offset = 0,
    Duration? expireAfter = const Duration(minutes: 60),
  }) {
    username ??= db.security.username;
    auth ??= db.security.userAuth;
    return cacheManager.postModel(
      "/laplace/v2/query/user",
      data: {
        'username': username,
        'auth': auth,
        'limit': limit,
        'offset': offset,
      },
      (data) => (data as List).map((e) => UserBattleData.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<List<UserBattleData>?> laplaceQueryTeamByQuest({
    required int questId,
    required int phase,
    required String? enemyHash,
    int limit = 20,
    int offset = 0,
    Duration? expireAfter = const Duration(minutes: 60),
  }) {
    return cacheManager.postModel(
      "/laplace/v2/query/quest",
      data: {
        'questId': questId,
        'phase': phase,
        if (enemyHash != null) 'enemyHash': enemyHash,
        'limit': limit,
        'offset': offset,
      },
      (data) => (data as List).map((e) => UserBattleData.fromJson(e)).toList(),
      expireAfter: expireAfter,
    );
  }

  static Future<WorkerResponse> laplaceDeleteTeam({required int id}) {
    final username = db.security.username;
    final auth = db.security.userAuth;
    return postCommon(
      "/laplace/v2/delete",
      {
        'username': username,
        'auth': auth,
        'id': id,
      },
    );
  }

  static Future<WorkerResponse> laplaceUploadTeam({
    required int ver,
    required int questId,
    required int phase,
    required String enemyHash,
    required String record,
  }) {
    final username = db.security.username;
    return postCommon(
      "/laplace/v2/upload",
      {
        'username': username,
        'auth': db.security.userAuth,
        'ver': 1,
        'questId': questId,
        'phase': phase,
        'enemyHash': enemyHash,
        'record': record,
      },
    );
  }
}
