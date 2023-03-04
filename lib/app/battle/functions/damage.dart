import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/app/battle/models/svt_entity.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';

final List<BuffAction> powerMods = [
  BuffAction.damage,
  BuffAction.damageIndividuality,
  BuffAction.damageIndividualityActiveonly,
  BuffAction.damageEventPoint
];

bool damage(
  BattleData battleData,
  DataVals dataVals,
  Iterable<BattleServantData> targets,
  int chainPos,
  bool isTypeChain,
  bool isMightyChain,
  CardType firstCardType, {
  bool isPierceDefense = false,
}) {
  final functionRate = dataVals.Rate ?? 1000;
  if (functionRate < battleData.probabilityThreshold) {
    return false;
  }

  final activator = battleData.activator!;
  final currentCard = battleData.currentCard!;

  for (final target in targets) {
    battleData.setTarget(target);

    final classAdvantage = db.gameData.constData.getClassRelation(activator.svtClass, target.svtClass);

    final damageParameters = DamageParameters()
      ..attack = activator.attack + currentCard.cardStrengthen
      ..totalHits = Maths.sum(currentCard.cardDetail.hitsDistribution)
      ..damageRate = currentCard.isNP ? dataVals.Value! : 1000
      ..npSpecificAttackRate =
          dataVals.Target != null && target.checkTrait(NiceTrait(id: dataVals.Target!)) ? dataVals.Correction! : 1000
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
      ..cardBuff = activator.getBuffValueOnAction(battleData, BuffAction.commandAtk, currentCard.commandCodeBuffs)
      ..attackBuff = activator.getBuffValueOnAction(battleData, BuffAction.atk, currentCard.commandCodeBuffs)
      ..specificAttackBuff = Maths.sum(powerMods.map((action) => activator.getBuffValueOnAction(battleData, action)))
      ..criticalDamageBuff = currentCard.isCritical
          ? activator.getBuffValueOnAction(battleData, BuffAction.criticalDamage, currentCard.commandCodeBuffs)
          : 0
      ..npDamageBuff = currentCard.isNP
          ? activator.getBuffValueOnAction(battleData, BuffAction.npdamage, currentCard.commandCodeBuffs)
          : 0
      ..percentAttackBuff =
          activator.getBuffValueOnAction(battleData, BuffAction.damageSpecial, currentCard.commandCodeBuffs)
      ..damageAdditionBuff =
          activator.getBuffValueOnAction(battleData, BuffAction.givenDamage, currentCard.commandCodeBuffs)
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
        ..cardBuff = activator.getBuffValueOnAction(battleData, BuffAction.commandNpAtk, currentCard.commandCodeBuffs)
        ..npGainBuff = activator.getBuffValueOnAction(battleData, BuffAction.dropNp, currentCard.commandCodeBuffs);

      starParameters
        ..attackerStarGen = activator.starGen
        ..defenderStarRate = target.enemyStarRate
        ..isNp = currentCard.isNP
        ..chainPos = chainPos
        ..currentCardType = currentCard.cardType
        ..firstCardType = firstCardType
        ..isMightyChain = isMightyChain
        ..isCritical = currentCard.isCritical
        ..cardBuff = activator.getBuffValueOnAction(battleData, BuffAction.commandStarAtk, currentCard.commandCodeBuffs)
        ..starGenBuff =
            activator.getBuffValueOnAction(battleData, BuffAction.criticalPoint, currentCard.commandCodeBuffs);
    } else {
      defNpParameters
        ..defenderNpCharge = target.defenceNpGain
        ..attackerNpRate = activator.enemyTdAttackRate
        ..npGainBuff = target.getBuffValueOnAction(battleData, BuffAction.dropNp, currentCard.commandCodeBuffs)
        ..defenseNpGainBuff =
            target.getBuffValueOnAction(battleData, BuffAction.dropNpDamage, currentCard.commandCodeBuffs);
    }

    final hasPierceDefense = activator.hasBuffOnAction(battleData, BuffAction.pierceDefence, currentCard.commandCodeBuffs);
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
    var remainingDamage = totalDamage;

    // Future logging
    var totalNp = 0;
    var defTotalNp = 0;
    var totalStars = 0;
    var overkillCount = 0;
    for (int i = 0; i < currentCard.cardDetail.hitsDistribution.length; i += 1) {
      if (!skipDamage) {
        final hitsPercentage = currentCard.cardDetail.hitsDistribution[i];
        final int hitDamage;
        if (i < currentCard.cardDetail.hitsDistribution.length - 1) {
          hitDamage = totalDamage * hitsPercentage ~/ 100;
        } else {
          hitDamage = remainingDamage;
        }

        remainingDamage -= hitDamage;

        target.receiveDamage(hitDamage);
      }

      if (target.hp <= 0) {
        activator.activateBuffOnAction(battleData, BuffAction.functionDeadattack);
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
        totalNp += hitNpGain;
        activator.changeNP(hitNpGain);

        final hitStars = calculateStar(starParameters);
        totalStars += hitStars;
      }

      if (target.isPlayer) {
        defNpParameters.isOverkill = isOverkill;
        final hitNpGain = calculateDefendNpGain(defNpParameters);

        defTotalNp += hitNpGain;
        target.changeNP(hitNpGain);
      }
    }

    battleData.changeStar(toModifier(totalStars));

    target.removeBuffWithTrait(NiceTrait(id: Trait.buffSleep.id));

    target.addAccumulationDamage(totalDamage - remainingDamage);

    battleData.unsetTarget();
  }

  return true;
}

bool shouldSkipDamage(
  BattleData battleData,
  BattleServantData activator,
  BattleServantData target,
  CommandCardData currentCard,
) {
  final hasSpecialInvincible = target.hasBuffOnAction(battleData, BuffAction.specialInvincible);
  final hasPierceInvincible =
      activator.hasBuffOnAction(battleData, BuffAction.pierceInvincible, currentCard.commandCodeBuffs);
  if (hasSpecialInvincible) {
    return true;
  }
  final hasInvincible = target.hasBuffOnAction(battleData, BuffAction.invincible);
  if (hasPierceInvincible) {
    return false;
  }
  final hasBreakAvoidance =
      activator.hasBuffOnAction(battleData, BuffAction.breakAvoidance, currentCard.commandCodeBuffs);
  if (hasInvincible) {
    return true;
  }
  final hasAvoidance = target.hasBuffOnAction(battleData, BuffAction.avoidance) ||
      target.hasBuffOnAction(battleData, BuffAction.avoidanceIndividuality);
  return !hasBreakAvoidance && hasAvoidance;
}

int getClassRelation(
  BattleData battleData,
  BattleServantData activator,
  BattleServantData target,
  CommandCardData currentCard,
) {
  return db.gameData.constData.getClassRelation(activator.svtClass, target.svtClass);
}
