// ignore_for_file: non_constant_identifier_names

import '_helper.dart';

part '../../generated/models/gamedata/vals.g.dart';

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

  List<T>? _list<T>(String key) {
    final v = _vals[key];
    if (v != null && v is! List) {
      if (T == int && v is int) {
        return <T>[v as T];
      }
      assert(() {
        throw FormatException('[DataVals]: key "$key" requires List but ${v.runtimeType}');
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
  @Deprecated('use getAddIndividualty()')
  int? get AddIndividualty => _vals['AddIndividualty'];
  List<int>? get AddIndividualtyList => _list('AddIndividualtyList'); // an array version of `AddIndividualty`
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
  List<List<int>>? get AndOrCheckIndividualityList => _2dList('AndOrCheckIndividualityList');
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
  List<int>? get AddIndividualityEx => _list('AddIndividualityEx');
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

  String? get TriggeredFieldCountRange => _vals['TriggeredFieldCountRange'];
  List<int>? get TargetEnemyRange => _list('TargetEnemyRange'); // 1/2/3

  // TriggeredFuncPositionSameTarget > TriggeredFuncPositionAll > TriggeredFuncPosition
  int? get TriggeredFuncPositionSameTarget => _vals['TriggeredFuncPositionSameTarget'];
  int? get TriggeredFuncPositionAll => _vals['TriggeredFuncPositionAll'];
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
  String? get DisplayNoEffectCauses => _vals['DisplayNoEffectCauses'];
  int? get BattlePointId => _vals['BattlePointId'];
  int? get BattlePointValue => _vals['BattlePointValue'];
  int? get BattlePointUiUpdateType => _vals['BattlePointUiUpdateType'];
  int? get BattlePointOverwrite => _vals['BattlePointOverwrite'];
  // [CheckOverChargeStageRange]: 0~4 => OC1~5
  List<String>? get CheckOverChargeStageRange => _list('CheckOverChargeStageRange');
  List<ValCheckBattlePointPhaseRange>? get CheckBattlePointPhaseRange =>
      _parseObjList('CheckBattlePointPhaseRange', ValCheckBattlePointPhaseRange.fromJson);
  List<int>? get StartingPosition => _list('StartingPosition');
  int? get FriendShipAbove => _vals['FriendShipAbove'];
  List<ValDamageRateBattlePointPhase>? get DamageRateBattlePointPhase =>
      _parseObjList('DamageRateBattlePointPhase', ValDamageRateBattlePointPhase.fromJson);
  int? get ParamAddBattlePointPhaseId => _vals['ParamAddBattlePointPhaseId'];
  int? get ParamAddBattlePointPhaseValue => _vals['ParamAddBattlePointPhaseValue'];
  List<int>? get ShortenMaxCountEachSkill => _list('ShortenMaxCountEachSkill');
  int? get ChargeHpMaxBeforeBreakGaugeUp => _vals['ChargeHpMaxBeforeBreakGaugeUp'];
  List<int>? get TargetFunctionIndividuality => _list('TargetFunctionIndividuality');
  List<int>? get TargetBuffIndividuality => _list('TargetBuffIndividuality');

  int? get TargetEnemyClass => _vals['TargetEnemyClass'];
  int? get ParamAddIndividualityTargetType => _vals['ParamAddIndividualityTargetType'];
  List<int>? get TriggeredFuncIndexAndCheckList => _vals['TriggeredFuncIndexAndCheckList'];
  int? get FuncCheckTargetIndividualityTargetType => _vals['FuncCheckTargetIndividualityTargetType'];
  int? get FuncCheckTargetIndividualityCountHigher => _vals['FuncCheckTargetIndividualityCountHigher'];
  int? get FuncCheckTargetIndividualityCountLower => _vals['FuncCheckTargetIndividualityCountLower'];
  int? get FuncCheckTargetIndividualityCountEqual => _vals['FuncCheckTargetIndividualityCountEqual'];
  List<List<int>>? get ParamAddSelfIndividualityAndCheck => _2dList('ParamAddSelfIndividualityAndCheck');
  List<List<int>>? get ParamAddOpIndividualityAndCheck => _2dList('ParamAddOpIndividualityAndCheck');
  List<List<int>>? get ParamAddFieldIndividualityAndCheck => _2dList('ParamAddFieldIndividualityAndCheck');
  List<List<int>>? get SnapShotParamAddSelfIndividualityAndCheck =>
      _2dList('SnapShotParamAddSelfIndividualityAndCheck');
  List<List<int>>? get SnapShotParamAddOpIndividualityAndCheck => _2dList('SnapShotParamAddOpIndividualityAndCheck');
  List<List<int>>? get SnapShotParamAddFieldIndividualityAndCheck =>
      _2dList('SnapShotParamAddFieldIndividualityAndCheck');
  int? get EnemyCountChangeTime => _vals['EnemyCountChangeTime'];
  int? get EnemyCountChangeEffectId => _vals['EnemyCountChangeEffectId'];
  int? get EnemyCountWaitTimeAfterMessage => _vals['EnemyCountWaitTimeAfterMessage'];
  int? get WaitMessageEnd => _vals['WaitMessageEnd'];
  int? get MessageStartDelayTime => _vals['MessageStartDelayTime'];
  int? get ContinueDisplayMessage => _vals['ContinueDisplayMessage'];
  int? get StartIntervalTurn => _vals['StartIntervalTurn'];
  int? get StartIntervalCount => _vals['StartIntervalCount'];
  int? get CommonReleaseId => _vals['CommonReleaseId'];
  int? get ForceTurnProgressIfTimingIsOverInPartyTurn => _vals['ForceTurnProgressIfTimingIsOverInPartyTurn'];
  int? get ForceTurnProgressIfTimingIsOverInOpponentTurn => _vals['ForceTurnProgressIfTimingIsOverInOpponentTurn'];
  int? get OverwriteFuncInvalidType => _vals['OverwriteFuncInvalidType'];
  int? get BgmFadeTime => _vals['BgmFadeTime'];
  int? get KeepChangeModelAfterContinue => _vals['KeepChangeModelAfterContinue'];
  int? get DefenceDamageHigher => _vals['DefenceDamageHigher'];
  int? get SameIndivBuffActorOnField => _vals['SameIndivBuffActorOnField'];
  int? get SyncUsedSameIndivBuffActorOnField => _vals['SyncUsedSameIndivBuffActorOnField'];
  int? get OnlyMaxFuncGroupId => _vals['OnlyMaxFuncGroupId'];
  int? get UseAttack => _vals['UseAttack'];

  int? get ApplySupportSvt => _vals['ApplySupportSvt'];
  int? get Individuality => _vals['Individuality'];
  int? get EventId => _vals['EventId'];
  int? get AddCount => _vals['AddCount'];
  int? get RateCount => _vals['RateCount'];
  int? get DropRateCount => _vals['DropRateCount'];
  // custom fields
  int? get CommandSpellId => _vals['CommandSpellId'];

  List<T>? _parseObjList<T>(String key, T Function(Map<String, dynamic> json) fromJson) {
    final v = _vals[key];
    assert(v == null || v is List, '$key: $v');
    if (v == null || v is! List) return null;
    return v.map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
  }

  List<int> getAddIndividuality() {
    return [
      if (AddIndividualtyList != null) ...?AddIndividualtyList else if (AddIndividualty != null) AddIndividualty!,
      ...?AddIndividualityEx,
    ];
  }

  /// [TriggeredTargetHpRange], [TriggeredTargetHpRateRange]
  /// [CheckOverChargeStageRange], [CheckBattlePointPhaseRange]
  static bool isSatisfyRangeText(int value, {String? rangeText, List<String>? ranges}) {
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
          _check(RegExp(r'^<(\d+)$'), (target) => value < target) ??
          _check(RegExp(r'^<=(\d+)$'), (target) => value <= target) ??
          _check(RegExp(r'^>(\d+)$'), (target) => value > target) ??
          _check(RegExp(r'^>=(\d+)$'), (target) => value >= target) ??
          _check(RegExp(r'^(\d+)>$'), (target) => value < target) ??
          _check(RegExp(r'^(\d+)>=$'), (target) => value <= target) ??
          _check(RegExp(r'^(\d+)<$'), (target) => value > target) ??
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
