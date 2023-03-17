import 'dart:math';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';

class Damage {
  Damage._();

  static final List<BuffAction> powerMods = [
    BuffAction.damage,
    BuffAction.damageIndividuality,
    BuffAction.damageIndividualityActiveonly,
    BuffAction.damageEventPoint
  ];

  static Future<bool> damage(
    final BattleData battleData,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets,
    final int chainPos,
    final bool isTypeChain,
    final bool isMightyChain,
    final CardType firstCardType, {
    final bool isPierceDefense = false,
    final bool checkHpRatio = false,
    final bool checkBuffTraits = false,
    final bool individualSum = false,
  }) async {
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.probabilityThreshold) {
      return false;
    }

    final activator = battleData.activator!;
    final currentCard = battleData.currentCard!;

    for (final target in targets) {
      battleData.setTarget(target);

      final classAdvantage = getClassRelation(battleData, activator, target, currentCard);

      final additionDamageRate = checkHpRatio && dataVals.Target != null
          ? ((1 - activator.hp / activator.getMaxHp(battleData)) * dataVals.Target!).toInt()
          : 0;

      int specificAttackRate = 1000;
      if (!checkHpRatio && dataVals.Target != null) {
        if (!individualSum) {
          final requiredTraits = [NiceTrait(id: dataVals.Target!)];
          final useCorrection = checkBuffTraits
              ? containsAnyTraits(
                  target.getBuffTraits(battleData, ignoreIrremovable: dataVals.IgnoreIndivUnreleaseable == 1),
                  requiredTraits)
              : containsAnyTraits(target.getTraits(battleData), requiredTraits);

          if (useCorrection) {
            specificAttackRate = dataVals.Correction!;
          }
        } else {
          final countTarget = dataVals.Target! == 1 ? target : activator;
          final requiredTraits = dataVals.TargetList!.map((traitId) => NiceTrait(id: traitId)).toList();
          int useCount = checkBuffTraits
              ? countTarget.countBuffWithTrait(requiredTraits)
              : countTarget.countTrait(battleData, requiredTraits);
          if (dataVals.ParamAddMaxCount != null && dataVals.ParamAddMaxCount! > 0) {
            useCount = min(useCount, dataVals.ParamAddMaxCount!);
          }
          specificAttackRate = dataVals.Value2! + useCount * dataVals.Correction!;
        }
      }

      final damageParameters = DamageParameters()
        ..attack = activator.attack + currentCard.cardStrengthen
        ..totalHits = Maths.sum(currentCard.cardDetail.hitsDistribution)
        ..damageRate = currentCard.isNP ? dataVals.Value! + additionDamageRate : 1000
        ..npSpecificAttackRate = specificAttackRate
        ..attackerClass = activator.svtClass
        ..defenderClass = target.svtClass
        ..classAdvantage = classAdvantage
        ..attackerAttribute = activator.attribute
        ..defenderAttribute = target.attribute
        ..isNp = currentCard.isNP
        ..chainPos = chainPos
        ..currentCardType = currentCard.cardType
        ..firstCardType = firstCardType
        ..isTypeChain = isTypeChain
        ..isMightyChain = isMightyChain
        ..isCritical = currentCard.isCritical
        ..cardBuff = activator.getBuffValueOnAction(battleData, BuffAction.commandAtk)
        ..attackBuff = activator.getBuffValueOnAction(battleData, BuffAction.atk)
        ..specificAttackBuff = Maths.sum(powerMods.map((action) => activator.getBuffValueOnAction(battleData, action)))
        ..criticalDamageBuff =
            currentCard.isCritical ? activator.getBuffValueOnAction(battleData, BuffAction.criticalDamage) : 0
        ..npDamageBuff = currentCard.isNP ? activator.getBuffValueOnAction(battleData, BuffAction.npdamage) : 0
        ..percentAttackBuff = activator.getBuffValueOnAction(battleData, BuffAction.damageSpecial)
        ..damageAdditionBuff = activator.getBuffValueOnAction(battleData, BuffAction.givenDamage)
        ..fixedRandom = battleData.fixedRandom;

      final atkNpParameters = AttackNpGainParameters();
      final defNpParameters = DefendNpGainParameters();
      final starParameters = StarParameters();

      if (activator.isPlayer) {
        atkNpParameters
          ..attackerNpCharge = currentCard.npGain
          ..defenderNpRate = target.enemyTdRate
          ..isNp = currentCard.isNP
          ..chainPos = chainPos
          ..currentCardType = currentCard.cardType
          ..firstCardType = firstCardType
          ..isMightyChain = isMightyChain
          ..isCritical = currentCard.isCritical
          ..cardBuff = activator.getBuffValueOnAction(battleData, BuffAction.commandNpAtk)
          ..npGainBuff = activator.getBuffValueOnAction(battleData, BuffAction.dropNp);

        starParameters
          ..attackerStarGen = activator.starGen
          ..defenderStarRate = target.enemyStarRate
          ..isNp = currentCard.isNP
          ..chainPos = chainPos
          ..currentCardType = currentCard.cardType
          ..firstCardType = firstCardType
          ..isMightyChain = isMightyChain
          ..isCritical = currentCard.isCritical
          ..cardBuff = activator.getBuffValueOnAction(battleData, BuffAction.commandStarAtk)
          ..starGenBuff = activator.getBuffValueOnAction(battleData, BuffAction.criticalPoint);
      } else {
        defNpParameters
          ..defenderNpCharge = target.defenceNpGain
          ..attackerNpRate = activator.enemyTdAttackRate
          ..npGainBuff = target.getBuffValueOnAction(battleData, BuffAction.dropNp)
          ..defenseNpGainBuff = target.getBuffValueOnAction(battleData, BuffAction.dropNpDamage);
      }

      final hasPierceDefense = activator.hasBuffOnAction(battleData, BuffAction.pierceDefence);
      final skipDamage = shouldSkipDamage(battleData, activator, target, currentCard);
      if (!skipDamage) {
        damageParameters
          ..cardResist = target.getBuffValueOnAction(battleData, BuffAction.commandDef)
          ..defenseBuff = isPierceDefense || hasPierceDefense
              ? target.getBuffValueOnAction(battleData, BuffAction.defencePierce)
              : target.getBuffValueOnAction(battleData, BuffAction.defence)
          ..specificDefenseBuff = target.getBuffValueOnAction(battleData, BuffAction.selfdamage)
          ..percentDefenseBuff = target.getBuffValueOnAction(battleData, BuffAction.specialdefence)
          ..damageReductionBuff = target.getBuffValueOnAction(battleData, BuffAction.receiveDamage);

        atkNpParameters.cardResist = target.getBuffValueOnAction(battleData, BuffAction.commandNpDef);

        starParameters
          ..cardResist = target.getBuffValueOnAction(battleData, BuffAction.commandStarDef)
          ..enemyStarGenResist = target.getBuffValueOnAction(battleData, BuffAction.criticalStarDamageTaken);
      }

      final totalDamage = calculateDamage(damageParameters);
      int remainingDamage = totalDamage;

      int overkillCount = 0;
      final List<int> hitDamages = [];
      final List<int> hitNpGains = [];
      final List<int> hitStars = [];
      for (int i = 0; i < currentCard.cardDetail.hitsDistribution.length; i += 1) {
        if (skipDamage) {
          hitDamages.add(0);
        } else {
          final hitsPercentage = currentCard.cardDetail.hitsDistribution[i];
          final int hitDamage;
          if (i < currentCard.cardDetail.hitsDistribution.length - 1) {
            hitDamage = totalDamage * hitsPercentage ~/ 100;
          } else {
            hitDamage = remainingDamage;
          }

          hitDamages.add(hitDamage);
          remainingDamage -= hitDamage;

          target.receiveDamage(hitDamage);
        }

        if (target.hp <= 0) {
          await activator.activateBuffOnAction(battleData, BuffAction.functionDeadattack);
          target.killedBy = activator;
          target.killedByCard = currentCard;
        }

        final isOverkill = target.hp < 0 || (!currentCard.isNP && target.isBuggedOverkill);
        if (isOverkill) {
          overkillCount += 1;
        }

        if (activator.isPlayer) {
          atkNpParameters.isOverkill = isOverkill;
          starParameters.isOverkill = isOverkill;
          final hitNpGain = calculateAttackNpGain(atkNpParameters);
          final previousNP = activator.np;
          activator.changeNP(hitNpGain);
          hitNpGains.add(activator.np - previousNP);

          final hitStar = calculateStar(starParameters);
          hitStars.add(hitStar);
        }

        if (target.isPlayer) {
          defNpParameters.isOverkill = isOverkill;
          final hitNpGain = calculateDefendNpGain(defNpParameters);

          final previousNP = activator.np;
          target.changeNP(hitNpGain);
          hitNpGains.add(activator.np - previousNP);
        }
      }

      battleData.logger.debug(damageParameters.toString());
      if (activator.isPlayer) {
        battleData.logger.debug(atkNpParameters.toString());
        battleData.logger.debug(starParameters.toString());
      } else {
        battleData.logger.debug(defNpParameters.toString());
      }
      final starString = activator.isPlayer
          ? '${S.current.battle_critical_star}: ${(Maths.sum(hitStars) / 1000).toStringAsFixed(3)} - '
          : '';
      battleData.logger.action('${activator.lBattleName} - ${currentCard.cardType.name.toUpperCase()} - '
          '${currentCard.isNP ? S.current.battle_np_card : S.current.battle_command_card} - '
          '${S.current.effect_target}: ${target.lBattleName} - '
          '${S.current.battle_damage}: $totalDamage - '
          'NP: ${(Maths.sum(hitNpGains) / 100).toStringAsFixed(2)}% - '
          '$starString'
          'Overkill: $overkillCount/${currentCard.cardDetail.hitsDistribution.length}');
      final hitStarString = activator.isPlayer ? ', ${S.current.battle_critical_star}: $hitStars' : '';
      battleData.logger
          .debug('${S.current.details}: ${S.current.battle_damage}: $hitDamages, NP: $hitNpGains$hitStarString');

      battleData.changeStar(toModifier(Maths.sum(hitStars)));

      target.removeBuffWithTrait(NiceTrait(id: Trait.buffSleep.id));

      target.addAccumulationDamage(totalDamage - remainingDamage);

      battleData.unsetTarget();
    }

    return true;
  }

  static bool shouldSkipDamage(
    final BattleData battleData,
    final BattleServantData activator,
    final BattleServantData target,
    final CommandCardData currentCard,
  ) {
    final hasSpecialInvincible = target.hasBuffOnAction(battleData, BuffAction.specialInvincible);
    final hasPierceInvincible = activator.hasBuffOnAction(battleData, BuffAction.pierceInvincible);
    if (hasSpecialInvincible) {
      return true;
    }
    final hasInvincible = target.hasBuffOnAction(battleData, BuffAction.invincible);
    if (hasPierceInvincible) {
      return false;
    }
    final hasBreakAvoidance = activator.hasBuffOnAction(battleData, BuffAction.breakAvoidance);
    if (hasInvincible) {
      return true;
    }
    final hasAvoidance = target.hasBuffOnAction(battleData, BuffAction.avoidance) ||
        target.hasBuffOnAction(battleData, BuffAction.avoidanceIndividuality);
    return !hasBreakAvoidance && hasAvoidance;
  }

  static int getClassRelation(
    final BattleData battleData,
    final BattleServantData activator,
    final BattleServantData target,
    final CommandCardData currentCard,
  ) {
    return ConstData.getClassRelation(activator.svtClass, target.svtClass);
  }
}
