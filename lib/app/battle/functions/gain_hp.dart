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
    final BattleServantData? activator,
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
      if (target.hp <= 0) {
        continue;
      }

      final previousHp = target.hp;
      final baseValue = isPercent ? target.maxHp * toModifier(dataVals.Value!) : dataVals.Value!;
      if (isLoss) {
        target.lossHp(baseValue.toInt(), lethal: isLethal);
        target.actionHistory.add(BattleServantActionHistory(
          actType: BattleServantActionHistoryType.hploss,
          targetUniqueId: activator?.uniqueId ?? -1,
          isOpponent: false,
        ));
      } else {
        final healGrantEff = await activator?.getBuffValue(battleData, BuffAction.giveGainHp, other: target) ?? 1000;
        final healReceiveEff = await target.getBuffValue(battleData, BuffAction.gainHp);
        final finalHeal = (baseValue * toModifier(healReceiveEff) * toModifier(healGrantEff)).toInt();
        target.heal(finalHeal);
      }
      target.procAccumulationDamage(previousHp);
      battleData.setFuncResult(target.uniqueId, true);
    }
  }
}
