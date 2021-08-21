part of datatypes;

enum SvtCompare { no, className, rarity, atk, hp, priority }

@JsonSerializable(checked: true)
class Servant with GameCardMixin {
  // left avatar & model
  int no;
  @JsonKey(ignore: true)
  int originNo;

  /// the real identity [svtId] in game database
  /// default -1 for [Servant.unavailable]
  int svtId;
  String mcLink;

  // @deprecated
  String icon;

  String get thumb => icon;
  ServantBaseInfo info;
  List<NoblePhantasm> noblePhantasm;
  List<NoblePhantasm> noblePhantasmEn;
  List<ActiveSkill> activeSkills;
  List<ActiveSkill> activeSkillsEn;
  List<Skill> passiveSkills;
  List<Skill> passiveSkillsEn;
  List<Skill> appendSkills;
  int coinSummonNum;
  ItemCost itemCost;
  List<int> costumeNos;
  List<int> bondPoints;

  /// 0:default, 1-6:profile 1-6, 7:april fool's
  List<SvtProfileData> profiles;
  List<VoiceTable> voices;
  int bondCraft;
  List<int> valentineCraft;
  List<KeyValueListEntry> icons;
  List<KeyValueListEntry> sprites;

  // from data file not in code
  static List<int> get unavailable => db.gameData.unavailableSvts;

  String toString() => '$runtimeType(No.$no-$mcLink)';

  String get lName => info.localizedName;

  String get stdClassName {
    String clsName;
    if (info.className.startsWith('Beast'))
      clsName = 'Beast';
    else if (info.className.contains('Caster'))
      clsName = 'Caster';
    else
      clsName = info.className;
    assert(SvtFilterData.classesData.contains(clsName),
        'svt class name: "$clsName", ${clsName == "Beast"},${SvtFilterData.classesData}');
    return clsName;
  }

  List<NoblePhantasm> get lNoblePhantasm =>
      Language.isEN && noblePhantasmEn.isNotEmpty
          ? noblePhantasmEn
          : noblePhantasm;

  List<ActiveSkill> get lActiveSkills =>
      Language.isEN && activeSkillsEn.isNotEmpty
          ? activeSkillsEn
          : activeSkills;

  List<Skill> get lPassiveSkills => Language.isEN && passiveSkillsEn.isNotEmpty
      ? passiveSkillsEn
      : passiveSkills;

  Servant({
    required this.no,
    required this.svtId,
    required this.mcLink,
    required this.icon,
    required this.info,
    required this.noblePhantasm,
    required this.noblePhantasmEn,
    required this.activeSkills,
    required this.activeSkillsEn,
    required this.passiveSkills,
    required this.passiveSkillsEn,
    required this.appendSkills,
    required this.coinSummonNum,
    required this.itemCost,
    required this.costumeNos,
    required this.bondPoints,
    required this.profiles,
    required this.voices,
    required this.bondCraft,
    required this.valentineCraft,
    required this.icons,
    required this.sprites,
  }) : originNo = no;

  Servant duplicate(int newNo) {
    return Servant.fromJson(deepCopy(this))
      ..no = newNo
      ..originNo = originNo;
  }

  String get cardBackFace {
    final _colors = ['黑', '铜', '铜', '银', '金', '金'];
    String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
    String key = '${capitalize(this.stdClassName)}'
        '${_colors[this.info.rarity]}卡背';
    if (this.no == 285) {
      // 泳装杀生院
      key += '2';
    } else if (this.no == 1) {
      //玛修
      key = '普通金卡背';
    } else if (this.stdClassName.startsWith('Beast')) {
      key = '普通黑卡背';
    }
    return key;
  }

  /// [cur]=[target]=null: all
  /// [cur.favorite]=true
  /// else empty
  Map<String, int> getAllCost(
      {ServantStatus? status, ServantPlan? target, bool all = false}) {
    if (all) {
      return sumDict([
        getAscensionCost(),
        getSkillCost(),
        getDressCost(),
        getAppendSkillCost(),
        getExtraCost()
      ]);
    }
    ServantPlan? cur = status?.curVal;
    target ??= ServantPlan();
    if (cur?.favorite == true) {
      final items = sumDict([
        getAscensionCost(cur: cur!.ascension, target: target.ascension),
        getSkillCost(cur: cur.skills, target: target.skills),
        getDressCost(cur: cur.dress, target: target.dress),
        getAppendSkillCost(cur: cur.appendSkills, target: target.appendSkills),
        getExtraCost(cur: cur, target: target)
      ]);
      if (status != null) {
        items[Items.servantCoin] =
            max(0, (items[Items.servantCoin] ?? 0) - status.coin);
      }
      return items;
    } else {
      return {};
    }
  }

  SvtParts<Map<String, int>> getAllCostParts(
      {ServantStatus? status, ServantPlan? target, bool all = false}) {
    // no grail?
    if (all) {
      return SvtParts(
        ascension: getAscensionCost(),
        skill: getSkillCost(),
        dress: getDressCost(),
        appendSkill: getAppendSkillCost(),
        extra: getExtraCost(),
      );
    }
    ServantPlan? cur = status?.curVal;
    target ??= ServantPlan();
    if (cur?.favorite == true) {
      return SvtParts(
        ascension:
            getAscensionCost(cur: cur!.ascension, target: target.ascension),
        skill: getSkillCost(cur: cur.skills, target: target.skills),
        dress: getDressCost(cur: cur.dress, target: target.dress),
        appendSkill: getAppendSkillCost(
            cur: cur.appendSkills, target: target.appendSkills),
        extra: getExtraCost(cur: cur, target: target),
      );
    } else {
      return SvtParts(k: () => <String, int>{});
    }
  }

  Map<String, int> getAscensionCost({int cur = 0, int target = 4}) {
    cur = fixValidRange(cur, 0, 4);
    target = fixValidRange(target, 0, 4);
    if (itemCost.ascension.isEmpty) return {};
    return sumDict(itemCost.ascension.sublist(cur, max(cur, target)));
  }

  Map<String, int> getSkillCost({List<int>? cur, List<int>? target}) {
    if (itemCost.skill.isEmpty || itemCost.skill.first.isEmpty) return {};
    cur ??= [1, 1, 1];
    target ??= [10, 10, 10];
    Map<String, int> items = {};

    for (int i = 0; i < 3; i++) {
      cur[i] = fixValidRange(cur[i], 1, 10);
      target[i] = fixValidRange(target[i], 1, 10);
      // lv 1-10 -> 0-9
      for (int j = cur[i] - 1; j < target[i] - 1; j++) {
        sumDict([items, itemCost.skill[j]], inPlace: true);
      }
    }
    return items;
  }

  Map<String, int> getAppendSkillCost({List<int>? cur, List<int>? target}) {
    if (itemCost.appendSkill.isEmpty || itemCost.appendSkill.first.isEmpty)
      return {};
    cur ??= [0, 0, 0];
    target ??= [10, 10, 10];
    Map<String, int> items = {};

    for (int i = 0; i < 3; i++) {
      cur[i] = fixValidRange(cur[i], 0, 10);
      target[i] = fixValidRange(target[i], 0, 10);
      // lv 1-10 -> 0-9
      for (int j = cur[i]; j < target[i]; j++) {
        sumDict([items, itemCost.appendSkillWithCoin[j]], inPlace: true);
      }
    }
    // if (coin != null) {
    //   items[Items.servantCoin] = max(0, (items[Items.servantCoin] ?? 0) - coin);
    // }
    return items;
  }

  Map<String, int> getDressCost({List<int>? cur, List<int>? target}) {
    Map<String, int> items = {};
    final dressNum = costumeNos.length;
    if (cur == null) cur = List.filled(dressNum, 0, growable: true);
    if (target == null) target = List.filled(dressNum, 1, growable: true);
    if (cur.length < dressNum)
      cur.addAll(List.filled(dressNum - cur.length, 0, growable: true));
    if (target.length < dressNum)
      target.addAll(List.filled(dressNum - target.length, 0, growable: true));

    for (int i = 0; i < dressNum; i++) {
      cur[i] = fixValidRange(cur[i], 0, 1);
      target[i] = fixValidRange(target[i], 0, 1);
      if (cur[i] == 0 && target[i] == 1) {
        sumDict([items, db.gameData.costumes[costumeNos[i]]?.itemCost],
            inPlace: true);
      }
    }
    return items;
  }

  Map<String, int> getExtraCost({ServantPlan? cur, ServantPlan? target}) {
    final maxGrail = Grail.maxGrailCount(this.info.rarity);
    cur ??= ServantPlan();
    target ??= ServantPlan()
      ..grail = maxGrail
      ..fouHp = 50
      ..fouAtk = 50
      ..bondLimit = 15;
    int coins = max(0, target.grail - maxGrail + 10) * 30 -
        max(0, cur.grail - maxGrail + 10) * 30;
    int qp = sum([
      QPCost.bondLimitQP(cur.bondLimit, target.bondLimit),
      QPCost.grailQp(this.info.rarity, cur.grail, target.grail),
    ]);
    return <String, int>{
      Items.grail: max(0, target.grail - cur.grail),
      Items.servantCoin: max(0, coins),
      Items.fou4Hp: max(0, target.fouHp - max(0, cur.fouHp)),
      Items.fou4Atk: max(0, target.fouAtk - max(0, cur.fouAtk)),
      Items.fou3Hp: max(0, min(0, target.fouHp) - cur.fouHp),
      Items.fou3Atk: max(0, min(0, target.fouAtk) - cur.fouAtk),
      Items.chaldeaLantern: max(0, target.lanternCost - cur.lanternCost),
      Items.qp: qp,
    }..removeWhere((key, value) => value <= 0);
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

  static int compare(Servant? a, Servant? b,
      {List<SvtCompare>? keys, List<bool>? reversed, User? user}) {
    if (a == null && b == null) return 0;
    if (a == null) return -1;
    if (b == null) return 1;

    int res = 0;
    if (keys == null || keys.isEmpty) {
      keys = [SvtCompare.no];
    }
    for (var i = 0; i < keys.length; i++) {
      int r;
      switch (keys[i]) {
        case SvtCompare.no:
          r = a.originNo - b.originNo;
          if (r == 0) r = a.no - b.no;
          break;
        case SvtCompare.className:
          r = a.getClassSortIndex() - b.getClassSortIndex();
          break;
        case SvtCompare.rarity:
          r = a.info.rarity - b.info.rarity;
          break;
        case SvtCompare.atk:
          r = (a.info.atkMax) - (b.info.atkMax);
          break;
        case SvtCompare.hp:
          r = (a.info.hpMax) - (b.info.hpMax);
          break;
        case SvtCompare.priority:
          final aa = user?.svtStatusOf(a.no), bb = user?.svtStatusOf(b.no);
          r = (aa?.priority ?? 1) - (bb?.priority ?? 1);
          break;
      }
      res = res * 1000000 + ((reversed?.elementAt(i) ?? false) ? -r : r);
    }
    return res;
  }

  Future pushDetail(BuildContext context) {
    return SplitRoute.push(context, ServantDetailPage(this));
  }

  @override
  Widget iconBuilder({
    required BuildContext context,
    double? width,
    double? height,
    double? aspectRatio = 132 / 144,
    String? text,
    EdgeInsets? padding,
    EdgeInsets? textPadding,
    VoidCallback? onTap,
    bool jumpToDetail = true,
  }) {
    return super.iconBuilder(
      context: context,
      width: width,
      height: height,
      aspectRatio: aspectRatio,
      text: text,
      padding: padding,
      textPadding: textPadding,
      onTap: onTap ??
          (jumpToDetail
              ? () => SplitRoute.push(context, ServantDetailPage(this))
              : null),
    );
  }

  static Widget withFavIcon(
      {required Widget child, bool favorite = false, double size = 10}) {
    if (!favorite) return child;
    return Stack(
      alignment: Alignment.topRight,
      children: [
        child,
        IgnorePointer(
          child: Container(
            padding: EdgeInsets.all(size * 0.2),
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(size * 0.4)),
            child: Icon(
              Icons.favorite,
              color: Colors.white,
              size: size,
            ),
          ),
        )
      ],
    );
  }

  factory Servant.fromJson(Map<String, dynamic> data) =>
      _$ServantFromJson(data);

  Map<String, dynamic> toJson() => _$ServantToJson(this);
}

@JsonSerializable(checked: true)
class ServantBaseInfo {
  int gameId;
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
  String? illustratorJp;
  String? illustratorEn;
  String className;
  String attribute;
  bool isHumanoid;
  bool isWeakToEA;
  bool isTDNS;
  List<String> cv;
  List<String> cvJp;
  List<String> cvEn;
  List<String> alignments;
  List<String> traits;
  Map<String, String> ability;
  Map<String, String> illustrations; //key: description, value:wiki filename
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
    required this.gameId,
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.namesOther,
    required this.namesJpOther,
    required this.namesEnOther,
    required this.nicknames,
    required this.obtain,
    required this.obtains,
    required this.rarity,
    required this.rarity2,
    required this.weight,
    required this.height,
    required this.gender,
    required this.illustrator,
    required this.illustratorJp,
    required this.illustratorEn,
    required this.className,
    required this.attribute,
    required this.isHumanoid,
    required this.isWeakToEA,
    required this.isTDNS,
    required this.cv,
    required this.cvJp,
    required this.cvEn,
    required this.alignments,
    required this.traits,
    required this.ability,
    required this.illustrations,
    required this.cards,
    required this.cardHits,
    required this.cardHitsDamage,
    required this.npRate,
    required this.atkMin,
    required this.hpMin,
    required this.atkMax,
    required this.hpMax,
    required this.atk90,
    required this.hp90,
    required this.atk100,
    required this.hp100,
    required this.starRate,
    required this.deathRate,
    required this.criticalRate,
  });

  String get localizedName => localizeNoun(name, nameJp, nameEn);

  String get lIllustrator =>
      localizeNoun(illustrator, illustratorJp, illustratorEn);

  List<String> get lCV =>
      localizeNoun<List<String>>(cv, cvJp, cvEn, k: () => <String>[]);

  factory ServantBaseInfo.fromJson(Map<String, dynamic> data) =>
      _$ServantBaseInfoFromJson(data);

  Map<String, dynamic> toJson() => _$ServantBaseInfoToJson(this);
}

@JsonSerializable(checked: true)
class NoblePhantasm {
  String? state;
  String? openCondition;
  String name;
  String? nameJp;
  String upperName;
  String? upperNameJp;
  String? color;
  String category;
  String? rank;
  String? typeText;
  List<Effect> effects;

  NoblePhantasm({
    required this.state,
    required this.openCondition,
    required this.name,
    required this.nameJp,
    required this.upperName,
    required this.upperNameJp,
    required this.color,
    required this.category,
    required this.rank,
    required this.typeText,
    required this.effects,
  });

  String get lName => localizeNoun(name, nameJp, null);

  factory NoblePhantasm.fromJson(Map<String, dynamic> data) =>
      _$NoblePhantasmFromJson(data);

  Map<String, dynamic> toJson() => _$NoblePhantasmToJson(this);
}

@JsonSerializable(checked: true)
class ActiveSkill {
  int cnState;
  List<Skill> skills;

  ActiveSkill({required this.cnState, required this.skills});

  Skill ofIndex(int? index) {
    if (index != null && index >= 0 && index < skills.length) {
      return skills[index];
    } else {
      return Language.isCN
          ? skills.getOrNull(cnState) ?? skills.last
          : skills.last;
    }
  }

  factory ActiveSkill.fromJson(Map<String, dynamic> data) =>
      _$ActiveSkillFromJson(data);

  Map<String, dynamic> toJson() => _$ActiveSkillToJson(this);
}

@JsonSerializable(checked: true)
class Skill {
  String state;
  String? openCondition;
  String name;
  String? nameJp;
  String? nameEn;
  String? rank;
  String icon;
  int cd;
  List<Effect> effects;

  Skill({
    required this.state,
    required this.openCondition,
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.rank,
    required this.icon,
    required this.cd,
    required this.effects,
  });

  String get localizedName => localizeNoun(name, nameJp, nameEn);

  String get state2 {
    if (state.trim().isNotEmpty) return state;
    return 'Rank $rank';
  }

  factory Skill.fromJson(Map<String, dynamic> data) => _$SkillFromJson(data);

  Map<String, dynamic> toJson() => _$SkillToJson(this);
}

@JsonSerializable(checked: true)
class Effect {
  String description;
  String? descriptionJp;
  String? descriptionEn;
  List<String> lvData;

  Effect({
    required this.description,
    required this.descriptionJp,
    required this.descriptionEn,
    required this.lvData,
  });

  String get lDescription =>
      localizeNoun(description, descriptionJp, descriptionEn);

  factory Effect.fromJson(Map<String, dynamic> data) => _$EffectFromJson(data);

  Map<String, dynamic> toJson() => _$EffectToJson(this);
}

@JsonSerializable(checked: true)
class SvtProfileData {
  String? title;
  String? description;
  String? descriptionJp;
  String? descriptionEn;
  String? condition;
  String? conditionEn;

  SvtProfileData({
    required this.title,
    required this.description,
    required this.descriptionJp,
    required this.descriptionEn,
    required this.condition,
    required this.conditionEn,
  });

  String get lDescription =>
      localizeNoun(description, descriptionJp, descriptionEn, k: () => '???');

  String get lCondition => localizeNoun(condition, null, conditionEn);

  factory SvtProfileData.fromJson(Map<String, dynamic> data) =>
      _$SvtProfileDataFromJson(data);

  Map<String, dynamic> toJson() => _$SvtProfileDataToJson(this);
}

@JsonSerializable(checked: true)
class VoiceTable {
  String section;
  List<VoiceRecord> table;

  VoiceTable({required this.section, required this.table});

  factory VoiceTable.fromJson(Map<String, dynamic> data) =>
      _$VoiceTableFromJson(data);

  Map<String, dynamic> toJson() => _$VoiceTableToJson(this);
}

@JsonSerializable(checked: true)
class VoiceRecord {
  String title;
  String? text;
  String? textJp;
  String? textEn;
  String? condition;
  String? voiceFile;

  VoiceRecord({
    required this.title,
    required this.text,
    required this.textJp,
    required this.textEn,
    required this.condition,
    required this.voiceFile,
  });

  factory VoiceRecord.fromJson(Map<String, dynamic> data) =>
      _$VoiceRecordFromJson(data);

  Map<String, dynamic> toJson() => _$VoiceRecordToJson(this);
}

@JsonSerializable(checked: true)
class Costume {
  int no;
  int gameId;
  int svtNo;
  String name;
  String nameJp;
  String nameEn;
  String icon;
  String avatar;
  List<String> models;
  String illustration;
  String? description;
  String? descriptionJp;
  Map<String, int> itemCost;
  String? obtain;
  String? obtainEn;

  Costume({
    required this.no,
    required this.gameId,
    required this.svtNo,
    required this.name,
    required this.nameJp,
    required this.nameEn,
    required this.icon,
    required this.avatar,
    required this.models,
    required this.illustration,
    required this.description,
    required this.descriptionJp,
    required this.itemCost,
    required this.obtain,
    required this.obtainEn,
  });

  String get lName => localizeNoun(name, nameJp, nameEn);

  String get lDescription => localizeNoun(description, descriptionJp, null);

  String get lObtain => localizeNoun(obtain, null, obtainEn);

  factory Costume.fromJson(Map<String, dynamic> data) =>
      _$CostumeFromJson(data);

  Map<String, dynamic> toJson() => _$CostumeToJson(this);
}
