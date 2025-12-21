// ignore_for_file: non_constant_identifier_names

import '_helper.dart';
import 'func.dart' show FuncTargetType;

part '../../generated/models/gamedata/vals.g.dart';

@JsonSerializable(createFactory: false, createToJson: false)
class DataVals {
  Map<String, dynamic> _vals;
  DataVals? get DependFuncVals => _vals['DependFuncVals'] == null ? null : DataVals(_vals['DependFuncVals']);

  DataVals([Map<dynamic, dynamic>? sourceVals]) : _vals = Map.from(sourceVals ?? {});

  Map<String, dynamic> getSourceVals() => _vals;

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

  T? get<T>(String key) => _vals[key];

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

  T? _get<T>(String key) {
    final v = _vals[key];
    try {
      return v as T?;
    } catch (e) {
      assert(() {
        throw FormatException('[DataVals]: decode "$key"($T) failed, received "$v"(${v.runtimeType})');
      }());
      return null;
    }
  }

  List<T>? _list<T>(String key) {
    final v = _vals[key];
    if (v != null && v is! List) {
      if (T == int && v is int) {
        return <T>[v as T];
      }
      assert(() {
        throw FormatException('[DataVals]: decode list "$key"($T) failed, received "$v"(${v.runtimeType})');
      }());
      return null;
    }
    return (v as List<dynamic>?)?.cast();
  }

  List<List<T>>? _2dList<T>(String key) {
    final v = _vals[key];
    if (v == null) return null;
    if (v is String && T == int) {
      try {
        List<List<int>> array = [];
        for (String v1 in v.split('|')) {
          v1 = v1.trim();
          if (v1.isEmpty) continue;
          array.add(v1.split('/').map(int.tryParse).whereType<int>().toList());
        }
        return array as List<List<T>>;
      } catch (e) {
        return null;
      }
    }
    return (v as List<dynamic>).map((e) => (e as List<dynamic>).cast<T>()).toList();
  }

  List<T>? _parseObjList<T>(String key, T Function(Map<String, dynamic> json) fromJson) {
    final v = _vals[key];
    assert(v == null || v is List, '$key: $v');
    if (v == null || v is! List) return null;
    return v.map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
  }

  // start fields

  /// probability, 1000 -> 100%
  int? get Rate => _get('Rate');

  /// 3 Turns/3ターン/3回合
  int? get Turn => _get('Turn');

  /// 3 Times/3回/3次
  int? get Count => _get('Count');
  int? get Value => _get('Value');
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
  int? get UseRate => _get('UseRate');
  int? get Target => _get('Target');
  int? get Correction => _get('Correction');
  int? get ParamAdd => _get('ParamAdd');
  int? get ParamMax => _get('ParamMax');
  int? get HideMiss => _get('HideMiss');
  int? get OnField => _get('OnField');
  int? get HideNoEffect => _get('HideNoEffect');
  int? get Unaffected => _get('Unaffected');
  // SHOW_STATE = 1;
  // HIDE_STATE = -1;
  // SHOW_DEFF_STATE = -2;
  // SHOW_STATE_STATUS_BUFF_ONLY = 2;
  // SHOW_STATE_DAMAGE_AND_COMMANDCARD_BUFF = 3;
  int? get ShowState => _get('ShowState');
  int? get AuraEffectId => _get('AuraEffectId');
  int? get ActSet => _get('ActSet');
  int? get ActSetWeight => _get('ActSetWeight');
  int? get ShowQuestNoEffect => _get('ShowQuestNoEffect');
  int? get CheckDead => _get('CheckDead');
  int? get RatioHPHigh => _get('RatioHPHigh');
  int? get RatioHPLow => _get('RatioHPLow');
  int? get SetPassiveFrame => _get('SetPassiveFrame');
  int? get ProcPassive => _get('ProcPassive');
  int? get ProcActive => _get('ProcActive');
  int? get HideParam => _get('HideParam');
  int? get SkillID => _get('SkillID');
  int? get SkillLV => _get('SkillLV');
  int? get ShowCardOnly => _get('ShowCardOnly');
  int? get EffectSummon => _get('EffectSummon');
  int? get RatioHPRangeHigh => _get('RatioHPRangeHigh');
  int? get RatioHPRangeLow => _get('RatioHPRangeLow');
  List<int>? get TargetList => _list('TargetList');
  int? get OpponentOnly => _get('OpponentOnly');
  int? get StatusEffectId => _get('StatusEffectId');
  int? get EndBattle => _get('EndBattle');
  int? get LoseBattle => _get('LoseBattle');
  @Deprecated('use getAddIndividualty()')
  int? get AddIndividualty => _get('AddIndividualty');
  List<int>? get AddIndividualtyList => _list('AddIndividualtyList'); // an array version of `AddIndividualty`
  int? get AddLinkageTargetIndividualty => _get('AddLinkageTargetIndividualty');
  int? get SameBuffLimitTargetIndividuality => _get('SameBuffLimitTargetIndividuality');
  int? get SameBuffLimitNum => _get('SameBuffLimitNum');
  int? get CheckDuplicate => _get('CheckDuplicate');
  int? get OnFieldCount => _get('OnFieldCount');
  List<int>? get TargetRarityList => _list('TargetRarityList');
  int? get DependFuncId => _get('DependFuncId');
  int? get InvalidHide => _get('InvalidHide');
  int? get OutEnemyNpcId => _get('OutEnemyNpcId');
  int? get InEnemyNpcId => _get('InEnemyNpcId');
  int? get OutEnemyPosition => _get('OutEnemyPosition');
  int? get IgnoreIndividuality => _get('IgnoreIndividuality');
  int? get StarHigher => _get('StarHigher');
  int? get ChangeTDCommandType => _get('ChangeTDCommandType');
  int? get ShiftNpcId => _get('ShiftNpcId');
  int? get DisplayLastFuncInvalidType => _get('DisplayLastFuncInvalidType');
  List<int>? get AndCheckIndividualityList => _list('AndCheckIndividualityList');
  List<List<int>>? get AndOrCheckIndividualityList => _2dList('AndOrCheckIndividualityList');
  int? get WinBattleNotRelatedSurvivalStatus => _get('WinBattleNotRelatedSurvivalStatus');
  int? get ForceSelfInstantDeath => _get('ForceSelfInstantDeath');
  int? get ChangeMaxBreakGauge => _get('ChangeMaxBreakGauge');
  int? get ParamAddMaxValue => _get('ParamAddMaxValue');
  int? get ParamAddMaxCount => _get('ParamAddMaxCount');
  int? get LossHpChangeDamage => _get('LossHpChangeDamage');
  int? get IncludePassiveIndividuality => _get('IncludePassiveIndividuality');
  int? get MotionChange => _get('MotionChange');
  int? get PopLabelDelay => _get('PopLabelDelay');
  int? get NoTargetNoAct => _get('NoTargetNoAct');
  int? get CardIndex => _get('CardIndex');
  int? get CardIndividuality => _get('CardIndividuality');
  int? get WarBoardTakeOverBuff => _get('WarBoardTakeOverBuff');
  List<int>? get ParamAddSelfIndividuality => _list('ParamAddSelfIndividuality');
  List<int>? get ParamAddOpIndividuality => _list('ParamAddOpIndividuality');
  List<int>? get ParamAddFieldIndividuality => _list('ParamAddFieldIndividuality'); // quest field indiv
  int? get ParamAddValue => _get('ParamAddValue');
  int? get MultipleGainStar => _get('MultipleGainStar');
  int? get NoCheckIndividualityIfNotUnit => _get('NoCheckIndividualityIfNotUnit');
  int? get ForcedEffectSpeedOne => _get('ForcedEffectSpeedOne');
  int? get SetLimitCount => _get('SetLimitCount');
  int? get CheckEnemyFieldSpace => _get('CheckEnemyFieldSpace');
  int? get TriggeredFuncPosition => _get('TriggeredFuncPosition');
  int? get TriggeredFuncPositionDisp => _get('TriggeredFuncPositionDisp'); // custom, for display
  int? get DamageCount => _get('DamageCount');
  List<int>? get DamageRates => _list('DamageRates');
  List<int>? get OnPositions => _list('OnPositions');
  List<int>? get OffPositions => _list('OffPositions');
  int? get TargetIndiv => _get('TargetIndiv');
  int? get IncludeIgnoreIndividuality => _get('IncludeIgnoreIndividuality');
  int? get EvenIfWinDie => _get('EvenIfWinDie');
  int? get CallSvtEffectId => _get('CallSvtEffectId');
  int? get ForceAddState => _get('ForceAddState');
  int? get UnSubState => _get('UnSubState');
  int? get ForceSubState => _get('ForceSubState');
  int? get IgnoreIndivUnreleaseable => _get('IgnoreIndivUnreleaseable');
  int? get OnParty => _get('OnParty');
  int? get CounterId => _get('CounterId');
  int? get CounterLv => _get('CounterLv');
  int? get CounterOc => _get('CounterOc');
  int? get UseTreasureDevice => _get('UseTreasureDevice');
  int? get SkillReaction => _get('SkillReaction');
  int? get BehaveAsFamilyBuff => _get('BehaveAsFamilyBuff');
  int? get UnSubStateWhileLinkedToOthers => _get('UnSubStateWhileLinkedToOthers');
  // int? get AllowSubBgmPlaying => _get('AllowSubBgmPlaying');
  int? get NotAccompanyWhenLinkedTargetMoveState => _get('NotAccompanyWhenLinkedTargetMoveState');
  List<int>? get NotTargetSkillIdArray => _list('NotTargetSkillIdArray');
  int? get ShortTurn => _get('ShortTurn');
  List<int>? get FieldIndividuality => _list('FieldIndividuality');
  int? get BGId => _get('BGId');
  int? get BGType => _get('BGType');
  int? get BgmId => _get('BgmId');
  int? get TakeOverFieldState => _get('TakeOverFieldState');
  int? get TakeOverNextWaveBGAndBGM => _get('TakeOverNextWaveBGAndBGM');
  int? get RemoveFieldBuffActorDeath => _get('RemoveFieldBuffActorDeath');
  int? get FieldBuffGrantType => _get('FieldBuffGrantType');
  int? get Priority => _get('Priority');
  List<int>? get AddIndividualityEx => _list('AddIndividualityEx');
  int? get IgnoreResistance => _get('IgnoreResistance');
  int? get GainNpTargetPassiveIndividuality => _get('GainNpTargetPassiveIndividuality');
  int? get HpReduceToRegainIndiv => _get('HpReduceToRegainIndiv');
  int? get DisplayActualRecoveryHpFlag => _get('DisplayActualRecoveryHpFlag');
  int? get ShiftDeckIndex => _get('ShiftDeckIndex');
  String? get PopValueText => _get('PopValueText');
  int? get IsLossHpPerNow => _get('IsLossHpPerNow');
  List<int>? get CopyTargetFunctionType => _list('CopyTargetFunctionType');
  int? get CopyFunctionTargetPTOnly => _get('CopyFunctionTargetPTOnly');
  int? get IgnoreValueUp => _get('IgnoreValueUp');
  // skill 964295 ["Value", "Value2"]
  List<String>? get ApplyValueUp => _list('ApplyValueUp');
  int? get ActNoDamageBuff => _get('ActNoDamageBuff');
  int? get ActSelectIndex => _get('ActSelectIndex');
  List<int>? get CopyTargetBuffType => _list('CopyTargetBuffType');
  List<int>? get NotSkillCopyTargetFuncIds => _list('NotSkillCopyTargetFuncIds');
  List<int>? get NotSkillCopyTargetIndividualities => _list('NotSkillCopyTargetIndividualities');
  int? get ClassIconAuraEffectId => _get('ClassIconAuraEffectId');
  int? get ActMasterGenderType => _get('ActMasterGenderType');
  int? get IntervalTurn => _get('IntervalTurn');
  int? get IntervalCount => _get('IntervalCount');
  int? get TriggeredFieldCountTarget => _get('TriggeredFieldCountTarget');

  String? get TriggeredFieldCountRange => _get('TriggeredFieldCountRange');
  List<int>? get TargetEnemyRange => _list('TargetEnemyRange'); // 1/2/3

  // TriggeredFuncPositionSameTarget > TriggeredFuncPositionAll > TriggeredFuncPosition
  int? get TriggeredFuncPositionSameTarget => _get('TriggeredFuncPositionSameTarget');
  int? get TriggeredFuncPositionAll => _get('TriggeredFuncPositionAll');
  List<String>? get TriggeredTargetHpRange {
    final v = _vals['TriggeredTargetHpRange'];
    if (v is String) {
      return v.split('/');
    }
    return v;
  }

  List<String>? get TriggeredTargetHpRateRange {
    final v = _vals['TriggeredTargetHpRateRange'];
    if (v is String) {
      return v.split('/');
    }
    return v;
  }

  int? get ExcludeUnSubStateIndiv => _get('ExcludeUnSubStateIndiv');
  int? get ProgressTurnOnBoard => _get('ProgressTurnOnBoard');
  int? get CheckTargetResurrectable => _get('CheckTargetResurrectable');
  int? get CancelTransform => _get('CancelTransform');
  int? get UnSubStateWhenContinue => _get('UnSubStateWhenContinue');
  int? get CheckTargetHaveDefeatPoint => _get('CheckTargetHaveDefeatPoint');
  int? get NPFixedDamageValue => _get('NPFixedDamageValue');
  int? get IgnoreShiftSafeDamage => _get('IgnoreShiftSafeDamage');
  int? get ActAttackFunction => _get('ActAttackFunction');
  int? get DelayRemoveBuffExpiredOnPlayerTurn => _get('DelayRemoveBuffExpiredOnPlayerTurn');
  int? get AllowRemoveBuff => _get('AllowRemoveBuff');
  int? get NotExecFunctionIfKeepAliveOnWarBoard => _get('NotExecFunctionIfKeepAliveOnWarBoard');
  List<int>? get SnapShotParamAddSelfIndv => _list('SnapShotParamAddSelfIndv');
  List<int>? get SnapShotParamAddOpIndv => _list('SnapShotParamAddOpIndv');
  List<int>? get SnapShotParamAddFieldIndv => _list('SnapShotParamAddFieldIndv');
  int? get SnapShotParamAddValue => _get('SnapShotParamAddValue');
  int? get SnapShotParamAddMaxValue => _get('SnapShotParamAddMaxValue');
  int? get SnapShotParamAddMaxCount => _get('SnapShotParamAddMaxCount');
  int? get NotExecOnTransform => _get('NotExecOnTransform');
  int? get NotRemoveOnTransform => _get('NotRemoveOnTransform');
  int? get PriorityBgm => _get('PriorityBgm');
  int? get BgmAllowSubPlaying => _get('BgmAllowSubPlaying');
  int? get BgPriority => _get('BgPriority');
  int? get PriorityBg => _get('PriorityBg');
  int? get ResetPriorityBgmAtWaveStart => _get('ResetPriorityBgmAtWaveStart');
  int? get ControlOtherBgmAtOverStageBgm_Priority => _get('ControlOtherBgmAtOverStageBgm_Priority');
  int? get ControlOtherBgmAtOverStageBgm_Target => _get('ControlOtherBgmAtOverStageBgm_Target');
  int? get ExtendBuffHalfTurnInOpponentTurn => _get('ExtendBuffHalfTurnInOpponentTurn');
  int? get ShortenBuffHalfTurnInOpponentTurn => _get('ShortenBuffHalfTurnInOpponentTurn');
  int? get ExtendBuffHalfTurnInPartyTurn => _get('ExtendBuffHalfTurnInPartyTurn');
  int? get ShortenBuffHalfTurnInPartyTurn => _get('ShortenBuffHalfTurnInPartyTurn');
  int? get LinkageBuffGrantSuccessEvenIfOtherFailed => _get('LinkageBuffGrantSuccessEvenIfOtherFailed');
  String? get DisplayNoEffectCauses => _get('DisplayNoEffectCauses');
  int? get BattlePointId => _get('BattlePointId');
  int? get BattlePointValue => _get('BattlePointValue');
  int? get BattlePointUiUpdateType => _get('BattlePointUiUpdateType');
  int? get BattlePointOverwrite => _get('BattlePointOverwrite');
  // [CheckOverChargeStageRange]: 0~4 => OC1~5
  List<String>? get CheckOverChargeStageRange => _list('CheckOverChargeStageRange');
  List<ValCheckBattlePointPhaseRange>? get CheckBattlePointPhaseRange =>
      _parseObjList('CheckBattlePointPhaseRange', ValCheckBattlePointPhaseRange.fromJson);
  List<int>? get StartingPosition => _list('StartingPosition');
  int? get FriendShipAbove => _get('FriendShipAbove');
  List<ValDamageRateBattlePointPhase>? get DamageRateBattlePointPhase =>
      _parseObjList('DamageRateBattlePointPhase', ValDamageRateBattlePointPhase.fromJson);
  int? get ParamAddBattlePointPhaseId => _get('ParamAddBattlePointPhaseId');
  int? get ParamAddBattlePointPhaseValue => _get('ParamAddBattlePointPhaseValue');
  List<int>? get ShortenMaxCountEachSkill => _list('ShortenMaxCountEachSkill');
  int? get ChargeHpMaxBeforeBreakGaugeUp => _get('ChargeHpMaxBeforeBreakGaugeUp');
  List<int>? get TargetFunctionIndividuality => _list('TargetFunctionIndividuality');
  List<int>? get TargetBuffIndividuality => _list('TargetBuffIndividuality');

  int? get TargetEnemyClass => _get('TargetEnemyClass');
  int? get ParamAddIndividualityTargetType => _get('ParamAddIndividualityTargetType'); // default -1
  List<int>? get TriggeredFuncIndexAndCheckList => _list('TriggeredFuncIndexAndCheckList');
  int? get FuncCheckTargetIndividualityTargetType => _get('FuncCheckTargetIndividualityTargetType');
  int? get FuncCheckTargetIndividualityCountHigher => _get('FuncCheckTargetIndividualityCountHigher');
  int? get FuncCheckTargetIndividualityCountLower => _get('FuncCheckTargetIndividualityCountLower');
  int? get FuncCheckTargetIndividualityCountEqual => _get('FuncCheckTargetIndividualityCountEqual');
  List<List<int>>? get ParamAddSelfIndividualityAndCheck => _2dList('ParamAddSelfIndividualityAndCheck');
  List<List<int>>? get ParamAddOpIndividualityAndCheck => _2dList('ParamAddOpIndividualityAndCheck');
  List<List<int>>? get ParamAddFieldIndividualityAndCheck => _2dList('ParamAddFieldIndividualityAndCheck');
  List<List<int>>? get SnapShotParamAddSelfIndividualityAndCheck =>
      _2dList('SnapShotParamAddSelfIndividualityAndCheck');
  List<List<int>>? get SnapShotParamAddOpIndividualityAndCheck => _2dList('SnapShotParamAddOpIndividualityAndCheck');
  List<List<int>>? get SnapShotParamAddFieldIndividualityAndCheck =>
      _2dList('SnapShotParamAddFieldIndividualityAndCheck');
  int? get EnemyCountChangeTime => _get('EnemyCountChangeTime');
  int? get EnemyCountChangeEffectId => _get('EnemyCountChangeEffectId');
  int? get EnemyCountWaitTimeAfterMessage => _get('EnemyCountWaitTimeAfterMessage');
  int? get WaitMessageEnd => _get('WaitMessageEnd');
  int? get MessageStartDelayTime => _get('MessageStartDelayTime');
  int? get ContinueDisplayMessage => _get('ContinueDisplayMessage');
  int? get StartIntervalTurn => _get('StartIntervalTurn');
  int? get StartIntervalCount => _get('StartIntervalCount');
  int? get CommonReleaseId => _get('CommonReleaseId');
  int? get ForceTurnProgressIfTimingIsOverInPartyTurn => _get('ForceTurnProgressIfTimingIsOverInPartyTurn');
  int? get ForceTurnProgressIfTimingIsOverInOpponentTurn => _get('ForceTurnProgressIfTimingIsOverInOpponentTurn');
  int? get OverwriteFuncInvalidType => _get('OverwriteFuncInvalidType');
  int? get BgmFadeTime => _get('BgmFadeTime');
  int? get KeepChangeModelAfterContinue => _get('KeepChangeModelAfterContinue');
  int? get DefenceDamageHigher => _get('DefenceDamageHigher');
  int? get SameIndivBuffActorOnField => _get('SameIndivBuffActorOnField');
  int? get SyncUsedSameIndivBuffActorOnField => _get('SyncUsedSameIndivBuffActorOnField');
  int? get OnlyMaxFuncGroupId => _get('OnlyMaxFuncGroupId');
  int? get UseAttack => _get('UseAttack');
  int? get CondParamAddType => _get('CondParamAddType');
  int? get CondParamAddValue => _get('CondParamAddValue');
  int? get CondParamAddMaxValue => _get('CondParamAddMaxValue');
  List<int>? get CondParamAddTargetId => _list('CondParamAddTargetId');
  int? get CondParamRangeType => _get('CondParamRangeType');
  int? get CondParamRangeMaxCount => _get('CondParamRangeMaxCount');
  int? get CondParamRangeMaxValue => _get('CondParamRangeMaxValue');
  List<int>? get CondParamRangeTargetId => _list('CondParamRangeTargetId');
  int? get ExecOnce => _get('ExecOnce');
  List<List<int>>? get ApplyBuffIndividuality => _2dList('ApplyBuffIndividuality');
  int? get ExecWhenCanNotAttack => _get('ExecWhenCanNotAttack');
  int? get ExecEvenCardSelectState => _get('ExecEvenCardSelectState');
  int? get OverwriteShift => _get('OverwriteShift');
  int? get IgnoreShiftWhiteFade => _get('IgnoreShiftWhiteFade');
  List<int>? get BackStepTargets => _list('BackStepTargets');
  List<int>? get ReplacePositionTargets => _list('ReplacePositionTargets');
  int? get ApplySupportSvt => _get('ApplySupportSvt');
  int? get ApplyHighestValueInFieldGroup => _get('ApplyHighestValueInFieldGroup');
  int? get IsClassIconChangeSaveGrand => _get('IsClassIconChangeSaveGrand');
  int? get ExecuteEffectId => _get('ExecuteEffectId');
  int? get PriorityUpHate => _get('PriorityUpHate');
  int? get JudgeUseEveryTime => _get('JudgeUseEveryTime');
  int? get IgnoreDeathRate => _get('IgnoreDeathRate');
  int? get SubstituteRate => _get('SubstituteRate');
  int? get SubstituteResist => _get('SubstituteResist');
  int? get UseSvtResistRate => _get('UseSvtResistRate');
  int? get UseBuffResistRate => _get('UseBuffResistRate');
  int? get SubstituteSkillId => _get('SubstituteSkillId');
  int? get SubstituteSkillLv => _get('SubstituteSkillLv');
  int? get ResistSkillId => _get('ResistSkillId');
  int? get ResistSkillLv => _get('ResistSkillLv');
  String? get SubstitutePopupText => _get('SubstitutePopupText');
  int? get SubstitutePopupIconId => _get('SubstitutePopupIconId');
  String? get ResistPopupText => _get('ResistPopupText');
  int? get ResistPopupIconId => _get('ResistPopupIconId');
  List<int>? get SubstituteEffectList => _list('SubstituteEffectList');
  List<int>? get ResistEffectList => _list('ResistEffectList');
  int? get EnablePassiveBuffConvert => _get('EnablePassiveBuffConvert');
  int? get FieldBuffApplyTarget => _get('FieldBuffApplyTarget'); // enum FieldBuffApplyTargetType
  int? get MaxGainNp => _get('MaxGainNp');
  int? get MaxHastenNpTurn => _get('MaxHastenNpTurn');
  int? get FunctionTriggerActorTargetFlag =>
      _get('FunctionTriggerActorTargetFlag'); // flag list, enum FuncTriggerActorTargetFlag
  int? get IsTurnProgressWithoutGrantActor => _get('IsTurnProgressWithoutGrantActor');
  int? get IsFuncCheckFieldIndividuality => _get('IsFuncCheckFieldIndividuality');
  int? get IgnoreTargetFuncResult => _get('IgnoreTargetFuncResult');
  int? get ExecuteWhenHideText => _get('ExecuteWhenHideText');
  int? get SkipCheckAlive => _get('SkipCheckAlive');

  //
  int? get Individuality => _get('Individuality');
  int? get EventId => _get('EventId');
  int? get AddCount => _get('AddCount');
  int? get RateCount => _get('RateCount');
  int? get DropRateCount => _get('DropRateCount');
  // custom fields
  int? get CommandSpellId => _get('CommandSpellId');
  // end fields

  // methods

  List<int> getAddIndividuality() {
    return [
      // ignore: deprecated_member_use_from_same_package
      if (AddIndividualtyList != null) ...?AddIndividualtyList else if (AddIndividualty != null) AddIndividualty!,
      ...?AddIndividualityEx,
    ];
  }

  /// [TriggeredTargetHpRange], [TriggeredTargetHpRateRange]
  /// [CheckOverChargeStageRange], [CheckBattlePointPhaseRange]
  /// [TriggeredFieldCountRange] always force equal checks
  static bool isSatisfyRangeText(int value, {String? rangeText, List<String>? ranges, bool forceEqual = false}) {
    if (ranges == null && rangeText != null) ranges = rangeText.split('/').map((e) => e.trim()).toList();
    if (ranges == null || ranges.isEmpty) return true;

    for (final range in ranges) {
      bool? _check(RegExp reg, bool Function(int target) compare) {
        final m = reg.firstMatch(range);
        if (m == null) return null;
        assert(int.tryParse(m.group(1) ?? '') != null, '$reg: $range');
        return compare(int.parse(m.group(1)!));
      }

      bool? result =
          _check(RegExp(r'^<(\d+)$'), (target) => value < target || (forceEqual && value <= target)) ??
          _check(RegExp(r'^<=(\d+)$'), (target) => value <= target) ??
          _check(RegExp(r'^>(\d+)$'), (target) => value > target || (forceEqual && value >= target)) ??
          _check(RegExp(r'^>=(\d+)$'), (target) => value >= target) ??
          _check(RegExp(r'^(\d+)>$'), (target) => value < target || (forceEqual && value <= target)) ??
          _check(RegExp(r'^(\d+)>=$'), (target) => value <= target) ??
          _check(RegExp(r'^(\d+)<$'), (target) => value > target || (forceEqual && value >= target)) ??
          _check(RegExp(r'^(\d+)<=$'), (target) => value >= target);
      _check(RegExp(r'^=*(\d+)$'), (target) => value == target);
      assert(result != null, 'Unknown compare type: $range');
      if (result == false) return false;
    }
    return true;
  }

  static List<String> beautifyRangeTexts(List<String> ranges) {
    if (ranges.length == 1) {
      final m = RegExp(r'^(\d+)(<=|<)$').firstMatch(ranges.single);
      final String range = switch (m?.group(2)) {
        '<=' => '>=${m?.group(1)}',
        '<' => '>${m?.group(1)}',
        _ => ranges.single,
      };
      ranges = [range];
    }
    return ranges.map((e) => e.replaceAll('>=', '≥').replaceAll('<=', '≤')).toList();
  }
}

@JsonSerializable()
class ValCheckBattlePointPhaseRange {
  int battlePointId;
  List<String> range;

  ValCheckBattlePointPhaseRange({required this.battlePointId, required this.range});

  factory ValCheckBattlePointPhaseRange.fromJson(Map<String, dynamic> json) =>
      _$ValCheckBattlePointPhaseRangeFromJson(json);

  Map<String, dynamic> toJson() => _$ValCheckBattlePointPhaseRangeToJson(this);
}

@JsonSerializable()
class ValDamageRateBattlePointPhase {
  int battlePointPhase;
  int value;

  ValDamageRateBattlePointPhase({required this.battlePointPhase, required this.value});

  factory ValDamageRateBattlePointPhase.fromJson(Map<String, dynamic> json) =>
      _$ValDamageRateBattlePointPhaseFromJson(json);

  Map<String, dynamic> toJson() => _$ValDamageRateBattlePointPhaseToJson(this);
}

enum FieldBuffApplyTargetType {
  none(0),
  player(1),
  enemy(2),
  all(3);

  const FieldBuffApplyTargetType(this.value);
  final int value;

  static FieldBuffApplyTargetType fromValue(int value) =>
      values.firstWhere((e) => e.value == value, orElse: () => none);

  bool get onPlayer => this == player || this == all;
  bool get onEnemy => this == enemy || this == all;
}

enum FuncTriggerActorTargetFlag {
  none(0),
  self(1),
  partyOther(2),
  opponents(4),
  partyOtherAll(8),
  opponentsAll(16);

  const FuncTriggerActorTargetFlag(this.value);
  final int value;

  static List<FuncTriggerActorTargetFlag> fromValue(int? value) {
    if (value == null || value == 0) return [];
    return [
      for (final v in values)
        if (v.value != 0 && v.value & value != 0) v,
    ];
  }

  FuncTargetType toFuncTarget() {
    return switch (this) {
      .none => FuncTargetType.noTarget,
      .self => FuncTargetType.self,
      .partyOther => .ptOther,
      .opponents => .enemyAll,
      .partyOtherAll => .ptOtherFull,
      .opponentsAll => .enemyFull,
    };
  }
}
