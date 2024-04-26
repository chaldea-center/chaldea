// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/misc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MstMyRoomAdd _$MstMyRoomAddFromJson(Map json) => MstMyRoomAdd(
      id: (json['id'] as num).toInt(),
      type: (json['type'] as num).toInt(),
      priority: (json['priority'] as num).toInt(),
      overwriteId: (json['overwriteId'] as num).toInt(),
      condType: (json['condType'] as num).toInt(),
      condValue: (json['condValue'] as num).toInt(),
      condValue2: (json['condValue2'] as num).toInt(),
      startedAt: (json['startedAt'] as num).toInt(),
      endedAt: (json['endedAt'] as num).toInt(),
    );

Map<String, dynamic> _$MstMyRoomAddToJson(MstMyRoomAdd instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'priority': instance.priority,
      'overwriteId': instance.overwriteId,
      'condType': instance.condType,
      'condValue': instance.condValue,
      'condValue2': instance.condValue2,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
    };
