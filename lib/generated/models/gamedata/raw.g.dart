// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/raw.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MstEvent _$MstEventFromJson(Map json) => MstEvent(
      id: (json['id'] as num).toInt(),
      type: (json['type'] as num).toInt(),
      name: json['name'] as String? ?? "",
      shortName: json['shortName'] as String? ?? "",
      startedAt: (json['startedAt'] as num).toInt(),
      endedAt: (json['endedAt'] as num).toInt(),
      finishedAt: (json['finishedAt'] as num).toInt(),
    );

ExtraCharaFigure _$ExtraCharaFigureFromJson(Map json) => ExtraCharaFigure(
      svtId: (json['svtId'] as num).toInt(),
      charaFigureIds: (json['charaFigureIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    );

Map<String, dynamic> _$ExtraCharaFigureToJson(ExtraCharaFigure instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'charaFigureIds': instance.charaFigureIds,
    };

ExtraCharaImage _$ExtraCharaImageFromJson(Map json) => ExtraCharaImage(
      svtId: (json['svtId'] as num).toInt(),
      imageIds: json['imageIds'] as List<dynamic>?,
    );

Map<String, dynamic> _$ExtraCharaImageToJson(ExtraCharaImage instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'imageIds': instance.imageIds,
    };

MstViewEnemy _$MstViewEnemyFromJson(Map json) => MstViewEnemy(
      questId: (json['questId'] as num).toInt(),
      enemyId: (json['enemyId'] as num).toInt(),
      name: json['name'] as String,
      classId: (json['classId'] as num).toInt(),
      svtId: (json['svtId'] as num).toInt(),
      limitCount: (json['limitCount'] as num).toInt(),
      iconId: (json['iconId'] as num).toInt(),
      displayType: (json['displayType'] as num).toInt(),
      missionIds: (json['missionIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      impossibleKill: (json['impossibleKill'] as num?)?.toInt() ?? 0,
      enemyScript: json['enemyScript'],
      npcSvtId: (json['npcSvtId'] as num).toInt(),
    );

Map<String, dynamic> _$MstViewEnemyToJson(MstViewEnemy instance) => <String, dynamic>{
      'questId': instance.questId,
      'enemyId': instance.enemyId,
      'name': instance.name,
      'classId': instance.classId,
      'svtId': instance.svtId,
      'limitCount': instance.limitCount,
      'iconId': instance.iconId,
      'displayType': instance.displayType,
      'missionIds': instance.missionIds,
      'impossibleKill': instance.impossibleKill,
      'enemyScript': instance.enemyScript,
      'npcSvtId': instance.npcSvtId,
    };

UserDeckFormationCond _$UserDeckFormationCondFromJson(Map json) => UserDeckFormationCond(
      targetVals: (json['targetVals'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      targetVals2: (json['targetVals2'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      id: (json['id'] as num).toInt(),
      type: (json['type'] as num?)?.toInt() ?? 0,
      rangeType: (json['rangeType'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserDeckFormationCondToJson(UserDeckFormationCond instance) => <String, dynamic>{
      'targetVals': instance.targetVals,
      'targetVals2': instance.targetVals2,
      'id': instance.id,
      'type': instance.type,
      'rangeType': instance.rangeType,
    };

MstQuestHint _$MstQuestHintFromJson(Map json) => MstQuestHint(
      questId: (json['questId'] as num).toInt(),
      questPhase: (json['questPhase'] as num).toInt(),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      leftIndent: (json['leftIndent'] as num?)?.toInt() ?? 0,
      openType: (json['openType'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MstQuestHintToJson(MstQuestHint instance) => <String, dynamic>{
      'questId': instance.questId,
      'questPhase': instance.questPhase,
      'title': instance.title,
      'message': instance.message,
      'leftIndent': instance.leftIndent,
      'openType': instance.openType,
    };
