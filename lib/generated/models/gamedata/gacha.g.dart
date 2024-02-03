// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/gacha.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MstGacha _$MstGachaFromJson(Map json) => MstGacha(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? "",
      imageId: json['imageId'] as int? ?? 0,
      priority: json['priority'] as int? ?? 0,
      warId: json['warId'] as int? ?? 0,
      gachaSlot: json['gachaSlot'] as int? ?? 0,
      type: json['type'] as int? ?? 1,
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

NiceGacha _$NiceGachaFromJson(Map json) => NiceGacha(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      imageId: json['imageId'] as int? ?? 0,
      type: json['type'] == null ? GachaType.payGacha : const GachaTypeConverter().fromJson(json['type']),
      adjustId: json['adjustId'] as int? ?? 0,
      pickupId: json['pickupId'] as int? ?? 0,
      drawNum1: json['drawNum1'] as int? ?? 0,
      drawNum2: json['drawNum2'] as int? ?? 0,
      maxDrawNum: json['maxDrawNum'] as int? ?? 0,
      openedAt: json['openedAt'] as int? ?? 0,
      closedAt: json['closedAt'] as int? ?? 0,
      detailUrl: json['detailUrl'] as String? ?? '',
      flags: (json['flags'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$GachaFlagEnumMap, e, unknownValue: GachaFlag.none))
              .toList() ??
          const [],
      storyAdjusts: (json['storyAdjusts'] as List<dynamic>?)
              ?.map((e) => GachaStoryAdjust.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      userAdded: json['userAdded'] as bool? ?? false,
    );

const _$GachaFlagEnumMap = {
  GachaFlag.none: 'none',
  GachaFlag.pcMessage: 'pcMessage',
  GachaFlag.bonusSelect: 'bonusSelect',
};

GachaStoryAdjust _$GachaStoryAdjustFromJson(Map json) => GachaStoryAdjust(
      adjustId: json['adjustId'] as int,
      idx: json['idx'] as int? ?? 1,
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      targetId: json['targetId'] as int? ?? 0,
      value: json['value'] as int? ?? 0,
      imageId: json['imageId'] as int? ?? 0,
    );

const _$GachaTypeEnumMap = {
  GachaType.unknown: 'unknown',
  GachaType.payGacha: 'payGacha',
  GachaType.freeGacha: 'freeGacha',
  GachaType.ticketGacha: 'ticketGacha',
  GachaType.chargeStone: 'chargeStone',
};
