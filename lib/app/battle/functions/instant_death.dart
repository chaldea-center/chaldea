import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

class InstantDeath {
  InstantDeath._();

  static Future<void> instantDeath(
    final BattleData battleData,
    final DataVals dataVals,
    final NiceFunction func,
    final BattleServantData? activator,
    final List<BattleServantData> targets, {
    final CommandCardData? card,
    final bool defaultToPlayer = true,
  }) async {
    final force = func.funcType == FuncType.forceInstantDeath;
    final record = BattleInstantDeathRecord(forceInstantDeath: force, activator: activator, targets: []);
    for (final target in targets) {
      final params = InstantDeathParameters();
      final previousHp = target.hp;
      final isForceInstantDeath = force || (activator == target && dataVals.ForceSelfInstantDeath == 1);

      if (await shouldInstantDeath(battleData, dataVals, activator, target, isForceInstantDeath, params, card: card)) {
        target.hp = 0;
        target.lastHitBy = activator;
        target.lastHitByFunc = func;
        target.actionHistory.add(
          BattleServantActionHistory(
            actType: BattleServantActionHistoryType.instantDeath,
            targetUniqueId: activator?.uniqueId ?? -1,
            isOpponent: (activator?.isPlayer ?? defaultToPlayer) != target.isPlayer,
          ),
        );

        if (!isForceInstantDeath && target != activator) {
          target.procAccumulationDamage(previousHp);
        }
        battleData.setFuncResult(target.uniqueId, true);
      }
      record.targets.add(InstantDeathResultDetail(target: target, params: params));
    }
    if (targets.isNotEmpty) {
      battleData.recorder.instantDeath(record);
    }
  }

  static Future<bool> shouldInstantDeath(
    final BattleData battleData,
    final DataVals dataVals,
    final BattleServantData? activator,
    final BattleServantData target,
    final bool isForceInstantDeath,
    InstantDeathParameters? params, {
    final CommandCardData? card,
  }) async {
    params ??= InstantDeathParameters();
    params.isForce = isForceInstantDeath;
    if (params.isForce) {
      params.success = true;
      params.resultString = S.current.success;
      battleData.battleLogger.debug(
        '${S.current.effect_target}: ${target.lBattleName} - ${S.current.force_instant_death}',
      );
      return true;
    }

    if (await target.hasBuff(battleData, BuffAction.avoidInstantdeath, opponent: activator)) {
      params.immune = true;
      params.success = false;
      params.resultString = kBattleFuncNoEffect;
      battleData.battleLogger.debug('${S.current.effect_target}: ${target.lBattleName} - ${S.current.battle_invalid}');
      return false;
    }

    final resistInstantDeath = await target.getBuffValue(
      battleData,
      BuffAction.resistInstantdeath,
      opponent: activator,
    );
    final nonResistInstantDeath = await target.getBuffValue(
      battleData,
      BuffAction.nonresistInstantdeath,
      opponent: activator,
    );
    final grantInstantDeath =
        await activator?.getBuffValue(battleData, BuffAction.grantInstantdeath, opponent: target, card: card) ?? 0;

    final functionRate = dataVals.Rate ?? 1000;
    final resistRate = resistInstantDeath - nonResistInstantDeath;
    final buffRate = grantInstantDeath - resistRate;
    final activationRate = (functionRate * toModifier(target.deathRate) * toModifier(1000 + buffRate)).toInt();
    final success = await battleData.canActivateFunction(activationRate);
    final resultsString =
        success
            ? S.current.success
            : resistRate > 0
            ? kBattleFuncGUARD
            : kBattleFuncMiss;

    params
      ..functionRate = functionRate
      ..deathRate = target.deathRate
      ..buffRate = buffRate
      ..activateRate = activationRate
      ..success = success
      ..resultString = resultsString;
    battleData.battleLogger.debug(
      '${S.current.effect_target}: ${target.lBattleName} - '
      '$resultsString'
      '${battleData.options.tailoredExecution ? '' : ' [$activationRate vs ${battleData.options.threshold}]'}',
    );

    return success;
  }
}
