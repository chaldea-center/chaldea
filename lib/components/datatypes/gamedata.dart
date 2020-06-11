/// Servant data
part of datatypes;

@JsonSerializable(checked: true)
class GameData {
  String version;
  Map<int, Servant> servants;
  Map<int, CraftEssential> crafts;
  Map<int, CommandCode> cmdCodes;
  Map<String, Item> items;
  Map<String, IconResource> icons;
  Events events;
  Map<String, Quest> freeQuests;
  Map<String,List<Quest>> svtQuests;
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
    this.svtQuests,
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
    svtQuests??={};
    glpk ??= GLPKData();
  }

  factory GameData.fromJson(Map<String, dynamic> data) =>
      _$GameDataFromJson(data);

  Map<String, dynamic> toJson() => _$GameDataToJson(this);
}

@JsonSerializable(checked: true)
class IconResource {
  String name;
  String originName;
  String url;

  IconResource({this.name,this.originName, this.url});

  factory IconResource.fromJson(Map<String, dynamic> data) =>
      _$IconResourceFromJson(data);

  Map<String, dynamic> toJson() => _$IconResourceToJson(this);
}

@JsonSerializable(checked: true)
class ItemCost {
  List<Map<String, int>> ascension;
  List<Map<String, int>> skill;
  List<Map<String, int>> dress;

  List<String> dressName;
  List<String> dressNameJp;

  ItemCost({
    this.ascension,
    this.skill,
    this.dressName,
    this.dressNameJp,
    this.dress,
  });

  factory ItemCost.fromJson(Map<String, dynamic> data) =>
      _$ItemCostFromJson(data);

  Map<String, dynamic> toJson() => _$ItemCostToJson(this);
}

@JsonSerializable(checked: true)
class Item {
  int id;
  String name;
  int category;
  @JsonKey(defaultValue: 0)
  int rarity;

  Item({this.id, this.name, this.category, this.rarity = 0});

  Item copyWith({int id, String name, int rarity, int category, int num}) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      rarity: rarity ?? this.rarity,
      category: category ?? this.category,
    );
  }

  factory Item.fromJson(Map<String, dynamic> data) => _$ItemFromJson(data);

  Map<String, dynamic> toJson() => _$ItemToJson(this);

  @override
  String toString() {
    return 'Item($name, $num)';
  }
}
