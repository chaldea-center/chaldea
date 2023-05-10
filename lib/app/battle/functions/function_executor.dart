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
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/app/descriptors/func/func.dart';
import 'package:chaldea/generated/l10n.dart';
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
    }
    for (int index = 0; index < functions.length; index += 1) {
      NiceFunction func = functions[index];
      final dataVal = FunctionExecutor.getDataVals(func, skillLevel, overchargeLvl);
      if ((dataVal.ActSet ?? 0) != 0 && dataVal.ActSet != selectedActSet) {
        continue;
      }

      await FunctionExecutor.executeFunction(
        battleData,
        func,
        skillLevel,
        overchargeLvl: overchargeLvl,
        isPassive: isPassive,
        notActorFunction: notActorFunction,
        isCommandCode: isCommandCode,
        selectedActionIndex: selectedActionIndex,
        effectiveness: effectiveness,
        defaultToPlayer: defaultToPlayer,
      );
    }
  }

  static Future<void> executeFunction(
    final BattleData battleData,
    final NiceFunction function,
    final int skillLevel, {
    final int overchargeLvl = 1,
    final int chainPos = 1,
    final bool isTypeChain = false,
    final bool isMightyChain = false,
    final CardType firstCardType = CardType.none,
    final bool isPassive = false,
    final bool notActorFunction = false,
    final bool isCommandCode = false,
    final int? selectedActionIndex,
    final int? effectiveness,
    final bool defaultToPlayer = true,
  }) async {
    final BattleServantData? activator = battleData.activator;
    if (!validateFunctionTargetTeam(function, activator?.isPlayer ?? defaultToPlayer)) {
      return;
    }

    switch (function.funcType) {
      case FuncType.servantFriendshipUp:
      case FuncType.eventDropUp:
      case FuncType.eventPointUp:
      case FuncType.none:
        return;
      default:
        final fieldTraitString = function.funcquestTvals.isNotEmpty
            ? ' - ${S.current.battle_require_field_traits} ${function.funcquestTvals.map((e) => e.shownName())}'
            : '';
        final targetTraitString = function.functvals.isNotEmpty
            ? ' - ${S.current.battle_require_opponent_traits} ${function.functvals.map((e) => e.shownName())}'
            : '';
        battleData.battleLogger.function('${activator?.lBattleName ?? S.current.battle_no_source} - '
            '${FuncDescriptor.buildFuncText(function)}'
            '$fieldTraitString'
            '$targetTraitString');
        break;
    }

    DataVals dataVals = getDataVals(function, skillLevel, overchargeLvl);
    if (dataVals.ActSelectIndex != null && dataVals.ActSelectIndex != selectedActionIndex) {
      return;
    }

    if (effectiveness != null && dataVals.Value != null && dataVals.Value2 == null) {
      final dataJson = dataVals.toJson();
      dataJson['Value'] = (dataVals.Value! * toModifier(effectiveness)).toInt();
      dataVals = DataVals.fromJson(dataJson);
    }

    final funcQuestTvalsMatch = battleData.checkTraits(CheckTraitParameters(
      requiredTraits: function.funcquestTvals,
      checkQuestTraits: true,
    ));

    final List<BattleServantData> targets = acquireFunctionTarget(
      battleData,
      function.funcTargetType,
      activator,
      funcId: function.funcId,
      defaultToPlayer: defaultToPlayer,
    );

    battleData.curFuncResults.clear();
    for (final target in targets) {
      battleData.curFuncResults[target.uniqueId] = false;
    }

    if (!funcQuestTvalsMatch) {
      battleData.updateLastFuncResults();
      battleData.battleLogger.function('${S.current.battle_require_field_traits} ${S.current.failed}');
      return;
    }

    if (dataVals.StarHigher != null && battleData.criticalStars < dataVals.StarHigher!) {
      battleData.updateLastFuncResults();
      battleData.battleLogger.function('${S.current.critical_star} ${battleData.criticalStars.toStringAsFixed(3)} < '
          '${dataVals.StarHigher}');
      return;
    }

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
        GainNP.gainNP(
          battleData,
          dataVals,
          targets,
          targetTraits: function.traitVals,
          checkBuff: function.funcType == FuncType.gainNpBuffIndividualSum,
        );
        break;
      case FuncType.hastenNpturn:
      case FuncType.delayNpturn:
        HastenNpturn.hastenNpturn(battleData, dataVals, targets, isNegative: function.funcType == FuncType.delayNpturn);
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
        await Damage.damage(battleData, dataVals, targets, chainPos, isTypeChain, isMightyChain, firstCardType);
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
        break;
      case FuncType.fixCommandcard:
        // do nothing
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
      // TODO: unimplemented FuncTypes
      case FuncType.damageValue:
      case FuncType.damageNpCounter:
      case FuncType.damageValueSafe:
      case FuncType.damageNpSafe:
      // ↑↑↑ should be implemented ↑↑↑
      case FuncType.shortenUserEquipSkill:
      case FuncType.subFieldBuff:
      case FuncType.damageNpAndCheckIndividuality:
      case FuncType.damageNpStateIndividual:
      case FuncType.releaseState:
      case FuncType.ptShuffle:
      case FuncType.changeBg:
      case FuncType.withdraw:
      case FuncType.displayBuffstring:
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
        battleData.battleLogger.debug('${S.current.skip}: ${function.funcType}, '
            'Function ID: ${function.funcId}, '
            'Activator: ${activator?.lBattleName}');
        break;
    }

    battleData.updateLastFuncResults();
    battleData.checkBuffStatus();
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

  static List<BattleServantData> acquireFunctionTarget(
    final BattleData battleData,
    final FuncTargetType funcTargetType,
    final BattleServantData? activator, {
    final int? funcId,
    final bool defaultToPlayer = true,
  }) {
    final List<BattleServantData> targets = [];

    final isAlly = activator?.isPlayer ?? defaultToPlayer;
    final List<BattleServantData> backupAllies =
        isAlly ? battleData.nonnullBackupAllies : battleData.nonnullBackupEnemies;
    final List<BattleServantData> aliveAllies = isAlly ? battleData.nonnullAllies : battleData.nonnullEnemies;
    final BattleServantData? targetedAlly = isAlly ? battleData.targetedAlly : battleData.targetedEnemy;

    final List<BattleServantData> backupEnemies =
        isAlly ? battleData.nonnullBackupEnemies : battleData.nonnullBackupAllies;
    final List<BattleServantData> aliveEnemies = isAlly ? battleData.nonnullEnemies : battleData.nonnullAllies;
    final BattleServantData? targetedEnemy = isAlly ? battleData.targetedEnemy : battleData.targetedAlly;

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
      case FuncTargetType.ptAnother:
      case FuncTargetType.enemyAnother:
      case FuncTargetType.ptSelfBefore:
      case FuncTargetType.ptSelfAfter:
      case FuncTargetType.ptRandom:
      case FuncTargetType.enemyRandom:
      case FuncTargetType.ptOneAnotherRandom:
      case FuncTargetType.ptSelfAnotherRandom:
      case FuncTargetType.enemyOneAnotherRandom:
        battleData.battleLogger.debug('${S.current.not_implemented}: $funcTargetType, '
            'Function ID: $funcId, '
            'Activator: ${activator?.lBattleName}, '
            'Quest ID: ${battleData.niceQuest?.id}, '
            'Phase: ${battleData.niceQuest?.phase}');
        break;
    }

    return targets;
  }
}
