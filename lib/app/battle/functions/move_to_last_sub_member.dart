import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class MoveToLastSubMember {
  MoveToLastSubMember._();

  static void moveToLastSubMember(
    final BattleData battleData,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    for (final target in targets) {
      final nonnullOnFieldList = target.isPlayer ? battleData.nonnullPlayers : battleData.nonnullEnemies;
      if (nonnullOnFieldList.length == 1) {
        continue;
      }
      if (!target.canAttack()) {
        continue;
      }

      for (final svt in battleData.nonnullPlayers) {
        svt.battleBuff.removeBuffOfType(BuffType.fixCommandcard);
      }

      final onFieldList = target.isPlayer ? battleData.onFieldAllyServants : battleData.onFieldEnemies;
      final backupList = target.isPlayer ? battleData.backupAllyServants : battleData.backupEnemies;

      final onFieldIndex = onFieldList.indexOf(target);
      final backupIndex = backupList.indexOf(target);
      if (onFieldIndex == -1 && backupIndex >= 0) {
        backupList[backupIndex] = null;
      } else if (onFieldIndex >= 0) {
        onFieldList[onFieldIndex] = null;
      }
      backupList.add(target);
      battleData.setFuncResult(target.uniqueId, true);
    }
  }
}
