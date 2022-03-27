// ignore_for_file: non_constant_identifier_names
import 'dart:ui';

import 'package:chaldea/utils/basic.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../app/tools/gamedata_loader.dart';
import 'common.dart';
import 'wiki_data.dart';

part '../../generated/models/gamedata/skill.g.dart';

abstract class SkillOrTd {
  String? get unmodifiedDetail;
  List<NiceFunction> get functions;
  String? get lDetail;
}

@JsonSerializable()
class BaseSkill implements SkillOrTd {
  int id;
  String name;
  String ruby;
  @override
  String? unmodifiedDetail; // String? detail;
  SkillType type;
  String? icon;
  List<int> coolDown;
  List<NiceTrait> actIndividuality;
  SkillScript script;
  List<ExtraPassive> extraPassive;
  List<SkillAdd> skillAdd;
  Map<AiType, List<int>>? aiIds;
  @override
  List<NiceFunction> functions;

  BaseSkill({
    required this.id,
    required this.name,
    this.ruby = '',
    // this.detail,
    this.unmodifiedDetail,
    required this.type,
    this.icon,
    this.coolDown = const [],
    this.actIndividuality = const [],
    SkillScript? script,
    this.extraPassive = const [],
    this.skillAdd = const [],
    this.aiIds,
    required this.functions,
  }) : script = script ?? SkillScript();

  factory BaseSkill.fromJson(Map<String, dynamic> json) =>
      _$BaseSkillFromJson(json);

  Transl<String, String> get lName => Transl.skillNames(name);

  @override
  String? get lDetail {
    if (unmodifiedDetail == null) return null;
    return Transl.skillDetail(
            unmodifiedDetail!.replaceAll(RegExp(r'\[/?[og]\]'), ''))
        .l
        .replaceAll('{0}', 'Lv.');
  }
}

@JsonSerializable()
class NiceSkill extends BaseSkill {
  int num;
  int strengthStatus;
  int priority;
  int condQuestId;
  int condQuestPhase;
  int condLv;
  int condLimitCount;

  NiceSkill({
    required int id,
    required String name,
    String ruby = '',
    String? unmodifiedDetail,
    required SkillType type,
    String? icon,
    List<int> coolDown = const [],
    List<NiceTrait> actIndividuality = const [],
    SkillScript? script,
    List<ExtraPassive> extraPassive = const [],
    List<SkillAdd> skillAdd = const [],
    Map<AiType, List<int>>? aiIds,
    List<NiceFunction> functions = const [],
    this.num = 0,
    this.strengthStatus = 0,
    this.priority = 0,
    this.condQuestId = 0,
    this.condQuestPhase = 0,
    this.condLv = 0,
    this.condLimitCount = 0,
  }) : super(
          id: id,
          name: name,
          ruby: ruby,
          unmodifiedDetail: unmodifiedDetail,
          type: type,
          icon: icon,
          coolDown: coolDown,
          actIndividuality: actIndividuality,
          script: script ?? SkillScript(),
          extraPassive: extraPassive,
          skillAdd: skillAdd,
          aiIds: aiIds,
          functions: functions,
        );

  factory NiceSkill.fromJson(Map<String, dynamic> json) {
    if (json['type'] == null) {
      final baseSkill = GameDataLoader
          .instance!.gameJson!['baseSkills']![json['id'].toString()]!;
      json.addAll(Map.from(baseSkill));
    }
    return _$NiceSkillFromJson(json);
  }
}

@JsonSerializable()
class NiceTd implements SkillOrTd {
  int id;
  int num;
  CardType card;
  String name;
  String ruby;
  String? icon;
  String rank;
  String type;

  // String? detail;
  @override
  String? unmodifiedDetail;
  NpGain npGain;
  List<int> npDistribution;
  int strengthStatus;
  int priority;
  int condQuestId;
  int condQuestPhase;
  List<NiceTrait> individuality;
  SkillScript script;
  @override
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
    // this.detail,
    this.unmodifiedDetail,
    required this.npGain,
    required this.npDistribution,
    this.strengthStatus = 0,
    required this.priority,
    this.condQuestId = 0,
    this.condQuestPhase = 0,
    required this.individuality,
    required this.script,
    required this.functions,
  });

  factory NiceTd.fromJson(Map<String, dynamic> json) => _$NiceTdFromJson(json);

  NpDamageType? _damageType;

  NpDamageType get damageType {
    if (_damageType != null) return _damageType!;
    for (var func in functions) {
      if (func.funcTargetTeam == FuncApplyTarget.enemy) continue;
      if (EnumUtil.shortString(func.funcType).startsWith('damageNp')) {
        if (func.funcTargetType == FuncTargetType.enemyAll) {
          _damageType = NpDamageType.aoe;
        } else if (func.funcTargetType == FuncTargetType.enemy) {
          _damageType = NpDamageType.indiv;
        } else {
          throw 'Unknown damageType: ${func.funcTargetType}';
        }
      }
    }
    return _damageType ??= NpDamageType.none;
  }

  @override
  String? get lDetail {
    if (unmodifiedDetail == null) return null;
    return Transl.tdDetail(
            unmodifiedDetail!.replaceAll(RegExp(r'\[/?[og]\]'), ''))
        .l
        .replaceAll('{0}', 'Lv.');
  }
}

enum NpDamageType { none, indiv, aoe }

@JsonSerializable()
class NiceFunction implements BaseFunction {
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
  List<DataVals> svals;
  List<DataVals>? svals2;
  List<DataVals>? svals3;
  List<DataVals>? svals4;
  List<DataVals>? svals5;
  List<DataVals>? followerVals;

  NiceFunction({
    required this.funcId,
    this.funcType = FuncType.none,
    required this.funcTargetType,
    required this.funcTargetTeam,
    this.funcPopupText = '',
    this.funcPopupIcon,
    this.functvals = const [],
    this.funcquestTvals = const [],
    this.funcGroup = const [],
    this.traitVals = const [],
    this.buffs = const [],
    required this.svals,
    this.svals2,
    this.svals3,
    this.svals4,
    this.svals5,
    this.followerVals,
  });

  List<DataVals> ocVals(int lv) {
    assert(lv >= 0 && lv < svals.length, lv);
    return [
      for (final sv in [svals, svals2, svals3, svals4, svals5])
        if (sv != null) sv[lv]
    ];
  }

  factory NiceFunction.fromJson(Map<String, dynamic> json) {
    if (json['funcType'] == null) {
      final baseFunction = GameDataLoader
          .instance!.gameJson!['baseFunctions']![json['funcId'].toString()]!;
      json.addAll(Map.from(baseFunction));
    }

    return _$NiceFunctionFromJson(json);
  }
}

@JsonSerializable()
class Buff {
  int id;
  String name;
  String detail;
  String? icon;
  BuffType type;
  int buffGroup;
  BuffScript script;
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
    this.type = BuffType.none,
    this.buffGroup = 0,
    BuffScript? script,
    this.vals = const [],
    this.tvals = const [],
    this.ckSelfIndv = const [],
    this.ckOpIndv = const [],
    required this.maxRate,
  }) : script = script ?? BuffScript();

  factory Buff.fromJson(Map<String, dynamic> json) => _$BuffFromJson(json);
}

@JsonSerializable(
    createToJson: true, includeIfNull: false, explicitToJson: true)
class DataVals {
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
  int? CounterId;
  int? CounterLv;
  int? CounterOc;
  int? UseTreasureDevice;
  int? SkillReaction;
  int? BehaveAsFamilyBuff;
  int? UnSubStateWhileLinkedToOthers;
  int? NotAccompanyWhenLinkedTargetMoveState;

  int? ApplySupportSvt;

  int? Individuality;
  int? EventId;
  int? AddCount;
  int? RateCount;
  int? DropRateCount;
  DataVals? DependFuncVals;

  DataVals({
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
    this.CounterId,
    this.CounterLv,
    this.CounterOc,
    this.UseTreasureDevice,
    this.SkillReaction,
    this.ApplySupportSvt,
    this.BehaveAsFamilyBuff,
    this.UnSubStateWhileLinkedToOthers,
    this.NotAccompanyWhenLinkedTargetMoveState,
    this.Individuality,
    this.EventId,
    this.AddCount,
    this.RateCount,
    this.DropRateCount,
    this.DependFuncVals,
  });

  factory DataVals.fromJson(Map<String, dynamic> json) =>
      _$DataValsFromJson(json);

  Map<String, dynamic> toJson() => _$DataValsToJson(this);

  @override
  operator ==(Object? other) {
    if (other is! DataVals) {
      return false;
    }
    return Rate == other.Rate &&
        Turn == other.Turn &&
        Count == other.Count &&
        Value == other.Value &&
        Value2 == other.Value2 &&
        UseRate == other.UseRate &&
        Target == other.Target &&
        Correction == other.Correction &&
        ParamAdd == other.ParamAdd &&
        ParamMax == other.ParamMax &&
        HideMiss == other.HideMiss &&
        OnField == other.OnField &&
        HideNoEffect == other.HideNoEffect &&
        Unaffected == other.Unaffected &&
        ShowState == other.ShowState &&
        AuraEffectId == other.AuraEffectId &&
        ActSet == other.ActSet &&
        ActSetWeight == other.ActSetWeight &&
        ShowQuestNoEffect == other.ShowQuestNoEffect &&
        CheckDead == other.CheckDead &&
        RatioHPHigh == other.RatioHPHigh &&
        RatioHPLow == other.RatioHPLow &&
        SetPassiveFrame == other.SetPassiveFrame &&
        ProcPassive == other.ProcPassive &&
        ProcActive == other.ProcActive &&
        HideParam == other.HideParam &&
        SkillID == other.SkillID &&
        SkillLV == other.SkillLV &&
        ShowCardOnly == other.ShowCardOnly &&
        EffectSummon == other.EffectSummon &&
        RatioHPRangeHigh == other.RatioHPRangeHigh &&
        RatioHPRangeLow == other.RatioHPRangeLow &&
        TargetList == other.TargetList &&
        OpponentOnly == other.OpponentOnly &&
        StatusEffectId == other.StatusEffectId &&
        EndBattle == other.EndBattle &&
        LoseBattle == other.LoseBattle &&
        AddIndividualty == other.AddIndividualty &&
        AddLinkageTargetIndividualty == other.AddLinkageTargetIndividualty &&
        SameBuffLimitTargetIndividuality ==
            other.SameBuffLimitTargetIndividuality &&
        SameBuffLimitNum == other.SameBuffLimitNum &&
        CheckDuplicate == other.CheckDuplicate &&
        OnFieldCount == other.OnFieldCount &&
        TargetRarityList == other.TargetRarityList &&
        DependFuncId == other.DependFuncId &&
        InvalidHide == other.InvalidHide &&
        OutEnemyNpcId == other.OutEnemyNpcId &&
        InEnemyNpcId == other.InEnemyNpcId &&
        OutEnemyPosition == other.OutEnemyPosition &&
        IgnoreIndividuality == other.IgnoreIndividuality &&
        StarHigher == other.StarHigher &&
        ChangeTDCommandType == other.ChangeTDCommandType &&
        ShiftNpcId == other.ShiftNpcId &&
        DisplayLastFuncInvalidType == other.DisplayLastFuncInvalidType &&
        AndCheckIndividualityList == other.AndCheckIndividualityList &&
        WinBattleNotRelatedSurvivalStatus ==
            other.WinBattleNotRelatedSurvivalStatus &&
        ForceSelfInstantDeath == other.ForceSelfInstantDeath &&
        ChangeMaxBreakGauge == other.ChangeMaxBreakGauge &&
        ParamAddMaxValue == other.ParamAddMaxValue &&
        ParamAddMaxCount == other.ParamAddMaxCount &&
        LossHpChangeDamage == other.LossHpChangeDamage &&
        IncludePassiveIndividuality == other.IncludePassiveIndividuality &&
        MotionChange == other.MotionChange &&
        PopLabelDelay == other.PopLabelDelay &&
        NoTargetNoAct == other.NoTargetNoAct &&
        CardIndex == other.CardIndex &&
        CardIndividuality == other.CardIndividuality &&
        WarBoardTakeOverBuff == other.WarBoardTakeOverBuff &&
        ParamAddSelfIndividuality == other.ParamAddSelfIndividuality &&
        ParamAddOpIndividuality == other.ParamAddOpIndividuality &&
        ParamAddFieldIndividuality == other.ParamAddFieldIndividuality &&
        ParamAddValue == other.ParamAddValue &&
        MultipleGainStar == other.MultipleGainStar &&
        NoCheckIndividualityIfNotUnit == other.NoCheckIndividualityIfNotUnit &&
        ForcedEffectSpeedOne == other.ForcedEffectSpeedOne &&
        SetLimitCount == other.SetLimitCount &&
        CheckEnemyFieldSpace == other.CheckEnemyFieldSpace &&
        TriggeredFuncPosition == other.TriggeredFuncPosition &&
        DamageCount == other.DamageCount &&
        DamageRates == other.DamageRates &&
        OnPositions == other.OnPositions &&
        OffPositions == other.OffPositions &&
        TargetIndiv == other.TargetIndiv &&
        IncludeIgnoreIndividuality == other.IncludeIgnoreIndividuality &&
        EvenIfWinDie == other.EvenIfWinDie &&
        CallSvtEffectId == other.CallSvtEffectId &&
        ForceAddState == other.ForceAddState &&
        UnSubState == other.UnSubState &&
        ForceSubState == other.ForceSubState &&
        IgnoreIndivUnreleaseable == other.IgnoreIndivUnreleaseable &&
        OnParty == other.OnParty &&
        CounterId == other.CounterId &&
        CounterLv == other.CounterLv &&
        CounterOc == other.CounterOc &&
        UseTreasureDevice == other.UseTreasureDevice &&
        SkillReaction == other.SkillReaction &&
        ApplySupportSvt == other.ApplySupportSvt &&
        BehaveAsFamilyBuff == other.BehaveAsFamilyBuff &&
        UnSubStateWhileLinkedToOthers == other.UnSubStateWhileLinkedToOthers &&
        NotAccompanyWhenLinkedTargetMoveState ==
            other.NotAccompanyWhenLinkedTargetMoveState &&
        Individuality == other.Individuality &&
        EventId == other.EventId &&
        AddCount == other.AddCount &&
        RateCount == other.RateCount &&
        DropRateCount == other.DropRateCount &&
        DependFuncVals == other.DependFuncVals;
  }

  @override
  int get hashCode {
    // all elements must be non-iterable
    return hashList([
      '_DataVals_',
      Rate,
      Turn,
      Count,
      Value,
      Value2,
      UseRate,
      Target,
      Correction,
      ParamAdd,
      ParamMax,
      HideMiss,
      OnField,
      HideNoEffect,
      Unaffected,
      ShowState,
      AuraEffectId,
      ActSet,
      ActSetWeight,
      ShowQuestNoEffect,
      CheckDead,
      RatioHPHigh,
      RatioHPLow,
      SetPassiveFrame,
      ProcPassive,
      ProcActive,
      HideParam,
      SkillID,
      SkillLV,
      ShowCardOnly,
      EffectSummon,
      RatioHPRangeHigh,
      RatioHPRangeLow,
      hashList(TargetList),
      OpponentOnly,
      StatusEffectId,
      EndBattle,
      LoseBattle,
      AddIndividualty,
      AddLinkageTargetIndividualty,
      SameBuffLimitTargetIndividuality,
      SameBuffLimitNum,
      CheckDuplicate,
      OnFieldCount,
      hashList(TargetRarityList),
      DependFuncId,
      InvalidHide,
      OutEnemyNpcId,
      InEnemyNpcId,
      OutEnemyPosition,
      IgnoreIndividuality,
      StarHigher,
      ChangeTDCommandType,
      ShiftNpcId,
      DisplayLastFuncInvalidType,
      hashList(AndCheckIndividualityList),
      WinBattleNotRelatedSurvivalStatus,
      ForceSelfInstantDeath,
      ChangeMaxBreakGauge,
      ParamAddMaxValue,
      ParamAddMaxCount,
      LossHpChangeDamage,
      IncludePassiveIndividuality,
      MotionChange,
      PopLabelDelay,
      NoTargetNoAct,
      CardIndex,
      CardIndividuality,
      WarBoardTakeOverBuff,
      hashList(ParamAddSelfIndividuality),
      hashList(ParamAddOpIndividuality),
      hashList(ParamAddFieldIndividuality),
      ParamAddValue,
      MultipleGainStar,
      NoCheckIndividualityIfNotUnit,
      ForcedEffectSpeedOne,
      SetLimitCount,
      CheckEnemyFieldSpace,
      TriggeredFuncPosition,
      DamageCount,
      hashList(DamageRates),
      hashList(OnPositions),
      hashList(OffPositions),
      TargetIndiv,
      IncludeIgnoreIndividuality,
      EvenIfWinDie,
      CallSvtEffectId,
      ForceAddState,
      UnSubState,
      ForceSubState,
      IgnoreIndivUnreleaseable,
      OnParty,
      CounterId,
      CounterLv,
      CounterOc,
      UseTreasureDevice,
      SkillReaction,
      ApplySupportSvt,
      BehaveAsFamilyBuff,
      UnSubStateWhileLinkedToOthers,
      NotAccompanyWhenLinkedTargetMoveState,
      Individuality,
      EventId,
      AddCount,
      RateCount,
      DropRateCount,
      DependFuncVals,
    ]);
  }
}

@JsonSerializable()
class CommonRelease {
  int id;
  int priority;
  int condGroup;
  @JsonKey(fromJson: toEnumCondType)
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
class BuffScript {
  int? checkIndvType;
  List<BuffType>? CheckOpponentBuffTypes;
  BuffRelationOverwrite? relationId;
  String? ReleaseText;
  int? DamageRelease;
  NiceTrait? INDIVIDUALITIE;
  List<NiceTrait>? UpBuffRateBuffIndiv;
  int? HP_LOWER;

  BuffScript({
    this.checkIndvType,
    this.CheckOpponentBuffTypes,
    this.relationId,
    this.ReleaseText,
    this.DamageRelease,
    this.INDIVIDUALITIE,
    this.UpBuffRateBuffIndiv,
    this.HP_LOWER,
  });

  factory BuffScript.fromJson(Map<String, dynamic> json) =>
      _$BuffScriptFromJson(json);
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

@JsonSerializable()
class BaseFunction {
  int funcId;
  FuncType funcType;
  FuncTargetType funcTargetType;
  FuncApplyTarget funcTargetTeam;
  String funcPopupText;
  String? funcPopupIcon;
  List<NiceTrait> functvals;
  List<NiceTrait> funcquestTvals;
  List<FuncGroup> funcGroup;
  List<NiceTrait> traitVals;
  List<Buff> buffs;

  BaseFunction({
    required this.funcId,
    this.funcType = FuncType.none,
    required this.funcTargetType,
    required this.funcTargetTeam,
    this.funcPopupText = "",
    this.funcPopupIcon,
    this.functvals = const [],
    this.funcquestTvals = const [],
    this.funcGroup = const [],
    this.traitVals = const [],
    this.buffs = const [],
  });

  factory BaseFunction.fromJson(Map<String, dynamic> json) =>
      _$BaseFunctionFromJson(json);
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
    this.condQuestId = 0,
    this.condQuestPhase = 0,
    this.condLv = 0,
    this.condLimitCount = 0,
    this.condFriendshipRank = 0,
    this.eventId = 0,
    this.flag = 0,
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
class BuffRelationOverwrite {
  Map<SvtClass, Map<SvtClass, dynamic>> atkSide;
  Map<SvtClass, Map<SvtClass, dynamic>> defSide;

  BuffRelationOverwrite({
    required this.atkSide,
    required this.defSide,
  });

  factory BuffRelationOverwrite.fromJson(Map<String, dynamic> json) =>
      _$BuffRelationOverwriteFromJson(json);
}

@JsonSerializable()
class RelationOverwriteDetail {
  int damageRate;
  ClassRelationOverwriteType type;

  RelationOverwriteDetail({
    required this.damageRate,
    required this.type,
  });

  factory RelationOverwriteDetail.fromJson(Map<String, dynamic> json) =>
      _$RelationOverwriteDetailFromJson(json);
}

List<BuffType> toEnumListBuffType(List<dynamic> json) {
  return json.map((e) => $enumDecode(_$BuffTypeEnumMap, e)).toList();
}

enum BuffType {
  none,
  upCommandatk,
  upStarweight,
  upCriticalpoint,
  downCriticalpoint,
  regainNp,
  regainStar,
  regainHp,
  reduceHp,
  upAtk,
  downAtk,
  upDamage,
  downDamage,
  addDamage,
  subDamage,
  upNpdamage,
  downNpdamage,
  upDropnp,
  upCriticaldamage,
  downCriticaldamage,
  upSelfdamage,
  downSelfdamage,
  addSelfdamage,
  subSelfdamage,
  avoidance,
  breakAvoidance,
  invincible,
  upGrantstate,
  downGrantstate,
  upTolerance,
  downTolerance,
  avoidState,
  donotAct,
  donotSkill,
  donotNoble,
  donotRecovery,
  disableGender,
  guts,
  upHate,
  addIndividuality,
  subIndividuality,
  upDefence,
  downDefence,
  upCommandstar,
  upCommandnp,
  upCommandall,
  downCommandall,
  downStarweight,
  reduceNp,
  downDropnp,
  upGainHp,
  downGainHp,
  downCommandatk,
  downCommanstar,
  downCommandnp,
  upCriticalrate,
  downCriticalrate,
  pierceInvincible,
  avoidInstantdeath,
  upResistInstantdeath,
  upNonresistInstantdeath,
  delayFunction,
  regainNpUsedNoble,
  deadFunction,
  upMaxhp,
  downMaxhp,
  addMaxhp,
  subMaxhp,
  battlestartFunction,
  wavestartFunction,
  selfturnendFunction,
  damageFunction,
  upGivegainHp,
  downGivegainHp,
  commandattackFunction,
  deadattackFunction,
  upSpecialdefence,
  downSpecialdefence,
  upDamagedropnp,
  downDamagedropnp,
  entryFunction,
  upChagetd,
  reflectionFunction,
  upGrantSubstate,
  downGrantSubstate,
  upToleranceSubstate,
  downToleranceSubstate,
  upGrantInstantdeath,
  downGrantInstantdeath,
  gutsRatio,
  upDefencecommandall,
  downDefencecommandall,
  overwriteBattleclass,
  overwriteClassrelatioAtk,
  overwriteClassrelatioDef,
  upDamageIndividuality,
  downDamageIndividuality,
  upDamageIndividualityActiveonly,
  downDamageIndividualityActiveonly,
  upNpturnval,
  downNpturnval,
  multiattack,
  upGiveNp,
  downGiveNp,
  upResistanceDelayNpturn,
  downResistanceDelayNpturn,
  pierceDefence,
  upGutsHp,
  downGutsHp,
  upFuncgainNp,
  downFuncgainNp,
  upFuncHpReduce,
  downFuncHpReduce,
  upDefencecommanDamage,
  downDefencecommanDamage,
  npattackPrevBuff,
  fixCommandcard,
  donotGainnp,
  fieldIndividuality,
  donotActCommandtype,
  upDamageEventPoint,
  upDamageSpecial,
  attackFunction,
  commandcodeattackFunction,
  donotNobleCondMismatch,
  donotSelectCommandcard,
  donotReplace,
  shortenUserEquipSkill,
  tdTypeChange,
  overwriteClassRelation,
  tdTypeChangeArts,
  tdTypeChangeBuster,
  tdTypeChangeQuick,
  commandattackBeforeFunction,
  gutsFunction,
  upCriticalRateDamageTaken,
  downCriticalRateDamageTaken,
  upCriticalStarDamageTaken,
  downCriticalStarDamageTaken,
  skillRankUp,
  avoidanceIndividuality,
  changeCommandCardType,
  specialInvincible,
  preventDeathByDamage,
  commandcodeattackAfterFunction,
  attackBeforeFunction,
  donotSkillSelect,
  buffRate,
  invisibleBattleChara,
  counterFunction,
}

enum FuncType {
  none,
  addState,
  subState,
  damage,
  damageNp,
  gainStar,
  gainHp,
  gainNp,
  lossNp,
  shortenSkill,
  extendSkill,
  releaseState,
  lossHp,
  instantDeath,
  damageNpPierce,
  damageNpIndividual,
  addStateShort,
  gainHpPer,
  damageNpStateIndividual,
  hastenNpturn,
  delayNpturn,
  damageNpHpratioHigh,
  damageNpHpratioLow,
  cardReset,
  replaceMember,
  lossHpSafe,
  damageNpCounter,
  damageNpStateIndividualFix,
  damageNpSafe,
  callServant,
  ptShuffle,
  lossStar,
  changeServant,
  changeBg,
  damageValue,
  withdraw,
  fixCommandcard,
  shortenBuffturn,
  extendBuffturn,
  shortenBuffcount,
  extendBuffcount,
  changeBgm,
  displayBuffstring,
  resurrection,
  gainNpBuffIndividualSum,
  setSystemAliveFlag,
  forceInstantDeath,
  damageNpRare,
  gainNpFromTargets,
  gainHpFromTargets,
  lossHpPer,
  lossHpPerSafe,
  shortenUserEquipSkill,
  quickChangeBg,
  shiftServant,
  damageNpAndCheckIndividuality,
  absorbNpturn,
  overwriteDeadType,
  forceAllBuffNoact,
  breakGaugeUp,
  breakGaugeDown,
  moveToLastSubmember,
  expUp,
  qpUp,
  dropUp,
  friendPointUp,
  eventDropUp,
  eventDropRateUp,
  eventPointUp,
  eventPointRateUp,
  transformServant,
  qpDropUp,
  servantFriendshipUp,
  userEquipExpUp,
  classDropUp,
  enemyEncountCopyRateUp,
  enemyEncountRateUp,
  enemyProbDown,
  getRewardGift,
  sendSupportFriendPoint,
  movePosition,
  revival,
  damageNpIndividualSum,
  damageValueSafe,
  friendPointUpDuplicate,
  moveState,
  changeBgmCostume,
  func126,
  func127,
  updateEntryPositions,
  buddyPointUp,
}

enum FuncTargetType {
  self,
  ptOne,
  ptAnother,
  ptAll,
  enemy,
  enemyAnother,
  enemyAll,
  ptFull,
  enemyFull,
  ptOther,
  ptOneOther,
  ptRandom,
  enemyOther,
  enemyRandom,
  ptOtherFull,
  enemyOtherFull,
  ptselectOneSub,
  ptselectSub,
  ptOneAnotherRandom,
  ptSelfAnotherRandom,
  enemyOneAnotherRandom,
  ptSelfAnotherFirst,
  ptSelfBefore,
  ptSelfAfter,
  ptSelfAnotherLast,
  commandTypeSelfTreasureDevice,
  fieldOther,
  enemyOneNoTargetNoAction,
  ptOneHpLowestValue,
  ptOneHpLowestRate,
}

enum FuncApplyTarget {
  player,
  enemy,
  playerAndEnemy,
}

enum SkillType {
  active,
  passive,
}

enum ClassRelationOverwriteType {
  overwriteForce,
  overwriteMoreThanTarget,
  overwriteLessThanTarget,
}

enum AiType {
  svt,
  field,
}
