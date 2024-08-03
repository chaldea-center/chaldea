// ignore_for_file: non_constant_identifier_names

import '_helper.dart';

@JsonSerializable(createFactory: false, createToJson: false)
class DataVals {
  Map<String, dynamic> _vals;
  DataVals? get DependFuncVals => _vals['DependFuncVals'] == null ? null : DataVals(_vals['DependFuncVals']);

  DataVals([Map<dynamic, dynamic>? sourceVals]) : _vals = Map.from(sourceVals ?? {});

  static dynamic _deepCopy(dynamic value) {
    if (value is List) {
      return value.map((e) => _deepCopy(e)).toList();
    } else if (value is Map) {
      return value.map((k, v) => MapEntry(k, _deepCopy(v)));
    } else {
      return value;
    }
  }

  factory DataVals.fromJson(Map<String, dynamic> json) => DataVals(_deepCopy(json));

  Map<String, dynamic> toJson({bool sort = true}) {
    final entries = Map<String, dynamic>.from(_deepCopy(_vals)).entries.toList();
    if (sort) {
      entries.sort((a, b) => a.key.compareTo(b.key));
    }
    return Map.fromEntries(entries);
  }

  @override
  bool operator ==(Object other) {
    return other is DataVals && hashCode == other.hashCode;
  }

  void set(String key, dynamic value) {
    if (value == null) {
      _vals.remove(key);
    } else {
      _vals[key] = value;
    }
  }

  @override
  int get hashCode {
    return toJson().toString().hashCode;
  }

  List<T>? _list<T>(String key) {
    return (_vals[key] as List<dynamic>?)?.cast();
  }

  /// probability, 1000 -> 100%
  int? get Rate => _vals['Rate'];

  /// 3 Turns/3ターン/3回合
  int? get Turn => _vals['Turn'];

  /// 3 Times/3回/3次
  int? get Count => _vals['Count'];
  int? get Value => _vals['Value'];
  int? get Value2 {
    final v = _vals['Value2'];
    if (v is int) return v;
    return null;
  }

  String? get Value2Str {
    final v = _vals['Value2'];
    if (v is String) return v;
    return null;
  }

  /// probability, 1000 -> 100%
  int? get UseRate => _vals['UseRate'];
  int? get Target => _vals['Target'];
  int? get Correction => _vals['Correction'];
  int? get ParamAdd => _vals['ParamAdd'];
  int? get ParamMax => _vals['ParamMax'];
  int? get HideMiss => _vals['HideMiss'];
  int? get OnField => _vals['OnField'];
  int? get HideNoEffect => _vals['HideNoEffect'];
  int? get Unaffected => _vals['Unaffected'];
  // SHOW_STATE = 1;
  // HIDE_STATE = -1;
  // SHOW_DEFF_STATE = -2;
  // SHOW_STATE_STATUS_BUFF_ONLY = 2;
  // SHOW_STATE_DAMAGE_AND_COMMANDCARD_BUFF = 3;
  int? get ShowState => _vals['ShowState'];
  int? get AuraEffectId => _vals['AuraEffectId'];
  int? get ActSet => _vals['ActSet'];
  int? get ActSetWeight => _vals['ActSetWeight'];
  int? get ShowQuestNoEffect => _vals['ShowQuestNoEffect'];
  int? get CheckDead => _vals['CheckDead'];
  int? get RatioHPHigh => _vals['RatioHPHigh'];
  int? get RatioHPLow => _vals['RatioHPLow'];
  int? get SetPassiveFrame => _vals['SetPassiveFrame'];
  int? get ProcPassive => _vals['ProcPassive'];
  int? get ProcActive => _vals['ProcActive'];
  int? get HideParam => _vals['HideParam'];
  int? get SkillID => _vals['SkillID'];
  int? get SkillLV => _vals['SkillLV'];
  int? get ShowCardOnly => _vals['ShowCardOnly'];
  int? get EffectSummon => _vals['EffectSummon'];
  int? get RatioHPRangeHigh => _vals['RatioHPRangeHigh'];
  int? get RatioHPRangeLow => _vals['RatioHPRangeLow'];
  List<int>? get TargetList => _list('TargetList');
  int? get OpponentOnly => _vals['OpponentOnly'];
  int? get StatusEffectId => _vals['StatusEffectId'];
  int? get EndBattle => _vals['EndBattle'];
  int? get LoseBattle => _vals['LoseBattle'];
  int? get AddIndividualty => _vals['AddIndividualty'];
  int? get AddLinkageTargetIndividualty => _vals['AddLinkageTargetIndividualty'];
  int? get SameBuffLimitTargetIndividuality => _vals['SameBuffLimitTargetIndividuality'];
  int? get SameBuffLimitNum => _vals['SameBuffLimitNum'];
  int? get CheckDuplicate => _vals['CheckDuplicate'];
  int? get OnFieldCount => _vals['OnFieldCount'];
  List<int>? get TargetRarityList => _list('TargetRarityList');
  int? get DependFuncId => _vals['DependFuncId'];
  int? get InvalidHide => _vals['InvalidHide'];
  int? get OutEnemyNpcId => _vals['OutEnemyNpcId'];
  int? get InEnemyNpcId => _vals['InEnemyNpcId'];
  int? get OutEnemyPosition => _vals['OutEnemyPosition'];
  int? get IgnoreIndividuality => _vals['IgnoreIndividuality'];
  int? get StarHigher => _vals['StarHigher'];
  int? get ChangeTDCommandType => _vals['ChangeTDCommandType'];
  int? get ShiftNpcId => _vals['ShiftNpcId'];
  int? get DisplayLastFuncInvalidType => _vals['DisplayLastFuncInvalidType'];
  List<int>? get AndCheckIndividualityList => _list('AndCheckIndividualityList');
  int? get WinBattleNotRelatedSurvivalStatus => _vals['WinBattleNotRelatedSurvivalStatus'];
  int? get ForceSelfInstantDeath => _vals['ForceSelfInstantDeath'];
  int? get ChangeMaxBreakGauge => _vals['ChangeMaxBreakGauge'];
  int? get ParamAddMaxValue => _vals['ParamAddMaxValue'];
  int? get ParamAddMaxCount => _vals['ParamAddMaxCount'];
  int? get LossHpChangeDamage => _vals['LossHpChangeDamage'];
  int? get IncludePassiveIndividuality => _vals['IncludePassiveIndividuality'];
  int? get MotionChange => _vals['MotionChange'];
  int? get PopLabelDelay => _vals['PopLabelDelay'];
  int? get NoTargetNoAct => _vals['NoTargetNoAct'];
  int? get CardIndex => _vals['CardIndex'];
  int? get CardIndividuality => _vals['CardIndividuality'];
  int? get WarBoardTakeOverBuff => _vals['WarBoardTakeOverBuff'];
  List<int>? get ParamAddSelfIndividuality => _list('ParamAddSelfIndividuality');
  List<int>? get ParamAddOpIndividuality => _list('ParamAddOpIndividuality');
  List<int>? get ParamAddFieldIndividuality => _list('ParamAddFieldIndividuality');
  int? get ParamAddValue => _vals['ParamAddValue'];
  int? get MultipleGainStar => _vals['MultipleGainStar'];
  int? get NoCheckIndividualityIfNotUnit => _vals['NoCheckIndividualityIfNotUnit'];
  int? get ForcedEffectSpeedOne => _vals['ForcedEffectSpeedOne'];
  int? get SetLimitCount => _vals['SetLimitCount'];
  int? get CheckEnemyFieldSpace => _vals['CheckEnemyFieldSpace'];
  int? get TriggeredFuncPosition => _vals['TriggeredFuncPosition'];
  int? get TriggeredFuncPositionDisp => _vals['TriggeredFuncPositionDisp']; // custom, for display
  int? get DamageCount => _vals['DamageCount'];
  List<int>? get DamageRates => _list('DamageRates');
  List<int>? get OnPositions => _list('OnPositions');
  List<int>? get OffPositions => _list('OffPositions');
  int? get TargetIndiv => _vals['TargetIndiv'];
  int? get IncludeIgnoreIndividuality => _vals['IncludeIgnoreIndividuality'];
  int? get EvenIfWinDie => _vals['EvenIfWinDie'];
  int? get CallSvtEffectId => _vals['CallSvtEffectId'];
  int? get ForceAddState => _vals['ForceAddState'];
  int? get UnSubState => _vals['UnSubState'];
  int? get ForceSubState => _vals['ForceSubState'];
  int? get IgnoreIndivUnreleaseable => _vals['IgnoreIndivUnreleaseable'];
  int? get OnParty => _vals['OnParty'];
  int? get CounterId => _vals['CounterId'];
  int? get CounterLv => _vals['CounterLv'];
  int? get CounterOc => _vals['CounterOc'];
  int? get UseTreasureDevice => _vals['UseTreasureDevice'];
  int? get SkillReaction => _vals['SkillReaction'];
  int? get BehaveAsFamilyBuff => _vals['BehaveAsFamilyBuff'];
  int? get UnSubStateWhileLinkedToOthers => _vals['UnSubStateWhileLinkedToOthers'];
  // int? get AllowSubBgmPlaying => _vals['AllowSubBgmPlaying'];
  int? get NotAccompanyWhenLinkedTargetMoveState => _vals['NotAccompanyWhenLinkedTargetMoveState'];
  List<int>? get NotTargetSkillIdArray => _list('NotTargetSkillIdArray');

  int? get ShortTurn => _vals['ShortTurn'];

  List<int>? get FieldIndividuality {
    final v = _vals['FieldIndividuality'];
    if (v is List) return List<int>.from(v);
    if (v is int) return [v];
    return null;
  }

  int? get BGId => _vals['BGId'];
  int? get BGType => _vals['BGType'];
  int? get BgmId => _vals['BgmId'];
  int? get TakeOverFieldState => _vals['TakeOverFieldState'];
  int? get TakeOverNextWaveBGAndBGM => _vals['TakeOverNextWaveBGAndBGM'];
  int? get RemoveFieldBuffActorDeath => _vals['RemoveFieldBuffActorDeath'];
  int? get FieldBuffGrantType => _vals['FieldBuffGrantType'];
  int? get Priority => _vals['Priority'];
  int? get AddIndividualityEx => _vals['AddIndividualityEx'];
  int? get IgnoreResistance => _vals['IgnoreResistance'];
  int? get GainNpTargetPassiveIndividuality => _vals['GainNpTargetPassiveIndividuality'];
  int? get HpReduceToRegainIndiv => _vals['HpReduceToRegainIndiv'];
  int? get DisplayActualRecoveryHpFlag => _vals['DisplayActualRecoveryHpFlag'];
  int? get ShiftDeckIndex => _vals['ShiftDeckIndex'];
  String? get PopValueText => _vals['PopValueText'];
  int? get IsLossHpPerNow => _vals['IsLossHpPerNow'];
  List<int>? get CopyTargetFunctionType => _list('CopyTargetFunctionType');
  int? get CopyFunctionTargetPTOnly => _vals['CopyFunctionTargetPTOnly'];
  int? get IgnoreValueUp => _vals['IgnoreValueUp'];
  // skill 964295 ["Value", "Value2"]
  List<String>? get ApplyValueUp => _list('ApplyValueUp');
  int? get ActNoDamageBuff => _vals['ActNoDamageBuff'];
  int? get ActSelectIndex => _vals['ActSelectIndex'];
  List<int>? get CopyTargetBuffType => _list('CopyTargetBuffType');
  List<int>? get NotSkillCopyTargetFuncIds => _list('NotSkillCopyTargetFuncIds');
  List<int>? get NotSkillCopyTargetIndividualities => _list('NotSkillCopyTargetIndividualities');
  int? get ClassIconAuraEffectId => _vals['ClassIconAuraEffectId'];
  int? get ActMasterGenderType => _vals['ActMasterGenderType'];
  int? get IntervalTurn => _vals['IntervalTurn'];
  int? get IntervalCount => _vals['IntervalCount'];
  int? get TriggeredFieldCountTarget => _vals['TriggeredFieldCountTarget'];

  List<int>? get TriggeredFieldCountRange => _list('TriggeredFieldCountRange');
  List<int>? get TargetEnemyRange => _list('TargetEnemyRange');

  // TriggeredFuncPositionSameTarget > TriggeredFuncPositionAll > TriggeredFuncPosition
  int? get TriggeredFuncPositionSameTarget => _vals['TriggeredFuncPositionSameTarget'];
  int? get TriggeredFuncPositionAll => _vals['TriggeredFuncPositionAll'];
  String? get TriggeredTargetHpRange => _vals['TriggeredTargetHpRange'];
  String? get TriggeredTargetHpRateRange => _vals['TriggeredTargetHpRateRange'];
  int? get ExcludeUnSubStateIndiv => _vals['ExcludeUnSubStateIndiv'];
  int? get ProgressTurnOnBoard => _vals['ProgressTurnOnBoard'];
  int? get CheckTargetResurrectable => _vals['CheckTargetResurrectable'];
  int? get CancelTransform => _vals['CancelTransform'];
  int? get UnSubStateWhenContinue => _vals['UnSubStateWhenContinue'];
  int? get CheckTargetHaveDefeatPoint => _vals['CheckTargetHaveDefeatPoint'];
  int? get NPFixedDamageValue => _vals['NPFixedDamageValue'];
  int? get IgnoreShiftSafeDamage => _vals['IgnoreShiftSafeDamage'];
  int? get ActAttackFunction => _vals['ActAttackFunction'];
  int? get DelayRemoveBuffExpiredOnPlayerTurn => _vals['DelayRemoveBuffExpiredOnPlayerTurn'];
  int? get AllowRemoveBuff => _vals['AllowRemoveBuff'];
  int? get NotExecFunctionIfKeepAliveOnWarBoard => _vals['NotExecFunctionIfKeepAliveOnWarBoard'];
  List<int>? get SnapShotParamAddSelfIndv => _list('SnapShotParamAddSelfIndv');
  List<int>? get SnapShotParamAddOpIndv => _list('SnapShotParamAddOpIndv');
  List<int>? get SnapShotParamAddFieldIndv => _list('SnapShotParamAddFieldIndv');
  int? get SnapShotParamAddValue => _vals['SnapShotParamAddValue'];
  int? get SnapShotParamAddMaxValue => _vals['SnapShotParamAddMaxValue'];
  int? get SnapShotParamAddMaxCount => _vals['SnapShotParamAddMaxCount'];
  int? get NotExecOnTransform => _vals['NotExecOnTransform'];
  int? get NotRemoveOnTransform => _vals['NotRemoveOnTransform'];
  int? get PriorityBgm => _vals['PriorityBgm'];
  int? get BgmAllowSubPlaying => _vals['BgmAllowSubPlaying'];
  int? get BgPriority => _vals['BgPriority'];
  int? get PriorityBg => _vals['PriorityBg'];
  int? get ResetPriorityBgmAtWaveStart => _vals['ResetPriorityBgmAtWaveStart'];
  int? get ControlOtherBgmAtOverStageBgm_Priority => _vals['ControlOtherBgmAtOverStageBgm_Priority'];
  int? get ControlOtherBgmAtOverStageBgm_Target => _vals['ControlOtherBgmAtOverStageBgm_Target'];
  int? get ExtendBuffHalfTurnInOpponentTurn => _vals['ExtendBuffHalfTurnInOpponentTurn'];
  int? get ShortenBuffHalfTurnInOpponentTurn => _vals['ShortenBuffHalfTurnInOpponentTurn'];
  int? get ExtendBuffHalfTurnInPartyTurn => _vals['ExtendBuffHalfTurnInPartyTurn'];
  int? get ShortenBuffHalfTurnInPartyTurn => _vals['ShortenBuffHalfTurnInPartyTurn'];
  int? get LinkageBuffGrantSuccessEvenIfOtherFailed => _vals['LinkageBuffGrantSuccessEvenIfOtherFailed'];
  int? get BattlePointId => _vals['BattlePointId'];
  int? get BattlePointValue => _vals['BattlePointValue'];
  int? get BattlePointUiUpdateType => _vals['BattlePointUiUpdateType'];
  int? get BattlePointOverwrite => _vals['BattlePointOverwrite'];
  String? get CheckOverChargeStageRange => _vals['CheckOverChargeStageRange'];
  String? get CheckBattlePointPhaseRange => _vals['CheckBattlePointPhaseRange'];
  int? get StartingPosition => _vals['StartingPosition'];
  int? get FriendShipAbove => _vals['FriendShipAbove'];
  int? get DamageRateBattlePointPhase => _vals['DamageRateBattlePointPhase'];
  int? get ParamAddBattlePointPhaseId => _vals['ParamAddBattlePointPhaseId'];
  int? get ParamAddBattlePointPhaseValue => _vals['ParamAddBattlePointPhaseValue'];
  int? get ShortenMaxCountEachSkill => _vals['ShortenMaxCountEachSkill'];

  int? get ApplySupportSvt => _vals['ApplySupportSvt'];
  int? get Individuality => _vals['Individuality'];
  int? get EventId => _vals['EventId'];
  int? get AddCount => _vals['AddCount'];
  int? get RateCount => _vals['RateCount'];
  int? get DropRateCount => _vals['DropRateCount'];
}
