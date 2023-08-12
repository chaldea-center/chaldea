import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/utils/extension.dart';
import '_helper.dart';
import 'item.dart';

part '../../generated/models/gamedata/raw.g.dart';

@JsonSerializable(createToJson: false)
class MstGacha {
  int id; //  50001251,
  String name; //  "【ニューイヤー1延長】【課金】第1部 0章 クリア前ベース",
  int imageId; //  80126,
  int priority; //  20122,
  int warId; //  100,
  int gachaSlot; //  3,
  int type; //  1,
  int shopId1; //  4,
  int shopId2; //  5,
  int rarityId; //  3,
  int baseId; //  3,
  int adjustId; //  50000731,
  int pickupId; //  50000772,
  int ticketItemId; //  4001,
  int gachaGroupId; //  0,
  int drawNum1; //  1,
  int drawNum2; //  10,
  int extraGroupId1; //  0,
  int extraGroupId2; //  0,
  int extraAddCount1; //  0,
  int extraAddCount2; //  0,
  int freeDrawFlag; //  0,
  int maxDrawNum; //  0,
  int beforeGachaId; //  101,
  int beforeDrawNum; //  1,
  int openedAt; //  1484114400,
  int closedAt; //  1484233199,
  int condQuestId; //  1000002,
  int condQuestPhase; //  1,
  String detailUrl; //  "/summon/gacha-description_newyear2017_12_tbyx2kua6c33y.html",
  int bannerQuestId; //  1000002,
  int bannerQuestPhase; //  1,
  int flag; //  0

  MstGacha({
    this.id = 0,
    this.name = "",
    this.imageId = 0,
    this.priority = 0,
    this.warId = 0,
    this.gachaSlot = 0,
    this.type = 0,
    this.shopId1 = 0,
    this.shopId2 = 0,
    this.rarityId = 0,
    this.baseId = 0,
    this.adjustId = 0,
    this.pickupId = 0,
    this.ticketItemId = 0,
    this.gachaGroupId = 0,
    this.drawNum1 = 0,
    this.drawNum2 = 0,
    this.extraGroupId1 = 0,
    this.extraGroupId2 = 0,
    this.extraAddCount1 = 0,
    this.extraAddCount2 = 0,
    this.freeDrawFlag = 0,
    this.maxDrawNum = 0,
    this.beforeGachaId = 0,
    this.beforeDrawNum = 0,
    this.openedAt = 0,
    this.closedAt = 0,
    this.condQuestId = 0,
    this.condQuestPhase = 0,
    this.detailUrl = "",
    this.bannerQuestId = 0,
    this.bannerQuestPhase = 0,
    this.flag = 0,
  });
  factory MstGacha.fromJson(Map<String, dynamic> json) => _$MstGachaFromJson(json);

  GachaType get gachaType => GachaType.values.firstWhereOrNull((e) => e.id == type) ?? GachaType.unknown;
}

// public enum SummonControl.GACHATYPE
enum GachaType {
  unknown(0),
  payGacha(1),
  freeGacha(3),
  ticketGacha(5),
  chargeStone(7),
  ;

  const GachaType(this.id);
  final int id;

  String get shownName {
    switch (this) {
      case unknown:
        return 'Unknown';
      case freeGacha:
        return Items.friendPoint?.lName.l ?? 'FriendPoint';
      case chargeStone:
        return S.current.lucky_bag;
      case payGacha:
        return 'Normal';
      case ticketGacha:
        return name;
    }
  }
}
