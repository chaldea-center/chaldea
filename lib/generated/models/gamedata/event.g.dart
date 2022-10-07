// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map json) => Event(
      id: json['id'] as int,
      type: $enumDecodeNullable(_$EventTypeEnumMap, json['type']) ??
          EventType.none,
      name: json['name'] as String,
      shortName: json['shortName'] as String? ?? "",
      detail: json['detail'] as String,
      noticeBanner: json['noticeBanner'] as String?,
      banner: json['banner'] as String?,
      icon: json['icon'] as String?,
      bannerPriority: json['bannerPriority'] as int? ?? 0,
      noticeAt: json['noticeAt'] as int,
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
      finishedAt: json['finishedAt'] as int,
      materialOpenedAt: json['materialOpenedAt'] as int,
      warIds:
          (json['warIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      shop: (json['shop'] as List<dynamic>?)
              ?.map(
                  (e) => NiceShop.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      rewards: (json['rewards'] as List<dynamic>?)
              ?.map((e) =>
                  EventReward.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      rewardScenes: (json['rewardScenes'] as List<dynamic>?)
              ?.map((e) => EventRewardScene.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      pointGroups: (json['pointGroups'] as List<dynamic>?)
              ?.map((e) =>
                  EventPointGroup.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      pointBuffs: (json['pointBuffs'] as List<dynamic>?)
              ?.map((e) =>
                  EventPointBuff.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      missions: (json['missions'] as List<dynamic>?)
              ?.map((e) =>
                  EventMission.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      towers: (json['towers'] as List<dynamic>?)
              ?.map((e) =>
                  EventTower.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      lotteries: (json['lotteries'] as List<dynamic>?)
              ?.map((e) =>
                  EventLottery.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      treasureBoxes: (json['treasureBoxes'] as List<dynamic>?)
              ?.map((e) => EventTreasureBox.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      recipes: (json['recipes'] as List<dynamic>?)
              ?.map((e) =>
                  EventRecipe.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      bulletinBoards: (json['bulletinBoards'] as List<dynamic>?)
              ?.map((e) => EventBulletinBoard.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      digging: json['digging'] == null
          ? null
          : EventDigging.fromJson(
              Map<String, dynamic>.from(json['digging'] as Map)),
      cooltime: json['cooltime'] == null
          ? null
          : EventCooltime.fromJson(
              Map<String, dynamic>.from(json['cooltime'] as Map)),
      campaigns: (json['campaigns'] as List<dynamic>?)
              ?.map((e) =>
                  EventCampaign.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      campaignQuests: (json['campaignQuests'] as List<dynamic>?)
              ?.map((e) =>
                  EventQuest.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      voicePlays: (json['voicePlays'] as List<dynamic>?)
              ?.map((e) =>
                  EventVoicePlay.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      voices: (json['voices'] as List<dynamic>?)
              ?.map((e) =>
                  VoiceGroup.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

const _$EventTypeEnumMap = {
  EventType.none: 'none',
  EventType.raidBoss: 'raidBoss',
  EventType.pvp: 'pvp',
  EventType.point: 'point',
  EventType.loginBonus: 'loginBonus',
  EventType.combineCampaign: 'combineCampaign',
  EventType.shop: 'shop',
  EventType.questCampaign: 'questCampaign',
  EventType.bank: 'bank',
  EventType.serialCampaign: 'serialCampaign',
  EventType.loginCampaign: 'loginCampaign',
  EventType.loginCampaignRepeat: 'loginCampaignRepeat',
  EventType.eventQuest: 'eventQuest',
  EventType.svtequipCombineCampaign: 'svtequipCombineCampaign',
  EventType.terminalBanner: 'terminalBanner',
  EventType.boxGacha: 'boxGacha',
  EventType.boxGachaPoint: 'boxGachaPoint',
  EventType.loginCampaignStrict: 'loginCampaignStrict',
  EventType.totalLogin: 'totalLogin',
  EventType.comebackCampaign: 'comebackCampaign',
  EventType.locationCampaign: 'locationCampaign',
  EventType.warBoard: 'warBoard',
  EventType.combineCosutumeItem: 'combineCosutumeItem',
  EventType.myroomMultipleViewCampaign: 'myroomMultipleViewCampaign',
  EventType.interludeCampaign: 'interludeCampaign',
};

MasterMission _$MasterMissionFromJson(Map json) => MasterMission(
      id: json['id'] as int,
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
      closedAt: json['closedAt'] as int,
      missions: (json['missions'] as List<dynamic>)
          .map(
              (e) => EventMission.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      quests: (json['quests'] as List<dynamic>?)
              ?.map((e) =>
                  BasicQuest.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

ItemSet _$ItemSetFromJson(Map json) => ItemSet(
      id: json['id'] as int,
      purchaseType: $enumDecode(_$PurchaseTypeEnumMap, json['purchaseType']),
      targetId: json['targetId'] as int,
      setNum: json['setNum'] as int,
    );

const _$PurchaseTypeEnumMap = {
  PurchaseType.none: 'none',
  PurchaseType.item: 'item',
  PurchaseType.equip: 'equip',
  PurchaseType.friendGacha: 'friendGacha',
  PurchaseType.servant: 'servant',
  PurchaseType.setItem: 'setItem',
  PurchaseType.quest: 'quest',
  PurchaseType.eventShop: 'eventShop',
  PurchaseType.eventSvtGet: 'eventSvtGet',
  PurchaseType.manaShop: 'manaShop',
  PurchaseType.storageSvt: 'storageSvt',
  PurchaseType.storageSvtequip: 'storageSvtequip',
  PurchaseType.bgm: 'bgm',
  PurchaseType.costumeRelease: 'costumeRelease',
  PurchaseType.bgmRelease: 'bgmRelease',
  PurchaseType.lotteryShop: 'lotteryShop',
  PurchaseType.eventFactory: 'eventFactory',
  PurchaseType.itemAsPresent: 'itemAsPresent',
  PurchaseType.commandCode: 'commandCode',
  PurchaseType.gift: 'gift',
  PurchaseType.eventSvtJoin: 'eventSvtJoin',
  PurchaseType.assist: 'assist',
  PurchaseType.kiaraPunisherReset: 'kiaraPunisherReset',
};

NiceShop _$NiceShopFromJson(Map json) => NiceShop(
      id: json['id'] as int,
      shopType: $enumDecodeNullable(_$ShopTypeEnumMap, json['shopType']) ??
          ShopType.eventItem,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) =>
                  ShopRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      slot: json['slot'] as int,
      priority: json['priority'] as int,
      name: json['name'] as String,
      infoMessage: json['infoMessage'] as String? ?? "",
      payType: $enumDecode(_$PayTypeEnumMap, json['payType']),
      cost: ItemAmount.fromJson(Map<String, dynamic>.from(json['cost'] as Map)),
      purchaseType: $enumDecode(_$PurchaseTypeEnumMap, json['purchaseType']),
      targetIds: (json['targetIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      itemSet: (json['itemSet'] as List<dynamic>?)
              ?.map(
                  (e) => ItemSet.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      setNum: json['setNum'] as int? ?? 1,
      limitNum: json['limitNum'] as int,
      defaultLv: json['defaultLv'] as int? ?? 0,
      defaultLimitCount: json['defaultLimitCount'] as int? ?? 0,
      scriptName: json['scriptName'] as String?,
      scriptId: json['scriptId'] as String?,
      script: json['script'] as String?,
    );

const _$ShopTypeEnumMap = {
  ShopType.none: 'none',
  ShopType.eventItem: 'eventItem',
  ShopType.mana: 'mana',
  ShopType.rarePri: 'rarePri',
  ShopType.svtStorage: 'svtStorage',
  ShopType.svtEquipStorage: 'svtEquipStorage',
  ShopType.stoneFragments: 'stoneFragments',
  ShopType.svtAnonymous: 'svtAnonymous',
  ShopType.bgm: 'bgm',
  ShopType.limitMaterial: 'limitMaterial',
  ShopType.grailFragments: 'grailFragments',
  ShopType.svtCostume: 'svtCostume',
  ShopType.startUpSummon: 'startUpSummon',
  ShopType.shop13: 'shop13',
  ShopType.tradeAp: 'tradeAp',
};

const _$PayTypeEnumMap = {
  PayType.stone: 'stone',
  PayType.qp: 'qp',
  PayType.friendPoint: 'friendPoint',
  PayType.mana: 'mana',
  PayType.ticket: 'ticket',
  PayType.eventItem: 'eventItem',
  PayType.chargeStone: 'chargeStone',
  PayType.stoneFragments: 'stoneFragments',
  PayType.anonymous: 'anonymous',
  PayType.rarePri: 'rarePri',
  PayType.item: 'item',
  PayType.grailFragments: 'grailFragments',
  PayType.free: 'free',
  PayType.commonConsume: 'commonConsume',
};

ShopRelease _$ShopReleaseFromJson(Map json) => ShopRelease(
      condValues: (json['condValues'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      condType: toEnumCondType(json['condType'] as Object),
      condNum: json['condNum'] as int,
      priority: json['priority'] as int? ?? 0,
      isClosedDisp: json['isClosedDisp'] as bool,
      closedMessage: json['closedMessage'] as String,
      closedItemName: json['closedItemName'] as String,
    );

EventReward _$EventRewardFromJson(Map json) => EventReward(
      groupId: json['groupId'] as int,
      point: json['point'] as int,
      gifts: (json['gifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

EventPointGroup _$EventPointGroupFromJson(Map json) => EventPointGroup(
      groupId: json['groupId'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );

EventPointBuff _$EventPointBuffFromJson(Map json) => EventPointBuff(
      id: json['id'] as int,
      funcIds:
          (json['funcIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      groupId: json['groupId'] as int? ?? 0,
      eventPoint: json['eventPoint'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
      background: $enumDecode(_$ItemBGTypeEnumMap, json['background']),
      value: json['value'] as int,
    );

const _$ItemBGTypeEnumMap = {
  ItemBGType.zero: 'zero',
  ItemBGType.bronze: 'bronze',
  ItemBGType.silver: 'silver',
  ItemBGType.gold: 'gold',
  ItemBGType.questClearQPReward: 'questClearQPReward',
};

EventMissionConditionDetail _$EventMissionConditionDetailFromJson(Map json) =>
    EventMissionConditionDetail(
      id: json['id'] as int,
      missionTargetId: json['missionTargetId'] as int,
      missionCondType: json['missionCondType'] as int,
      logicType: json['logicType'] as int,
      targetIds: (json['targetIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      addTargetIds: (json['addTargetIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      targetQuestIndividualities:
          (json['targetQuestIndividualities'] as List<dynamic>?)
                  ?.map((e) =>
                      NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList() ??
              const [],
      conditionLinkType: $enumDecode(
          _$DetailMissionCondLinkTypeEnumMap, json['conditionLinkType']),
      targetEventIds: (json['targetEventIds'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
    );

const _$DetailMissionCondLinkTypeEnumMap = {
  DetailMissionCondLinkType.eventStart: 'eventStart',
  DetailMissionCondLinkType.missionStart: 'missionStart',
  DetailMissionCondLinkType.masterMissionStart: 'masterMissionStart',
  DetailMissionCondLinkType.randomMissionStart: 'randomMissionStart',
};

EventMissionCondition _$EventMissionConditionFromJson(Map json) =>
    EventMissionCondition(
      id: json['id'] as int,
      missionProgressType: $enumDecode(
          _$MissionProgressTypeEnumMap, json['missionProgressType']),
      priority: json['priority'] as int? ?? 0,
      condGroup: json['condGroup'] as int,
      condType: toEnumCondType(json['condType'] as Object),
      targetIds:
          (json['targetIds'] as List<dynamic>).map((e) => e as int).toList(),
      targetNum: json['targetNum'] as int,
      conditionMessage: json['conditionMessage'] as String,
      closedMessage: json['closedMessage'] as String? ?? "",
      flag: json['flag'] as int? ?? 0,
      detail: json['detail'] == null
          ? null
          : EventMissionConditionDetail.fromJson(
              Map<String, dynamic>.from(json['detail'] as Map)),
    );

const _$MissionProgressTypeEnumMap = {
  MissionProgressType.none: 'none',
  MissionProgressType.regist: 'regist',
  MissionProgressType.openCondition: 'openCondition',
  MissionProgressType.start: 'start',
  MissionProgressType.clear: 'clear',
  MissionProgressType.achieve: 'achieve',
};

EventMission _$EventMissionFromJson(Map json) => EventMission(
      id: json['id'] as int,
      type: $enumDecodeNullable(_$MissionTypeEnumMap, json['type']) ??
          MissionType.event,
      dispNo: json['dispNo'] as int,
      name: json['name'] as String,
      startedAt: json['startedAt'] as int? ?? 0,
      endedAt: json['endedAt'] as int? ?? 0,
      closedAt: json['closedAt'] as int? ?? 0,
      rewardType: $enumDecode(_$MissionRewardTypeEnumMap, json['rewardType']),
      gifts: (json['gifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      bannerGroup: json['bannerGroup'] as int? ?? 0,
      priority: json['priority'] as int? ?? 0,
      conds: (json['conds'] as List<dynamic>?)
              ?.map((e) => EventMissionCondition.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

const _$MissionTypeEnumMap = {
  MissionType.none: 'none',
  MissionType.event: 'event',
  MissionType.weekly: 'weekly',
  MissionType.daily: 'daily',
  MissionType.extra: 'extra',
  MissionType.limited: 'limited',
  MissionType.complete: 'complete',
  MissionType.random: 'random',
};

const _$MissionRewardTypeEnumMap = {
  MissionRewardType.gift: 'gift',
  MissionRewardType.extra: 'extra',
  MissionRewardType.set: 'set',
};

EventTowerReward _$EventTowerRewardFromJson(Map json) => EventTowerReward(
      floor: json['floor'] as int,
      gifts: (json['gifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

EventTower _$EventTowerFromJson(Map json) => EventTower(
      towerId: json['towerId'] as int,
      name: json['name'] as String,
      rewards: (json['rewards'] as List<dynamic>)
          .map((e) =>
              EventTowerReward.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

EventLotteryBox _$EventLotteryBoxFromJson(Map json) => EventLotteryBox(
      boxIndex: json['boxIndex'] as int? ?? 0,
      talkId: json['talkId'] as int? ?? 0,
      no: json['no'] as int,
      type: json['type'] as int? ?? 1,
      gifts: (json['gifts'] as List<dynamic>?)
              ?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      maxNum: json['maxNum'] as int,
      isRare: json['isRare'] as bool? ?? false,
    );

EventLottery _$EventLotteryFromJson(Map json) => EventLottery(
      id: json['id'] as int,
      slot: json['slot'] as int? ?? 0,
      payType: $enumDecode(_$PayTypeEnumMap, json['payType']),
      cost: ItemAmount.fromJson(Map<String, dynamic>.from(json['cost'] as Map)),
      priority: json['priority'] as int,
      limited: json['limited'] as bool,
      boxes: (json['boxes'] as List<dynamic>)
          .map((e) =>
              EventLotteryBox.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      talks: (json['talks'] as List<dynamic>?)
              ?.map((e) => EventLotteryTalk.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

EventLotteryTalk _$EventLotteryTalkFromJson(Map json) => EventLotteryTalk(
      talkId: json['talkId'] as int,
      no: json['no'] as int,
      guideImageId: json['guideImageId'] as int,
      beforeVoiceLines: (json['beforeVoiceLines'] as List<dynamic>?)
              ?.map((e) =>
                  VoiceLine.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      afterVoiceLines: (json['afterVoiceLines'] as List<dynamic>?)
              ?.map((e) =>
                  VoiceLine.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      isRare: json['isRare'] as bool,
    );

CommonConsume _$CommonConsumeFromJson(Map json) => CommonConsume(
      id: json['id'] as int,
      priority: json['priority'] as int,
      type: $enumDecode(_$CommonConsumeTypeEnumMap, json['type']),
      objectId: json['objectId'] as int,
      num: json['num'] as int,
    );

const _$CommonConsumeTypeEnumMap = {
  CommonConsumeType.item: 'item',
  CommonConsumeType.ap: 'ap',
};

EventTreasureBoxGift _$EventTreasureBoxGiftFromJson(Map json) =>
    EventTreasureBoxGift(
      id: json['id'] as int,
      idx: json['idx'] as int,
      gifts: (json['gifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      collateralUpperLimit: json['collateralUpperLimit'] as int,
    );

EventTreasureBox _$EventTreasureBoxFromJson(Map json) => EventTreasureBox(
      slot: json['slot'] as int,
      id: json['id'] as int,
      idx: json['idx'] as int,
      treasureBoxGifts: (json['treasureBoxGifts'] as List<dynamic>)
          .map((e) => EventTreasureBoxGift.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      maxDrawNumOnce: json['maxDrawNumOnce'] as int,
      extraGifts: (json['extraGifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      consumes: (json['consumes'] as List<dynamic>?)
              ?.map((e) =>
                  CommonConsume.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

EventRewardSceneGuide _$EventRewardSceneGuideFromJson(Map json) =>
    EventRewardSceneGuide(
      imageId: json['imageId'] as int,
      limitCount: json['limitCount'] as int? ?? 0,
      image: json['image'] as String,
      faceId: json['faceId'] as int? ?? 0,
      displayName: json['displayName'] as String?,
      weight: json['weight'] as int?,
      unselectedMax: json['unselectedMax'] as int?,
    );

EventRewardScene _$EventRewardSceneFromJson(Map json) => EventRewardScene(
      slot: json['slot'] as int,
      groupId: json['groupId'] as int,
      type: json['type'] as int,
      guides: (json['guides'] as List<dynamic>?)
              ?.map((e) => EventRewardSceneGuide.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      tabOnImage: json['tabOnImage'] as String,
      tabOffImage: json['tabOffImage'] as String,
      image: json['image'] as String?,
      bg: json['bg'] as String,
      bgm: BgmEntity.fromJson(Map<String, dynamic>.from(json['bgm'] as Map)),
      afterBgm: BgmEntity.fromJson(
          Map<String, dynamic>.from(json['afterBgm'] as Map)),
      flags: (json['flags'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$EventRewardSceneFlagEnumMap, e))
              .toList() ??
          const [],
    );

const _$EventRewardSceneFlagEnumMap = {
  EventRewardSceneFlag.npcGuide: 'npcGuide',
  EventRewardSceneFlag.isChangeSvtByChangedTab: 'isChangeSvtByChangedTab',
  EventRewardSceneFlag.isHideTab: 'isHideTab',
};

EventVoicePlay _$EventVoicePlayFromJson(Map json) => EventVoicePlay(
      slot: json['slot'] as int,
      idx: json['idx'] as int,
      guideImageId: json['guideImageId'] as int,
      voiceLines: (json['voiceLines'] as List<dynamic>?)
              ?.map((e) =>
                  VoiceLine.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      confirmVoiceLines: (json['confirmVoiceLines'] as List<dynamic>?)
              ?.map((e) =>
                  VoiceLine.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      condType: toEnumCondType(json['condType'] as Object),
      condValue: json['condValue'] as int,
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
    );

EventDigging _$EventDiggingFromJson(Map json) => EventDigging(
      sizeX: json['sizeX'] as int,
      sizeY: json['sizeY'] as int,
      bgImage: json['bgImage'] as String,
      eventPointItem: Item.fromJson(
          Map<String, dynamic>.from(json['eventPointItem'] as Map)),
      resettableDiggedNum: json['resettableDiggedNum'] as int,
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((e) => EventDiggingBlock.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      rewards: (json['rewards'] as List<dynamic>?)
              ?.map((e) => EventDiggingReward.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

EventDiggingBlock _$EventDiggingBlockFromJson(Map json) => EventDiggingBlock(
      id: json['id'] as int,
      image: json['image'] as String,
      consumes: (json['consumes'] as List<dynamic>?)
              ?.map((e) =>
                  CommonConsume.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      objectId: json['objectId'] as int,
      diggingEventPoint: json['diggingEventPoint'] as int,
      blockNum: json['blockNum'] as int,
    );

EventDiggingReward _$EventDiggingRewardFromJson(Map json) => EventDiggingReward(
      id: json['id'] as int,
      gifts: (json['gifts'] as List<dynamic>?)
              ?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      rewardSize: json['rewardSize'] as int,
    );

EventCooltimeReward _$EventCooltimeRewardFromJson(Map json) =>
    EventCooltimeReward(
      spotId: json['spotId'] as int,
      lv: json['lv'] as int,
      name: json['name'] as String,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) =>
                  CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      cooltime: json['cooltime'] as int,
      addEventPointRate: json['addEventPointRate'] as int,
      gifts: (json['gifts'] as List<dynamic>)
          .map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      upperLimitGiftNum: json['upperLimitGiftNum'] as int,
    );

EventCooltime _$EventCooltimeFromJson(Map json) => EventCooltime(
      rewards: (json['rewards'] as List<dynamic>?)
              ?.map((e) => EventCooltimeReward.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

EventRecipeGift _$EventRecipeGiftFromJson(Map json) => EventRecipeGift(
      idx: json['idx'] as int,
      displayOrder: json['displayOrder'] as int,
      topIconId: json['topIconId'] as int? ?? 0,
      gifts: (json['gifts'] as List<dynamic>?)
              ?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

EventRecipe _$EventRecipeFromJson(Map json) => EventRecipe(
      id: json['id'] as int,
      icon: json['icon'] as String,
      name: json['name'] as String,
      maxNum: json['maxNum'] as int,
      eventPointItem: Item.fromJson(
          Map<String, dynamic>.from(json['eventPointItem'] as Map)),
      eventPointNum: json['eventPointNum'] as int,
      consumes: (json['consumes'] as List<dynamic>?)
              ?.map((e) =>
                  CommonConsume.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) =>
                  CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      closedMessage: json['closedMessage'] as String? ?? '',
      recipeGifts: (json['recipeGifts'] as List<dynamic>?)
              ?.map((e) =>
                  EventRecipeGift.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

EventBulletinBoard _$EventBulletinBoardFromJson(Map json) => EventBulletinBoard(
      bulletinBoardId: json['bulletinBoardId'] as int,
      message: json['message'] as String,
      probability: json['probability'] as int?,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => EventBulletinBoardRelease.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

EventBulletinBoardRelease _$EventBulletinBoardReleaseFromJson(Map json) =>
    EventBulletinBoardRelease(
      condGroup: json['condGroup'] as int,
      condType: toEnumCondType(json['condType'] as Object),
      condTargetId: json['condTargetId'] as int,
      condNum: json['condNum'] as int,
    );

EventCampaign _$EventCampaignFromJson(Map json) => EventCampaign(
      targetIds: (json['targetIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
      warIds:
          (json['warIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      target:
          $enumDecodeNullable(_$CombineAdjustTargetEnumMap, json['target']) ??
              CombineAdjustTarget.none,
      idx: json['idx'] as int? ?? 0,
      value: json['value'] as int,
      calcType: $enumDecode(_$EventCombineCalcEnumMap, json['calcType']),
    );

const _$CombineAdjustTargetEnumMap = {
  CombineAdjustTarget.none: 'none',
  CombineAdjustTarget.combineQp: 'combineQp',
  CombineAdjustTarget.combineExp: 'combineExp',
  CombineAdjustTarget.activeSkill: 'activeSkill',
  CombineAdjustTarget.largeSuccess: 'largeSuccess',
  CombineAdjustTarget.superSuccess: 'superSuccess',
  CombineAdjustTarget.limitQp: 'limitQp',
  CombineAdjustTarget.limitItem: 'limitItem',
  CombineAdjustTarget.skillQp: 'skillQp',
  CombineAdjustTarget.skillItem: 'skillItem',
  CombineAdjustTarget.treasureDeviceQp: 'treasureDeviceQp',
  CombineAdjustTarget.treasureDeviceItem: 'treasureDeviceItem',
  CombineAdjustTarget.questAp: 'questAp',
  CombineAdjustTarget.questExp: 'questExp',
  CombineAdjustTarget.questQp: 'questQp',
  CombineAdjustTarget.questDrop: 'questDrop',
  CombineAdjustTarget.svtequipCombineQp: 'svtequipCombineQp',
  CombineAdjustTarget.svtequipCombineExp: 'svtequipCombineExp',
  CombineAdjustTarget.svtequipLargeSuccess: 'svtequipLargeSuccess',
  CombineAdjustTarget.svtequipSuperSuccess: 'svtequipSuperSuccess',
  CombineAdjustTarget.questEventPoint: 'questEventPoint',
  CombineAdjustTarget.enemySvtClassPickUp: 'enemySvtClassPickUp',
  CombineAdjustTarget.eventEachDropNum: 'eventEachDropNum',
  CombineAdjustTarget.eventEachDropRate: 'eventEachDropRate',
  CombineAdjustTarget.questFp: 'questFp',
  CombineAdjustTarget.questApFirstTime: 'questApFirstTime',
  CombineAdjustTarget.dailyDropUp: 'dailyDropUp',
  CombineAdjustTarget.exchangeSvtCombineExp: 'exchangeSvtCombineExp',
  CombineAdjustTarget.questUseContinueItem: 'questUseContinueItem',
  CombineAdjustTarget.friendPointGachaFreeDrawNum:
      'friendPointGachaFreeDrawNum',
  CombineAdjustTarget.questUseFriendshipUpItem: 'questUseFriendshipUpItem',
  CombineAdjustTarget.questFriendship: 'questFriendship',
};

const _$EventCombineCalcEnumMap = {
  EventCombineCalc.addition: 'addition',
  EventCombineCalc.multiplication: 'multiplication',
  EventCombineCalc.fixedValue: 'fixedValue',
};

EventQuest _$EventQuestFromJson(Map json) => EventQuest(
      questId: json['questId'] as int,
    );
