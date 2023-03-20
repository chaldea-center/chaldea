import 'dart:math';

import 'package:chaldea/app/battle/functions/function_executor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class GainHpFromTargets {
  GainHpFromTargets._();

  static Future<bool> gainHpFromTargets(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.probabilityThreshold) {
      return false;
    }

    final BaseFunction dependFunction = db.gameData.baseFunctions[dataVals.DependFuncId!]!;
    final dependVal = dataVals.DependFuncVals!;
    final checkValue = dependVal.Value!;

    for (final receiver in targets) {
      battleData.setTarget(receiver);
      //  denoting who should receive the absorbed hp
      int gainValue = 0;
      for (final absorbTarget in FunctionExecutor.acquireFunctionTarget(
        battleData,
        dependFunction.funcTargetType,
        dependFunction.funcId,
        receiver,
      )) {
        gainValue += min(absorbTarget.hp - 1, checkValue);
      }

      receiver.heal(battleData, gainValue);
      battleData.unsetTarget();
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

    await FunctionExecutor.executeFunction(battleData, niceFunction, 1); // we provisioned only one dataVal

    return true;
  }
}
