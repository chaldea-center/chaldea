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
  Map<String, LimitEventPlan> limitEvents;

  /// {'chapter 1': [drops_switch,rewards_switch]}
  Map<String, List<bool>> mainRecords;

  ///{'monthCn': [num1, num2, num3]}
  Map<String, List<int>> exchangeTickets;

  Plans({
    this.servants,
    this.items,
    this.limitEvents,
    this.mainRecords,
    this.exchangeTickets,
  }) {
    servants ??= {};
    items ??= {};
    limitEvents ??= {};
    mainRecords ??= {};
    exchangeTickets ??= {};
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
  int treasureDeviceEnhanced;
  int treasureDeviceLv;
  bool favorite;

  factory ServantPlan.fromJson(Map<String, dynamic> data) =>
      _$ServantPlanFromJson(data);

  Map<String, dynamic> toJson() => _$ServantPlanToJson(this);

  ServantPlan({
    this.ascensionLv,
    this.skillLv,
    this.dressLv,
    this.grailLv,
    this.skillEnhanced,
    this.treasureDeviceEnhanced,
    this.treasureDeviceLv,
    this.favorite = false,
  }) {
    ascensionLv ??= [0, 0];
    skillLv ??= List.generate(3, (i) => [1, 1]);
    dressLv ??= [];
    grailLv ??= [0, 0];
    skillEnhanced ??= [null, null, null];
    // treasureDeviceEnhanced??=null;
    treasureDeviceLv ??= 1;
    favorite ??= false;
  }

  void reset() {
    ascensionLv = [0, 0];
    skillLv = List.generate(3, (i) => [1, 1]);
    dressLv = [];
    grailLv = [0, 0];
    skillEnhanced ??= [null, null, null];
    treasureDeviceEnhanced = null;
    treasureDeviceLv = 1;
    favorite = false;
  }

  void planMax([bool max9 = false]) {
    ascensionLv.last = 4;
    skillLv.forEach((e) {
      e.last = max9 ? 9 : 10;
      e.first = min(e.first, e.last);
    });
    dressLv.forEach((e) => e.last = 1);
    favorite = true;
  }

  void allMax() {
    ascensionLv = [4, 4];
    skillLv.forEach((e) => e.fillRange(0, 2, 10));
    dressLv.forEach((e) => e.fillRange(0, 2, 1));
    favorite = true;
  }
}

@JsonSerializable()
class LimitEventPlan {
  bool enable;
  bool rerun;
  int lottery;
  Map<String, int> hunting;

  LimitEventPlan({this.enable, this.rerun, this.lottery, this.hunting}) {
    enable ??= false;
    rerun ??= true;
    lottery ??= 0;
    hunting ??= {};
  }

  factory LimitEventPlan.fromJson(Map<String, dynamic> data) =>
      _$LimitEventPlanFromJson(data);

  Map<String, dynamic> toJson() => _$LimitEventPlanToJson(this);
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

class ItemsOfSvts {
  //Map<SvtNo, List<Map<ItemKey,num>>>
  Map<int, PartSet<Map<String, int>>> planCountBySvt, allCountBySvt;

  // Map<ItemKey, List<Map<SvtNo, num>>>
  Map<String, PartSet<Map<int, int>>> planCountByItem, allCountByItem;

  ItemsOfSvts();

  void update(GameData gameData, Map<int, ServantPlan> plans) {
    planCountBySvt = {};
    allCountBySvt = {};
    planCountByItem = {};
    allCountByItem = {};
    gameData.servants.forEach((no, svt) {
      if (plans != null && plans[no]?.favorite == true) {
        planCountBySvt[no] = PartSet<Map<String, int>>(
            ascension: svt.getAscensionCost(lv: plans[no].ascensionLv),
            skill: svt.getSkillCost(lv: plans[no].skillLv),
            dress: svt.getDressCost(lv: plans[no].dressLv));
      } else {
        planCountBySvt[no] = PartSet<Map<String, int>>(k: () => {});
      }
      allCountBySvt[no] = PartSet<Map<String, int>>(
          ascension: svt.getAscensionCost(),
          skill: svt.getSkillCost(),
          dress: svt.getDressCost());
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
