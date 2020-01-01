// userdata: plan etc.
part of datatypes;

@JsonSerializable()
class User {
  @JsonKey(nullable: false)
  String name;
  String server;

  // plans

  Map<int, ServantStatus> servants;
  int curPlanNo;

  /// Map<planNo, Map<SvtNo, SvtPlan>>
  List<Map<int, ServantPlan>> servantPlans;

  Map<int, ServantPlan> get curPlan =>
      servantPlans[curPlanNo];
  Map<String, int> items;
  EventPlans events;

  User({
    @required this.name,
    this.server,
    this.servants,
    this.curPlanNo,
    this.servantPlans,
    this.items,
    this.events,
  }) : assert(name != null && name.isNotEmpty) {
    server ??= GameServer.cn;
    servants ??= {};
    curPlanNo ??= 0;
    servantPlans ??= List.generate(5, (i)=>{});
    items ??= {};
    events ??= EventPlans();
  }

  factory User.fromJson(Map<String, dynamic> data) => _$UserFromJson(data);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class ServantStatus {
  ServantPlan curVal;
  List<bool> skillEnhanced; //length=3
  int treasureDeviceEnhanced;
  int treasureDeviceLv;

  ServantStatus({
    this.curVal,
    this.skillEnhanced,
    this.treasureDeviceEnhanced,
    this.treasureDeviceLv,
  }) {
    curVal ??= ServantPlan();
    skillEnhanced ??= List.filled(3, null);
    // treasureDeviceEnhanced??=null;
    treasureDeviceLv ??= 1;
  }

  factory ServantStatus.fromJson(Map<String, dynamic> data) =>
      _$ServantStatusFromJson(data);

  Map<String, dynamic> toJson() => _$ServantStatusToJson(this);
}

@JsonSerializable()
class ServantPlan {
  bool favorite;
  int ascension;
  List<int> skills; // length 3
  List<int> dress;
  int grail;

  ServantPlan({
    this.favorite,
    this.ascension,
    this.skills,
    this.dress,
    this.grail,
  }) {
    favorite ??= false;
    ascension ??= 0;
    skills ??= List.filled(3, 1);
    dress ??= [];
    grail ??= 0;
  }

  void reset() {
    favorite = false;
    ascension = 0;
    skills.fillRange(0, 3, 1);
    dress.fillRange(0, dress.length, 0);
    grail = 0;
  }

  void setMax({int skill = 10}) {
    // not change grail lv
    favorite = true;
    ascension = 4;
    skills.fillRange(0, 3, skill);
    dress.fillRange(0, dress.length, 1);
    // grail = grail;
  }

  factory ServantPlan.fromJson(Map<String, dynamic> data) =>
      _$ServantPlanFromJson(data);

  Map<String, dynamic> toJson() => _$ServantPlanToJson(this);
}

@JsonSerializable()
class EventPlans {
  Map<String, LimitEventPlan> limitEvents;

  /// {'chapter 1': [drops_switch,rewards_switch]}
  Map<String, List<bool>> mainRecords;

  ///{'monthCn': [num1, num2, num3]}
  Map<String, List<int>> exchangeTickets;

  EventPlans({this.limitEvents, this.mainRecords, this.exchangeTickets}) {
    limitEvents ??= {};
    mainRecords ??= {};
    exchangeTickets ??= {};
  }

  factory EventPlans.fromJson(Map<String, dynamic> data) =>
      _$EventPlansFromJson(data);

  Map<String, dynamic> toJson() => _$EventPlansToJson(this);
}

@JsonSerializable()
class LimitEventPlan {
  bool enable;
  bool rerun;
  int lottery;
  Map<String, int> extra;

  LimitEventPlan({this.enable, this.rerun, this.lottery, this.extra}) {
    enable ??= false;
    rerun ??= true;
    lottery ??= 0;
    extra ??= {};
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

  void update(
      Map<int, ServantStatus> curPlan, Map<int, ServantPlan> targetPlan) {
    planCountBySvt = {};
    allCountBySvt = {};
    planCountByItem = {};
    allCountByItem = {};
    db.gameData.servants.forEach((no, svt) {
      final cur = curPlan[no]?.curVal, target = targetPlan[no];
      if (cur?.favorite == true && target?.favorite == true) {
        planCountBySvt[no] = PartSet<Map<String, int>>(
            ascension: svt.getAscensionCost(
                cur: cur.ascension, target: target.ascension),
            skill: svt.getSkillCost(cur: cur.skills, target: target.skills),
            dress: svt.getDressCost(cur: cur.dress, target: target.dress));
      } else {
        planCountBySvt[no] = PartSet<Map<String, int>>(k: () => {});
      }
      allCountBySvt[no] = PartSet<Map<String, int>>(
          ascension: svt.getAscensionCost(),
          skill: svt.getSkillCost(),
          dress: svt.getDressCost());
    });
    // cal items
    for (String itemKey in db.gameData.items.keys) {
      PartSet<Map<int, int>> planOneItem = PartSet<Map<int, int>>(k: () => {}),
          allOneItem = PartSet<Map<int, int>>(k: () => {});

      planCountBySvt.forEach((no, value) {
        planOneItem.ascension[no] =
            sum([planOneItem.ascension[no], value.ascension[itemKey]]);
        planOneItem.skill[no] =
            sum([planOneItem.skill[no], value.skill[itemKey]]);
        planOneItem.dress[no] =
            sum([planOneItem.dress[no], value.dress[itemKey]]);
      });
      allCountBySvt.forEach((no, value) {
        allOneItem.ascension[no] =
            sum([allOneItem.ascension[no], value.ascension[itemKey]]);
        allOneItem.skill[no] =
            sum([allOneItem.skill[no], value.skill[itemKey]]);
        allOneItem.dress[no] =
            sum([allOneItem.dress[no], value.dress[itemKey]]);
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
