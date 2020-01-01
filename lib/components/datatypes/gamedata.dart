/// Servant data
part of datatypes;

@JsonSerializable(checked: true)
class GameData {
  String version;
  Map<int, Servant> servants;
  Map<int, CraftEssential> crafts;
  Map<int, CommandCode> cmdCodes;
  Map<String, Item> items;
  Map<String, GameIcon> icons;
  Events events;
  Map<String, Quest> freeQuests;
  GLPKData glpk;

  GameData({
    this.version,
    this.servants,
    this.crafts,
    this.cmdCodes,
    this.items,
    this.icons,
    this.events,
    this.freeQuests,
    this.glpk,
  }) {
    version ??= '0';
    servants ??= {};
    crafts ??= {};
    cmdCodes ??= {};
    items ??= {};
    icons ??= {};
    events ??= Events();
    freeQuests ??= {};
    glpk ??= GLPKData();
  }

  factory GameData.fromJson(Map<String, dynamic> data) =>
      _$GameDataFromJson(data);

  Map<String, dynamic> toJson() => _$GameDataToJson(this);
}

@JsonSerializable(checked: true)
class GameIcon {
  String filename;
  String url;

  GameIcon({this.filename, this.url});

  factory GameIcon.fromJson(Map<String, dynamic> data) =>
      _$GameIconFromJson(data);

  Map<String, dynamic> toJson() => _$GameIconToJson(this);
}

@JsonSerializable(checked: true)
class ItemCost {
  List<List<Item>> ascension;
  List<List<Item>> skill;
  List<List<Item>> dress;

  List<String> dressName;
  List<String> dressNameJp;

  factory ItemCost.fromJson(Map<String, dynamic> data) =>
      _$ItemCostFromJson(data);

  Map<String, dynamic> toJson() => _$ItemCostToJson(this);

  ItemCost({
    this.ascension,
    this.skill,
    this.dressName,
    this.dressNameJp,
    this.dress,
  });
}

@JsonSerializable(checked: true)
class Item {
  int id;
  String name;
  @JsonKey(defaultValue: 0)
  int rarity;
  int category;
  @JsonKey(defaultValue: 0)
  int num;

  Item({this.id, this.name, this.rarity = 0, this.category, this.num = 0});

  Item copyWith({int id, String name, int rarity, int category, int num}) {
    return Item(
        id: id ?? this.id,
        name: name ?? this.name,
        rarity: rarity ?? this.rarity,
        category: category ?? this.category,
        num: num ?? this.num);
  }

  factory Item.fromJson(Map<String, dynamic> data) => _$ItemFromJson(data);

  Map<String, dynamic> toJson() => _$ItemToJson(this);

  @override
  String toString() {
    return 'Item($name, $num)';
  }
}
