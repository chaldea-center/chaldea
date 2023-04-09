import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class MoveToLastSubMember {
  MoveToLastSubMember._();

  static bool moveToLastSubMember(
    final BattleData battleData,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.probabilityThreshold) {
      return false;
    }

    for (final svt in targets) {
      final nonnullOnFieldList = svt.isPlayer ? battleData.nonnullAllies : battleData.nonnullEnemies;
      if (nonnullOnFieldList.length == 1) {
        continue;
      }

      final onFieldList = svt.isPlayer ? battleData.onFieldAllyServants : battleData.onFieldEnemies;
      final backupList = svt.isPlayer ? battleData.playerDataList : battleData.enemyDataList;

      final onFieldIndex = onFieldList.indexOf(svt);
      if (onFieldIndex == -1) {
        backupList[backupList.indexOf(svt)] = null;
      } else {
        onFieldList[onFieldList.indexOf(svt)] = null;
      }
      backupList.add(svt);
    }

    return true;
  }
}
