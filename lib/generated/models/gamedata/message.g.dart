// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BattleMessage _$BattleMessageFromJson(Map json) => BattleMessage(
  id: (json['id'] as num).toInt(),
  idx: (json['idx'] as num).toInt(),
  priority: (json['priority'] as num).toInt(),
  releaseConditions:
      (json['releaseConditions'] as List<dynamic>?)
          ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  motionId: (json['motionId'] as num?)?.toInt() ?? 0,
  message: json['message'] as String? ?? '',
  script: (json['script'] as Map?)?.map((k, e) => MapEntry(k as String, e)) ?? const {},
);

Map<String, dynamic> _$BattleMessageToJson(BattleMessage instance) => <String, dynamic>{
  'id': instance.id,
  'idx': instance.idx,
  'priority': instance.priority,
  'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
  'motionId': instance.motionId,
  'message': instance.message,
  'script': instance.script,
};

BattleMessageGroup _$BattleMessageGroupFromJson(Map json) => BattleMessageGroup(
  groupId: (json['groupId'] as num).toInt(),
  probability: (json['probability'] as num).toInt(),
  messages:
      (json['messages'] as List<dynamic>?)
          ?.map((e) => BattleMessage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$BattleMessageGroupToJson(BattleMessageGroup instance) => <String, dynamic>{
  'groupId': instance.groupId,
  'probability': instance.probability,
  'messages': instance.messages.map((e) => e.toJson()).toList(),
};

BattleScript _$BattleScriptFromJson(Map json) => BattleScript(
  id: (json['id'] as num).toInt(),
  playOrder: (json['playOrder'] as num?)?.toInt() ?? 0,
  idx: (json['idx'] as num?)?.toInt() ?? 0,
  battleScriptAction: $enumDecodeNullable(_$BattleScriptActionTypeEnumMap, json['battleScriptAction']) ?? .unknown,
  script: json['script'] == null ? null : BattleScriptDetail.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
);

Map<String, dynamic> _$BattleScriptToJson(BattleScript instance) => <String, dynamic>{
  'id': instance.id,
  'playOrder': instance.playOrder,
  'idx': instance.idx,
  'battleScriptAction': _$BattleScriptActionTypeEnumMap[instance.battleScriptAction]!,
  'script': instance.script?.toJson(),
};

const _$BattleScriptActionTypeEnumMap = {
  BattleScriptActionType.unknown: 'unknown',
  BattleScriptActionType.aiAct: 'aiAct',
  BattleScriptActionType.wait: 'wait',
  BattleScriptActionType.cutIn: 'cutIn',
  BattleScriptActionType.moveCamera: 'moveCamera',
  BattleScriptActionType.message: 'message',
  BattleScriptActionType.playVoice: 'playVoice',
  BattleScriptActionType.normalSpeed: 'normalSpeed',
  BattleScriptActionType.resumeSpeed: 'resumeSpeed',
};

BattleScriptDetail _$BattleScriptDetailFromJson(Map json) => BattleScriptDetail();

Map<String, dynamic> _$BattleScriptDetailToJson(BattleScriptDetail instance) => <String, dynamic>{};
