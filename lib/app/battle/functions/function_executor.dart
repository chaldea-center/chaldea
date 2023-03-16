import 'package:chaldea/app/battle/functions/add_field_change_to_field.dart';
import 'package:chaldea/app/battle/functions/add_state.dart';
import 'package:chaldea/app/battle/functions/damage.dart';
import 'package:chaldea/app/battle/functions/gain_np.dart';
import 'package:chaldea/app/battle/functions/gain_np_from_targets.dart';
import 'package:chaldea/app/battle/functions/gain_star.dart';
import 'package:chaldea/app/battle/functions/hasten_npturn.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/extension.dart';

class FunctionExecutor {
  FunctionExecutor._();

  static void executeFunction(
    final BattleData battleData,
    final NiceFunction function,
    final int skillLevel, {
    final int overchargeLvl = 1,
    final int chainPos = 1,
    final bool isTypeChain = false,
    final bool isMightyChain = false,
    final CardType firstCardType = CardType.none,
    final bool isDefensePierce = false,
    final bool isPassive = false,
    final bool notActorFunction = false,
    final bool isCommandCode = false,
    final int? selectedActionIndex,
  }) {
    final BattleServantData? activator = battleData.activator;
    if (!validateFunctionTargetTeam(function, activator)) {
      return;
    }
    final dataVals = getDataVals(function, skillLevel, overchargeLvl);
    if (dataVals.ActSelectIndex != null && dataVals.ActSelectIndex != selectedActionIndex) {
      logger.d('${dataVals.ActSelectIndex} vs $selectedActionIndex');
      return;
    }

    final fieldTraitString = function.funcquestTvals.isNotEmpty
        ? ' - ${S.current.battle_require_field_traits} ${function.funcquestTvals.map((e) => e.shownName())}'
        : '';
    final targetTraitString = function.functvals.isNotEmpty
        ? ' - ${S.current.battle_require_opponent_traits} ${function.funcquestTvals.map((e) => e.shownName())}'
        : '';
    battleData.logger.function('${activator?.lBattleName ?? S.current.battle_no_source} - '
        '${Transl.funcTargetType(function.funcTargetType).l} -  ${function.lPopupText.l}'
        '$fieldTraitString'
        '$targetTraitString');

    if (!containsAnyTraits(battleData.getFieldTraits(), function.funcquestTvals)) {
      return;
    }


    final checkDead = dataVals.CheckDead != null && dataVals.CheckDead! > 0;
    final List<BattleServantData> targets = acquireFunctionTarget(
      battleData,
      function.funcTargetType,
      function.funcId,
      activator,
    );
    targets.retainWhere(
        (svt) => (svt.isAlive(battleData) || checkDead) && svt.checkTraits(battleData, function.functvals));

    bool functionSuccess = true;
    switch (function.funcType) {
      case FuncType.absorbNpturn:
      case FuncType.gainNpFromTargets:
        functionSuccess = GainNpFromTargets.gainNpFromTargets(battleData, dataVals, targets);
        break;
      case FuncType.addState:
        functionSuccess = AddState.addState(
          battleData,
          function.buff!,
          dataVals,
          targets,
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
          isPassive: isPassive,
          isCommandCode: isCommandCode,
          notActorPassive: notActorFunction,
          isShortBuff: true,
        );
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
      case FuncType.damage:
      case FuncType.damageNp:
      case FuncType.damageNpIndividual:
        functionSuccess = Damage.damage(
          battleData,
          dataVals,
          targets,
          chainPos,
          isTypeChain,
          isMightyChain,
          firstCardType,
        );
        break;
      case FuncType.damageNpStateIndividualFix:
        functionSuccess = Damage.damage(
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
      case FuncType.damageNpPierce:
        functionSuccess = Damage.damage(
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
      case FuncType.servantFriendshipUp:
      case FuncType.eventDropUp:
      case FuncType.eventPointUp:
      case FuncType.none:
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
      case FuncTargetType.commandTypeSelfTreasureDevice: // TODO (battle): svt 11 svt 268 uses this
        if (activator != null) {
          targets.add(activator);
        }
        break;
      case FuncTargetType.ptOne:
      case FuncTargetType.ptselectOneSub:
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
      case FuncTargetType.ptAnother:
      case FuncTargetType.enemyAnother:
      case FuncTargetType.ptSelfBefore:
      case FuncTargetType.ptSelfAfter:
      case FuncTargetType.fieldOther:
      case FuncTargetType.enemyOneNoTargetNoAction:
      case FuncTargetType.ptRandom:
      case FuncTargetType.enemyRandom:
      case FuncTargetType.ptOneAnotherRandom:
      case FuncTargetType.ptSelfAnotherRandom: // TODO (battle): svt 251 skill 3 uses this
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
