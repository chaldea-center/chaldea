part of gamedata;

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
    required this.uses,
    required this.detail,
    required this.individuality,
    required this.icon,
    required this.background,
    required this.priority,
    required this.dropPriority,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}

@JsonSerializable()
class ItemAmount {
  Item item;
  int amount;

  ItemAmount({
    required this.item,
    required this.amount,
  });

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
