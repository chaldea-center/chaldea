// userdata: plan etc.
part of datatypes;

@JsonSerializable(checked: true)
class User {
  @JsonKey(nullable: false)
  String name;
  GameServer server;

  Map<int, ServantStatus> servants;
  int curSvtPlanNo;

  /// Map<planNo, Map<SvtNo, SvtPlan>>
  List<Map<int, ServantPlan>> servantPlans;

  /// user own items, key: item name, value: item count
  Map<String, int> items;
  EventPlans events;
  Map<String, int> mysticCodes;
  bool isMasterGirl;

  User({
    @required this.name,
    this.server,
    this.servants,
    this.curSvtPlanNo,
    this.servantPlans,
    this.items,
    this.events,
    this.mysticCodes,
    this.isMasterGirl,
  }) : assert(name != null && name.isNotEmpty) {
    server ??= GameServer.cn;
    servants ??= {};
    curSvtPlanNo ??= 0;
    servantPlans ??= List.generate(5, (i) => <int, ServantPlan>{});
    items ??= {};
    events ??= EventPlans();
    mysticCodes ??= {};
    isMasterGirl ??= true;
  }

  Map<int, ServantPlan> get curSvtPlan {
    if (curSvtPlanNo >= servantPlans.length) {
      servantPlans.length = curSvtPlanNo + 1;
      for (int index = 0; index < servantPlans.length; index++) {
        servantPlans[index] ??= <int, ServantPlan>{};
      }
    }
    return servantPlans[curSvtPlanNo];
  }

  ServantPlan svtPlanOf(int no) =>
      curSvtPlan.putIfAbsent(no, () => ServantPlan())..validate();

  ServantStatus svtStatusOf(int no) =>
      servants.putIfAbsent(no, () => ServantStatus())..curVal.validate();

  factory User.fromJson(Map<String, dynamic> data) => _$UserFromJson(data);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable(checked: true)
class ServantStatus {
  ServantPlan curVal;
  int npLv;

  @Deprecated('Use "npLv" instead')
  int tdLv;

  /// null-not set, >=0 index, sorted from non-enhanced to enhanced
  List<int> skillIndex; //length=3
  /// default 0, origin order in wiki
  int npIndex;

  /// priority 1-5
  int priority;

  ServantStatus({
    this.curVal,
    this.npLv,
    this.tdLv,
    this.skillIndex,
    this.npIndex,
    this.priority,
  }) {
    validate();
  }

  void validate() {
    curVal ??= ServantPlan();
    curVal.validate();
    // ignore: deprecated_member_use_from_same_package
    npLv = fixValidRange(npLv ?? tdLv ?? 1, 1, 5);
    npIndex ??= 0;
    skillIndex ??= <int>[]..length = 3;
    priority = fixValidRange(priority ?? 1, 1, 5);
  }

  void reset() {
    curVal.reset();
    npLv = 1;
    skillIndex.fillRange(0, 3, null);
    npIndex = 0;
    priority = 1;
  }

  factory ServantStatus.fromJson(Map<String, dynamic> data) =>
      _$ServantStatusFromJson(data);

  Map<String, dynamic> toJson() => _$ServantStatusToJson(this);
}

@JsonSerializable(checked: true)
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

  void fixDressLength(int length, [int fill = 0]) {
    dress.length = length;
    for (int i = 0; i < dress.length; i++) {
      dress[i] ??= fill;
    }
  }

  void validate() {
    ascension = fixValidRange(ascension ?? 0, 0, 4);
    skills ??= [1, 1, 1];
    for (int i = 0; i < skills.length; i++) {
      skills[i] = fixValidRange(skills[i], 1, 10);
    }
    dress ??= [];
    for (int i = 0; i < dress.length; i++) {
      dress[i] = fixValidRange(dress[i], 0, 1);
    }
    // check grail max limit when used
    grail = fixValidRange(grail ?? 0, 0);
  }

  factory ServantPlan.fromJson(Map<String, dynamic> data) =>
      _$ServantPlanFromJson(data)..validate();

  Map<String, dynamic> toJson() => _$ServantPlanToJson(this);

  ServantPlan copyWith(bool favorite, int ascension, List<int> skills,
      List<int> dress, int grail) {
    return ServantPlan(
      favorite: favorite ?? this.favorite,
      ascension: ascension ?? this.ascension,
      skills: skills ?? this.skills,
      dress: dress ?? this.dress,
      grail: grail ?? this.grail,
    );
  }

  void copyFrom(ServantPlan other) {
    favorite = other.favorite;
    ascension = other.ascension;
    skills = List.from(other.skills);
    dress = List.from(other.dress);
    grail = other.grail;
  }

  static ServantPlan from(ServantPlan other) => ServantPlan()..copyFrom(other);
}

@JsonSerializable(checked: true)
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

@JsonSerializable(checked: true)
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
