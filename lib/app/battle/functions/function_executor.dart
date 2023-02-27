import 'package:chaldea/app/battle/functions/add_state.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

void executeFunction(
  BattleData battleData,
  NiceFunction function,
  int skillLevel, {
  int overchargeLevel = 1,
  bool isPassive = false,
  bool isCE = false,
}) {
  BattleServantData? activator = battleData.activator;
  if (!validateFunctionTargetTeam(function, activator)) {
    return;
  }

  if (!checkTrait(battleData.getFieldTraits(), function.funcquestTvals)) {
    return;
  }

  List<BattleServantData> targets = acquireFunctionTarget(battleData, function, activator);

  targets.retainWhere((svt) => checkTrait(svt.getTraits(), function.functvals));

  bool functionSuccess = true;
  switch (function.funcType) {
    case FuncType.addState:
      addState(battleData, function, skillLevel, targets,
          overchargeLevel: overchargeLevel, isPassive: isPassive, isCE: isCE);
      break;
    case FuncType.addStateShort:
      addState(battleData, function, skillLevel, targets,
          overchargeLevel: overchargeLevel, isPassive: isPassive, isCE: isCE, isShortBuff: true);
      break;
    default:
      print('Unimplemented FuncType: ${function.funcType}, function ID: ${function.funcId}, '
          'activator: ${activator?.name}, quest ID: ${battleData.niceQuest?.id}, phase: ${battleData.niceQuest?.phase}');
  }
  battleData.previousFunctionResult = functionSuccess;
}

bool checkTrait(Iterable<NiceTrait> myTraits, Iterable<NiceTrait> requiredTraits) {
  Iterable<int> traitIds = myTraits.map((e) => e.id);
  for (NiceTrait trait in requiredTraits) {
    if (!traitIds.contains(trait.id)) {
      return false;
    }
  }
  return true;
}

bool validateFunctionTargetTeam(
  BaseFunction function,
  BattleServantData? activator,
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

List<BattleServantData> acquireFunctionTarget(
  BattleData battleData,
  BaseFunction function,
  BattleServantData? activator,
) {
  List<BattleServantData> targets = [];

  bool isAlly = activator?.isPlayer ?? true;
  List<BattleServantData> backupAllies = isAlly ? battleData.nonnullBackupAllies : battleData.nonnullBackupEnemies;
  List<BattleServantData> aliveAllies = isAlly ? battleData.aliveAllies : battleData.aliveEnemies;
  BattleServantData targetedAlly = isAlly ? battleData.targetedAlly : battleData.targetedEnemy;

  List<BattleServantData> backupEnemies = isAlly ? battleData.nonnullBackupEnemies : battleData.nonnullBackupAllies;
  List<BattleServantData> aliveEnemies = isAlly ? battleData.aliveEnemies : battleData.aliveAllies;
  BattleServantData targetedEnemy = isAlly ? battleData.targetedEnemy : battleData.targetedAlly;

  switch (function.funcTargetType) {
    case FuncTargetType.self:
      targets.add(activator!);
      break;
    case FuncTargetType.ptOne:
    case FuncTargetType.ptselectOneSub:
      targets.add(targetedAlly);
      break;
    case FuncTargetType.ptAll:
      targets.addAll(aliveAllies);
      break;
    case FuncTargetType.enemy:
      targets.add(targetedEnemy);
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
      targets.add(aliveAllies.firstWhere((svt) => svt != activator && svt.selectable));
      break;
    case FuncTargetType.ptSelfAnotherLast:
      targets.add(aliveAllies.lastWhere((svt) => svt != activator && svt.selectable));
      break;
    case FuncTargetType.ptOneHpLowestValue:
      BattleServantData hpLowestValue = aliveAllies.first;
      for (BattleServantData svt in aliveAllies) {
        if (svt.hp < hpLowestValue.hp) {
          hpLowestValue = svt;
        }
      }
      targets.add(hpLowestValue);
      break;
    case FuncTargetType.ptOneHpLowestRate:
      BattleServantData hpLowestRate = aliveAllies.first;
      for (BattleServantData svt in aliveAllies) {
        if (svt.hp / svt.maxHp < hpLowestRate.hp / hpLowestRate.maxHp) {
          hpLowestRate = svt;
        }
      }
      targets.add(hpLowestRate);
      break;
    case FuncTargetType.ptselectSub:
      if (activator == null) {
        targets.add(aliveAllies.first);
      } else {
        targets.add(activator);
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
      print('Unimplemented FuncTargetType: ${function.funcTargetType}, function ID: ${function.funcId}, '
          'activator: ${activator?.name}, quest ID: ${battleData.niceQuest?.id}, phase: ${battleData.niceQuest?.phase}');
      break;
  }

  return targets;
}
