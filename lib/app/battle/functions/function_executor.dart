import 'dart:math' show min;

import 'package:chaldea/app/battle/functions/add_battle_point.dart';
import 'package:chaldea/app/battle/functions/add_field_change_to_field.dart';
import 'package:chaldea/app/battle/functions/add_state.dart';
import 'package:chaldea/app/battle/functions/break_gauge_up.dart';
import 'package:chaldea/app/battle/functions/damage.dart';
import 'package:chaldea/app/battle/functions/damage_np_counter.dart';
import 'package:chaldea/app/battle/functions/gain_hp.dart';
import 'package:chaldea/app/battle/functions/gain_hp_from_targets.dart';
import 'package:chaldea/app/battle/functions/gain_np.dart';
import 'package:chaldea/app/battle/functions/gain_np_from_targets.dart';
import 'package:chaldea/app/battle/functions/gain_np_target_sum.dart';
import 'package:chaldea/app/battle/functions/gain_star.dart';
import 'package:chaldea/app/battle/functions/hasten_npturn.dart';
import 'package:chaldea/app/battle/functions/instant_death.dart';
import 'package:chaldea/app/battle/functions/move_state.dart';
import 'package:chaldea/app/battle/functions/replace_member.dart';
import 'package:chaldea/app/battle/functions/skill_charge_turn.dart';
import 'package:chaldea/app/battle/functions/sub_state.dart';
import 'package:chaldea/app/battle/functions/transform_servant.dart';
import 'package:chaldea/app/battle/functions/update_entry_positions.dart';
import 'package:chaldea/app/battle/interactions/choose_targets.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/gamedata/individuality.dart';
import 'package:chaldea/utils/extension.dart';
import '../../api/atlas.dart';
import '../interactions/act_set_select.dart';
import '../utils/battle_logger.dart';
import 'buff_turn_count.dart';
import 'call_servant.dart';
import 'move_to_last_sub_member.dart';
import 'shift_servant.dart';

class FunctionExecutor {
  FunctionExecutor._();

  static Future<void> executeCustomSkill({
    required BattleData battleData,
    required int skillId,
    BattleServantData? activator,
    BattleServantData? target,
    int? skillLv,
  }) async {
    BaseSkill? skill = db.gameData.baseSkills[skillId];
    skill ??= await showEasyLoading(() => AtlasApi.skill(skillId), mask: true);
    final actSkillLv = skillLv ?? 1;
    if (skill != null) {
      await FunctionExecutor.executeFunctions(
        battleData,
        skill.functions,
        actSkillLv.clamp(1, skill.maxLv),
        script: skill.script,
        activator: activator,
        targetedAlly: battleData.getTargetedAlly(activator),
        targetedEnemy: target,
        skillType: skill.type,
        skillInfoType: null,
      );
    }
  }

  static Future<void> executeFunctions(
    final BattleData battleData,
    final List<NiceFunction> functions,
    final int skillLevel, {
    final SkillScript? script,
    final BattleServantData? activator,
    final BattleServantData? targetedAlly,
    final BattleServantData? targetedEnemy,
    final CommandCardData? card,
    final int overchargeLvl = 1,
    final int? overchargeState,
    final List<int>? ignoreBattlePoints,
    final SkillType? skillType,
    final SkillInfoType? skillInfoType,
    final int? selectedActionIndex,
    final int? effectiveness,
    final bool defaultToPlayer = true,
    final BattleSkillParams? param,
    final bool isTransform = false,
  }) async {
    await battleData.withFunctions(() async {
      Map<int, List<NiceFunction>> actSets = {};
      for (final func in functions) {
        if (!validateFunctionTargetTeam(func, activator?.isPlayer ?? defaultToPlayer)) continue;

        final dataVal = FunctionExecutor.getDataVals(func, skillLevel, overchargeLvl);
        if ((dataVal.ActSet ?? 0) != 0 && (dataVal.ActSetWeight ?? 0) > 0) {
          actSets.putIfAbsent(dataVal.ActSet!, () => []).add(func);
        }
      }
      int? selectedActSet;
      if (actSets.isNotEmpty) {
        if (battleData.delegate?.actWeight != null) {
          selectedActSet = await battleData.delegate!.actWeight!(activator);
        } else if (battleData.mounted) {
          selectedActSet = await FuncActSetSelector.show(battleData, actSets);
          battleData.replayDataRecord.actWeightSelections.add(selectedActSet);
          if (selectedActSet != null && selectedActSet > 0) {
            battleData.recorder.reasons.setUpload("ActSetWeight: Must skip random effects");
          }
        }
      }
      param?.actSet = selectedActSet;
      for (int index = 0; index < functions.length; index += 1) {
        if (battleData.checkDuplicateFuncData[index] == null) {
          battleData.checkDuplicateFuncData[index] = {};
        }
        NiceFunction func = functions[index];
        final dataVal = FunctionExecutor.getDataVals(func, skillLevel, overchargeLvl);
        if ((dataVal.ActSet ?? 0) != 0 && dataVal.ActSet != selectedActSet) {
          battleData.functionResults.add(null);
          continue;
        }
        final actMasterGenderType = dataVal.ActMasterGenderType ?? 0;
        if (actMasterGenderType != 0) {
          if (!(db.curUser.isGirl ? actMasterGenderType == 2 : actMasterGenderType == 1)) {
            continue;
          }
        }
        if (isTransform && dataVal.NotExecOnTransform == 1) {
          continue;
        }

        final updatedResult = await FunctionExecutor.executeFunction(
          battleData,
          func,
          index,
          skillLevel,
          script: script,
          activator: activator,
          targetedAlly: targetedAlly,
          targetedEnemy: targetedEnemy,
          card: card,
          overchargeLvl: overchargeLvl,
          overchargeState: overchargeState,
          ignoreBattlePoints: ignoreBattlePoints,
          shouldTrigger: !isDmgFuncType(functions.getOrNull(index - 1)?.funcType),
          shouldDamageRelease: !isDmgFuncType(functions.getOrNull(index + 1)?.funcType),
          skillType: skillType,
          skillInfoType: skillInfoType,
          selectedActionIndex: selectedActionIndex,
          effectiveness: effectiveness,
          defaultToPlayer: defaultToPlayer,
        );
        if (!updatedResult) {
          battleData.functionResults.add(null);
        }
      }
      if (script != null && script.additionalSkillId != null) {
        final askillId = script.additionalSkillId!.getOrNull(skillLevel - 1);
        final askillLv = script.additionalSkillLv?.getOrNull(skillLevel - 1) ?? 1;
        if (askillId != null && askillId != 0) {
          final askill =
              db.gameData.baseSkills[askillId] ?? await showEasyLoading(() => AtlasApi.skill(askillId), mask: true);
          final aSkillInfo = BattleSkillInfoData(askill, type: SkillInfoType.skillAdditional, skillLv: askillLv);
          await aSkillInfo.activate(battleData, activator: activator);
        }
      }
    });
  }

  /// Return value is whether the uniqueIdToFuncResultMap is updated or not
  static Future<bool> executeFunction(
    final BattleData battleData,
    final NiceFunction function,
    final int funcIndex,
    final int skillLevel, {
    final SkillScript? script,
    final BattleServantData? activator,
    final BattleServantData? targetedAlly,
    final BattleServantData? targetedEnemy,
    final CommandCardData? card,
    final int overchargeLvl = 1,
    final int? overchargeState,
    final List<int>? ignoreBattlePoints,
    final bool shouldTrigger = true,
    final bool shouldDamageRelease = true,
    final SkillType? skillType,
    final SkillInfoType? skillInfoType,
    final int? selectedActionIndex,
    final int? effectiveness,
    final bool defaultToPlayer = true,
  }) async {
    if (!validateFunctionTargetTeam(function, activator?.isPlayer ?? defaultToPlayer)) {
      return false;
    }

    switch (function.funcType) {
      case FuncType.servantFriendshipUp:
      case FuncType.eventDropUp:
      case FuncType.eventPointUp:
      case FuncType.none:
        return false;
      default:
        final fieldTraitString = function.funcquestTvals.isNotEmpty
            ? ' - ${S.current.battle_require_field_traits} ${function.funcquestTvals.map(Transl.traitName)}'
            : '';
        final targetTraitString = function.functvals.isNotEmpty
            ? ' - ${S.current.battle_require_opponent_traits} ${function.functvals.map(Transl.traitName)}'
            : '';
        battleData.battleLogger.function(
          '${activator?.lBattleName ?? S.current.battle_no_source} - '
          '${function.lPopupText.l}'
          '$fieldTraitString'
          '$targetTraitString',
        );
        break;
    }

    DataVals dataVals = getDataVals(function, skillLevel, overchargeLvl);
    if (dataVals.ActSelectIndex != null && dataVals.ActSelectIndex != selectedActionIndex) {
      return false;
    }

    final requiredEventId = dataVals.EventId ?? 0;
    if (requiredEventId != 0 && requiredEventId != battleData.eventId) {
      return false;
    }

    if (activator != null) {
      dataVals = updateDataValsForActivatorConds(dataVals, activator);
    }
    if (effectiveness != null && effectiveness != 1000) {
      dataVals = updateDataValsWithEffectiveness(function, script, dataVals, effectiveness);
    }

    final List<BattleServantData> targets = await acquireFunctionTarget(
      battleData,
      function.funcTargetType,
      activator,
      targetedAlly: targetedAlly,
      targetedEnemy: targetedEnemy,
      funcId: function.funcId,
      defaultToPlayer: defaultToPlayer,
      dataVals: dataVals,
    );

    return await battleData.withFunction(() async {
      for (final target in targets) {
        battleData.setFuncResult(target.uniqueId, false);
      }

      final funcQuestTvalsMatch = checkSignedIndividualities2(
        myTraits: battleData.getQuestIndividuality(),
        requiredTraits: function.funcquestTvals,
      );

      if (!funcQuestTvalsMatch) {
        battleData.updateLastFuncResults(function.funcId, funcIndex);
        battleData.battleLogger.function('${S.current.battle_require_field_traits} ${S.current.failed}');
        return true;
      }

      if (dataVals.StarHigher != null && battleData.criticalStars < dataVals.StarHigher!) {
        battleData.updateLastFuncResults(function.funcId, funcIndex);
        battleData.battleLogger.function(
          '${S.current.critical_star} ${battleData.criticalStars.toStringAsFixed(3)} < '
          '${dataVals.StarHigher}',
        );
        return true;
      }

      // not in updateTargets because these end execution immediately
      if (!triggeredPositionCheck(battleData, dataVals) ||
          !triggeredPositionAllCheck(battleData, dataVals) ||
          !triggeredFieldCountCheck(battleData, dataVals, activator?.isPlayer ?? defaultToPlayer)) {
        battleData.updateLastFuncResults(function.funcId, funcIndex);
        return true;
      }

      final specialFuncTargetCheck = await funcCheckTargetIndividualityTargetType(
        battleData,
        function,
        dataVals,
        activator,
        targetedAlly,
        targetedEnemy,
        defaultToPlayer,
      );
      if (!specialFuncTargetCheck) {
        battleData.updateLastFuncResults(function.funcId, funcIndex);
        return true;
      }

      final hasAvoidFunctionExecuteSelf =
          await activator?.hasBuff(
            battleData,
            BuffAction.avoidFunctionExecuteSelf,
            addTraits: function.getFuncIndividuality(),
          ) ??
          false;
      if (hasAvoidFunctionExecuteSelf) {
        battleData.updateLastFuncResults(function.funcId, funcIndex);
        return true;
      }

      updateTargets(battleData, function, funcIndex, dataVals, targets);

      battleData.curFunc = function;
      switch (function.funcType) {
        case FuncType.absorbNpturn:
        case FuncType.gainNpFromTargets:
          await GainNpFromTargets.gainNpFromTargets(battleData, dataVals, activator!, targetedAlly, targetedEnemy);
          break;
        case FuncType.addState:
        case FuncType.addStateShort:
          await AddState.addState(
            battleData,
            function.buff!,
            function.funcId,
            dataVals,
            activator,
            targets,
            isShortBuff: function.funcType == FuncType.addStateShort,
            selectTreasureDeviceInfo: script?.selectTreasureDeviceInfo?.getOrNull(skillLevel - 1),
            skillType: skillType,
            skillInfoType: skillInfoType,
          );
          break;
        case FuncType.subState:
          await SubState.subState(battleData, function.vals, dataVals, activator, targets);
          break;
        case FuncType.moveState:
          await MoveState.moveState(battleData, dataVals, activator!, targetedAlly, targetedEnemy);
          break;
        case FuncType.addFieldChangeToField:
          AddFieldChangeToField.addFieldChangeToField(battleData, function.buff!, dataVals, activator, targets);
          break;
        case FuncType.gainNp:
        case FuncType.lossNp:
          GainNp.gainNp(battleData, dataVals, targets, isNegative: function.funcType == FuncType.lossNp);
          break;
        case FuncType.gainMultiplyNp:
        case FuncType.lossMultiplyNp:
          final isNegative = function.funcType == FuncType.lossMultiplyNp;
          GainNp.gainMultiplyNp(battleData, dataVals, targets, isNegative: isNegative);
          break;
        case FuncType.gainNpIndividualSum:
          GainNp.gainNpPerIndividual(battleData, dataVals, activator, targets, function.vals);
          break;
        case FuncType.gainNpBuffIndividualSum:
          GainNp.gainNpPerBuffIndividual(battleData, dataVals, targets, function.vals);
          break;
        case FuncType.gainNpTargetSum:
          GainNpTargetSum.gainNpTargetSum(battleData, dataVals, targets, function.vals);
          break;
        case FuncType.gainNpCriticalstarSum:
          GainNp.gainNpCriticalStarSum(battleData, dataVals, targets);
          break;
        case FuncType.hastenNpturn:
        case FuncType.delayNpturn:
          final isNegative = function.funcType == FuncType.delayNpturn;
          await HastenNpturn.hastenNpturn(battleData, dataVals, activator, targets, isNegative: isNegative);
          break;
        case FuncType.gainStar:
        case FuncType.lossStar:
          final isNegative = function.funcType == FuncType.lossStar;
          GainStar.gainStar(battleData, dataVals, activator, targets: targets, isNegative: isNegative);
          break;
        case FuncType.shortenSkill:
          SkillChargeTurn.shortenSkill(battleData, dataVals, targets);
          break;
        case FuncType.extendSkill:
          SkillChargeTurn.extendSkill(battleData, dataVals, targets);
          break;
        case FuncType.shortenUserEquipSkill:
          SkillChargeTurn.updateUserEquipSkillChargeTurn(battleData, dataVals, true);
          break;
        case FuncType.extendUserEquipSkill:
          SkillChargeTurn.updateUserEquipSkillChargeTurn(battleData, dataVals, false);
          break;
        case FuncType.damage:
        case FuncType.damageNp:
        case FuncType.damageNpIndividual:
        case FuncType.damageNpAndOrCheckIndividuality:
        case FuncType.damageNpPierce:
        case FuncType.damageNpHpratioLow:
        case FuncType.damageNpHpratioHigh: // no real example yet
        case FuncType.damageNpRare:
        case FuncType.damageNpIndividualSum:
        case FuncType.damageNpStateIndividualFix:
        case FuncType.damageNpBattlePointPhase:
        case FuncType.damageNpSafe:
          await Damage.damage(
            battleData,
            function,
            dataVals,
            activator!,
            targets,
            card!,
            shouldTrigger: shouldTrigger,
            shouldDamageRelease: shouldDamageRelease,
          );
          break;
        case FuncType.instantDeath:
        case FuncType.forceInstantDeath:
          await InstantDeath.instantDeath(
            battleData,
            dataVals,
            function,
            activator,
            targets,
            defaultToPlayer: defaultToPlayer,
            card: card,
          );
          break;
        case FuncType.gainHp:
        case FuncType.gainHpPer:
          await GainHP.gainHP(battleData, dataVals, activator, targets, function.funcType);
          break;
        case FuncType.lossHp:
        case FuncType.lossHpSafe:
        case FuncType.lossHpPer:
        case FuncType.lossHpPerSafe:
          await GainHP.lossHP(battleData, dataVals, activator, targets, function.funcType);
          break;
        case FuncType.damageValue:
        case FuncType.damageValueSafe:
          await GainHP.damageValue(battleData, dataVals, activator, targets, function.funcType);
          break;
        case FuncType.gainHpFromTargets:
          await GainHpFromTargets.gainHpFromTargets(battleData, dataVals, activator!, targetedAlly, targetedEnemy);
          break;
        case FuncType.transformServant:
          await TransformServant.transformServant(battleData, dataVals, targets);
          break;
        case FuncType.shiftServant:
          await ShiftServant.skillShift(battleData, dataVals, targets);
          break;
        case FuncType.changeServant:
          await ShiftServant.changeServant(battleData, dataVals, activator);
          break;
        case FuncType.callServant:
          await CallServant.callServant(battleData, dataVals, activator);
          break;
        case FuncType.moveToLastSubmember:
          MoveToLastSubMember.moveToLastSubMember(battleData, dataVals, targets);
          break;
        case FuncType.replaceMember:
          await ReplaceMember.replaceMember(battleData, dataVals);
          break;
        case FuncType.cardReset:
          for (final svt in battleData.nonnullPlayers) {
            svt.battleBuff.removeBuffOfType(BuffType.fixCommandcard);
          }
          battleData.refillCardDeck();
          for (final target in targets) {
            battleData.setFuncResult(target.uniqueId, true);
          }
          break;
        case FuncType.fixCommandcard:
        case FuncType.displayBuffstring:
          // do nothing
          for (final target in targets) {
            battleData.setFuncResult(target.uniqueId, true);
          }
          break;
        case FuncType.shortenBuffturn:
        case FuncType.extendBuffturn:
        case FuncType.shortenBuffcount:
        case FuncType.extendBuffcount:
          BuffTurnCount.changeBuffValue(battleData, function.funcType, dataVals, targets);
          break;
        case FuncType.updateEntryPositions:
          UpdateEntryPositions.updateEntryPositions(battleData, dataVals);
          break;
        case FuncType.breakGaugeUp:
        case FuncType.breakGaugeDown:
          await BreakGaugeUp.breakGaugeUp(battleData, function.funcType, dataVals, targets);
          break;
        case FuncType.damageNpCounter:
          DamageNpCounter.damageNpCounter(battleData, dataVals, activator, targets);
          break;
        case FuncType.addBattlePoint:
          AddBattlePoint.addBattlePoint(battleData, dataVals, targets, overchargeState, ignoreBattlePoints);
          break;
        case FuncType.updateEnemyEntryMaxCountEachTurn:
        case FuncType.swapFieldPosition:
        case FuncType.addStateToField:
        case FuncType.addStateShortToField:
        // ↑↑↑ should be implemented ↑↑↑
        case FuncType.damageValueSafeOnce:
        case FuncType.subFieldBuff:
        case FuncType.damageNpStateIndividual:
        case FuncType.releaseState:
        case FuncType.ptShuffle:
        case FuncType.changeBg:
        case FuncType.withdraw:
        case FuncType.resurrection:
        case FuncType.quickChangeBg:
        case FuncType.overwriteDeadType:
        case FuncType.forceAllBuffNoact:
        case FuncType.movePosition:
        case FuncType.revival:
        case FuncType.changeBgmCostume:
        case FuncType.lossCommandSpell:
        case FuncType.gainCommandSpell:
        case FuncType.lastUsePlayerSkillCopy:
        case FuncType.setNpExecutedState:
        case FuncType.hideOverGauge:
        case FuncType.generateBattleSkillDrop:
          battleData.battleLogger.debug(
            '${S.current.not_implemented}: ${function.funcType}, '
            'Function ID: ${function.funcId}, '
            'Activator: ${activator?.lBattleName}',
          );
          break;
        case FuncType.unknown:
        case FuncType.none:
        case FuncType.changeBgm:
        case FuncType.expUp:
        case FuncType.qpUp:
        case FuncType.dropUp:
        case FuncType.friendPointUp:
        case FuncType.eventDropUp:
        case FuncType.eventDropRateUp:
        case FuncType.eventPointUp:
        case FuncType.eventPointRateUp:
        case FuncType.qpDropUp:
        case FuncType.servantFriendshipUp:
        case FuncType.userEquipExpUp:
        case FuncType.classDropUp:
        case FuncType.enemyEncountCopyRateUp:
        case FuncType.enemyEncountRateUp:
        case FuncType.enemyProbDown:
        case FuncType.getRewardGift:
        case FuncType.sendSupportFriendPoint:
        case FuncType.friendPointUpDuplicate:
        case FuncType.buddyPointUp:
        case FuncType.eventFortificationPointUp:
        case FuncType.setQuestRouteFlag:
        case FuncType.setSystemAliveFlag:
        case FuncType.changeEnemyMasterFace:
        case FuncType.addBattleValue:
        case FuncType.setBattleValue:
        case FuncType.enemyCountChange:
        case FuncType.displayBattleMessage:
        case FuncType.setDisplayDirectBattleMessageInFsm:
          battleData.battleLogger.debug(
            '${S.current.skip}: ${function.funcType}, '
            'Function ID: ${function.funcId}, '
            'Activator: ${activator?.lBattleName}',
          );
          break;
        case FuncType.changeMasterFace:
        case FuncType.enableMasterSkill:
        case FuncType.enableMasterCommandSpell:
        case FuncType.battleModelChange:
        case FuncType.addBattleMissionValue:
        case FuncType.setBattleMissionValue:
        case FuncType.changeEnemyStatusUiType:
      }

      for (final target in targets) {
        if (battleData.getCurFuncResult(target.uniqueId) == true) {
          target.receivedFunctionsList.add(function);
        }
      }
      battleData.updateLastFuncResults(function.funcId, funcIndex);
      battleData.checkActorStatus();

      return true;
    });
  }

  static bool validateFunctionTargetTeam(final BaseFunction function, final bool isPlayer) {
    return function.funcTargetTeam == FuncApplyTarget.all ||
        (function.canBePlayerFunc && isPlayer) ||
        (function.canBeEnemyFunc && !isPlayer);
  }

  static DataVals getDataVals(final NiceFunction function, final int skillLevel, int overchargeLevel) {
    if (overchargeLevel > function.svalsList.length) {
      overchargeLevel = function.svalsList.length;
    }
    return (function.svalsList.getOrNull(overchargeLevel - 1) ?? function.svals).getOrNull(skillLevel - 1) ??
        DataVals();
  }

  static DataVals updateDataValsWithEffectiveness(
    final NiceFunction function,
    final SkillScript? script,
    final DataVals dataVals,
    final int effectiveness,
  ) {
    if (dataVals.Value == null ||
        effectiveness == 1000 ||
        dataVals.IgnoreValueUp == 1 ||
        script?.IgnoreValueUp == true) {
      return dataVals;
    }

    final funcDetail = ConstData.funcTypeDetail[function.funcType.value];
    if (!function.funcType.isAddState && funcDetail != null && funcDetail.ignoreValueUp) {
      return dataVals;
    }

    final buffDetail = ConstData.buffTypeDetail[function.buff?.type.value];
    if (function.funcType.isAddState && buffDetail != null && buffDetail.ignoreValueUp) {
      return dataVals;
    }

    final dataJson = dataVals.toJson();
    dataJson['Value'] = (dataVals.Value! * toModifier(effectiveness)).toInt();
    return DataVals.fromJson(dataJson);
  }

  static DataVals updateDataValsForActivatorConds(final DataVals dataVals, final BattleServantData activator) {
    if (dataVals.Value == null) {
      return dataVals;
    }

    final dataJson = dataVals.toJson();
    int condParamRangeType = dataVals.CondParamRangeType ?? 0;
    if (condParamRangeType != 0 && activator.isPlayer) {
      final List<int> condParamRangeTargetId = dataVals.CondParamRangeTargetId ?? [];
      final int maxCount = dataVals.CondParamRangeMaxCount ?? 0, maxValue = dataVals.CondParamRangeMaxValue ?? 0;
      if (maxCount > 0) {
        int count =
            activator.playerSvtData?.classBoardData.getClassStatVal(condParamRangeType, condParamRangeTargetId) ?? 0;
        count = min(count, maxCount);
        dataJson['Value'] += (count / maxCount * maxValue).floor();
      }
    }

    int condParamAddType = dataVals.CondParamAddType ?? 0;
    if (condParamAddType != 0 && activator.isPlayer) {
      final List<int> condParamAddTargetId = dataVals.CondParamAddTargetId ?? [];
      final int condParamAddValue = dataVals.CondParamAddValue ?? 0;
      final int? maxValue = dataVals.CondParamAddMaxValue;
      int count = activator.playerSvtData?.classBoardData.getClassStatVal(condParamAddType, condParamAddTargetId) ?? 0;
      int _value = condParamAddValue * count;
      if (maxValue != null) {
        _value = min(_value, maxValue);
      }
      dataJson['Value'] += _value;
    }
    return DataVals.fromJson(dataJson);
  }

  static Future<List<BattleServantData>> acquireFunctionTarget(
    final BattleData battleData,
    final FuncTargetType funcTargetType,
    final BattleServantData? activator, {
    final int? funcId,
    final BattleServantData? targetedAlly,
    final BattleServantData? targetedEnemy,
    final DataVals? dataVals,
    final bool defaultToPlayer = true,
  }) async {
    final isAlly = activator?.isPlayer ?? defaultToPlayer;
    final List<BattleServantData> aliveAllies = isAlly ? battleData.nonnullPlayers : battleData.nonnullEnemies;
    final List<BattleServantData> targets = acquireSimpleFunctionTarget(
      battleData,
      funcTargetType,
      activator,
      funcId: funcId,
      dataVals: dataVals,
      targetedAlly: targetedAlly,
      targetedEnemy: targetedEnemy,
      defaultToPlayer: defaultToPlayer,
    ).toList();
    if (funcTargetType == FuncTargetType.ptRandom) {
      if (battleData.delegate?.ptRandom != null) {
        final selected = await battleData.delegate!.ptRandom!.call(aliveAllies);
        if (selected != null) {
          targets.add(selected);
        }
      } else if (aliveAllies.isNotEmpty && battleData.mounted) {
        final selectedSvts = await ChooseTargetsDialog.show(
          battleData,
          targetType: funcTargetType,
          targets: aliveAllies,
          maxCount: 1,
          minCount: 0,
        );
        if (selectedSvts != null) {
          final selectedSvt = selectedSvts.firstOrNull;
          if (selectedSvt != null) {
            targets.add(selectedSvt);
            battleData.replayDataRecord.ptRandomIndexes.add(aliveAllies.indexOf(selectedSvt));
          } else {
            battleData.replayDataRecord.ptRandomIndexes.add(null);
          }
        }
        return targets;
      }
    }

    return targets;
  }

  static List<BattleServantData> acquireSimpleFunctionTarget(
    final BattleData battleData,
    final FuncTargetType funcTargetType,
    final BattleServantData? activator, {
    final int? funcId,
    final BattleServantData? targetedAlly,
    final BattleServantData? targetedEnemy,
    final DataVals? dataVals,
    final bool defaultToPlayer = true,
  }) {
    final List<BattleServantData> targets = [];

    final isAlly = activator?.isPlayer ?? defaultToPlayer;
    final List<BattleServantData> backupAllies = isAlly
        ? battleData.nonnullBackupPlayers
        : battleData.nonnullBackupEnemies;
    final List<BattleServantData> aliveAllies = isAlly ? battleData.nonnullPlayers : battleData.nonnullEnemies;

    final List<BattleServantData> backupEnemies = isAlly
        ? battleData.nonnullBackupEnemies
        : battleData.nonnullBackupPlayers;
    final List<BattleServantData> aliveEnemies = isAlly ? battleData.nonnullEnemies : battleData.nonnullPlayers;

    switch (funcTargetType) {
      case FuncTargetType.self:
      case FuncTargetType.commandTypeSelfTreasureDevice:
        if (activator != null) {
          targets.add(activator);
        } else if (aliveAllies.isNotEmpty) {
          targets.add(aliveAllies.first);
        }
        break;
      case FuncTargetType.ptOne:
        if (targetedAlly != null) {
          targets.add(targetedAlly);
        }
        break;
      case FuncTargetType.enemy:
        if (targetedEnemy != null) {
          targets.add(targetedEnemy);
        }
        break;
      case FuncTargetType.ptAll:
        targets.addAll(aliveAllies);
        break;
      case FuncTargetType.enemyAll:
        targets.addAll(aliveEnemies);
        break;
      case FuncTargetType.ptFull:
        targets.addAll(aliveAllies);
        targets.addAll(backupAllies);
        break;
      case FuncTargetType.enemyFull:
        targets.addAll(aliveEnemies);
        targets.addAll(backupEnemies);
        break;
      case FuncTargetType.ptOther:
        targets.addAll(aliveAllies);
        targets.remove(activator);
        break;
      case FuncTargetType.ptOneOther:
        targets.addAll(aliveAllies);
        targets.remove(targetedAlly);
        break;
      case FuncTargetType.enemyOther:
        targets.addAll(aliveEnemies);
        targets.remove(targetedEnemy);
        break;
      case FuncTargetType.ptOtherFull:
        targets.addAll(aliveAllies);
        targets.addAll(backupAllies);
        targets.remove(activator);
        break;
      case FuncTargetType.enemyOtherFull:
        targets.addAll(aliveEnemies);
        targets.addAll(backupEnemies);
        targets.remove(targetedEnemy);
        break;
      case FuncTargetType.fieldOther:
        targets.addAll(aliveAllies);
        targets.addAll(aliveEnemies);
        targets.remove(activator);
        break;
      case FuncTargetType.ptSelfAnotherFirst:
        final firstOtherSelectable = aliveAllies.firstWhereOrNull((svt) {
          final targetIndiv = dataVals?.TargetIndiv;
          final includeIgnoredIndiv = dataVals?.IncludeIgnoreIndividuality == 1;
          final targetIndivCheck =
              targetIndiv == null ||
              checkSignedIndividualities2(
                myTraits: svt.getTraits(addTraits: svt.getBuffTraits(includeIgnoreIndiv: includeIgnoredIndiv)),
                requiredTraits: [targetIndiv],
              );
          return svt != activator && targetIndivCheck;
        });
        if (firstOtherSelectable != null) {
          targets.add(firstOtherSelectable);
        }
        break;
      case FuncTargetType.ptSelfAnotherLast:
        final lastOtherSelectable = aliveAllies.lastWhereOrNull((svt) {
          final targetIndiv = dataVals?.TargetIndiv;
          final includeIgnoredIndiv = dataVals?.IncludeIgnoreIndividuality == 1;
          final targetIndivCheck =
              targetIndiv == null ||
              checkSignedIndividualities2(
                myTraits: svt.getTraits(addTraits: svt.getBuffTraits(includeIgnoreIndiv: includeIgnoredIndiv)),
                requiredTraits: [targetIndiv],
              );
          return svt != activator && targetIndivCheck;
        });
        if (lastOtherSelectable != null) {
          targets.add(lastOtherSelectable);
        }
        break;
      case FuncTargetType.ptOneHpLowestValue:
        if (aliveAllies.isEmpty) {
          break;
        }

        BattleServantData hpLowestValue = aliveAllies.first;
        for (final svt in aliveAllies) {
          if (svt.hp < hpLowestValue.hp) {
            hpLowestValue = svt;
          }
        }
        targets.add(hpLowestValue);
        break;
      case FuncTargetType.ptOneHpLowestRate:
        if (aliveAllies.isEmpty) {
          break;
        }

        BattleServantData hpLowestRate = aliveAllies.first;
        for (final svt in aliveAllies) {
          if (svt.hp / svt.maxHp < hpLowestRate.hp / hpLowestRate.maxHp) {
            hpLowestRate = svt;
          }
        }
        targets.add(hpLowestRate);
        break;
      case FuncTargetType.ptselectSub:
        if (activator != null) {
          targets.add(activator);
        } else if (aliveAllies.isNotEmpty) {
          targets.add(aliveAllies.first);
        }
        break;
      case FuncTargetType.ptselectOneSub: //  used by replace member
      case FuncTargetType.ptRandom: // not handled in simple
        break;
      case FuncTargetType.enemyOneNoTargetNoAction:
        if (activator != null) {
          final target = battleData.getServantData(activator.getRevengeTargetUniqueId(), onFieldOnly: true);
          if (target != null) {
            targets.add(target);
          }
        }
        break;
      case FuncTargetType.fieldAll:
        targets.addAll(aliveAllies);
        targets.addAll(aliveEnemies);
        break;
      case FuncTargetType.ptAnother:
      case FuncTargetType.enemyAnother:
      case FuncTargetType.ptSelfBefore:
      case FuncTargetType.ptSelfAfter:
      case FuncTargetType.enemyRandom:
      case FuncTargetType.ptOneAnotherRandom:
      case FuncTargetType.ptSelfAnotherRandom:
      case FuncTargetType.enemyOneAnotherRandom:
      case FuncTargetType.enemyRange:
      case FuncTargetType.handCommandcardRandomOne:
      case FuncTargetType.noTarget:
      case FuncTargetType.fieldRandom:
        battleData.battleLogger.error(
          '${S.current.not_implemented}: $funcTargetType, '
          'Function ID: $funcId, '
          'Activator: ${activator?.lBattleName}',
        );
        break;
    }

    return targets;
  }

  static bool triggeredPositionCheck(final BattleData battleData, final DataVals dataVals) {
    final triggeredFuncPosition = dataVals.TriggeredFuncPosition;
    if (triggeredFuncPosition == null || triggeredFuncPosition == 0) {
      return true;
    }

    final results = battleData.functionResults.getOrNull(triggeredFuncPosition.abs() - 1);
    if (triggeredFuncPosition > 0) {
      // any true
      if (results == null) return false;
      if (results.isEmpty) return false;
      return results.containsValue(true);
    } else if (triggeredFuncPosition < 0) {
      // any false
      if (results == null) return true;
      if (results.isEmpty) return true;
      return results.containsValue(false);
    }

    return false;
  }

  static bool triggeredPositionAllCheck(final BattleData battleData, final DataVals dataVals) {
    final triggeredFuncPositionAll = dataVals.TriggeredFuncPositionAll;
    if (triggeredFuncPositionAll == null || triggeredFuncPositionAll == 0) {
      return true;
    }

    final results = battleData.functionResults.getOrNull(triggeredFuncPositionAll.abs() - 1);
    if (triggeredFuncPositionAll > 0) {
      // all true
      if (results == null) return false;
      if (results.isEmpty) return false;
      return !results.containsValue(false);
    } else if (triggeredFuncPositionAll < 0) {
      // all false
      if (results == null) return true;
      if (results.isEmpty) return true;
      return !results.containsValue(true);
    }
    return true;
  }

  static bool triggeredPositionTargetCheck(
    final BattleData battleData,
    final DataVals dataVals,
    final BattleServantData target,
  ) {
    final triggeredFuncPositionSameTarget = dataVals.TriggeredFuncPositionSameTarget;
    if (triggeredFuncPositionSameTarget == null || triggeredFuncPositionSameTarget == 0) {
      return true;
    }

    final results = battleData.functionResults.getOrNull(triggeredFuncPositionSameTarget.abs() - 1);
    final last = (results?[target.uniqueId] ?? false);
    if (triggeredFuncPositionSameTarget > 0) {
      // last true
      return last;
    } else if (triggeredFuncPositionSameTarget < 0) {
      // last false
      return !last;
    }

    return false;
  }

  static bool triggeredFieldCountCheck(BattleData battleData, DataVals dataVals, bool isPlayer) {
    final triggeredFieldCountTarget = dataVals.TriggeredFieldCountTarget;
    final triggeredFieldCountRange = dataVals.TriggeredFieldCountRange;
    if (triggeredFieldCountRange == null || triggeredFieldCountTarget == null) return true;

    final allies = isPlayer ? battleData.nonnullPlayers : battleData.nonnullEnemies;
    final enemies = isPlayer ? battleData.nonnullEnemies : battleData.nonnullPlayers;
    final List<BattleServantData> targets = [];
    if (triggeredFieldCountTarget == TriggeredFieldCountTarget.ally.value) {
      targets.addAll(allies);
    } else if (triggeredFieldCountTarget == TriggeredFieldCountTarget.enemy.value) {
      targets.addAll(enemies);
    } else if (triggeredFieldCountTarget == TriggeredFieldCountTarget.all.value) {
      targets.addAll(allies);
      targets.addAll(enemies);
    }

    return DataVals.isSatisfyRangeText(targets.length, rangeText: triggeredFieldCountRange, forceEqual: true);
  }

  static Future<bool> funcCheckTargetIndividualityTargetType(
    BattleData battleData,
    NiceFunction function,
    DataVals dataVals,
    BattleServantData? activator,
    BattleServantData? targetedAlly,
    BattleServantData? targetedEnemy,
    bool defaultToPlayer,
  ) async {
    final targetTypeInt = dataVals.FuncCheckTargetIndividualityTargetType;
    if (targetTypeInt == null) return true;
    final traitTargets = await acquireFunctionTarget(
      battleData,
      FuncTargetType.fromId(targetTypeInt)!,
      activator,
      targetedAlly: targetedAlly,
      targetedEnemy: targetedEnemy,
      funcId: function.funcId,
      defaultToPlayer: defaultToPlayer,
      dataVals: dataVals,
    );

    final activeOnly = dataVals.IncludePassiveIndividuality != 1;
    final includeIgnoreIndividuality = dataVals.IncludeIgnoreIndividuality == 1;
    final excludeUnsubstate = dataVals.ExcludeUnSubStateIndiv == 1;
    final List<int> selfTraits = [];
    for (final svt in traitTargets) {
      selfTraits.addAll(
        svt.getTraits(
          addTraits: svt.getBuffTraits(
            activeOnly: activeOnly,
            includeIgnoreIndiv: includeIgnoreIndividuality,
            ignoreIndivUnreleaseable: excludeUnsubstate,
          ),
        ),
      );
    }
    int countAbove = 0, countBelow = 0;
    if (dataVals.FuncCheckTargetIndividualityCountEqual != null) {
      countAbove = countBelow = dataVals.FuncCheckTargetIndividualityCountEqual!;
    } else if (dataVals.FuncCheckTargetIndividualityCountHigher != null) {
      countAbove = dataVals.FuncCheckTargetIndividualityCountHigher!;
    } else if (dataVals.FuncCheckTargetIndividualityCountLower != null) {
      countBelow = dataVals.FuncCheckTargetIndividualityCountLower!;
    } else {
      return Individuality.checkSignedIndividualities2(
        self: selfTraits,
        signedTarget: function.functvals,
        matchedFunc: Individuality.isMatchArray,
        mismatchFunc: Individuality.isMatchArray,
      );
    }

    return Individuality.checkSignedIndividualitiesCount(
      selfs: selfTraits,
      targets: function.functvals,
      matchedFunc: Individuality.isMatchArrayCount,
      mismatchFunc: Individuality.isMatchArrayCount,
      countAbove: countAbove,
      countBelow: countBelow,
    );
  }

  static void updateTargets(
    final BattleData battleData,
    final NiceFunction function,
    final int funcIndex,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) {
    final checkDead = dataVals.CheckDead != null && dataVals.CheckDead! > 0;
    targets.retainWhere((svt) => svt.isAlive(battleData, function: function) || checkDead);

    final List<List<int>> overwriteTvals = function.getOverwriteTvalsList();
    final activeOnly = dataVals.IncludePassiveIndividuality != 1;
    final includeIgnoreIndividuality = dataVals.IncludeIgnoreIndividuality == 1;
    final excludeUnsubstate = dataVals.ExcludeUnSubStateIndiv == 1;

    // update base on traits
    if (overwriteTvals.isNotEmpty) {
      targets.retainWhere((svt) {
        final List<int> selfTraits = svt.getTraits(
          addTraits: svt.getBuffTraits(
            activeOnly: activeOnly,
            includeIgnoreIndiv: includeIgnoreIndividuality,
            ignoreIndivUnreleaseable: excludeUnsubstate,
          ),
        );
        for (final List<int> requiredTraits in overwriteTvals) {
          // Currently assuming the first array is OR. Need more samples on this
          final checkTrait = checkSignedIndividualities2(
            myTraits: selfTraits,
            requiredTraits: requiredTraits,
            positiveMatchFunc: allMatch,
            negativeMatchFunc: allMatch,
          );
          if (checkTrait) {
            return true;
          }
        }
        return false;
      });
    } else if (dataVals.FuncCheckTargetIndividualityTargetType == null) {
      targets.retainWhere(
        (svt) => checkSignedIndividualities2(
          myTraits: svt.getTraits(
            addTraits: svt.getBuffTraits(
              activeOnly: activeOnly,
              includeIgnoreIndiv: includeIgnoreIndividuality,
              ignoreIndivUnreleaseable: excludeUnsubstate,
            ),
          ),
          requiredTraits: function.functvals,
        ),
      );
    } // else checked in funcCheckTargetIndividualityTargetType

    if (dataVals.TriggeredTargetHpRange != null || dataVals.TriggeredTargetHpRateRange != null) {
      targets.retainWhere((svt) {
        if (dataVals.TriggeredTargetHpRange != null &&
            !DataVals.isSatisfyRangeText(svt.hp, ranges: dataVals.TriggeredTargetHpRange)) {
          return false;
        }
        final svtHpRate = (svt.hp / svt.maxHp * 1000).toInt();
        if (dataVals.TriggeredTargetHpRateRange != null &&
            !DataVals.isSatisfyRangeText(svtHpRate, ranges: dataVals.TriggeredTargetHpRateRange)) {
          return false;
        }
        return true;
      });
    }

    targets.retainWhere((target) => triggeredPositionTargetCheck(battleData, dataVals, target));

    targets.retainWhere((target) => battlePointCheck(dataVals, target));

    if (dataVals.CheckDuplicate == 1) {
      final Map<int, bool>? previousExecutionResults = battleData.checkDuplicateFuncData[funcIndex]?[function.funcId];
      if (previousExecutionResults != null) {
        for (final svt in targets) {
          final previousResult = previousExecutionResults[svt.uniqueId];
          if (previousResult != null) {
            battleData.setFuncResult(svt.uniqueId, previousResult);
          }
        }
        targets.retainWhere((svt) => previousExecutionResults[svt.uniqueId] == false);
      }
    }
  }

  static bool battlePointCheck(final DataVals dataVals, final BattleServantData target) {
    final checkBattlePointPhaseRanges = dataVals.CheckBattlePointPhaseRange ?? [];
    for (final phaseRange in checkBattlePointPhaseRanges) {
      final curPhase = target.determineBattlePointPhase(phaseRange.battlePointId);
      if (!DataVals.isSatisfyRangeText(curPhase, ranges: phaseRange.range)) {
        return false;
      }
    }
    return true;
  }

  static bool isDmgFuncType(final FuncType? nextFuncType) {
    if (nextFuncType == null) {
      return false;
    }
    if (nextFuncType.isDamageNp) return true;
    if ({
      FuncType.damage,
      FuncType.damageValue,
      FuncType.damageValueSafe,
      FuncType.damageValueSafeOnce,
    }.contains(nextFuncType)) {
      return true;
    }
    return false;
  }
}
