/// Servant data
part of datatypes;

@JsonSerializable()
class GameData{
  Map<String,Servant> servants;
  Map<String,String> crafts;
  GameData({this.servants,this.crafts});

  factory GameData.fromJson(Map<String, dynamic> data) =>
      _$GameDataFromJson(data);

  Map<String, dynamic> toJson() => _$GameDataToJson(this);
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
  String state;
  String openTime;
  String openCondition;
  String opeQuest;
  String name;
  String nameJP;
  String upperName;
  String upperNameJP;
  String color;
  String category;
  String rank;
  String typeText;
  List<Map<String, dynamic>> effect;

  factory NobelPhantasm.fromJson(Map<String, dynamic> data) =>
      _$NobelPhantasmFromJson(data);

  Map<String, dynamic> toJson() => _$NobelPhantasmToJson(this);

  NobelPhantasm(
      {this.state,
      this.openTime,
      this.openCondition,
      this.opeQuest,
      this.name,
      this.nameJP,
      this.upperName,
      this.upperNameJP,
      this.color,
      this.category,
      this.rank,
      this.typeText,
      this.effect});
}

@JsonSerializable()
class Skill {
  String state;
  String openTime;
  String openCondition;
  String openQuest;
  String name;
  String rank;
  String icon;
  int cd;
  List<Effect> effects;

  factory Skill.fromJson(Map<String, dynamic> data) => _$SkillFromJson(data);

  Map<String, dynamic> toJson() => _$SkillToJson(this);

  Skill({this.state, this.openTime, this.openCondition, this.openQuest,
      this.name, this.rank, this.icon, this.cd, this.effects});
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
class ItemCost{
  List<List<Item>> ascension;
  List<List<Item>> skill;

  List<String> dressName;
  List<List<Item>> dress;

  factory ItemCost.fromJson(Map<String, dynamic> data) =>
      _$ItemCostFromJson(data);

  Map<String, dynamic> toJson() => _$ItemCostToJson(this);

  ItemCost({this.ascension,this.skill,this.dressName,this.dress});
}

@JsonSerializable()
class Item{
  String name;
  int num;

  factory Item.fromJson(Map<String, dynamic> data) =>
      _$ItemFromJson(data);

  Map<String, dynamic> toJson() => _$ItemToJson(this);

  Item({this.name, this.num});
}