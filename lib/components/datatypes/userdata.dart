// userdata: plan etc.
part of datatypes;

@JsonSerializable()
class User {
  @JsonKey(nullable: false)
  String name;
  String server;
  Plans plans;

  User({@required this.name, this.server, this.plans})
      : assert(name != null && name.isNotEmpty) {
    server ??= GameServer.cn;
    plans ??= Plans();
  }

  factory User.fromJson(Map<String, dynamic> data) => _$UserFromJson(data);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable(anyMap: true)
class Plans {
  Map<int, ServantPlan> servants;
  Map<String, int> items;
  Map<String, EventPlan> events;

  Plans({this.servants, this.items}) {
    servants ??= {};
    items ??= {};
    events ??= {};
  }

  factory Plans.fromJson(Map<String, dynamic> data) => _$PlansFromJson(data);

  Map<String, dynamic> toJson() => _$PlansToJson(this);
}

@JsonSerializable()
class ServantPlan {
  List<int> ascensionLv;
  List<List<int>> skillLv;
  List<List<int>> dressLv;
  List<int> grailLv;
  List<bool> skillEnhanced;
  bool npEnhanced;
  int npLv;
  bool favorite;

  factory ServantPlan.fromJson(Map<String, dynamic> data) =>
      _$ServantPlanFromJson(data);

  Map<String, dynamic> toJson() => _$ServantPlanToJson(this);

  ServantPlan(
      {this.ascensionLv,
      this.skillLv,
      this.dressLv,
      this.grailLv,
      this.skillEnhanced,
      this.npEnhanced,
      this.npLv,
      this.favorite = false}) {
    ascensionLv ??= [0, 0];
    skillLv ??= List.generate(3, (i) => [1, 1]);
    dressLv ??= [];
    grailLv ??= [0, 0];
    skillEnhanced ??= [null, null, null];
    // npEnhanced??=null;
    npLv ??= 1;
    favorite ??= false;
  }
}

@JsonSerializable()
class EventPlan {
  bool enable;
  bool rerun;
  int lottery;
  Map<String, int> hunting;

  EventPlan({this.enable, this.rerun, this.lottery, this.hunting}) {
    enable ??= false;
    rerun ??= true;
    lottery ??= 0;
    hunting ??= {};
  }

  factory EventPlan.fromJson(Map<String, dynamic> data) =>
      _$EventPlanFromJson(data);

  Map<String, dynamic> toJson() => _$EventPlanToJson(this);
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
  Map<int, PartSet<Map<String, int>>> planCountBySvt, allCountBySvt;

  // Map<ItemKey, List<Map<SvtNo, num>>>
  Map<String, PartSet<Map<int, int>>> planCountByItem, allCountByItem;

  ItemCostStatistics(GameData gameData, Map<int, ServantPlan> plans) {
    update(gameData, plans);
  }

  void update(GameData gameData, Map<int, ServantPlan> plans) {
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
      PartSet<Map<int, int>> planOneItem = PartSet<Map<int, int>>(k: () => {}),
          allOneItem = PartSet<Map<int, int>>(k: () => {});
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
    PartSet<Map<int, int>> value =
        planned ? planCountByItem[itemKey] : allCountByItem[itemKey];
    return PartSet<int>(
        ascension: sum(value.ascension.values),
        skill: sum(value.skill.values),
        dress: sum(value.dress.values));
  }

  PartSet<Map<int, int>> getSvtListOfItem(String itemKey,
      [bool planned = true]) {
    return planned ? planCountByItem[itemKey] : allCountByItem[itemKey];
  }
}
