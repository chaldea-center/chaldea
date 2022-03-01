import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';

import '../userdata/userdata.dart';
import 'gamedata.dart';

part '../../generated/models/gamedata/event.g.dart';

@JsonSerializable()
class MasterMission {
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
    required this.quests,
  });

  factory MasterMission.fromJson(Map<String, dynamic> json) =>
      _$MasterMissionFromJson(json);
}

@JsonSerializable()
class ItemSet {
  int id;
  PurchaseType purchaseType;
  int targetId;
  int setNum;

  ItemSet({
    required this.id,
    required this.purchaseType,
    required this.targetId,
    required this.setNum,
  });

  factory ItemSet.fromJson(Map<String, dynamic> json) =>
      _$ItemSetFromJson(json);
}

@JsonSerializable()
class NiceShop {
  // int id;
  // int baseShopId;
  ShopType shopType;

  // int eventId;
  int slot;
  int priority;

  // String name;
  // String detail;
  String infoMessage;

  // String warningMessage;
  PayType payType;
  ItemAmount cost;
  PurchaseType purchaseType;
  List<int> targetIds;
  List<ItemSet> itemSet;
  int setNum;
  int limitNum;
  int defaultLv;
  int defaultLimitCount;
  String? scriptName;
  String? scriptId;
  String? script;

  // int openedAt;
  // int closedAt;

  NiceShop({
    // required this.id,
    // required this.baseShopId,
    this.shopType = ShopType.eventItem,
    // required this.eventId,
    required this.slot,
    required this.priority,
    // required this.name,
    // required this.detail,
    this.infoMessage = "",
    // this.warningMessage = "",
    required this.payType,
    required this.cost,
    required this.purchaseType,
    this.targetIds = const [],
    this.itemSet = const [],
    this.setNum = 1,
    required this.limitNum,
    this.defaultLv = 0,
    this.defaultLimitCount = 0,
    this.scriptName,
    this.scriptId,
    this.script,
    // required this.openedAt,
    // required this.closedAt,
  });

  factory NiceShop.fromJson(Map<String, dynamic> json) =>
      _$NiceShopFromJson(json);
}

@JsonSerializable()
class EventReward {
  int groupId;
  int point;
  List<Gift> gifts;

  // String bgImagePoint;
  // String bgImageGet;

  EventReward({
    required this.groupId,
    required this.point,
    required this.gifts,
    // required this.bgImagePoint,
    // required this.bgImageGet,
  });

  factory EventReward.fromJson(Map<String, dynamic> json) =>
      _$EventRewardFromJson(json);
}

@JsonSerializable()
class EventPointGroup {
  int groupId;
  String name;
  String icon;

  EventPointGroup({
    required this.groupId,
    required this.name,
    required this.icon,
  });

  factory EventPointGroup.fromJson(Map<String, dynamic> json) =>
      _$EventPointGroupFromJson(json);
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

  EventPointBuff({
    required this.id,
    this.funcIds = const [],
    this.groupId = 0,
    required this.eventPoint,
    required this.name,
    // required this.detail,
    required this.icon,
    required this.background,
    required this.value,
  });

  factory EventPointBuff.fromJson(Map<String, dynamic> json) =>
      _$EventPointBuffFromJson(json);
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

  EventMissionConditionDetail({
    required this.id,
    required this.missionTargetId,
    required this.missionCondType,
    required this.logicType,
    this.targetIds = const [],
    this.addTargetIds = const [],
    this.targetQuestIndividualities = const [],
    required this.conditionLinkType,
    this.targetEventIds,
  });

  factory EventMissionConditionDetail.fromJson(Map<String, dynamic> json) =>
      _$EventMissionConditionDetailFromJson(json);
}

@JsonSerializable()
class EventMissionCondition {
  int id;
  MissionProgressType missionProgressType;
  int priority;

  // int missionTargetId;
  int condGroup;
  @JsonKey(fromJson: toEnumCondType)
  CondType condType;
  List<int> targetIds;
  int targetNum;

  // String conditionMessage;
  String closedMessage;
  int flag;
  EventMissionConditionDetail? detail;

  EventMissionCondition({
    required this.id,
    required this.missionProgressType,
    this.priority = 0,
    // required this.missionTargetId,
    required this.condGroup,
    required this.condType,
    required this.targetIds,
    required this.targetNum,
    // required this.conditionMessage,
    this.closedMessage = "",
    this.flag = 0,
    this.detail,
  });

  factory EventMissionCondition.fromJson(Map<String, dynamic> json) =>
      _$EventMissionConditionFromJson(json);
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
    required this.rewardType,
    required this.gifts,
    this.bannerGroup = 0,
    this.priority = 0,
    // required this.rewardRarity,
    // required this.notfyPriority,
    // required this.presentMessageId,
    this.conds = const [],
  });

  factory EventMission.fromJson(Map<String, dynamic> json) =>
      _$EventMissionFromJson(json);
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

  factory EventTowerReward.fromJson(Map<String, dynamic> json) =>
      _$EventTowerRewardFromJson(json);
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

  factory EventTower.fromJson(Map<String, dynamic> json) =>
      _$EventTowerFromJson(json);
}

@JsonSerializable()
class EventLotteryBox {
  // int id;
  int boxIndex;
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

  factory EventLotteryBox.fromJson(Map<String, dynamic> json) =>
      _$EventLotteryBoxFromJson(json);
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

  EventLottery({
    required this.id,
    this.slot = 0,
    required this.payType,
    required this.cost,
    required this.priority,
    required this.limited,
    required this.boxes,
  });

  factory EventLottery.fromJson(Map<String, dynamic> json) =>
      _$EventLotteryFromJson(json);

  int get maxBoxIndex =>
      _maxBoxIndex ??= Maths.max(boxes.map((e) => e.boxIndex));
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
}

@JsonSerializable()
class CommonConsume {
  int id;
  int priority;

  // CommonConsumeType type;
  int objectId;
  int num;

  CommonConsume({
    required this.id,
    required this.priority,
    // required this.type,
    required this.objectId,
    required this.num,
  });

  factory CommonConsume.fromJson(Map<String, dynamic> json) =>
      _$CommonConsumeFromJson(json);
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

  factory EventTreasureBoxGift.fromJson(Map<String, dynamic> json) =>
      _$EventTreasureBoxGiftFromJson(json);
}

@JsonSerializable()
class EventTreasureBox {
  int slot;
  int id;
  int idx;
  List<EventTreasureBoxGift> treasureBoxGifts;
  int maxDrawNumOnce;
  List<Gift> extraGifts;
  CommonConsume commonConsume;

  EventTreasureBox({
    required this.slot,
    required this.id,
    required this.idx,
    required this.treasureBoxGifts,
    required this.maxDrawNumOnce,
    required this.extraGifts,
    required this.commonConsume,
  });

  factory EventTreasureBox.fromJson(Map<String, dynamic> json) =>
      _$EventTreasureBoxFromJson(json);
}

@JsonSerializable()
class Event {
  int id;
  EventType type;
  String name;
  String shortName;
  String detail;
  String? noticeBanner;
  String? banner;
  String? icon;
  int bannerPriority;
  int noticeAt;
  int startedAt;
  int endedAt;
  int finishedAt;
  int materialOpenedAt;
  List<int> warIds;
  List<NiceShop> shop;
  List<EventReward> rewards; // point rewards
  List<EventPointGroup> pointGroups;
  List<EventPointBuff> pointBuffs;
  List<EventMission> missions;
  List<EventTower> towers;
  List<EventLottery> lotteries;
  List<EventTreasureBox> treasureBoxes;

  Event({
    required this.id,
    required this.type,
    required this.name,
    this.shortName = "",
    required this.detail,
    this.noticeBanner,
    this.banner,
    this.icon,
    this.bannerPriority = 0,
    required this.noticeAt,
    required this.startedAt,
    required this.endedAt,
    required this.finishedAt,
    required this.materialOpenedAt,
    this.warIds = const [],
    this.shop = const [],
    this.rewards = const [],
    this.pointGroups = const [],
    this.pointBuffs = const [],
    this.missions = const [],
    this.towers = const [],
    this.lotteries = const [],
    this.treasureBoxes = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  EventExtra get extra => db2.gameData.wikiData.events
      .putIfAbsent(id, () => EventExtra(id: id, name: name));

  bool get isEmpty =>
      warIds.isEmpty &&
      shop.isEmpty &&
      lotteries.isEmpty &&
      missions.isEmpty &&
      treasureBoxes.isEmpty &&
      towers.isEmpty &&
      rewards.isEmpty &&
      extra.extraItems.isEmpty;

  bool isOutdated([Duration diff = const Duration(days: 32)]) {
    if (db2.curUser.region == Region.jp) {
      return DateTime.now().difference(startedAt.sec2date()) >
          const Duration(days: 31 * 12);
    }
    final t = db2.curUser.region == Region.jp
        ? endedAt
        : extra.endTime.of(db2.curUser.region);
    return t != null && t.sec2date().isBefore(DateTime.now().subtract(diff));
  }

  Transl<String, String> get lName => Transl.eventNames(name);

  String get route => Routes.eventI(id);

  // statistics
  @JsonKey(ignore: true)
  Map<int, int> itemShop = {};
  @JsonKey(ignore: true)
  Map<int, int> itemPointReward = {};
  @JsonKey(ignore: true)
  Map<int, int> itemMission = {};
  @JsonKey(ignore: true)
  Map<int, int> itemTower = {};
  @JsonKey(ignore: true)
  Map<int, Map<int, Map<int, int>>> itemLottery = {}; // lotteryId, boxNum
  @JsonKey(ignore: true)
  Map<int, Map<int, int>> itemTreasureBox = {}; //treasureBox.id
  @JsonKey(ignore: true)
  Map<int, int> itemWarReward = {};
  @JsonKey(ignore: true)
  Map<int, int> itemWarDrop = {};

  //
  @JsonKey(ignore: true)
  Map<int, int> statItemFixed = {};
  @JsonKey(ignore: true)
  Map<int, Map<int, int>> statItemLottery = {}; //unlimited
  @JsonKey(ignore: true)
  Set<int> statItemExtra = {}; // treasureBox, extraItems

  void updateStat() {
    db2.itemCenter.updateEvents(events: [this]);
  }

  void calcItems(GameData gameData) {
    statItemFixed.clear();
    statItemLottery.clear();
    statItemExtra.clear();
    // ensure war calcItems called before events
    itemWarReward.clear();
    itemWarDrop.clear();
    for (final warId in warIds) {
      final war = gameData.wars[warId];
      if (war == null) continue;
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
      if (shopItem.purchaseType == PurchaseType.item ||
          shopItem.purchaseType == PurchaseType.servant) {
        for (final id in shopItem.targetIds) {
          itemShop.addNum(id, shopItem.limitNum * shopItem.setNum);
        }
      } else if (shopItem.payType == PurchaseType.setItem) {
        for (final set in shopItem.itemSet) {
          if (set.purchaseType == PurchaseType.item ||
              set.purchaseType == PurchaseType.servant) {
            itemShop.addNum(
                set.targetId, set.setNum * shopItem.setNum * shopItem.limitNum);
          }
        }
      }
    }
    statItemFixed.addDict(itemShop);

    // point rewards
    itemPointReward.clear();
    for (final point in rewards) {
      for (final gift in point.gifts) {
        if (gift.isStatItem) itemPointReward.addNum(gift.objectId, gift.num);
      }
    }
    statItemFixed.addDict(itemPointReward);

    // mission, exclude random mission
    itemMission.clear();
    for (final mission in missions) {
      if (mission.type == MissionType.random) continue;
      if (mission.rewardType == MissionRewardType.gift) {
        for (final gift in mission.gifts) {
          if (gift.isStatItem) itemMission.addNum(gift.objectId, gift.num);
        }
      }
    }
    statItemFixed.addDict(itemMission);

    // tower, similar with point rewards
    itemTower.clear();
    for (final tower in towers) {
      for (final reward in tower.rewards) {
        for (final gift in reward.gifts) {
          if (gift.isStatItem) itemTower.addNum(gift.objectId, gift.num);
        }
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
          if (gift.isStatItem) {
            itemLottery
                .putIfAbsent(lottery.id, () => {})
                .putIfAbsent(box.boxIndex, () => {})
                .addNum(gift.objectId, gift.num * box.maxNum);
            if (lottery.limited || !_lastBoxItems.containsKey(gift.objectId)) {
              statItemFixed.addNum(gift.objectId, gift.num * box.maxNum);
            }
          }
        }
      }
    }

    //
    itemTreasureBox.clear();
    for (final box in treasureBoxes) {
      for (final boxGifts in box.treasureBoxGifts) {
        for (final gift in boxGifts.gifts) {
          if (gift.isStatItem) {
            itemTreasureBox
                .putIfAbsent(box.id, () => {})
                .addNum(gift.objectId, gift.num);
            statItemExtra.add(gift.objectId);
          }
        }
      }
    }
  }
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
}
enum MissionProgressType {
  none,
  regist,
  openCondition,
  start,
  clear,
  achieve,
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
}

enum CommonConsumeType {
  item,
}
enum EventType {
  none,
  raidBoss,
  pvp,
  point,
  loginBonus,
  combineCampaign,
  shop,
  questCampaign,
  bank,
  serialCampaign,
  loginCampaign,
  loginCampaignRepeat,
  eventQuest,
  svtequipCombineCampaign,
  terminalBanner,
  boxGacha,
  boxGachaPoint,
  loginCampaignStrict,
  totalLogin,
  comebackCampaign,
  locationCampaign,
  warBoard,
  combineCosutumeItem,
  treasureBox,
}

enum DetailMissionCondLinkType {
  eventStart,
  missionStart,
  masterMissionStart,
  randomMissionStart,
}
