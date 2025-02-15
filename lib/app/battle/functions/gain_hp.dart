import 'package:chaldea/app/battle/interactions/damage_value_adjustor.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class GainHP {
  GainHP._();

  static final lethalFuncTypes = {FuncType.lossHp, FuncType.lossHpPer, FuncType.damageValue};
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

    final isPercent = percentFuncTypes.contains(funcType);

    for (final target in targets) {
      if (target.hp <= 0) {
        continue;
      }

      final previousHp = target.hp;
      final baseValue = isPercent ? target.maxHp * toModifier(dataVals.Value!) : dataVals.Value!;
      final healGrantEff = await activator?.getBuffValue(battleData, BuffAction.giveGainHp, opponent: target) ?? 1000;
      final healReceiveEff = await target.getBuffValue(battleData, BuffAction.gainHp);
      final finalHeal = (baseValue * toModifier(healReceiveEff) * toModifier(healGrantEff)).toInt();
      target.heal(finalHeal);
      target.procAccumulationDamage(previousHp);
      battleData.setFuncResult(target.uniqueId, true);
    }
  }

  static Future<void> lossHP(
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
    final isLethal = lethalFuncTypes.contains(funcType);
    final isPercent = percentFuncTypes.contains(funcType);

    for (final target in targets) {
      if (target.hp <= 0) {
        continue;
      }

      final previousHp = target.hp;
      final baseValue = isPercent ? (target.maxHp * toModifier(dataVals.Value!)).toInt() : dataVals.Value!;
      int finalValue = baseValue;
      if (dataVals.Value2 != null) {
        final upperBound = isPercent ? (target.maxHp * toModifier(dataVals.Value2!).toInt()) : dataVals.Value2!;
        finalValue = await DamageValueAdjustor.show(battleData, activator, target, funcType, baseValue, upperBound);
      }

      target.lossHp(finalValue, lethal: isLethal);
      target.actionHistory.add(
        BattleServantActionHistory(
          actType: BattleServantActionHistoryType.hploss,
          targetUniqueId: activator?.uniqueId ?? -1,
          isOpponent: false,
        ),
      );
      target.procAccumulationDamage(previousHp);
      battleData.setFuncResult(target.uniqueId, true);
    }
  }

  // basically the same as lossHp
  static Future<void> damageValue(
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

    final isLethal = funcType == FuncType.damageValueSafe;
    for (final target in targets) {
      if (target.hp <= 0) {
        continue;
      }

      final previousHp = target.hp;
      final baseVal = dataVals.Value!;
      int finalValue = baseVal;
      if (dataVals.Value2 != null) {
        finalValue = await DamageValueAdjustor.show(battleData, activator, target, funcType, baseVal, dataVals.Value2!);
      }

      target.lossHp(finalValue, lethal: isLethal);
      target.actionHistory.add(
        BattleServantActionHistory(
          actType: BattleServantActionHistoryType.damageValue,
          targetUniqueId: activator?.uniqueId ?? -1,
          isOpponent: false,
        ),
      );
      target.procAccumulationDamage(previousHp);
      battleData.setFuncResult(target.uniqueId, true);
    }
  }
}
