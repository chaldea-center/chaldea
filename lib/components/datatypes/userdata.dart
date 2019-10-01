// userdata: plan etc.
part of datatypes;

@JsonSerializable(anyMap: true)
class Plans {
  Map<String, ServantPlan> servants;

  Map<String, int> items;

  factory Plans.fromJson(Map<String, dynamic> data) => _$PlansFromJson(data);

  Map<String, dynamic> toJson() => _$PlansToJson(this);

  Plans({this.servants, this.items}) {
    servants = servants ?? <String, ServantPlan>{};
    items = items ?? <String, int>{};
  }
}

@JsonSerializable()
class ServantPlan {
  @JsonKey(defaultValue: [0, 0])
  List<int> ascensionLv;
  @JsonKey(defaultValue: [
    [1, 1],
    [1, 1],
    [1, 1]
  ])
  List<List<int>> skillLv;
  @JsonKey(defaultValue: [])
  List<List<int>> dressLv;
  @JsonKey(defaultValue: [0, 0])
  List<int> grailLv;

  //enhanced - 0:default,1:enhanced,-1:not enhanced
  //TODO: use 0,1 and null
  @JsonKey(nullable: true)
  List<Sign> skillEnhanced;
  @JsonKey()
  Sign npEnhanced;
  @JsonKey(defaultValue: 1)
  int npLv;

  @JsonKey(defaultValue: false)
  bool favorite;

  factory ServantPlan.fromJson(Map<String, dynamic> data) =>
      _$ServantPlanFromJson(data);

  Map<String, dynamic> toJson() => _$ServantPlanToJson(this);

  ServantPlan({this.ascensionLv,
    this.skillLv,
    this.dressLv,
    this.grailLv,
      this.skillEnhanced,
    this.npEnhanced = Sign.none,
      this.npLv = 1,
      this.favorite = false}) {
    ascensionLv = ascensionLv ?? [0, 0];
    skillLv = skillLv ??
        [
          [1, 1],
          [1, 1],
          [1, 1]
        ];
    dressLv = dressLv ?? [];
    grailLv = grailLv ?? [0, 0];
    skillEnhanced = skillEnhanced ?? [Sign.none, Sign.none, Sign.none];
  }
}

class PartSet<T> {
  T ascension;
  T skill;
  T dress;

  PartSet({this.ascension, this.skill, this.dress, T k()}) {
    ascension ??= k();
    skill ??= k();
    dress ??= k();
  }

  List<T> get values => [ascension, skill, dress];

  @override
  String toString() {
    // TODO: implement toString
    return 'PartSet<$T>(\n  ascension:$ascension,\n  skill:$skill,\n  dress:$dress))';
  }

  void forEach(void f(T)) {
    f(ascension);
    f(skill);
    f(dress);
  }
}

class ItemCostStatistics {
  //Map<SvtNo, List<Map<ItemKey,num>>>
  Map<String, PartSet<Map<String, int>>> planCountBySvt, allCountBySvt;

  // Map<ItemKey, List<Map<SvtNo, num>>>
  Map<String, PartSet<Map<String, int>>> planCountByItem, allCountByItem;

  ItemCostStatistics(GameData gameData, Map<String, ServantPlan> plans) {
    update(gameData, plans);
  }

  void update(GameData gameData, Map<String, ServantPlan> plans) {
    planCountBySvt = {};
    allCountBySvt = {};
    planCountByItem = {};
    allCountByItem = {};
    gameData.servants.forEach((no, svt) {
      if (plans != null && plans[no]?.favorite == true) {
        planCountBySvt[no] = PartSet<Map<String, int>>(
            ascension: svt.calAscensionCost(lv: plans[no].ascensionLv),
            skill: svt.calSkillCost(lv: plans[no].skillLv),
            dress: svt.calDressCost(lv: plans[no].dressLv));
      } else {
        planCountBySvt[no] = PartSet<Map<String, int>>(k: () => {});
      }
      allCountBySvt[no] = PartSet<Map<String, int>>(
          ascension: svt.calAscensionCost(),
          skill: svt.calSkillCost(),
          dress: svt.calDressCost());
    });
    // cal items
    for (String itemKey in gameData.items.keys) {
      PartSet<Map<String, int>> planOneItem =
      PartSet<Map<String, int>>(k: () => {}),
          allOneItem = PartSet<Map<String, int>>(k: () => {});
      planCountBySvt.forEach((no, value) {
        planOneItem.ascension[no] =
            (planOneItem.ascension[no] ?? 0) + (value.ascension[itemKey] ?? 0);
        planOneItem.skill[no] =
            (planOneItem.skill[no] ?? 0) + (value.skill[itemKey] ?? 0);
        planOneItem.dress[no] =
            (planOneItem.dress[no] ?? 0) + (value.dress[itemKey] ?? 0);
      });
      allCountBySvt.forEach((no, value) {
        allOneItem.ascension[no] =
            (allOneItem.ascension[no] ?? 0) + (value.ascension[itemKey] ?? 0);
        allOneItem.skill[no] =
            (allOneItem.skill[no] ?? 0) + (value.skill[itemKey] ?? 0);
        allOneItem.dress[no] =
            (allOneItem.dress[no] ?? 0) + (value.dress[itemKey] ?? 0);
      });
      planCountByItem[itemKey] = planOneItem
        ..forEach((e) => e.removeWhere((k, v) => v == 0));
      allCountByItem[itemKey] = allOneItem
        ..forEach((e) => e.removeWhere((k, v) => v == 0));
    }
  }

  PartSet<int> getNumOfItem(String itemKey, [bool planned = true]) {
    //used in ItemCostListPage
    PartSet<Map<String, int>> value =
    planned ? planCountByItem[itemKey] : allCountByItem[itemKey];
    return PartSet<int>(
        ascension: sum(value.ascension.values),
        skill: sum(value.skill.values),
        dress: sum(value.dress.values));
  }

  PartSet<Map<String, int>> getSvtListOfItem(String itemKey,
      [bool planned = true]) {
    return planned ? planCountByItem[itemKey] : allCountByItem[itemKey];
  }
}

class CostTable {
  //key1-itemName,key2-svtNo
  Map<String, Map<String, int>> data;

  CostTable(Map<String, Servant> servants, [Map<String, ServantPlan> plans]) {
    servants.forEach((no, svt) {
      svt.calculateCost(plans[no]);
    });
  }

  void getSvtList(String item) {
    //return Map<svtNo, num>
  }

  void getAscensionList(String item) {}
}
