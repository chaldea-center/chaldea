/// Servant data
part of datatypes;

@JsonSerializable()
class GameData {
  String version;
  Map<int, Servant> servants;
  Map<int, CraftEssential> crafts;
  Map<String, Item> items;
  Map<String, GameIcon> icons;
  Events events;

  GameData(
      {this.version,
      this.servants,
      this.crafts,
      this.items,
      this.icons,
      this.events}) {
    version ??= '0';
    servants ??= {};
    crafts ??= {};
    items ??= {};
    icons ??= {};
    events ??= Events();
  }

  factory GameData.fromJson(Map<String, dynamic> data) =>
      _$GameDataFromJson(data);

  Map<String, dynamic> toJson() => _$GameDataToJson(this);
}

@JsonSerializable()
class GameIcon {
  String filename;
  String url;

  GameIcon({this.filename, this.url});

  factory GameIcon.fromJson(Map<String, dynamic> data) =>
      _$GameIconFromJson(data);

  Map<String, dynamic> toJson() => _$GameIconToJson(this);
}

@JsonSerializable()
class ItemCost {
  List<List<Item>> ascension;
  List<List<Item>> skill;
  List<List<Item>> dress;

  List<String> dressName;
  List<String> dressNameJp;

  factory ItemCost.fromJson(Map<String, dynamic> data) =>
      _$ItemCostFromJson(data);

  Map<String, dynamic> toJson() => _$ItemCostToJson(this);

  ItemCost(
      {this.ascension,
      this.skill,
      this.dressName,
      this.dressNameJp,
      this.dress});
}

@JsonSerializable()
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
