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

  @JsonKey(defaultValue: [1, 1, 1])
  List<int> curSkillLv;

  @JsonKey(defaultValue: [1, 1, 1])
  List<int> targetSkillLv;

  @JsonKey(defaultValue: [true, true, true])
  List<bool> skillEnhanced;

  @JsonKey(defaultValue: 0)
  int curAscensionLv;

  @JsonKey(defaultValue: 0)
  int targetAscensionLv;

  @JsonKey(defaultValue: 0)
  int curGrail;

  @JsonKey(defaultValue: 0)
  int targetGrail;

  @JsonKey(defaultValue: 1)
  int npLv;

  @JsonKey(defaultValue: false)
  bool npEnhanced;

  @JsonKey(defaultValue: false)
  bool favorite;

  factory ServantPlan.fromJson(Map<String, dynamic> data) =>
      _$ServantPlanFromJson(data);

  Map<String, dynamic> toJson() => _$ServantPlanToJson(this);

  ServantPlan(
      {this.curSkillLv,
      this.targetSkillLv,
      this.skillEnhanced,
      this.curAscensionLv = 0,
      this.targetAscensionLv = 0,
      this.curGrail = 0,
      this.targetGrail = 0,
      this.npLv = 1,
      this.npEnhanced = false,
      this.favorite = false}) {
    curSkillLv = curSkillLv ?? [1, 1, 1];
    targetSkillLv = targetSkillLv ?? [1, 1, 1];
    skillEnhanced = skillEnhanced ?? [false, false, false];
  }
}
