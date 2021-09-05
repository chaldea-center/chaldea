/// Atlas Academy nicely bundled data
part of datatypes;

@JsonSerializable()
class NiceSkill {
  int id;
  int num;
  String name;
  String ruby;
  String detail;
  String type;
  int strengthStatus;
  int priority;
  int condQuestId;
  int condQuestPhase;
  int conLv;
  int condLimitCount;
  String icon; // full url
  List<int> coolDown;
  List<NiceSkillFunction> functions;

  NiceSkill({
    required this.id,
    required this.num,
    required this.name,
    required this.ruby,
    required this.detail,
    required this.type,
    required this.strengthStatus,
    required this.priority,
    required this.condQuestId,
    required this.condQuestPhase,
    required this.conLv,
    required this.condLimitCount,
    required this.icon,
    required this.coolDown,
    required this.functions,
  });

  factory NiceSkill.fromJson(Map<String, dynamic> data) =>
      _$NiceSkillFromJson(data);

  Map<String, dynamic> toJson() => _$NiceSkillToJson(this);
}

@JsonSerializable()
class NiceNoblePhantasm {
  int id;
  int num;
  String card;
  String name;
  String ruby;
  String rank;
  String type;
  String detail;
  Map<String, List<int>> npGain;
  List<int> npDistribution;
  int strengthStatus;
  int priority;
  int condQuestId;
  int condQuestPhase;
  List<Map<String, dynamic>> individuality;
  List<NiceSkillFunction> functions;

  NiceNoblePhantasm({
    required this.id,
    required this.num,
    required this.card,
    required this.name,
    required this.ruby,
    required this.rank,
    required this.type,
    required this.detail,
    required this.npGain,
    required this.npDistribution,
    required this.strengthStatus,
    required this.priority,
    required this.condQuestId,
    required this.condQuestPhase,
    required this.individuality,
    required this.functions,
  });

  factory NiceNoblePhantasm.fromJson(Map<String, dynamic> data) =>
      _$NiceNoblePhantasmFromJson(data);

  Map<String, dynamic> toJson() => _$NiceNoblePhantasmToJson(this);
}

@JsonSerializable()
class NiceSkillFunction {
  int funcId;
  String funcType;
  String funcTargetType;
  String funcTargetTeam;
  String funcPopupText;
  List<NiceSkillBuff> buffs;

  NiceSkillFunction({
    required this.funcId,
    required this.funcType,
    required this.funcTargetType,
    required this.funcTargetTeam,
    required this.funcPopupText,
    required this.buffs,
  });

  factory NiceSkillFunction.fromJson(Map<String, dynamic> data) =>
      _$NiceSkillFunctionFromJson(data);

  Map<String, dynamic> toJson() => _$NiceSkillFunctionToJson(this);
}

@JsonSerializable()
class NiceSkillBuff {
  int id;
  String name;
  String detail;
  String type;
  int buffGroup;

  NiceSkillBuff({
    required this.id,
    required this.name,
    required this.detail,
    required this.type,
    required this.buffGroup,
  });

  factory NiceSkillBuff.fromJson(Map<String, dynamic> data) =>
      _$NiceSkillBuffFromJson(data);

  Map<String, dynamic> toJson() => _$NiceSkillBuffToJson(this);
}
