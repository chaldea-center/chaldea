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
        target.skillShift(battleData, skillShiftSvt);
        await battleData.initActorSkills([target]);
        battleData.curFuncResults[target.uniqueId] = true;
      }

      battleData.unsetTarget();
    }
  }

  static Future<void> changeServant(
    final BattleData battleData,
    final DataVals dataVals,
    final BattleServantData? actor,
  ) async {
    if (actor == null || actor.isPlayer) return;
    final changeIndex = dataVals.Value!;
    if (changeIndex == 0) {
      // if changeIndex == 0: reset to original enemy. Same for shift.
      return;
    }
    final changeNpcId = actor.changeNpcIds.getOrNull(actor.shiftIndex); // use shiftIndex here!
    final changeSvt = battleData.enemyDecks[DeckType.change]?.firstWhereOrNull((e) => e.npcId == changeNpcId);
    if (changeSvt == null) {
      battleData.battleLogger.error('ChangeServant NpcId=$changeNpcId not found');
      return;
    }
    battleData.battleLogger.function('ChangeServant to NpcId=$changeNpcId');

    if (changeSvt.enemyScript.shift?.isNotEmpty == true) {
      actor.shiftNpcIds = changeSvt.enemyScript.shift!.toList();
    }

    battleData.setTarget(actor);
    actor.changeIndex = changeIndex;
    actor.niceEnemy = changeSvt;
    actor.atk = changeSvt.atk;
    // actor.hp = targetEnemy.hp;
    actor.maxHp = changeSvt.hp;
    actor.level = changeSvt.lv;
    actor.battleBuff.clearPassive(actor.uniqueId);
    actor.initScript(battleData);
    await battleData.initActorSkills([actor]);
    battleData.unsetTarget();
  }
}
