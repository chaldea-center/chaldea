// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/api/api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerResponse _$WorkerResponseFromJson(Map json) => $checkedCreate(
      'WorkerResponse',
      json,
      ($checkedConvert) {
        final val = WorkerResponse(
          status: $checkedConvert('status', (v) => v as int?),
          error: $checkedConvert('error', (v) => v),
          message: $checkedConvert('message', (v) => v as String?),
          body: $checkedConvert('body', (v) => v),
        );
        return val;
      },
    );

Map<String, dynamic> _$WorkerResponseToJson(WorkerResponse instance) => <String, dynamic>{
      'status': instance.status,
      'error': instance.error,
      'message': instance.message,
      'body': instance.body,
    };

ChaldeaUser _$ChaldeaUserFromJson(Map json) => $checkedCreate(
      'ChaldeaUser',
      json,
      ($checkedConvert) {
        final val = ChaldeaUser(
          id: $checkedConvert('id', (v) => v as int),
          name: $checkedConvert('name', (v) => v as String),
          role: $checkedConvert('role', (v) => v as int? ?? ChaldeaUserRole.member),
          secret: $checkedConvert('secret', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$ChaldeaUserToJson(ChaldeaUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': instance.role,
      'secret': instance.secret,
    };

UserBackupData _$UserBackupDataFromJson(Map json) => $checkedCreate(
      'UserBackupData',
      json,
      ($checkedConvert) {
        final val = UserBackupData(
          id: $checkedConvert('id', (v) => v as int),
          userId: $checkedConvert('userId', (v) => v as int),
          appVer: $checkedConvert('appVer', (v) => v as String?),
          os: $checkedConvert('os', (v) => v as String?),
          createdAt: $checkedConvert('createdAt', (v) => v as int),
          content: $checkedConvert('content', (v) => v as String),
        );
        return val;
      },
    );

Map<String, dynamic> _$UserBackupDataToJson(UserBackupData instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'appVer': instance.appVer,
      'os': instance.os,
      'createdAt': instance.createdAt,
      'content': instance.content,
    };

TeamVoteData _$TeamVoteDataFromJson(Map json) => $checkedCreate(
      'TeamVoteData',
      json,
      ($checkedConvert) {
        final val = TeamVoteData(
          up: $checkedConvert('up', (v) => v as int? ?? 0),
          down: $checkedConvert('down', (v) => v as int? ?? 0),
          mine: $checkedConvert('mine', (v) => v as int? ?? 0),
        );
        return val;
      },
    );

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
          id: $checkedConvert('id', (v) => v as int),
          ver: $checkedConvert('ver', (v) => v as int),
          appVer: $checkedConvert('appVer', (v) => v as String?),
          userId: $checkedConvert('userId', (v) => v as int),
          questId: $checkedConvert('questId', (v) => v as int),
          phase: $checkedConvert('phase', (v) => v as int),
          enemyHash: $checkedConvert('enemyHash', (v) => v as String),
          createdAt: $checkedConvert('createdAt', (v) => v as int),
          content: $checkedConvert('content', (v) => v as String),
          username: $checkedConvert('username', (v) => v as String?),
          votes: $checkedConvert(
              'votes', (v) => v == null ? null : TeamVoteData.fromJson(Map<String, dynamic>.from(v as Map))),
        );
        return val;
      },
    );

Map<String, dynamic> _$UserBattleDataToJson(UserBattleData instance) => <String, dynamic>{
      'id': instance.id,
      'ver': instance.ver,
      'appVer': instance.appVer,
      'userId': instance.userId,
      'questId': instance.questId,
      'phase': instance.phase,
      'enemyHash': instance.enemyHash,
      'createdAt': instance.createdAt,
      'content': instance.content,
      'username': instance.username,
      'votes': instance.votes.toJson(),
    };

TeamQueryResult _$TeamQueryResultFromJson(Map json) => $checkedCreate(
      'TeamQueryResult',
      json,
      ($checkedConvert) {
        final val = TeamQueryResult(
          offset: $checkedConvert('offset', (v) => v as int? ?? 0),
          limit: $checkedConvert('limit', (v) => v as int? ?? 0),
          total: $checkedConvert('total', (v) => v as int?),
          data: $checkedConvert(
              'data',
              (v) => (v as List<dynamic>)
                  .map((e) => UserBattleData.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$TeamQueryResultToJson(TeamQueryResult instance) => <String, dynamic>{
      'offset': instance.offset,
      'limit': instance.limit,
      'total': instance.total,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };
