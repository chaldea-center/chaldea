// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/api/api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerResponse _$WorkerResponseFromJson(Map json) => $checkedCreate('WorkerResponse', json, ($checkedConvert) {
  final val = WorkerResponse(
    status: $checkedConvert('status', (v) => (v as num?)?.toInt()),
    error: $checkedConvert('error', (v) => v),
    message: $checkedConvert('message', (v) => v as String?),
    body: $checkedConvert('body', (v) => v),
  );
  return val;
});

Map<String, dynamic> _$WorkerResponseToJson(WorkerResponse instance) => <String, dynamic>{
  'status': instance.status,
  'error': instance.error,
  'message': instance.message,
  'body': instance.body,
};

UserInfo _$UserInfoFromJson(Map json) => $checkedCreate('UserInfo', json, ($checkedConvert) {
  final val = UserInfo(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    name: $checkedConvert('name', (v) => v as String),
    email: $checkedConvert('email', (v) => v as String?),
    role: $checkedConvert('role', (v) => (v as num?)?.toInt() ?? ChaldeaUserRole.member),
    createdAt: $checkedConvert('created_at', (v) => (v as num?)?.toInt()),
  );
  return val;
}, fieldKeyMap: const {'createdAt': 'created_at'});

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
  'created_at': instance.createdAt,
};

LoginResponse _$LoginResponseFromJson(Map json) => $checkedCreate('LoginResponse', json, ($checkedConvert) {
  final val = LoginResponse(
    accessToken: $checkedConvert('access_token', (v) => v as String),
    tokenType: $checkedConvert('token_type', (v) => v as String? ?? 'bearer'),
    userInfo: $checkedConvert('user_info', (v) => UserInfo.fromJson(Map<String, dynamic>.from(v as Map))),
  );
  return val;
}, fieldKeyMap: const {'accessToken': 'access_token', 'tokenType': 'token_type', 'userInfo': 'user_info'});

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) => <String, dynamic>{
  'access_token': instance.accessToken,
  'token_type': instance.tokenType,
  'user_info': instance.userInfo.toJson(),
};

ChaldeaUser _$ChaldeaUserFromJson(Map json) => $checkedCreate('ChaldeaUser', json, ($checkedConvert) {
  final val = ChaldeaUser(
    info: $checkedConvert('info', (v) => v == null ? null : UserInfo.fromJson(Map<String, dynamic>.from(v as Map))),
    accessToken: $checkedConvert('access_token', (v) => v as String?),
    secret: $checkedConvert('secret', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'accessToken': 'access_token'});

Map<String, dynamic> _$ChaldeaUserToJson(ChaldeaUser instance) => <String, dynamic>{
  'info': instance.info?.toJson(),
  'access_token': instance.accessToken,
  'secret': instance.secret,
};

UserBackupData _$UserBackupDataFromJson(Map json) => $checkedCreate('UserBackupData', json, ($checkedConvert) {
  final val = UserBackupData(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    userId: $checkedConvert('user_id', (v) => (v as num).toInt()),
    appVer: $checkedConvert('app_ver', (v) => v as String?),
    os: $checkedConvert('os', (v) => v as String?),
    createdAt: $checkedConvert('created_at', (v) => (v as num).toInt()),
    content: $checkedConvert('content', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'userId': 'user_id', 'appVer': 'app_ver', 'createdAt': 'created_at'});

Map<String, dynamic> _$UserBackupDataToJson(UserBackupData instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'app_ver': instance.appVer,
  'os': instance.os,
  'created_at': instance.createdAt,
  'content': instance.content,
};

TeamVoteData _$TeamVoteDataFromJson(Map json) => $checkedCreate('TeamVoteData', json, ($checkedConvert) {
  final val = TeamVoteData(
    up: $checkedConvert('up', (v) => (v as num?)?.toInt() ?? 0),
    down: $checkedConvert('down', (v) => (v as num?)?.toInt() ?? 0),
    mine: $checkedConvert('mine', (v) => (v as num?)?.toInt() ?? 0),
  );
  return val;
});

Map<String, dynamic> _$TeamVoteDataToJson(TeamVoteData instance) => <String, dynamic>{
  'up': instance.up,
  'down': instance.down,
  'mine': instance.mine,
};

UserBattleData _$UserBattleDataFromJson(Map json) => $checkedCreate(
  'UserBattleData',
  json,
  ($checkedConvert) {
    final val = UserBattleData(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      ver: $checkedConvert('ver', (v) => (v as num).toInt()),
      appVer: $checkedConvert('app_ver', (v) => v as String?),
      userId: $checkedConvert('user_id', (v) => (v as num).toInt()),
      questId: $checkedConvert('quest_id', (v) => (v as num).toInt()),
      phase: $checkedConvert('phase', (v) => (v as num).toInt()),
      enemyHash: $checkedConvert('enemy_hash', (v) => v as String),
      createdAt: $checkedConvert('created_at', (v) => (v as num).toInt()),
      content: $checkedConvert('data', (v) => v as String),
      username: $checkedConvert('username', (v) => v as String?),
      votes: $checkedConvert(
        'votes',
        (v) => v == null ? null : TeamVoteData.fromJson(Map<String, dynamic>.from(v as Map)),
        readValue: UserBattleData._readVotes,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'appVer': 'app_ver',
    'userId': 'user_id',
    'questId': 'quest_id',
    'enemyHash': 'enemy_hash',
    'createdAt': 'created_at',
    'content': 'data',
  },
);

Map<String, dynamic> _$UserBattleDataToJson(UserBattleData instance) => <String, dynamic>{
  'id': instance.id,
  'ver': instance.ver,
  'app_ver': instance.appVer,
  'user_id': instance.userId,
  'quest_id': instance.questId,
  'phase': instance.phase,
  'enemy_hash': instance.enemyHash,
  'created_at': instance.createdAt,
  'data': instance.content,
  'username': instance.username,
  'votes': instance.votes.toJson(),
};

TeamQueryResult _$TeamQueryResultFromJson(Map json) => $checkedCreate('TeamQueryResult', json, ($checkedConvert) {
  final val = TeamQueryResult(
    offset: $checkedConvert('offset', (v) => (v as num?)?.toInt() ?? 0),
    limit: $checkedConvert('limit', (v) => (v as num?)?.toInt() ?? 0),
    total: $checkedConvert('total', (v) => (v as num?)?.toInt()),
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>).map((e) => UserBattleData.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$TeamQueryResultToJson(TeamQueryResult instance) => <String, dynamic>{
  'offset': instance.offset,
  'limit': instance.limit,
  'total': instance.total,
  'data': instance.data.map((e) => e.toJson()).toList(),
};

AAFileManifest _$AAFileManifestFromJson(Map json) => $checkedCreate('AAFileManifest', json, ($checkedConvert) {
  final val = AAFileManifest(
    fileName: $checkedConvert('fileName', (v) => v as String),
    size: $checkedConvert('size', (v) => (v as num).toInt()),
  );
  return val;
});

Map<String, dynamic> _$AAFileManifestToJson(AAFileManifest instance) => <String, dynamic>{
  'fileName': instance.fileName,
  'size': instance.size,
};

AdminUserListItem _$AdminUserListItemFromJson(Map json) => $checkedCreate('AdminUserListItem', json, ($checkedConvert) {
  final val = AdminUserListItem(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    name: $checkedConvert('name', (v) => v as String),
    email: $checkedConvert('email', (v) => v as String?),
    role: $checkedConvert('role', (v) => (v as num).toInt()),
    createdAt: $checkedConvert('created_at', (v) => (v as num).toInt()),
  );
  return val;
}, fieldKeyMap: const {'createdAt': 'created_at'});

Map<String, dynamic> _$AdminUserListItemToJson(AdminUserListItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
  'created_at': instance.createdAt,
};

AdminUsersList _$AdminUsersListFromJson(Map json) => $checkedCreate('AdminUsersList', json, ($checkedConvert) {
  final val = AdminUsersList(
    offset: $checkedConvert('offset', (v) => (v as num?)?.toInt() ?? 0),
    limit: $checkedConvert('limit', (v) => (v as num?)?.toInt() ?? 0),
    total: $checkedConvert('total', (v) => (v as num?)?.toInt()),
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>).map((e) => AdminUserListItem.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$AdminUsersListToJson(AdminUsersList instance) => <String, dynamic>{
  'offset': instance.offset,
  'limit': instance.limit,
  'total': instance.total,
  'data': instance.data.map((e) => e.toJson()).toList(),
};

AdminUserSession _$AdminUserSessionFromJson(Map json) => $checkedCreate('AdminUserSession', json, ($checkedConvert) {
  final val = AdminUserSession(
    device: $checkedConvert('device', (v) => v as String),
    sessionId: $checkedConvert('session_id', (v) => v as String),
  );
  return val;
}, fieldKeyMap: const {'sessionId': 'session_id'});

Map<String, dynamic> _$AdminUserSessionToJson(AdminUserSession instance) => <String, dynamic>{
  'device': instance.device,
  'session_id': instance.sessionId,
};

AdminUserLogin _$AdminUserLoginFromJson(Map json) => $checkedCreate('AdminUserLogin', json, ($checkedConvert) {
  final val = AdminUserLogin(
    device: $checkedConvert('device', (v) => v as String),
    createdAt: $checkedConvert('created_at', (v) => (v as num).toInt()),
    updatedAt: $checkedConvert('updated_at', (v) => (v as num).toInt()),
  );
  return val;
}, fieldKeyMap: const {'createdAt': 'created_at', 'updatedAt': 'updated_at'});

Map<String, dynamic> _$AdminUserLoginToJson(AdminUserLogin instance) => <String, dynamic>{
  'device': instance.device,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

AdminUserDetail _$AdminUserDetailFromJson(Map json) => $checkedCreate('AdminUserDetail', json, ($checkedConvert) {
  final val = AdminUserDetail(
    user: $checkedConvert('user', (v) => ChaldeaUser.fromJson(Map<String, dynamic>.from(v as Map))),
    sessions: $checkedConvert(
      'sessions',
      (v) =>
          (v as List<dynamic>?)?.map((e) => AdminUserSession.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
          const [],
    ),
    logins: $checkedConvert(
      'logins',
      (v) =>
          (v as List<dynamic>?)?.map((e) => AdminUserLogin.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
          const [],
    ),
    backupsCount: $checkedConvert('backups_count', (v) => (v as num).toInt()),
    teamsCount: $checkedConvert('teams_count', (v) => (v as num).toInt()),
  );
  return val;
}, fieldKeyMap: const {'backupsCount': 'backups_count', 'teamsCount': 'teams_count'});

Map<String, dynamic> _$AdminUserDetailToJson(AdminUserDetail instance) => <String, dynamic>{
  'user': instance.user.toJson(),
  'sessions': instance.sessions.map((e) => e.toJson()).toList(),
  'logins': instance.logins.map((e) => e.toJson()).toList(),
  'backups_count': instance.backupsCount,
  'teams_count': instance.teamsCount,
};

AdminRecoverResponse _$AdminRecoverResponseFromJson(Map json) => $checkedCreate(
  'AdminRecoverResponse',
  json,
  ($checkedConvert) {
    final val = AdminRecoverResponse(
      message: $checkedConvert('message', (v) => v as String),
      messageZh: $checkedConvert('message_zh', (v) => v as String),
      action: $checkedConvert('action', (v) => v as String),
      userId: $checkedConvert('user_id', (v) => (v as num).toInt()),
      username: $checkedConvert('username', (v) => v as String),
      emailProvided: $checkedConvert('email_provided', (v) => v as bool),
      emailBound: $checkedConvert('email_bound', (v) => v as bool),
      details: $checkedConvert('details', (v) => v as String),
      detailsZh: $checkedConvert('details_zh', (v) => v as String),
      reminders: $checkedConvert(
        'reminders',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      ),
      remindersZh: $checkedConvert(
        'reminders_zh',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'messageZh': 'message_zh',
    'userId': 'user_id',
    'emailProvided': 'email_provided',
    'emailBound': 'email_bound',
    'detailsZh': 'details_zh',
    'remindersZh': 'reminders_zh',
  },
);

Map<String, dynamic> _$AdminRecoverResponseToJson(AdminRecoverResponse instance) => <String, dynamic>{
  'message': instance.message,
  'message_zh': instance.messageZh,
  'action': instance.action,
  'user_id': instance.userId,
  'username': instance.username,
  'email_provided': instance.emailProvided,
  'email_bound': instance.emailBound,
  'details': instance.details,
  'details_zh': instance.detailsZh,
  'reminders': instance.reminders,
  'reminders_zh': instance.remindersZh,
};
