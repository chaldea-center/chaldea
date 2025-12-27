import 'package:flutter/material.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/mc/mc_prob_edit.dart';
import 'package:chaldea/app/modules/shop/shop.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/event.dart';
import 'package:chaldea/utils/extension.dart';
import '_helper.dart';
import 'common.dart';
import 'item.dart';
import 'mappings.dart';

part '../../generated/models/gamedata/gacha.g.dart';

@JsonSerializable()
class MstGacha with RouteInfo {
  int id; //  50001251,
  String name; //  "【ニューイヤー1延長】【課金】第1部 0章 クリア前ベース",
  int imageId; //  80126,
  // int priority; //  20122,
  // int warId; //  100,
  // int gachaSlot; //  3,
  @GachaTypeConverter()
  int type; //  1,
  // int shopId1; //  4,
  // int shopId2; //  5,
  // int rarityId; //  3,
  // int baseId; //  3,
  // int adjustId; //  50000731,
  // int pickupId; //  50000772,
  // int ticketItemId; //  4001,
  // int gachaGroupId; //  0,
  // int drawNum1; //  1,
  // int drawNum2; //  10,
  // int extraGroupId1; //  0,
  // int extraGroupId2; //  0,
  // int extraAddCount1; //  0,
  // int extraAddCount2; //  0,
  int freeDrawFlag; //  0,
  // int maxDrawNum; //  0,
  // int beforeGachaId; //  101,
  // int beforeDrawNum; //  1,
  int openedAt; //  1484114400,
  int closedAt; //  1484233199,
  // int condQuestId; //  1000002,
  // int condQuestPhase; //  1,
  String detailUrl; //  "/summon/gacha-description_newyear2017_12_tbyx2kua6c33y.html",
  // int bannerQuestId; //  1000002,
  // int bannerQuestPhase; //  1,
  // int flag; //  0
  bool userAdded;

  MstGacha({
    this.id = 0,
    this.name = "",
    this.imageId = 0,
    // this.priority = 0,
    // this.warId = 0,
    // this.gachaSlot = 0,
    this.type = 1,
    // this.shopId1 = 0,
    // this.shopId2 = 0,
    // this.rarityId = 0,
    // this.baseId = 0,
    // this.adjustId = 0,
    // this.pickupId = 0,
    // this.ticketItemId = 0,
    // this.gachaGroupId = 0,
    // this.drawNum1 = 0,
    // this.drawNum2 = 0,
    // this.extraGroupId1 = 0,
    // this.extraGroupId2 = 0,
    // this.extraAddCount1 = 0,
    // this.extraAddCount2 = 0,
    this.freeDrawFlag = 0,
    // this.maxDrawNum = 0,
    // this.beforeGachaId = 0,
    // this.beforeDrawNum = 0,
    this.openedAt = 0,
    this.closedAt = 0,
    // this.condQuestId = 0,
    // this.condQuestPhase = 0,
    this.detailUrl = "",
    // this.bannerQuestId = 0,
    // this.bannerQuestPhase = 0,
    // this.flag = 0,
    this.userAdded = false,
  });

  factory MstGacha.fromJson(Map<String, dynamic> json) => _$MstGachaFromJson(json);

  Map<String, dynamic> toJson() => _$MstGachaToJson(this);

  GachaType get gachaType => GachaType.values.firstWhereOrNull((e) => e.value == type) ?? GachaType.unknown;

  bool get isLuckyBag => type == GachaType.chargeStone.value;
  bool get isFpGacha => type == GachaType.freeGacha.value;

  String get lName {
    const pujp = 'ピックアップ召喚';
    if (!name.endsWith(pujp) || Transl.current == Region.jp) return Transl.summonNames(name).l;
    if (Transl.summonNames(name).matched) return Transl.summonNames(name).l;
    String name1 = name.substring(0, name.length - pujp.length).trim();
    final spaceIndex = name1.lastIndexOf(RegExp(r'[\s\n]'));
    if (spaceIndex > 0 && spaceIndex < name1.length - 1) {
      String summonName = name1.substring(0, spaceIndex).trim().replaceAll('\n', '') + pujp;
      String svtName = name1.substring(spaceIndex).trim();
      final lSvtName = Transl.svtNames(svtName);
      if (!lSvtName.matched) {
        final match = RegExp(r'^(.+)\((.+?)\)$').firstMatch(svtName);
        if (match != null) {
          String baseSvtName = match.group(1)!.trim(), clsName = match.group(2)!.trim();
          final lClsName = Transl.svtClassName(clsName);
          if (lClsName.matched) {
            return '${Transl.summonNames(summonName).l} ${Transl.svtNames(baseSvtName).l}(${lClsName.l})';
          }
          String svtName2 = clsName;
          final lSvtName2 = Transl.svtNames(svtName2);
          if (lSvtName2.matched) {
            return '${Transl.summonNames(summonName).l} ${Transl.svtNames(baseSvtName).l}(${lSvtName2.l})';
          }
        }
      }
      return '${Transl.summonNames(summonName).l} ${lSvtName.l}';
    }
    return name;
  }

  String get detailUrlPrefix {
    final match = RegExp(r'^(/.+/.+_)(([a-z]\d)|(\d+)|([a-z]))$').firstMatch(detailUrl);
    return match?.group(1) ?? detailUrl;
  }

  String? getHtmlUrl(Region region) {
    // final page = gacha?.detailUrl;
    // if (page == null || page.trim().isEmpty) return null;
    if (const [1, 101].contains(id)) return null;
    switch (region) {
      case Region.jp:
        // return 'https://webview.fate-go.jp/webview$page';
        if (openedAt < 1640790000) {
          // ID50017991 2021-12-29 23:00+08
          return null;
        }
        return "https://static.atlasacademy.io/file/aa-fgo/GameData-uTvNN4iBTNInrYDa/JP/Banners/$id/index.html";
      case Region.na:
        if (openedAt < 1641268800) {
          // 50010611: 2022-01-04 12:00+08
          return null;
        }
        return "https://static.atlasacademy.io/file/aa-fgo/GameData-uTvNN4iBTNInrYDa/NA/Banners/$id/index.html";
      case Region.cn:
      case Region.tw:
      case Region.kr:
        return null;
    }
  }

  @override
  String get route => Routes.gachaI(id);

  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) {
    return super.routeTo(
      child: child ?? MCGachaProbEditPage(gacha: NiceGacha.fromJson(toJson()), region: region ?? Region.jp),
      popDetails: popDetails,
    );
  }
}

@JsonSerializable()
class NiceGacha extends MstGacha {
  // @JsonKey(unknownEnumValue: GachaFlag.none)
  // List<GachaFlag> flags;
  List<GachaStoryAdjust> storyAdjusts;
  List<GachaSub> gachaSubs;
  List<int> featuredSvtIds; // only GSSR gacha has data during open and with displayFeaturedSvt flag
  List<GachaRelease> releaseConditions;
  // int extraGroupId; // 330 保底

  NiceGacha({
    super.id,
    super.name = '',
    super.imageId = 0,
    super.type,
    super.freeDrawFlag,
    super.openedAt,
    super.closedAt,
    super.detailUrl,
    super.userAdded,
    // this.flags = const [],
    this.storyAdjusts = const [],
    this.gachaSubs = const [],
    this.featuredSvtIds = const [],
    this.releaseConditions = const [],
  });

  factory NiceGacha.fromJson(Map<String, dynamic> json) => _$NiceGachaFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NiceGachaToJson(this);

  List<GachaSub> getValidGachaSubs() {
    final now = DateTime.now().timestamp;
    final subs = gachaSubs.where((e) => e.openedAt <= now && e.closedAt > now).toList();
    subs.sort2((e) => e.priority);
    return subs;
  }

  int getImageId(int subId) {
    for (final sub in gachaSubs) {
      if (sub.id == subId && sub.imageId != 0) {
        return sub.imageId;
      }
    }
    return imageId;
  }
}

@JsonSerializable()
class GachaStoryAdjust {
  int adjustId;
  int idx; // max idx
  @CondTypeConverter()
  CondType condType;
  int targetId;
  int value;
  int imageId;

  GachaStoryAdjust({
    required this.adjustId,
    this.idx = 1,
    this.condType = CondType.none,
    this.targetId = 0,
    this.value = 0,
    this.imageId = 0,
  });

  factory GachaStoryAdjust.fromJson(Map<String, dynamic> json) => _$GachaStoryAdjustFromJson(json);

  Map<String, dynamic> toJson() => _$GachaStoryAdjustToJson(this);
}

// class NiceGachaSub(BaseModelORJson):
//     id: int
//     priority: int
//     imageId: int
//     adjustAddId: int
//     openedAt: int
//     closedAt: int
//     releaseConditions: list[NiceCommonRelease]
//     script: dict[str, Any] | None = None

@JsonSerializable()
class GachaSub {
  int id;
  int priority;
  int imageId;
  int adjustAddId;
  int openedAt;
  int closedAt;
  List<CommonRelease> releaseConditions;
  Map<String, dynamic>? script;

  GachaSub({
    required this.id,
    this.priority = 0,
    this.imageId = 0,
    this.adjustAddId = 0,
    this.openedAt = 0,
    this.closedAt = 0,
    this.releaseConditions = const [],
    this.script,
  });

  factory GachaSub.fromJson(Map<String, dynamic> json) => _$GachaSubFromJson(json);
  Map<String, dynamic> toJson() => _$GachaSubToJson(this);
}

@JsonSerializable()
class GachaRelease {
  @CondTypeConverter()
  CondType type;
  int targetId;
  int value;

  GachaRelease({this.type = CondType.none, this.targetId = 0, this.value = 0});

  factory GachaRelease.fromJson(Map<String, dynamic> json) => _$GachaReleaseFromJson(json);
  Map<String, dynamic> toJson() => _$GachaReleaseToJson(this);
}

class GachaTypeConverter extends JsonConverter<int, dynamic> {
  const GachaTypeConverter();

  static const payTypeToGachaType = <PayType, GachaType>{
    PayType.stone: GachaType.payGacha,
    PayType.friendPoint: GachaType.freeGacha,
    PayType.ticket: GachaType.ticketGacha,
    PayType.chargeStone: GachaType.chargeStone,
  };

  @override
  int fromJson(dynamic value) {
    if (value == null) return GachaType.payGacha.value;
    if (value is int) return value;
    if (value is String) {
      for (final (k, v) in payTypeToGachaType.items) {
        if (k.name == value) return v.value;
      }
      return decodeEnum(_$GachaTypeEnumMap, value, GachaType.unknown).value;
    }
    return GachaType.unknown.value;
  }

  @override
  int toJson(int obj) => obj;
}

// public enum SummonControl.GACHATYPE or PayType
@JsonEnum(alwaysCreate: true)
enum GachaType {
  unknown(0),
  payGacha(1),
  freeGacha(3),
  ticketGacha(5),
  chargeStone(7);

  const GachaType(this.value);
  final int value;

  String get shownName {
    switch (this) {
      case unknown:
        return S.current.unknown;
      case freeGacha:
        return Items.friendPoint?.lName.l ?? 'FriendPoint';
      case chargeStone:
        return S.current.lucky_bag;
      case payGacha:
        return S.current.normal;
      case ticketGacha:
        return name;
    }
  }
}

enum GachaFlag {
  none,
  pcMessage, // 2
  bonusSelect, // 8
  displayFeaturedSvt, // 16
}

@JsonSerializable()
class MstShop with RouteInfo {
  List<int> itemIds;
  List<int> prices;
  List<int> targetIds;
  Map<String, dynamic> script;
  // anotherPayType: Optional[int] = None
  // anotherItemIds: Optional[list[int]] = None
  // useAnotherPayCommonReleaseId: Optional[int] = None
  // freeShopCondId: Optional[int] = None
  // freeShopCondMessage: Optional[str] = None
  // hideWarningMessageCondId: Optional[int] = None
  // freeShopReleaseDate: Optional[int] = None
  int id;
  // baseShopId: int  # 80107019
  int eventId;
  int slot;
  int flag;
  int priority;
  int purchaseType;
  int setNum;
  int payType;
  int shopType;
  int limitNum;
  int defaultLv;
  int defaultLimitCount;
  String name;
  String detail;
  // infoMessage: str  # ""
  // warningMessage: str  # ""
  int imageId;
  int bgImageId;
  int openedAt;
  int closedAt;

  MstShop({
    this.itemIds = const [],
    this.prices = const [],
    this.targetIds = const [],
    this.script = const {},
    this.id = 0,
    this.eventId = 0,
    this.slot = 0,
    this.flag = 0,
    this.priority = 0,
    this.purchaseType = 0,
    this.setNum = 0,
    this.payType = 0,
    this.shopType = 0,
    this.limitNum = 0,
    this.defaultLv = 0,
    this.defaultLimitCount = 0,
    this.name = "",
    this.detail = "",
    this.imageId = 0,
    this.bgImageId = 0,
    this.openedAt = 0,
    this.closedAt = 0,
  });

  factory MstShop.fromJson(Map<String, dynamic> json) => _$MstShopFromJson(json);

  Map<String, dynamic> toJson() => _$MstShopToJson(this);

  @override
  String get route => Routes.shopI(id);

  @override
  void routeTo({Widget? child, bool popDetails = false, Region? region}) {
    return super.routeTo(
      child: child ?? ShopDetailPage(id: id, region: region ?? Region.jp),
      popDetails: popDetails,
    );
  }
}
