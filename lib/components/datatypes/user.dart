// userdata: plan etc.
part of datatypes;

@JsonSerializable(checked: true)
class User {
  @JsonKey(nullable: false)
  String name;
  GameServer server;

  // plans

  Map<int, ServantStatus> servants;
  int curSvtPlanNo;

  /// Map<planNo, Map<SvtNo, SvtPlan>>
  List<Map<int, ServantPlan>> servantPlans;

  Map<int, ServantPlan> get curSvtPlan => servantPlans[curSvtPlanNo];

  /// user own items, key: item name, value: item count
  Map<String, int> items;
  EventPlans events;

  User({
    @required this.name,
    this.server,
    this.servants,
    this.curSvtPlanNo,
    this.servantPlans,
    this.items,
    this.events,
  }) : assert(name != null && name.isNotEmpty) {
    server ??= GameServer.cn;
    servants ??= {};
    curSvtPlanNo ??= 0;
    servantPlans ??= List.generate(5, (i) => {});
    items ??= {};
    events ??= EventPlans();
  }

  factory User.fromJson(Map<String, dynamic> data) => _$UserFromJson(data);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable(checked: true)
class ServantStatus {
  ServantPlan curVal;

  /// null-not set, >=0 index
  List<int> skillIndex; //length=3
  int tdIndex;
  int tdLv;

  ServantStatus({
    this.curVal,
    this.skillIndex,
    this.tdIndex,
    this.tdLv,
  }) {
    curVal ??= ServantPlan();
    skillIndex ??= List.filled(3, null);
    tdIndex ??= 0;
    tdLv ??= 1;
  }

  void reset() {
    tdLv = 1;
    tdIndex = 0;
    skillIndex.fillRange(0, 3, 0);
    curVal.reset();
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
    if (length < dress.length) {
      dress.length = length;
    } else {
      dress.addAll(List.filled(length - dress.length, fill));
    }
  }

  factory ServantPlan.fromJson(Map<String, dynamic> data) =>
      _$ServantPlanFromJson(data);

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
