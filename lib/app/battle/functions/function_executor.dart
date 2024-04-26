import 'package:chaldea/app/battle/functions/add_field_change_to_field.dart';
import 'package:chaldea/app/battle/functions/add_state.dart';
import 'package:chaldea/app/battle/functions/break_gauge_up.dart';
import 'package:chaldea/app/battle/functions/damage.dart';
import 'package:chaldea/app/battle/functions/damage_np_counter.dart';
import 'package:chaldea/app/battle/functions/gain_hp.dart';
import 'package:chaldea/app/battle/functions/gain_hp_from_targets.dart';
import 'package:chaldea/app/battle/functions/gain_np.dart';
import 'package:chaldea/app/battle/functions/gain_np_from_targets.dart';
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

  static Future<void> executeFunctions(
    final BattleData battleData,
    final List<NiceFunction> functions,
    final int skillLevel, {
    required final SkillScript? script,
    final int overchargeLvl = 1,
    final bool isPassive = false,
    final bool isClassPassive = false,
    final bool notActorFunction = false,
    final bool isCommandCode = false,
    final int? selectedActionIndex,
    final int? effectiveness,
    final bool defaultToPlayer = true,
    final BattleSkillParams? param,
  }) async {
    return await battleData.withFunctions(() async {
      Map<int, List<NiceFunction>> actSets = {};
      for (final func in functions) {
        if (!validateFunctionTargetTeam(func, battleData.activator?.isPlayer ?? defaultToPlayer)) continue;

        final dataVal = FunctionExecutor.getDataVals(func, skillLevel, overchargeLvl);
        if ((dataVal.ActSet ?? 0) != 0 && (dataVal.ActSetWeight ?? 0) > 0) {
          actSets.putIfAbsent(dataVal.ActSet!, () => []).add(func);
        }
      }
      int? selectedActSet;
      if (actSets.isNotEmpty) {
        if (battleData.delegate?.actWeight != null) {
          selectedActSet = await battleData.delegate!.actWeight!(battleData.activator);
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

        final updatedResult = await FunctionExecutor.executeFunction(
          battleData,
          func,
          index,
          skillLevel,
          overchargeLvl: overchargeLvl,
          shouldTrigger: !isDmgFuncType(functions.getOrNull(index - 1)?.funcType),
          shouldDamageRelease: !isDmgFuncType(functions.getOrNull(index + 1)?.funcType),
          isPassive: isPassive,
          isClassPassive: isClassPassive,
          notActorFunction: notActorFunction,
          isCommandCode: isCommandCode,
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
          final aSkillInfo = BattleSkillInfoData(askill, type: SkillInfoType.none, skillLv: askillLv);
          await aSkillInfo.activate(battleData);
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
    final int overchargeLvl = 1,
    final bool shouldTrigger = true,
    final bool shouldDamageRelease = true,
    final bool isPassive = false,
    final bool isClassPassive = false,
    final bool notActorFunction = false,
    final bool isCommandCode = false,
    final int? selectedActionIndex,
    final int? effectiveness,
    final bool defaultToPlayer = true,
  }) async {
    final BattleServantData? activator = battleData.activator;
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
            ? ' - ${S.current.battle_require_field_traits} ${function.funcquestTvals.map((e) => e.shownName())}'
            : '';
        final targetTraitString = function.functvals.isNotEmpty
            ? ' - ${S.current.battle_require_opponent_traits} ${function.functvals.map((e) => e.shownName())}'
            : '';
        battleData.battleLogger.function('${activator?.lBattleName ?? S.current.battle_no_source} - '
            '${function.lPopupText.l}'
            '$fieldTraitString'
            '$targetTraitString');
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

    if (effectiveness != null && effectiveness != 1000) {
      dataVals = updateDataValsWithEffectiveness(function, dataVals, effectiveness);
    }

    final List<BattleServantData> targets = await acquireFunctionTarget(
      battleData,
      function.funcTargetType,
      activator,
      funcId: function.funcId,
      defaultToPlayer: defaultToPlayer,
    );

    return await battleData.withFunction(() async {
      for (final target in targets) {
        battleData.setFuncResult(target.uniqueId, false);
      }

      final funcQuestTvalsMatch = battleData.checkTraits(CheckTraitParameters(
        requiredTraits: function.funcquestTvals,
        checkQuestTraits: true,
      ));

      if (!funcQuestTvalsMatch) {
        battleData.updateLastFuncResults(function.funcId, funcIndex);
        battleData.battleLogger.function('${S.current.battle_require_field_traits} ${S.current.failed}');
        return true;
      }

      if (dataVals.StarHigher != null && battleData.criticalStars < dataVals.StarHigher!) {
        battleData.updateLastFuncResults(function.funcId, funcIndex);
        battleData.battleLogger.function('${S.current.critical_star} ${battleData.criticalStars.toStringAsFixed(3)} < '
            '${dataVals.StarHigher}');
        return true;
      }

      if (!triggeredPositionCheck(battleData, dataVals) || !triggeredPositionAllCheck(battleData, dataVals)) {
        battleData.updateLastFuncResults(function.funcId, funcIndex);
        return true;
      }

      updateTargets(battleData, function, funcIndex, dataVals, targets);

      battleData.curFunc = function;
      switch (function.funcType) {
        case FuncType.absorbNpturn:
        case FuncType.gainNpFromTargets:
          await GainNpFromTargets.gainNpFromTargets(battleData, dataVals, targets);
          break;
        case FuncType.addState:
        case FuncType.addStateShort:
          await AddState.addState(
            battleData,
            function.buff!,
            function.funcId,
            dataVals,
            targets,
            isPassive: isPassive,
            isClassPassive: isClassPassive,
            isShortBuff: function.funcType == FuncType.addStateShort,
            isCommandCode: isCommandCode,
            notActorPassive: notActorFunction,
          );
          break;
        case FuncType.subState:
          await SubState.subState(battleData, function.traitVals, dataVals, targets);
          break;
        case FuncType.moveState:
          await MoveState.moveState(battleData, dataVals, targets);
          break;
        case FuncType.addFieldChangeToField:
          AddFieldChangeToField.addFieldChangeToField(battleData, function.buff!, dataVals, targets);
          break;
        case FuncType.gainNp:
        case FuncType.lossNp:
          GainNP.gainNP(battleData, dataVals, targets, isNegative: function.funcType == FuncType.lossNp);
          break;
        case FuncType.gainMultiplyNp:
        case FuncType.lossMultiplyNp:
          GainNP.gainMultiplyNP(battleData, dataVals, targets,
              isNegative: function.funcType == FuncType.lossMultiplyNp);
          break;
        case FuncType.gainNpIndividualSum:
        case FuncType.gainNpBuffIndividualSum:
          await GainNP.gainNpPerIndividual(
            battleData,
            dataVals,
            targets,
            targetTraits: function.traitVals,
            onlyCheckBuff: function.funcType == FuncType.gainNpBuffIndividualSum,
          );
          break;
        case FuncType.hastenNpturn:
        case FuncType.delayNpturn:
          HastenNpturn.hastenNpturn(battleData, dataVals, targets,
              isNegative: function.funcType == FuncType.delayNpturn);
          break;
        case FuncType.gainStar:
        case FuncType.lossStar:
          GainStar.gainStar(battleData, dataVals, targets: targets, isNegative: function.funcType == FuncType.lossStar);
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
        case FuncType.damageNpPierce:
        case FuncType.damageNpHpratioLow:
        case FuncType.damageNpHpratioHigh: // no real example yet
        case FuncType.damageNpRare:
        case FuncType.damageNpIndividualSum:
        case FuncType.damageNpStateIndividualFix:
          await Damage.damage(
            battleData,
            function,
            dataVals,
            targets,
            shouldTrigger: shouldTrigger,
            shouldDamageRelease: shouldDamageRelease,
          );
          break;
        case FuncType.instantDeath:
        case FuncType.forceInstantDeath:
          await InstantDeath.instantDeath(
            battleData,
            dataVals,
            targets,
            force: function.funcType == FuncType.forceInstantDeath,
            defaultToPlayer: defaultToPlayer,
          );
          break;
        case FuncType.gainHp:
        case FuncType.gainHpPer:
        case FuncType.lossHp:
        case FuncType.lossHpSafe:
        case FuncType.lossHpPer:
        case FuncType.lossHpPerSafe:
          await GainHP.gainHP(battleData, dataVals, targets, function.funcType);
          break;
        case FuncType.gainHpFromTargets:
          await GainHpFromTargets.gainHpFromTargets(battleData, dataVals, targets);
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
            svt.battleBuff.removeBuffWithTrait(NiceTrait(id: Trait.buffLockCardsDeck.id));
          }
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
        case FuncType.updateEnemyEntryMaxCountEachTurn:
        case FuncType.damageValue:
        case FuncType.damageValueSafe:
        case FuncType.damageNpSafe:
        case FuncType.gainMultiplyNp:
        case FuncType.lossMultiplyNp:
        // ↑↑↑ should be implemented ↑↑↑
        case FuncType.subFieldBuff:
        case FuncType.damageNpAndCheckIndividuality:
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
          battleData.battleLogger.debug('${S.current.not_implemented}: ${function.funcType}, '
              'Function ID: ${function.funcId}, '
              'Activator: ${activator?.lBattleName}');
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
        case FuncType.damageValueSafeOnce:
        case FuncType.addBattleValue:
        case FuncType.setBattleValue:
          battleData.battleLogger.debug('${S.current.skip}: ${function.funcType}, '
              'Function ID: ${function.funcId}, '
              'Activator: ${activator?.lBattleName}');
          break;
      }

      battleData.updateLastFuncResults(function.funcId, funcIndex);
      battleData.checkActorStatus();
      return true;
    });
  }

  static bool validateFunctionTargetTeam(
    final BaseFunction function,
    final bool isPlayer,
  ) {
    return function.funcTargetTeam == FuncApplyTarget.playerAndEnemy ||
        (function.canBePlayerFunc && isPlayer) ||
        (function.canBeEnemyFunc && !isPlayer);
  }

  static DataVals getDataVals(
    final NiceFunction function,
    final int skillLevel,
    int overchargeLevel,
  ) {
    if (overchargeLevel > function.svalsList.length) {
      overchargeLevel = function.svalsList.length;
    }
    return (function.svalsList.getOrNull(overchargeLevel - 1) ?? function.svals).getOrNull(skillLevel - 1) ??
        DataVals();
  }

  static DataVals updateDataValsWithEffectiveness(
    final NiceFunction function,
    final DataVals dataVals,
    final int effectiveness,
  ) {
    if (dataVals.Value == null || effectiveness == 1000 || dataVals.IgnoreValueUp == 1) {
      return dataVals;
    }

    final funcDetail = ConstData.funcTypeDetail[function.funcType.id];
    if (funcDetail != null && funcDetail.ignoreValueUp) {
      return dataVals;
    }

    final buffDetail = ConstData.buffTypeDetail[function.buff?.type.id];
    if (buffDetail != null && buffDetail.ignoreValueUp) {
      return dataVals;
    }

    final dataJson = dataVals.toJson();
    dataJson['Value'] = (dataVals.Value! * toModifier(effectiveness)).toInt();
    return DataVals.fromJson(dataJson);
  }

  static Future<List<BattleServantData>> acquireFunctionTarget(
    final BattleData battleData,
    final FuncTargetType funcTargetType,
    final BattleServantData? activator, {
    final int? funcId,
    final bool defaultToPlayer = true,
  }) async {
    final List<BattleServantData> targets = [];

    final isAlly = activator?.isPlayer ?? defaultToPlayer;
    final List<BattleServantData> backupAllies =
        isAlly ? battleData.nonnullBackupPlayers : battleData.nonnullBackupEnemies;
    final List<BattleServantData> aliveAllies = isAlly ? battleData.nonnullPlayers : battleData.nonnullEnemies;
    final BattleServantData? targetedAlly = isAlly
        ? battleData.target?.isPlayer == true
            ? battleData.target
            : battleData.targetedPlayer
        : battleData.target?.isEnemy == true
            ? battleData.target
            : battleData.targetedEnemy;

    final List<BattleServantData> backupEnemies =
        isAlly ? battleData.nonnullBackupEnemies : battleData.nonnullBackupPlayers;
    final List<BattleServantData> aliveEnemies = isAlly ? battleData.nonnullEnemies : battleData.nonnullPlayers;
    final BattleServantData? targetedEnemy = isAlly
        ? battleData.target?.isEnemy == true
            ? battleData.target
            : battleData.targetedEnemy
        : battleData.target?.isPlayer == true
            ? battleData.target
            : battleData.targetedPlayer;

    switch (funcTargetType) {
      case FuncTargetType.self:
      case FuncTargetType.commandTypeSelfTreasureDevice:
        if (activator != null) {
          targets.add(activator);
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
        final firstOtherSelectable = aliveAllies.firstWhereOrNull((svt) => svt != activator && svt.selectable);
        if (firstOtherSelectable != null) {
          targets.add(firstOtherSelectable);
        }
        break;
      case FuncTargetType.ptSelfAnotherLast:
        final lastOtherSelectable = aliveAllies.lastWhereOrNull((svt) => svt != activator && svt.selectable);
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
        break;
      case FuncTargetType.enemyOneNoTargetNoAction:
        if (activator != null) {
          final target = battleData.getServantData(activator.getRevengeTargetUniqueId(), onFieldOnly: true);
          if (target != null) {
            targets.add(target);
          }
        }
        break;
      // random target: set minCount=0 to enable skip
      case FuncTargetType.ptRandom:
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
        }
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
        battleData.battleLogger.debug('${S.current.not_implemented}: $funcTargetType, '
            'Function ID: $funcId, '
            'Activator: ${activator?.lBattleName}');
        break;
    }

    return targets;
  }

  static bool triggeredPositionCheck(
    final BattleData battleData,
    final DataVals dataVals,
  ) {
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

  static bool triggeredPositionAllCheck(
    final BattleData battleData,
    final DataVals dataVals,
  ) {
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

  static void updateTargets(
    final BattleData battleData,
    final NiceFunction function,
    final int funcIndex,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) {
    final checkDead = dataVals.CheckDead != null && dataVals.CheckDead! > 0;
    targets.retainWhere((svt) => svt.isAlive(battleData) || checkDead);

    final List<List<NiceTrait>> overwriteTvals = function.getOverwriteTvalsList();
    if (overwriteTvals.isNotEmpty) {
      targets.retainWhere((svt) {
        for (final List<NiceTrait> requiredTraits in overwriteTvals) {
          // Currently assuming the first array is OR. Need more samples on this
          if (battleData.checkTraits(CheckTraitParameters(
            requiredTraits: requiredTraits,
            actor: svt,
            checkActorTraits: true,
            checkActorBuffTraits: true,
            checkActiveBuffOnly: dataVals.IncludePassiveIndividuality != 1,
            positiveMatchFunction: allMatch,
            negativeMatchFunction: allMatch,
          ))) {
            return true;
          }
        }
        return false;
      });
    } else {
      targets.retainWhere((svt) => battleData.checkTraits(CheckTraitParameters(
            requiredTraits: function.functvals,
            actor: svt,
            checkActorTraits: true,
            checkActorBuffTraits: true,
            checkActiveBuffOnly: dataVals.IncludePassiveIndividuality != 1,
          )));
    }

    final triggeredHpRateRange = dataVals.TriggeredTargetHpRateRange;
    if (triggeredHpRateRange != null && RegExp(r'(^<\d+$|^\d+<$)').hasMatch(triggeredHpRateRange)) {
      final lessThan = triggeredHpRateRange.startsWith('<');
      final hpRateRange = int.parse(triggeredHpRateRange.replaceAll('<', ''));

      targets.retainWhere((svt) {
        final svtHpRate = (svt.hp / svt.maxHp * 1000).toInt();

        if (lessThan) {
          return svtHpRate < hpRateRange;
        } else {
          return svtHpRate > hpRateRange;
        }
      });
    }

    targets.retainWhere((target) => triggeredPositionTargetCheck(battleData, dataVals, target));

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

  static bool isDmgFuncType(final FuncType? nextFuncType) {
    if (nextFuncType == null) {
      return false;
    }

    switch (nextFuncType) {
      case FuncType.damage:
      case FuncType.damageNp:
      case FuncType.damageNpHpratioLow:
      case FuncType.damageNpHpratioHigh:
      case FuncType.damageNpIndividual:
      case FuncType.damageNpIndividualSum:
      case FuncType.damageNpPierce:
      case FuncType.damageNpRare:
      case FuncType.damageNpStateIndividual:
      case FuncType.damageNpStateIndividualFix:
        return true;
      default:
        return false;
    }
  }
}
