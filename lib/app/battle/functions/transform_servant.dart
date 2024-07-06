import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/extension.dart';
import '../../../models/db.dart';

class TransformServant {
  TransformServant._();

  static Future<void> transformServant(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    for (final target in targets) {
      if (target.isPlayer) {
        await _transformAlly(battleData, dataVals, target);
      } else {
        await _transformEnemy(battleData, dataVals, target);
      }

      battleData.setFuncResult(target.uniqueId, true);
    }
  }

  static Future<void> _transformAlly(BattleData battleData, DataVals dataVals, BattleServantData target) async {
    final targetSvtId = dataVals.Value!;
    Servant? targetSvt =
        db.gameData.servantsById[targetSvtId] ?? await showEasyLoading(() => AtlasApi.svt(targetSvtId), mask: true);
    if (targetSvt == null) {
      battleData.battleLogger.error('${S.current.not_found}: $targetSvtId');
      return;
    }

    await target.transformAlly(battleData, targetSvt, dataVals);
  }

  static Future<void> _transformEnemy(BattleData battleData, DataVals dataVals, BattleServantData target) async {
    final targetSvtId = dataVals.Value!;
    final targetEnemy = battleData.enemyDecks[DeckType.transform]?.firstWhereOrNull((enemy) => enemy.id == targetSvtId);
    if (targetEnemy == null) {
      battleData.battleLogger.error('${S.current.not_found}: $targetSvtId');
      return;
    }

    await target.transformEnemy(battleData, targetEnemy);
  }
}
