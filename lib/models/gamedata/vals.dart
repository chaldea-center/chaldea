// ignore_for_file: non_constant_identifier_names

part of 'skill.dart';

@JsonSerializable(
    createToJson: true, includeIfNull: false, explicitToJson: true)
class DataVals {
  /// probability, 1000 -> 100%
  int? Rate;

  /// 3 Turns/3ターン/3回合
  int? Turn;

  /// 3 Times/3回/3次
  int? Count;
  int? Value;
  int? Value2;

  /// probability, 1000 -> 100%
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
  int? AllowSubBgmPlaying;
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
    this.AllowSubBgmPlaying,
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
        AllowSubBgmPlaying == other.AllowSubBgmPlaying &&
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
      AllowSubBgmPlaying,
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
