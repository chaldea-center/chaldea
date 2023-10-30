import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class GainHP {
  GainHP._();

  static final lossFuncTypes = {FuncType.lossHp, FuncType.lossHpSafe, FuncType.lossHpPer, FuncType.lossHpPerSafe};
  static final lethalFuncTypes = {FuncType.lossHp, FuncType.lossHpPer};
  static final percentFuncTypes = {FuncType.gainHpPer, FuncType.lossHpPer, FuncType.lossHpPerSafe};

  static Future<void> gainHP(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
    final FuncType funcType,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }
    final isLoss = lossFuncTypes.contains(funcType);
    final isLethal = lethalFuncTypes.contains(funcType);
    final isPercent = percentFuncTypes.contains(funcType);

    for (final target in targets) {
      await battleData.withTarget(target, () async {
        final baseValue = isPercent ? target.getMaxHp(battleData) * toModifier(dataVals.Value!) : dataVals.Value!;
        if (isLoss) {
          target.lossHp(baseValue.toInt(), lethal: isLethal);
        } else {
          final healGrantEff =
              toModifier(await battleData.activator?.getBuffValueOnAction(battleData, BuffAction.giveGainHp) ?? 1000);
          final healReceiveEff = toModifier(await target.getBuffValueOnAction(battleData, BuffAction.gainHp));
          final finalHeal = (baseValue * healReceiveEff * healGrantEff).toInt();
          await target.heal(battleData, finalHeal);
        }
        battleData.curFuncResults[target.uniqueId] = true;
      });
    }
  }
}
