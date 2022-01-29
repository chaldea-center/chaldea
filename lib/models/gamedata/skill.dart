// ignore_for_file: non_constant_identifier_names

part of gamedata;

@JsonSerializable()
class Vals {
  int? Rate;
  int? Turn;
  int? Count;
  int? Value;
  int? Value2;
  int? UseRate;
  int? Target;
  int? Correction;
  int? ParamAdd;
  int? ParamMax;
  int? HideMiss;
  int? OnField;
  int? HideNoEffect;
  int? Unaffected;
  int? ShowState;
  int? AuraEffectId;
  int? ActSet;
  int? ActSetWeight;
  int? ShowQuestNoEffect;
  int? CheckDead;
  int? RatioHPHigh;
  int? RatioHPLow;
  int? SetPassiveFrame;
  int? ProcPassive;
  int? ProcActive;
  int? HideParam;
  int? SkillID;
  int? SkillLV;
  int? ShowCardOnly;
  int? EffectSummon;
  int? RatioHPRangeHigh;
  int? RatioHPRangeLow;
  List<int>? TargetList;
  int? OpponentOnly;
  int? StatusEffectId;
  int? EndBattle;
  int? LoseBattle;
  int? AddIndividualty;
  int? AddLinkageTargetIndividualty;
  int? SameBuffLimitTargetIndividuality;
  int? SameBuffLimitNum;
  int? CheckDuplicate;
  int? OnFieldCount;
  List<int>? TargetRarityList;
  int? DependFuncId;
  int? InvalidHide;
  int? OutEnemyNpcId;
  int? InEnemyNpcId;
  int? OutEnemyPosition;
  int? IgnoreIndividuality;
  int? StarHigher;
  int? ChangeTDCommandType;
  int? ShiftNpcId;
  int? DisplayLastFuncInvalidType;
  List<int>? AndCheckIndividualityList;
  int? WinBattleNotRelatedSurvivalStatus;
  int? ForceSelfInstantDeath;
  int? ChangeMaxBreakGauge;
  int? ParamAddMaxValue;
  int? ParamAddMaxCount;
  int? LossHpChangeDamage;
  int? IncludePassiveIndividuality;
  int? MotionChange;
  int? PopLabelDelay;
  int? NoTargetNoAct;
  int? CardIndex;
  int? CardIndividuality;
  int? WarBoardTakeOverBuff;
  List<int>? ParamAddSelfIndividuality;
  List<int>? ParamAddOpIndividuality;
  List<int>? ParamAddFieldIndividuality;
  int? ParamAddValue;
  int? MultipleGainStar;
  int? NoCheckIndividualityIfNotUnit;
  int? ForcedEffectSpeedOne;
  int? SetLimitCount;
  int? CheckEnemyFieldSpace;
  int? TriggeredFuncPosition;
  int? DamageCount;
  List<int>? DamageRates;
  List<int>? OnPositions;
  List<int>? OffPositions;
  int? TargetIndiv;
  int? IncludeIgnoreIndividuality;
  int? EvenIfWinDie;
  int? CallSvtEffectId;
  int? ForceAddState;
  int? UnSubState;
  int? ForceSubState;
  int? IgnoreIndivUnreleaseable;
  int? OnParty;
  int? ApplySupportSvt;
  int? Individuality;
  int? EventId;
  int? AddCount;
  int? RateCount;
  int? DropRateCount;
  Vals? DependFuncVals;

  Vals({
    this.Rate,
    this.Turn,
    this.Count,
    this.Value,
    this.Value2,
    this.UseRate,
    this.Target,
    this.Correction,
    this.ParamAdd,
    this.ParamMax,
    this.HideMiss,
    this.OnField,
    this.HideNoEffect,
    this.Unaffected,
    this.ShowState,
    this.AuraEffectId,
    this.ActSet,
    this.ActSetWeight,
    this.ShowQuestNoEffect,
    this.CheckDead,
    this.RatioHPHigh,
    this.RatioHPLow,
    this.SetPassiveFrame,
    this.ProcPassive,
    this.ProcActive,
    this.HideParam,
    this.SkillID,
    this.SkillLV,
    this.ShowCardOnly,
    this.EffectSummon,
    this.RatioHPRangeHigh,
    this.RatioHPRangeLow,
    this.TargetList,
    this.OpponentOnly,
    this.StatusEffectId,
    this.EndBattle,
    this.LoseBattle,
    this.AddIndividualty,
    this.AddLinkageTargetIndividualty,
    this.SameBuffLimitTargetIndividuality,
    this.SameBuffLimitNum,
    this.CheckDuplicate,
    this.OnFieldCount,
    this.TargetRarityList,
    this.DependFuncId,
    this.InvalidHide,
    this.OutEnemyNpcId,
    this.InEnemyNpcId,
    this.OutEnemyPosition,
    this.IgnoreIndividuality,
    this.StarHigher,
    this.ChangeTDCommandType,
    this.ShiftNpcId,
    this.DisplayLastFuncInvalidType,
    this.AndCheckIndividualityList,
    this.WinBattleNotRelatedSurvivalStatus,
    this.ForceSelfInstantDeath,
    this.ChangeMaxBreakGauge,
    this.ParamAddMaxValue,
    this.ParamAddMaxCount,
    this.LossHpChangeDamage,
    this.IncludePassiveIndividuality,
    this.MotionChange,
    this.PopLabelDelay,
    this.NoTargetNoAct,
    this.CardIndex,
    this.CardIndividuality,
    this.WarBoardTakeOverBuff,
    this.ParamAddSelfIndividuality,
    this.ParamAddOpIndividuality,
    this.ParamAddFieldIndividuality,
    this.ParamAddValue,
    this.MultipleGainStar,
    this.NoCheckIndividualityIfNotUnit,
    this.ForcedEffectSpeedOne,
    this.SetLimitCount,
    this.CheckEnemyFieldSpace,
    this.TriggeredFuncPosition,
    this.DamageCount,
    this.DamageRates,
    this.OnPositions,
    this.OffPositions,
    this.TargetIndiv,
    this.IncludeIgnoreIndividuality,
    this.EvenIfWinDie,
    this.CallSvtEffectId,
    this.ForceAddState,
    this.UnSubState,
    this.ForceSubState,
    this.IgnoreIndivUnreleaseable,
    this.OnParty,
    this.ApplySupportSvt,
    this.Individuality,
    this.EventId,
    this.AddCount,
    this.RateCount,
    this.DropRateCount,
    this.DependFuncVals,
  });

  factory Vals.fromJson(Map<String, dynamic> json) => _$ValsFromJson(json);
}

@JsonSerializable()
class CommonRelease {
  int id;
  int priority;
  int condGroup;
  CondType condType;
  int condId;
  int condNum;

  CommonRelease({
    required this.id,
    required this.priority,
    required this.condGroup,
    required this.condType,
    required this.condId,
    required this.condNum,
  });

  factory CommonRelease.fromJson(Map<String, dynamic> json) =>
      _$CommonReleaseFromJson(json);
}

@JsonSerializable()
class Buff {
  int id;
  String name;
  String detail;
  String? icon;
  BuffType type;
  int buffGroup;
  dynamic script;
  List<NiceTrait> vals;
  List<NiceTrait> tvals;
  List<NiceTrait> ckSelfIndv;
  List<NiceTrait> ckOpIndv;
  int maxRate;

  Buff({
    required this.id,
    required this.name,
    required this.detail,
    this.icon,
    required this.type,
    required this.buffGroup,
    required this.script,
    required this.vals,
    required this.tvals,
    required this.ckSelfIndv,
    required this.ckOpIndv,
    required this.maxRate,
  });

  factory Buff.fromJson(Map<String, dynamic> json) => _$BuffFromJson(json);
}

@JsonSerializable()
class FuncGroup {
  int eventId;
  int baseFuncId;
  String nameTotal;
  String name;
  String? icon;
  int priority;
  bool isDispValue;

  FuncGroup({
    required this.eventId,
    required this.baseFuncId,
    required this.nameTotal,
    required this.name,
    this.icon,
    required this.priority,
    required this.isDispValue,
  });

  factory FuncGroup.fromJson(Map<String, dynamic> json) =>
      _$FuncGroupFromJson(json);
}

abstract class BaseFunction {
  int get funcId;

  FuncType get funcType;

  FuncTargetType get funcTargetType;

  FuncApplyTarget get funcTargetTeam;

  String get funcPopupText;

  String? get funcPopupIcon;

  List<NiceTrait> get functvals;

  List<NiceTrait> get funcquestTvals;

  List<FuncGroup> get funcGroup;

  List<NiceTrait> get traitVals;

  List<Buff> get buffs;
}

@JsonSerializable()
class NiceFunction extends BaseFunction {
  @override
  int funcId;
  @override
  FuncType funcType;
  @override
  FuncTargetType funcTargetType;
  @override
  FuncApplyTarget funcTargetTeam;
  @override
  String funcPopupText;
  @override
  String? funcPopupIcon;
  @override
  List<NiceTrait> functvals;
  @override
  List<NiceTrait> funcquestTvals;
  @override
  List<FuncGroup> funcGroup;
  @override
  List<NiceTrait> traitVals;
  @override
  List<Buff> buffs;
  List<Vals>? svals2;
  List<Vals>? svals3;
  List<Vals>? svals4;
  List<Vals>? svals5;
  List<Vals>? followerVals;

  NiceFunction({
    required this.funcId,
    required this.funcType,
    required this.funcTargetType,
    required this.funcTargetTeam,
    required this.funcPopupText,
    this.funcPopupIcon,
    required this.functvals,
    required this.funcquestTvals,
    required this.funcGroup,
    required this.traitVals,
    required this.buffs,
    this.svals2,
    this.svals3,
    this.svals4,
    this.svals5,
    this.followerVals,
  });

  factory NiceFunction.fromJson(Map<String, dynamic> json) =>
      _$NiceFunctionFromJson(json);
}

@JsonSerializable()
class ExtraPassive {
  int num;
  int priority;
  int condQuestId;
  int condQuestPhase;
  int condLv;
  int condLimitCount;
  int condFriendshipRank;
  int eventId;
  int flag;
  int startedAt;
  int endedAt;

  ExtraPassive({
    required this.num,
    required this.priority,
    required this.condQuestId,
    required this.condQuestPhase,
    required this.condLv,
    required this.condLimitCount,
    required this.condFriendshipRank,
    required this.eventId,
    required this.flag,
    required this.startedAt,
    required this.endedAt,
  });

  factory ExtraPassive.fromJson(Map<String, dynamic> json) =>
      _$ExtraPassiveFromJson(json);
}

@JsonSerializable()
class SkillScript {
  List<int>? NP_HIGHER;
  List<int>? NP_LOWER;
  List<int>? STAR_HIGHER;
  List<int>? STAR_LOWER;
  List<int>? HP_VAL_HIGHER;
  List<int>? HP_VAL_LOWER;
  List<int>? HP_PER_HIGHER;
  List<int>? HP_PER_LOWER;
  List<int>? additionalSkillId;
  List<int>? additionalSkillActorType;

  SkillScript({
    this.NP_HIGHER,
    this.NP_LOWER,
    this.STAR_HIGHER,
    this.STAR_LOWER,
    this.HP_VAL_HIGHER,
    this.HP_VAL_LOWER,
    this.HP_PER_HIGHER,
    this.HP_PER_LOWER,
    this.additionalSkillId,
    this.additionalSkillActorType,
  });

  factory SkillScript.fromJson(Map<String, dynamic> json) =>
      _$SkillScriptFromJson(json);
}

@JsonSerializable()
class SkillAdd {
  int priority;
  List<CommonRelease> releaseConditions;
  String name;
  String ruby;

  SkillAdd({
    required this.priority,
    required this.releaseConditions,
    required this.name,
    required this.ruby,
  });

  factory SkillAdd.fromJson(Map<String, dynamic> json) =>
      _$SkillAddFromJson(json);
}

@JsonSerializable()
class NiceSkill {
  int id;
  int num = -1;
  String name;
  String ruby;
  String? detail;
  String? unmodifiedDetail;
  SkillType type;
  int strengthStatus = -1;
  int priority = -1;
  int condQuestId = -1;
  int condQuestPhase = -1;
  int condLv = -1;
  int condLimitCount = -1;
  String? icon;
  List<int> coolDown;
  List<NiceTrait> actIndividuality;
  SkillScript script;
  List<ExtraPassive> extraPassive;
  List<SkillAdd> skillAdd;

  // Map<AiType, List<int>> aiIds;
  List<NiceFunction> functions;

  NiceSkill({
    required this.id,
    this.num = -1,
    required this.name,
    required this.ruby,
    this.detail,
    this.unmodifiedDetail,
    required this.type,
    this.strengthStatus = -1,
    this.priority = -1,
    this.condQuestId = -1,
    this.condQuestPhase = -1,
    this.condLv = -1,
    this.condLimitCount = -1,
    this.icon,
    required this.coolDown,
    required this.actIndividuality,
    required this.script,
    required this.extraPassive,
    required this.skillAdd,
    required this.functions,
  });

  factory NiceSkill.fromJson(Map<String, dynamic> json) =>
      _$NiceSkillFromJson(json);
}

@JsonSerializable()
class NpGain {
  List<int> buster;
  List<int> arts;
  List<int> quick;
  List<int> extra;
  List<int> defence;
  List<int> np;

  NpGain({
    required this.buster,
    required this.arts,
    required this.quick,
    required this.extra,
    required this.defence,
    required this.np,
  });

  factory NpGain.fromJson(Map<String, dynamic> json) => _$NpGainFromJson(json);
}

@JsonSerializable()
class NiceTd {
  int id;
  int num;
  CardType card;
  String name;
  String ruby;
  String? icon;
  String rank;
  String type;
  String? detail;
  String? unmodifiedDetail;
  NpGain npGain;
  List<int> npDistribution;
  int strengthStatus;
  int priority;
  int condQuestId;
  int condQuestPhase;
  List<NiceTrait> individuality;
  SkillScript script;
  List<NiceFunction> functions;

  NiceTd({
    required this.id,
    required this.num,
    required this.card,
    required this.name,
    required this.ruby,
    this.icon,
    required this.rank,
    required this.type,
    this.detail,
    this.unmodifiedDetail,
    required this.npGain,
    required this.npDistribution,
    required this.strengthStatus,
    required this.priority,
    required this.condQuestId,
    required this.condQuestPhase,
    required this.individuality,
    required this.script,
    required this.functions,
  });

  factory NiceTd.fromJson(Map<String, dynamic> json) => _$NiceTdFromJson(json);
}
