import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/basic.dart';

class DamageNpCounter {
  DamageNpCounter._();

  static void damageNpCounter(
    final BattleData battleData,
    final DataVals dataVals,
    final BattleServantData? activator,
    final Iterable<BattleServantData> targets,
  ) {
    if (activator == null) {
      // cannot find accumulation damage
      return;
    }

    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    final rate = toModifier(dataVals.Value ?? 0);
    final damage = (activator.accumulationDamage * rate).toInt();
    final List<AttackResultDetail> targetResults = [];

    for (final target in targets) {
      final targetBefore = target.copy();
      final previousHp = target.hp;
      target.receiveDamage(damage);
      if (target != activator) {
        target.procAccumulationDamage(previousHp);
      }
      target.actionHistory.add(BattleServantActionHistory(
        actType: BattleServantActionHistoryType.damageCommand,
        targetUniqueId: activator.uniqueId,
        isOpponent: activator.isPlayer != target.isPlayer,
      ));
      targetResults.add(AttackResultDetail(
        target: target,
        targetBefore: targetBefore,
        damageParams: DamageParameters(),
        attackNpParams: AttackNpGainParameters(),
        defenseNpParams: DefendNpGainParameters(),
        starParams: StarParameters(),
        result: DamageResult()
          ..damages = [damage]
          ..cardHits = [100]
          ..npGains = [0]
          ..npMaxLimited = [false]
          ..overkillStates = [false],
        minResult: null,
        maxResult: null,
      ));

      battleData.battleLogger.action('${activator.lBattleName} - '
          '${Transl.buffType(BuffType.reflectionFunction).l}: $damage -'
          '${S.current.effect_target}: ${target.lBattleName}');
      battleData.setFuncResult(target.uniqueId, true);
    }
    battleData.recorder.attack(
      activator,
      BattleAttackRecord(
        activator: activator,
        card: null,
        targets: targetResults,
        damage: Maths.sum(targetResults.map((e) => Maths.sum(e.result.damages))),
        attackNp: Maths.sum(targetResults.map((e) => Maths.sum(e.result.npGains))),
        defenseNp: Maths.sum(targetResults.map((e) => Maths.sum(e.result.defNpGains))),
        star: Maths.sum(targetResults.map((e) => Maths.sum(e.result.stars))),
      ),
    );
  }
}
