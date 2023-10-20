// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/raw.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MstEvent _$MstEventFromJson(Map json) => MstEvent(
      id: json['id'] as int,
      type: json['type'] as int,
      name: json['name'] as String? ?? "",
      shortName: json['shortName'] as String? ?? "",
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
      finishedAt: json['finishedAt'] as int,
    );

MstGacha _$MstGachaFromJson(Map json) => MstGacha(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? "",
      imageId: json['imageId'] as int? ?? 0,
      priority: json['priority'] as int? ?? 0,
      warId: json['warId'] as int? ?? 0,
      gachaSlot: json['gachaSlot'] as int? ?? 0,
      type: json['type'] as int? ?? 0,
      shopId1: json['shopId1'] as int? ?? 0,
      shopId2: json['shopId2'] as int? ?? 0,
      rarityId: json['rarityId'] as int? ?? 0,
      baseId: json['baseId'] as int? ?? 0,
      adjustId: json['adjustId'] as int? ?? 0,
      pickupId: json['pickupId'] as int? ?? 0,
      ticketItemId: json['ticketItemId'] as int? ?? 0,
      gachaGroupId: json['gachaGroupId'] as int? ?? 0,
      drawNum1: json['drawNum1'] as int? ?? 0,
      drawNum2: json['drawNum2'] as int? ?? 0,
      extraGroupId1: json['extraGroupId1'] as int? ?? 0,
      extraGroupId2: json['extraGroupId2'] as int? ?? 0,
      extraAddCount1: json['extraAddCount1'] as int? ?? 0,
      extraAddCount2: json['extraAddCount2'] as int? ?? 0,
      freeDrawFlag: json['freeDrawFlag'] as int? ?? 0,
      maxDrawNum: json['maxDrawNum'] as int? ?? 0,
      beforeGachaId: json['beforeGachaId'] as int? ?? 0,
      beforeDrawNum: json['beforeDrawNum'] as int? ?? 0,
      openedAt: json['openedAt'] as int? ?? 0,
      closedAt: json['closedAt'] as int? ?? 0,
      condQuestId: json['condQuestId'] as int? ?? 0,
      condQuestPhase: json['condQuestPhase'] as int? ?? 0,
      detailUrl: json['detailUrl'] as String? ?? "",
      bannerQuestId: json['bannerQuestId'] as int? ?? 0,
      bannerQuestPhase: json['bannerQuestPhase'] as int? ?? 0,
      flag: json['flag'] as int? ?? 0,
      userAdded: json['userAdded'] as bool? ?? false,
    );

ExtraCharaFigure _$ExtraCharaFigureFromJson(Map json) => ExtraCharaFigure(
      svtId: json['svtId'] as int,
      charaFigureIds: (json['charaFigureIds'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );

Map<String, dynamic> _$ExtraCharaFigureToJson(ExtraCharaFigure instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'charaFigureIds': instance.charaFigureIds,
    };

ExtraCharaImage _$ExtraCharaImageFromJson(Map json) => ExtraCharaImage(
      svtId: json['svtId'] as int,
      imageIds: json['imageIds'] as List<dynamic>?,
    );

Map<String, dynamic> _$ExtraCharaImageToJson(ExtraCharaImage instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'imageIds': instance.imageIds,
    };
