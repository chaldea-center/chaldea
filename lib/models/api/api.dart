import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:archive/archive.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/utils/url.dart';
import 'package:chaldea/widgets/custom_dialogs.dart';
import '../../packages/logger.dart';
import '../userdata/_helper.dart';
import '../userdata/battle.dart';
import '../userdata/userdata.dart';

part '../../generated/models/api/api.g.dart';

@JsonSerializable()
class WorkerResponse {
  int? status;
  dynamic error;

  String? message;
  dynamic body;

  WorkerResponse({this.status, this.error, this.message, this.body});

  factory WorkerResponse.fromJson(Map<dynamic, dynamic> json) => _$WorkerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WorkerResponseToJson(this);

  bool get hasError => error != null;

  String get fullMessage {
    String msg = <String>[
      ?message,
      if (error != null) error.toString(),
      if (message == null && body != null) body.toString(),
    ].join('\n');
    return msg.isEmpty ? 'No message' : msg;
  }

  Future<void> showDialog([BuildContext? context]) {
    return SimpleConfirmDialog(
      title: Text(error != null ? S.current.error : S.current.success),
      content: Text(fullMessage),
      scrollable: true,
      showCancel: false,
    ).showDialog(context);
  }

  Future<void> showToast() {
    final msg = fullMessage;
    if (hasError) {
      return EasyLoading.showError(msg);
    } else {
      return EasyLoading.showSuccess(message ?? S.current.success);
    }
  }
}

// users

abstract class ChaldeaUserRole {
  static const int member = 1;
  static const int team = 2;
  static const int teamMod = 8;
  static const int admin = 16;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserInfo {
  final int id;
  final String name;
  final String? email;
  final int role;
  final int? createdAt;

  UserInfo({required this.id, required this.name, this.email, this.role = ChaldeaUserRole.member, this.createdAt});

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LoginResponse {
  final String accessToken;
  final String tokenType;
  final UserInfo userInfo;

  LoginResponse({required this.accessToken, this.tokenType = 'bearer', required this.userInfo});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ChaldeaUser {
  UserInfo? info;
  String? accessToken;
  String? secret; // legacy Worker session_id, kept for migration detection only

  ChaldeaUser({this.info, this.accessToken, this.secret});

  // ---- Update methods (mutate internal state, never reassign secrets.user) ----

  /// Update from a LoginResponse-shaped API response.
  void updateFromLoginResponse(LoginResponse resp) {
    accessToken = resp.accessToken;
    info = resp.userInfo;
  }

  /// Update from a UserInfo-shaped API response (getMe/updateMe/admin).
  /// accessToken and secret are preserved.
  void updateFromUserInfo(UserInfo newInfo) {
    info = newInfo;
  }

  /// Clear auth state on logout / account deletion.
  /// secret is kept for legacy migration detection.
  void clearAuth() {
    info = null;
    accessToken = null;
  }

  // ---- Backward-compatible getters (delegate to info) ----

  int get id => info?.id ?? 0;
  String get name => info?.name ?? '';
  String? get email => info?.email;
  int get role => info?.role ?? ChaldeaUserRole.member;
  int? get createdAt => info?.createdAt;
  bool get isAdmin => role == ChaldeaUserRole.admin;
  bool get isTeamMod => isAdmin || role == ChaldeaUserRole.teamMod;

  // ---- JSON serialization with backward compat ----

  factory ChaldeaUser.fromJson(Map<String, dynamic> json) {
    // Preprocess legacy flat format into nested format, then delegate to generated parser.
    // New nested format: { info: {...}, access_token, secret }
    // Legacy flat format: { id, name, role, email, access_token, secret, created_at }
    final normalized = json.containsKey('info')
        ? json
        : <String, dynamic>{
            ...json,
            'info': {
              'id': json['id'],
              'name': json['name'],
              'email': json['email'],
              'role': json['role'],
              'created_at': json['created_at'],
            },
          };
    return _$ChaldeaUserFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$ChaldeaUserToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserBackupData {
  final int id;
  final int userId;
  final String? appVer; // length<=16
  final String? os; // length<=64
  final int createdAt;
  final String content; // base64

  @JsonKey(includeFromJson: false, includeToJson: false)
  final UserData? decoded;

  UserBackupData({
    required this.id,
    required this.userId,
    this.appVer,
    this.os,
    required this.createdAt,
    required this.content,
  }) : decoded = decode(content);

  static String encode(UserData userData) {
    return base64Encode(GZipEncoder().encode(utf8.encode(jsonEncode(userData))));
  }

  static UserData? decode(String content) {
    try {
      return UserData.fromJson(jsonDecode(utf8.decode(GZipDecoder().decodeBytes(base64Decode(content)))));
    } catch (e, s) {
      logger.e('decode user backup failed', e, s);
      return null;
    }
  }

  factory UserBackupData.fromJson(Map<String, dynamic> json) => _$UserBackupDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserBackupDataToJson(this);
}

@JsonSerializable()
class TeamVoteData {
  int up;
  int down;
  int mine;

  TeamVoteData({this.up = 0, this.down = 0, this.mine = 0});

  TeamVoteData copy() {
    return TeamVoteData(up: up, down: down, mine: mine);
  }

  void updateMyVote(bool isUpVote) {
    if (isUpVote) {
      if (mine == 0) {
        up += 1;
        mine = 1;
      } else if (mine == 1) {
        up -= 1;
        mine = 0;
      } else if (mine == -1) {
        up += 1;
        down -= 1;
        mine = 1;
      }
    } else {
      if (mine == 0) {
        down += 1;
        mine = -1;
      } else if (mine == 1) {
        up -= 1;
        down += 1;
        mine = -1;
      } else if (mine == -1) {
        down -= 1;
        mine = 0;
      }
    }
  }

  factory TeamVoteData.fromJson(Map<String, dynamic> json) => _$TeamVoteDataFromJson(json);

  Map<String, dynamic> toJson() => _$TeamVoteDataToJson(this);
}

// teams
@JsonSerializable(fieldRename: FieldRename.snake)
class UserBattleData {
  int id;
  int ver;
  String? appVer;
  int userId;
  int questId;
  int phase;
  String enemyHash;
  int createdAt;
  @JsonKey(name: 'data')
  String content;
  // stats
  String? username;
  @JsonKey(readValue: _readVotes)
  TeamVoteData votes;
  @JsonKey(includeFromJson: false, includeToJson: false)
  TeamVoteData? tempVotes;

  UserBattleData({
    required this.id,
    required this.ver,
    required this.appVer,
    required this.userId,
    required this.questId,
    required this.phase,
    required this.enemyHash,
    required this.createdAt,
    required this.content,
    this.username,
    TeamVoteData? votes,
  }) : votes = votes ?? TeamVoteData();

  factory UserBattleData.fromJson(Map<String, dynamic> json) => _$UserBattleDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserBattleDataToJson(this);

  /// Read votes from either nested `votes: {...}` (legacy) or flat `up`/`down`/`mine`.
  /// The new server returns flat fields; the nested format is kept as a safety net.
  static Object? _readVotes(Map json, String key) {
    final v = json['votes'];
    if (v != null) {
      return TeamVoteData.fromJson(Map<String, dynamic>.from(v as Map));
    }
    return <String, dynamic>{'up': json['up'], 'down': json['down'], 'mine': json['mine']};
  }

  BattleShareData? parse() {
    if (decoded != null) return decoded;
    try {
      if (ver == 1 || ver == 2) {
        return decoded = BattleShareData.parse(content);
      }
    } catch (e, s) {
      logger.e('parse gzip team data failed', e, s);
      return null;
    }
    print('parse failed');
    return null;
  }

  BattleQuestInfo get questInfo {
    return BattleQuestInfo(id: questId, phase: phase, enemyHash: enemyHash);
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  BattleShareData? decoded;

  Uri toShortUri() {
    Uri shareUri = Uri.parse(ChaldeaUrl.deepLink('/laplace/share'));
    shareUri = shareUri.replace(
      queryParameters: <String, String>{
        "id": id.toString(),
        // "questId": questId.toString(),
        // "phase": phase.toString(),
        // "enemyHash": enemyHash,
      },
    );
    return shareUri;
  }

  Uri toUriV2() {
    final detail = parse();
    String? data = detail?.toDataV2();
    Uri shareUri = Uri.parse(ChaldeaUrl.deepLink('/laplace/share'));
    shareUri = shareUri.replace(
      queryParameters: <String, String>{
        "data": ?data,
        "questId": (detail?.quest?.id ?? questId).toString(),
        "phase": (detail?.quest?.phase ?? phase).toString(),
        "enemyHash": detail?.quest?.enemyHash ?? enemyHash,
      },
    );
    return shareUri;
  }
}

class PaginatedData<T> {
  final int offset;
  final int limit;
  final int? total;
  final List<T> data;

  PaginatedData({this.offset = 0, this.limit = 0, this.total, required this.data});

  bool get hasNextPage {
    if (total != null) {
      return offset + data.length < total!;
    }
    if (limit > 0) {
      return data.length >= limit;
    }
    return data.isNotEmpty;
  }
}

@JsonSerializable()
class TeamQueryResult extends PaginatedData<UserBattleData> {
  TeamQueryResult({super.offset = 0, super.limit = 0, super.total, required super.data});

  factory TeamQueryResult.fromJson(Map<String, dynamic> json) => _$TeamQueryResultFromJson(json);

  Map<String, dynamic> toJson() => _$TeamQueryResultToJson(this);
}

@JsonSerializable()
class AAFileManifest {
  String fileName;
  int size;
  // int uploadTimestamp;
  // String contentType;
  // String contentSHA1;
  // String contentMD5;

  AAFileManifest({
    required this.fileName,
    required this.size,
    // required this.uploadTimestamp,
    // required this.contentType,
    // required this.contentSHA1,
    // required this.contentMD5,
  });

  factory AAFileManifest.fromJson(Map<String, dynamic> json) => _$AAFileManifestFromJson(json);

  Map<String, dynamic> toJson() => _$AAFileManifestToJson(this);

  String resolveUrl(String base) => Uri.parse(base).resolve(fileName).toString();
}

// admin

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminUserListItem {
  final int id;
  final String name;
  final String? email;
  final int role;
  final int createdAt;

  AdminUserListItem({
    required this.id,
    required this.name,
    this.email,
    required this.role,
    required this.createdAt,
  });

  factory AdminUserListItem.fromJson(Map<String, dynamic> json) => _$AdminUserListItemFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserListItemToJson(this);
}

@JsonSerializable()
class AdminUsersList extends PaginatedData<AdminUserListItem> {
  AdminUsersList({super.offset = 0, super.limit = 0, super.total, required super.data});

  factory AdminUsersList.fromJson(Map<String, dynamic> json) => _$AdminUsersListFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUsersListToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminUserSession {
  final String device;
  final String sessionId;

  AdminUserSession({required this.device, required this.sessionId});

  factory AdminUserSession.fromJson(Map<String, dynamic> json) => _$AdminUserSessionFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserSessionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminUserLogin {
  final String device;
  final int createdAt;
  final int updatedAt;

  AdminUserLogin({required this.device, required this.createdAt, required this.updatedAt});

  factory AdminUserLogin.fromJson(Map<String, dynamic> json) => _$AdminUserLoginFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserLoginToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminUserDetail {
  final ChaldeaUser user;
  final List<AdminUserSession> sessions;
  final List<AdminUserLogin> logins;
  final int backupsCount;
  final int teamsCount;

  AdminUserDetail({
    required this.user,
    this.sessions = const [],
    this.logins = const [],
    required this.backupsCount,
    required this.teamsCount,
  });

  factory AdminUserDetail.fromJson(Map<String, dynamic> json) => _$AdminUserDetailFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserDetailToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AdminRecoverResponse {
  final String message;
  final String messageZh;
  final String action; // "reset_email_sent" | "password_directly_reset"
  final int userId;
  final String username;
  final bool emailProvided;
  final bool emailBound;
  final String details;
  final String detailsZh;
  final List<String> reminders;
  final List<String> remindersZh;

  AdminRecoverResponse({
    required this.message,
    required this.messageZh,
    required this.action,
    required this.userId,
    required this.username,
    required this.emailProvided,
    required this.emailBound,
    required this.details,
    required this.detailsZh,
    this.reminders = const [],
    this.remindersZh = const [],
  });

  factory AdminRecoverResponse.fromJson(Map<String, dynamic> json) => _$AdminRecoverResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AdminRecoverResponseToJson(this);
}
