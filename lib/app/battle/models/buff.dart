import 'dart:math';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/app/descriptors/func/vals.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/individuality.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';

class BattleBuff {
  List<BuffData> _passiveList = [];
  List<BuffData> _activeList = [];
  List<BuffData> commandCodeList = [];
  List<BuffData> auraBuffList = [];

  /// directly return origin instance, be aware if you want to modify in place
  List<BuffData> get originalPassiveList => _passiveList;
  List<BuffData> get originalActiveList => _activeList;

  List<BuffData> getPassiveList() => _passiveList.where((e) => e.checkAct()).toList();
  List<BuffData> getActiveList() => _activeList.where((e) => e.checkAct()).toList();
  List<BuffData> getCommandCodeList() => commandCodeList.where((e) => e.checkAct()).toList();

  List<BuffData> getAllBuffs() => [..._passiveList, ..._activeList, ...commandCodeList];

  // does any buffAction actually follow this passive first order?
  List<BuffData> get validBuffs => [...getPassiveList(), ...getActiveList(), ...getCommandCodeList()];
  List<BuffData> get validBuffsActiveFirst => [...getActiveList(), ...getPassiveList(), ...getCommandCodeList()];

  void setPassiveList(List<BuffData> list) => _passiveList = list;
  void setActiveList(List<BuffData> list) => _activeList = list;

  void addBuff(BuffData buff, {required bool isPassive}) {
    if (isPassive) {
      _passiveList.add(buff);
    } else {
      _activeList.add(buff);
    }
  }

  void checkUsedBuff() {
    _passiveList.removeWhere((buff) => buff.checkBuffClear());
    _activeList.removeWhere((buff) => buff.checkBuffClear());
  }

  List<BuffData> get shownBuffs => [
    ..._passiveList.where((buff) {
      final showState = buff.vals.ShowState ?? 0;
      if (showState == -1) return false;
      if (buff.vals.SetPassiveFrame == 1 || showState >= 1) return true;
      return false;
    }),
    ..._activeList.where((buff) {
      final showState = buff.vals.ShowState ?? 0;
      if (showState == -1) return false;
      return true;
    }),
  ];

  bool get isSelectable =>
      validBuffs.every((buff) => !buff.getTraits().map((trait) => trait.id).contains(Trait.cantBeSacrificed.value));

  void removeBuffWithTrait(final NiceTrait trait, {bool includeNoAct = false, bool includeNoField = false}) {
    _activeList.removeWhere(
      (buff) =>
          (includeNoAct || !buff.checkState(BuffState.noAct)) &&
          (includeNoField || !buff.checkState(BuffState.noField)) &&
          checkSignedIndividualities2(
            myTraits: buff.getTraits(),
            requiredTraits: [trait],
            positiveMatchFunc: partialMatch,
            negativeMatchFunc: partialMatch,
          ),
    );
  }

  void removeBuffOfType(final BuffType type, {bool includeNoAct = false, bool includeNoField = false}) {
    _activeList.removeWhere(
      (buff) =>
          (includeNoAct || !buff.checkState(BuffState.noAct)) &&
          (includeNoField || !buff.checkState(BuffState.noField)) &&
          buff.buff.type == type,
    );
  }

  void turnProgress() {
    for (final buff in getAllBuffs()) {
      if (!buff.checkField()) continue;
      buff.turnPass();
    }
  }

  void selfTurnPass() {
    for (final buff in validBuffs) {
      buff.turnPassParamAdd();
    }

    for (final buff in getAllBuffs()) {
      if (buff.intervalTurn > 0) {
        buff.intervalTurn -= 1;
      }
    }
  }

  void clearPassive(final int uniqueId) {
    _passiveList.removeWhere((buff) => buff.activatorUniqueId == uniqueId);
  }

  void clearClassPassive(final int uniqueId) {
    _passiveList.removeWhere(
      (buff) => buff.skillInfoType == SkillInfoType.svtClassPassive && buff.activatorUniqueId == uniqueId,
    );
  }

  BattleBuff copy() {
    final copy = BattleBuff()
      .._passiveList = _passiveList.map((e) => e.copy()).toList()
      .._activeList = _activeList.map((e) => e.copy()).toList()
      ..commandCodeList = commandCodeList.map((e) => e.copy()).toList()
      ..auraBuffList = auraBuffList.map((e) => e.copy()).toList();
    return copy;
  }
}

class BuffData {
  Buff buff;
  DataVals vals;
  int addOrder;

  int count = -1;
  int logicTurn = -1;
  int get dispTurn => logicTurn >= 0 ? (logicTurn + 1) ~/ 2 : logicTurn;
  int param = 0;
  int additionalParam = 0;
  NiceTd? tdTypeChange;
  List<int>? shortenMaxCountEachSkill;
  int intervalTurn = -1;

  bool checkBuffClear() => count == 0 || logicTurn == 0;

  int? ownerUniqueId;
  int? activatorUniqueId;
  String? activatorName;
  bool isUsed = false;

  bool passive = false;
  SkillInfoType? skillInfoType;
  bool get irremovable =>
      passive || vals.UnSubState == 1 || vals.IgnoreIndividuality == 1 || vals.UnSubStateWhileLinkedToOthers == 1;

  // ignore: unused_field
  // bool isDecide = false;
  // int userCommandCodeId = -1;
  // List<int> targetSkill = [];
  int _state = 0;
  // int auraEffectId = -1;
  // bool isActiveCC = false;

  bool get isOnField => vals.OnField == 1;

  BuffData({
    required this.buff,
    required this.vals,
    required this.addOrder,
    this.ownerUniqueId,
    this.activatorUniqueId,
    this.activatorName,
    this.passive = false,
    this.skillInfoType,
  }) {
    count = vals.Count ?? -1;
    logicTurn = vals.Turn == null ? -1 : vals.Turn! * 2;
    param = vals.Value ?? 0;
    additionalParam = vals.Value2 ?? 0;
  }

  static final List<BuffType> activeOnlyTypes = [
    BuffType.upDamageIndividualityActiveonly,
    BuffType.downDamageIndividualityActiveonly,
  ];

  List<NiceTrait> getTraits() {
    return [...buff.vals, ...vals.getAddIndividuality().map((indiv) => NiceTrait(id: indiv))];
  }

  int getValue(final BattleServantData self, [final BattleServantData? opponent, final BattleData? battleData]) {
    int addValue = 0;
    if (vals.ParamAddValue != null) {
      int addCount = 0;
      final selfIndiv = vals.ParamAddSelfIndividuality;
      final oppIndiv = vals.ParamAddOpIndividuality;
      final fieldIndiv = vals.ParamAddFieldIndividuality;
      if (selfIndiv != null) {
        final targetTraits = NiceTrait.list(selfIndiv);
        addCount += self.countTrait(targetTraits) + self.countBuffWithTrait(targetTraits);
      }
      if (oppIndiv != null && opponent != null) {
        final targetTraits = NiceTrait.list(oppIndiv);
        addCount += opponent.countTrait(targetTraits) + opponent.countBuffWithTrait(targetTraits);
      }
      if (fieldIndiv != null && battleData != null) {
        final targetTraits = NiceTrait.list(fieldIndiv);
        addCount += countAnyTraits(battleData.getQuestIndividuality(), targetTraits);
      }

      if (vals.ParamAddMaxCount != null) {
        addCount = min(addCount, vals.ParamAddMaxCount!);
      }

      addValue = addCount * vals.ParamAddValue!;

      if (vals.ParamAddMaxValue != null) {
        addValue = min(addValue, vals.ParamAddMaxValue!);
      }
    }

    int baseParam = param;
    if (vals.RatioHPLow != null || vals.RatioHPHigh != null) {
      final lowerBound = vals.RatioHPHigh ?? 0;
      final upperBound = vals.RatioHPLow ?? 0;
      final addition = upperBound - lowerBound;
      final maxHpRatio = vals.RatioHPRangeHigh ?? 1000;
      final minHpRatio = vals.RatioHPRangeLow ?? 0;
      final currentHpRatio = ((self.hp / self.maxHp) * 1000).toInt();

      final appliedBase = currentHpRatio > maxHpRatio ? 0 : lowerBound;
      final additionPercent = (maxHpRatio - currentHpRatio.clamp(minHpRatio, maxHpRatio)) / (maxHpRatio - minHpRatio);

      baseParam += appliedBase + (addition * additionPercent).toInt();
    }

    return baseParam + addValue;
  }

  bool shouldActivateBuffNoProbabilityCheck(
    List<NiceTrait> selfTraits, {
    List<NiceTrait>? opponentTraits,
    BattleData? battleData,
    SkillInfoType? skillInfoType,
    List<NiceFunction>? receivedFunctionsList,
    List<int>? triggeredSkillIds,
    Buff? buffToCheck,
  }) {
    if (!checkAct()) return false;
    if (!checkBuffDataVals(
      battleData: battleData,
      selfTraits: selfTraits,
      receivedFunctionsList: receivedFunctionsList,
      triggeredSkillIds: triggeredSkillIds,
    )) {
      return false;
    }
    if (!checkBuffScript(
      isFirstSkillInTurn: battleData?.isFirstSkillInTurn,
      selfTraits: selfTraits,
      opponentTraits: opponentTraits,
      skillInfoType: skillInfoType,
      buffToCheck: buffToCheck,
    )) {
      return false;
    }

    /// dw does not check self / op traits for svtTrait related types
    if (buff.type == BuffType.addIndividuality || buff.type == BuffType.subIndividuality) {
      return true;
    } else {
      final checkIndivType = buff.script.checkIndvType;
      if (checkIndivType == 1 || checkIndivType == 3) {
        return checkSignedIndividualities2(
              myTraits: selfTraits,
              requiredTraits: buff.ckSelfIndv,
              positiveMatchFunc: allMatch,
              negativeMatchFunc: allMatch,
            ) &&
            checkSignedIndividualities2(
              myTraits: opponentTraits ?? [],
              requiredTraits: buff.ckOpIndv,
              positiveMatchFunc: allMatch,
              negativeMatchFunc: allMatch,
            );
      } else if (checkIndivType == 4) {
        return checkSignedIndividualitiesPartialMatch(
              myTraits: selfTraits,
              requiredTraits: buff.ckSelfIndv,
              positiveMatchFunc: partialMatch,
              negativeMatchFunc: partialMatch,
            ) &&
            checkSignedIndividualitiesPartialMatch(
              myTraits: opponentTraits ?? [],
              requiredTraits: buff.ckOpIndv,
              positiveMatchFunc: partialMatch,
              negativeMatchFunc: partialMatch,
            );
      } else {
        // null, 0, 2
        return checkSignedIndividualities2(
              myTraits: selfTraits,
              requiredTraits: buff.ckSelfIndv,
              positiveMatchFunc: partialMatch,
              negativeMatchFunc: partialMatch,
            ) &&
            checkSignedIndividualities2(
              myTraits: opponentTraits ?? [],
              requiredTraits: buff.ckOpIndv,
              positiveMatchFunc: partialMatch,
              negativeMatchFunc: partialMatch,
            );
      }
    }
  }

  Future<bool> shouldActivateBuff(
    BattleData battleData,
    List<NiceTrait> selfTraits, {
    List<NiceTrait>? opponentTraits,
    SkillInfoType? skillInfoType,
    List<NiceFunction>? receivedFunctionsList,
    List<int>? triggeredSkillIds,
    Buff? buffToCheck,
  }) async {
    return shouldActivateBuffNoProbabilityCheck(
          selfTraits,
          battleData: battleData,
          opponentTraits: opponentTraits,
          skillInfoType: skillInfoType,
          receivedFunctionsList: receivedFunctionsList,
          triggeredSkillIds: triggeredSkillIds,
          buffToCheck: buffToCheck,
        ) &&
        await probabilityCheck(battleData, opponentTraits);
  }

  Future<bool> probabilityCheck(BattleData battleData, List<NiceTrait>? opponentTraits) async {
    if (vals.UseRate == null) return true;

    final owner = ownerUniqueId != null ? battleData.getServantData(ownerUniqueId!) : null;
    final finalUseRate = await owner?.applyChangeBuffUseRate(battleData, this, opponentTraits) ?? vals.UseRate!;
    final probabilityCheck = await battleData.canActivate(finalUseRate, buff.lName.l);

    if (finalUseRate < 1000) {
      battleData.battleLogger.debug(
        '${buff.lName.l}: ${probabilityCheck ? S.current.success : S.current.failed}'
        '${battleData.options.tailoredExecution ? '' : ' [$finalUseRate vs ${battleData.options.threshold}]'}',
      );
    }

    return probabilityCheck;
  }

  bool checkBuffDataVals({
    BattleData? battleData,
    List<NiceTrait>? selfTraits,
    List<NiceFunction>? receivedFunctionsList,
    final List<int>? triggeredSkillIds,
  }) {
    if (!(checkHpReduceToRegainIndiv(selfTraits) &&
        checkTargetFunctionIndividuality(receivedFunctionsList) &&
        checkSameIndivBuffActorOnField(battleData))) {
      return false;
    }

    if (vals.ApplyBuffIndividuality != null &&
        !Individuality.checkSignedMultiIndividuality(
          selfArray: selfTraits?.toIntList(),
          signedTargetsArray: vals.ApplyBuffIndividuality,
        )) {
      return false;
    }

    if (vals.ExecOnce == 1 && triggeredSkillIds != null && param != 0 && triggeredSkillIds.contains(param)) {
      return false;
    }
    return true;
  }

  bool checkSameIndivBuffActorOnField(BattleData? battleData) {
    final sameIndivBuffActorOnField = vals.SameIndivBuffActorOnField;
    if (sameIndivBuffActorOnField == null) return true;

    return battleData != null &&
        battleData.nonnullActors.firstWhereOrNull(
              (svt) => svt.getBuffTraits().any((trait) => trait.id == sameIndivBuffActorOnField),
            ) !=
            null;
  }

  bool checkHpReduceToRegainIndiv(final List<NiceTrait>? selfTraits) {
    final hpReduceToRegainIndiv = vals.HpReduceToRegainIndiv;
    return hpReduceToRegainIndiv == null ||
        checkSignedIndividualities2(
          myTraits: selfTraits ?? [],
          requiredTraits: [NiceTrait(id: hpReduceToRegainIndiv)],
        );
  }

  bool checkTargetFunctionIndividuality(final List<NiceFunction>? functions) {
    final targetFuncIndiv = vals.TargetFunctionIndividuality;
    final targetBuffIndiv = vals.TargetBuffIndividuality;
    if (targetFuncIndiv == null) {
      return true;
    }

    final requiredFuncTraits = targetFuncIndiv.map((traitId) => NiceTrait(id: traitId)).toList();
    final requiredBuffTraits = targetBuffIndiv?.map((traitId) => NiceTrait(id: traitId)).toList();
    for (final NiceFunction function in functions ?? []) {
      if (checkSignedIndividualities2(myTraits: function.getFuncIndividuality(), requiredTraits: requiredFuncTraits)) {
        if (requiredBuffTraits == null || !function.funcType.isAddState) {
          return true;
        }

        if (checkSignedIndividualities2(myTraits: function.buff?.vals ?? [], requiredTraits: requiredBuffTraits)) {
          return true;
        }
      }
    }

    return false;
  }

  bool checkBuffScript({
    bool? isFirstSkillInTurn,
    List<NiceTrait>? selfTraits,
    List<NiceTrait>? opponentTraits,
    SkillInfoType? skillInfoType,
    Buff? buffToCheck,
  }) {
    if (buff.script.source.isEmpty) {
      return true;
    }

    final script = buff.script;

    bool scriptCheck = true;
    if (script.UpBuffRateBuffIndiv != null) {
      scriptCheck &=
          selfTraits != null &&
          checkSignedIndividualities2(myTraits: selfTraits, requiredTraits: script.UpBuffRateBuffIndiv!);
    }

    if (script.useFirstTimeInTurn == 1) {
      scriptCheck &= isFirstSkillInTurn ?? false;
    }

    if (script.fromCommandSpell == 1) {
      scriptCheck &= skillInfoType == SkillInfoType.commandSpell;
    }

    if (script.fromMasterEquip == 1) {
      scriptCheck &= skillInfoType == SkillInfoType.masterEquip;
    }

    if (script.ckSelfCountIndividuality != null) {
      scriptCheck &= Individuality.checkSignedIndividualitiesCount(
        selfs: selfTraits?.toIntList(),
        targets: script.ckSelfCountIndividuality!,
        matchedFunc: Individuality.isPartialMatchArrayCount,
        mismatchFunc: Individuality.isPartialMatchArrayCount,
        countAbove: script.ckIndvCountAbove ?? 0,
        countBelow: script.ckIndvCountBelow ?? 0,
      );
    }

    if (script.ckOpCountIndividuality != null) {
      scriptCheck &= Individuality.checkSignedIndividualitiesCount(
        selfs: opponentTraits?.toIntList(),
        targets: script.ckOpCountIndividuality!,
        matchedFunc: Individuality.isPartialMatchArrayCount,
        mismatchFunc: Individuality.isPartialMatchArrayCount,
        countAbove: script.ckIndvCountAbove ?? 0,
        countBelow: script.ckIndvCountBelow ?? 0,
      );
    }

    if (script.convert != null && buffToCheck != null) {
      final convert = script.convert!;
      bool shouldConvert = false;
      switch (convert.convertType) {
        case BuffConvertType.none:
          break;
        case BuffConvertType.buff:
          for (final targetBuff in convert.targetBuffs) {
            shouldConvert = targetBuff.id == buffToCheck.id;
            break;
          }
          break;
        case BuffConvertType.individuality:
          for (final targetIndiv in convert.targetIndividualities) {
            shouldConvert = buff.vals.any((e) => e.signedId == targetIndiv.signedId);
            break;
          }
          break;
      }
      scriptCheck &= shouldConvert;
    }

    return scriptCheck;
  }

  bool canStack(final int buffGroup) {
    return buffGroup == 0 || buffGroup != buff.buffGroup;
  }

  void setUsed(final BattleServantData owner, [BattleData? battleData]) {
    isUsed = true;

    if (vals.BehaveAsFamilyBuff == 1 && vals.AddLinkageTargetIndividualty != null) {
      final targetIndividuality = vals.AddLinkageTargetIndividualty;
      for (final buff in owner.battleBuff.getAllBuffs()) {
        if (buff.vals.getAddIndividuality().contains(targetIndividuality) && buff.vals.BehaveAsFamilyBuff == 1) {
          buff.isUsed = true;
        }
      }
    }

    if (vals.IntervalTurn != null) {
      intervalTurn = vals.IntervalTurn!;
    }

    if (vals.SyncUsedSameIndivBuffActorOnField == 1 && vals.SameIndivBuffActorOnField != null && battleData != null) {
      final sameIndivBuffActorOnField = vals.SameIndivBuffActorOnField!;
      final sameIndivBuff = battleData.nonnullActors
          .expand((svt) => svt.battleBuff.validBuffs)
          .firstWhere((buff) => buff.getTraits().any((trait) => trait.id == sameIndivBuffActorOnField));
      sameIndivBuff.isUsed = true;
    }
  }

  void useOnce() {
    isUsed = false;
    if (count > 0) {
      count -= 1;
    }
  }

  void turnPassParamAdd() {
    if (vals.ParamAdd != null) {
      if (vals.ParamAddSelfIndividuality == null &&
          vals.ParamAddOpIndividuality == null &&
          vals.ParamAddFieldIndividuality == null) {
        param += vals.ParamAdd!;
        param = param.clamp(0, vals.ParamMax!);
      }
    }
  }

  void turnPass() {
    if (logicTurn > 0) {
      logicTurn -= 1;
    }
  }

  void updateActState(final BattleData battleData, final BattleServantData owner) {
    bool isAct = true;

    List<int> selfTraits() => [
      ...owner.getTraits(addTraits: owner.getBuffTraits()),
      ...battleData.getQuestIndividuality(),
    ].toIntList();

    if (buff.script.INDIVIDUALITIE_OR != null) {
      isAct &= Individuality.checkSignedIndividualitiesPartialMatch(
        selfs: selfTraits(),
        signedTargets: buff.script.INDIVIDUALITIE_OR?.toIntList(),
        matchedFunc: Individuality.isPartialMatchArray,
        mismatchFunc: Individuality.isPartialMatchArray,
      );
    }
    if (buff.script.INDIVIDUALITIE_AND != null) {
      isAct &= Individuality.checkSignedIndividualities2(
        self: selfTraits(),
        signedTarget: buff.script.INDIVIDUALITIE_AND?.toIntList(),
        matchedFunc: Individuality.isMatchArray,
        mismatchFunc: Individuality.isMatchArray,
      );
    }
    if (buff.script.INDIVIDUALITIE != null) {
      int countAbove = buff.script.INDIVIDUALITIE_COUNT_ABOVE ?? 0;
      int countBelow = buff.script.INDIVIDUALITIE_COUNT_BELOW ?? 0;
      List<int> signedTarget = [buff.script.INDIVIDUALITIE!.signedId];
      if (countAbove <= 0 && countBelow <= 0) {
        isAct &= Individuality.checkSignedIndividualities2(
          self: selfTraits(),
          signedTarget: signedTarget,
          matchedFunc: Individuality.isPartialMatchArray,
          mismatchFunc: Individuality.isPartialMatchArray,
        );
      } else {
        isAct &= Individuality.checkSignedIndividualitiesCount(
          selfs: selfTraits(),
          targets: signedTarget,
          matchedFunc: Individuality.isPartialMatchArrayCount,
          mismatchFunc: Individuality.isPartialMatchArrayCount,
          countAbove: countAbove,
          countBelow: countBelow,
        );
      }
    }

    // written based on Chen Gong np & passive. Right now only Chen Gong uses this
    if (vals.OnFieldCount == -1 && buff.script.TargetIndiv != null) {
      final List<BattleServantData> allies = owner.isPlayer ? battleData.nonnullPlayers : battleData.nonnullEnemies;
      final includeIgnoreIndividuality = buff.script.IncludeIgnoreIndividuality == 1;
      isAct &= allies
          .where(
            (svt) =>
                svt != owner &&
                checkSignedIndividualities2(
                  myTraits: svt.getTraits(addTraits: svt.getBuffTraits(includeIgnoreIndiv: includeIgnoreIndividuality)),
                  requiredTraits: [buff.script.TargetIndiv!],
                ),
          )
          .isEmpty;
    }

    if (buff.script.HP_HIGHER != null) {
      final int hpRatio = (owner.hp / owner.maxHp * 1000).toInt();
      isAct &= hpRatio >= buff.script.HP_HIGHER!;
    }

    if (buff.script.HP_LOWER != null) {
      final int hpRatio = (owner.hp / owner.maxHp * 1000).toInt();
      isAct &= hpRatio <= buff.script.HP_LOWER!;
    }

    isAct &= intervalTurn <= 0;

    if (isAct) {
      offState(BuffState.noAct);
    } else {
      onState(BuffState.noAct);
    }
    setState(BuffState.noAct, !isAct);

    bool isField = true;
    if (isOnField && activatorUniqueId != null) {
      isField &= battleData.isActorOnField(activatorUniqueId!);
    }
    setState(BuffState.noField, !isField);
  }

  String getParamString() {
    final List<String> effectString = [];
    ValDsc.describeBuff(effectString, buff, vals, inList: false, ignoreCount: true);
    return effectString.join(' ');
  }

  String durationString() {
    final List<String> durationString = [];
    if (count > 0) {
      durationString.add(Transl.special.funcValCountTimes(count));
    }
    if (logicTurn > 0) {
      durationString.add(Transl.special.funcValTurns(dispTurn));
    }
    if (durationString.isEmpty) {
      durationString.add(S.current.battle_buff_permanent);
    }

    return durationString.join(', ');
  }

  BuffData copy() {
    final BuffData copy =
        BuffData(
            buff: buff,
            vals: vals,
            addOrder: addOrder,
            activatorUniqueId: activatorUniqueId,
            activatorName: activatorName,
            ownerUniqueId: ownerUniqueId,
            passive: passive,
            skillInfoType: skillInfoType,
          )
          ..count = count
          ..logicTurn = logicTurn
          ..param = param
          ..additionalParam = additionalParam
          ..tdTypeChange = tdTypeChange
          ..shortenMaxCountEachSkill = shortenMaxCountEachSkill?.toList()
          ..intervalTurn = intervalTurn
          ..isUsed = isUsed
          .._state = _state;
    return copy;
  }

  // dw style
  void onState(BuffState state) => _state |= state.value;
  void offState(BuffState state) => _state &= ~state.value;
  void setState(BuffState state, bool v) => v ? onState(state) : offState(state);
  bool checkState(BuffState state) => _state & state.value > 0;

  bool checkAct() => !checkState(BuffState.noAct) && !checkState(BuffState.noField);
  bool checkField() => !checkState(BuffState.noField);
  bool checkProgressTurn() => !checkState(BuffState.cond) && logicTurn > 0;
  // skip command buff related...
  // bool isActiveCommandCode, isCommandCodeBuff, IsMineCommandCode
}

enum BuffState {
  noField(1),
  noAct(16),
  cond(32);

  const BuffState(this.value);
  final int value;
}
