import 'dart:math';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/basic.dart';

class SubState {
  SubState._();

  static bool subState(
    final BattleData battleData,
    final List<NiceTrait> affectTraits,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) {
    final activator = battleData.activator;
    bool buffRemoved = false;
    for (final target in targets) {
      battleData.setTarget(target);
      final removeFromStart = dataVals.Value != null && dataVals.Value! > 0;
      final removeTargetCount =
          dataVals.Value != null && dataVals.Value2 != null ? max(dataVals.Value!, dataVals.Value2!) : null;
      int removeCount = 0;
      if (removeFromStart) {
        for (int i = 0; i < target.battleBuff.activeList.length; i += 1) {
          final buff = target.battleBuff.activeList[i];
          if (!containsAnyTraits(buff.traits, affectTraits)) {
            continue;
          }

          battleData.setCurrentBuff(buff);
          if (shouldSubState(battleData, dataVals, activator, target)) {
            buffRemoved = true;
            target.battleBuff.activeList.removeAt(i);
            removeCount += 1;
            i -= 1;
          }
          battleData.unsetCurrentBuff();

          if (removeTargetCount != null && removeCount == removeTargetCount) {
            break;
          }
        }
      } else {
        for (int i = target.battleBuff.activeList.length - 1; i >= 0; i -= 1) {
          final buff = target.battleBuff.activeList[i];
          if (!containsAnyTraits(buff.traits, affectTraits)) {
            continue;
          }

          battleData.setCurrentBuff(buff);
          if (shouldSubState(battleData, dataVals, activator, target)) {
            buffRemoved = true;
            target.battleBuff.activeList.removeAt(i);
            removeCount += 1;
          }
          battleData.unsetCurrentBuff();

          if (removeTargetCount != null && removeCount == removeTargetCount) {
            break;
          }
        }
      }
      battleData.unsetTarget();
    }

    return buffRemoved;
  }

  static bool shouldSubState(
    final BattleData battleData,
    final DataVals dataVals,
    final BattleServantData? activator,
    final BattleServantData target,
  ) {
    if (dataVals.ForceSubState == 1) {
      return true;
    }

    final buff = battleData.currentBuff!;
    if (buff.irremovable) {
      return false;
    }

    final toleranceSubState = target.getBuffValueOnAction(battleData, BuffAction.toleranceSubstate);
    final grantSubStateDetails = ConstData.buffActions[BuffAction.resistanceState]!;
    final grantSubState = activator?.getBuffValueOnAction(battleData, BuffAction.grantSubstate) ??
        capBuffValue(grantSubStateDetails, 0, Maths.min(grantSubStateDetails.maxRate));

    final functionRate = dataVals.Rate ?? 1000;
    final activationRate = functionRate + grantSubState;
    final resistRate = battleData.probabilityThreshold + toleranceSubState;
    final success = activationRate >= resistRate;
    final resultsString = success
        ? S.current.success
        : resistRate > 1000
            ? 'GUARD'
            : 'MISS';

    battleData.logger.debug('${S.current.effect_target}: ${target.lBattleName}'
        ' - ${buff.buff.lName.l}'
        ' - $resultsString ($activationRate vs $resistRate)');

    return success;
  }
}
