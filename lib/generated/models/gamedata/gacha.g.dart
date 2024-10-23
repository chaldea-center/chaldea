// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/gacha.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MstGacha _$MstGachaFromJson(Map json) => MstGacha(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? "",
      imageId: (json['imageId'] as num?)?.toInt() ?? 0,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      warId: (json['warId'] as num?)?.toInt() ?? 0,
      gachaSlot: (json['gachaSlot'] as num?)?.toInt() ?? 0,
      type: (json['type'] as num?)?.toInt() ?? 1,
      shopId1: (json['shopId1'] as num?)?.toInt() ?? 0,
      shopId2: (json['shopId2'] as num?)?.toInt() ?? 0,
      rarityId: (json['rarityId'] as num?)?.toInt() ?? 0,
      baseId: (json['baseId'] as num?)?.toInt() ?? 0,
      adjustId: (json['adjustId'] as num?)?.toInt() ?? 0,
      pickupId: (json['pickupId'] as num?)?.toInt() ?? 0,
      ticketItemId: (json['ticketItemId'] as num?)?.toInt() ?? 0,
      gachaGroupId: (json['gachaGroupId'] as num?)?.toInt() ?? 0,
      drawNum1: (json['drawNum1'] as num?)?.toInt() ?? 0,
      drawNum2: (json['drawNum2'] as num?)?.toInt() ?? 0,
      extraGroupId1: (json['extraGroupId1'] as num?)?.toInt() ?? 0,
      extraGroupId2: (json['extraGroupId2'] as num?)?.toInt() ?? 0,
      extraAddCount1: (json['extraAddCount1'] as num?)?.toInt() ?? 0,
      extraAddCount2: (json['extraAddCount2'] as num?)?.toInt() ?? 0,
      freeDrawFlag: (json['freeDrawFlag'] as num?)?.toInt() ?? 0,
      maxDrawNum: (json['maxDrawNum'] as num?)?.toInt() ?? 0,
      beforeGachaId: (json['beforeGachaId'] as num?)?.toInt() ?? 0,
      beforeDrawNum: (json['beforeDrawNum'] as num?)?.toInt() ?? 0,
      openedAt: (json['openedAt'] as num?)?.toInt() ?? 0,
      closedAt: (json['closedAt'] as num?)?.toInt() ?? 0,
      condQuestId: (json['condQuestId'] as num?)?.toInt() ?? 0,
      condQuestPhase: (json['condQuestPhase'] as num?)?.toInt() ?? 0,
      detailUrl: json['detailUrl'] as String? ?? "",
      bannerQuestId: (json['bannerQuestId'] as num?)?.toInt() ?? 0,
      bannerQuestPhase: (json['bannerQuestPhase'] as num?)?.toInt() ?? 0,
      flag: (json['flag'] as num?)?.toInt() ?? 0,
      userAdded: json['userAdded'] as bool? ?? false,
    );

NiceGacha _$NiceGachaFromJson(Map json) => NiceGacha(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      imageId: (json['imageId'] as num?)?.toInt() ?? 0,
      type: json['type'] == null ? GachaType.payGacha : const GachaTypeConverter().fromJson(json['type']),
      adjustId: (json['adjustId'] as num?)?.toInt() ?? 0,
      pickupId: (json['pickupId'] as num?)?.toInt() ?? 0,
      drawNum1: (json['drawNum1'] as num?)?.toInt() ?? 0,
      drawNum2: (json['drawNum2'] as num?)?.toInt() ?? 0,
      maxDrawNum: (json['maxDrawNum'] as num?)?.toInt() ?? 0,
      openedAt: (json['openedAt'] as num?)?.toInt() ?? 0,
      closedAt: (json['closedAt'] as num?)?.toInt() ?? 0,
      detailUrl: json['detailUrl'] as String? ?? '',
      flags: (json['flags'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$GachaFlagEnumMap, e, unknownValue: GachaFlag.none))
              .toList() ??
          const [],
      storyAdjusts: (json['storyAdjusts'] as List<dynamic>?)
              ?.map((e) => GachaStoryAdjust.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      gachaSubs: (json['gachaSubs'] as List<dynamic>?)
              ?.map((e) => GachaSub.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      userAdded: json['userAdded'] as bool? ?? false,
    );

const _$GachaFlagEnumMap = {
  GachaFlag.none: 'none',
  GachaFlag.pcMessage: 'pcMessage',
  GachaFlag.bonusSelect: 'bonusSelect',
  GachaFlag.displayFeaturedSvt: 'displayFeaturedSvt',
};

GachaStoryAdjust _$GachaStoryAdjustFromJson(Map json) => GachaStoryAdjust(
      adjustId: (json['adjustId'] as num).toInt(),
      idx: (json['idx'] as num?)?.toInt() ?? 1,
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      targetId: (json['targetId'] as num?)?.toInt() ?? 0,
      value: (json['value'] as num?)?.toInt() ?? 0,
      imageId: (json['imageId'] as num?)?.toInt() ?? 0,
    );

GachaSub _$GachaSubFromJson(Map json) => GachaSub(
      id: (json['id'] as num).toInt(),
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      imageId: (json['imageId'] as num?)?.toInt() ?? 0,
      adjustAddId: (json['adjustAddId'] as num?)?.toInt() ?? 0,
      openedAt: (json['openedAt'] as num?)?.toInt() ?? 0,
      closedAt: (json['closedAt'] as num?)?.toInt() ?? 0,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: (json['script'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
    );

const _$GachaTypeEnumMap = {
  GachaType.unknown: 'unknown',
  GachaType.payGacha: 'payGacha',
  GachaType.freeGacha: 'freeGacha',
  GachaType.ticketGacha: 'ticketGacha',
  GachaType.chargeStone: 'chargeStone',
};
