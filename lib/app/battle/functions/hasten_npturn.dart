import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/models/gamedata/const_data.dart';
import 'package:chaldea/models/gamedata/vals.dart';

class HastenNpturn {
  HastenNpturn._();

  static Future<void> hastenNpturn(
    BattleData battleData,
    DataVals dataVals,
    BattleServantData? activator,
    Iterable<BattleServantData> targets, {
    bool isNegative = false,
  }) async {
    final functionRate = dataVals.Rate ?? 1000;

    for (final target in targets) {
      if (!target.isEnemy) continue;

      bool shouldChange = true;
      if (isNegative) {
        final resistRate = await target.getBuffValue(battleData, BuffAction.resistanceDelayNpturn, opponent: activator);
        shouldChange = await battleData.canActivateFunction(functionRate - resistRate);
      }

      if (shouldChange) {
        target.changeNPLineCount(isNegative ? -dataVals.Value! : dataVals.Value!);
        battleData.setFuncResult(target.uniqueId, true);
      }
    }
  }

  static Future<void> hastenNpturnFromConsumed(
    BattleData battleData,
    DataVals dataVals,
    int consumed,
    BattleServantData? activator,
    Iterable<BattleServantData> targets, {
    bool isNegative = false,
  }) async {
    final functionRate = dataVals.Rate ?? 1000;

    for (final target in targets) {
      if (!target.isEnemy) continue;

      bool shouldChange = true;
      if (isNegative) {
        final resistRate = await target.getBuffValue(battleData, BuffAction.resistanceDelayNpturn, opponent: activator);
        shouldChange = await battleData.canActivateFunction(functionRate - resistRate);
      }

      if (shouldChange && consumed > 0) {
        final changePercent = toModifier(isNegative ? -dataVals.Value! : dataVals.Value!);
        final lineChange = (consumed * changePercent).toInt();
        target.changeNPLineCount(lineChange);
        battleData.setFuncResult(target.uniqueId, true);
      }
    }
  }
}
