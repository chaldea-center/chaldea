// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/gift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MstGiftBase _$MstGiftBaseFromJson(Map json) => MstGiftBase(
  type: (json['type'] as num?)?.toInt() ?? 0,
  objectId: (json['objectId'] as num?)?.toInt() ?? 0,
  num: (json['num'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MstGiftBaseToJson(MstGiftBase instance) => <String, dynamic>{
  'type': instance.type,
  'objectId': instance.objectId,
  'num': instance.num,
};
