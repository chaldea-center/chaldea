import 'package:chaldea/models/db.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'common.dart';
import 'game_card.dart';

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

  String? get borderedIcon {
    if (type == ItemType.svtCoin) return icon;
    return icon.replaceFirst(RegExp(r'.png$'), '_bordered.png');
  }

  static Widget iconBuilder({
    required BuildContext context,
    required String? icon,
    double? width,
    double? height,
    double? aspectRatio = 132 / 144,
    String? text,
    EdgeInsets? padding,
    EdgeInsets? textPadding,
    VoidCallback? onTap,
    bool jumpToDetail = true,
    bool popDetail = false,
  }) {
    if (onTap == null && jumpToDetail) {
      // onTap = () {
      //   SplitRoute.push(context, ItemDetailPage(itemKey: itemKey),
      //       popDetail: popDetail);
      // };
    }
    return GameCardMixin.cardIconBuilder(
      context: context,
      icon: icon,
      width: width,
      height: height,
      aspectRatio: aspectRatio,
      text: text,
      padding: padding,
      textPadding: textPadding,
      onTap: onTap,
    );
  }
}

class Items {
  const Items._();
  static Map<int, Item> get _items => db2.gameData.items;
  static Item get qp => _items[1]!;
  static Item get grail => _items[7999]!;
}

@JsonSerializable()
class ItemAmount {
  int itemId;
  int amount;

  ItemAmount({
    Item? item,
    int? itemId,
    required this.amount,
  }) : itemId = item?.id ?? itemId!;

  Item get item => db2.gameData.items[itemId]!;

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
