import 'dart:math';

import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class GainHpFromTargets {
  GainHpFromTargets._();

  static Future<void> gainHpFromTargets(
    final BattleData battleData,
    final DataVals dataVals,
    final BattleServantData receiver,
    final BattleServantData? targetedAlly,
    final BattleServantData? targetedEnemy,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    final dependFunction = await getDependFunc(battleData.battleLogger, dataVals);
    final dependVal = dataVals.DependFuncVals!;
    final checkValue = dependVal.Value!;

    final previousHp = receiver.hp;
    // denoting who should receive the absorbed hp
    int gainValue = 0;
    for (final absorbTarget in await FunctionExecutor.acquireFunctionTarget(
      battleData,
      dependFunction.funcTargetType,
      receiver,
      funcId: dependFunction.funcId,
      targetedAlly: receiver,
      targetedEnemy: battleData.targetedEnemy,
    )) {
      gainValue += min(absorbTarget.hp - 1, checkValue);
    }

    receiver.heal(gainValue);
    receiver.procAccumulationDamage(previousHp);
    battleData.setFuncResult(receiver.uniqueId, true);

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
      vals: dependFunction.vals,
      buffs: dependFunction.buffs,
      svals: [dependVal],
    );

    // we provisioned only one dataVal
    await FunctionExecutor.executeFunctions(
      battleData,
      [niceFunction],
      1,
      activator: receiver,
      targetedAlly: targetedAlly,
      targetedEnemy: targetedEnemy,
    );
  }
}
