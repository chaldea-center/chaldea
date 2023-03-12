import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';

bool addState(
  final BattleData battleData,
  final Buff buff,
  final DataVals dataVals,
  final List<BattleServantData> targets, {
  final bool isPassive = false,
  final bool notActorPassive = false,
  final bool isShortBuff = false,
}) {
  final activator = battleData.activator;
  bool buffAdded = false;
  for (final target in targets) {
    final buffData = BuffData(buff, dataVals)
      ..actorUniqueId = activator?.uniqueId ?? 0
      ..actorName = activator?.battleName ?? ''
      ..notActorPassive = notActorPassive
      ..isShortBuff = isShortBuff
      ..irremovable |= isPassive || notActorPassive;

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
  final BattleData battleData,
  final DataVals dataVals,
  final BattleServantData? activator,
  final BattleServantData target,
  final BuffData buffData,
) {
  if (dataVals.ForceAddState == 1) {
    return true;
  }

  if (target.hasBuffOnAction(battleData, BuffAction.avoidState)) {
    return false;
  }

  final buffReceiveChance = target.getBuffValueOnAction(battleData, BuffAction.resistanceState);
  final buffChanceDetails = ConstData.buffActions[BuffAction.resistanceState]!;
  final buffChance = activator?.getBuffValueOnAction(battleData, BuffAction.grantState) ??
      capBuffValue(buffChanceDetails, 0, Maths.min(buffChanceDetails.maxRate));

  final functionRate = dataVals.Rate ?? 1000;
  final activationProbability = functionRate + buffChance + buffReceiveChance;

  return activationProbability >= battleData.probabilityThreshold;
}
