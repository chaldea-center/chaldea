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

GachaInfos _$GachaInfosFromJson(Map json) => GachaInfos(
      isNew: json['isNew'] as bool? ?? false,
      userSvtId: (json['userSvtId'] as num?)?.toInt() ?? 0,
      type: (json['type'] as num?)?.toInt() ?? 0,
      objectId: (json['objectId'] as num?)?.toInt() ?? 0,
      num: (json['num'] as num?)?.toInt() ?? 0,
      limitCount: (json['limitCount'] as num?)?.toInt() ?? 0,
      sellQp: (json['sellQp'] as num?)?.toInt() ?? 0,
      sellMana: (json['sellMana'] as num?)?.toInt() ?? 0,
      svtCoinNum: (json['svtCoinNum'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GachaInfosToJson(GachaInfos instance) => <String, dynamic>{
      'type': instance.type,
      'objectId': instance.objectId,
      'num': instance.num,
      'isNew': instance.isNew,
      'userSvtId': instance.userSvtId,
      'limitCount': instance.limitCount,
      'sellQp': instance.sellQp,
      'sellMana': instance.sellMana,
      'svtCoinNum': instance.svtCoinNum,
    };
