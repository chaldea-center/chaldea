// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NiceTrait _$NiceTraitFromJson(Map json) =>
    NiceTrait(id: (json['id'] as num).toInt(), negative: json['negative'] as bool? ?? false);

Map<String, dynamic> _$NiceTraitToJson(NiceTrait instance) => <String, dynamic>{
  'id': instance.id,
  'negative': instance.negative,
};

BgmRelease _$BgmReleaseFromJson(Map json) => BgmRelease(
  id: (json['id'] as num).toInt(),
  type: const CondTypeConverter().fromJson(json['type'] as String),
  condGroup: (json['condGroup'] as num?)?.toInt() ?? 0,
  targetIds: (json['targetIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  vals: (json['vals'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  closedMessage: json['closedMessage'] as String? ?? "",
);

Map<String, dynamic> _$BgmReleaseToJson(BgmRelease instance) => <String, dynamic>{
  'id': instance.id,
  'type': const CondTypeConverter().toJson(instance.type),
  'condGroup': instance.condGroup,
  'targetIds': instance.targetIds,
  'vals': instance.vals,
  'priority': instance.priority,
  'closedMessage': instance.closedMessage,
};

BgmEntity _$BgmEntityFromJson(Map json) => BgmEntity(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? '',
  fileName: json['fileName'] as String? ?? "",
  notReleased: json['notReleased'] as bool? ?? true,
  audioAsset: json['audioAsset'] as String?,
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  detail: json['detail'] as String? ?? "",
  shop: json['shop'] == null ? null : NiceShop.fromJson(Map<String, dynamic>.from(json['shop'] as Map)),
  logo: json['logo'] as String?,
  releaseConditions:
      (json['releaseConditions'] as List<dynamic>?)
          ?.map((e) => BgmRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
);

Map<String, dynamic> _$BgmEntityToJson(BgmEntity instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'fileName': instance.fileName,
  'notReleased': instance.notReleased,
  'audioAsset': instance.audioAsset,
  'priority': instance.priority,
  'detail': instance.detail,
  'shop': instance.shop?.toJson(),
  'logo': instance.logo,
  'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
};

Bgm _$BgmFromJson(Map json) => Bgm(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? '',
  fileName: json['fileName'] as String? ?? "",
  notReleased: json['notReleased'] as bool? ?? true,
  audioAsset: json['audioAsset'] as String?,
);

Map<String, dynamic> _$BgmToJson(Bgm instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'fileName': instance.fileName,
  'notReleased': instance.notReleased,
  'audioAsset': instance.audioAsset,
};

StageLink _$StageLinkFromJson(Map json) => StageLink(
  questId: (json['questId'] as num?)?.toInt() ?? 0,
  phase: (json['phase'] as num?)?.toInt() ?? 1,
  stage: (json['stage'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$StageLinkToJson(StageLink instance) => <String, dynamic>{
  'questId': instance.questId,
  'phase': instance.phase,
  'stage': instance.stage,
};

CommonConsume _$CommonConsumeFromJson(Map json) => CommonConsume(
  id: (json['id'] as num).toInt(),
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  type: $enumDecode(_$CommonConsumeTypeEnumMap, json['type']),
  objectId: (json['objectId'] as num).toInt(),
  num: (json['num'] as num).toInt(),
);

Map<String, dynamic> _$CommonConsumeToJson(CommonConsume instance) => <String, dynamic>{
  'id': instance.id,
  'priority': instance.priority,
  'type': _$CommonConsumeTypeEnumMap[instance.type]!,
  'objectId': instance.objectId,
  'num': instance.num,
};

const _$CommonConsumeTypeEnumMap = {CommonConsumeType.item: 'item', CommonConsumeType.ap: 'ap'};

CommonRelease _$CommonReleaseFromJson(Map json) => CommonRelease(
  id: (json['id'] as num).toInt(),
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  condGroup: (json['condGroup'] as num?)?.toInt() ?? 0,
  condType: const CondTypeConverter().fromJson(json['condType'] as String),
  condId: (json['condId'] as num?)?.toInt() ?? 0,
  condNum: (json['condNum'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CommonReleaseToJson(CommonRelease instance) => <String, dynamic>{
  'id': instance.id,
  'priority': instance.priority,
  'condGroup': instance.condGroup,
  'condType': const CondTypeConverter().toJson(instance.condType),
  'condId': instance.condId,
  'condNum': instance.condNum,
};

const _$RegionEnumMap = {Region.jp: 'jp', Region.cn: 'cn', Region.tw: 'tw', Region.na: 'na', Region.kr: 'kr'};

const _$CardTypeEnumMap = {
  CardType.none: 'none',
  CardType.arts: 'arts',
  CardType.buster: 'buster',
  CardType.quick: 'quick',
  CardType.extra: 'extra',
  CardType.blank: 'blank',
  CardType.weak: 'weak',
  CardType.strength: 'strength',
  CardType.weakalt1: 'weakalt1',
  CardType.weakalt2: 'weakalt2',
  CardType.busteralt1: 'busteralt1',
  CardType.extra2: 'extra2',
};

const _$SvtClassEnumMap = {
  SvtClass.none: 'none',
  SvtClass.saber: 'saber',
  SvtClass.archer: 'archer',
  SvtClass.lancer: 'lancer',
  SvtClass.rider: 'rider',
  SvtClass.caster: 'caster',
  SvtClass.assassin: 'assassin',
  SvtClass.berserker: 'berserker',
  SvtClass.shielder: 'shielder',
  SvtClass.ruler: 'ruler',
  SvtClass.alterEgo: 'alterEgo',
  SvtClass.avenger: 'avenger',
  SvtClass.demonGodPillar: 'demonGodPillar',
  SvtClass.loreGrandSaber: 'loreGrandSaber',
  SvtClass.loreGrandArcher: 'loreGrandArcher',
  SvtClass.loreGrandLancer: 'loreGrandLancer',
  SvtClass.loreGrandRider: 'loreGrandRider',
  SvtClass.loreGrandCaster: 'loreGrandCaster',
  SvtClass.loreGrandAssassin: 'loreGrandAssassin',
  SvtClass.loreGrandBerserker: 'loreGrandBerserker',
  SvtClass.beastII: 'beastII',
  SvtClass.ushiChaosTide: 'ushiChaosTide',
  SvtClass.beastI: 'beastI',
  SvtClass.moonCancer: 'moonCancer',
  SvtClass.beastIIIR: 'beastIIIR',
  SvtClass.foreigner: 'foreigner',
  SvtClass.beastIIIL: 'beastIIIL',
  SvtClass.beastUnknown: 'beastUnknown',
  SvtClass.pretender: 'pretender',
  SvtClass.beastIV: 'beastIV',
  SvtClass.beastILost: 'beastILost',
  SvtClass.uOlgaMarieAlienGod: 'uOlgaMarieAlienGod',
  SvtClass.uOlgaMarie: 'uOlgaMarie',
  SvtClass.beastDoraco: 'beastDoraco',
  SvtClass.beastVI: 'beastVI',
  SvtClass.beastVIBoss: 'beastVIBoss',
  SvtClass.uOlgaMarieFlare: 'uOlgaMarieFlare',
  SvtClass.uOlgaMarieAqua: 'uOlgaMarieAqua',
  SvtClass.beastEresh: 'beastEresh',
  SvtClass.uOlgaMarieGround: 'uOlgaMarieGround',
  SvtClass.unknown: 'unknown',
  SvtClass.agarthaPenth: 'agarthaPenth',
  SvtClass.cccFinaleEmiyaAlter: 'cccFinaleEmiyaAlter',
  SvtClass.salemAbby: 'salemAbby',
  SvtClass.OTHER: 'OTHER',
  SvtClass.ALL: 'ALL',
  SvtClass.EXTRA: 'EXTRA',
  SvtClass.MIX: 'MIX',
  SvtClass.EXTRA1: 'EXTRA1',
  SvtClass.EXTRA2: 'EXTRA2',
  SvtClass.uOlgaMarieFlareCollection: 'uOlgaMarieFlareCollection',
  SvtClass.uOlgaMarieAquaCollection: 'uOlgaMarieAquaCollection',
  SvtClass.uOlgaMarieGroundCollection: 'uOlgaMarieGroundCollection',
  SvtClass.uOlgaMarieStellarCollection: 'uOlgaMarieStellarCollection',
  SvtClass.grandSaber: 'grandSaber',
  SvtClass.grandArcher: 'grandArcher',
  SvtClass.grandLancer: 'grandLancer',
  SvtClass.grandRider: 'grandRider',
  SvtClass.grandCaster: 'grandCaster',
  SvtClass.grandAssassin: 'grandAssassin',
  SvtClass.grandBerserker: 'grandBerserker',
  SvtClass.beastAny: 'beastAny',
};

const _$CondTypeEnumMap = {
  CondType.unknown: 'unknown',
  CondType.none: 'none',
  CondType.questClear: 'questClear',
  CondType.itemGet: 'itemGet',
  CondType.useItemEternity: 'useItemEternity',
  CondType.useItemTime: 'useItemTime',
  CondType.useItemCount: 'useItemCount',
  CondType.svtLevel: 'svtLevel',
  CondType.svtLimit: 'svtLimit',
  CondType.svtGet: 'svtGet',
  CondType.svtFriendship: 'svtFriendship',
  CondType.svtGroup: 'svtGroup',
  CondType.event: 'event',
  CondType.date: 'date',
  CondType.weekday: 'weekday',
  CondType.purchaseQpShop: 'purchaseQpShop',
  CondType.purchaseStoneShop: 'purchaseStoneShop',
  CondType.warClear: 'warClear',
  CondType.flag: 'flag',
  CondType.svtCountStop: 'svtCountStop',
  CondType.birthDay: 'birthDay',
  CondType.eventEnd: 'eventEnd',
  CondType.svtEventJoin: 'svtEventJoin',
  CondType.missionConditionDetail: 'missionConditionDetail',
  CondType.eventMissionClear: 'eventMissionClear',
  CondType.eventMissionAchieve: 'eventMissionAchieve',
  CondType.questClearNum: 'questClearNum',
  CondType.notQuestGroupClear: 'notQuestGroupClear',
  CondType.raidAlive: 'raidAlive',
  CondType.raidDead: 'raidDead',
  CondType.raidDamage: 'raidDamage',
  CondType.questChallengeNum: 'questChallengeNum',
  CondType.masterMission: 'masterMission',
  CondType.questGroupClear: 'questGroupClear',
  CondType.superBossDamage: 'superBossDamage',
  CondType.superBossDamageAll: 'superBossDamageAll',
  CondType.purchaseShop: 'purchaseShop',
  CondType.questNotClear: 'questNotClear',
  CondType.notShopPurchase: 'notShopPurchase',
  CondType.notSvtGet: 'notSvtGet',
  CondType.notEventShopPurchase: 'notEventShopPurchase',
  CondType.svtHaving: 'svtHaving',
  CondType.notSvtHaving: 'notSvtHaving',
  CondType.questChallengeNumEqual: 'questChallengeNumEqual',
  CondType.questChallengeNumBelow: 'questChallengeNumBelow',
  CondType.questClearNumEqual: 'questClearNumEqual',
  CondType.questClearNumBelow: 'questClearNumBelow',
  CondType.questClearPhase: 'questClearPhase',
  CondType.notQuestClearPhase: 'notQuestClearPhase',
  CondType.eventPointGroupWin: 'eventPointGroupWin',
  CondType.eventNormaPointClear: 'eventNormaPointClear',
  CondType.questAvailable: 'questAvailable',
  CondType.questGroupAvailableNum: 'questGroupAvailableNum',
  CondType.eventNormaPointNotClear: 'eventNormaPointNotClear',
  CondType.notItemGet: 'notItemGet',
  CondType.costumeGet: 'costumeGet',
  CondType.questResetAvailable: 'questResetAvailable',
  CondType.svtGetBeforeEventEnd: 'svtGetBeforeEventEnd',
  CondType.questClearRaw: 'questClearRaw',
  CondType.questGroupClearRaw: 'questGroupClearRaw',
  CondType.eventGroupPointRatioInTerm: 'eventGroupPointRatioInTerm',
  CondType.eventGroupRankInTerm: 'eventGroupRankInTerm',
  CondType.notEventRaceQuestOrNotAllGroupGoal: 'notEventRaceQuestOrNotAllGroupGoal',
  CondType.eventGroupTotalWinEachPlayer: 'eventGroupTotalWinEachPlayer',
  CondType.eventScriptPlay: 'eventScriptPlay',
  CondType.svtCostumeReleased: 'svtCostumeReleased',
  CondType.questNotClearAnd: 'questNotClearAnd',
  CondType.svtRecoverd: 'svtRecoverd',
  CondType.shopReleased: 'shopReleased',
  CondType.eventPoint: 'eventPoint',
  CondType.eventRewardDispCount: 'eventRewardDispCount',
  CondType.equipWithTargetCostume: 'equipWithTargetCostume',
  CondType.raidGroupDead: 'raidGroupDead',
  CondType.notSvtGroup: 'notSvtGroup',
  CondType.notQuestResetAvailable: 'notQuestResetAvailable',
  CondType.notQuestClearRaw: 'notQuestClearRaw',
  CondType.notQuestGroupClearRaw: 'notQuestGroupClearRaw',
  CondType.notEventMissionClear: 'notEventMissionClear',
  CondType.notEventMissionAchieve: 'notEventMissionAchieve',
  CondType.notCostumeGet: 'notCostumeGet',
  CondType.notSvtCostumeReleased: 'notSvtCostumeReleased',
  CondType.notEventRaceQuestOrNotTargetRankGoal: 'notEventRaceQuestOrNotTargetRankGoal',
  CondType.playerGenderType: 'playerGenderType',
  CondType.shopGroupLimitNum: 'shopGroupLimitNum',
  CondType.eventGroupPoint: 'eventGroupPoint',
  CondType.eventGroupPointBelow: 'eventGroupPointBelow',
  CondType.eventTotalPoint: 'eventTotalPoint',
  CondType.eventTotalPointBelow: 'eventTotalPointBelow',
  CondType.eventValue: 'eventValue',
  CondType.eventValueBelow: 'eventValueBelow',
  CondType.eventFlag: 'eventFlag',
  CondType.eventStatus: 'eventStatus',
  CondType.notEventStatus: 'notEventStatus',
  CondType.forceFalse: 'forceFalse',
  CondType.svtHavingLimitMax: 'svtHavingLimitMax',
  CondType.eventPointBelow: 'eventPointBelow',
  CondType.svtEquipFriendshipHaving: 'svtEquipFriendshipHaving',
  CondType.movieNotDownload: 'movieNotDownload',
  CondType.multipleDate: 'multipleDate',
  CondType.svtFriendshipAbove: 'svtFriendshipAbove',
  CondType.svtFriendshipBelow: 'svtFriendshipBelow',
  CondType.movieDownloaded: 'movieDownloaded',
  CondType.routeSelect: 'routeSelect',
  CondType.notRouteSelect: 'notRouteSelect',
  CondType.limitCount: 'limitCount',
  CondType.limitCountAbove: 'limitCountAbove',
  CondType.limitCountBelow: 'limitCountBelow',
  CondType.badEndPlay: 'badEndPlay',
  CondType.commandCodeGet: 'commandCodeGet',
  CondType.notCommandCodeGet: 'notCommandCodeGet',
  CondType.allUsersBoxGachaCount: 'allUsersBoxGachaCount',
  CondType.totalTdLevel: 'totalTdLevel',
  CondType.totalTdLevelAbove: 'totalTdLevelAbove',
  CondType.totalTdLevelBelow: 'totalTdLevelBelow',
  CondType.commonRelease: 'commonRelease',
  CondType.battleResultWin: 'battleResultWin',
  CondType.battleResultLose: 'battleResultLose',
  CondType.eventValueEqual: 'eventValueEqual',
  CondType.boardGameTokenHaving: 'boardGameTokenHaving',
  CondType.boardGameTokenGroupHaving: 'boardGameTokenGroupHaving',
  CondType.eventFlagOn: 'eventFlagOn',
  CondType.eventFlagOff: 'eventFlagOff',
  CondType.questStatusFlagOn: 'questStatusFlagOn',
  CondType.questStatusFlagOff: 'questStatusFlagOff',
  CondType.eventValueNotEqual: 'eventValueNotEqual',
  CondType.limitCountMaxEqual: 'limitCountMaxEqual',
  CondType.limitCountMaxAbove: 'limitCountMaxAbove',
  CondType.limitCountMaxBelow: 'limitCountMaxBelow',
  CondType.boardGameTokenGetNum: 'boardGameTokenGetNum',
  CondType.battleLineWinAbove: 'battleLineWinAbove',
  CondType.battleLineLoseAbove: 'battleLineLoseAbove',
  CondType.battleLineContinueWin: 'battleLineContinueWin',
  CondType.battleLineContinueLose: 'battleLineContinueLose',
  CondType.battleLineContinueWinBelow: 'battleLineContinueWinBelow',
  CondType.battleLineContinueLoseBelow: 'battleLineContinueLoseBelow',
  CondType.battleGroupWinAvove: 'battleGroupWinAvove',
  CondType.battleGroupLoseAvove: 'battleGroupLoseAvove',
  CondType.svtLimitClassNum: 'svtLimitClassNum',
  CondType.overTimeLimitRaidAlive: 'overTimeLimitRaidAlive',
  CondType.onTimeLimitRaidDead: 'onTimeLimitRaidDead',
  CondType.onTimeLimitRaidDeadNum: 'onTimeLimitRaidDeadNum',
  CondType.raidBattleProgressAbove: 'raidBattleProgressAbove',
  CondType.svtEquipRarityLevelNum: 'svtEquipRarityLevelNum',
  CondType.latestMainScenarioWarClear: 'latestMainScenarioWarClear',
  CondType.eventMapValueContains: 'eventMapValueContains',
  CondType.resetBirthDay: 'resetBirthDay',
  CondType.shopFlagOn: 'shopFlagOn',
  CondType.shopFlagOff: 'shopFlagOff',
  CondType.purchaseValidShopGroup: 'purchaseValidShopGroup',
  CondType.svtLevelClassNum: 'svtLevelClassNum',
  CondType.svtLevelIdNum: 'svtLevelIdNum',
  CondType.limitCountImageEqual: 'limitCountImageEqual',
  CondType.limitCountImageAbove: 'limitCountImageAbove',
  CondType.limitCountImageBelow: 'limitCountImageBelow',
  CondType.eventTypeStartTimeToEndDate: 'eventTypeStartTimeToEndDate',
  CondType.existBoxGachaScriptReplaceGiftId: 'existBoxGachaScriptReplaceGiftId',
  CondType.notExistBoxGachaScriptReplaceGiftId: 'notExistBoxGachaScriptReplaceGiftId',
  CondType.limitedPeriodVoiceChangeTypeOn: 'limitedPeriodVoiceChangeTypeOn',
  CondType.startRandomMission: 'startRandomMission',
  CondType.randomMissionClearNum: 'randomMissionClearNum',
  CondType.progressValueEqual: 'progressValueEqual',
  CondType.progressValueAbove: 'progressValueAbove',
  CondType.progressValueBelow: 'progressValueBelow',
  CondType.randomMissionTotalClearNum: 'randomMissionTotalClearNum',
  CondType.weekdays: 'weekdays',
  CondType.eventFortificationRewardNum: 'eventFortificationRewardNum',
  CondType.questClearBeforeEventStart: 'questClearBeforeEventStart',
  CondType.notQuestClearBeforeEventStart: 'notQuestClearBeforeEventStart',
  CondType.eventTutorialFlagOn: 'eventTutorialFlagOn',
  CondType.eventTutorialFlagOff: 'eventTutorialFlagOff',
  CondType.eventSuperBossValueEqual: 'eventSuperBossValueEqual',
  CondType.notEventSuperBossValueEqual: 'notEventSuperBossValueEqual',
  CondType.allSvtTargetSkillLvNum: 'allSvtTargetSkillLvNum',
  CondType.superBossDamageAbove: 'superBossDamageAbove',
  CondType.superBossDamageBelow: 'superBossDamageBelow',
  CondType.eventMissionGroupAchieve: 'eventMissionGroupAchieve',
  CondType.svtFriendshipClassNumAbove: 'svtFriendshipClassNumAbove',
  CondType.notWarClear: 'notWarClear',
  CondType.svtSkillLvClassNumAbove: 'svtSkillLvClassNumAbove',
  CondType.svtClassLvUpCount: 'svtClassLvUpCount',
  CondType.svtClassSkillLvUpCount: 'svtClassSkillLvUpCount',
  CondType.svtClassLimitUpCount: 'svtClassLimitUpCount',
  CondType.svtClassFriendshipCount: 'svtClassFriendshipCount',
  CondType.completeHeelPortrait: 'completeHeelPortrait',
  CondType.notCompleteHeelPortrait: 'notCompleteHeelPortrait',
  CondType.classBoardSquareReleased: 'classBoardSquareReleased',
  CondType.svtLevelExchangeSvt: 'svtLevelExchangeSvt',
  CondType.svtLimitExchangeSvt: 'svtLimitExchangeSvt',
  CondType.skillLvExchangeSvt: 'skillLvExchangeSvt',
  CondType.svtFriendshipExchangeSvt: 'svtFriendshipExchangeSvt',
  CondType.exchangeSvt: 'exchangeSvt',
  CondType.raidDamageAbove: 'raidDamageAbove',
  CondType.raidDamageBelow: 'raidDamageBelow',
  CondType.raidGroupDamageAbove: 'raidGroupDamageAbove',
  CondType.raidGroupDamageBelow: 'raidGroupDamageBelow',
  CondType.raidDamageRateAbove: 'raidDamageRateAbove',
  CondType.raidDamageRateBelow: 'raidDamageRateBelow',
  CondType.raidDamageRateNotAbove: 'raidDamageRateNotAbove',
  CondType.raidDamageRateNotBelow: 'raidDamageRateNotBelow',
  CondType.raidGroupDamageRateAbove: 'raidGroupDamageRateAbove',
  CondType.raidGroupDamageRateBelow: 'raidGroupDamageRateBelow',
  CondType.raidGroupDamageRateNotAbove: 'raidGroupDamageRateNotAbove',
  CondType.raidGroupDamageRateNotBelow: 'raidGroupDamageRateNotBelow',
  CondType.notQuestGroupClearNum: 'notQuestGroupClearNum',
  CondType.raidGroupOpenAbove: 'raidGroupOpenAbove',
  CondType.raidGroupOpenBelow: 'raidGroupOpenBelow',
  CondType.treasureDeviceAccelerate: 'treasureDeviceAccelerate',
  CondType.playQuestPhase: 'playQuestPhase',
  CondType.notPlayQuestPhase: 'notPlayQuestPhase',
  CondType.eventStartToEnd: 'eventStartToEnd',
  CondType.commonValueAbove: 'commonValueAbove',
  CondType.commonValueBelow: 'commonValueBelow',
  CondType.commonValueEqual: 'commonValueEqual',
  CondType.elapsedTimeAfterQuestClear: 'elapsedTimeAfterQuestClear',
  CondType.withStartingMember: 'withStartingMember',
  CondType.latestQuestPhaseEqual: 'latestQuestPhaseEqual',
  CondType.notLatestQuestPhaseEqual: 'notLatestQuestPhaseEqual',
  CondType.purchaseShopNum: 'purchaseShopNum',
  CondType.eventTradeTotalNum: 'eventTradeTotalNum',
  CondType.limitedMissionAchieveNumBelow: 'limitedMissionAchieveNumBelow',
  CondType.limitedMissionAchieveNumAbove: 'limitedMissionAchieveNumAbove',
  CondType.notSvtVoicePlayed: 'notSvtVoicePlayed',
  CondType.battlePointAbove: 'battlePointAbove',
  CondType.battlePointBelow: 'battlePointBelow',
  CondType.beforeSpecifiedDate: 'beforeSpecifiedDate',
  CondType.notHaveChargeStone: 'notHaveChargeStone',
  CondType.haveChargeStone: 'haveChargeStone',
  CondType.battleFunctionTargetAllIndividuality: 'battleFunctionTargetAllIndividuality',
  CondType.battleFunctionTargetOneIndividuality: 'battleFunctionTargetOneIndividuality',
  CondType.beforeQuestClearTime: 'beforeQuestClearTime',
  CondType.afterQuestClearTime: 'afterQuestClearTime',
  CondType.notBattleFunctionTargetAllIndividuality: 'notBattleFunctionTargetAllIndividuality',
  CondType.notBattleFunctionTargetOneIndividuality: 'notBattleFunctionTargetOneIndividuality',
  CondType.eventScriptNotPlay: 'eventScriptNotPlay',
  CondType.eventScriptFlag: 'eventScriptFlag',
  CondType.imagePartsGroup: 'imagePartsGroup',
  CondType.userLevelAbove: 'userLevelAbove',
  CondType.userLevelBelow: 'userLevelBelow',
  CondType.userLevelEqual: 'userLevelEqual',
  CondType.highestWaveAbove: 'highestWaveAbove',
  CondType.highestWaveBelow: 'highestWaveBelow',
  CondType.privilegeValid: 'privilegeValid',
  CondType.privilegeInvalid: 'privilegeInvalid',
  CondType.battleActionOpponentIndividuality: 'battleActionOpponentIndividuality',
  CondType.notBattleActionOpponentIndividuality: 'notBattleActionOpponentIndividuality',
  CondType.treasureDeviceOfSelectedCard: 'treasureDeviceOfSelectedCard',
  CondType.battleSvtFriendshipAbove: 'battleSvtFriendshipAbove',
  CondType.battleSvtFriendshipBelow: 'battleSvtFriendshipBelow',
  CondType.elapsedTimeAfterSvtGet: 'elapsedTimeAfterSvtGet',
  CondType.notElapsedTimeAfterQuestClear: 'notElapsedTimeAfterQuestClear',
  CondType.notElapsedTimeAfterSvtGet: 'notElapsedTimeAfterSvtGet',
  CondType.grandSvtSet: 'grandSvtSet',
  CondType.playedMovie: 'playedMovie',
  CondType.notPlayedMovie: 'notPlayedMovie',
  CondType.notShopGroupLimitNum: 'notShopGroupLimitNum',
  CondType.equipGet: 'equipGet',
  CondType.notEquipGet: 'notEquipGet',
};
