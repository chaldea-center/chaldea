import 'package:json_annotation/json_annotation.dart';

import 'common.dart';

part '../../generated/models/gamedata/item.g.dart';

@JsonSerializable()
class Item {
  int id;
  String name;
  ItemType type;
  List<ItemUse> uses;
  String detail;
  List<NiceTrait> individuality;
  String icon;
  ItemBGType background;
  int priority;
  int dropPriority;

  Item({
    required this.id,
    required this.name,
    required this.type,
    this.uses = const [],
    required this.detail,
    this.individuality = const [],
    required this.icon,
    required this.background,
    required this.priority,
    required this.dropPriority,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}

@JsonSerializable()
class ItemAmount {
  int itemId;
  int amount;

  ItemAmount({
    Item? item,
    int? itemId,
    required this.amount,
  }) : itemId = item?.id ?? itemId ?? 0;

  Item? get item => null;

  factory ItemAmount.fromJson(Map<String, dynamic> json) =>
      _$ItemAmountFromJson(json);
}

@JsonSerializable()
class LvlUpMaterial {
  List<ItemAmount> items;
  int qp;

  LvlUpMaterial({
    required this.items,
    required this.qp,
  });

  factory LvlUpMaterial.fromJson(Map<String, dynamic> json) =>
      _$LvlUpMaterialFromJson(json);
}

enum ItemUse {
  skill,
  ascension,
  costume,
}

enum ItemType {
  qp,
  stone,
  apRecover,
  apAdd,
  mana,
  key,
  gachaClass,
  gachaRelic,
  gachaTicket,
  limit,
  skillLvUp,
  tdLvUp,
  friendPoint,
  eventPoint,
  eventItem,
  questRewardQp,
  chargeStone,
  rpAdd,
  boostItem,
  stoneFragments,
  anonymous,
  rarePri,
  costumeRelease,
  itemSelect,
  commandCardPrmUp,
  dice,
  continueItem,
  euqipSkillUseItem,
  svtCoin,
  friendshipUpItem,
  pp,
}

enum ItemBGType {
  zero,
  bronze,
  silver,
  gold,
  questClearQPReward,
}
