import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class UpdateEntryPositions {
  UpdateEntryPositions._();

  static void updateEntryPositions(
    final BattleData battleData,
    final DataVals dataVals,
  ) {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    if (dataVals.OnPositions != null) {
      for (final onPosition in dataVals.OnPositions!) {
        if (onPosition > 0 && onPosition <= battleData.enemyValidAppear.length) {
          battleData.enemyValidAppear[onPosition - 1] = true;
        }
      }
    }

    if (dataVals.OffPositions != null) {
      for (final offPosition in dataVals.OffPositions!) {
        if (offPosition > 0 && offPosition <= battleData.enemyValidAppear.length) {
          battleData.enemyValidAppear[offPosition - 1] = false;
        }
      }
    }
  }
}
