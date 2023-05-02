import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/models/gamedata/const_data.dart';
import 'package:chaldea/models/gamedata/vals.dart';

class GainHP {
  GainHP._();

  static Future<bool> gainHP(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets, {
    final bool isPercent = false,
    final bool isNegative = false,
    final bool isLethal = false,
  }) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.probabilityThreshold) {
      return false;
    }

    for (final target in targets) {
      battleData.setTarget(target);

      if (isNegative) {
        target.lossHp(dataVals.Value!, lethal: isLethal);
      } else {
        final healGrantEff =
            toModifier(await battleData.activator?.getBuffValueOnAction(battleData, BuffAction.giveGainHp) ?? 1000);
        final healReceiveEff = toModifier(await target.getBuffValueOnAction(battleData, BuffAction.gainHp));
        final baseHeal = isPercent ? target.getMaxHp(battleData) * toModifier(dataVals.Value!) : dataVals.Value!;
        final finalHeal = (baseHeal * healReceiveEff * healGrantEff).toInt();
        await target.heal(battleData, finalHeal);
      }

      battleData.unsetTarget();
    }

    return true;
  }
}
