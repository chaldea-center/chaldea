import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/extension.dart';

class CallServant {
  CallServant._();

  static Future<void> callServant(
    final BattleData battleData,
    final DataVals dataVals,
    final BattleServantData? activator,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    if (activator != null && activator.isPlayer) {
      return;
    }

    final callIndex = dataVals.Value!;
    int? callSvtNpcId = activator?.niceEnemy!.enemyScript.call?.getOrNull(callIndex);
    callSvtNpcId ??= battleData.curStage?.call.getOrNull(callIndex);
    final callSvt = battleData.enemyDecks[DeckType.call]?.firstWhereOrNull((e) => e.npcId == callSvtNpcId);
    if (callSvt != null) {
      for (int index = 0; index < battleData.enemyOnFieldCount; index++) {
        if (battleData.onFieldEnemies[index] == null && battleData.enemyValidAppear[index]) {
          // init & entry enemy
          final actor = BattleServantData.fromEnemy(callSvt, battleData.getNextUniqueId());
          if (battleData.options.simulateEnemy) {
            await actor.loadEnemySvtData(battleData);
          }
          battleData.onFieldEnemies[index] = actor;
          await actor.initScript(battleData);
          await battleData.initActorSkills([actor]);
          await actor.enterField(battleData);
          break;
        }
      }
    }
  }
}
