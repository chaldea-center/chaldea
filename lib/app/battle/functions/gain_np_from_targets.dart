import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/extension.dart';
import '../utils/battle_utils.dart';

class GainNpFromTargets {
  GainNpFromTargets._();

  static Future<void> gainNpFromTargets(
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
        // denoting who should receive the absorbed np
        int gainValue = 0;
        for (final absorbTarget in await FunctionExecutor.acquireFunctionTarget(
          battleData,
          dependFunction.funcTargetType,
          receiver,
          funcId: dependFunction.funcId,
        )) {
          final targetNP = absorbTarget.isPlayer ? absorbTarget.np : absorbTarget.npLineCount;
          // ignoring Value2 for enemy here as the only usage is in Yuyu (svt 275)'s skill 2
          // which has value 100 (I assume that's a percentage? But doesn't make sense)
          final baseGainValue = receiver.isEnemy ? 1 : dependVal.Value2 ?? checkValue;

          if (targetNP >= checkValue) {
            gainValue += baseGainValue;
          } else if (receiver.isPlayer && absorbTarget.isPlayer) {
            gainValue += targetNP;
          }
        }

        if (receiver.isEnemy) {
          receiver.changeNPLineCount(gainValue);
        } else {
          receiver.changeNP(gainValue);
        }
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

    final updatedResult =
        await FunctionExecutor.executeFunction(battleData, niceFunction, 1); // we provisioned only one dataVal

    if (updatedResult) {
      battleData.uniqueIdToFuncResultsList.removeLast();
    }

    battleData.curFuncResults.addAll(currentFunctionResults);
  }
}
