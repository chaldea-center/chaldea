import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';
import '../../app/modules/shop/shop.dart';
import '_helper.dart';
import 'gamedata.dart';

part '../../generated/models/gamedata/event.g.dart';

@JsonSerializable()
class Event {
  int id;
  EventType type;
  String name;
  String? _shortName;
  String detail;
  String? noticeBanner;
  String? banner;
  String? icon;
  int bannerPriority;
  int noticeAt;
  int startedAt;
  int endedAt;
  int finishedAt;
  // int materialOpenedAt;
  List<int> _warIds;
  List<EventAdd> eventAdds;
  List<NiceShop> shop;
  List<EventRewardScene> rewardScenes;
  @JsonKey(name: 'rewards')
  List<EventPointReward> pointRewards; // point rewards
  List<EventPointGroup> pointGroups;
  List<EventPointBuff> pointBuffs;
  List<EventPointActivity> pointActivities;
  List<EventMission> missions;
  List<EventRandomMission> randomMissions;
  List<NiceEventMissionGroup> missionGroups;
  List<EventTower> towers;
  List<EventLottery> lotteries;
  List<EventTreasureBox> treasureBoxes;
  List<EventRecipe> recipes;
  List<EventBulletinBoard> bulletinBoards;
  EventDigging? digging;
  EventCooltime? cooltime;
  List<EventFortification> fortifications;
  List<EventCampaign> campaigns;
  List<EventQuest> campaignQuests;
  List<EventCommandAssist> commandAssists;
  List<HeelPortrait> heelPortraits;
  List<EventMural> murals;
  List<EventVoicePlay> voicePlays;
  List<VoiceGroup> voices;

  List<int> get warIds {
    if (_warIds.isEmpty) {
      for (final entry in kExtraWarEventMapping.entries) {
        if (entry.value == id) return [entry.key];
      }
    }
    return _warIds;
  }

  Event({
    required this.id,
    this.type = EventType.none,
    required this.name,
    String shortName = "",
    required this.detail,
    this.noticeBanner,
    this.banner,
    this.icon,
    this.bannerPriority = 0,
    required this.noticeAt,
    required this.startedAt,
    required this.endedAt,
    required this.finishedAt,
    // required this.materialOpenedAt,
    List<int> warIds = const [],
    this.eventAdds = const [],
    this.shop = const [],
    this.pointRewards = const [],
    this.rewardScenes = const [],
    this.pointGroups = const [],
    this.pointBuffs = const [],
    this.pointActivities = const [],
    this.missions = const [],
    this.randomMissions = const [],
    this.missionGroups = const [],
    this.towers = const [],
    this.lotteries = const [],
    this.treasureBoxes = const [],
    this.recipes = const [],
    this.bulletinBoards = const [],
    this.digging,
    this.cooltime,
    this.fortifications = const [],
    this.campaigns = const [],
    this.campaignQuests = const [],
    this.commandAssists = const [],
    this.heelPortraits = const [],
    this.murals = const [],
    this.voicePlays = const [],
    this.voices = const [],
  })  : _shortName = ['', '-'].contains(shortName) ? null : shortName,
        _warIds = warIds;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  String get shortName => lShortName.jp;
  Transl<String, String> get lShortName {
    if (_shortName != null) return Transl.warNames(_shortName!);
    return lName;
  }

  EventExtra get extra => db.gameData.wiki.events.putIfAbsent(id, () => EventExtra(id: id, name: name));

  /// Check valuable "content", campaigns are not considered as "event" usually
  bool get isEmpty =>
      warIds.isEmpty &&
      shop.isEmpty &&
      lotteries.isEmpty &&
      missions.isEmpty &&
      randomMissions.isEmpty &&
      treasureBoxes.isEmpty &&
      towers.isEmpty &&
      pointRewards.isEmpty &&
      // bulletinBoards.isEmpty &&
      // rewardScenes.isEmpty &&
      digging == null &&
      cooltime == null &&
      recipes.isEmpty &&
      fortifications.isEmpty &&
      // campaigns.isEmpty &&
      // campaignQuests.isEmpty &&
      // heelPortraits.isEmpty &&
      !isHuntingEvent &&
      extra.extraFixedItems.isEmpty &&
      extra.extraItems.isEmpty &&
      !db.gameData.others.eventQuestGroups.containsKey(id) &&
      !isAdvancedQuestEvent;

  bool get isInfinite =>
      extra.extraItems.any((e) => e.infinite) ||
      isHuntingEvent ||
      lotteries.any((e) => !e.limited) ||
      treasureBoxes.isNotEmpty ||
      randomMissions.isNotEmpty ||
      digging != null ||
      fortifications.isNotEmpty ||
      recipes.isNotEmpty;

  bool get isAdvancedQuestEvent => name.contains('アドバンスドクエスト');
  bool get isHuntingEvent => extra.huntingId > 0 || name.contains('ハンティングクエスト');

  String? get shopBanner {
    // if (shop.isEmpty) return null;
    // return 'https://static.atlasacademy.io/JP/ShopBanners/shop_event_menu_$id.png';
    return null;
  }

  bool isOutdated([Duration diff = const Duration(days: 10)]) {
    if (db.curUser.region == Region.jp) {
      final t = endedAt > kNeverClosedTimestamp || endedAt - startedAt > 30 * kSecsPerDay
          ? startedAt + 7 * kSecsPerDay
          : endedAt;
      return DateTime.now().difference(t.sec2date()) > const Duration(days: 365);
    }
    int? _end = db.curUser.region == Region.jp ? endedAt : extra.endTime.ofRegion(db.curUser.region);
    final neverClosed = DateTime.now().add(const Duration(days: 365)).timestamp;
    if (_end != null && _end > neverClosed) {
      final _start = db.curUser.region == Region.jp ? startedAt : extra.startTime.ofRegion(db.curUser.region);
      if (_start != null) {
        _end = _start + const Duration(days: 30).inSeconds;
      }
    }
    if (_end != null) {
      return _end.sec2date().isBefore(DateTime.now().subtract(diff));
    }
    // if one event is delayed more than 1 year than expected, mark as outdated/will never open
    final months = db.curUser.region.eventDelayMonth;
    final days = months * 31 + 360 + diff.inDays;
    return endedAt.sec2date().isBefore(DateTime.now().subtract(Duration(days: days)));
  }

  int? startTimeOf(Region? region) {
    if (region == Region.jp) return startedAt;
    return extra.startTime.ofRegion(region);
  }

  int? endTimeOf(Region? region) {
    if (region == Region.jp) return endedAt;
    return extra.endTime.ofRegion(region);
  }

  bool isOnGoing(Region? region) {
    int now = DateTime.now().timestamp;
    int neverEndTime = region == Region.cn || region == Region.tw ? kNeverClosedTimestampCN : kNeverClosedTimestamp;
    final starts = region == null ? [startedAt, ...extra.startTime.values] : [startTimeOf(region)];
    final ends = region == null ? [endedAt, ...extra.endTime.values] : [endTimeOf(region)];
    for (int index = 0; index < starts.length; index++) {
      int? start = starts[index], end = ends[index];
      if (start != null && end != null) {
        if (end > neverEndTime) {
          end = start + 14 * kSecsPerDay;
        }
        if (now > start && end > now) {
          return true;
        }
      }
    }
    return false;
  }

  Transl<String, String> get lName => Transl.eventNames(name);

  String get shownName {
    if (extra.huntingId > 0) {
      return '${lName.l} ${extra.huntingId}';
    }
    return lName.l.setMaxLines(2);
  }

  String get route => Routes.eventI(id);
  void routeTo() => router.push(url: Routes.eventI(id));

  // statistics
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, Map<int, int>> itemShop = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, int> itemPointReward = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, int> itemMission = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, int> itemTower = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, Map<int, Map<int, int>>> itemLottery = {}; // lotteryId, boxNum
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, Map<int, int>> itemTreasureBox = {}; //treasureBox.id
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, int> itemDigging = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, int> itemWarReward = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, int> itemWarDrop = {};

  //
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, int> statItemFixed = {};
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<int, Map<int, int>> statItemLottery = {}; //unlimited
  @JsonKey(includeFromJson: false, includeToJson: false)
  Set<int> statItemExtra = {}; // treasureBox, extraItems

  void updateStat() {
    db.itemCenter.updateEvents(events: [this]);
  }

  void calcItems(GameData gameData) {
    final extra = gameData.wiki.events[id];
    statItemFixed.clear();
    statItemLottery.clear();
    statItemExtra.clear();
    // ensure war calcItems called before events
    itemWarReward.clear();
    itemWarDrop.clear();
    for (final warId in warIds) {
      final war = gameData.wars[warId];
      if (war == null || war.id < 1000) continue;
      itemWarReward.addDict(war.itemReward);
      itemWarDrop.addDict(war.itemDrop);
    }
    statItemFixed
      ..addDict(itemWarReward)
      ..addDict(itemWarDrop);

    itemShop.clear();
    // shop
    for (final shopItem in shop) {
      if (shopItem.limitNum == 0) continue;
      if (![
        PurchaseType.item,
        PurchaseType.servant,
        PurchaseType.setItem,
        PurchaseType.eventSvtGet,
        PurchaseType.costumeRelease,
        PurchaseType.itemAsPresent,
        PurchaseType.commandCode,
        PurchaseType.gift,
      ].contains(shopItem.purchaseType)) {
        continue;
      }
      final _items = itemShop[shopItem.id] = {};
      if (shopItem.purchaseType == PurchaseType.setItem) {
        for (final set in shopItem.itemSet) {
          if (set.purchaseType == PurchaseType.item || set.purchaseType == PurchaseType.servant) {
            if (gameData.craftEssencesById[set.targetId]?.flag == SvtFlag.svtEquipChocolate) {
              continue;
            }
            _items.addNum(set.targetId, set.setNum * shopItem.setNum);
            statItemFixed.addNum(set.targetId, set.setNum * shopItem.setNum * shopItem.limitNum);
          }
          _items.addDict({for (final gift in set.gifts) gift.objectId: gift.num});
        }
      } else {
        for (final id in shopItem.targetIds) {
          if (gameData.craftEssencesById[id]?.flag == SvtFlag.svtEquipChocolate) {
            continue;
          }
          _items.addNum(id, shopItem.setNum);
          statItemFixed.addNum(id, shopItem.setNum * shopItem.limitNum);
        }
      }
      _items.addDict({for (final gift in shopItem.gifts) gift.objectId: gift.num});
    }

    // point rewards
    itemPointReward.clear();
    for (final point in pointRewards) {
      Gift.checkAddGifts(itemPointReward, point.gifts);
    }
    statItemFixed.addDict(itemPointReward);

    // mission, exclude random mission
    itemMission.clear();
    for (final mission in missions) {
      if (mission.type == MissionType.random) continue;
      if (mission.rewardType == MissionRewardType.gift) {
        Gift.checkAddGifts(itemMission, mission.gifts);
      }
    }
    statItemFixed.addDict(itemMission);

    // tower, similar with point rewards
    itemTower.clear();
    for (final tower in towers) {
      for (final reward in tower.rewards) {
        Gift.checkAddGifts(itemTower, reward.gifts);
      }
    }
    statItemFixed.addDict(itemTower);

    //
    itemLottery.clear();
    for (final lottery in lotteries) {
      final _lastBoxItems = lottery.lastBoxItems;
      if (!lottery.limited) {
        // what if multiple unlimited lottery?
        statItemLottery[lottery.id] = _lastBoxItems;
      }
      for (final box in lottery.boxes) {
        for (final gift in box.gifts) {
          final itemLotBox = itemLottery.putIfAbsent(lottery.id, () => {}).putIfAbsent(box.boxIndex, () => {});
          Gift.checkAddGifts(itemLotBox, box.gifts, box.maxNum);
          if (gift.isStatItem) {
            if (lottery.limited || !_lastBoxItems.containsKey(gift.objectId)) {
              Gift.checkAddGifts(statItemFixed, [gift], box.maxNum);
            }
          }
        }
      }
    }

    //
    itemTreasureBox.clear();
    for (final box in treasureBoxes) {
      for (final boxGifts in box.treasureBoxGifts) {
        final itemBox = itemTreasureBox.putIfAbsent(box.id, () => {});
        for (final gift in boxGifts.gifts) {
          if (gift.isStatItem) {
            itemBox.addNum(gift.objectId, gift.num);
            statItemExtra.add(gift.objectId);
          }
        }
      }
    }

    itemDigging.clear();
    if (digging != null) {
      for (final reward in digging!.rewards) {
        for (final gift in reward.gifts) {
          if (gift.isStatItem) {
            itemDigging.addNum(gift.objectId, gift.num);
            statItemExtra.add(gift.objectId);
          }
        }
      }
    }
    if (extra != null) {
      for (final e in extra.extraFixedItems) {
        statItemFixed.addDict(e.items);
      }
      for (final e in extra.extraItems) {
        statItemExtra.addAll(e.items.keys);
      }
    }
  }

  Map<String, dynamic> toJson() => _$EventToJson(this);
}

@JsonSerializable(converters: [CondTypeConverter()])
class EventAdd {
  EventOverwriteType overwriteType;
  int priority;
  int overwriteId;
  String overwriteText;
  String? overwriteBanner;
  CondType condType;
  int targetId;
  int startedAt;
  int endedAt;

  EventAdd({
    this.overwriteType = EventOverwriteType.unknown,
    this.priority = 0,
    this.overwriteId = 0,
    this.overwriteText = '',
    this.overwriteBanner,
    this.condType = CondType.none,
    this.targetId = 0,
    this.startedAt = 0,
    this.endedAt = 0,
  });

  factory EventAdd.fromJson(Map<String, dynamic> json) => _$EventAddFromJson(json);

  Map<String, dynamic> toJson() => _$EventAddToJson(this);
}

@JsonSerializable()
class MasterMission {
  static const int kExtraMasterMissionId = 10001;

  int id;
  int startedAt;
  int endedAt;
  int closedAt;
  List<EventMission> missions;
  List<BasicQuest> quests;

  MasterMission({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.closedAt,
    required this.missions,
    this.quests = const [],
  });

  factory MasterMission.fromJson(Map<String, dynamic> json) => _$MasterMissionFromJson(json);

  bool get isWeekly => id >= 1e5 && id < 2e5;
  bool get isLimited => id >= 2e5 && id < 3e5;

  Map<String, dynamic> toJson() => _$MasterMissionToJson(this);
}

@JsonSerializable()
class ItemSet {
  int id;
  PurchaseType purchaseType;
  int targetId;
  int setNum;
  List<Gift> gifts;

  ItemSet({
    required this.id,
    this.purchaseType = PurchaseType.none,
    required this.targetId,
    required this.setNum,
    this.gifts = const [],
  });

  factory ItemSet.fromJson(Map<String, dynamic> json) => _$ItemSetFromJson(json);

  Map<String, dynamic> toJson() => _$ItemSetToJson(this);
}

@JsonSerializable()
class NiceShop with RouteInfo {
  int id;
  // int baseShopId;
  ShopType shopType;
  List<ShopRelease> releaseConditions;
  // int eventId;
  int slot;
  int priority;

  String name;
  String detail;
  String infoMessage;
  String warningMessage;
  // pay
  PayType payType;
  ItemAmount? cost;
  List<CommonConsume> consumes;
  // purchase
  PurchaseType purchaseType;
  List<int> targetIds; // only kiaraPunisherReset and quest using more than 1
  List<ItemSet> itemSet;
  List<Gift> gifts;

  int setNum;
  int limitNum;
  int defaultLv;
  int defaultLimitCount;
  String? scriptName;
  String? scriptId;
  String? script;
  String? image;

  int openedAt;
  int closedAt;

  NiceShop({
    required this.id,
    // required this.baseShopId,
    this.shopType = ShopType.eventItem,
    this.releaseConditions = const [],
    // required this.eventId,
    this.slot = 0,
    required this.priority,
    required this.name,
    this.detail = "",
    this.infoMessage = "",
    this.warningMessage = "",
    this.payType = PayType.eventItem,
    ItemAmount? cost,
    this.consumes = const [],
    this.purchaseType = PurchaseType.none,
    this.targetIds = const [],
    this.itemSet = const [],
    this.gifts = const [],
    this.setNum = 1,
    required this.limitNum,
    this.defaultLv = 0,
    this.defaultLimitCount = 0,
    this.scriptName,
    this.scriptId,
    this.script,
    this.image,
    this.openedAt = 0,
    this.closedAt = 0,
  }) : cost = cost == null || cost.itemId == 0 ? null : cost;

  factory NiceShop.fromJson(Map<String, dynamic> json) => _$NiceShopFromJson(json);

  @override
  String get route => Routes.shopI(id);

  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) {
    return super.routeTo(
      child: child ?? ShopDetailPage(shop: this, region: region),
      popDetails: popDetails,
    );
  }

  Map<String, dynamic> toJson() => _$NiceShopToJson(this);
}

@JsonSerializable()
class ShopRelease {
  List<int> condValues;
  // int shopId;
  @CondTypeConverter()
  CondType condType;
  int condNum;
  int priority;
  bool isClosedDisp;
  String closedMessage;
  String closedItemName;

  ShopRelease({
    this.condValues = const [],
    this.condType = CondType.none,
    this.condNum = 0,
    this.priority = 0,
    this.isClosedDisp = true,
    this.closedMessage = "",
    this.closedItemName = "",
  });

  factory ShopRelease.fromJson(Map<String, dynamic> json) => _$ShopReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$ShopReleaseToJson(this);
}

@JsonSerializable()
class EventPointReward {
  int groupId;
  int point;
  List<Gift> gifts;

  // String bgImagePoint;
  // String bgImageGet;

  EventPointReward({
    this.groupId = 0,
    required this.point,
    this.gifts = const [],
    // required this.bgImagePoint,
    // required this.bgImageGet,
  });

  factory EventPointReward.fromJson(Map<String, dynamic> json) => _$EventPointRewardFromJson(json);

  Map<String, dynamic> toJson() => _$EventPointRewardToJson(this);
}

@JsonSerializable()
class EventPointGroup {
  int groupId;
  String name;
  String? icon;

  EventPointGroup({
    this.groupId = 0,
    this.name = "",
    String? icon,
  }) : icon = icon != null && icon.endsWith('/Items/0.png') ? null : icon;

  Transl<String, String> get lName => Transl.itemNames(name);

  factory EventPointGroup.fromJson(Map<String, dynamic> json) => _$EventPointGroupFromJson(json);

  Map<String, dynamic> toJson() => _$EventPointGroupToJson(this);
}

@JsonSerializable()
class EventPointBuff {
  int id;
  List<int> funcIds;
  int groupId;
  int eventPoint;
  String name;

  // String detail;
  String icon;
  ItemBGType background;
  int value;
  String? skillIcon;
  int lv; // display only? use CE skill condQuest

  EventPointBuff({
    required this.id,
    this.funcIds = const [],
    this.groupId = 0,
    required this.eventPoint,
    required this.name,
    // required this.detail,
    required this.icon,
    this.background = ItemBGType.zero,
    this.value = 0,
    this.skillIcon,
    this.lv = 0,
  });

  factory EventPointBuff.fromJson(Map<String, dynamic> json) => _$EventPointBuffFromJson(json);

  Map<String, dynamic> toJson() => _$EventPointBuffToJson(this);
}

@JsonSerializable()
class EventPointActivity {
  int groupId;
  int point;
  EventPointActivityObjectType objectType;
  int objectId;
  int objectValue;

  EventPointActivity({
    this.groupId = 0,
    this.point = 0,
    this.objectType = EventPointActivityObjectType.none,
    this.objectId = 0,
    this.objectValue = 0,
  });

  factory EventPointActivity.fromJson(Map<String, dynamic> json) => _$EventPointActivityFromJson(json);

  Map<String, dynamic> toJson() => _$EventPointActivityToJson(this);
}

@JsonSerializable()
class EventMissionConditionDetail {
  int id;
  int missionTargetId;
  int missionCondType;
  int logicType;
  List<int> targetIds;
  List<int> addTargetIds;
  List<NiceTrait> targetQuestIndividualities;
  DetailMissionCondLinkType conditionLinkType;
  List<int>? targetEventIds;
  // used for custom mission
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool? useAnd;

  EventMissionConditionDetail({
    required this.id,
    this.missionTargetId = 0,
    required this.missionCondType,
    this.logicType = 1,
    this.targetIds = const [],
    this.addTargetIds = const [],
    this.targetQuestIndividualities = const [],
    this.conditionLinkType = DetailMissionCondLinkType.missionStart,
    this.targetEventIds,
    this.useAnd,
  });

  factory EventMissionConditionDetail.fromJson(Map<String, dynamic> json) =>
      _$EventMissionConditionDetailFromJson(json);

  Map<String, dynamic> toJson() => _$EventMissionConditionDetailToJson(this);
}

@JsonSerializable()
class EventMissionCondition {
  int id;
  MissionProgressType missionProgressType;
  int priority;

  // int missionTargetId;
  int condGroup;
  @CondTypeConverter()
  CondType condType;
  List<int> targetIds;
  int targetNum;

  String conditionMessage;
  String closedMessage;
  int flag;
  List<EventMissionConditionDetail>? details;

  EventMissionCondition({
    required this.id,
    required this.missionProgressType,
    this.priority = 0,
    // required this.missionTargetId,
    this.condGroup = 1,
    this.condType = CondType.none,
    required this.targetIds,
    required this.targetNum,
    required this.conditionMessage,
    this.closedMessage = "",
    this.flag = 0,
    this.details,
  });

  factory EventMissionCondition.fromJson(Map<String, dynamic> json) => _$EventMissionConditionFromJson(json);

  Map<String, dynamic> toJson() => _$EventMissionConditionToJson(this);
}

@JsonSerializable()
class EventMission {
  int id;

  // int flag;
  MissionType type;

  // int missionTargetId;
  int dispNo;
  String name;

  // String detail;
  int startedAt;
  int endedAt;
  int closedAt;
  MissionRewardType rewardType;
  List<Gift> gifts;
  int bannerGroup;
  int priority;

  // int rewardRarity;
  // int notfyPriority;
  // int presentMessageId;
  List<EventMissionCondition> conds;

  EventMission({
    required this.id,
    // required this.flag,
    this.type = MissionType.event,
    // required this.missionTargetId,
    required this.dispNo,
    required this.name,
    // required this.detail,
    this.startedAt = 0,
    this.endedAt = 0,
    this.closedAt = 0,
    this.rewardType = MissionRewardType.gift,
    required this.gifts,
    this.bannerGroup = 0,
    this.priority = 0,
    // required this.rewardRarity,
    // required this.notfyPriority,
    // required this.presentMessageId,
    this.conds = const [],
  });

  factory EventMission.fromJson(Map<String, dynamic> json) => _$EventMissionFromJson(json);

  Map<String, dynamic> toJson() => _$EventMissionToJson(this);
}

@JsonSerializable()
class EventRandomMission {
  // int  eventId;
  int missionId;
  int missionRank;
  @CondTypeConverter()
  CondType condType; // CondType.progressValueEqual
  int condId; // eventId
  int condNum; // 0-5, detective rank

  EventRandomMission({
    required this.missionId,
    required this.missionRank,
    this.condType = CondType.none,
    required this.condId,
    required this.condNum,
  });

  factory EventRandomMission.fromJson(Map<String, dynamic> json) => _$EventRandomMissionFromJson(json);

  Map<String, dynamic> toJson() => _$EventRandomMissionToJson(this);
}

@JsonSerializable()
class NiceEventMissionGroup {
  // int  eventId;
  int id;
  List<int> missionIds;

  NiceEventMissionGroup({
    required this.id,
    this.missionIds = const [],
  });

  factory NiceEventMissionGroup.fromJson(Map<String, dynamic> json) => _$NiceEventMissionGroupFromJson(json);

  Map<String, dynamic> toJson() => _$NiceEventMissionGroupToJson(this);
}

@JsonSerializable()
class EventCommandAssist {
  int id;
  int priority;
  int lv;
  String name;
  CardType assistCard;
  String image;
  NiceSkill skill;
  int skillLv;
  List<CommonRelease> releaseConditions;

  EventCommandAssist({
    required this.id,
    this.priority = 0,
    required this.lv,
    required this.name,
    this.assistCard = CardType.none,
    required this.image,
    required this.skill,
    required this.skillLv,
    this.releaseConditions = const [],
  });

  factory EventCommandAssist.fromJson(Map<String, dynamic> json) => _$EventCommandAssistFromJson(json);

  Map<String, dynamic> toJson() => _$EventCommandAssistToJson(this);
}

@JsonSerializable()
class EventTowerReward {
  int floor;
  List<Gift> gifts;

  // String boardMessage;
  // String rewardGet;
  // String banner;

  EventTowerReward({
    required this.floor,
    required this.gifts,
    // required this.boardMessage,
    // required this.rewardGet,
    // required this.banner,
  });

  factory EventTowerReward.fromJson(Map<String, dynamic> json) => _$EventTowerRewardFromJson(json);

  Map<String, dynamic> toJson() => _$EventTowerRewardToJson(this);
}

@JsonSerializable()
class EventTower {
  int towerId;
  String name;
  List<EventTowerReward> rewards;

  EventTower({
    required this.towerId,
    required this.name,
    required this.rewards,
  });

  String get lName => Transl.misc2('TowerName', name);

  factory EventTower.fromJson(Map<String, dynamic> json) => _$EventTowerFromJson(json);

  Map<String, dynamic> toJson() => _$EventTowerToJson(this);
}

@JsonSerializable()
class EventLotteryBox {
  // int id;
  int boxIndex;
  int talkId;
  int no;
  int type;
  List<Gift> gifts;
  int maxNum;
  bool isRare;

  // int priority;
  // String detail;

  // String icon;
  // String banner;

  EventLotteryBox({
    // required this.id,
    this.boxIndex = 0,
    this.talkId = 0,
    required this.no,
    this.type = 1,
    this.gifts = const [],
    required this.maxNum,
    this.isRare = false,
    // this.priority=0,
    // required this.detail,
    // required this.icon,
    // required this.banner,
  });

  factory EventLotteryBox.fromJson(Map<String, dynamic> json) => _$EventLotteryBoxFromJson(json);

  Map<String, dynamic> toJson() => _$EventLotteryBoxToJson(this);
}

@JsonSerializable()
class EventLottery {
  int id;
  int slot;
  PayType payType;
  ItemAmount cost;
  int priority;
  bool limited;
  List<EventLotteryBox> boxes;
  List<EventLotteryTalk> talks;

  EventLottery({
    required this.id,
    this.slot = 0,
    this.payType = PayType.eventItem,
    required this.cost,
    required this.priority,
    required this.limited,
    required this.boxes,
    this.talks = const [],
  });

  factory EventLottery.fromJson(Map<String, dynamic> json) => _$EventLotteryFromJson(json);

  int get maxBoxIndex => _maxBoxIndex ??= Maths.max(boxes.map((e) => e.boxIndex), 0);
  int? _maxBoxIndex;

  Map<int, int> get lastBoxItems {
    if (_lastBoxItems != null) return _lastBoxItems!;
    Map<int, int> items = {};
    final _maxBoxIndex = maxBoxIndex;
    for (final box in boxes) {
      if (box.boxIndex != _maxBoxIndex || box.isRare) continue;
      for (final gift in box.gifts) {
        if (gift.isStatItem) {
          items.addNum(gift.objectId, gift.num * box.maxNum);
        }
      }
    }
    return items;
  }

  Map<int, int>? _lastBoxItems;

  Map<String, dynamic> toJson() => _$EventLotteryToJson(this);
}

@JsonSerializable()
class EventLotteryTalk {
  int talkId;
  int no;
  int guideImageId;
  List<VoiceLine> beforeVoiceLines;
  List<VoiceLine> afterVoiceLines;
  bool isRare;

  EventLotteryTalk({
    required this.talkId,
    required this.no,
    required this.guideImageId,
    this.beforeVoiceLines = const [],
    this.afterVoiceLines = const [],
    required this.isRare,
  });

  factory EventLotteryTalk.fromJson(Map<String, dynamic> json) => _$EventLotteryTalkFromJson(json);

  Map<String, dynamic> toJson() => _$EventLotteryTalkToJson(this);
}

@JsonSerializable()
class CommonConsume {
  int id;
  int priority;
  CommonConsumeType type;
  int objectId;
  int num;

  CommonConsume({
    required this.id,
    required this.priority,
    required this.type,
    required this.objectId,
    required this.num,
  });

  factory CommonConsume.fromJson(Map<String, dynamic> json) => _$CommonConsumeFromJson(json);

  Map<String, dynamic> toJson() => _$CommonConsumeToJson(this);
}

@JsonSerializable()
class EventTreasureBoxGift {
  int id;
  int idx;
  List<Gift> gifts;
  int collateralUpperLimit;

  EventTreasureBoxGift({
    required this.id,
    required this.idx,
    required this.gifts,
    required this.collateralUpperLimit,
  });

  factory EventTreasureBoxGift.fromJson(Map<String, dynamic> json) => _$EventTreasureBoxGiftFromJson(json);

  Map<String, dynamic> toJson() => _$EventTreasureBoxGiftToJson(this);
}

@JsonSerializable()
class EventTreasureBox {
  int slot;
  int id;
  int idx;
  List<EventTreasureBoxGift> treasureBoxGifts;
  int maxDrawNumOnce;
  List<Gift> extraGifts;
  List<CommonConsume> consumes;

  EventTreasureBox({
    required this.slot,
    required this.id,
    required this.idx,
    required this.treasureBoxGifts,
    required this.maxDrawNumOnce,
    required this.extraGifts,
    this.consumes = const [],
  });

  factory EventTreasureBox.fromJson(Map<String, dynamic> json) => _$EventTreasureBoxFromJson(json);

  Map<String, dynamic> toJson() => _$EventTreasureBoxToJson(this);
}

@JsonSerializable()
class EventRewardSceneGuide {
  int imageId;
  int limitCount;
  String image;
  int? faceId;
  String? displayName;
  int? weight;
  int? unselectedMax;

  EventRewardSceneGuide({
    required this.imageId,
    this.limitCount = 0,
    required this.image,
    this.faceId = 0,
    this.displayName,
    this.weight,
    this.unselectedMax,
  });

  factory EventRewardSceneGuide.fromJson(Map<String, dynamic> json) => _$EventRewardSceneGuideFromJson(json);

  Map<String, dynamic> toJson() => _$EventRewardSceneGuideToJson(this);
}

@JsonSerializable()
class EventRewardScene {
  int slot;
  int groupId;
  int type;
  List<EventRewardSceneGuide> guides;
  String tabOnImage;
  String tabOffImage;
  String? image;
  String bg;
  BgmEntity bgm;
  BgmEntity afterBgm;
  List<EventRewardSceneFlag> flags;

  EventRewardScene({
    this.slot = 0,
    this.groupId = 0,
    this.type = 0,
    this.guides = const [],
    required this.tabOnImage,
    required this.tabOffImage,
    this.image,
    required this.bg,
    required this.bgm,
    required this.afterBgm,
    this.flags = const [],
  });

  factory EventRewardScene.fromJson(Map<String, dynamic> json) => _$EventRewardSceneFromJson(json);

  Map<String, dynamic> toJson() => _$EventRewardSceneToJson(this);
}

@JsonSerializable()
class EventVoicePlay {
  int slot;
  int idx;
  int guideImageId;
  List<VoiceLine> voiceLines;
  List<VoiceLine> confirmVoiceLines;
  @CondTypeConverter()
  CondType condType;
  int condValue;
  int startedAt;
  int endedAt;
  EventVoicePlay({
    required this.slot,
    required this.idx,
    required this.guideImageId,
    this.voiceLines = const [],
    this.confirmVoiceLines = const [],
    required this.condType,
    required this.condValue,
    required this.startedAt,
    required this.endedAt,
  });

  factory EventVoicePlay.fromJson(Map<String, dynamic> json) => _$EventVoicePlayFromJson(json);

  Map<String, dynamic> toJson() => _$EventVoicePlayToJson(this);
}

@JsonSerializable()
class EventDigging {
  int sizeX;
  int sizeY;
  String bgImage;
  Item eventPointItem;
  int resettableDiggedNum;
  List<EventDiggingBlock> blocks;
  List<EventDiggingReward> rewards;

  EventDigging({
    required this.sizeX,
    required this.sizeY,
    required this.bgImage,
    required this.eventPointItem,
    required this.resettableDiggedNum,
    this.blocks = const [],
    this.rewards = const [],
  });

  factory EventDigging.fromJson(Map<String, dynamic> json) => _$EventDiggingFromJson(json);

  Map<String, dynamic> toJson() => _$EventDiggingToJson(this);

  // eventId, blockId, rewardId
  static Map<int, Map<int, List<int>>> blockRewards = const {
    80367: {
      // white
      3: [10, 5, 6],
      12: [19, 20, 21],
      13: [28, 29, 30],
      14: [38, 39, 41],
      15: [46, 47, 48],
      // grey
      1: [4, 8],
      4: [13, 14, 15],
      5: [22, 23, 24],
      6: [31, 32, 33],
      7: [35, 40, 42],
      //
      2: [7, 11],
      8: [16, 17, 18],
      9: [25, 26, 27],
      10: [34, 37, 36],
      11: [43, 44, 45],
    }
  };
}

@JsonSerializable()
class EventDiggingBlock {
  int id;
  String image;
  List<CommonConsume> consumes;
  int objectId;
  int diggingEventPoint;
  int blockNum;

  EventDiggingBlock({
    required this.id,
    required this.image,
    this.consumes = const [],
    required this.objectId,
    required this.diggingEventPoint,
    required this.blockNum,
  });

  factory EventDiggingBlock.fromJson(Map<String, dynamic> json) => _$EventDiggingBlockFromJson(json);

  Map<String, dynamic> toJson() => _$EventDiggingBlockToJson(this);
}

@JsonSerializable()
class EventDiggingReward {
  int id;
  List<Gift> gifts;
  int rewardSize;

  EventDiggingReward({
    required this.id,
    this.gifts = const [],
    required this.rewardSize,
  });

  factory EventDiggingReward.fromJson(Map<String, dynamic> json) => _$EventDiggingRewardFromJson(json);

  Map<String, dynamic> toJson() => _$EventDiggingRewardToJson(this);
}

@JsonSerializable()
class EventCooltimeReward {
  int spotId;
  int lv;
  String name;
  // CommonRelease commonRelease;
  List<CommonRelease> releaseConditions;
  int cooltime;
  int addEventPointRate;
  List<Gift> gifts;
  int upperLimitGiftNum;

  EventCooltimeReward({
    required this.spotId,
    required this.lv,
    required this.name,
    this.releaseConditions = const [],
    required this.cooltime,
    required this.addEventPointRate,
    required this.gifts,
    required this.upperLimitGiftNum,
  });

  factory EventCooltimeReward.fromJson(Map<String, dynamic> json) => _$EventCooltimeRewardFromJson(json);

  Map<String, dynamic> toJson() => _$EventCooltimeRewardToJson(this);
}

@JsonSerializable()
class EventCooltime {
  List<EventCooltimeReward> rewards;

  EventCooltime({
    this.rewards = const [],
  });

  factory EventCooltime.fromJson(Map<String, dynamic> json) => _$EventCooltimeFromJson(json);

  Map<String, dynamic> toJson() => _$EventCooltimeToJson(this);
}

@JsonSerializable()
class EventRecipeGift {
  int idx;
  int displayOrder;
  int topIconId;
  List<Gift> gifts;

  EventRecipeGift({
    required this.idx,
    required this.displayOrder,
    this.topIconId = 0,
    this.gifts = const [],
  });

  factory EventRecipeGift.fromJson(Map<String, dynamic> json) => _$EventRecipeGiftFromJson(json);

  Map<String, dynamic> toJson() => _$EventRecipeGiftToJson(this);
}

@JsonSerializable()
class EventRecipe {
  int id;
  String icon;
  String name;
  int maxNum;
  Item eventPointItem;
  int eventPointNum;
  List<CommonConsume> consumes;
  List<CommonRelease> releaseConditions;
  String closedMessage;
  List<EventRecipeGift> recipeGifts;

  EventRecipe({
    required this.id,
    required this.icon,
    required this.name,
    required this.maxNum,
    required this.eventPointItem,
    required this.eventPointNum,
    this.consumes = const [],
    this.releaseConditions = const [],
    this.closedMessage = '',
    this.recipeGifts = const [],
  });

  factory EventRecipe.fromJson(Map<String, dynamic> json) => _$EventRecipeFromJson(json);

  Map<String, dynamic> toJson() => _$EventRecipeToJson(this);
}

@JsonSerializable()
class EventFortificationDetail {
  int position;
  String name;
  SvtClassSupportGroupType className;
  List<CommonRelease> releaseConditions;

  EventFortificationDetail({
    required this.position,
    required this.name,
    this.className = SvtClassSupportGroupType.notSupport,
    this.releaseConditions = const [],
  });

  factory EventFortificationDetail.fromJson(Map<String, dynamic> json) => _$EventFortificationDetailFromJson(json);

  Map<String, dynamic> toJson() => _$EventFortificationDetailToJson(this);
}

@JsonSerializable()
class EventFortificationSvt {
  int position;
  EventFortificationSvtType type;
  int svtId;
  int limitCount;
  int lv;
  List<CommonRelease> releaseConditions;

  EventFortificationSvt({
    required this.position,
    this.type = EventFortificationSvtType.none,
    required this.svtId,
    required this.limitCount,
    required this.lv,
    this.releaseConditions = const [],
  });

  factory EventFortificationSvt.fromJson(Map<String, dynamic> json) => _$EventFortificationSvtFromJson(json);

  Map<String, dynamic> toJson() => _$EventFortificationSvtToJson(this);
}

@JsonSerializable()
class EventFortification {
  int idx;
  String name;
  int x;
  int y;
  int rewardSceneX;
  int rewardSceneY;
  int maxFortificationPoint;
  EventWorkType workType;
  List<Gift> gifts;
  List<CommonRelease> releaseConditions;
  List<EventFortificationDetail> details;
  List<EventFortificationSvt> servants;

  EventFortification({
    required this.idx,
    required this.name,
    required this.x,
    required this.y,
    required this.rewardSceneX,
    required this.rewardSceneY,
    required this.maxFortificationPoint,
    this.workType = EventWorkType.unknown,
    this.gifts = const [],
    this.releaseConditions = const [],
    this.details = const [],
    this.servants = const [],
  });

  factory EventFortification.fromJson(Map<String, dynamic> json) => _$EventFortificationFromJson(json);

  Map<String, dynamic> toJson() => _$EventFortificationToJson(this);
}

@JsonSerializable()
class EventBulletinBoard {
  int bulletinBoardId;
  String message;
  int? probability;
  List<EventBulletinBoardRelease> releaseConditions;
  // int dispOrder;
  List<EventBulletinBoardScript>? script;

  EventBulletinBoard({
    required this.bulletinBoardId,
    required this.message,
    this.probability,
    this.releaseConditions = const [],
    this.script,
  });

  factory EventBulletinBoard.fromJson(Map<String, dynamic> json) => _$EventBulletinBoardFromJson(json);

  Map<String, dynamic> toJson() => _$EventBulletinBoardToJson(this);
}

@JsonSerializable()
class EventBulletinBoardScript with DataScriptBase {
  String? icon;
  String? name;

  EventBulletinBoardScript({
    this.icon,
    this.name,
  });

  factory EventBulletinBoardScript.fromJson(Map<String, dynamic> json) =>
      _$EventBulletinBoardScriptFromJson(json)..setSource(json);

  Map<String, dynamic> toJson() => _$EventBulletinBoardScriptToJson(this);
}

@JsonSerializable()
class EventBulletinBoardRelease {
  int condGroup;
  @CondTypeConverter()
  CondType condType;
  int condTargetId;
  int condNum;

  EventBulletinBoardRelease({
    this.condGroup = 1,
    this.condType = CondType.none,
    this.condTargetId = 0,
    this.condNum = 0,
  });

  factory EventBulletinBoardRelease.fromJson(Map<String, dynamic> json) => _$EventBulletinBoardReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$EventBulletinBoardReleaseToJson(this);
}

@JsonSerializable()
class EventCampaign {
  List<int> targetIds;
  List<int> warIds;
  CombineAdjustTarget target;
  int idx;
  int value;
  EventCombineCalc calcType;
  // String entryCondMessage;

  EventCampaign({
    this.targetIds = const [],
    this.warIds = const [],
    this.target = CombineAdjustTarget.none,
    this.idx = 0,
    required this.value,
    this.calcType = EventCombineCalc.multiplication,
    // this.entryCondMessage = '',
  });

  factory EventCampaign.fromJson(Map<String, dynamic> json) => _$EventCampaignFromJson(json);

  Map<String, dynamic> toJson() => _$EventCampaignToJson(this);
}

/// If [questId]=0 and [phase]=0, means all quests
@JsonSerializable()
class EventQuest {
  int questId;
  // int phase;  // currently all are 0

  EventQuest({
    required this.questId,
    // this.phase = 0,
  });

  factory EventQuest.fromJson(Map<String, dynamic> json) => _$EventQuestFromJson(json);

  Map<String, dynamic> toJson() => _$EventQuestToJson(this);
}

@JsonSerializable()
class HeelPortrait {
  int id;
  String name;
  String image;
  // CondType dispCondType;
  // int dispCondId;
  // int dispCondNum;
  // Map<String,dynamic> script;

  HeelPortrait({
    required this.id,
    this.name = "",
    required this.image,
  });

  factory HeelPortrait.fromJson(Map<String, dynamic> json) => _$HeelPortraitFromJson(json);

  Map<String, dynamic> toJson() => _$HeelPortraitToJson(this);
}

@JsonSerializable()
class EventMural {
  int id;
  String message;
  List<String> images;
  int num;
  int condQuestId;
  int condQuestPhase;
  EventMural({
    this.id = 0,
    this.message = "",
    this.images = const [],
    this.num = 0,
    this.condQuestId = 0,
    this.condQuestPhase = 0,
  });

  factory EventMural.fromJson(Map<String, dynamic> json) => _$EventMuralFromJson(json);

  Map<String, dynamic> toJson() => _$EventMuralToJson(this);
}

enum EventOverwriteType {
  unknown,
  bgImage,
  bgm,
  name,
  banner,
  noticeBanner,
}

enum PurchaseType {
  none,
  item,
  equip,
  friendGacha,
  servant,
  setItem,
  quest,
  eventShop,
  eventSvtGet,
  manaShop,
  storageSvt,
  storageSvtequip,
  bgm,
  costumeRelease,
  bgmRelease,
  lotteryShop,
  eventFactory,
  itemAsPresent,
  commandCode,
  gift,
  eventSvtJoin,
  assist,
  kiaraPunisherReset,
}

enum ShopType {
  none,
  eventItem,
  mana,
  rarePri,
  svtStorage,
  svtEquipStorage,
  stoneFragments,
  svtAnonymous,
  bgm,
  limitMaterial,
  grailFragments,
  svtCostume,
  startUpSummon,
  shop13,
  tradeAp,
  shop15,
}

enum MissionProgressType {
  none(0),
  regist(1),
  openCondition(2),
  start(3),
  clear(4),
  achieve(5),
  ;

  const MissionProgressType(this.id);
  final int id;
}

enum MissionType {
  none,
  event,
  weekly,
  daily,
  extra,
  limited,
  complete,
  random,
}

enum MissionRewardType {
  gift,
  extra,
  set,
}

enum PayType {
  stone,
  qp,
  friendPoint,
  mana,
  ticket,
  eventItem,
  chargeStone,
  stoneFragments,
  anonymous,
  rarePri,
  item,
  grailFragments,
  free,
  commonConsume,
}

enum CommonConsumeType {
  item,
  ap,
}

enum EventType {
  none(0),
  raidBoss(1),
  pvp(2),
  point(3),
  loginBonus(4),
  combineCampaign(5),
  shop(6),
  questCampaign(7),
  bank(8),
  serialCampaign(9),
  loginCampaign(10),
  loginCampaignRepeat(11),
  eventQuest(12), // main
  svtequipCombineCampaign(13),
  terminalBanner(14),
  boxGacha(15),
  boxGachaPoint(16),
  loginCampaignStrict(17),
  totalLogin(18),
  comebackCampaign(19),
  locationCampaign(20),
  comebackCampaign2(21),
  warBoard(22), // main
  combineCosutumeItem(23),
  myroomMultipleViewCampaign(24),
  interludeCampaign(25),
  myroomPhotoCampaign(26);

  const EventType(this.id);
  final int id;
}

enum DetailMissionCondLinkType {
  eventStart,
  missionStart,
  masterMissionStart,
  randomMissionStart,
}

// TODO: use enum
/// https://github.com/atlasacademy/apps/blob/master/packages/api-connector/src/Schema/Mission.ts
class DetailCondType {
  const DetailCondType._();
  // [1, 2, 3, 6, 7, 8, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 24, 25, 26, 27, 28, 31, 32, 33, 34, 36]
  static const int enemyKillNum = 1; // traits AND
  static const int enemyIndividualityKillNum = 2; // traits OR
  static const int itemGetTotal = 3;
  static const int battleSvtInDeck = 4; // Unused
  static const int battleSvtEquipInDeck = 5; // Unused
  static const int targetQuestEnemyKillNum = 6;
  static const int targetQuestEnemyIndividualityKillNum = 7;
  static const int targetQuestItemGetTotal = 8;
  static const int questClearOnce = 9;
  static const int questClearNum1 = 10;
  static const int itemGetBattle = 12;
  static const int defeatEnemyIndividuality = 13;
  static const int defeatEnemyClass = 14;
  static const int defeatServantClass = 15;
  static const int defeatEnemyNotServantClass = 16;
  static const int battleSvtIndividualityInDeck = 17;
  static const int battleSvtClassInDeck = 18; // Filter by svt class
  static const int svtGetBattle = 19; // Embers are svt instead of items
  static const int friendPointSummon = 21;
  static const int battleSvtIdInDeck1 = 22;
  static const int battleSvtIdInDeck2 = 23; // Filter by svt ID
  static const int questClearNum2 = 24; // Not sure what's the difference QUEST_CLEAR_NUM_1
  static const int diceUse = 25; // Probably Fate/Requiem event
  static const int squareAdvanced = 26;
  static const int moreFriendFollower = 27; // 5th Anniversary missions
  static const int questTypeClear = 28; // 22M Download Campaign
  static const int questClearNumIncludingGrailFront = 31;
  static const int warMainQuestClear = 32; // 「Lostbelt No.7」開幕前メインクエストクリア応援キャンペーン 第1弾
  static const int svtFriendshipGet = 33; // 28M Download Campaign
  static const int battleSvtIdInFrontDeck = 34;
  static const int questChallengeNum = 36; // similar to CondType.questChallengeNum

  /// custom, only used in app
  static const int questClearIndividuality = 999;
}

enum EventRewardSceneFlag {
  npcGuide,
  isChangeSvtByChangedTab,
  isHideTab,
}

enum CombineAdjustTarget {
  none, // custom
  combineQp,
  combineExp,
  activeSkill,
  largeSuccess,
  superSuccess,
  limitQp,
  limitItem,
  skillQp,
  skillItem,
  treasureDeviceQp,
  treasureDeviceItem,
  questAp,
  questExp,
  questQp,
  questDrop,
  svtequipCombineQp,
  svtequipCombineExp,
  svtequipLargeSuccess,
  svtequipSuperSuccess,
  questEventPoint,
  enemySvtClassPickUp,
  eventEachDropNum,
  eventEachDropRate,
  questFp,
  questApFirstTime,
  dailyDropUp,
  exchangeSvtCombineExp,
  questUseContinueItem,
  friendPointGachaFreeDrawNum,
  questUseFriendshipUpItem,
  questFriendship,
  largeSuccessByClass,
  superSuccessByClass,
  exchangeSvt,
}

enum EventCombineCalc {
  addition,
  multiplication,
  fixedValue,
}

// FuncType.eventFortificationPointUp: DataVal.Individuality
enum EventWorkType {
  militsryAffairs, // 1 军务 √
  internalAffairs, // 2 政务 x
  farmming, // 3 内务 x
  unknown, // in case DW correct the naming
  ;

  String get shownName => Transl.enums(this, (enums) => enums.eventWorkType).l;
  String get icon => getIcon(index + 1);
  static String getIcon(int indiv) {
    final suffix = indiv.toString().padLeft(2, '0');
    return 'https://static.atlasacademy.io/JP/EventUI/Prefabs/80400/DownloadEventUIAtlas8040001/icon_event_80400$suffix.png';
  }
}

enum EventFortificationSvtType {
  userSvt,
  npc,
  none,
}

enum EventPointActivityObjectType {
  none,
  questId,
  skillId,
  shopId,
}
