import 'dart:math';

import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class SubState {
  SubState._();

  static Future<void> subState(
    final BattleData battleData,
    final List<int> affectTraits,
    final DataVals dataVals,
    final BattleServantData? activator,
    final List<BattleServantData> targets,
  ) async {
    for (final target in targets) {
      final removeFromStart = dataVals.Value != null && dataVals.Value! > 0;
      final removeTargetCount = dataVals.Value != null && dataVals.Value2 != null
          ? max(dataVals.Value!, dataVals.Value2!)
          : null;
      int removeCount = 0;
      final List<BuffData> listToInspect = removeFromStart
          ? target.battleBuff.originalActiveList.reversed.toList()
          : target.battleBuff.originalActiveList.toList();
      final List<int> removedFamilyIndiv = [];
      final List<BuffData> removedBuffs = [];

      for (int index = listToInspect.length - 1; index >= 0; index -= 1) {
        final buff = listToInspect[index];

        final substituteAddState = await target.getBuff(battleData, BuffAction.substituteAddState);
        if (buff.checkField() &&
            await shouldSubState(
              battleData,
              buff,
              affectTraits,
              dataVals,
              activator,
              target,
              substituteAddState: substituteAddState,
            )) {
          if (substituteAddState != null && substituteAddState.vals.SubstituteSkillId != null) {
            await FunctionExecutor.executeCustomSkill(
              battleData: battleData,
              skillId: substituteAddState.vals.SubstituteSkillId!,
              activator: target,
              target: activator,
              skillLv: substituteAddState.vals.SubstituteSkillLv,
            );
          } else {
            removedBuffs.add(listToInspect.removeAt(index));
            removeCount += 1;
            if (buff.vals.BehaveAsFamilyBuff == 1 && buff.vals.AddLinkageTargetIndividualty != null) {
              removedFamilyIndiv.add(buff.vals.AddLinkageTargetIndividualty!);
            }
          }
        } else if (substituteAddState != null && substituteAddState.vals.ResistSkillId != null) {
          await FunctionExecutor.executeCustomSkill(
            battleData: battleData,
            skillId: substituteAddState.vals.ResistSkillId!,
            activator: target,
            target: activator,
            skillLv: substituteAddState.vals.ResistSkillLv,
          );
        }

        if (removeTargetCount != null && removeCount == removeTargetCount) {
          break;
        }
      }

      listToInspect.removeWhere((buff) {
        final shouldRemove =
            buff.vals.BehaveAsFamilyBuff == 1 &&
            buff.vals.getAddIndividuality().any((indiv) => removedFamilyIndiv.contains(indiv));
        if (shouldRemove) {
          removedBuffs.add(buff);
        }
        return shouldRemove;
      });

      target.battleBuff.setActiveList(removeFromStart ? listToInspect.reversed.toList() : listToInspect.toList());
      target.postSubStateProcessing(removedBuffs);

      if (removeCount > 0) {
        battleData.setFuncResult(target.uniqueId, true);
      }
    }
  }

  static Future<bool> shouldSubState(
    final BattleData battleData,
    final BuffData buff,
    final List<int> affectTraits,
    final DataVals dataVals,
    final BattleServantData? activator,
    final BattleServantData target, {
    final BuffData? substituteAddState,
  }) async {
    if (!checkSignedIndividualities2(myTraits: buff.getTraits(), requiredTraits: affectTraits)) {
      return false;
    }

    if (buff.vals.IgnoreIndividuality == 1 || buff.vals.UnSubStateWhileLinkedToOthers == 1) return false;
    if (buff.vals.UnSubState == 1 && dataVals.ForceSubState != 1) return false;
    if (dataVals.ForceSubState == 1) return true;

    final toleranceSubState = await target.getBuffValue(
      battleData,
      BuffAction.toleranceSubstate,
      opponent: activator,
      addTraits: affectTraits,
    );
    final grantSubState =
        await activator?.getBuffValue(
          battleData,
          BuffAction.grantSubstate,
          opponent: target,
          addTraits: affectTraits,
        ) ??
        0;

    // TODO: double check substitute formula
    final substituteRate = substituteAddState?.vals.SubstituteRate ?? 0;
    final substituteResist = substituteAddState?.vals.SubstituteResist ?? 0;
    final functionRate = dataVals.Rate ?? 1000;
    final activationRate = functionRate + grantSubState - substituteRate;
    final resistRate = toleranceSubState + substituteResist;
    final success = await battleData.canActivateFunction(activationRate - resistRate);
    final resultsString = success
        ? S.current.success
        : resistRate > 0
        ? 'GUARD'
        : 'MISS';

    battleData.battleLogger.debug(
      '${S.current.effect_target}: ${target.lBattleName} - ${buff.buff.lName.l}'
      '$resultsString'
      '${battleData.options.tailoredExecution ? '' : ' [($activationRate - $resistRate) vs ${battleData.options.threshold}]'}',
    );

    return success;
  }
}
