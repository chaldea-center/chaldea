import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/extension.dart';
import '../utils/battle_utils.dart';

class MoveState {
  MoveState._();

  static Future<void> moveState(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    final dependFunction = await getDependFunc(battleData.battleLogger, dataVals);
    final dependVal = dataVals.DependFuncVals!;
    final affectTraits = dependFunction.traitVals;
    final Map<int, bool> currentFunctionResults = battleData.curFuncResults.deepCopy();

    for (final receiver in targets) {
      // denoting who should receive the absorbed hp
      await battleData.withTarget(receiver, () async {
        for (final absorbTarget in await FunctionExecutor.acquireFunctionTarget(
          battleData,
          dependFunction.funcTargetType,
          receiver,
          funcId: dependFunction.funcId,
        )) {
          for (final buff in absorbTarget.getBuffsWithTraits(affectTraits)) {
            receiver.addBuff(buff.copy());
          }
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
        svals: [dependVal]);

    final updatedResult =
        await FunctionExecutor.executeFunction(battleData, niceFunction, 1); // we provisioned only one dataVal

    if (updatedResult) {
      battleData.uniqueIdToFuncResultsList.removeLast();
    }

    battleData.curFuncResults.addAll(currentFunctionResults);
  }
}
