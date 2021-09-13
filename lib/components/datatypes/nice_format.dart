/// Atlas Academy nicely bundled data
part of datatypes;

class NiceUtil {
  static List<ActiveSkill> niceToActive(List<NiceSkill> niceSkills) {
    List<ActiveSkill> activeSkills =
        List.generate(3, (index) => ActiveSkill(cnState: 0, skills: []));
    for (final niceSkill in niceSkills) {
      activeSkills[niceSkill.num - 1].skills.add(niceToSkill(niceSkill));
    }

    return activeSkills;
  }

  static List<Skill> niceToPassive(List<NiceSkill> niceSkills) {
    List<Skill> passiveSkills = [];
    for (final niceSkill in niceSkills) {
      passiveSkills.add(niceToSkill(niceSkill));
    }
    return passiveSkills;
  }

  static Skill niceToSkill(NiceSkill niceSkill) {
    return Skill(
      state: niceSkill.name,
      openCondition: null,
      name: niceSkill.name,
      nameJp: null,
      nameEn: null,
      rank: null,
      icon: niceSkill.icon,
      cd: niceSkill.coolDown.first,
      effects: niceToEffects(niceSkill),
    );
  }

  static List<Effect> niceToEffects(NiceSkill skill) {
    // todo: parse nice
    List<Effect> effects = [];
    effects.add(Effect(
      description: skill.detail,
      descriptionJp: null,
      descriptionEn: null,
      lvData: [],
    ));
    for (final NiceFunction function in skill.functions) {
      if (function.funcTargetTeam == 'enemy') continue;
      List<String> lvData = [];
      for (final val in function.svals) {
        lvData.add(function.displayValue(val) ?? '');
      }
      if (lvData.toSet().length == 1) {
        lvData = [lvData.first];
      }
      effects.add(Effect(
        description: function.funcPopupText,
        descriptionJp: null,
        descriptionEn: null,
        lvData: lvData,
      ));
    }
    return effects;
  }
}

abstract class WithNiceFunctionsMixin {
  List<NiceFunction> get functions;

  static bool testFunctionsStatic(
      List<NiceFunction> functions, FilterGroupData groupData) {
    groupData.options.removeWhere((key, value) => value == false);
    if (groupData.options.isEmpty) return true;
    final matches = groupData.options.keys.map((key) {
      EffectType? effectType = EffectType.validEffectsMap[key];
      return effectType?.test(functions) ?? false;
    }).toList();
    bool result = groupData.matchAll
        ? matches.every((e) => e == true)
        : matches.any((e) => e == true);
    return groupData.invert ? !result : result;
  }

  bool testFunctions(FilterGroupData groupData) =>
      testFunctionsStatic(functions, groupData);
}

@JsonSerializable()
class NiceSkill with WithNiceFunctionsMixin {
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
  @override
  List<NiceFunction> functions;

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
class NiceNoblePhantasm with WithNiceFunctionsMixin {
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
  @override
  List<NiceFunction> functions;

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
class NiceFunction {
  int funcId;
  String funcType;
  String funcTargetType;
  String funcTargetTeam;
  String funcPopupText;
  List<NiceBuff> buffs;
  List<NiceEffectVal> svals;

  NiceFunction({
    required this.funcId,
    required this.funcType,
    required this.funcTargetType,
    required this.funcTargetTeam,
    required this.funcPopupText,
    required this.buffs,
    required this.svals,
  });

  String? displayValue(NiceEffectVal val) {
    if (val.value == null) return null;
    if (val.rate == null) return val.value.toString();
    num value = val.value!;
    if (funcType == 'gainNp') {
      return formatNumber(value / 10000, percent: true);
    }
    if (funcType == 'gainStar') {
      return value.toString();
    }
    return formatNumber(value / 1000, percent: true);
  }

  factory NiceFunction.fromJson(Map<String, dynamic> data) =>
      _$NiceFunctionFromJson(data);

  Map<String, dynamic> toJson() => _$NiceFunctionToJson(this);
}

@JsonSerializable()
class NiceBuff {
  int id;
  String name;
  String detail;
  String type;
  int buffGroup;

  NiceBuff({
    required this.id,
    required this.name,
    required this.detail,
    required this.type,
    required this.buffGroup,
  });

  factory NiceBuff.fromJson(Map<String, dynamic> data) =>
      _$NiceBuffFromJson(data);

  Map<String, dynamic> toJson() => _$NiceBuffToJson(this);
}

@JsonSerializable()
class NiceEffectVal {
  @JsonKey(name: 'Rate')
  int? rate;
  @JsonKey(name: 'Turn')
  int? turn;
  @JsonKey(name: 'Count')
  int? count;
  @JsonKey(name: 'Value')
  int? value;

  NiceEffectVal({
    this.rate,
    this.turn,
    this.count,
    this.value,
  });

  factory NiceEffectVal.fromJson(Map<String, dynamic> data) =>
      _$NiceEffectValFromJson(data);

  Map<String, dynamic> toJson() => _$NiceEffectValToJson(this);
}
