import 'dart:math';

import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';

class GainHpFromTargets {
  GainHpFromTargets._();

  static Future<void> gainHpFromTargets(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.probabilityThreshold) {
      return;
    }

    final dependFunction = await getDependFunc(battleData.battleLogger, dataVals);
    final dependVal = dataVals.DependFuncVals!;
    final checkValue = dependVal.Value!;
    final Map<int, bool> currentFunctionResults = battleData.curFuncResults.deepCopy();

    for (final receiver in targets) {
      await battleData.withTarget(receiver, () async {
        // denoting who should receive the absorbed hp
        int gainValue = 0;
        for (final absorbTarget in await FunctionExecutor.acquireFunctionTarget(
          battleData,
          dependFunction.funcTargetType,
          receiver,
          funcId: dependFunction.funcId,
        )) {
          gainValue += min(absorbTarget.hp - 1, checkValue);
        }

        await receiver.heal(battleData, gainValue);
        currentFunctionResults[receiver.uniqueId] = true;
      });
    }

    final NiceFunction niceFunction = NiceFunction(
        funcId: dependFunction.funcId,
        funcType: dependFunction.funcType,
        funcTargetType: dependFunction.funcTargetType,
        funcTargetTeam: dependFunction.funcTargetTeam,
        funcPopupText: dependFunction.funcPopupText,
        funcPopupIcon: dependFunction.funcPopupIcon,
        functvals: dependFunction.functvals,
        funcquestTvals: dependFunction.funcquestTvals,
        funcGroup: dependFunction.funcGroup,
        traitVals: dependFunction.traitVals,
        buffs: dependFunction.buffs,
        // Rate of dataVals.DependFuncVals is always 0, not sure why, so substituting functionRate into it
        svals: [
          DataVals({'Rate': functionRate, 'Value': checkValue})
        ]);

    final updatedResult = await FunctionExecutor.executeFunction(battleData, niceFunction, 1); // we provisioned only one dataVal

    if (updatedResult) {
      battleData.uniqueIdToLastFuncResultStack.removeLast();
    }

    battleData.curFuncResults.addAll(currentFunctionResults);
  }
}
