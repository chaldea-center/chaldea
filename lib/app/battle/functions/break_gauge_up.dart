import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/func.dart';
import 'package:chaldea/models/gamedata/vals.dart';

class BreakGaugeUp {
  const BreakGaugeUp._();

  static Future<void> breakGaugeUp(
    final BattleData battleData,
    final FuncType funcType,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) async {
    final isDown = funcType == FuncType.breakGaugeDown;
    int value = dataVals.Value ?? 0;
    final changeMaxGauge = dataVals.ChangeMaxBreakGauge == 1;
    if (isDown) {
      value *= -1;
    }

    for (final target in targets) {
      await battleData.withTarget(target, () async {
        if (value != 0) {
          target.shiftDeckIndex -= value;
          target.shiftDeckIndex = target.shiftDeckIndex.clamp(-1, target.shiftNpcIds.length - 1);
          if (changeMaxGauge) {
            target.shiftLowLimit -= value;
            target.shiftLowLimit = target.shiftLowLimit.clamp(0, target.shiftNpcIds.length - 1);
          }

          if (target.shiftLowLimit > target.shiftDeckIndex + 1) {
            // number of shifts exceed current limit, bump
            target.shiftLowLimit = target.shiftDeckIndex + 1;
          }

          target.shiftDeckIndex -= 1; // go to previous shift to shift to desired shift
          await target.shift(battleData);
        }

        battleData.setFuncResult(target.uniqueId, true);
      });
    }
  }
}
