import 'package:chaldea/app/battle/functions/add_field_change_to_field.dart';
import 'package:chaldea/app/battle/functions/add_state.dart';
import 'package:chaldea/app/battle/functions/damage.dart';
import 'package:chaldea/app/battle/functions/gain_np.dart';
import 'package:chaldea/app/battle/functions/gain_np_from_targets.dart';
import 'package:chaldea/app/battle/functions/gain_star.dart';
import 'package:chaldea/app/battle/functions/hasten_npturn.dart';
import 'package:chaldea/app/battle/functions/instant_death.dart';
import 'package:chaldea/app/battle/functions/replace_member.dart';
import 'package:chaldea/app/battle/functions/shorten_skill.dart';
import 'package:chaldea/app/battle/functions/sub_state.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/app/modules/common/misc.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';
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
  }) async {
    for (int i = 0; i < functions.length; i += 1) {
      NiceFunction func = functions[i];
      final dataVal = FunctionExecutor.getDataVals(func, skillLevel, overchargeLvl);
      if (dataVal.ActSet != null && dataVal.ActSet! > 0) {
        final List<NiceFunction> actFunctions = getGroupedFunctions(
          functions,
          skillLevel,
          i,
          overchargeLv: overchargeLvl,
        );
        i += actFunctions.length - 1;

        final validFuncs = actFunctions
            .where((func) => FunctionExecutor.validateFunctionTargetTeam(func, battleData.activator))
            .toList();

        if (battleData.context != null && validFuncs.isNotEmpty) {
          await getSelectedFunction(battleData, validFuncs).then((value) => func = value);
        }
      }

      await FunctionExecutor.executeFunction(battleData, func, skillLevel,
          overchargeLvl: overchargeLvl,
          isPassive: isPassive,
          notActorFunction: notActorFunction,
          isCommandCode: isCommandCode,
          selectedActionIndex: selectedActionIndex);
    }

    battleData.checkBuffStatus();
  }

  static List<NiceFunction> getGroupedFunctions(
    final List<NiceFunction> functions,
    final int skillLevel,
    final int startIndex, {
    final int overchargeLv = 1,
  }) {
    final List<NiceFunction> groupedFunctions = [];
    int index = startIndex;
    int? curAct = 0;
    do {
      final func = functions[index];
      index += 1;
      final nextAct = FunctionExecutor.getDataVals(func, skillLevel, overchargeLv).ActSet;
      curAct = nextAct != null && curAct != null && nextAct >= curAct ? nextAct : null;
      if (curAct != null) {
        groupedFunctions.add(func);
      }
    } while (index < functions.length && curAct != null);
    return groupedFunctions;
  }

  static Future<NiceFunction> getSelectedFunction(
    final BattleData battleData,
    final List<NiceFunction> functions,
  ) async {
    final transl = Transl.miscScope('SelectAddInfo');
    return await showDialog(
      context: battleData.context!,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) {
        return SimpleCancelOkDialog(
          title: Text(S.current.battle_select_effect),
          contentPadding: const EdgeInsets.all(8),
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: divideTiles(List.generate(functions.length, (index) {
                return TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(functions[index]);
                    battleData.logger.action('${S.current.battle_select_effect}: ${transl('Option').l} ${index + 1}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      '${transl('Option').l} ${index + 1}: ${functions[index].lPopupText.l}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              })),
            ),
          ),
          hideOk: true,
          hideCancel: true,
        );
      },
    );
  }

  static Future<NiceTd> getSelectedTd(
    final BattleData battleData,
    final List<NiceTd> tds,
  ) async {
    tds.sort((a, b) => (a.card.index % 3).compareTo(b.card.index % 3)); // Q A B

    return await showDialog(
      context: battleData.context!,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) {
        return SimpleCancelOkDialog(
          title: Text(S.current.battle_select_effect),
          contentPadding: const EdgeInsets.all(8),
          content: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: divideTiles(List.generate(tds.length, (index) {
                return InkWell(
                  onLongPress: () {},
                  onTap: () {
                    Navigator.of(context).pop(tds[index]);
                    battleData.logger.action('${S.current.battle_select_effect}: ${tds[index].card.name.toUpperCase()}'
                        ' ${S.current.battle_np_card}');
                  },
                  child: CommandCardWidget(card: tds[index].card, width: 100),
                );
              })),
            ),
          ),
          hideOk: true,
          hideCancel: true,
        );
      },
    );
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
  }) async {
    final BattleServantData? activator = battleData.activator;
    if (!validateFunctionTargetTeam(function, activator)) {
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
        battleData.logger.function('${activator?.lBattleName ?? S.current.battle_no_source} - '
            '${Transl.funcTargetType(function.funcTargetType).l} -  ${function.lPopupText.l}'
            '$fieldTraitString'
            '$targetTraitString');
        break;
    }

    final dataVals = getDataVals(function, skillLevel, overchargeLvl);
    if (dataVals.ActSelectIndex != null && dataVals.ActSelectIndex != selectedActionIndex) {
      return;
    }

    if (!containsAnyTraits(battleData.getFieldTraits(), function.funcquestTvals)) {
      battleData.logger.function('${S.current.battle_require_field_traits} ${S.current.failed}');
      return;
    }

    if (dataVals.StarHigher != null && battleData.criticalStars < dataVals.StarHigher!) {
      battleData.previousFunctionResult = false;
      battleData.logger.function('${S.current.battle_critical_star} ${battleData.criticalStars.toStringAsFixed(3)} < '
          '${dataVals.StarHigher}');
      return;
    }

    final checkDead = dataVals.CheckDead != null && dataVals.CheckDead! > 0;
    final List<BattleServantData> targets = acquireFunctionTarget(
      battleData,
      function.funcTargetType,
      function.funcId,
      activator,
    );
    final checkBuff = dataVals.IncludePassiveIndividuality == 1;
    targets.retainWhere((svt) =>
        (svt.isAlive(battleData) || checkDead) &&
        svt.checkTraits(battleData, function.functvals, checkBuff: checkBuff));

    List<NiceTd> tdSelections = [];
    if (function.funcTargetType == FuncTargetType.commandTypeSelfTreasureDevice) {
      for (final svt in targets) {
        NiceTd tdSelection = svt.getCurrentNP(battleData);
        if (tdSelection.script != null && tdSelection.script!.tdTypeChangeIDs != null) {
          final List<NiceTd> tds = svt.getTdsById(tdSelection.script!.tdTypeChangeIDs!);
          if (tds.isNotEmpty && battleData.context != null) {
            await getSelectedTd(battleData, tds).then((value) => tdSelection = value);
          }
        }
        tdSelections.add(tdSelection);
      }
    }

    bool functionSuccess = true;
    switch (function.funcType) {
      case FuncType.absorbNpturn:
      case FuncType.gainNpFromTargets:
        GainNpFromTargets.gainNpFromTargets(battleData, dataVals, targets).then((value) => functionSuccess = value);
        break;
      case FuncType.addState:
        functionSuccess = AddState.addState(
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
        functionSuccess = AddState.addState(
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
        functionSuccess = SubState.subState(battleData, function.traitVals, dataVals, targets);
        break;
      case FuncType.addFieldChangeToField:
        functionSuccess = AddFieldChangeToField.addFieldChangeToField(battleData, function.buff!, dataVals);
        break;
      case FuncType.gainNp:
        functionSuccess = GainNP.gainNP(battleData, dataVals, targets);
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
        functionSuccess = GainStar.gainStar(battleData, dataVals);
        break;
      case FuncType.lossStar:
        functionSuccess = GainStar.gainStar(battleData, dataVals, isNegative: true);
        break;
      case FuncType.shortenSkill:
        functionSuccess = ShortenSkill.shortenSkill(battleData, dataVals, targets);
        break;
      case FuncType.damage:
      case FuncType.damageNp:
      case FuncType.damageNpIndividual:
        await Damage.damage(
          battleData,
          dataVals,
          targets,
          chainPos,
          isTypeChain,
          isMightyChain,
          firstCardType,
        ).then((value) => functionSuccess = value);
        break;
      case FuncType.damageNpIndividualSum:
        await Damage.damage(
          battleData,
          dataVals,
          targets,
          chainPos,
          isTypeChain,
          isMightyChain,
          firstCardType,
          checkBuffTraits: dataVals.IncludeIgnoreIndividuality == 1,
          npSpecificMode: NpSpecificMode.individualSum,
        ).then((value) => functionSuccess = value);
        break;
      case FuncType.damageNpRare:
        await Damage.damage(
          battleData,
          dataVals,
          targets,
          chainPos,
          isTypeChain,
          isMightyChain,
          firstCardType,
          npSpecificMode: NpSpecificMode.rarity,
        ).then((value) => functionSuccess = value);
        break;
      case FuncType.damageNpStateIndividualFix:
        await Damage.damage(
          battleData,
          dataVals,
          targets,
          chainPos,
          isTypeChain,
          isMightyChain,
          firstCardType,
          checkBuffTraits: true,
        ).then((value) => functionSuccess = value);
        break;
      case FuncType.damageNpHpratioLow:
        await Damage.damage(
          battleData,
          dataVals,
          targets,
          chainPos,
          isTypeChain,
          isMightyChain,
          firstCardType,
          checkHpRatio: true,
        ).then((value) => functionSuccess = value);
        break;
      case FuncType.damageNpPierce:
        await Damage.damage(
          battleData,
          dataVals,
          targets,
          chainPos,
          isTypeChain,
          isMightyChain,
          firstCardType,
          isPierceDefense: true,
        ).then((value) => functionSuccess = value);
        break;
      case FuncType.instantDeath:
        functionSuccess = InstantDeath.instantDeath(battleData, dataVals, targets);
        break;
      case FuncType.forceInstantDeath:
        functionSuccess = InstantDeath.instantDeath(battleData, dataVals, targets, force: true);
        break;
      case FuncType.moveToLastSubmember:
        functionSuccess = MoveToLastSubMember.moveToLastSubMember(battleData, dataVals, targets);
        break;
      case FuncType.replaceMember:
        await ReplaceMember.replaceMember(battleData, dataVals).then((value) => functionSuccess = value);
        break;
      case FuncType.cardReset:
        battleData.nonnullAllies.forEach((svt) {
          svt.removeBuffWithTrait(NiceTrait(id: Trait.buffLockCardsDeck.id));
        });
        break;
      case FuncType.fixCommandcard:
        // do nothing
        break;
      default:
        battleData.logger.debug('${S.current.not_implemented}: ${function.funcType}, '
            'Function ID: ${function.funcId}, '
            'Activator: ${activator?.lBattleName}, '
            'Quest ID: ${battleData.niceQuest?.id}, '
            'Phase: ${battleData.niceQuest?.phase}');
    }

    battleData.previousFunctionResult = functionSuccess;
  }

  static bool validateFunctionTargetTeam(
    final BaseFunction function,
    final BattleServantData? activator,
  ) {
    if (activator == null || function.funcTargetTeam == FuncApplyTarget.playerAndEnemy) {
      return true;
    }

    return function.isPlayerOnlyFunc ? activator.isPlayer : activator.isEnemy;
  }

  static DataVals getDataVals(
    final NiceFunction function,
    final int skillLevel,
    final int overchargeLevel,
  ) {
    switch (overchargeLevel) {
      case 1:
        return function.svals[skillLevel - 1];
      case 2:
        return function.svals2![skillLevel - 1];
      case 3:
        return function.svals3![skillLevel - 1];
      case 4:
        return function.svals4![skillLevel - 1];
      case 5:
        return function.svals5![skillLevel - 1];
      default:
        throw 'Illegal overcharge level: $overchargeLevel}';
    }
  }

  static List<BattleServantData> acquireFunctionTarget(
    final BattleData battleData,
    final FuncTargetType funcTargetType,
    final int funcId,
    final BattleServantData? activator,
  ) {
    final List<BattleServantData> targets = [];

    final isAlly = activator?.isPlayer ?? true;
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
      case FuncTargetType.ptAnother:
      case FuncTargetType.enemyAnother:
      case FuncTargetType.ptSelfBefore:
      case FuncTargetType.ptSelfAfter:
      case FuncTargetType.fieldOther:
      case FuncTargetType.enemyOneNoTargetNoAction:
      case FuncTargetType.ptRandom:
      case FuncTargetType.enemyRandom:
      case FuncTargetType.ptOneAnotherRandom:
      case FuncTargetType.ptSelfAnotherRandom:
      case FuncTargetType.enemyOneAnotherRandom:
        battleData.logger.debug('${S.current.not_implemented}: $funcTargetType, '
            'Function ID: $funcId, '
            'Activator: ${activator?.lBattleName}, '
            'Quest ID: ${battleData.niceQuest?.id}, '
            'Phase: ${battleData.niceQuest?.phase}');
        break;
    }

    return targets;
  }
}
