import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/auth/login_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/language.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import '../../models/api/api.dart';
import 'api_error_codes.dart';
import 'cache.dart';

// ChaldeaServerApi talks to the new chaldea-server-v2 FastAPI backend (/api/v1).
// It replaces the legacy ChaldeaWorkerApi for user/team/backup flows.
class ChaldeaServerApi {
  ChaldeaServerApi._();

  static const apiV1 = '/api/v1';

  static final cacheManager = ApiCacheManager(null)
    ..dispatchError = dispatchError
    ..createDio = createDio;

  // ===================== 401 / session state =====================
  //
  // Single-flight dialog: the first 401 shows the session-expired dialog;
  // concurrent 401s are suppressed. Prevents N stacked dialogs when N
  // requests fail simultaneously.
  static bool _sessionDialogShown = false;

  // The new server returns errors as {"detail": {"message": ..., "message_zh": ...}}
  // (FastAPI HTTPException). For 401s, it also includes `error_code`
  // (token_expired | token_revoked | invalid_credentials). We extract the
  // code and route 401s to _handle401 instead of showing a toast.
  static void dispatchError(RequestOptions options, Response? response, dynamic error, dynamic stackTrace) async {
    String? errorCode;
    String? errorMessage;
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
          final decoded = jsonDecode(text);
          if (decoded is Map && decoded.containsKey('detail')) {
            final detail = decoded['detail'];
            if (detail is Map) {
              errorCode = detail['error_code'] is String ? detail['error_code'] as String : null;
              errorMessage = Language.isZH
                  ? (detail['message_zh'] ?? detail['message'])
                  : (detail['message'] ?? detail['message_zh']);
            } else {
              errorMessage = detail?.toString();
            }
          } else {
            errorMessage = text;
          }
        } catch (e) {
          errorMessage = text;
        }
      }
    }

    // 401s are handled by the session/re-login pipeline — no toast.
    if (response?.statusCode == 401) {
      await _handle401(errorCode);
      return;
    }

    errorMessage ??= error?.toString();
    if (EasyLoading.instance.overlayEntry?.mounted != true) return;
    EasyLoading.showError(errorMessage.toString());
  }

  static Dio createDio() {
    return DioE(
      BaseOptions(
        baseUrl: kDebugMode && 1 > 2 ? 'http://localhost:8000' : HostsX.apiHost,
        headers: {
          'x-chaldea-ver': AppInfo.versionString,
          'x-chaldea-build': AppInfo.buildNumber,
          'x-chaldea-uuid': AppInfo.uuid,
          'x-chaldea-lang': Language.current.code,
          'x-chaldea-platform': PlatformU.operatingSystem,
        },
      ),
    );
  }

  static bool hasToken() => (db.settings.secrets.user.accessToken ?? "").isNotEmpty;

  static Options addAuthHeader({Options? options}) {
    options ??= Options();
    final token = db.settings.secrets.user.accessToken ?? '';
    if (token.isEmpty) return options;
    options.headers = {...?options.headers, 'Authorization': 'Bearer $token'};
    return options;
  }

  static void clearCache(bool Function(ApiCachedInfo cache) test) {
    cacheManager.removeWhere(test);
  }

  static void clearTeamCache() {
    cacheManager.removeWhere((info) => info.url.contains('/teams/'));
  }

  // ===================== Auth =====================

  static Future<LoginResponse?> login({required String username, required String password}) {
    return cacheManager.postModel(
      '$apiV1/auth/login',
      fromJson: (data) => LoginResponse.fromJson(data),
      data: {'username': username, 'password': password},
      expireAfter: Duration.zero,
    );
  }

  // Returns true on 202 success, null on failure.
  static Future<bool?> register({required String username, required String email, required String password}) {
    return cacheManager.postModel(
      '$apiV1/auth/register',
      fromJson: (_) => true,
      data: {'username': username, 'email': email, 'password': password},
      expireAfter: Duration.zero,
    );
  }

  static Future<LoginResponse?> verifyRegister({
    required String username,
    required String email,
    required String password,
    required String code,
  }) {
    return cacheManager.postModel(
      '$apiV1/auth/verify-register',
      fromJson: (data) => LoginResponse.fromJson(data),
      data: {'username': username, 'email': email, 'password': password, 'code': code},
      expireAfter: Duration.zero,
    );
  }

  static Future<bool?> logout({bool allDevices = false}) {
    return cacheManager.postModel(
      '$apiV1/auth/logout?all_devices=$allDevices',
      fromJson: (_) => true,
      options: addAuthHeader(),
      expireAfter: Duration.zero,
    );
  }

  static Future<LoginResponse?> refreshToken() {
    return cacheManager.postModel(
      '$apiV1/auth/refresh',
      fromJson: (data) => LoginResponse.fromJson(data),
      options: addAuthHeader(),
      expireAfter: Duration.zero,
    );
  }

  static Future<bool?> forgotPassword({required String email}) {
    return cacheManager.postModel(
      '$apiV1/auth/forgot-password',
      fromJson: (_) => true,
      data: {'email': email},
      expireAfter: Duration.zero,
    );
  }

  static Future<bool?> resetPassword({required String email, required String code, required String newPassword}) {
    return cacheManager.postModel(
      '$apiV1/auth/reset-password',
      fromJson: (_) => true,
      data: {'email': email, 'code': code, 'new_password': newPassword},
      expireAfter: Duration.zero,
    );
  }

  static Future<bool?> resetPasswordByDevice({
    required String username,
    required String code,
    required String newEmail,
    required String newPassword,
  }) {
    return cacheManager.postModel(
      '$apiV1/auth/reset-password-by-device',
      fromJson: (_) => true,
      data: {'username': username, 'code': code, 'new_email': newEmail, 'new_password': newPassword},
      expireAfter: Duration.zero,
    );
  }

  // Migrate a legacy Worker session_id (secret) into a JWT. Idempotent, no auth header.
  static Future<LoginResponse?> migrateToken({required String secret}) {
    return cacheManager.postModel(
      '$apiV1/auth/migrate-token',
      fromJson: (data) => LoginResponse.fromJson(data),
      data: {'secret': secret},
      expireAfter: Duration.zero,
    );
  }

  // Public device-based recovery for migrated users without a bound email.
  // Sends a reset+bind_email link to `newEmail` if the username+device match.
  // Anti-enumeration: the server returns the same 200 success body regardless
  // of whether the username/device matched. Only 429 (lockout) or 422
  // (invalid device_id format) indicate a definitive failure. No auth header.
  static Future<bool?> recoverByDevice({required String username, required String deviceId, required String newEmail}) {
    return cacheManager.postModel(
      '$apiV1/auth/recover-by-device',
      fromJson: (_) => true,
      data: {'username': username, 'device_id': deviceId, 'new_email': newEmail},
      expireAfter: Duration.zero,
    );
  }

  // Step 1 of email binding: send verification code to new email.
  static Future<bool?> changeEmail({required String newEmail}) {
    return cacheManager.postModel(
      '$apiV1/users/me/change-email',
      fromJson: (_) => true,
      data: {'new_email': newEmail},
      options: addAuthHeader(),
      expireAfter: Duration.zero,
    );
  }

  // Step 2 of email binding: verify code and update email.
  static Future<bool?> verifyEmail({required String newEmail, required String code}) {
    return cacheManager.postModel(
      '$apiV1/users/me/verify-email',
      fromJson: (_) => true,
      data: {'new_email': newEmail, 'code': code},
      options: addAuthHeader(),
      expireAfter: Duration.zero,
    );
  }

  // ===================== Users =====================

  static Future<UserInfo?> getMe() {
    if (!hasToken()) return Future.value(null);
    return cacheManager.getModel(
      '$apiV1/users/me',
      (data) => UserInfo.fromJson(data),
      expireAfter: Duration.zero,
      options: addAuthHeader(),
    );
  }

  // The server response for PATCH /users/me returns the updated profile
  // without access_token. Callers should use updateFromUserInfo to preserve
  // the existing token.
  static Future<UserInfo?> updateMe({String? name}) async {
    return cacheManager.patchModel(
      '$apiV1/users/me',
      fromJson: (data) => UserInfo.fromJson(data),
      data: {'name': ?name},
      options: addAuthHeader(),
      expireAfter: Duration.zero,
    );
  }

  // The server returns a FRESH access_token after a password change.
  static Future<LoginResponse?> changePassword({required String currentPassword, required String newPassword}) {
    return cacheManager.patchModel(
      '$apiV1/users/me/password',
      fromJson: (data) => LoginResponse.fromJson(data),
      data: {'current_password': currentPassword, 'new_password': newPassword},
      options: addAuthHeader(),
      expireAfter: Duration.zero,
    );
  }

  static Future<bool?> deleteMe({required String password}) {
    return cacheManager.deleteModel(
      '$apiV1/users/me',
      fromJson: (_) => true,
      data: {'password': password},
      options: addAuthHeader(),
      expireAfter: Duration.zero,
    );
  }

  static Future<List<UserBackupData>?> listBackups() {
    return cacheManager.getModel(
      '$apiV1/users/me/backups',
      (data) => (data as List).map((e) => UserBackupData.fromJson(Map.from(e))).toList(),
      expireAfter: Duration.zero,
      options: addAuthHeader(),
    );
  }

  static Future<UserBackupData?> uploadBackup({required String content}) {
    AppInfo.deviceParams;
    return cacheManager.postModel(
      '$apiV1/users/me/backups',
      fromJson: (data) => UserBackupData.fromJson(Map.from(data)),
      options: addAuthHeader(),
      data: <String, String>{
        'content': content,
        'app_ver': AppInfo.versionString,
        'os': <String?>[
          PlatformU.operatingSystem,
          if (kIsWeb) ...[AppInfo.deviceParams['browserName'], AppInfo.deviceParams['platform']],
          if (!kIsWeb) PlatformU.operatingSystemVersion,
        ].where((e) => e != null && e.isNotEmpty).join(' ').substring2(0, 60).trim(),
      },
      expireAfter: Duration.zero,
    );
  }

  // Fetch a single backup by id (LOW-tier auth). Used for download flows.
  // 404 if the backup does not belong to the caller or does not exist.
  static Future<UserBackupData?> getBackup(int backupId) {
    return cacheManager.getModel(
      '$apiV1/users/me/backups/$backupId',
      (data) => UserBackupData.fromJson(Map.from(data)),
      expireAfter: Duration.zero,
      options: addAuthHeader(),
    );
  }

  // ===================== Admin =====================

  // Look up a user id by exact name via the admin search endpoint.
  // Returns null if no exact match is found.
  static Future<int?> adminGetUserIdByName(String name) async {
    final result = await cacheManager.getModel<Map?>(
      '$apiV1/admin/users?search=${Uri.encodeQueryComponent(name)}&limit=50',
      (data) => Map.from(data),
      expireAfter: Duration.zero,
      options: addAuthHeader(),
    );
    if (result == null) return null;
    final list = result['data'];
    if (list is! List) return null;
    for (final u in list) {
      if (u is Map && u['name'] == name) {
        return (u['id'] as num?)?.toInt();
      }
    }
    return null;
  }

  static Future<bool?> adminResetPassword({required int userId, required String password}) {
    return cacheManager.patchModel(
      '$apiV1/admin/users/$userId',
      fromJson: (_) => true,
      data: {'password': password},
      options: addAuthHeader(),
      expireAfter: Duration.zero,
    );
  }

  // Search users via the admin paginated list endpoint. `search` matches name
  // or email (server-defined); null returns all users paginated.
  static Future<AdminUsersList?> adminSearchUsers({
    String? search,
    int limit = 20,
    int offset = 0,
    Duration? expireAfter,
  }) {
    final query = _encodeQuery({'search': search, 'limit': limit, if (offset > 0) 'offset': offset});
    final url = query.isEmpty ? '$apiV1/admin/users' : '$apiV1/admin/users?$query';
    return cacheManager.getModel(
      url,
      (data) => AdminUsersList.fromJson(data),
      expireAfter: expireAfter,
      options: addAuthHeader(),
    );
  }

  // Full detail for a single user: embedded user, active sessions, recent
  // logins, and backups/teams counts.
  static Future<AdminUserDetail?> adminGetUserDetail(int userId) {
    return cacheManager.getModel(
      '$apiV1/admin/users/$userId',
      (data) => AdminUserDetail.fromJson(data),
      expireAfter: Duration.zero,
      options: addAuthHeader(),
    );
  }

  // Admin-initiated recovery. Email mode wins when both are provided; password
  // mode directly resets and revokes sessions. Returns null without a request
  // when neither is provided (caller-side guard).
  static Future<AdminRecoverResponse?> adminRecoverUser({required int userId, String? email, String? password}) {
    if (email == null && password == null) return Future.value();
    return cacheManager.postModel(
      '$apiV1/admin/users/$userId/recover',
      fromJson: (data) => AdminRecoverResponse.fromJson(Map.from(data)),
      data: <String, dynamic>{'email': ?email, 'password': ?password},
      options: addAuthHeader(),
      expireAfter: Duration.zero,
    );
  }

  // ===================== Teams =====================

  static Future<UserBattleData?> team(int id, {Duration? expireAfter}) {
    return cacheManager.getModel(
      '$apiV1/teams/$id',
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
    String? username,
    int? ver,
    List<int> teamIds = const [],
    int limit = 200,
    int offset = 0,
    Duration? expireAfter = const Duration(hours: 2),
  }) {
    if (questId == null && userId == null && ver == null && username == null && teamIds.isEmpty) {
      return Future.value();
    }
    final query = _encodeQuery({
      'questId': questId,
      'phase': phase,
      'enemyHash': enemyHash,
      'userId': userId,
      'username': username,
      'ids': teamIds.toList()..sort(),
      'ver': ver,
      'limit': limit,
      if (offset > 0) 'offset': offset,
    });
    return cacheManager.getModel(
      "$apiV1/teams/?$query",
      (data) => TeamQueryResult.fromJson(data),
      expireAfter: expireAfter,
      options: addAuthHeader(),
    );
  }

  static Future<TeamQueryResult?> teamsByUser({
    int? userId,
    String? username,
    int limit = 200,
    int offset = 0,
    Duration? expireAfter,
  }) {
    if (username == null) userId ??= db.settings.secrets.user.id;
    if ((userId == null || userId == 0) && (username == null || username.isEmpty)) return Future.value();
    return teams(userId: userId, username: username, limit: limit, offset: offset, expireAfter: expireAfter);
  }

  static Future<TeamQueryResult?> teamsByQuest({
    required int questId,
    required int phase,
    required String? enemyHash,
    int limit = 200,
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

  static Future<TeamQueryResult?> teamsByVote({
    required int userId,
    required bool isUpVote,
    int limit = 200,
    int offset = 0,
    Duration? expireAfter,
  }) {
    final query = _encodeQuery({
      'userId': userId,
      'value': isUpVote ? 1 : -1,
      'limit': limit,
      if (offset > 0) 'offset': offset,
    });
    return cacheManager.getModel(
      "$apiV1/teams/voted?$query",
      (data) => TeamQueryResult.fromJson(data),
      expireAfter: expireAfter,
      options: addAuthHeader(),
    );
  }

  static Future<TeamQueryResult?> teamsRanking({
    int limit = 200,
    int offset = 0,
    Duration? expireAfter = const Duration(hours: 2),
  }) {
    final query = _encodeQuery({'limit': limit, if (offset > 0) 'offset': offset});
    return cacheManager.getModel(
      "$apiV1/teams/ranking?$query",
      (data) => TeamQueryResult.fromJson(data),
      expireAfter: expireAfter,
      options: addAuthHeader(),
    );
  }

  // Returns the new team id, or null on failure.
  static Future<int?> teamUpload({required BattleShareData data}) {
    return cacheManager.postModel(
      '$apiV1/teams/',
      fromJson: (data) => (data as Map)['id'] as int,
      options: addAuthHeader(),
      data: {
        'ver': BattleShareData.kDataVer,
        'app_ver': AppInfo.versionString,
        'quest_id': data.quest?.id,
        'phase': data.quest?.phase,
        'enemy_hash': data.quest?.enemyHash,
        'content': data.toDataV2(),
      },
      expireAfter: Duration.zero,
    );
  }

  static Future<bool?> teamUpdate({required UserBattleData team}) {
    return cacheManager.putModel(
      '$apiV1/teams/${team.id}',
      fromJson: (_) => true,
      options: addAuthHeader(),
      data: {
        'ver': team.ver,
        'app_ver': team.appVer,
        'quest_id': team.questId,
        'phase': team.phase,
        'enemy_hash': team.enemyHash,
        'content': team.content,
      },
      expireAfter: Duration.zero,
    );
  }

  static Future<bool?> teamDelete({required int id}) {
    return cacheManager.deleteModel(
      '$apiV1/teams/$id',
      fromJson: (_) => true,
      options: addAuthHeader(),
      expireAfter: Duration.zero,
    );
  }

  static Future<TeamVoteData?> teamVote({required int teamId, required int voteValue}) {
    return cacheManager.postModel(
      '$apiV1/teams/$teamId/vote',
      fromJson: (data) => TeamVoteData.fromJson(data),
      options: addAuthHeader(),
      data: {'value': voteValue},
      expireAfter: Duration.zero,
    );
  }

  // ===================== Legacy token migration =====================

  // At startup, if the user still has a legacy Worker secret but no JWT, exchange
  // the secret for a JWT. On 401 (invalid/expired secret), the local secret is
  // cleared to prevent infinite retry. Other failures are silent.
  //
  // Returns the migrated ChaldeaUser (with accessToken set) on success, or null
  // on any failure. The caller may inspect the returned user's `email` field to
  // decide whether to prompt for email binding.
  static Future<ChaldeaUser?> maybeMigrateLegacyToken() async {
    final user = db.settings.secrets.user;
    if (user.accessToken?.isNotEmpty == true) return null;
    final secret = user.secret;
    if (secret == null || secret.isEmpty) return null;

    int? statusCode;
    final migrated = await cacheManager.postModel(
      '$apiV1/auth/migrate-token',
      fromJson: (data) => LoginResponse.fromJson(data),
      data: {'secret': secret},
      expireAfter: Duration.zero,
      onError: (options, response, error, stackTrace) {
        // Swallow error silently — migration is best-effort.
        // Capture status code for 401 handling below.
        statusCode = response?.statusCode;
      },
    );

    if (migrated == null) {
      // 401 means the legacy secret is invalid/expired — clear it to stop retry loops.
      // Other failures (network, 5xx) keep the secret for a future retry.
      if (statusCode == 401) {
        user.secret = null;
        await db.saveSettings();
      }
      return null;
    }

    // Migration succeeded — persist the JWT and user info from the response.
    user.updateFromLoginResponse(migrated);
    await db.saveSettings();

    // Fetch the full profile (including email) for the caller.
    final me = await getMe();
    if (me != null) {
      user.updateFromUserInfo(me);
      await db.saveSettings();
    }
    return user;
  }

  // ===================== 401 / session pipeline =====================

  /// Clears the access token (preserving the user object for UI display)
  /// and navigates to the login page. Does NOT null out `secrets.user` —
  /// the login page can pre-fill the username and any "logged in as X"
  /// UI can still show the name.
  ///
  /// Uses `router.push()` (not `popDetailAndPush`) so the user's current
  /// navigation context (detail pages, in-progress forms) is preserved.
  /// After re-login the user returns to where they were.
  static Future<void> _forceRelogin({String? reason}) async {
    final user = db.settings.secrets.user;
    user.accessToken = null;
    await db.saveSettings();
    if (kDebugMode && reason != null) {
      debugPrint('ChaldeaServerApi._forceRelogin: $reason');
    }
    if (rootRouter.navigatorKey.currentContext != null) {
      router.push(child: LoginPage());
    }
  }

  /// Shows a single-flight session-expired dialog guiding the user to the
  /// login page. Concurrent 401s are suppressed by `_sessionDialogShown`.
  static void _showSessionExpiredDialog() {
    if (_sessionDialogShown) return;
    _sessionDialogShown = true;

    final context = rootRouter.navigatorKey.currentContext;
    if (context == null) {
      _forceRelogin();
      _sessionDialogShown = false;
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(S.current.auth_session_expired_title),
        content: Text(S.current.auth_session_expired_message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _sessionDialogShown = false;
              _forceRelogin();
            },
            child: Text(S.current.login_login),
          ),
        ],
      ),
    );
  }

  /// Branches on the server's `error_code` for 401 responses.
  ///
  /// - `invalid_credentials`: toast only (user is on the login form).
  /// - `token_expired` / `token_revoked` / `token_missing` / unknown:
  ///   session-expired dialog + redirect to login.
  static Future<void> _handle401(String? errorCode) async {
    switch (errorCode) {
      case ApiErrorCode.invalidCredentials:
        EasyLoading.showError(S.current.auth_invalid_credentials);
        return;
      case ApiErrorCode.tokenExpired:
      case ApiErrorCode.tokenRevoked:
      case ApiErrorCode.tokenMissing:
      default:
        _showSessionExpiredDialog();
    }
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
