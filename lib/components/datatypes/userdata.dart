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
  @JsonKey()
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
