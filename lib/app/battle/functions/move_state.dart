import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
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

    for (final receiver in targets) {
      // denoting who should receive the absorbed hp
      for (final absorbTarget in await FunctionExecutor.acquireFunctionTarget(
        battleData,
        dependFunction.funcTargetType,
        receiver,
        funcId: dependFunction.funcId,
        target: receiver,
      )) {
        for (final buff in absorbTarget.getBuffsWithTraits(affectTraits)) {
          receiver.addBuff(buff.copy());
        }
      }
      battleData.setFuncResult(receiver.uniqueId, true);
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

    // we provisioned only one dataVal
    await FunctionExecutor.executeFunctions(battleData, [niceFunction], 1, script: null);
  }
}
