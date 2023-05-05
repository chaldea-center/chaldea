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
    if (functionRate < battleData.options.probabilityThreshold) {
      return;
    }

    for (final target in targets) {
      final nonnullOnFieldList = target.isPlayer ? battleData.nonnullAllies : battleData.nonnullEnemies;
      if (nonnullOnFieldList.length == 1) {
        continue;
      }

      final onFieldList = target.isPlayer ? battleData.onFieldAllyServants : battleData.onFieldEnemies;
      final backupList = target.isPlayer ? battleData.playerDataList : battleData.enemyDataList;

      final onFieldIndex = onFieldList.indexOf(target);
      if (onFieldIndex == -1) {
        backupList[backupList.indexOf(target)] = null;
      } else {
        onFieldList[onFieldList.indexOf(target)] = null;
      }
      backupList.add(target);
      battleData.curFuncResults[target.uniqueId] = true;
    }
  }
}
