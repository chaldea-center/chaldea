import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/models/gamedata/vals.dart';

class TransformServant {
  TransformServant._();

  static Future<bool> transformServant(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
  ) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.probabilityThreshold) {
      return false;
    }

    for (final target in targets) {
      if (target.isEnemy) {
        continue;
      }

      final targetSvtId = dataVals.Value!;
      if (targetSvtId == 304800) {
        // lazy transform svt 312
        target.ascensionPhase = dataVals.SetLimitCount!;
        target.skillInfoList[2].rawSkill = target.niceSvt!.groupedActiveSkills[2][1];
        target.npStrengthenLv = 2;
      } else {
        final targetSvt = await AtlasApi.svt(targetSvtId);
        if (targetSvt == null) {
          battleData.logger.debug('${S.current.not_found}: $targetSvtId');
        } else {
          target.niceSvt = targetSvt;
        }
      }
    }

    return true;
  }
}
