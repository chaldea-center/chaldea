part of 'mst_tables.dart';

@JsonSerializable(createToJson: false)
class BattleFriendshipRewardInfo {
  bool isNew;
  int userSvtId; // =0
  int targetSvtId;
  // int targetSvtFriendshipRank;
  int mstGiftId;
  int type;
  int objectId;
  int num;
  int limitCount;
  int lv;
  int rarity;

  BattleFriendshipRewardInfo({
    dynamic isNew,
    dynamic userSvtId,
    dynamic mstGiftId,
    dynamic type,
    dynamic targetSvtId,
    dynamic objectId,
    dynamic num,
    dynamic limitCount,
    dynamic lv,
    dynamic rarity,
  }) : isNew = _toBool(isNew),
       userSvtId = _toInt(userSvtId),
       mstGiftId = _toInt(mstGiftId),
       type = _toInt(type),
       targetSvtId = _toInt(targetSvtId),
       objectId = _toInt(objectId),
       num = _toInt(num),
       limitCount = _toInt(limitCount),
       lv = _toInt(lv),
       rarity = _toInt(rarity);

  factory BattleFriendshipRewardInfo.fromJson(Map<String, dynamic> data) => _$BattleFriendshipRewardInfoFromJson(data);
}

// BattleResultComponent.resultData
@JsonSerializable(createToJson: false)
class BattleResultData {
  int battleId;
  int battleResult;
  int eventId;

  int followerId;
  int followerClassId;
  int followerSupportDeckId;
  int followerType;
  int followerStatus;

  List<UserGameEntity> oldUserGame;
  List<UserQuestEntity> oldUserQuest;
  List<UserEquipEntity> oldUserEquip;
  List<UserServantCollectionEntity> oldUserSvtCollection;
  List<UserServantEntity> oldUserSvt; // usually empty

  Map myDeck; // DeckData, id+userSvtId

  int firstClearRewardQp;
  int originalPhaseClearQp;
  int phaseClearQp;
  int friendshipExpBase;

  List<BattleFriendshipRewardInfo> friendshipRewardInfos; // List<BattleFriendshipRewardInfo>
  List warClearReward; // List<WarClearReward>
  List<DropInfo> rewardInfos; // List<QuestRewardInfo>, 星光之砂
  List<DropInfo> resultDropInfos;

  BattleResultData({
    dynamic battleId,
    dynamic battleResult,
    dynamic eventId,
    dynamic followerId,
    dynamic followerClassId,
    dynamic followerSupportDeckId,
    dynamic followerType,
    dynamic followerStatus,
    List<UserGameEntity>? oldUserGame,
    List<UserQuestEntity>? oldUserQuest,
    List<UserEquipEntity>? oldUserEquip,
    List<UserServantCollectionEntity>? oldUserSvtCollection,
    List<UserServantEntity>? oldUserSvt,
    dynamic myDeck,
    dynamic firstClearRewardQp,
    dynamic originalPhaseClearQp,
    dynamic phaseClearQp,
    dynamic friendshipExpBase,
    List<BattleFriendshipRewardInfo>? friendshipRewardInfos,
    dynamic warClearReward,
    List<DropInfo>? rewardInfos,
    List<DropInfo>? resultDropInfos,
  }) : battleId = _toInt(battleId),
       battleResult = _toInt(battleResult),
       eventId = _toInt(eventId, 0),
       followerId = _toInt(followerId, 0),
       followerClassId = _toInt(followerClassId, 0),
       followerSupportDeckId = _toInt(followerSupportDeckId, 0),
       followerType = _toInt(followerType, 0),
       followerStatus = _toInt(followerStatus, 0),
       oldUserGame = oldUserGame ?? [],
       oldUserQuest = oldUserQuest ?? [],
       oldUserEquip = oldUserEquip ?? [],
       oldUserSvtCollection = oldUserSvtCollection ?? [],
       oldUserSvt = oldUserSvt ?? [],
       myDeck = myDeck is Map ? myDeck : {}, //
       firstClearRewardQp = _toInt(firstClearRewardQp, 0),
       originalPhaseClearQp = _toInt(originalPhaseClearQp, 0),
       phaseClearQp = _toInt(phaseClearQp, 0),
       friendshipExpBase = _toInt(friendshipExpBase, 0),
       friendshipRewardInfos = friendshipRewardInfos ?? [],
       warClearReward = warClearReward as List? ?? [],
       rewardInfos = rewardInfos ?? [],
       resultDropInfos = resultDropInfos ?? [];

  factory BattleResultData.fromJson(Map<dynamic, dynamic> data) => _$BattleResultDataFromJson(data);
}

@JsonSerializable(createToJson: false, createFieldMap: true)
class LoginResultData {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int serverTime = 0;
  // List<LoginMessageData> loginMessages;
  List<LoginBonusData> totalLoginBonus;
  List<LoginBonusData> seqLoginBonus;
  // List<FortuneBonusData> loginFortuneBonus;
  List<CampaignBonusData> campaignBonus;
  // List<LeaveSvtData> leaveSvt;
  // List<int> materialAddSvtIds;
  // List<int> returnRarePriShopIds;
  // List<int> freeShopIds;
  List<Map<String, dynamic>> campaignDirectBonus; // List<CampaignDirectBonusData>

  LoginResultData({
    List<LoginBonusData>? totalLoginBonus,
    List<LoginBonusData>? seqLoginBonus,
    List<CampaignBonusData>? campaignBonus,
    List<Map<String, dynamic>>? campaignDirectBonus,
  }) : totalLoginBonus = totalLoginBonus ?? [],
       seqLoginBonus = seqLoginBonus ?? [],
       campaignBonus = campaignBonus ?? [],
       campaignDirectBonus = campaignDirectBonus ?? [];

  factory LoginResultData.fromJson(Map<dynamic, dynamic> data) => _$LoginResultDataFromJson(data);

  static const fieldMap = _$LoginResultDataFieldMap;

  List<List<LoginBonusBase>> getLists() => [totalLoginBonus, seqLoginBonus, campaignBonus /*campaignDirectBonus*/];

  void clear() {
    totalLoginBonus = [];
    seqLoginBonus = [];
    campaignBonus = [];
    campaignDirectBonus = [];
  }

  void updateServerTime(int? t) {
    if (t != null && t > 0) {
      serverTime = t;
      for (final bonusList in getLists()) {
        for (final bonus in bonusList) {
          bonus.createdAt = t;
        }
      }
    }
  }

  bool get isEmpty => getLists().every((e) => e.isEmpty);
  bool get isNotEmpty => !isEmpty;
  int get length => Maths.sum(getLists().map((e) => e.length));

  @Deprecated('')
  void mergeLoginBonus(LoginResultData target) {
    totalLoginBonus = [...totalLoginBonus, ...target.totalLoginBonus];
    seqLoginBonus = [...seqLoginBonus, ...target.seqLoginBonus];
    campaignBonus = [...campaignBonus, ...target.campaignBonus];
    campaignDirectBonus = [...campaignDirectBonus, ...target.campaignDirectBonus];
  }
}

sealed class LoginBonusBase {
  List<LoginBonusItemData> items;
  Map<String, dynamic> script;
  int createdAt;

  LoginBonusBase({this.items = const [], this.script = const {}, dynamic createdAt}) : createdAt = _toInt(createdAt);

  String get key;

  @JsonKey(includeFromJson: false)
  Map srcData = {};

  List<({String? bannerUrl, String? urlLink})> getBanners(Region region) {
    List<({String? bannerUrl, String? urlLink})> result = [];
    final List<Map> banners = List.from(script['banners'] ?? []);
    for (final banner in banners) {
      String? bannerUrl = banner['bannerUrl'], urlLink = banner['urlLink'];
      if (bannerUrl == null && urlLink == null) continue;
      if (bannerUrl != null && !bannerUrl.toLowerCase().startsWith('http')) {
        switch (region) {
          case Region.jp:
            const baseUrl = 'https://view.fate-go.jp';
            bannerUrl = Uri.parse(baseUrl).resolve(bannerUrl).toString();
          default:
            break;
        }
      }
      result.add((bannerUrl: bannerUrl, urlLink: urlLink));
    }
    return result;
  }
}

@JsonSerializable(createToJson: false)
class LoginBonusData extends LoginBonusBase {
  int num;
  String message;

  LoginBonusData({dynamic num, super.items, dynamic message, super.script, super.createdAt})
    : num = _toInt(num),
      message = message?.toString() ?? '';

  factory LoginBonusData.fromJson(Map<dynamic, dynamic> data) => _$LoginBonusDataFromJson(data)..srcData = data;

  @override
  String get key => 'day $num';
}

@JsonSerializable(createToJson: false)
class CampaignBonusData extends LoginBonusBase {
  String name;
  String detail;
  String addDetail;
  bool isDeemedLogin;
  int eventId;
  int day;

  CampaignBonusData({
    this.name = '',
    this.detail = '',
    this.addDetail = '',
    this.isDeemedLogin = false,
    super.items,
    super.script,
    dynamic eventId,
    dynamic day,
    super.createdAt,
  }) : eventId = _toInt(eventId),
       day = _toInt(day);

  factory CampaignBonusData.fromJson(Map<dynamic, dynamic> data) => _$CampaignBonusDataFromJson(data)..srcData = data;

  @override
  String get key => '$eventId-day$day';
}

@JsonSerializable(createToJson: false)
class LoginBonusItemData {
  String name;
  int num;

  LoginBonusItemData({this.name = '', dynamic num}) : num = _toInt(num);

  factory LoginBonusItemData.fromJson(Map<dynamic, dynamic> data) => _$LoginBonusItemDataFromJson(data);
}

// class SummonControl.resData
@JsonSerializable(createToJson: false)
class SummonControlResultData {
  List<GachaInfo> gachaInfos;
  // List<int> canRankUpClassIds;
  // List<GetSvtCoin> overflowSvtCoinInfos;
  // List<int> extraGiftIds;
  // List<GachaExtraGifts> gachaExtraGifts;

  SummonControlResultData({this.gachaInfos = const []});

  factory SummonControlResultData.fromJson(Map<dynamic, dynamic> data) => _$SummonControlResultDataFromJson(data);
}

// GachaInfos
@JsonSerializable()
class GachaInfo extends MstGiftBase {
  bool isNew;
  int userSvtId;
  //  int type;
  //  int objectId;
  //  int num;
  int limitCount;
  int sellQp;
  int sellMana;
  int svtCoinNum;

  GachaInfo({
    dynamic isNew,
    dynamic userSvtId,
    dynamic type,
    dynamic objectId,
    dynamic num,
    dynamic limitCount,
    dynamic sellQp,
    dynamic sellMana,
    dynamic svtCoinNum,
  }) : isNew = _toBool(isNew),
       userSvtId = _toInt(userSvtId),
       limitCount = _toInt(limitCount),
       sellQp = _toInt(sellQp),
       sellMana = _toInt(sellMana),
       svtCoinNum = _toInt(svtCoinNum),
       super(type: _toInt(type), objectId: _toInt(objectId), num: _toInt(num));

  factory GachaInfo.fromJson(Map<String, dynamic> json) => _$GachaInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GachaInfoToJson(this);
}
