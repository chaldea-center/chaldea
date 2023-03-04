import 'package:chaldea/app/battle/functions/add_state.dart';
import 'package:chaldea/app/battle/functions/damage.dart';
import 'package:chaldea/app/battle/functions/gain_np.dart';
import 'package:chaldea/app/battle/functions/gain_star.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/extension.dart';

void executeFunction(
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
}) {
  final BattleServantData? activator = battleData.activator;
  if (!validateFunctionTargetTeam(function, activator) ||
      !containsAnyTraits(battleData.getFieldTraits(), function.funcquestTvals)) {
    battleData.previousFunctionResult = false;
    return;
  }

  final dataVals = getDataVals(function, skillLevel, overchargeLvl);
  final List<BattleServantData> targets =
      acquireFunctionTarget(battleData, function.funcTargetType, function.funcId, activator);

  final checkDead = dataVals.CheckDead != null && dataVals.CheckDead! > 0;
  targets.retainWhere((svt) => (svt.isAlive() || checkDead) && svt.checkTraits(function.functvals));

  bool functionSuccess = true;
  switch (function.funcType) {
    case FuncType.addState:
      functionSuccess = addState(battleData, function.buff!, dataVals, targets,
          isPassive: isPassive, notActorPassive: notActorFunction);
      break;
    case FuncType.addStateShort:
      functionSuccess = addState(battleData, function.buff!, dataVals, targets,
          isPassive: isPassive, notActorPassive: notActorFunction, isShortBuff: true);
      break;
    case FuncType.gainNp:
      functionSuccess = gainNP(battleData, dataVals, targets);
      break;
    case FuncType.gainStar:
      functionSuccess = gainStar(battleData, dataVals);
      break;
    case FuncType.damage:
    case FuncType.damageNp:
    case FuncType.damageNpIndividual:
      functionSuccess = damage(battleData, dataVals, targets, chainPos, isTypeChain, isMightyChain, firstCardType);
      break;
    case FuncType.damageNpStateIndividualFix:
      functionSuccess = damage(battleData, dataVals, targets, chainPos, isTypeChain, isMightyChain, firstCardType,
          checkBuffTraits: true);
      break;
    case FuncType.damageNpPierce:
      functionSuccess = damage(battleData, dataVals, targets, chainPos, isTypeChain, isMightyChain, firstCardType,
          isPierceDefense: true);
      break;
    case FuncType.servantFriendshipUp:
    case FuncType.eventDropUp:
    case FuncType.eventPointUp:
      break;
    default:
      print('Unimplemented FuncType: ${function.funcType}, function ID: ${function.funcId}, '
          'activator: ${activator?.name}, quest ID: ${battleData.niceQuest?.id}, phase: ${battleData.niceQuest?.phase}');
  }
  battleData.previousFunctionResult = functionSuccess;
}

bool validateFunctionTargetTeam(
  final BaseFunction function,
  final BattleServantData? activator,
) {
  switch (function.funcTargetTeam) {
    case FuncApplyTarget.player:
      return activator?.isPlayer ?? true;
    case FuncApplyTarget.enemy:
      return activator?.isEnemy ?? true;
    default:
      return true;
  }
}

DataVals getDataVals(
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

List<BattleServantData> acquireFunctionTarget(
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
      targets.remove(activator);
      targets.addAll(backupAllies);
      break;
    case FuncTargetType.enemyOtherFull:
      targets.addAll(aliveEnemies);
      targets.remove(targetedEnemy);
      targets.addAll(backupEnemies);
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
    case FuncTargetType.ptSelfAnotherRandom:
    case FuncTargetType.enemyOneAnotherRandom:
    case FuncTargetType.commandTypeSelfTreasureDevice:
      print('Unimplemented FuncTargetType: $funcTargetType, function ID: $funcId, '
          'activator: ${activator?.name}, quest ID: ${battleData.niceQuest?.id}, phase: ${battleData.niceQuest?.phase}');
      break;
  }

  return targets;
}
