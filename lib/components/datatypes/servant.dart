part of datatypes;

@JsonSerializable(checked: true)
class Servant {
  // left avatar & model
  int no;
  String mcLink;
  String icon;
  ServantBaseInfo info;
  List<TreasureDevice> treasureDevice;
  List<List<Skill>> activeSkills;
  List<Skill> passiveSkills;
  ItemCost itemCost;
  List<int> bondPoints;
  List<SvtProfileData> profiles;
  int bondCraft;
  List<int> valentineCraft;

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
    this.bondPoints,
    this.profiles,
    this.bondCraft,
    this.valentineCraft,
  });

  /// [cur]=[target]=null: all
  /// [cur.favorite]=[target.favorite]=true
  /// else empty
  Map<String, int> getAllCost(
      {ServantPlan cur, ServantPlan target, bool all = false}) {
    if (all) {
      return sumDict([getAscensionCost(), getSkillCost(), getDressCost()]);
    }
    if (cur?.favorite == true && target?.favorite == true) {
      return sumDict([
        getAscensionCost(cur: cur.ascension, target: target.ascension),
        getSkillCost(cur: cur.skills, target: target.skills),
        getDressCost(cur: cur.dress, target: target.dress)
      ]);
    } else {
      return {};
    }
  }

  SvtParts<Map<String, int>> getAllCostParts(
      {ServantPlan cur, ServantPlan target, bool all = false}) {
    if (all) {
      return SvtParts(
        ascension: getAscensionCost(),
        skill: getSkillCost(),
        dress: getDressCost(),
      );
    }
    if (cur?.favorite == true && target?.favorite == true) {
      return SvtParts(
        ascension:
            getAscensionCost(cur: cur.ascension, target: target.ascension),
        skill: getSkillCost(cur: cur.skills, target: target.skills),
        dress: getDressCost(cur: cur.dress, target: target.dress),
      );
    } else {
      return SvtParts(k: () => <String, int>{});
    }
  }

  Map<String, int> getAscensionCost({int cur = 0, target = 4}) {
    Map<String, int> cost = {};
    if (itemCost?.ascension == null) {
      return cost;
    }
    for (int i = cur; i < target; i++) {
      for (var item in itemCost.ascension[i]) {
        cost[item.name] = (cost[item.name] ?? 0) + item.num;
      }
    }
    return cost;
  }

  Map<String, int> getSkillCost(
      {List<int> cur = const [1, 1, 1],
      List<int> target = const [10, 10, 10]}) {
    Map<String, int> cost = {};
    if (itemCost?.skill == null) {
      return cost;
    }
    for (int i = 0; i < 3; i++) {
      for (int j = cur[i] - 1; j < target[i] - 1; j++) {
        for (var item in itemCost.skill[j]) {
          cost[item.name] = (cost[item.name] ?? 0) + item.num;
        }
      }
    }
    return cost;
  }

  Map<String, int> getDressCost({List<int> cur, List<int> target}) {
    Map<String, int> cost = {};
    if (itemCost?.dress == null) {
      return cost;
    }
    cur ??= List.generate(itemCost.dress.length, (i) => 0);
    target ??= List.generate(itemCost.dress.length, (i) => 1);

    for (int i = 0; i < itemCost.dress.length; i++) {
      for (int j = cur[i]; j < target[i]; j++) {
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

@JsonSerializable(checked: true)
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

@JsonSerializable(checked: true)
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

@JsonSerializable(checked: true)
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

@JsonSerializable(checked: true)
class Effect {
  String description;
  String target;
  String valueType;
  List<dynamic> lvData;

  factory Effect.fromJson(Map<String, dynamic> data) => _$EffectFromJson(data);

  Map<String, dynamic> toJson() => _$EffectToJson(this);

  Effect({this.description, this.target, this.valueType, this.lvData});
}

@JsonSerializable(checked: true)
class SvtProfileData {
  String profile;
  String profileJp;
  String condition;

  SvtProfileData({this.profile, this.profileJp, this.condition});

  factory SvtProfileData.fromJson(Map<String, dynamic> data) =>
      _$SvtProfileDataFromJson(data);

  Map<String, dynamic> toJson() => _$SvtProfileDataToJson(this);
}
