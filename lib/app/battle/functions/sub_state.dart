import 'dart:math';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class SubState {
  SubState._();

  static Future<void> subState(
    final BattleData battleData,
    final List<NiceTrait> affectTraits,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) async {
    final activator = battleData.activator;
    for (final target in targets) {
      await battleData.withTarget(target, () async {
        final removeFromStart = dataVals.Value != null && dataVals.Value! > 0;
        final removeTargetCount =
            dataVals.Value != null && dataVals.Value2 != null ? max(dataVals.Value!, dataVals.Value2!) : null;
        int removeCount = 0;
        final List<BuffData> listToInspect = removeFromStart
            ? target.battleBuff.originalActiveList.reversed.toList()
            : target.battleBuff.originalActiveList.toList();

        for (int index = listToInspect.length - 1; index >= 0; index -= 1) {
          final buff = listToInspect[index];

          await battleData.withBuff(buff, () async {
            if (buff.checkField() &&
                await shouldSubState(battleData, buff, affectTraits, dataVals, activator, target)) {
              listToInspect.removeAt(index);
              removeCount += 1;
            }
          });

          if (removeTargetCount != null && removeCount == removeTargetCount) {
            break;
          }
        }
        target.battleBuff.setActiveList(removeFromStart ? listToInspect.reversed.toList() : listToInspect.toList());
        if (target.hp > 0) {
          target.hp = target.hp.clamp(1, target.maxHp);
        }

        if (removeCount > 0) {
          battleData.setFuncResult(target.uniqueId, true);
        }
      });
    }
  }

  static Future<bool> shouldSubState(
    final BattleData battleData,
    final BuffData buff,
    final Iterable<NiceTrait> affectTraits,
    final DataVals dataVals,
    final BattleServantData? activator,
    final BattleServantData target,
  ) async {
    if (!battleData.checkTraits(CheckTraitParameters(requiredTraits: affectTraits, checkCurrentBuffTraits: true))) {
      return false;
    }

    if (buff.vals.IgnoreIndividuality == 1 || buff.vals.UnSubStateWhileLinkedToOthers == 1) return false;
    if (buff.vals.UnSubState == 1 && dataVals.ForceSubState != 1) return false;

    final toleranceSubState = await target.getBuffValueOnAction(battleData, BuffAction.toleranceSubstate);
    final grantSubState = await activator?.getBuffValueOnAction(battleData, BuffAction.grantSubstate) ?? 0;

    final functionRate = dataVals.Rate ?? 1000;
    final activationRate = functionRate + grantSubState;
    final resistRate = toleranceSubState;
    final success = await battleData.canActivateFunction(activationRate - resistRate);
    final resultsString = success
        ? S.current.success
        : resistRate > 0
            ? 'GUARD'
            : 'MISS';

    battleData.battleLogger.debug('${S.current.effect_target}: ${target.lBattleName} - ${buff.buff.lName.l}'
        '$resultsString'
        '${battleData.options.tailoredExecution ? '' : ' [($activationRate - $resistRate) vs ${battleData.options.threshold}]'}');

    return success;
  }
}
