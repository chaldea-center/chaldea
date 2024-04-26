// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map json) => Event(
      id: (json['id'] as num).toInt(),
      type: $enumDecodeNullable(_$EventTypeEnumMap, json['type']) ?? EventType.none,
      name: json['name'] as String,
      shortName: json['shortName'] as String? ?? "",
      detail: json['detail'] as String? ?? "",
      noticeBanner: json['noticeBanner'] as String?,
      banner: json['banner'] as String?,
      icon: json['icon'] as String?,
      bannerPriority: (json['bannerPriority'] as num?)?.toInt() ?? 0,
      noticeAt: (json['noticeAt'] as num?)?.toInt(),
      startedAt: (json['startedAt'] as num).toInt(),
      endedAt: (json['endedAt'] as num).toInt(),
      finishedAt: (json['finishedAt'] as num?)?.toInt(),
      warIds: (json['warIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      eventAdds: (json['eventAdds'] as List<dynamic>?)
              ?.map((e) => EventAdd.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      svts: (json['svts'] as List<dynamic>?)
              ?.map((e) => EventSvt.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      shop: (json['shop'] as List<dynamic>?)
              ?.map((e) => NiceShop.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      pointRewards: (json['rewards'] as List<dynamic>?)
              ?.map((e) => EventPointReward.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      rewardScenes: (json['rewardScenes'] as List<dynamic>?)
              ?.map((e) => EventRewardScene.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      pointGroups: (json['pointGroups'] as List<dynamic>?)
              ?.map((e) => EventPointGroup.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      pointBuffs: (json['pointBuffs'] as List<dynamic>?)
              ?.map((e) => EventPointBuff.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      pointActivities: (json['pointActivities'] as List<dynamic>?)
              ?.map((e) => EventPointActivity.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      missions: (json['missions'] as List<dynamic>?)
              ?.map((e) => EventMission.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      randomMissions: (json['randomMissions'] as List<dynamic>?)
              ?.map((e) => EventRandomMission.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      missionGroups: (json['missionGroups'] as List<dynamic>?)
              ?.map((e) => NiceEventMissionGroup.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      towers: (json['towers'] as List<dynamic>?)
              ?.map((e) => EventTower.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      lotteries: (json['lotteries'] as List<dynamic>?)
              ?.map((e) => EventLottery.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      warBoards: (json['warBoards'] as List<dynamic>?)
              ?.map((e) => WarBoard.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      treasureBoxes: (json['treasureBoxes'] as List<dynamic>?)
              ?.map((e) => EventTreasureBox.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      recipes: (json['recipes'] as List<dynamic>?)
              ?.map((e) => EventRecipe.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      bulletinBoards: (json['bulletinBoards'] as List<dynamic>?)
              ?.map((e) => EventBulletinBoard.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      digging:
          json['digging'] == null ? null : EventDigging.fromJson(Map<String, dynamic>.from(json['digging'] as Map)),
      cooltime:
          json['cooltime'] == null ? null : EventCooltime.fromJson(Map<String, dynamic>.from(json['cooltime'] as Map)),
      fortifications: (json['fortifications'] as List<dynamic>?)
              ?.map((e) => EventFortification.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      campaigns: (json['campaigns'] as List<dynamic>?)
              ?.map((e) => EventCampaign.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      campaignQuests: (json['campaignQuests'] as List<dynamic>?)
              ?.map((e) => EventQuest.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      commandAssists: (json['commandAssists'] as List<dynamic>?)
              ?.map((e) => EventCommandAssist.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      heelPortraits: (json['heelPortraits'] as List<dynamic>?)
              ?.map((e) => HeelPortrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      murals: (json['murals'] as List<dynamic>?)
              ?.map((e) => EventMural.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      voicePlays: (json['voicePlays'] as List<dynamic>?)
              ?.map((e) => EventVoicePlay.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      voices: (json['voices'] as List<dynamic>?)
              ?.map((e) => VoiceGroup.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$EventTypeEnumMap[instance.type]!,
      'name': instance.name,
      'detail': instance.detail,
      'noticeBanner': instance.noticeBanner,
      'banner': instance.banner,
      'icon': instance.icon,
      'bannerPriority': instance.bannerPriority,
      'noticeAt': instance.noticeAt,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
      'finishedAt': instance.finishedAt,
      'eventAdds': instance.eventAdds.map((e) => e.toJson()).toList(),
      'svts': instance.svts.map((e) => e.toJson()).toList(),
      'shop': instance.shop.map((e) => e.toJson()).toList(),
      'rewardScenes': instance.rewardScenes.map((e) => e.toJson()).toList(),
      'rewards': instance.pointRewards.map((e) => e.toJson()).toList(),
      'pointGroups': instance.pointGroups.map((e) => e.toJson()).toList(),
      'pointBuffs': instance.pointBuffs.map((e) => e.toJson()).toList(),
      'pointActivities': instance.pointActivities.map((e) => e.toJson()).toList(),
      'missions': instance.missions.map((e) => e.toJson()).toList(),
      'randomMissions': instance.randomMissions.map((e) => e.toJson()).toList(),
      'missionGroups': instance.missionGroups.map((e) => e.toJson()).toList(),
      'towers': instance.towers.map((e) => e.toJson()).toList(),
      'lotteries': instance.lotteries.map((e) => e.toJson()).toList(),
      'warBoards': instance.warBoards.map((e) => e.toJson()).toList(),
      'treasureBoxes': instance.treasureBoxes.map((e) => e.toJson()).toList(),
      'recipes': instance.recipes.map((e) => e.toJson()).toList(),
      'bulletinBoards': instance.bulletinBoards.map((e) => e.toJson()).toList(),
      'digging': instance.digging?.toJson(),
      'cooltime': instance.cooltime?.toJson(),
      'fortifications': instance.fortifications.map((e) => e.toJson()).toList(),
      'campaigns': instance.campaigns.map((e) => e.toJson()).toList(),
      'campaignQuests': instance.campaignQuests.map((e) => e.toJson()).toList(),
      'commandAssists': instance.commandAssists.map((e) => e.toJson()).toList(),
      'heelPortraits': instance.heelPortraits.map((e) => e.toJson()).toList(),
      'murals': instance.murals.map((e) => e.toJson()).toList(),
      'voicePlays': instance.voicePlays.map((e) => e.toJson()).toList(),
      'voices': instance.voices.map((e) => e.toJson()).toList(),
      'warIds': instance.warIds,
      'shortName': instance.shortName,
    };

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
  EventType.comebackCampaign2: 'comebackCampaign2',
  EventType.warBoard: 'warBoard',
  EventType.combineCosutumeItem: 'combineCosutumeItem',
  EventType.myroomMultipleViewCampaign: 'myroomMultipleViewCampaign',
  EventType.interludeCampaign: 'interludeCampaign',
  EventType.myroomPhotoCampaign: 'myroomPhotoCampaign',
  EventType.fortuneCampaign: 'fortuneCampaign',
  EventType.mcCampaign: 'mcCampaign',
};

EventAdd _$EventAddFromJson(Map json) => EventAdd(
      overwriteType:
          $enumDecodeNullable(_$EventOverwriteTypeEnumMap, json['overwriteType']) ?? EventOverwriteType.unknown,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      overwriteId: (json['overwriteId'] as num?)?.toInt() ?? 0,
      overwriteText: json['overwriteText'] as String? ?? '',
      overwriteBanner: json['overwriteBanner'] as String?,
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      targetId: (json['targetId'] as num?)?.toInt() ?? 0,
      startedAt: (json['startedAt'] as num?)?.toInt() ?? 0,
      endedAt: (json['endedAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EventAddToJson(EventAdd instance) => <String, dynamic>{
      'overwriteType': _$EventOverwriteTypeEnumMap[instance.overwriteType]!,
      'priority': instance.priority,
      'overwriteId': instance.overwriteId,
      'overwriteText': instance.overwriteText,
      'overwriteBanner': instance.overwriteBanner,
      'condType': const CondTypeConverter().toJson(instance.condType),
      'targetId': instance.targetId,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
    };

const _$EventOverwriteTypeEnumMap = {
  EventOverwriteType.unknown: 'unknown',
  EventOverwriteType.bgImage: 'bgImage',
  EventOverwriteType.bgm: 'bgm',
  EventOverwriteType.name: 'name',
  EventOverwriteType.banner: 'banner',
  EventOverwriteType.noticeBanner: 'noticeBanner',
};

MstMasterMission _$MstMasterMissionFromJson(Map json) => MstMasterMission(
      id: (json['id'] as num).toInt(),
      startedAt: (json['startedAt'] as num).toInt(),
      endedAt: (json['endedAt'] as num).toInt(),
      closedAt: (json['closedAt'] as num).toInt(),
      gifts: (json['gifts'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$MstMasterMissionToJson(MstMasterMission instance) => <String, dynamic>{
      'id': instance.id,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
      'closedAt': instance.closedAt,
      'gifts': instance.gifts.map((k, e) => MapEntry(k.toString(), e)),
    };

MasterMission _$MasterMissionFromJson(Map json) => MasterMission(
      id: (json['id'] as num).toInt(),
      startedAt: (json['startedAt'] as num).toInt(),
      endedAt: (json['endedAt'] as num).toInt(),
      closedAt: (json['closedAt'] as num).toInt(),
      missions: (json['missions'] as List<dynamic>)
          .map((e) => EventMission.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      completeMission: json['completeMission'] == null
          ? null
          : CompleteMission.fromJson(Map<String, dynamic>.from(json['completeMission'] as Map)),
      quests: (json['quests'] as List<dynamic>?)
              ?.map((e) => BasicQuest.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MasterMissionToJson(MasterMission instance) => <String, dynamic>{
      'id': instance.id,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
      'closedAt': instance.closedAt,
      'missions': instance.missions.map((e) => e.toJson()).toList(),
      'completeMission': instance.completeMission?.toJson(),
      'quests': instance.quests.map((e) => e.toJson()).toList(),
    };

CompleteMission _$CompleteMissionFromJson(Map json) => CompleteMission(
      objectId: (json['objectId'] as num).toInt(),
      presentMessageId: (json['presentMessageId'] as num?)?.toInt() ?? 0,
      gifts:
          (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
              const [],
      bgm: json['bgm'] == null ? null : Bgm.fromJson(Map<String, dynamic>.from(json['bgm'] as Map)),
    );

Map<String, dynamic> _$CompleteMissionToJson(CompleteMission instance) => <String, dynamic>{
      'objectId': instance.objectId,
      'presentMessageId': instance.presentMessageId,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
      'bgm': instance.bgm?.toJson(),
    };

ItemSet _$ItemSetFromJson(Map json) => ItemSet(
      id: (json['id'] as num).toInt(),
      purchaseType: $enumDecodeNullable(_$PurchaseTypeEnumMap, json['purchaseType']) ?? PurchaseType.none,
      targetId: (json['targetId'] as num).toInt(),
      setNum: (json['setNum'] as num).toInt(),
      gifts:
          (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
              const [],
    );

Map<String, dynamic> _$ItemSetToJson(ItemSet instance) => <String, dynamic>{
      'id': instance.id,
      'purchaseType': _$PurchaseTypeEnumMap[instance.purchaseType]!,
      'targetId': instance.targetId,
      'setNum': instance.setNum,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
    };

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
      id: (json['id'] as num).toInt(),
      shopType: $enumDecodeNullable(_$ShopTypeEnumMap, json['shopType']) ?? ShopType.eventItem,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => ShopRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      slot: (json['slot'] as num?)?.toInt() ?? 0,
      priority: (json['priority'] as num).toInt(),
      name: json['name'] as String,
      detail: json['detail'] as String? ?? "",
      infoMessage: json['infoMessage'] as String? ?? "",
      warningMessage: json['warningMessage'] as String? ?? "",
      payType: $enumDecodeNullable(_$PayTypeEnumMap, json['payType']) ?? PayType.eventItem,
      cost: json['cost'] == null ? null : ItemAmount.fromJson(Map<String, dynamic>.from(json['cost'] as Map)),
      consumes: (json['consumes'] as List<dynamic>?)
              ?.map((e) => CommonConsume.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      purchaseType: $enumDecodeNullable(_$PurchaseTypeEnumMap, json['purchaseType']) ?? PurchaseType.none,
      targetIds: (json['targetIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      itemSet: (json['itemSet'] as List<dynamic>?)
              ?.map((e) => ItemSet.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      gifts:
          (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
              const [],
      setNum: (json['setNum'] as num?)?.toInt() ?? 1,
      limitNum: (json['limitNum'] as num).toInt(),
      defaultLv: (json['defaultLv'] as num?)?.toInt() ?? 0,
      defaultLimitCount: (json['defaultLimitCount'] as num?)?.toInt() ?? 0,
      scriptName: json['scriptName'] as String?,
      scriptId: json['scriptId'] as String?,
      script: json['script'] as String?,
      image: json['image'] as String?,
      openedAt: (json['openedAt'] as num?)?.toInt() ?? 0,
      closedAt: (json['closedAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$NiceShopToJson(NiceShop instance) => <String, dynamic>{
      'id': instance.id,
      'shopType': _$ShopTypeEnumMap[instance.shopType]!,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
      'slot': instance.slot,
      'priority': instance.priority,
      'name': instance.name,
      'detail': instance.detail,
      'infoMessage': instance.infoMessage,
      'warningMessage': instance.warningMessage,
      'payType': _$PayTypeEnumMap[instance.payType]!,
      'cost': instance.cost?.toJson(),
      'consumes': instance.consumes.map((e) => e.toJson()).toList(),
      'purchaseType': _$PurchaseTypeEnumMap[instance.purchaseType]!,
      'targetIds': instance.targetIds,
      'itemSet': instance.itemSet.map((e) => e.toJson()).toList(),
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
      'setNum': instance.setNum,
      'limitNum': instance.limitNum,
      'defaultLv': instance.defaultLv,
      'defaultLimitCount': instance.defaultLimitCount,
      'scriptName': instance.scriptName,
      'scriptId': instance.scriptId,
      'script': instance.script,
      'image': instance.image,
      'openedAt': instance.openedAt,
      'closedAt': instance.closedAt,
    };

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
  ShopType.shop15: 'shop15',
  ShopType.eventSvtEquip: 'eventSvtEquip',
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
      condValues: (json['condValues'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      condNum: (json['condNum'] as num?)?.toInt() ?? 0,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      isClosedDisp: json['isClosedDisp'] as bool? ?? true,
      closedMessage: json['closedMessage'] as String? ?? "",
      closedItemName: json['closedItemName'] as String? ?? "",
    );

Map<String, dynamic> _$ShopReleaseToJson(ShopRelease instance) => <String, dynamic>{
      'condValues': instance.condValues,
      'condType': const CondTypeConverter().toJson(instance.condType),
      'condNum': instance.condNum,
      'priority': instance.priority,
      'isClosedDisp': instance.isClosedDisp,
      'closedMessage': instance.closedMessage,
      'closedItemName': instance.closedItemName,
    };

EventPointReward _$EventPointRewardFromJson(Map json) => EventPointReward(
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      point: (json['point'] as num).toInt(),
      gifts:
          (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
              const [],
    );

Map<String, dynamic> _$EventPointRewardToJson(EventPointReward instance) => <String, dynamic>{
      'groupId': instance.groupId,
      'point': instance.point,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
    };

EventPointGroup _$EventPointGroupFromJson(Map json) => EventPointGroup(
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? "",
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$EventPointGroupToJson(EventPointGroup instance) => <String, dynamic>{
      'groupId': instance.groupId,
      'name': instance.name,
      'icon': instance.icon,
    };

EventPointBuff _$EventPointBuffFromJson(Map json) => EventPointBuff(
      id: (json['id'] as num).toInt(),
      funcIds: (json['funcIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      eventPoint: (json['eventPoint'] as num).toInt(),
      name: json['name'] as String,
      icon: json['icon'] as String,
      background: $enumDecodeNullable(_$ItemBGTypeEnumMap, json['background']) ?? ItemBGType.zero,
      value: (json['value'] as num?)?.toInt() ?? 0,
      skillIcon: json['skillIcon'] as String?,
      lv: (json['lv'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EventPointBuffToJson(EventPointBuff instance) => <String, dynamic>{
      'id': instance.id,
      'funcIds': instance.funcIds,
      'groupId': instance.groupId,
      'eventPoint': instance.eventPoint,
      'name': instance.name,
      'icon': instance.icon,
      'background': _$ItemBGTypeEnumMap[instance.background]!,
      'value': instance.value,
      'skillIcon': instance.skillIcon,
      'lv': instance.lv,
    };

const _$ItemBGTypeEnumMap = {
  ItemBGType.zero: 'zero',
  ItemBGType.bronze: 'bronze',
  ItemBGType.silver: 'silver',
  ItemBGType.gold: 'gold',
  ItemBGType.questClearQPReward: 'questClearQPReward',
  ItemBGType.aquaBlue: 'aquaBlue',
};

EventPointActivity _$EventPointActivityFromJson(Map json) => EventPointActivity(
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      point: (json['point'] as num?)?.toInt() ?? 0,
      objectType: $enumDecodeNullable(_$EventPointActivityObjectTypeEnumMap, json['objectType']) ??
          EventPointActivityObjectType.none,
      objectId: (json['objectId'] as num?)?.toInt() ?? 0,
      objectValue: (json['objectValue'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EventPointActivityToJson(EventPointActivity instance) => <String, dynamic>{
      'groupId': instance.groupId,
      'point': instance.point,
      'objectType': _$EventPointActivityObjectTypeEnumMap[instance.objectType]!,
      'objectId': instance.objectId,
      'objectValue': instance.objectValue,
    };

const _$EventPointActivityObjectTypeEnumMap = {
  EventPointActivityObjectType.none: 'none',
  EventPointActivityObjectType.questId: 'questId',
  EventPointActivityObjectType.skillId: 'skillId',
  EventPointActivityObjectType.shopId: 'shopId',
};

EventMissionConditionDetail _$EventMissionConditionDetailFromJson(Map json) => EventMissionConditionDetail(
      id: (json['id'] as num).toInt(),
      missionTargetId: (json['missionTargetId'] as num?)?.toInt() ?? 0,
      missionCondType: (json['missionCondType'] as num).toInt(),
      logicType: (json['logicType'] as num?)?.toInt() ?? 1,
      targetIds: (json['targetIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      addTargetIds: (json['addTargetIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      targetQuestIndividualities: (json['targetQuestIndividualities'] as List<dynamic>?)
              ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      conditionLinkType: $enumDecodeNullable(_$DetailMissionCondLinkTypeEnumMap, json['conditionLinkType']) ??
          DetailMissionCondLinkType.missionStart,
      targetEventIds: (json['targetEventIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    );

Map<String, dynamic> _$EventMissionConditionDetailToJson(EventMissionConditionDetail instance) => <String, dynamic>{
      'id': instance.id,
      'missionTargetId': instance.missionTargetId,
      'missionCondType': instance.missionCondType,
      'logicType': instance.logicType,
      'targetIds': instance.targetIds,
      'addTargetIds': instance.addTargetIds,
      'targetQuestIndividualities': instance.targetQuestIndividualities.map((e) => e.toJson()).toList(),
      'conditionLinkType': _$DetailMissionCondLinkTypeEnumMap[instance.conditionLinkType]!,
      'targetEventIds': instance.targetEventIds,
    };

const _$DetailMissionCondLinkTypeEnumMap = {
  DetailMissionCondLinkType.eventStart: 'eventStart',
  DetailMissionCondLinkType.missionStart: 'missionStart',
  DetailMissionCondLinkType.masterMissionStart: 'masterMissionStart',
  DetailMissionCondLinkType.randomMissionStart: 'randomMissionStart',
};

EventMissionCondition _$EventMissionConditionFromJson(Map json) => EventMissionCondition(
      id: (json['id'] as num).toInt(),
      missionProgressType: $enumDecode(_$MissionProgressTypeEnumMap, json['missionProgressType']),
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      condGroup: (json['condGroup'] as num?)?.toInt() ?? 1,
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      targetIds: (json['targetIds'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
      targetNum: (json['targetNum'] as num).toInt(),
      conditionMessage: json['conditionMessage'] as String,
      closedMessage: json['closedMessage'] as String? ?? "",
      flag: (json['flag'] as num?)?.toInt() ?? 0,
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => EventMissionConditionDetail.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$EventMissionConditionToJson(EventMissionCondition instance) => <String, dynamic>{
      'id': instance.id,
      'missionProgressType': _$MissionProgressTypeEnumMap[instance.missionProgressType]!,
      'priority': instance.priority,
      'condGroup': instance.condGroup,
      'condType': const CondTypeConverter().toJson(instance.condType),
      'targetIds': instance.targetIds,
      'targetNum': instance.targetNum,
      'conditionMessage': instance.conditionMessage,
      'closedMessage': instance.closedMessage,
      'flag': instance.flag,
      'details': instance.details?.map((e) => e.toJson()).toList(),
    };

const _$MissionProgressTypeEnumMap = {
  MissionProgressType.none: 'none',
  MissionProgressType.regist: 'regist',
  MissionProgressType.openCondition: 'openCondition',
  MissionProgressType.start: 'start',
  MissionProgressType.clear: 'clear',
  MissionProgressType.achieve: 'achieve',
};

EventMission _$EventMissionFromJson(Map json) => EventMission(
      id: (json['id'] as num).toInt(),
      type: $enumDecodeNullable(_$MissionTypeEnumMap, json['type']) ?? MissionType.event,
      dispNo: (json['dispNo'] as num).toInt(),
      name: json['name'] as String,
      startedAt: (json['startedAt'] as num?)?.toInt() ?? 0,
      endedAt: (json['endedAt'] as num?)?.toInt() ?? 0,
      closedAt: (json['closedAt'] as num?)?.toInt() ?? 0,
      rewardType: $enumDecodeNullable(_$MissionRewardTypeEnumMap, json['rewardType']) ?? MissionRewardType.gift,
      gifts: (json['gifts'] as List<dynamic>).map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      bannerGroup: (json['bannerGroup'] as num?)?.toInt() ?? 0,
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      conds: (json['conds'] as List<dynamic>?)
              ?.map((e) => EventMissionCondition.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EventMissionToJson(EventMission instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$MissionTypeEnumMap[instance.type]!,
      'dispNo': instance.dispNo,
      'name': instance.name,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
      'closedAt': instance.closedAt,
      'rewardType': _$MissionRewardTypeEnumMap[instance.rewardType]!,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
      'bannerGroup': instance.bannerGroup,
      'priority': instance.priority,
      'conds': instance.conds.map((e) => e.toJson()).toList(),
    };

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

EventRandomMission _$EventRandomMissionFromJson(Map json) => EventRandomMission(
      missionId: (json['missionId'] as num).toInt(),
      missionRank: (json['missionRank'] as num).toInt(),
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      condId: (json['condId'] as num).toInt(),
      condNum: (json['condNum'] as num).toInt(),
    );

Map<String, dynamic> _$EventRandomMissionToJson(EventRandomMission instance) => <String, dynamic>{
      'missionId': instance.missionId,
      'missionRank': instance.missionRank,
      'condType': const CondTypeConverter().toJson(instance.condType),
      'condId': instance.condId,
      'condNum': instance.condNum,
    };

NiceEventMissionGroup _$NiceEventMissionGroupFromJson(Map json) => NiceEventMissionGroup(
      id: (json['id'] as num).toInt(),
      missionIds: (json['missionIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
    );

Map<String, dynamic> _$NiceEventMissionGroupToJson(NiceEventMissionGroup instance) => <String, dynamic>{
      'id': instance.id,
      'missionIds': instance.missionIds,
    };

EventCommandAssist _$EventCommandAssistFromJson(Map json) => EventCommandAssist(
      id: (json['id'] as num).toInt(),
      priority: (json['priority'] as num?)?.toInt() ?? 0,
      lv: (json['lv'] as num).toInt(),
      name: json['name'] as String,
      assistCard: $enumDecodeNullable(_$CardTypeEnumMap, json['assistCard']) ?? CardType.none,
      image: json['image'] as String,
      skill: NiceSkill.fromJson(Map<String, dynamic>.from(json['skill'] as Map)),
      skillLv: (json['skillLv'] as num).toInt(),
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EventCommandAssistToJson(EventCommandAssist instance) => <String, dynamic>{
      'id': instance.id,
      'priority': instance.priority,
      'lv': instance.lv,
      'name': instance.name,
      'assistCard': _$CardTypeEnumMap[instance.assistCard]!,
      'image': instance.image,
      'skill': instance.skill.toJson(),
      'skillLv': instance.skillLv,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
    };

const _$CardTypeEnumMap = {
  CardType.none: 'none',
  CardType.arts: 'arts',
  CardType.buster: 'buster',
  CardType.quick: 'quick',
  CardType.extra: 'extra',
  CardType.blank: 'blank',
  CardType.weak: 'weak',
  CardType.strength: 'strength',
};

EventTowerReward _$EventTowerRewardFromJson(Map json) => EventTowerReward(
      floor: (json['floor'] as num).toInt(),
      gifts: (json['gifts'] as List<dynamic>).map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    );

Map<String, dynamic> _$EventTowerRewardToJson(EventTowerReward instance) => <String, dynamic>{
      'floor': instance.floor,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
    };

EventTower _$EventTowerFromJson(Map json) => EventTower(
      towerId: (json['towerId'] as num).toInt(),
      name: json['name'] as String,
      rewards: (json['rewards'] as List<dynamic>)
          .map((e) => EventTowerReward.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$EventTowerToJson(EventTower instance) => <String, dynamic>{
      'towerId': instance.towerId,
      'name': instance.name,
      'rewards': instance.rewards.map((e) => e.toJson()).toList(),
    };

EventLotteryBox _$EventLotteryBoxFromJson(Map json) => EventLotteryBox(
      boxIndex: (json['boxIndex'] as num?)?.toInt() ?? 0,
      talkId: (json['talkId'] as num?)?.toInt() ?? 0,
      no: (json['no'] as num).toInt(),
      type: (json['type'] as num?)?.toInt() ?? 1,
      gifts:
          (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
              const [],
      maxNum: (json['maxNum'] as num).toInt(),
      isRare: json['isRare'] as bool? ?? false,
    );

Map<String, dynamic> _$EventLotteryBoxToJson(EventLotteryBox instance) => <String, dynamic>{
      'boxIndex': instance.boxIndex,
      'talkId': instance.talkId,
      'no': instance.no,
      'type': instance.type,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
      'maxNum': instance.maxNum,
      'isRare': instance.isRare,
    };

EventLottery _$EventLotteryFromJson(Map json) => EventLottery(
      id: (json['id'] as num).toInt(),
      slot: (json['slot'] as num?)?.toInt() ?? 0,
      payType: $enumDecodeNullable(_$PayTypeEnumMap, json['payType']) ?? PayType.eventItem,
      cost: ItemAmount.fromJson(Map<String, dynamic>.from(json['cost'] as Map)),
      priority: (json['priority'] as num).toInt(),
      limited: json['limited'] as bool,
      boxes: (json['boxes'] as List<dynamic>)
          .map((e) => EventLotteryBox.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      talks: (json['talks'] as List<dynamic>?)
              ?.map((e) => EventLotteryTalk.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EventLotteryToJson(EventLottery instance) => <String, dynamic>{
      'id': instance.id,
      'slot': instance.slot,
      'payType': _$PayTypeEnumMap[instance.payType]!,
      'cost': instance.cost.toJson(),
      'priority': instance.priority,
      'limited': instance.limited,
      'boxes': instance.boxes.map((e) => e.toJson()).toList(),
      'talks': instance.talks.map((e) => e.toJson()).toList(),
    };

EventLotteryTalk _$EventLotteryTalkFromJson(Map json) => EventLotteryTalk(
      talkId: (json['talkId'] as num).toInt(),
      no: (json['no'] as num).toInt(),
      guideImageId: (json['guideImageId'] as num).toInt(),
      beforeVoiceLines: (json['beforeVoiceLines'] as List<dynamic>?)
              ?.map((e) => VoiceLine.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      afterVoiceLines: (json['afterVoiceLines'] as List<dynamic>?)
              ?.map((e) => VoiceLine.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      isRare: json['isRare'] as bool,
    );

Map<String, dynamic> _$EventLotteryTalkToJson(EventLotteryTalk instance) => <String, dynamic>{
      'talkId': instance.talkId,
      'no': instance.no,
      'guideImageId': instance.guideImageId,
      'beforeVoiceLines': instance.beforeVoiceLines.map((e) => e.toJson()).toList(),
      'afterVoiceLines': instance.afterVoiceLines.map((e) => e.toJson()).toList(),
      'isRare': instance.isRare,
    };

WarBoard _$WarBoardFromJson(Map json) => WarBoard(
      warBoardId: (json['warBoardId'] as num).toInt(),
      stages: (json['stages'] as List<dynamic>?)
              ?.map((e) => WarBoardStage.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WarBoardToJson(WarBoard instance) => <String, dynamic>{
      'warBoardId': instance.warBoardId,
      'stages': instance.stages.map((e) => e.toJson()).toList(),
    };

WarBoardStage _$WarBoardStageFromJson(Map json) => WarBoardStage(
      warBoardStageId: (json['warBoardStageId'] as num).toInt(),
      boardMessage: json['boardMessage'] as String? ?? '',
      formationCost: (json['formationCost'] as num?)?.toInt() ?? 0,
      squares: (json['squares'] as List<dynamic>?)
              ?.map((e) => WarBoardStageSquare.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      questId: (json['questId'] as num?)?.toInt() ?? 0,
      questPhase: (json['questPhase'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$WarBoardStageToJson(WarBoardStage instance) => <String, dynamic>{
      'warBoardStageId': instance.warBoardStageId,
      'boardMessage': instance.boardMessage,
      'formationCost': instance.formationCost,
      'squares': instance.squares.map((e) => e.toJson()).toList(),
      'questId': instance.questId,
      'questPhase': instance.questPhase,
    };

WarBoardStageSquare _$WarBoardStageSquareFromJson(Map json) => WarBoardStageSquare(
      squareIndex: (json['squareIndex'] as num).toInt(),
      type: $enumDecodeNullable(_$WarBoardStageSquareTypeEnumMap, json['type']) ?? WarBoardStageSquareType.normal,
      effectId: (json['effectId'] as num?)?.toInt() ?? 0,
      treasures: (json['treasures'] as List<dynamic>?)
              ?.map((e) => WarBoardTreasure.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$WarBoardStageSquareToJson(WarBoardStageSquare instance) => <String, dynamic>{
      'squareIndex': instance.squareIndex,
      'type': _$WarBoardStageSquareTypeEnumMap[instance.type]!,
      'effectId': instance.effectId,
      'treasures': instance.treasures.map((e) => e.toJson()).toList(),
    };

const _$WarBoardStageSquareTypeEnumMap = {
  WarBoardStageSquareType.normal: 'normal',
  WarBoardStageSquareType.item: 'item',
  WarBoardStageSquareType.effect: 'effect',
  WarBoardStageSquareType.treasure: 'treasure',
  WarBoardStageSquareType.wall: 'wall',
};

WarBoardTreasure _$WarBoardTreasureFromJson(Map json) => WarBoardTreasure(
      warBoardTreasureId: (json['warBoardTreasureId'] as num).toInt(),
      rarity: $enumDecodeNullable(_$WarBoardTreasureRarityEnumMap, json['rarity']) ?? WarBoardTreasureRarity.unknown,
      gifts:
          (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
              const [],
    );

Map<String, dynamic> _$WarBoardTreasureToJson(WarBoardTreasure instance) => <String, dynamic>{
      'warBoardTreasureId': instance.warBoardTreasureId,
      'rarity': _$WarBoardTreasureRarityEnumMap[instance.rarity]!,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
    };

const _$WarBoardTreasureRarityEnumMap = {
  WarBoardTreasureRarity.unknown: 'unknown',
  WarBoardTreasureRarity.common: 'common',
  WarBoardTreasureRarity.rare: 'rare',
  WarBoardTreasureRarity.srare: 'srare',
  WarBoardTreasureRarity.commonPlus: 'commonPlus',
  WarBoardTreasureRarity.rarePlus: 'rarePlus',
  WarBoardTreasureRarity.srarePlus: 'srarePlus',
  WarBoardTreasureRarity.commonPlus2: 'commonPlus2',
  WarBoardTreasureRarity.rarePlus2: 'rarePlus2',
  WarBoardTreasureRarity.srarePlus2: 'srarePlus2',
  WarBoardTreasureRarity.itemIcon: 'itemIcon',
  WarBoardTreasureRarity.itemIconPlus: 'itemIconPlus',
  WarBoardTreasureRarity.itemIconPlus2: 'itemIconPlus2',
};

EventTreasureBoxGift _$EventTreasureBoxGiftFromJson(Map json) => EventTreasureBoxGift(
      id: (json['id'] as num).toInt(),
      idx: (json['idx'] as num).toInt(),
      gifts:
          (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
              const [],
      collateralUpperLimit: (json['collateralUpperLimit'] as num).toInt(),
    );

Map<String, dynamic> _$EventTreasureBoxGiftToJson(EventTreasureBoxGift instance) => <String, dynamic>{
      'id': instance.id,
      'idx': instance.idx,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
      'collateralUpperLimit': instance.collateralUpperLimit,
    };

EventTreasureBox _$EventTreasureBoxFromJson(Map json) => EventTreasureBox(
      slot: (json['slot'] as num).toInt(),
      id: (json['id'] as num).toInt(),
      idx: (json['idx'] as num).toInt(),
      treasureBoxGifts: (json['treasureBoxGifts'] as List<dynamic>)
          .map((e) => EventTreasureBoxGift.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      maxDrawNumOnce: (json['maxDrawNumOnce'] as num).toInt(),
      extraGifts:
          (json['extraGifts'] as List<dynamic>).map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      consumes: (json['consumes'] as List<dynamic>?)
              ?.map((e) => CommonConsume.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EventTreasureBoxToJson(EventTreasureBox instance) => <String, dynamic>{
      'slot': instance.slot,
      'id': instance.id,
      'idx': instance.idx,
      'treasureBoxGifts': instance.treasureBoxGifts.map((e) => e.toJson()).toList(),
      'maxDrawNumOnce': instance.maxDrawNumOnce,
      'extraGifts': instance.extraGifts.map((e) => e.toJson()).toList(),
      'consumes': instance.consumes.map((e) => e.toJson()).toList(),
    };

EventRewardSceneGuide _$EventRewardSceneGuideFromJson(Map json) => EventRewardSceneGuide(
      imageId: (json['imageId'] as num).toInt(),
      limitCount: (json['limitCount'] as num?)?.toInt() ?? 0,
      image: json['image'] as String,
      faceId: (json['faceId'] as num?)?.toInt() ?? 0,
      displayName: json['displayName'] as String?,
      weight: (json['weight'] as num?)?.toInt(),
      unselectedMax: (json['unselectedMax'] as num?)?.toInt(),
    );

Map<String, dynamic> _$EventRewardSceneGuideToJson(EventRewardSceneGuide instance) => <String, dynamic>{
      'imageId': instance.imageId,
      'limitCount': instance.limitCount,
      'image': instance.image,
      'faceId': instance.faceId,
      'displayName': instance.displayName,
      'weight': instance.weight,
      'unselectedMax': instance.unselectedMax,
    };

EventRewardScene _$EventRewardSceneFromJson(Map json) => EventRewardScene(
      slot: (json['slot'] as num?)?.toInt() ?? 0,
      groupId: (json['groupId'] as num?)?.toInt() ?? 0,
      type: (json['type'] as num?)?.toInt() ?? 0,
      guides: (json['guides'] as List<dynamic>?)
              ?.map((e) => EventRewardSceneGuide.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      tabOnImage: json['tabOnImage'] as String,
      tabOffImage: json['tabOffImage'] as String,
      image: json['image'] as String?,
      bg: json['bg'] as String,
      bgm: BgmEntity.fromJson(Map<String, dynamic>.from(json['bgm'] as Map)),
      afterBgm: BgmEntity.fromJson(Map<String, dynamic>.from(json['afterBgm'] as Map)),
      flags: (json['flags'] as List<dynamic>?)?.map((e) => $enumDecode(_$EventRewardSceneFlagEnumMap, e)).toList() ??
          const [],
    );

Map<String, dynamic> _$EventRewardSceneToJson(EventRewardScene instance) => <String, dynamic>{
      'slot': instance.slot,
      'groupId': instance.groupId,
      'type': instance.type,
      'guides': instance.guides.map((e) => e.toJson()).toList(),
      'tabOnImage': instance.tabOnImage,
      'tabOffImage': instance.tabOffImage,
      'image': instance.image,
      'bg': instance.bg,
      'bgm': instance.bgm.toJson(),
      'afterBgm': instance.afterBgm.toJson(),
      'flags': instance.flags.map((e) => _$EventRewardSceneFlagEnumMap[e]!).toList(),
    };

const _$EventRewardSceneFlagEnumMap = {
  EventRewardSceneFlag.npcGuide: 'npcGuide',
  EventRewardSceneFlag.isChangeSvtByChangedTab: 'isChangeSvtByChangedTab',
  EventRewardSceneFlag.isHideTab: 'isHideTab',
};

EventVoicePlay _$EventVoicePlayFromJson(Map json) => EventVoicePlay(
      slot: (json['slot'] as num).toInt(),
      idx: (json['idx'] as num).toInt(),
      guideImageId: (json['guideImageId'] as num).toInt(),
      voiceLines: (json['voiceLines'] as List<dynamic>?)
              ?.map((e) => VoiceLine.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      confirmVoiceLines: (json['confirmVoiceLines'] as List<dynamic>?)
              ?.map((e) => VoiceLine.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      condType: const CondTypeConverter().fromJson(json['condType'] as String),
      condValue: (json['condValue'] as num).toInt(),
      startedAt: (json['startedAt'] as num).toInt(),
      endedAt: (json['endedAt'] as num).toInt(),
    );

Map<String, dynamic> _$EventVoicePlayToJson(EventVoicePlay instance) => <String, dynamic>{
      'slot': instance.slot,
      'idx': instance.idx,
      'guideImageId': instance.guideImageId,
      'voiceLines': instance.voiceLines.map((e) => e.toJson()).toList(),
      'confirmVoiceLines': instance.confirmVoiceLines.map((e) => e.toJson()).toList(),
      'condType': const CondTypeConverter().toJson(instance.condType),
      'condValue': instance.condValue,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
    };

EventDigging _$EventDiggingFromJson(Map json) => EventDigging(
      sizeX: (json['sizeX'] as num).toInt(),
      sizeY: (json['sizeY'] as num).toInt(),
      bgImage: json['bgImage'] as String,
      eventPointItem: Item.fromJson(Map<String, dynamic>.from(json['eventPointItem'] as Map)),
      resettableDiggedNum: (json['resettableDiggedNum'] as num).toInt(),
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((e) => EventDiggingBlock.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      rewards: (json['rewards'] as List<dynamic>?)
              ?.map((e) => EventDiggingReward.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EventDiggingToJson(EventDigging instance) => <String, dynamic>{
      'sizeX': instance.sizeX,
      'sizeY': instance.sizeY,
      'bgImage': instance.bgImage,
      'eventPointItem': instance.eventPointItem.toJson(),
      'resettableDiggedNum': instance.resettableDiggedNum,
      'blocks': instance.blocks.map((e) => e.toJson()).toList(),
      'rewards': instance.rewards.map((e) => e.toJson()).toList(),
    };

EventDiggingBlock _$EventDiggingBlockFromJson(Map json) => EventDiggingBlock(
      id: (json['id'] as num).toInt(),
      image: json['image'] as String,
      consumes: (json['consumes'] as List<dynamic>?)
              ?.map((e) => CommonConsume.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      objectId: (json['objectId'] as num).toInt(),
      diggingEventPoint: (json['diggingEventPoint'] as num).toInt(),
      blockNum: (json['blockNum'] as num).toInt(),
    );

Map<String, dynamic> _$EventDiggingBlockToJson(EventDiggingBlock instance) => <String, dynamic>{
      'id': instance.id,
      'image': instance.image,
      'consumes': instance.consumes.map((e) => e.toJson()).toList(),
      'objectId': instance.objectId,
      'diggingEventPoint': instance.diggingEventPoint,
      'blockNum': instance.blockNum,
    };

EventDiggingReward _$EventDiggingRewardFromJson(Map json) => EventDiggingReward(
      id: (json['id'] as num).toInt(),
      gifts:
          (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
              const [],
      rewardSize: (json['rewardSize'] as num).toInt(),
    );

Map<String, dynamic> _$EventDiggingRewardToJson(EventDiggingReward instance) => <String, dynamic>{
      'id': instance.id,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
      'rewardSize': instance.rewardSize,
    };

EventCooltimeReward _$EventCooltimeRewardFromJson(Map json) => EventCooltimeReward(
      spotId: (json['spotId'] as num).toInt(),
      lv: (json['lv'] as num).toInt(),
      name: json['name'] as String,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      cooltime: (json['cooltime'] as num).toInt(),
      addEventPointRate: (json['addEventPointRate'] as num).toInt(),
      gifts: (json['gifts'] as List<dynamic>).map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      upperLimitGiftNum: (json['upperLimitGiftNum'] as num).toInt(),
    );

Map<String, dynamic> _$EventCooltimeRewardToJson(EventCooltimeReward instance) => <String, dynamic>{
      'spotId': instance.spotId,
      'lv': instance.lv,
      'name': instance.name,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
      'cooltime': instance.cooltime,
      'addEventPointRate': instance.addEventPointRate,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
      'upperLimitGiftNum': instance.upperLimitGiftNum,
    };

EventCooltime _$EventCooltimeFromJson(Map json) => EventCooltime(
      rewards: (json['rewards'] as List<dynamic>?)
              ?.map((e) => EventCooltimeReward.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EventCooltimeToJson(EventCooltime instance) => <String, dynamic>{
      'rewards': instance.rewards.map((e) => e.toJson()).toList(),
    };

EventRecipeGift _$EventRecipeGiftFromJson(Map json) => EventRecipeGift(
      idx: (json['idx'] as num).toInt(),
      displayOrder: (json['displayOrder'] as num).toInt(),
      topIconId: (json['topIconId'] as num?)?.toInt() ?? 0,
      gifts:
          (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
              const [],
    );

Map<String, dynamic> _$EventRecipeGiftToJson(EventRecipeGift instance) => <String, dynamic>{
      'idx': instance.idx,
      'displayOrder': instance.displayOrder,
      'topIconId': instance.topIconId,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
    };

EventRecipe _$EventRecipeFromJson(Map json) => EventRecipe(
      id: (json['id'] as num).toInt(),
      icon: json['icon'] as String,
      name: json['name'] as String,
      maxNum: (json['maxNum'] as num).toInt(),
      eventPointItem: Item.fromJson(Map<String, dynamic>.from(json['eventPointItem'] as Map)),
      eventPointNum: (json['eventPointNum'] as num).toInt(),
      consumes: (json['consumes'] as List<dynamic>?)
              ?.map((e) => CommonConsume.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      closedMessage: json['closedMessage'] as String? ?? '',
      recipeGifts: (json['recipeGifts'] as List<dynamic>?)
              ?.map((e) => EventRecipeGift.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EventRecipeToJson(EventRecipe instance) => <String, dynamic>{
      'id': instance.id,
      'icon': instance.icon,
      'name': instance.name,
      'maxNum': instance.maxNum,
      'eventPointItem': instance.eventPointItem.toJson(),
      'eventPointNum': instance.eventPointNum,
      'consumes': instance.consumes.map((e) => e.toJson()).toList(),
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
      'closedMessage': instance.closedMessage,
      'recipeGifts': instance.recipeGifts.map((e) => e.toJson()).toList(),
    };

EventFortificationDetail _$EventFortificationDetailFromJson(Map json) => EventFortificationDetail(
      position: (json['position'] as num).toInt(),
      name: json['name'] as String,
      className: $enumDecodeNullable(_$SvtClassSupportGroupTypeEnumMap, json['className']) ??
          SvtClassSupportGroupType.notSupport,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EventFortificationDetailToJson(EventFortificationDetail instance) => <String, dynamic>{
      'position': instance.position,
      'name': instance.name,
      'className': _$SvtClassSupportGroupTypeEnumMap[instance.className]!,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
    };

const _$SvtClassSupportGroupTypeEnumMap = {
  SvtClassSupportGroupType.all: 'all',
  SvtClassSupportGroupType.saber: 'saber',
  SvtClassSupportGroupType.archer: 'archer',
  SvtClassSupportGroupType.lancer: 'lancer',
  SvtClassSupportGroupType.rider: 'rider',
  SvtClassSupportGroupType.caster: 'caster',
  SvtClassSupportGroupType.assassin: 'assassin',
  SvtClassSupportGroupType.berserker: 'berserker',
  SvtClassSupportGroupType.extra: 'extra',
  SvtClassSupportGroupType.mix: 'mix',
  SvtClassSupportGroupType.notSupport: 'notSupport',
};

EventFortificationSvt _$EventFortificationSvtFromJson(Map json) => EventFortificationSvt(
      position: (json['position'] as num).toInt(),
      type: $enumDecodeNullable(_$EventFortificationSvtTypeEnumMap, json['type']) ?? EventFortificationSvtType.none,
      svtId: (json['svtId'] as num).toInt(),
      limitCount: (json['limitCount'] as num).toInt(),
      lv: (json['lv'] as num).toInt(),
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EventFortificationSvtToJson(EventFortificationSvt instance) => <String, dynamic>{
      'position': instance.position,
      'type': _$EventFortificationSvtTypeEnumMap[instance.type]!,
      'svtId': instance.svtId,
      'limitCount': instance.limitCount,
      'lv': instance.lv,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
    };

const _$EventFortificationSvtTypeEnumMap = {
  EventFortificationSvtType.userSvt: 'userSvt',
  EventFortificationSvtType.npc: 'npc',
  EventFortificationSvtType.none: 'none',
};

EventFortification _$EventFortificationFromJson(Map json) => EventFortification(
      idx: (json['idx'] as num).toInt(),
      name: json['name'] as String,
      x: (json['x'] as num).toInt(),
      y: (json['y'] as num).toInt(),
      rewardSceneX: (json['rewardSceneX'] as num).toInt(),
      rewardSceneY: (json['rewardSceneY'] as num).toInt(),
      maxFortificationPoint: (json['maxFortificationPoint'] as num).toInt(),
      workType: $enumDecodeNullable(_$EventWorkTypeEnumMap, json['workType']) ?? EventWorkType.unknown,
      gifts:
          (json['gifts'] as List<dynamic>?)?.map((e) => Gift.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
              const [],
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      details: (json['details'] as List<dynamic>?)
              ?.map((e) => EventFortificationDetail.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      servants: (json['servants'] as List<dynamic>?)
              ?.map((e) => EventFortificationSvt.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EventFortificationToJson(EventFortification instance) => <String, dynamic>{
      'idx': instance.idx,
      'name': instance.name,
      'x': instance.x,
      'y': instance.y,
      'rewardSceneX': instance.rewardSceneX,
      'rewardSceneY': instance.rewardSceneY,
      'maxFortificationPoint': instance.maxFortificationPoint,
      'workType': _$EventWorkTypeEnumMap[instance.workType]!,
      'gifts': instance.gifts.map((e) => e.toJson()).toList(),
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
      'details': instance.details.map((e) => e.toJson()).toList(),
      'servants': instance.servants.map((e) => e.toJson()).toList(),
    };

const _$EventWorkTypeEnumMap = {
  EventWorkType.militsryAffairs: 'militsryAffairs',
  EventWorkType.internalAffairs: 'internalAffairs',
  EventWorkType.farmming: 'farmming',
  EventWorkType.unknown: 'unknown',
};

EventBulletinBoard _$EventBulletinBoardFromJson(Map json) => EventBulletinBoard(
      bulletinBoardId: (json['bulletinBoardId'] as num).toInt(),
      message: json['message'] as String,
      probability: (json['probability'] as num?)?.toInt(),
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => EventBulletinBoardRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: (json['script'] as List<dynamic>?)
          ?.map((e) => EventBulletinBoardScript.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$EventBulletinBoardToJson(EventBulletinBoard instance) => <String, dynamic>{
      'bulletinBoardId': instance.bulletinBoardId,
      'message': instance.message,
      'probability': instance.probability,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
      'script': instance.script?.map((e) => e.toJson()).toList(),
    };

EventBulletinBoardScript _$EventBulletinBoardScriptFromJson(Map json) => EventBulletinBoardScript(
      icon: json['icon'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$EventBulletinBoardScriptToJson(EventBulletinBoardScript instance) => <String, dynamic>{
      'icon': instance.icon,
      'name': instance.name,
    };

EventBulletinBoardRelease _$EventBulletinBoardReleaseFromJson(Map json) => EventBulletinBoardRelease(
      condGroup: (json['condGroup'] as num?)?.toInt() ?? 1,
      condType:
          json['condType'] == null ? CondType.none : const CondTypeConverter().fromJson(json['condType'] as String),
      condTargetId: (json['condTargetId'] as num?)?.toInt() ?? 0,
      condNum: (json['condNum'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EventBulletinBoardReleaseToJson(EventBulletinBoardRelease instance) => <String, dynamic>{
      'condGroup': instance.condGroup,
      'condType': const CondTypeConverter().toJson(instance.condType),
      'condTargetId': instance.condTargetId,
      'condNum': instance.condNum,
    };

EventCampaign _$EventCampaignFromJson(Map json) => EventCampaign(
      targetIds: (json['targetIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      warIds: (json['warIds'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
      target: $enumDecodeNullable(_$CombineAdjustTargetEnumMap, json['target']) ?? CombineAdjustTarget.none,
      idx: (json['idx'] as num?)?.toInt() ?? 0,
      value: (json['value'] as num).toInt(),
      calcType: $enumDecodeNullable(_$EventCombineCalcEnumMap, json['calcType']) ?? EventCombineCalc.multiplication,
    );

Map<String, dynamic> _$EventCampaignToJson(EventCampaign instance) => <String, dynamic>{
      'targetIds': instance.targetIds,
      'warIds': instance.warIds,
      'target': _$CombineAdjustTargetEnumMap[instance.target]!,
      'idx': instance.idx,
      'value': instance.value,
      'calcType': _$EventCombineCalcEnumMap[instance.calcType]!,
    };

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
  CombineAdjustTarget.friendPointGachaFreeDrawNum: 'friendPointGachaFreeDrawNum',
  CombineAdjustTarget.questUseFriendshipUpItem: 'questUseFriendshipUpItem',
  CombineAdjustTarget.questFriendship: 'questFriendship',
  CombineAdjustTarget.largeSuccessByClass: 'largeSuccessByClass',
  CombineAdjustTarget.superSuccessByClass: 'superSuccessByClass',
  CombineAdjustTarget.exchangeSvt: 'exchangeSvt',
};

const _$EventCombineCalcEnumMap = {
  EventCombineCalc.addition: 'addition',
  EventCombineCalc.multiplication: 'multiplication',
  EventCombineCalc.fixedValue: 'fixedValue',
};

EventQuest _$EventQuestFromJson(Map json) => EventQuest(
      questId: (json['questId'] as num).toInt(),
    );

Map<String, dynamic> _$EventQuestToJson(EventQuest instance) => <String, dynamic>{
      'questId': instance.questId,
    };

HeelPortrait _$HeelPortraitFromJson(Map json) => HeelPortrait(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? "",
      image: json['image'] as String,
    );

Map<String, dynamic> _$HeelPortraitToJson(HeelPortrait instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
    };

EventMural _$EventMuralFromJson(Map json) => EventMural(
      id: (json['id'] as num?)?.toInt() ?? 0,
      message: json['message'] as String? ?? "",
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      num: (json['num'] as num?)?.toInt() ?? 0,
      condQuestId: (json['condQuestId'] as num?)?.toInt() ?? 0,
      condQuestPhase: (json['condQuestPhase'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EventMuralToJson(EventMural instance) => <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'images': instance.images,
      'num': instance.num,
      'condQuestId': instance.condQuestId,
      'condQuestPhase': instance.condQuestPhase,
    };

EventSvt _$EventSvtFromJson(Map json) => EventSvt(
      svtId: (json['svtId'] as num).toInt(),
      script: json['script'] == null ? null : EventSvtScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
      originalScript: (json['originalScript'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      type: $enumDecodeNullable(_$EventSvtTypeEnumMap, json['type']) ?? EventSvtType.none,
      joinMessage: json['joinMessage'] as String? ?? '',
      getMessage: json['getMessage'] as String? ?? '',
      leaveMessage: json['leaveMessage'] as String? ?? '',
      name: json['name'] as String? ?? '',
      battleName: json['battleName'] as String? ?? '',
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      startedAt: (json['startedAt'] as num?)?.toInt() ?? 0,
      endedAt: (json['endedAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$EventSvtToJson(EventSvt instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'script': instance.script.toJson(),
      'originalScript': instance.originalScript,
      'type': _$EventSvtTypeEnumMap[instance.type]!,
      'joinMessage': instance.joinMessage,
      'getMessage': instance.getMessage,
      'leaveMessage': instance.leaveMessage,
      'name': instance.name,
      'battleName': instance.battleName,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
    };

const _$EventSvtTypeEnumMap = {
  EventSvtType.none: 'none',
  EventSvtType.join: 'join',
  EventSvtType.condJoin: 'condJoin',
  EventSvtType.directJoin: 'directJoin',
};

EventSvtScript _$EventSvtScriptFromJson(Map json) => EventSvtScript(
      addGetMessage: json['addGetMessage'] as String?,
      addMessageReleaseConditions: (json['addMessageReleaseConditions'] as List<dynamic>?)
          ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      isProtectedDuringEvent: json['isProtectedDuringEvent'] as bool?,
      joinQuestId: (json['joinQuestId'] as num?)?.toInt(),
      joinShopId: (json['joinShopId'] as num?)?.toInt(),
      notPresentAnonymous: json['notPresentAnonymous'] as bool?,
      notPresentRarePri: (json['notPresentRarePri'] as num?)?.toInt(),
      ruby: json['ruby'] as String?,
    );

Map<String, dynamic> _$EventSvtScriptToJson(EventSvtScript instance) => <String, dynamic>{
      'addGetMessage': instance.addGetMessage,
      'addMessageReleaseConditions': instance.addMessageReleaseConditions?.map((e) => e.toJson()).toList(),
      'isProtectedDuringEvent': instance.isProtectedDuringEvent,
      'joinQuestId': instance.joinQuestId,
      'joinShopId': instance.joinShopId,
      'notPresentAnonymous': instance.notPresentAnonymous,
      'notPresentRarePri': instance.notPresentRarePri,
      'ruby': instance.ruby,
    };
