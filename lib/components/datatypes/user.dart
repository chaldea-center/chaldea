// userdata: plan etc.
part of datatypes;

@JsonSerializable(checked: true)
class User {
  @JsonKey(nullable: false)
  String name;
  String server;

  // plans

  Map<int, ServantStatus> servants;
  int curSvtPlanNo;

  /// Map<planNo, Map<SvtNo, SvtPlan>>
  List<Map<int, ServantPlan>> servantPlans;

  Map<int, ServantPlan> get curSvtPlan => servantPlans[curSvtPlanNo];
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

  void reset() {
    treasureDeviceLv = 1;
    treasureDeviceEnhanced = null;
    skillEnhanced.fillRange(0, 3, null);
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

  factory ServantPlan.fromJson(Map<String, dynamic> data) =>
      _$ServantPlanFromJson(data);

  Map<String, dynamic> toJson() => _$ServantPlanToJson(this);
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
