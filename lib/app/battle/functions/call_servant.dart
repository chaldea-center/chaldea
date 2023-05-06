import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/extension.dart';

class CallServant {
  CallServant._();

  static Future<void> callServant(
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
      final callIndex = dataVals.Value!;
      final callSvtNpcId = target.niceEnemy!.enemyScript.call?.getOrNull(callIndex);
      final callSvt = battleData.enemyDecks[DeckType.call]?.firstWhereOrNull((e) => e.npcId == callSvtNpcId);
      if (callSvt != null) {
        bool called = false;
        for (int index = 0; index < battleData.enemyOnFieldCount; index++) {
          if (battleData.onFieldEnemies[index] == null && battleData.enemyValidAppear[index]) {
            // init & entry enemy
            called = true;
            break;
          }
        }
        battleData.curFuncResults[target.uniqueId] = called;
      }
      battleData.unsetTarget();
    }
  }
}
