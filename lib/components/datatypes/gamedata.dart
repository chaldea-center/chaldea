/// Servant data
part of datatypes;

@JsonSerializable()
class GameData {
  Map<String, Servant> servants;
  Map<String, String> crafts;
  Map<String, Item> items;
  Map<String, GameIcon> icons;

  GameData({this.servants, this.crafts, this.items, this.icons}){
    servants??={};
    crafts??={};
    items??={};
    icons??={};
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
class Servant {
  int no;
  String mcLink;
  String icon;
  ServantBaseInfo info;
  List<NobelPhantasm> nobelPhantasm;
  List<List<Skill>> activeSkills;
  List<Skill> passiveSkills;
  ItemCost itemCost;

  Servant(
      {this.no,
      this.mcLink,
      this.icon,
      this.info,
      this.nobelPhantasm,
      this.activeSkills,
      this.passiveSkills,
      this.itemCost});

  Map<String, int> calculateCost(ServantPlan plan, {bool planned = true}) {
    if (planned && (plan == null || plan.favorite == false)) {
      return {};
    }
    Map<String, int> cost = {};
    List<Map<String, int>> all = [
      calAscensionCost(lv: planned ? plan.ascensionLv : null),
      calSkillCost(lv: planned ? plan.skillLv : null),
      calDressCost(lv: planned ? plan.dressLv : null)
    ];
    all.forEach((e) => e.forEach((item, num) {
          cost[item] = (cost[item] ?? 0) + num;
        }));
    return cost;
  }

  Map<String, int> calAscensionCost({List<int> lv}) {
    Map<String, int> cost = {};
    if (itemCost == null || itemCost.ascension == null) {
      return cost;
    }
    lv = lv ?? [0, 4];
    int start = lv[0], end = lv[1];
    for (int i = start; i < end; i++) {
      for (var item in itemCost.ascension[i]) {
        cost[item.name] = (cost[item.name] ?? 0) + item.num;
      }
    }
    if (sum(cost.values) > 0) {
//      print('Ascension: $cost');
    }
    return cost;
  }

  Map<String, int> calSkillCost({List<List<int>> lv}) {
    Map<String, int> cost = {};
    if (itemCost == null || itemCost.skill == null) {
      return cost;
    }
    lv = lv ?? List.generate(3, (i) => [1, 10]);
    for (int i = 0; i < 3; i++) {
      int start = lv[i][0], end = lv[i][1];
      for (int j = start - 1; j < end - 1; j++) {
        for (var item in itemCost.skill[j]) {
          cost[item.name] = (cost[item.name] ?? 0) + item.num;
        }
      }
    }
    if (sum(cost.values) > 0) {
//      print('Skill: $cost');
    }
    return cost;
  }

  Map<String, int> calDressCost({List<List<int>> lv}) {
    Map<String, int> cost = {};
    if (itemCost == null || itemCost.dress == null) {
      return cost;
    }
    lv = lv ?? List.generate(itemCost.dress.length, (i) => [0, 1]);
    for (int i = 0; i < itemCost.dress.length; i++) {
      int start = lv[i][0], end = lv[i][1];
      for (int j = start; j < end; j++) {
        for (var item in itemCost.dress[i]) {
          cost[item.name] = (cost[item.name] ?? 0) + item.num;
        }
      }
    }
    if (sum(cost.values) > 0) {
//      print('Dress: $cost');
    }
    return cost;
  }

  factory Servant.fromJson(Map<String, dynamic> data) =>
      _$ServantFromJson(data);

  Map<String, dynamic> toJson() => _$ServantToJson(this);
}

@JsonSerializable()
class ServantBaseInfo {
  String get;
  int rarity;
  int rarity2;
  String weight;
  String height;
  String gender;
  String illustrator;
  String className;
  String attribute;
  bool isHumanoid;
  bool isWeakToEA;
  String name;
  String illustName;
  List<String> nicknames;
  List<String> cv;
  List<String> alignments;
  List<String> traits;
  Map<String, String> ability;
  List<Map<String, String>> illust;
  Map<String, Map<String, dynamic>> cards;
  Map<String, int> npRate;
  int atkMin;
  int hpMin;
  int atkMax;
  int hpMax;
  int atk90;
  int hp90;
  int atk100;
  int hp100;
  int starRate;
  int deathRate;
  int criticalRate;

  factory ServantBaseInfo.fromJson(Map<String, dynamic> data) =>
      _$ServantBaseInfoFromJson(data);

  Map<String, dynamic> toJson() => _$ServantBaseInfoToJson(this);

  ServantBaseInfo(
      {this.get,
      this.rarity,
      this.rarity2,
      this.weight,
      this.height,
      this.gender,
      this.illustrator,
      this.className,
      this.attribute,
      this.isHumanoid,
      this.isWeakToEA,
      this.name,
      this.illustName,
      this.nicknames,
      this.cv,
      this.alignments,
      this.traits,
      this.ability,
      this.illust,
      this.cards,
      this.npRate,
      this.atkMin,
      this.hpMin,
      this.atkMax,
      this.hpMax,
      this.atk90,
      this.hp90,
      this.atk100,
      this.hp100,
      this.starRate,
      this.deathRate,
      this.criticalRate});
}

@JsonSerializable()
class NobelPhantasm {
  bool enhanced;
  String state;
  String openTime;
  String openCondition;
  String opeQuest;
  String name;
  String nameJp;
  String upperName;
  String upperNameJp;
  String color;
  String category;
  String rank;
  String typeText;
  List<Effect> effects;

  factory NobelPhantasm.fromJson(Map<String, dynamic> data) =>
      _$NobelPhantasmFromJson(data);

  Map<String, dynamic> toJson() => _$NobelPhantasmToJson(this);

  NobelPhantasm(
      {this.enhanced,
      this.state,
      this.openTime,
      this.openCondition,
      this.opeQuest,
      this.name,
      this.nameJp,
      this.upperName,
      this.upperNameJp,
      this.color,
      this.category,
      this.rank,
      this.typeText,
      this.effects});
}

@JsonSerializable()
class Skill {
  String state;
  String openTime;
  String openCondition;
  String openQuest;
  bool enhanced;
  String name;
  String nameJp;
  String rank;
  String icon;
  int cd;
  List<Effect> effects;

  factory Skill.fromJson(Map<String, dynamic> data) => _$SkillFromJson(data);

  Map<String, dynamic> toJson() => _$SkillToJson(this);

  Skill(
      {this.state,
      this.openTime,
      this.openCondition,
      this.openQuest,
      this.enhanced,
      this.name,
      this.nameJp,
      this.rank,
      this.icon,
      this.cd,
      this.effects});
}

@JsonSerializable()
class Effect {
  String description;
  String target;
  String valueType;
  List<dynamic> lvData;

  factory Effect.fromJson(Map<String, dynamic> data) => _$EffectFromJson(data);

  Map<String, dynamic> toJson() => _$EffectToJson(this);

  Effect({this.description, this.target, this.valueType, this.lvData});
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
  String category;
  @JsonKey(defaultValue: 0)
  int num;

//  Item operator +(Object other) {
//    if (Object is Item) {
//      Item otherItem = other as Item;
//      return this.copyWith(num: num + otherItem.num);
//    } else if (Object is int) {
//      int otherInt = other as int;
//      return copyWith(num: num + otherInt);
//    } else {
//      throw (TypeError());
//    }
//  }

  Item copyWith({int id, String name, int rarity, String category, int num}) {
    return Item(
        id: id ?? this.id,
        name: name ?? this.name,
        rarity: rarity ?? this.name,
        category: category ?? this.category,
        num: num ?? this.num);
  }

  factory Item.fromJson(Map<String, dynamic> data) => _$ItemFromJson(data);

  Map<String, dynamic> toJson() => _$ItemToJson(this);

  Item({this.id, this.name, this.rarity = 0, this.category, this.num = 0});
}
