import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class ShortenSkill {
  ShortenSkill._();

  static bool shortenSkill(
    final BattleData battleData,
    final DataVals dataVals,
    final List<BattleServantData> targets,
  ) {
    for (final svt in targets) {
      svt.skillInfoList.forEach((element) {
        element.shortenSkill(dataVals.Value!);
      });
    }
    return true;
  }
}
