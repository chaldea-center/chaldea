//@dart=2.9
part of datatypes;

enum SvtCompare { no, className, rarity, atk, hp, priority }

@JsonSerializable(checked: true)
class Servant {
  // left avatar & model
  int no;
  String mcLink;
  String icon;
  ServantBaseInfo info;
  List<NobelPhantasm> nobelPhantasm;
  List<ActiveSkill> activeSkills;
  List<Skill> passiveSkills;
  ItemCost itemCost;
  List<int> bondPoints;
  List<SvtProfileData> profiles;
  List<VoiceTable> voices;
  int bondCraft;
  List<int> valentineCraft;

  // from data file not in code
  static const List<int> unavailable = [83, 149, 151, 152, 168, 240];

  String toString() => mcLink;

  Servant({
    this.no,
    this.mcLink,
    this.icon,
    this.info,
    this.nobelPhantasm,
    this.activeSkills,
    this.passiveSkills,
    this.itemCost,
    this.bondPoints,
    this.profiles,
    this.voices,
    this.bondCraft,
    this.valentineCraft,
  });

  /// [cur]=[target]=null: all
  /// [cur.favorite]=[target.favorite]=true
  /// else empty
  Map<String, int> getAllCost(
      {ServantPlan cur, ServantPlan target, bool all = false}) {
    if (all) {
      return sumDict(
          [getAscensionCost(), getSkillCost(), getDressCost(), getGrailCost()]);
    }
    target ??= ServantPlan();
    if (cur?.favorite == true) {
      return sumDict([
        getAscensionCost(cur: cur.ascension, target: target.ascension),
        getSkillCost(cur: cur.skills, target: target.skills),
        getDressCost(cur: cur.dress, target: target.dress),
        getGrailCost(cur: cur.grail, target: target.grail)
      ]);
    } else {
      return {};
    }
  }

  SvtParts<Map<String, int>> getAllCostParts(
      {ServantPlan cur, ServantPlan target, bool all = false}) {
    // no grail?
    if (all) {
      return SvtParts(
        ascension: getAscensionCost(),
        skill: getSkillCost(),
        dress: getDressCost(),
        grailAscension: getGrailCost(),
      );
    }
    target ??= ServantPlan();
    if (cur?.favorite == true) {
      return SvtParts(
        ascension:
            getAscensionCost(cur: cur.ascension, target: target.ascension),
        skill: getSkillCost(cur: cur.skills, target: target.skills),
        dress: getDressCost(cur: cur.dress, target: target.dress),
        grailAscension: getGrailCost(cur: cur.grail, target: target.grail),
      );
    } else {
      return SvtParts(k: () => <String, int>{});
    }
  }

  Map<String, int> getAscensionCost({int cur = 0, int target = 4}) {
    cur = fixValidRange(cur ?? 0, 0, 4);
    target = fixValidRange(target ?? 4, 0, 4);
    if (itemCost.ascension.isEmpty) return {};
    return sumDict(itemCost.ascension.sublist(cur, max(cur, target)));
  }

  Map<String, int> getSkillCost({List<int> cur, List<int> target}) {
    if (itemCost.skill.isEmpty || itemCost.skill.first.isEmpty) return {};
    cur ??= [1, 1, 1];
    target ??= [10, 10, 10];
    Map<String, int> items = {};

    for (int i = 0; i < 3; i++) {
      cur[i] = fixValidRange(cur[i] ?? 1, 1, 10);
      target[i] = fixValidRange(target[i] ?? 10, 1, 10);
      // lv 1-10 -> 0-9
      for (int j = cur[i] - 1; j < target[i] - 1; j++) {
        sumDict([items, itemCost.skill[j]], inPlace: true);
      }
    }
    return items;
  }

  Map<String, int> getDressCost({List<int> cur, List<int> target}) {
    Map<String, int> items = {};
    final dressNum = itemCost.dress.length;
    if (cur == null) cur = List.filled(dressNum, 0, growable: true);
    if (target == null) target = List.filled(dressNum, 1, growable: true);
    if (cur.length < dressNum)
      cur.addAll(List.filled(dressNum - cur.length, 0, growable: true));
    if (target.length < dressNum)
      target.addAll(List.filled(dressNum - target.length, 0, growable: true));

    for (int i = 0; i < dressNum; i++) {
      cur[i] = fixValidRange(cur[i] ?? 0, 0, 1);
      target[i] = fixValidRange(target[i] ?? 1, 0, 1);
      for (int j = cur[i]; j < target[i]; j++) {
        sumDict([items, itemCost.dress[i]], inPlace: true);
      }
    }
    return items;
  }

  Map<String, int> getGrailCost({int cur = 0, int target}) {
    final maxVal = [10, 10, 10, 9, 7, 5][this.info.rarity2];
    cur = fixValidRange(cur ?? 0, 0, maxVal);
    target = fixValidRange(target ?? maxVal, 0, maxVal);
    target = max(cur, target);

    return target > cur ? {Item.grail: target - cur} : <String, int>{};
  }

  int getGrailLv(int grail) {
    final maxGrail = [10, 10, 10, 9, 7, 5][info.rarity];
    if (grail == 0) return [65, 60, 65, 70, 80, 90][info.rarity];
    return [100, 98, 96, 94, 92, 90, 85, 80, 75, 70][maxGrail - grail];
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
      {List<SvtCompare> keys, List<bool> reversed, User user}) {
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
        case SvtCompare.priority:
          final aa = user?.svtStatusOf(a.no), bb = user?.svtStatusOf(b.no);
          r = (aa?.priority ?? 1) - (bb?.priority ?? 1);
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

@JsonSerializable(checked: true)
class ServantBaseInfo {
  String name;
  String nameJp;
  String nameEn;
  List<String> namesOther;
  List<String> namesJpOther;
  List<String> namesEnOther;
  List<String> nicknames;

  /// {'活动', '初始获得', '剧情', '常驻', '限定', '无法召唤', '友情点召唤'}
  String obtain;
  List<String> obtains;

  /// rarity 0-5, (小安-0, 玛修-4)
  int rarity;

  /// actual rarity for COST etc. 1~5, (小安-2, 玛修-3)
  int rarity2;
  String weight;
  String height;
  String gender;
  String illustrator;
  String className;
  String attribute;
  bool isHumanoid;
  bool isWeakToEA;
  bool isTDNS;
  List<String> cv;
  List<String> alignments;
  List<String> traits;
  Map<String, String> ability;
  Map<String, String> illustrations;
  List<String> cards;
  Map<String, int> cardHits;
  Map<String, List<int>> cardHitsDamage;
  Map<String, String> npRate;
  int atkMin;
  int hpMin;
  int atkMax;
  int hpMax;
  int atk90;
  int hp90;
  int atk100;
  int hp100;
  String starRate;
  String deathRate;
  String criticalRate;

  ServantBaseInfo({
    this.name,
    this.nameJp,
    this.nameEn,
    this.namesOther,
    this.namesJpOther,
    this.namesEnOther,
    this.nicknames,
    this.obtain,
    this.obtains,
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
    this.isTDNS,
    this.cv,
    this.alignments,
    this.traits,
    this.ability,
    this.illustrations,
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

  String get localizedName => localizeNoun(name, nameJp, nameEn);

  factory ServantBaseInfo.fromJson(Map<String, dynamic> data) =>
      _$ServantBaseInfoFromJson(data);

  Map<String, dynamic> toJson() => _$ServantBaseInfoToJson(this);
}

@JsonSerializable(checked: true)
class NobelPhantasm {
  String state;
  String name;
  String nameJp;
  String upperName;
  String upperNameJp;
  String color;
  String category;
  String rank;
  String typeText;
  List<Effect> effects;

  NobelPhantasm({
    this.state,
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

  factory NobelPhantasm.fromJson(Map<String, dynamic> data) =>
      _$NobelPhantasmFromJson(data);

  Map<String, dynamic> toJson() => _$NobelPhantasmToJson(this);
}

@JsonSerializable(checked: true)
class ActiveSkill {
  int cnState;
  List<Skill> skills;

  ActiveSkill({this.cnState, this.skills});

  factory ActiveSkill.fromJson(Map<String, dynamic> data) =>
      _$ActiveSkillFromJson(data);

  Map<String, dynamic> toJson() => _$ActiveSkillToJson(this);
}

@JsonSerializable(checked: true)
class Skill {
  String state;
  String name;
  String nameJp;
  String rank;
  String icon;
  int cd;
  List<Effect> effects;

  Skill({
    this.state,
    this.name,
    this.nameJp,
    this.rank,
    this.icon,
    this.cd,
    this.effects,
  });

  String get localizedName => localizeNoun(name, nameJp, null);

  factory Skill.fromJson(Map<String, dynamic> data) => _$SkillFromJson(data);

  Map<String, dynamic> toJson() => _$SkillToJson(this);
}

@JsonSerializable(checked: true)
class Effect {
  String description;
  List<String> lvData;

  Effect({this.description, this.lvData});

  factory Effect.fromJson(Map<String, dynamic> data) => _$EffectFromJson(data);

  Map<String, dynamic> toJson() => _$EffectToJson(this);
}

@JsonSerializable(checked: true)
class SvtProfileData {
  String title;
  String description;
  String descriptionJp;
  String condition;

  SvtProfileData(
      {this.title, this.description, this.descriptionJp, this.condition});

  factory SvtProfileData.fromJson(Map<String, dynamic> data) =>
      _$SvtProfileDataFromJson(data);

  Map<String, dynamic> toJson() => _$SvtProfileDataToJson(this);
}

@JsonSerializable(checked: true)
class VoiceTable {
  String section;
  List<VoiceRecord> table;

  VoiceTable({this.section, this.table});

  factory VoiceTable.fromJson(Map<String, dynamic> data) =>
      _$VoiceTableFromJson(data);

  Map<String, dynamic> toJson() => _$VoiceTableToJson(this);
}

@JsonSerializable(checked: true)
class VoiceRecord {
  String title;
  String text;
  String textJp;
  String condition;
  String voiceFile;

  VoiceRecord(
      {this.title, this.text, this.textJp, this.condition, this.voiceFile});

  factory VoiceRecord.fromJson(Map<String, dynamic> data) =>
      _$VoiceRecordFromJson(data);

  Map<String, dynamic> toJson() => _$VoiceRecordToJson(this);
}
