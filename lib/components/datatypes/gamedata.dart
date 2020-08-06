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
  Map<String, List<Quest>> svtQuests;
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
    svtQuests ??= {};
    glpk ??= GLPKData();
  }

  factory GameData.fromJson(Map<String, dynamic> data) => _$GameDataFromJson(data);

  Map<String, dynamic> toJson() => _$GameDataToJson(this);
}

@JsonSerializable(checked: true)
class IconResource {
  String name;
  String originName;
  String url;

  IconResource({this.name, this.originName, this.url});

  factory IconResource.fromJson(Map<String, dynamic> data) => _$IconResourceFromJson(data);

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

  factory ItemCost.fromJson(Map<String, dynamic> data) => _$ItemCostFromJson(data);

  Map<String, dynamic> toJson() => _$ItemCostToJson(this);
}

@JsonSerializable(checked: true)
class Item {
  /// id: 4-digit number, X-Y-ZZ = X category & Y rarity & ZZ order number
  int id;
  String name;

  /// category: 1-usual item(include crystal/grail), 2-skill gem, 3-ascension piece/monument,
  /// 4-event servants' ascension item, 5-special, now only QP
  int category;

  /// rarity: 1-cropper, 2-silver, 3-gold, 4-special(crystal/grail)
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

  static const String qp = 'QP';
  static const String grail = '圣杯';
  static const String crystal = '传承结晶';

  static getId(String key){
    return db.gameData.items[key]?.id;
  }

  static List<String> sortListById(List<String> data, [bool inPlace = false]) {
    return (inPlace ? data : List.from(data))..sort((a, b) => (getId(a) ?? 9999) - (getId(b) ?? 9999));
  }

  static Map<String, T> sortMapById<T>(Map<String, T> data) {
    data.forEach((key, value) {getId(key);});
    return Map.fromEntries(
        data.entries.toList()..sort((a, b) => (getId(a.key) ?? 9999) - (getId(b.key) ?? 9999)));
  }

  static String getNameOfCategory(int category, int rarity) {
    switch (category) {
      case 0:
        return ['Unknown', '铜材料', '银材料', '金材料', '特殊材料'][rarity];
      case 1:
        return ['素材', '铜素材', '银素材', '金素材', '稀有'][rarity];
      case 2:
        return ['技能石', '辉石', '魔石', '秘石'][rarity];
      case 3:
        return ['职阶棋子', 'Unknown', '银棋', '金像'][rarity];
      case 4:
        return '活动从者灵基再临素材';
      default:
        return '其他';
    }
  }
}
