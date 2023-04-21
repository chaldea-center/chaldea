// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/misc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MstMyRoomAdd _$MstMyRoomAddFromJson(Map json) => MstMyRoomAdd(
      id: json['id'] as int,
      type: json['type'] as int,
      priority: json['priority'] as int,
      overwriteId: json['overwriteId'] as int,
      condType: json['condType'] as int,
      condValue: json['condValue'] as int,
      condValue2: json['condValue2'] as int,
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
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
