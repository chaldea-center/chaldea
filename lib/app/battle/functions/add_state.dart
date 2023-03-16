import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';

class AddState {
  AddState._();

  static bool addState(
    final BattleData battleData,
    final Buff buff,
    final DataVals dataVals,
    final List<BattleServantData> targets, {
    final bool isPassive = false,
    final bool notActorPassive = false,
    final bool isCommandCode = false,
    final bool isShortBuff = false,
  }) {
    final activator = battleData.activator;
    bool buffAdded = false;
    for (final target in targets) {
      final buffData = BuffData(buff, dataVals)
        ..actorUniqueId = activator?.uniqueId ?? 0
        ..actorName = activator?.lBattleName ?? ''
        ..notActorPassive = notActorPassive
        ..isShortBuff = isShortBuff
        ..irremovable |= isPassive || notActorPassive;

      battleData.setCurrentBuff(buffData);
      battleData.setTarget(target);
      if (shouldAddState(battleData, dataVals, activator, target, buffData) &&
          target.isBuffStackable(buffData.buff.buffGroup)) {
        target.addBuff(
          buffData,
          isPassive: isPassive || notActorPassive,
          isCommandCode: isCommandCode,
        );
        buffAdded = true;
      }
      battleData.unsetTarget();
      battleData.unsetCurrentBuff();
    }

    return buffAdded;
  }

  static bool shouldAddState(
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
      battleData.logger.debug('${S.current.effect_target}: ${target.lBattleName} - ${S.current.battle_invalid}');
      return false;
    }

    final buffReceiveChance = target.getBuffValueOnAction(battleData, BuffAction.resistanceState);
    final buffChanceDetails = ConstData.buffActions[BuffAction.resistanceState]!;
    final buffChance = activator?.getBuffValueOnAction(battleData, BuffAction.grantState) ??
        capBuffValue(buffChanceDetails, 0, Maths.min(buffChanceDetails.maxRate));

    final functionRate = dataVals.Rate ?? 1000;
    final activationRate = functionRate + buffChance;
    final resistRate = battleData.probabilityThreshold + buffReceiveChance;
    final success = activationRate >= resistRate;
    final resultsString = success
        ? S.current.success
        : resistRate > 1000
            ? 'GUARD'
            : 'MISS';

    battleData.logger.debug('${S.current.effect_target}: ${target.lBattleName} - '
        '$resultsString ($activationRate vs $resistRate)');

    return success;
  }
}
