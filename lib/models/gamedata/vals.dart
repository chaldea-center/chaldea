// ignore_for_file: non_constant_identifier_names

part of 'skill.dart';

class DataVals {
  Map<String, dynamic> sourceVals;
  DataVals? get DependFuncVals => sourceVals['DependFuncVals'] == null
      ? null
      : DataVals(sourceVals['DependFuncVals']);

  List<int>? _listInt(dynamic v) {
    return (v as List<dynamic>?)?.map((e) => e as int).toList();
  }

  /// probability, 1000 -> 100%
  int? get Rate => sourceVals['Rate'];

  /// 3 Turns/3ターン/3回合
  int? get Turn => sourceVals['Turn'];

  /// 3 Times/3回/3次
  int? get Count => sourceVals['Count'];
  int? get Value => sourceVals['Value'];
  int? get Value2 => sourceVals['Value2'];

  /// probability, 1000 -> 100%
  int? get UseRate => sourceVals['UseRate'];
  int? get Target => sourceVals['Target'];
  int? get Correction => sourceVals['Correction'];
  int? get ParamAdd => sourceVals['ParamAdd'];
  int? get ParamMax => sourceVals['ParamMax'];
  int? get HideMiss => sourceVals['HideMiss'];
  int? get OnField => sourceVals['OnField'];
  int? get HideNoEffect => sourceVals['HideNoEffect'];
  int? get Unaffected => sourceVals['Unaffected'];
  int? get ShowState => sourceVals['ShowState'];
  int? get AuraEffectId => sourceVals['AuraEffectId'];
  int? get ActSet => sourceVals['ActSet'];
  int? get ActSetWeight => sourceVals['ActSetWeight'];
  int? get ShowQuestNoEffect => sourceVals['ShowQuestNoEffect'];
  int? get CheckDead => sourceVals['CheckDead'];
  int? get RatioHPHigh => sourceVals['RatioHPHigh'];
  int? get RatioHPLow => sourceVals['RatioHPLow'];
  int? get SetPassiveFrame => sourceVals['SetPassiveFrame'];
  int? get ProcPassive => sourceVals['ProcPassive'];
  int? get ProcActive => sourceVals['ProcActive'];
  int? get HideParam => sourceVals['HideParam'];
  int? get SkillID => sourceVals['SkillID'];
  int? get SkillLV => sourceVals['SkillLV'];
  int? get ShowCardOnly => sourceVals['ShowCardOnly'];
  int? get EffectSummon => sourceVals['EffectSummon'];
  int? get RatioHPRangeHigh => sourceVals['RatioHPRangeHigh'];
  int? get RatioHPRangeLow => sourceVals['RatioHPRangeLow'];
  List<int>? get TargetList => _listInt(sourceVals['TargetList']);
  int? get OpponentOnly => sourceVals['OpponentOnly'];
  int? get StatusEffectId => sourceVals['StatusEffectId'];
  int? get EndBattle => sourceVals['EndBattle'];
  int? get LoseBattle => sourceVals['LoseBattle'];
  int? get AddIndividualty => sourceVals['AddIndividualty'];
  int? get AddLinkageTargetIndividualty =>
      sourceVals['AddLinkageTargetIndividualty'];
  int? get SameBuffLimitTargetIndividuality =>
      sourceVals['SameBuffLimitTargetIndividuality'];
  int? get SameBuffLimitNum => sourceVals['SameBuffLimitNum'];
  int? get CheckDuplicate => sourceVals['CheckDuplicate'];
  int? get OnFieldCount => sourceVals['OnFieldCount'];
  List<int>? get TargetRarityList => _listInt(sourceVals['TargetRarityList']);
  int? get DependFuncId => sourceVals['DependFuncId'];
  int? get InvalidHide => sourceVals['InvalidHide'];
  int? get OutEnemyNpcId => sourceVals['OutEnemyNpcId'];
  int? get InEnemyNpcId => sourceVals['InEnemyNpcId'];
  int? get OutEnemyPosition => sourceVals['OutEnemyPosition'];
  int? get IgnoreIndividuality => sourceVals['IgnoreIndividuality'];
  int? get StarHigher => sourceVals['StarHigher'];
  int? get ChangeTDCommandType => sourceVals['ChangeTDCommandType'];
  int? get ShiftNpcId => sourceVals['ShiftNpcId'];
  int? get DisplayLastFuncInvalidType =>
      sourceVals['DisplayLastFuncInvalidType'];
  List<int>? get AndCheckIndividualityList =>
      _listInt(sourceVals['AndCheckIndividualityList']);
  int? get WinBattleNotRelatedSurvivalStatus =>
      sourceVals['WinBattleNotRelatedSurvivalStatus'];
  int? get ForceSelfInstantDeath => sourceVals['ForceSelfInstantDeath'];
  int? get ChangeMaxBreakGauge => sourceVals['ChangeMaxBreakGauge'];
  int? get ParamAddMaxValue => sourceVals['ParamAddMaxValue'];
  int? get ParamAddMaxCount => sourceVals['ParamAddMaxCount'];
  int? get LossHpChangeDamage => sourceVals['LossHpChangeDamage'];
  int? get IncludePassiveIndividuality =>
      sourceVals['IncludePassiveIndividuality'];
  int? get MotionChange => sourceVals['MotionChange'];
  int? get PopLabelDelay => sourceVals['PopLabelDelay'];
  int? get NoTargetNoAct => sourceVals['NoTargetNoAct'];
  int? get CardIndex => sourceVals['CardIndex'];
  int? get CardIndividuality => sourceVals['CardIndividuality'];
  int? get WarBoardTakeOverBuff => sourceVals['WarBoardTakeOverBuff'];
  List<int>? get ParamAddSelfIndividuality =>
      _listInt(sourceVals['ParamAddSelfIndividuality']);
  List<int>? get ParamAddOpIndividuality =>
      _listInt(sourceVals['ParamAddOpIndividuality']);
  List<int>? get ParamAddFieldIndividuality =>
      _listInt(sourceVals['ParamAddFieldIndividuality']);
  int? get ParamAddValue => sourceVals['ParamAddValue'];
  int? get MultipleGainStar => sourceVals['MultipleGainStar'];
  int? get NoCheckIndividualityIfNotUnit =>
      sourceVals['NoCheckIndividualityIfNotUnit'];
  int? get ForcedEffectSpeedOne => sourceVals['ForcedEffectSpeedOne'];
  int? get SetLimitCount => sourceVals['SetLimitCount'];
  int? get CheckEnemyFieldSpace => sourceVals['CheckEnemyFieldSpace'];
  int? get TriggeredFuncPosition => sourceVals['TriggeredFuncPosition'];
  int? get DamageCount => sourceVals['DamageCount'];
  List<int>? get DamageRates => _listInt(sourceVals['DamageRates']);
  List<int>? get OnPositions => _listInt(sourceVals['OnPositions']);
  List<int>? get OffPositions => _listInt(sourceVals['OffPositions']);
  int? get TargetIndiv => sourceVals['TargetIndiv'];
  int? get IncludeIgnoreIndividuality =>
      sourceVals['IncludeIgnoreIndividuality'];
  int? get EvenIfWinDie => sourceVals['EvenIfWinDie'];
  int? get CallSvtEffectId => sourceVals['CallSvtEffectId'];
  int? get ForceAddState => sourceVals['ForceAddState'];
  int? get UnSubState => sourceVals['UnSubState'];
  int? get ForceSubState => sourceVals['ForceSubState'];
  int? get IgnoreIndivUnreleaseable => sourceVals['IgnoreIndivUnreleaseable'];
  int? get OnParty => sourceVals['OnParty'];
  int? get CounterId => sourceVals['CounterId'];
  int? get CounterLv => sourceVals['CounterLv'];
  int? get CounterOc => sourceVals['CounterOc'];
  int? get UseTreasureDevice => sourceVals['UseTreasureDevice'];
  int? get SkillReaction => sourceVals['SkillReaction'];
  int? get BehaveAsFamilyBuff => sourceVals['BehaveAsFamilyBuff'];
  int? get UnSubStateWhileLinkedToOthers =>
      sourceVals['UnSubStateWhileLinkedToOthers'];
  int? get AllowSubBgmPlaying => sourceVals['AllowSubBgmPlaying'];
  int? get NotAccompanyWhenLinkedTargetMoveState =>
      sourceVals['NotAccompanyWhenLinkedTargetMoveState'];
  int? get ApplySupportSvt => sourceVals['ApplySupportSvt'];
  int? get Individuality => sourceVals['Individuality'];
  int? get EventId => sourceVals['EventId'];
  int? get AddCount => sourceVals['AddCount'];
  int? get RateCount => sourceVals['RateCount'];
  int? get DropRateCount => sourceVals['DropRateCount'];

  DataVals([Map<String, dynamic>? sourceVals]) : sourceVals = sourceVals ?? {};

  factory DataVals.fromJson(Map<String, dynamic> json) =>
      DataVals(Map.from(json));

  Map<String, dynamic> toJson() {
    final entries = sourceVals.entries.where((e) => e.value != null).toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return Map.fromEntries(entries);
  }

  @override
  operator ==(Object? other) {
    if (other is! DataVals) {
      return false;
    }
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode {
    return toJson().toString().hashCode;
  }
}
