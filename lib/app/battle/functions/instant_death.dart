import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/basic.dart';

class InstantDeath {
  InstantDeath._();

  static bool instantDeath(
    final BattleData battleData,
    final DataVals dataVals,
    final List<BattleServantData> targets, {
    final bool force = false,
  }) {
    final activator = battleData.activator;
    bool success = false;
    for (final target in targets) {
      if (force || shouldInstantDeath(battleData, dataVals, activator, target)) {
        target.hp = 0;
        success = true;
      }
    }

    return success;
  }

  static bool shouldInstantDeath(
    final BattleData battleData,
    final DataVals dataVals,
    final BattleServantData? activator,
    final BattleServantData target,
  ) {
    if (target.hasBuffOnAction(battleData, BuffAction.avoidInstantdeath)) {
      battleData.logger.debug('${S.current.effect_target}: ${target.lBattleName} - ${S.current.battle_invalid}');
      return false;
    }

    final resistInstantDeath = target.getBuffValueOnAction(battleData, BuffAction.resistInstantdeath);
    final nonResistInstantDeath = target.getBuffValueOnAction(battleData, BuffAction.nonresistInstantdeath);
    final grantInstantDeathDetails = ConstData.buffActions[BuffAction.grantInstantdeath]!;
    final grantInstantDeath = activator?.getBuffValueOnAction(battleData, BuffAction.grantInstantdeath) ??
        capBuffValue(grantInstantDeathDetails, 0, Maths.min(grantInstantDeathDetails.maxRate));

    final functionRate = dataVals.Rate ?? 1000;
    final resistRate = resistInstantDeath - nonResistInstantDeath;
    final activationRate =
        (functionRate * toModifier(target.deathRate) * (1000 + grantInstantDeath - resistRate)).toInt();
    final success = activationRate >= battleData.probabilityThreshold;
    final resultsString = success
        ? S.current.success
        : resistRate > 1000
            ? 'GUARD'
            : 'MISS';

    battleData.logger.debug('${S.current.effect_target}: ${target.lBattleName}'
        ' - ${S.current.info_death_rate}'
        ' - $resultsString ($activationRate vs ${battleData.probabilityThreshold})');

    return success;
  }
}
