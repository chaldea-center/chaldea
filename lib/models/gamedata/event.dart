part of gamedata;

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
  int id;
  int baseShopId;
  ShopType shopType;
  int eventId;
  int slot;
  int priority;
  String name;
  String detail;
  String infoMessage;
  String warningMessage;
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
  String? script;
  int openedAt;
  int closedAt;

  NiceShop({
    required this.id,
    required this.baseShopId,
    required this.shopType,
    required this.eventId,
    required this.slot,
    required this.priority,
    required this.name,
    required this.detail,
    required this.infoMessage,
    required this.warningMessage,
    required this.payType,
    required this.cost,
    required this.purchaseType,
    required this.targetIds,
    required this.itemSet,
    required this.setNum,
    required this.limitNum,
    required this.defaultLv,
    required this.defaultLimitCount,
    this.scriptName,
    this.script,
    required this.openedAt,
    required this.closedAt,
  });

  factory NiceShop.fromJson(Map<String, dynamic> json) =>
      _$NiceShopFromJson(json);
}

@JsonSerializable()
class Gift {
  int id;
  GiftType type;
  int objectId;
  int priority;
  int num;

  Gift({
    required this.id,
    required this.type,
    required this.objectId,
    required this.priority,
    required this.num,
  });

  factory Gift.fromJson(Map<String, dynamic> json) => _$GiftFromJson(json);
}

@JsonSerializable()
class EventReward {
  int groupId;
  int point;
  List<Gift> gifts;
  String bgImagePoint;
  String bgImageGet;

  EventReward({
    required this.groupId,
    required this.point,
    required this.gifts,
    required this.bgImagePoint,
    required this.bgImageGet,
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
  String detail;
  String icon;
  ItemBGType background;
  int value;

  EventPointBuff({
    required this.id,
    required this.funcIds,
    required this.groupId,
    required this.eventPoint,
    required this.name,
    required this.detail,
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
    required this.targetIds,
    required this.addTargetIds,
    required this.targetQuestIndividualities,
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
  int missionTargetId;
  int condGroup;
  CondType condType;
  List<int> targetIds;
  int targetNum;
  String conditionMessage;
  String closedMessage;
  int flag;
  EventMissionConditionDetail? detail;

  EventMissionCondition({
    required this.id,
    required this.missionProgressType,
    required this.priority,
    required this.missionTargetId,
    required this.condGroup,
    required this.condType,
    required this.targetIds,
    required this.targetNum,
    required this.conditionMessage,
    required this.closedMessage,
    required this.flag,
    this.detail,
  });

  factory EventMissionCondition.fromJson(Map<String, dynamic> json) =>
      _$EventMissionConditionFromJson(json);
}

@JsonSerializable()
class EventMission {
  int id;
  int flag;
  MissionType type;
  int missionTargetId;
  int dispNo;
  String name;
  String detail;
  int startedAt;
  int endedAt;
  int closedAt;
  MissionRewardType rewardType;
  List<Gift> gifts;
  int bannerGroup;
  int priority;
  int rewardRarity;
  int notfyPriority;
  int presentMessageId;
  List<EventMissionCondition> conds;

  EventMission({
    required this.id,
    required this.flag,
    required this.type,
    required this.missionTargetId,
    required this.dispNo,
    required this.name,
    required this.detail,
    required this.startedAt,
    required this.endedAt,
    required this.closedAt,
    required this.rewardType,
    required this.gifts,
    required this.bannerGroup,
    required this.priority,
    required this.rewardRarity,
    required this.notfyPriority,
    required this.presentMessageId,
    required this.conds,
  });

  factory EventMission.fromJson(Map<String, dynamic> json) =>
      _$EventMissionFromJson(json);
}

@JsonSerializable()
class EventTowerReward {
  int floor;
  List<Gift> gifts;
  String boardMessage;
  String rewardGet;
  String banner;

  EventTowerReward({
    required this.floor,
    required this.gifts,
    required this.boardMessage,
    required this.rewardGet,
    required this.banner,
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
  int id;
  int boxIndex;
  int no;
  int type;
  List<Gift> gifts;
  int maxNum;
  bool isRare;
  int priority;
  String detail;
  String icon;
  String banner;

  EventLotteryBox({
    required this.id,
    required this.boxIndex,
    required this.no,
    required this.type,
    required this.gifts,
    required this.maxNum,
    required this.isRare,
    required this.priority,
    required this.detail,
    required this.icon,
    required this.banner,
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
    required this.slot,
    required this.payType,
    required this.cost,
    required this.priority,
    required this.limited,
    required this.boxes,
  });

  factory EventLottery.fromJson(Map<String, dynamic> json) =>
      _$EventLotteryFromJson(json);
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
  List<EventReward> rewards;
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
    required this.shortName,
    required this.detail,
    this.noticeBanner,
    this.banner,
    this.icon,
    required this.bannerPriority,
    required this.noticeAt,
    required this.startedAt,
    required this.endedAt,
    required this.finishedAt,
    required this.materialOpenedAt,
    required this.warIds,
    required this.shop,
    required this.rewards,
    required this.pointGroups,
    required this.pointBuffs,
    required this.missions,
    required this.towers,
    required this.lotteries,
    required this.treasureBoxes,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
