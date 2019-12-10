part of datatypes;

@JsonSerializable()
class Servant {
  int no;
  String mcLink;
  String icon;
  ServantBaseInfo info;
  List<TreasureDevice> treasureDevice;
  List<List<Skill>> activeSkills;
  List<Skill> passiveSkills;
  ItemCost itemCost;
  List<SvtProfileData> profiles;
  int bondCraft;
  int valentineCraft;

  static const List<int> unavailable = [83, 149, 151, 152, 168, 240];

  Servant({
    this.no,
    this.mcLink,
    this.icon,
    this.info,
    this.treasureDevice,
    this.activeSkills,
    this.passiveSkills,
    this.itemCost,
    this.profiles,
    this.bondCraft,
    this.valentineCraft,
  });

  Map<String, int> getAllCost(ServantPlan plan, {bool planned = true}) {
    if (planned && (plan == null || plan.favorite == false)) {
      return {};
    }
    Map<String, int> cost = {};
    List<Map<String, int>> all = [
      getAscensionCost(lv: planned ? plan.ascensionLv : null),
      getSkillCost(lv: planned ? plan.skillLv : null),
      getDressCost(lv: planned ? plan.dressLv : null)
    ];
    all.forEach((e) => e.forEach((item, num) {
          cost[item] = (cost[item] ?? 0) + num;
        }));
    return cost;
  }

  Map<String, int> getAscensionCost({List<int> lv}) {
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
    return cost;
  }

  Map<String, int> getSkillCost({List<List<int>> lv}) {
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
    return cost;
  }

  Map<String, int> getDressCost({List<List<int>> lv}) {
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
    return cost;
  }

  int getClassSortIndex() {
    if (info.className == 'Grand Caster') {
      return SvtFilterData.classesData.indexWhere((v) => v == 'Caster');
    } else if (info.className.startsWith('Beast')) {
      return SvtFilterData.classesData.indexWhere((v) => v == 'Beast');
    } else {
      return SvtFilterData.classesData
          .indexWhere((v) => v.startsWith(info.className.substring(0, 5)));
    }
  }

  static int compare(Servant a, Servant b,
      [List<SvtCompare> keys, List<bool> reversed]) {
    int res = 0;
    if (keys == null || keys.isEmpty) {
      keys = [SvtCompare.no];
    }
    for (var i = 0; i < keys.length; i++) {
      int r;
      switch (keys[i]) {
        case SvtCompare.no:
          r = a.no - b.no;
          break;
        case SvtCompare.className:
          r = a.getClassSortIndex() - b.getClassSortIndex();
          break;
        case SvtCompare.rarity:
          r = a.info.rarity - b.info.rarity;
          break;
        case SvtCompare.atk:
          r = (a.info?.atkMax ?? 0) - (b.info?.atkMax ?? 0);
          break;
        case SvtCompare.hp:
          r = (a.info?.hpMax ?? 0) - (b.info?.hpMax ?? 0);
          break;
      }
      res = res * 1000 + ((reversed?.elementAt(i) ?? false) ? -r : r);
    }
    return res;
  }

  factory Servant.fromJson(Map<String, dynamic> data) =>
      _$ServantFromJson(data);

  Map<String, dynamic> toJson() => _$ServantToJson(this);
}

enum SvtCompare { no, className, rarity, atk, hp }

@JsonSerializable()
class ServantBaseInfo {
  String obtain;
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
  String nameJp;
  String nameEn;
  String illustName;
  List<String> nicknames;
  List<String> cv;
  List<String> alignments;
  List<String> traits;
  Map<String, String> ability;
  List<Map<String, String>> illust;
  List<String> cards;
  Map<String, int> cardHits;
  Map<String, List<int>> cardHitsDamage;
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

  ServantBaseInfo({
    this.obtain,
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
    this.nameJp,
    this.nameEn,
    this.illustName,
    this.nicknames,
    this.cv,
    this.alignments,
    this.traits,
    this.ability,
    this.illust,
    this.cards,
    this.cardHits,
    this.cardHitsDamage,
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
    this.criticalRate,
  });
}

@JsonSerializable()
class TreasureDevice {
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

  factory TreasureDevice.fromJson(Map<String, dynamic> data) =>
      _$TreasureDeviceFromJson(data);

  Map<String, dynamic> toJson() => _$TreasureDeviceToJson(this);

  TreasureDevice({
    this.enhanced,
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
    this.effects,
  });
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

  Skill({
    this.state,
    this.openTime,
    this.openCondition,
    this.openQuest,
    this.enhanced,
    this.name,
    this.nameJp,
    this.rank,
    this.icon,
    this.cd,
    this.effects,
  });
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
class SvtProfileData {
  String profile;
  String profileJp;
  String condition;

  SvtProfileData({this.profile, this.profileJp, this.condition});

  factory SvtProfileData.fromJson(Map<String, dynamic> data) =>
      _$SvtProfileDataFromJson(data);

  Map<String, dynamic> toJson() => _$SvtProfileDataToJson(this);
}
