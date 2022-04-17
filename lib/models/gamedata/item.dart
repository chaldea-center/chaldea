import 'package:flutter/material.dart';

import 'package:json_annotation/json_annotation.dart';

import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';
import '../../app/app.dart';
import 'common.dart';
import 'game_card.dart';
import 'mappings.dart';

part '../../generated/models/gamedata/item.g.dart';

enum SkillUpItemType {
  normal,
  ascension,
  skill,
  special,
  event,
  none,
}

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

  int get rarity =>
      background == ItemBGType.questClearQPReward ? 0 : background.index;

  String get borderedIcon {
    if (type == ItemType.svtCoin) return icon;
    return icon.replaceFirst(RegExp(r'.png$'), '_bordered.png');
  }

  SkillUpItemType get skillUpItemType {
    // if (type == ItemType.tdLvUp) return SkillUpItemType.ascension;
    // if (type != ItemType.skillLvUp) return SkillUpItemType.none;
    if (id >= 6000 && id < 6300) return SkillUpItemType.skill;
    if (id >= 6500 && id < 7000) return SkillUpItemType.normal;
    if (id >= 7000 && id < 7200) return SkillUpItemType.ascension;
    if (type == ItemType.eventItem && uses.contains(ItemUse.ascension)) {
      return SkillUpItemType.event;
    }
    if (Items.specialItems.contains(id)) return SkillUpItemType.special;
    return SkillUpItemType.none;
  }

  static Widget iconBuilder({
    required BuildContext context,
    required Item? item,
    int? itemId,
    String? icon,
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
    int? _itemId = item?.id ?? itemId;
    item ??= db.gameData.items[itemId];
    icon ??= item?.borderedIcon;
    if (onTap == null && jumpToDetail && _itemId != null) {
      onTap = () {
        router.push(
            url: Routes.itemI(_itemId), popDetail: popDetail, detail: true);
      };
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

  Transl<String, String> get lName => Transl.itemNames(name);

  String get route => Routes.itemI(id);

  void routeTo() => router.push(url: Routes.itemI(id));

  // include special items(entity)
  static String getName(int id) {
    return db.gameData.items[id]?.lName.l ??
        db.gameData.entities[id]?.lName.l ??
        id.toString();
  }

  static String? getIcon(int id) {
    return db.gameData.items[id]?.borderedIcon ??
        db.gameData.entities[id]?.face;
  }

  static Map<int, int> sortMapByPriority(Map<int, int> items) {
    return {
      for (final k
          in items.keys.toList()
            ..sort2((e) => db.gameData.items[e]?.priority ?? e))
        if (items[k]! > 0) k: items[k]!
    };
  }

  static Map<SkillUpItemType, Map<int, int>> groupItems(Map<int, int> items) {
    Map<SkillUpItemType, Map<int, int>> result = {
      for (final type in SkillUpItemType.values) type: {},
    };
    for (int itemId in items.keys) {
      SkillUpItemType? type = db.gameData.items[itemId]?.skillUpItemType;
      if (type == null && Items.specialSvtMat.contains(itemId)) {
        type = SkillUpItemType.special;
      }
      type ??= SkillUpItemType.none;
      result[type]![itemId] = items[itemId]!;
    }

    return {
      for (final type in SkillUpItemType.values)
        type: sortMapByPriority(result[type]!),
    };
  }
}

class Items {
  const Items._();

  // for own use, no a exact id
  static const int expPointId = -10;
  static const int bondPointId = -11;

  static Map<int, Item> get _items => db.gameData.items;

  static int qpId = 1;
  static int stoneId = 2;
  static int manaPrismId = 3;
  static int purePrismId = 46;
  static int rarePrismId = 18;
  static int summonTicketId = 4001;
  static int bronzeAppleId = 102;
  static int silverAppleId = 101;
  static int goldAppleId = 100;
  static int grailFragId = 7998;
  static int grailId = 7999;
  static int lanternId = 1000;

  // not item, icon only
  static int costumeIconId = 23;
  static int npRankUpIconId = 8;

  static Item get qp => _items[qpId]!;

  static Item get stone => _items[stoneId]!;

  static Item get manaPrism => _items[manaPrismId]!;

  static Item get purePrism => _items[purePrismId]!;

  static Item get rarePrism => _items[rarePrismId]!;

  static Item get summonTicket => _items[summonTicketId]!;

  static Item get bronzeApple => _items[bronzeAppleId]!;

  static Item get silverApple => _items[silverAppleId]!;

  static Item get goldApple => _items[goldAppleId]!;

  static Item get grailFrag => _items[grailFragId]!;

  static Item get grail => _items[grailId]!;

  static Item get lantern => _items[lanternId]!;

  static const List<int> specialItems = [
    //
    2, 3, 46, 18, 4001, 102, 101, 100,
    1, 7998, 7999, 1000
  ];
  static const List<int> specialSvtMat = [
    hpFou3,
    atkFou3,
    hpFou4,
    atkFou4,
  ];
  static const int hpFou3 = 9570300;
  static const int hpFou4 = 9570400;
  static const int atkFou3 = 9670300;
  static const int atkFou4 = 9670400;

  @Deprecated('to be evaluated')
  static bool isStatItem(int itemId) {
    final item = _items[itemId];
    if (item != null && item.skillUpItemType != SkillUpItemType.none) {
      return true;
    }
    if (specialSvtMat.contains(itemId)) return true;
    return false;
  }
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

  Item get item => db.gameData.items[itemId]!;

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

  Map<int, int> toItemDict() {
    return {
      for (final item in items) item.itemId: item.amount,
      Items.qpId: qp,
    };
  }
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
