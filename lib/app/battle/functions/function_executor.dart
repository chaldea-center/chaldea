import 'package:chaldea/app/battle/functions/add_field_change_to_field.dart';
import 'package:chaldea/app/battle/functions/add_state.dart';
import 'package:chaldea/app/battle/functions/damage.dart';
import 'package:chaldea/app/battle/functions/gain_hp.dart';
import 'package:chaldea/app/battle/functions/gain_hp_from_targets.dart';
import 'package:chaldea/app/battle/functions/gain_np.dart';
import 'package:chaldea/app/battle/functions/gain_np_from_targets.dart';
import 'package:chaldea/app/battle/functions/gain_star.dart';
import 'package:chaldea/app/battle/functions/hasten_npturn.dart';
import 'package:chaldea/app/battle/functions/instant_death.dart';
import 'package:chaldea/app/battle/functions/move_state.dart';
import 'package:chaldea/app/battle/functions/replace_member.dart';
import 'package:chaldea/app/battle/functions/shorten_skill.dart';
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
import '../interactions/act_set_select.dart';
import '../interactions/td_type_change_selector.dart';
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
    final int overchargeLvl = 1,
    final bool isPassive = false,
    final bool notActorFunction = false,
    final bool isCommandCode = false,
    final int? selectedActionIndex,
    final int? effectiveness,
    final bool defaultToPlayer = true,
  }) async {
    await battleData.withFunctions(() async {
      Map<int, List<NiceFunction>> actSets = {};
      for (final func in functions) {
        if (!validateFunctionTargetTeam(func, battleData.activator?.isPlayer ?? defaultToPlayer)) continue;

        final dataVal = FunctionExecutor.getDataVals(func, skillLevel, overchargeLvl);
        if ((dataVal.ActSet ?? 0) != 0 && (dataVal.ActSetWeight ?? 0) > 0) {
          actSets.putIfAbsent(dataVal.ActSet!, () => []).add(func);
        }
      }
      int? selectedActSet;
      if (battleData.delegate?.actWeight != null) {
        selectedActSet = await battleData.delegate!.actWeight!(battleData.activator);
      } else if (actSets.isNotEmpty && battleData.mounted) {
        selectedActSet = await FuncActSetSelector.show(battleData, actSets);
        battleData.replayDataRecord.actWeightSelections.add(selectedActSet);
      }
      for (int index = 0; index < functions.length; index += 1) {
        NiceFunction func = functions[index];
        final dataVal = FunctionExecutor.getDataVals(func, skillLevel, overchargeLvl);
        if ((dataVal.ActSet ?? 0) != 0 && dataVal.ActSet != selectedActSet) {
          battleData.uniqueIdToFuncResultsList.add(null);
          continue;
        }

        final updatedResult = await FunctionExecutor.executeFunction(
          battleData,
          func,
          skillLevel,
          overchargeLvl: overchargeLvl,
          shouldTrigger: !isDmgFuncType(functions.getOrNull(index - 1)?.funcType),
          shouldDamageRelease: !isDmgFuncType(functions.getOrNull(index + 1)?.funcType),
          isPassive: isPassive,
          notActorFunction: notActorFunction,
          isCommandCode: isCommandCode,
          selectedActionIndex: selectedActionIndex,
          effectiveness: effectiveness,
          defaultToPlayer: defaultToPlayer,
        );
        if (!updatedResult) {
          battleData.uniqueIdToFuncResultsList.add(null);
        }
      }
    });
  }

  /// Return value is whether the uniqueIdToFuncResultMap is updated or not
  static Future<bool> executeFunction(
    final BattleData battleData,
    final NiceFunction function,
    final int skillLevel, {
    final int overchargeLvl = 1,
    final bool shouldTrigger = true,
    final bool shouldDamageRelease = true,
    final bool isPassive = false,
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

    if (effectiveness != null) {
      dataVals = updateDataValsWithEffectiveness(function, dataVals, effectiveness);
    }

    final funcQuestTvalsMatch = battleData.checkTraits(CheckTraitParameters(
      requiredTraits: function.funcquestTvals,
      checkQuestTraits: true,
    ));

    final List<BattleServantData> targets = await acquireFunctionTarget(
      battleData,
      function.funcTargetType,
      activator,
      funcId: function.funcId,
      defaultToPlayer: defaultToPlayer,
    );

    return await battleData.withFunction(() async {
      for (final target in targets) {
        battleData.curFuncResults[target.uniqueId] = false;
      }

      if (!funcQuestTvalsMatch) {
        battleData.updateLastFuncResults(function.funcId);
        battleData.battleLogger.function('${S.current.battle_require_field_traits} ${S.current.failed}');
        return true;
      }

      if (dataVals.StarHigher != null && battleData.criticalStars < dataVals.StarHigher!) {
        battleData.updateLastFuncResults(function.funcId);
        battleData.battleLogger.function('${S.current.critical_star} ${battleData.criticalStars.toStringAsFixed(3)} < '
            '${dataVals.StarHigher}');
        return true;
      }

      if (!triggeredPositionCheck(battleData, dataVals) || !triggeredPositionAllCheck(battleData, dataVals)) {
        battleData.updateLastFuncResults(function.funcId);
        return true;
      }

      updateTargets(battleData, function, dataVals, targets);

      List<NiceTd?> tdSelections = [];
      if (function.funcTargetType == FuncTargetType.commandTypeSelfTreasureDevice) {
        for (final svt in targets) {
          NiceTd? tdSelection;
          final NiceTd? baseTd = svt.playerSvtData?.td;
          if (baseTd != null) {
            if (baseTd.script != null && baseTd.script!.tdTypeChangeIDs != null) {
              final List<NiceTd> tds = svt.getTdsById(baseTd.script!.tdTypeChangeIDs!);
              if (tds.isNotEmpty) {
                if (battleData.delegate?.tdTypeChange != null) {
                  tdSelection = await battleData.delegate!.tdTypeChange!(activator, tds);
                } else if (battleData.mounted) {
                  tdSelection = await TdTypeChangeSelector.show(battleData, tds);
                  if (tdSelection != null) {
                    battleData.replayDataRecord.tdTypeChangeIndexes.add(tds.indexOf(tdSelection));
                  }
                }
              }
            }
          }
          tdSelections.add(tdSelection);
        }
      }

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
            tdSelections: tdSelections,
            isPassive: isPassive,
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
          ShortenSkill.shortenSkill(battleData, dataVals, targets);
          break;
        case FuncType.extendSkill:
          ShortenSkill.extendSkill(battleData, dataVals, targets);
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
          battleData.nonnullAllies.forEach((svt) {
            svt.removeBuffWithTrait(NiceTrait(id: Trait.buffLockCardsDeck.id));
          });
          for (final target in targets) {
            battleData.curFuncResults[target.uniqueId] = true;
          }
          break;
        case FuncType.fixCommandcard:
        case FuncType.displayBuffstring:
          // do nothing
          for (final target in targets) {
            battleData.curFuncResults[target.uniqueId] = true;
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
        case FuncType.updateEnemyEntryMaxCountEachTurn:
        // TODO: unimplemented FuncTypes
        case FuncType.damageValue:
        case FuncType.damageNpCounter:
        case FuncType.damageValueSafe:
        case FuncType.damageNpSafe:
        // ↑↑↑ should be implemented ↑↑↑
        case FuncType.shortenUserEquipSkill:
        case FuncType.extendUserEquipSkill:
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
        case FuncType.breakGaugeUp:
        case FuncType.breakGaugeDown:
        case FuncType.movePosition:
        case FuncType.revival:
        case FuncType.changeBgmCostume:
        case FuncType.func126:
        case FuncType.func127:
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
          battleData.battleLogger.debug('${S.current.skip}: ${function.funcType}, '
              'Function ID: ${function.funcId}, '
              'Activator: ${activator?.lBattleName}');
          break;
      }

      battleData.updateLastFuncResults(function.funcId);
      battleData.checkActorStatus();
      return true;
    });
  }

  static bool validateFunctionTargetTeam(
    final BaseFunction function,
    final bool isPlayer,
  ) {
    return function.funcTargetTeam == FuncApplyTarget.playerAndEnemy ||
        (function.isPlayerOnlyFunc && isPlayer) ||
        (function.isEnemyOnlyFunc && !isPlayer);
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
    if (dataVals.Value == null || effectiveness == 1000) {
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
        isAlly ? battleData.nonnullBackupAllies : battleData.nonnullBackupEnemies;
    final List<BattleServantData> aliveAllies = isAlly ? battleData.nonnullAllies : battleData.nonnullEnemies;
    final BattleServantData? targetedAlly = isAlly
        ? battleData.target?.isPlayer == true
            ? battleData.target
            : battleData.targetedAlly
        : battleData.target?.isEnemy == true
            ? battleData.target
            : battleData.targetedEnemy;

    final List<BattleServantData> backupEnemies =
        isAlly ? battleData.nonnullBackupEnemies : battleData.nonnullBackupAllies;
    final List<BattleServantData> aliveEnemies = isAlly ? battleData.nonnullEnemies : battleData.nonnullAllies;
    final BattleServantData? targetedEnemy = isAlly
        ? battleData.target?.isEnemy == true
            ? battleData.target
            : battleData.targetedEnemy
        : battleData.target?.isPlayer == true
            ? battleData.target
            : battleData.targetedAlly;

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
          if (svt.hp / svt.getMaxHp(battleData) < hpLowestRate.hp / hpLowestRate.getMaxHp(battleData)) {
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
        if (activator != null && activator.lastHitBy != null) {
          targets.add(activator.lastHitBy!);
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
    if (triggeredFuncPosition == null) {
      return true;
    }

    final results = battleData.uniqueIdToFuncResultsList.getOrNull(triggeredFuncPosition.abs() - 1);
    if (triggeredFuncPosition > 0) {
      if (results == null) {
        return false;
      } else {
        for (final result in results.values) {
          if (result) {
            return true;
          }
        }
      }
    } else if (triggeredFuncPosition < 0) {
      if (results != null) {
        for (final result in results.values) {
          if (!result) {
            return true;
          }
        }
      }
    }

    return false;
  }

  static bool triggeredPositionAllCheck(
    final BattleData battleData,
    final DataVals dataVals,
  ) {
    final triggeredFuncPositionAll = dataVals.TriggeredFuncPositionAll;
    if (triggeredFuncPositionAll == null) {
      return true;
    }

    final results = battleData.uniqueIdToFuncResultsList.getOrNull(triggeredFuncPositionAll.abs() - 1);
    if (triggeredFuncPositionAll > 0) {
      if (results == null) {
        return false;
      } else {
        for (final result in results.values) {
          if (!result) {
            return false;
          }
        }
      }
    } else if (triggeredFuncPositionAll < 0) {
      if (results != null) {
        for (final result in results.values) {
          if (result) {
            return false;
          }
        }
      }
    }
    return true;
  }

  static void updateTargets(
    final BattleData battleData,
    final NiceFunction function,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) {
    final checkDead = dataVals.CheckDead != null && dataVals.CheckDead! > 0;
    targets.retainWhere((svt) =>
        (svt.isAlive(battleData) || checkDead) &&
        battleData.checkTraits(CheckTraitParameters(
          requiredTraits: function.functvals,
          actor: svt,
          checkActorTraits: true,
          checkActorBuffTraits: true,
          checkActiveBuffOnly: dataVals.IncludePassiveIndividuality != 1,
        )));

    final triggeredHpRateRange = dataVals.TriggeredTargetHpRateRange;
    if (triggeredHpRateRange != null && RegExp(r'(^<\d+$|^\d+<$)').hasMatch(triggeredHpRateRange)) {
      final lessThan = triggeredHpRateRange.startsWith('<');
      final hpRateRange = int.parse(triggeredHpRateRange.replaceAll('<', ''));

      targets.retainWhere((svt) {
        final svtHpRate = (svt.hp / svt.getMaxHp(battleData) * 1000).toInt();

        if (lessThan) {
          return svtHpRate < hpRateRange;
        } else {
          return svtHpRate > hpRateRange;
        }
      });
    }

    if (dataVals.CheckDuplicate == 1) {
      final Map<int, bool>? previousExecutionResults = battleData.actionHistory[function.funcId];
      if (previousExecutionResults != null) {
        for (final svt in targets) {
          final previousResult = previousExecutionResults[svt.uniqueId];
          if (previousResult != null) {
            battleData.curFuncResults[svt.uniqueId] = previousResult;
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
