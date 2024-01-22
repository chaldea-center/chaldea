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
      await battleData.withTarget(target, () async {
        final shiftNpcId = dataVals.ShiftNpcId ?? 0;
        final skillShiftSvt =
            battleData.enemyDecks[DeckType.skillShift]?.firstWhereOrNull((e) => e.npcId == shiftNpcId);
        if (skillShiftSvt == null) {
          battleData.battleLogger.error('SkillShift NpcId=$shiftNpcId not found');
        } else {
          await target.skillShift(battleData, skillShiftSvt);
          await battleData.initActorSkills([target]);
          battleData.setFuncResult(target.uniqueId, true);
        }
      });
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
    final changeNpcId = actor.changeNpcIds.getOrNull(actor.shiftDeckIndex + 1); // use shiftIndex here!
    final changeSvt = battleData.enemyDecks[DeckType.change]?.firstWhereOrNull((e) => e.npcId == changeNpcId);
    if (changeSvt == null) {
      battleData.battleLogger.error('ChangeServant NpcId=$changeNpcId not found');
      return;
    }
    battleData.battleLogger.function('ChangeServant to NpcId=$changeNpcId');

    if (changeSvt.enemyScript.shift?.isNotEmpty == true) {
      actor.shiftNpcIds = changeSvt.enemyScript.shift!.toList();
    }

    await actor.changeServant(battleData, changeSvt);
  }
}
