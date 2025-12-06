import 'dart:math';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class SubFieldBuff {
  SubFieldBuff._();

  static Future<void> subFieldBuff(
    final BattleData battleData,
    final List<int> affectTraits,
    final DataVals dataVals,
    final BattleServantData? activator,
    final List<BattleServantData> targets,
  ) async {
    final removeFromStart = dataVals.Value != null && dataVals.Value! > 0;
    final removeTargetCount = dataVals.Value != null && dataVals.Value2 != null
        ? max(dataVals.Value!, dataVals.Value2!)
        : null;
    int removeCount = 0;
    final List<BuffData> listToInspect = removeFromStart
        ? battleData.fieldBuffs.reversed.toList()
        : battleData.fieldBuffs.toList();
    final List<int> removedFamilyIndiv = [];
    final List<BuffData> removedBuffs = [];

    for (int index = listToInspect.length - 1; index >= 0; index -= 1) {
      final buff = listToInspect[index];

      if (buff.checkField() && await shouldSubFieldBuff(battleData, buff, affectTraits, dataVals)) {
        removedBuffs.add(listToInspect.removeAt(index));
        removeCount += 1;
        if (buff.vals.BehaveAsFamilyBuff == 1 && buff.vals.AddLinkageTargetIndividualty != null) {
          removedFamilyIndiv.add(buff.vals.AddLinkageTargetIndividualty!);
        }
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

    battleData.fieldBuffs.clear();
    battleData.fieldBuffs.addAll((removeFromStart ? listToInspect.reversed.toList() : listToInspect.toList()));
    for (final svt in battleData.nonnullAllActors) {
      svt.postSubStateProcessing(removedBuffs);
    }

    for (final target in targets) {
      if (removeCount > 0) {
        battleData.setFuncResult(target.uniqueId, true);
      }
    }
  }

  static Future<bool> shouldSubFieldBuff(
    final BattleData battleData,
    final BuffData buff,
    final List<int> affectTraits,
    final DataVals dataVals,
  ) async {
    if (!checkSignedIndividualities2(myTraits: buff.getTraits(), requiredTraits: affectTraits)) {
      return false;
    }

    if (buff.vals.IgnoreIndividuality == 1 || buff.vals.UnSubStateWhileLinkedToOthers == 1) return false;
    if (buff.vals.UnSubState == 1 && dataVals.ForceSubState != 1) return false;
    if (dataVals.ForceSubState == 1) return true;

    final functionRate = dataVals.Rate ?? 1000;
    final success = await battleData.canActivateFunction(functionRate);
    final resultsString = success ? S.current.success : 'MISS';

    battleData.battleLogger.debug(
      '${S.current.effect_target}: field - ${buff.buff.lName.l}'
      '$resultsString'
      '${battleData.options.tailoredExecution ? '' : ' [($functionRate - 0) vs ${battleData.options.threshold}]'}',
    );

    return success;
  }
}
