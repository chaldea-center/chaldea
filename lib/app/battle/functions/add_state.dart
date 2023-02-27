import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';

bool addState(
  BattleData battleData,
  NiceFunction function,
  int skillLevel,
  List<BattleServantData> targets, {
  int overchargeLevel = 1,
  bool isPassive = false,
  bool isCE = false,
  bool isShortBuff = false,
}) {
  final dataVals = _getDataVals(function, skillLevel, overchargeLevel);
  final activator = battleData.activator;
  final buffData = BuffData(function.buff!, dataVals)
    ..actorUniqueId = activator?.uniqueId ?? 0
    ..irremovable |= isCE || isPassive
    ..isShortBuff = isShortBuff;

  battleData.currentBuff = buffData;
  for (BattleServantData target in targets) {
    battleData.target = target;
    if (target.isAlive() && shouldAddState(battleData, dataVals, activator, target, buffData)) {
      if (target.isBuffStackable(buffData.buff!.buffGroup)) {
        target.addBuff(buffData, isPassive: isPassive);
      }
    }
    battleData.target = null;
  }
  battleData.currentBuff = null;

  return true;
}

bool shouldAddState(
  BattleData battleData,
  DataVals dataVals,
  BattleServantData? activator,
  BattleServantData target,
  BuffData buffData,
) {
  if (dataVals.ForceAddState == 1) {
    return true;
  }

  if (target.hasBuffOnAction(battleData, BuffAction.avoidState)) {
    return false;
  }

  final buffResist = target.getBuffValueOnAction(battleData, BuffAction.resistanceState);
  final buffChanceDetails = db.gameData.constData.buffActions[BuffAction.resistanceState]!;
  final buffChance = activator?.getBuffValueOnAction(battleData, BuffAction.grantState) ??
      capBuffValue(buffChanceDetails, 0, Maths.min(buffChanceDetails.maxRate));

  final activationProbability = buffData.buffRate + buffChance - buffResist;

  return activationProbability >= battleData.probabilityThreshold;
}

DataVals _getDataVals(
  NiceFunction function,
  int skillLevel,
  int overchargeLevel,
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
