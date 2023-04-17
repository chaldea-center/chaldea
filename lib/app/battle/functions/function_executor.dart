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
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/app/descriptors/func/func.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/extension.dart';
import '../interactions/act_set_select.dart';
import '../interactions/td_type_change_selector.dart';
import 'move_to_last_sub_member.dart';

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
    if (actSets.isNotEmpty && battleData.mounted) {
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

    battleData.checkBuffStatus();
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

    if (!containsAnyTraits(battleData.getFieldTraits(), function.funcquestTvals)) {
      battleData.battleLogger.function('${S.current.battle_require_field_traits} ${S.current.failed}');
      return;
    }

    if (dataVals.StarHigher != null && battleData.criticalStars < dataVals.StarHigher!) {
      battleData.previousFunctionResult = false;
      battleData.battleLogger.function('${S.current.critical_star} ${battleData.criticalStars.toStringAsFixed(3)} < '
          '${dataVals.StarHigher}');
      return;
    }

    final checkDead = dataVals.CheckDead != null && dataVals.CheckDead! > 0;
    final List<BattleServantData> targets = acquireFunctionTarget(
      battleData,
      function.funcTargetType,
      function.funcId,
      activator,
      defaultToPlayer: defaultToPlayer,
    );
    final checkBuff = dataVals.IncludePassiveIndividuality == 1;
    targets.retainWhere((svt) =>
        (svt.isAlive(battleData) || checkDead) &&
        svt.checkTraits(battleData, function.functvals, checkBuff: checkBuff));

    List<NiceTd?> tdSelections = [];
    if (function.funcTargetType == FuncTargetType.commandTypeSelfTreasureDevice) {
      for (final svt in targets) {
        NiceTd? tdSelection;
        final NiceTd? baseTd = svt.td;
        if (baseTd != null) {
          if (baseTd.script != null && baseTd.script!.tdTypeChangeIDs != null) {
            final List<NiceTd> tds = svt.getTdsById(baseTd.script!.tdTypeChangeIDs!);
            if (tds.isNotEmpty && battleData.mounted) {
              tdSelection = await TdTypeChangeSelector.show(battleData, tds);
            }
          }
        }
        tdSelections.add(tdSelection);
      }
    }

    battleData.curFunc = function;
    bool functionSuccess = true;
    switch (function.funcType) {
      case FuncType.absorbNpturn:
      case FuncType.gainNpFromTargets:
        functionSuccess = await GainNpFromTargets.gainNpFromTargets(battleData, dataVals, targets);
        break;
      case FuncType.addState:
        functionSuccess = await AddState.addState(
          battleData,
          function.buff!,
          dataVals,
          targets,
          tdSelections: tdSelections,
          isPassive: isPassive,
          isCommandCode: isCommandCode,
          notActorPassive: notActorFunction,
        );
        break;
      case FuncType.addStateShort:
        functionSuccess = await AddState.addState(
          battleData,
          function.buff!,
          dataVals,
          targets,
          tdSelections: tdSelections,
          isPassive: isPassive,
          isCommandCode: isCommandCode,
          notActorPassive: notActorFunction,
          isShortBuff: true,
        );
        break;
      case FuncType.subState:
        functionSuccess = await SubState.subState(battleData, function.traitVals, dataVals, targets);
        break;
      case FuncType.moveState:
        functionSuccess =
            await MoveState.moveState(battleData, dataVals, targets).then((value) => functionSuccess = value);
        break;
      case FuncType.addFieldChangeToField:
        functionSuccess = AddFieldChangeToField.addFieldChangeToField(battleData, function.buff!, dataVals);
        break;
      case FuncType.gainNp:
        functionSuccess = GainNP.gainNP(battleData, dataVals, targets);
        break;
      case FuncType.gainNpIndividualSum:
        functionSuccess = GainNP.gainNP(battleData, dataVals, targets, targetTraits: function.traitVals);
        break;
      case FuncType.gainNpBuffIndividualSum:
        functionSuccess =
            GainNP.gainNP(battleData, dataVals, targets, targetTraits: function.traitVals, checkBuff: true);
        break;
      case FuncType.lossNp:
        functionSuccess = GainNP.gainNP(battleData, dataVals, targets, isNegative: true);
        break;
      case FuncType.hastenNpturn:
        functionSuccess = HastenNpturn.hastenNpturn(battleData, dataVals, targets);
        break;
      case FuncType.delayNpturn:
        functionSuccess = HastenNpturn.hastenNpturn(battleData, dataVals, targets, isNegative: true);
        break;
      case FuncType.gainStar:
        functionSuccess = GainStar.gainStar(battleData, dataVals, times: targets.length);
        break;
      case FuncType.lossStar:
        functionSuccess = GainStar.gainStar(battleData, dataVals, times: targets.length, isNegative: true);
        break;
      case FuncType.shortenSkill:
        functionSuccess = ShortenSkill.shortenSkill(battleData, dataVals, targets);
        break;
      case FuncType.damage:
      case FuncType.damageNp:
      case FuncType.damageNpIndividual:
        functionSuccess = await Damage.damage(
          battleData,
          dataVals,
          targets,
          chainPos,
          isTypeChain,
          isMightyChain,
          firstCardType,
        );
        break;
      case FuncType.damageNpIndividualSum:
        functionSuccess = await Damage.damage(
          battleData,
          dataVals,
          targets,
          chainPos,
          isTypeChain,
          isMightyChain,
          firstCardType,
          checkBuffTraits: dataVals.IncludeIgnoreIndividuality == 1,
          npSpecificMode: NpSpecificMode.individualSum,
        );
        break;
      case FuncType.damageNpRare:
        functionSuccess = await Damage.damage(
          battleData,
          dataVals,
          targets,
          chainPos,
          isTypeChain,
          isMightyChain,
          firstCardType,
          npSpecificMode: NpSpecificMode.rarity,
        );
        break;
      case FuncType.damageNpStateIndividualFix:
        functionSuccess = await Damage.damage(
          battleData,
          dataVals,
          targets,
          chainPos,
          isTypeChain,
          isMightyChain,
          firstCardType,
          checkBuffTraits: true,
        );
        break;
      case FuncType.damageNpHpratioLow:
        functionSuccess = await Damage.damage(
          battleData,
          dataVals,
          targets,
          chainPos,
          isTypeChain,
          isMightyChain,
          firstCardType,
          checkHpRatio: true,
        );
        break;
      case FuncType.damageNpPierce:
        functionSuccess = await Damage.damage(
          battleData,
          dataVals,
          targets,
          chainPos,
          isTypeChain,
          isMightyChain,
          firstCardType,
          isPierceDefense: true,
        );
        break;
      case FuncType.instantDeath:
        functionSuccess = await InstantDeath.instantDeath(battleData, dataVals, targets);
        break;
      case FuncType.forceInstantDeath:
        functionSuccess = await InstantDeath.instantDeath(battleData, dataVals, targets, force: true);
        break;
      case FuncType.gainHp:
        functionSuccess = await GainHP.gainHP(battleData, dataVals, targets);
        break;
      case FuncType.gainHpPer:
        functionSuccess = await GainHP.gainHP(battleData, dataVals, targets, isPercent: true);
        break;
      case FuncType.lossHpSafe:
        functionSuccess = await GainHP.gainHP(battleData, dataVals, targets, isNegative: true);
        break;
      case FuncType.lossHp:
        functionSuccess = await GainHP.gainHP(battleData, dataVals, targets, isNegative: true, isLethal: true);
        break;
      case FuncType.gainHpFromTargets:
        functionSuccess = await GainHpFromTargets.gainHpFromTargets(battleData, dataVals, targets);
        break;
      case FuncType.transformServant:
        functionSuccess = await TransformServant.transformServant(battleData, dataVals, targets);
        break;
      case FuncType.moveToLastSubmember:
        functionSuccess = MoveToLastSubMember.moveToLastSubMember(battleData, dataVals, targets);
        break;
      case FuncType.replaceMember:
        functionSuccess =
            await ReplaceMember.replaceMember(battleData, dataVals).then((value) => functionSuccess = value);
        break;
      case FuncType.cardReset:
        battleData.nonnullAllies.forEach((svt) {
          svt.removeBuffWithTrait(NiceTrait(id: Trait.buffLockCardsDeck.id));
        });
        // functionSuccess = true; ?
        break;
      case FuncType.fixCommandcard:
        // do nothing
        break;
      default:
        battleData.battleLogger.debug('${S.current.not_implemented}: ${function.funcType}, '
            'Function ID: ${function.funcId}, '
            'Activator: ${activator?.lBattleName}, '
            'Quest ID: ${battleData.niceQuest?.id}, '
            'Phase: ${battleData.niceQuest?.phase}');
    }

    battleData.previousFunctionResult = functionSuccess;
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
    final int overchargeLevel,
  ) {
    return (function.svalsList.getOrNull(overchargeLevel - 1) ?? function.svals).getOrNull(skillLevel - 1) ??
        DataVals();
  }

  static List<BattleServantData> acquireFunctionTarget(
    final BattleData battleData,
    final FuncTargetType funcTargetType,
    final int funcId,
    final BattleServantData? activator, {
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
