import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';

bool addState(
  BattleData battleData,
  Buff buff,
  DataVals dataVals,
  List<BattleServantData> targets, {
  bool isPassive = false,
  bool notActorPassive = false,
  bool isShortBuff = false,
}) {
  final activator = battleData.activator;
  var buffAdded = false;
  for (BattleServantData target in targets) {
    final buffData = BuffData(buff, dataVals)
      ..actorUniqueId = activator?.uniqueId ?? 0
      ..notActorPassive = notActorPassive
      ..isShortBuff = isShortBuff;

    battleData.setCurrentBuff(buffData);
    battleData.setTarget(target);
    if (shouldAddState(battleData, dataVals, activator, target, buffData) &&
        target.isBuffStackable(buffData.buff.buffGroup)) {
      target.addBuff(buffData, isPassive: isPassive || notActorPassive);
      buffAdded = true;
    }
    battleData.unsetTarget();
    battleData.unsetCurrentBuff();
  }

  return buffAdded;
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

  final buffResist =
      target.getBuffValueOnAction(battleData, BuffAction.resistanceState);
  final buffChanceDetails =
      db.gameData.constData.buffActions[BuffAction.resistanceState]!;
  final buffChance = activator?.getBuffValueOnAction(
          battleData, BuffAction.grantState) ??
      capBuffValue(buffChanceDetails, 0, Maths.min(buffChanceDetails.maxRate));

  final functionRate = dataVals.Rate ?? 1000;
  final activationProbability = functionRate + buffChance - buffResist;

  return activationProbability >= battleData.probabilityThreshold;
}
