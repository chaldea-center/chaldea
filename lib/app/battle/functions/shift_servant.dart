import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import '../models/battle.dart';

class ShiftServant {
  const ShiftServant._();

  static Future<void> skillShift(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.probabilityThreshold) {
      return;
    }

    for (final target in targets) {
      if (target.isPlayer) {
        continue;
      }
      battleData.setTarget(target);
      final shiftNpcId = dataVals.ShiftNpcId ?? 0;
      final skillShiftSvt = battleData.enemyDecks[DeckType.skillShift]?.firstWhereOrNull((e) => e.npcId == shiftNpcId);
      if (skillShiftSvt == null) {
        battleData.battleLogger.error('SkillShift NpcId=$shiftNpcId not found');
        battleData.curFuncResults[target.uniqueId] = false;
      } else {
        await target.skillShift(battleData, skillShiftSvt);
        battleData.curFuncResults[target.uniqueId] = true;
      }

      battleData.unsetTarget();
    }
  }
}
