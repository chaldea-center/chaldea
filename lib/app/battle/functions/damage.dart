import 'dart:math';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/utils.dart';
import '../interactions/damage_adjustor.dart';
import '../utils/battle_logger.dart';

enum NpSpecificMode { normal, individualSum, rarity }

class Damage {
  Damage._();

  static final List<BuffAction> powerMods = [
    BuffAction.damage,
    BuffAction.damageIndividuality,
    BuffAction.damageIndividualityActiveonly,
    BuffAction.damageEventPoint
  ];

  /// during damage calculation, due to buffs potentially having only one count remaining, checkBuffStatus should
  /// not be called to avoid removing applied buffs
  static Future<void> damage(
    final BattleData battleData,
    final NiceFunction? damageFunction,
    final DataVals dataVals,
    final Iterable<BattleServantData> targets, {
    final int chainPos = 1,
    final bool isTypeChain = false,
    final bool isMightyChain = false,
    final CardType firstCardType = CardType.none,
    final bool shouldTrigger = true,
    final bool shouldDamageRelease = true,
  }) async {
    final funcType = damageFunction?.funcType;
    final functionRate = dataVals.Rate ?? 1000;
    if (functionRate < battleData.options.threshold) {
      return;
    }

    final activator = battleData.activator!;
    final currentCard = battleData.currentCard!;
    final List<AttackResultDetail> targetResults = [];

    final checkHpRatioHigh = funcType == FuncType.damageNpHpratioHigh;
    final checkHpRatioLow = funcType == FuncType.damageNpHpratioLow;
    final checkHpRatio = checkHpRatioHigh || checkHpRatioLow;
    for (final target in targets) {
      await battleData.withTarget(target, () async {
        final targetBefore = target.copy();
        if (shouldTrigger) {
          await activator.activateBuffOnAction(battleData, BuffAction.functionCommandcodeattackBefore);
          await activator.activateBuffOnActions(battleData, [
            if (!currentCard.isTD) BuffAction.functionCommandattackBefore,
            BuffAction.functionAttackBefore,
          ]);
        }

        final classAdvantage = await getClassRelation(battleData, activator, target);

        int? decideHp;
        if (battleData.delegate?.hpRatio != null) {
          decideHp = battleData.delegate!.hpRatio!(activator, battleData, damageFunction, dataVals);
        }
        decideHp ??= activator.hp;
        final hpRatioDamageLow = checkHpRatioLow && dataVals.Target != null
            ? ((1 - decideHp / activator.maxHp) * dataVals.Target!).toInt()
            : 0;

        final hpRatioDamageHigh =
            checkHpRatioHigh && dataVals.Target != null ? ((decideHp / activator.maxHp) * dataVals.Target!).toInt() : 0;

        int specificAttackRate = 1000;

        if (!checkHpRatio && dataVals.Target != null) {
          if (funcType == FuncType.damageNpRare) {
            final countTarget = dataVals.Target! == 1 ? activator : target; // need more sample
            final targetRarities = dataVals.TargetRarityList!;
            final damageNpSEDecision = battleData.delegate?.damageNpSE?.call(activator, damageFunction, dataVals);
            final useCorrection = damageNpSEDecision?.useCorrection ?? targetRarities.contains(countTarget.rarity);
            if (useCorrection) {
              specificAttackRate = dataVals.Correction!;
            }
          } else if (funcType == FuncType.damageNpIndividualSum) {
            final countTarget = dataVals.Target! == 1 ? target : activator;
            final requiredTraits = dataVals.TargetList!.map((traitId) => NiceTrait(id: traitId)).toList();
            final damageNpSEDecision = battleData.delegate?.damageNpSE?.call(activator, damageFunction, dataVals);
            int useCount = countTarget.countBuffWithTrait(requiredTraits,
                    excludeIndivUnreleaseable: dataVals.IgnoreIndivUnreleaseable == 1) +
                countTarget.countTrait(battleData, requiredTraits);
            final useCorrection = damageNpSEDecision?.useCorrection ?? useCount > 0;
            useCount = damageNpSEDecision?.indivSumCount ?? useCount;
            if (dataVals.ParamAddMaxCount != null && dataVals.ParamAddMaxCount! > 0) {
              useCount = min(useCount, dataVals.ParamAddMaxCount!);
            }
            if (useCorrection) {
              specificAttackRate = dataVals.Value2! + useCount * dataVals.Correction!;
            }
          } else if (funcType == FuncType.damageNpIndividual || funcType == FuncType.damageNpStateIndividualFix) {
            final damageNpSEDecision = battleData.delegate?.damageNpSE?.call(activator, damageFunction, dataVals);
            final useCorrection = damageNpSEDecision?.useCorrection ??
                battleData.checkTraits(CheckTraitParameters(
                  requiredTraits: [NiceTrait(id: dataVals.Target!)],
                  actor: battleData.target,
                  checkActorTraits: funcType == FuncType.damageNpIndividual,
                  checkActorBuffTraits: funcType == FuncType.damageNpStateIndividualFix,
                  ignoreIrremovableBuff: dataVals.IgnoreIndivUnreleaseable == 1,
                ));

            if (useCorrection) {
              specificAttackRate = dataVals.Correction!;
            }
          }
        }

        int specificAttackBuff = 0;
        for (final action in powerMods) {
          specificAttackBuff += await activator.getBuffValueOnAction(battleData, action);
        }

        final damageParameters = DamageParameters()
          ..attack = activator.atk + currentCard.cardStrengthen
          ..totalHits = Maths.sum(currentCard.cardDetail.hitsDistribution)
          ..damageRate = currentCard.isTD
              ? dataVals.Value! + hpRatioDamageLow + hpRatioDamageHigh
              : currentCard.cardDetail.damageRate ?? 1000
          ..npSpecificAttackRate = specificAttackRate
          ..attackerClass = activator.classId
          ..defenderClass = target.classId
          ..classAdvantage = classAdvantage
          ..attackerAttribute = activator.attribute
          ..defenderAttribute = target.attribute
          ..isNp = currentCard.isTD
          ..chainPos = chainPos
          ..currentCardType = currentCard.cardType
          ..firstCardType = firstCardType
          ..isTypeChain = isTypeChain
          ..isMightyChain = isMightyChain
          ..critical = currentCard.critical
          ..cardBuff = await activator.getBuffValueOnAction(battleData, BuffAction.commandAtk)
          ..attackBuff = await activator.getBuffValueOnAction(battleData, BuffAction.atk)
          ..specificAttackBuff = specificAttackBuff
          ..criticalDamageBuff =
              currentCard.critical ? await activator.getBuffValueOnAction(battleData, BuffAction.criticalDamage) : 0
          ..npDamageBuff = currentCard.isTD ? await activator.getBuffValueOnAction(battleData, BuffAction.npdamage) : 0
          ..percentAttackBuff = await activator.getBuffValueOnAction(battleData, BuffAction.damageSpecial)
          ..damageAdditionBuff = await activator.getBuffValueOnAction(battleData, BuffAction.givenDamage)
          ..random = battleData.options.random
          ..damageFunction = damageFunction;

        final atkNpParameters = AttackNpGainParameters();
        final defNpParameters = DefendNpGainParameters();
        final starParameters = StarParameters();

        if (activator.isPlayer) {
          atkNpParameters
            ..attackerNpCharge = currentCard.npGain
            ..defenderNpRate = target.enemyTdRate
            ..cardAttackNpRate = currentCard.cardDetail.damageRate ?? 1000
            ..isNp = currentCard.isTD
            ..chainPos = chainPos
            ..currentCardType = currentCard.cardType
            ..firstCardType = firstCardType
            ..isMightyChain = isMightyChain
            ..critical = currentCard.critical
            ..cardBuff = await activator.getBuffValueOnAction(battleData, BuffAction.commandNpAtk)
            ..npGainBuff = await activator.getBuffValueOnAction(battleData, BuffAction.dropNp);

          starParameters
            ..attackerStarGen = activator.starGen
            ..defenderStarRate = target.enemyStarRate
            ..cardDropStarRate = currentCard.cardDetail.damageRate ?? 1000
            ..isNp = currentCard.isTD
            ..chainPos = chainPos
            ..currentCardType = currentCard.cardType
            ..firstCardType = firstCardType
            ..isMightyChain = isMightyChain
            ..critical = currentCard.critical
            ..cardBuff = await activator.getBuffValueOnAction(battleData, BuffAction.commandStarAtk)
            ..starGenBuff = await activator.getBuffValueOnAction(battleData, BuffAction.criticalPoint);
        } else {
          defNpParameters
            ..defenderNpGainRate = target.defenceNpGain
            ..attackerNpRate = activator.enemyTdAttackRate
            ..cardDefNpRate = currentCard.cardDetail.damageRate ?? 1000
            ..npGainBuff = await target.getBuffValueOnAction(battleData, BuffAction.dropNp)
            ..defenseNpGainBuff = await target.getBuffValueOnAction(battleData, BuffAction.dropNpDamage);
        }

        final hasPierceDefense = await activator.hasBuffOnAction(battleData, BuffAction.pierceDefence);
        final skipDamage = await shouldSkipDamage(battleData, activator, target, currentCard);
        if (!skipDamage) {
          damageParameters
            ..cardResist = await target.getBuffValueOnAction(battleData, BuffAction.commandDef)
            ..defenseBuff = damageFunction?.funcType == FuncType.damageNpPierce || hasPierceDefense
                ? await target.getBuffValueOnAction(battleData, BuffAction.defencePierce)
                : await target.getBuffValueOnAction(battleData, BuffAction.defence)
            ..specificDefenseBuff = await target.getBuffValueOnAction(battleData, BuffAction.selfdamage)
            ..percentDefenseBuff = await target.getBuffValueOnAction(battleData, BuffAction.specialdefence)
            ..damageReceiveAdditionBuff = await target.getBuffValueOnAction(battleData, BuffAction.receiveDamage);

          atkNpParameters.cardResist = await target.getBuffValueOnAction(battleData, BuffAction.commandNpDef);

          starParameters
            ..cardResist = await target.getBuffValueOnAction(battleData, BuffAction.commandStarDef)
            ..enemyStarGenResist = await target.getBuffValueOnAction(battleData, BuffAction.criticalStarDamageTaken);
        }
        final multiAttack = await activator.getMultiAttackBuffValue(battleData);

        // real
        final int totalDamage = await DamageAdjustor.show(battleData, damageParameters);

        // calc min/max first, since it doesn't change original target/activator
        final minResult = await _calc(
              totalDamage:
                  calculateDamageNoError(damageParameters.copy()..random = ConstData.constants.attackRateRandomMin),
              atkNpParameters: atkNpParameters.copy(),
              defNpParameters: defNpParameters.copy(),
              starParameters: starParameters.copy(),
              target: target.copy(),
              activator: activator.copy(),
              currentCard: currentCard.copy(),
              multiAttack: multiAttack,
              skipDamage: skipDamage,
            ),
            maxResult = await _calc(
              totalDamage:
                  calculateDamageNoError(damageParameters.copy()..random = ConstData.constants.attackRateRandomMax - 1),
              atkNpParameters: atkNpParameters.copy(),
              defNpParameters: defNpParameters.copy(),
              starParameters: starParameters.copy(),
              target: target.copy(),
              activator: activator.copy(),
              currentCard: currentCard.copy(),
              multiAttack: multiAttack,
              skipDamage: skipDamage,
            );

        final result = await _calc(
          totalDamage: totalDamage,
          atkNpParameters: atkNpParameters,
          defNpParameters: defNpParameters,
          starParameters: starParameters,
          target: target,
          activator: activator,
          currentCard: currentCard,
          multiAttack: multiAttack,
          skipDamage: skipDamage,
        );

        battleData.battleLogger.debug(damageParameters.toString());
        if (activator.isPlayer) {
          battleData.battleLogger.debug(atkNpParameters.toString());
          battleData.battleLogger.debug(starParameters.toString());
        } else {
          battleData.battleLogger.debug(defNpParameters.toString());
        }
        final starString = activator.isPlayer
            ? '${S.current.critical_star}: ${(Maths.sum(result.stars) / 1000).toStringAsFixed(3)} - '
            : '';
        battleData.battleLogger.action('${activator.lBattleName} - ${currentCard.cardType.name.toUpperCase()} - '
            '${currentCard.isTD ? S.current.battle_np_card : S.current.battle_command_card} - '
            '${S.current.effect_target}: ${target.lBattleName} - '
            '${S.current.battle_damage}: $totalDamage - '
            '${S.current.battle_remaining_hp}: ${target.hp}/${target.maxHp} - '
            'NP: ${(Maths.sum(result.npGains) / 100).toStringAsFixed(2)}% - '
            '$starString'
            'Overkill: ${result.overkillStates.where((e) => e).length}/${currentCard.cardDetail.hitsDistribution.length}');
        final hitStarString = activator.isPlayer ? ', ${S.current.critical_star}: ${result.stars}' : '';
        battleData.battleLogger
            .debug('${S.current.details}: ${S.current.battle_damage}: ${result.damages}, NP: ${result.npGains}, '
                'DefNP: ${result.defNpGains}$hitStarString');

        battleData.changeStar(toModifier(Maths.sum(result.stars)));

        if (shouldDamageRelease) {
          target.battleBuff.originalActiveList
              .removeWhere((buff) => buff.checkAct() && buff.buff.script.DamageRelease == 1);
          // passive should also be checked?
          target.battleBuff.originalPassiveList
              .removeWhere((buff) => buff.checkAct() && buff.buff.script.DamageRelease == 1);
        }

        battleData.curFuncResults[target.uniqueId] = true;

        targetResults.add(AttackResultDetail(
          target: target,
          targetBefore: targetBefore,
          damageParams: damageParameters,
          attackNpParams: atkNpParameters,
          starParams: starParameters,
          defenseNpParams: defNpParameters,
          result: result,
          minResult: minResult,
          maxResult: maxResult,
        ));

        if (shouldTrigger) {
          await activator.activateBuffOnAction(battleData, BuffAction.functionCommandcodeattackAfter);
          await activator.activateBuffOnActions(battleData, [
            if (!currentCard.isTD) BuffAction.functionCommandattackAfter,
            BuffAction.functionAttackAfter,
          ]);
        }
      });
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

  static Future<DamageResult> _calc({
    required int totalDamage,
    required AttackNpGainParameters atkNpParameters,
    required DefendNpGainParameters defNpParameters,
    required StarParameters starParameters,
    required BattleServantData target,
    required BattleServantData activator,
    required CommandCardData currentCard,
    required int? multiAttack,
    required bool skipDamage,
  }) async {
    final result = DamageResult();
    int remainingDamage = totalDamage;

    if (multiAttack != null && multiAttack > 0) {
      for (final hit in currentCard.cardDetail.hitsDistribution) {
        for (int count = 1; count <= multiAttack; count += 1) {
          result.cardHits.add(hit);
        }
      }
    } else {
      result.cardHits.addAll(currentCard.cardDetail.hitsDistribution);
    }
    final totalHits = Maths.sum(result.cardHits);
    for (int i = 0; i < result.cardHits.length; i += 1) {
      if (skipDamage) {
        result.damages.add(0);
      } else {
        final hitsPercentage = result.cardHits[i];
        final int hitDamage;
        if (i < result.cardHits.length - 1) {
          hitDamage = totalDamage * hitsPercentage ~/ totalHits;
        } else {
          hitDamage = remainingDamage;
        }

        result.damages.add(hitDamage);
        remainingDamage -= hitDamage;

        target.receiveDamage(hitDamage);
      }

      target.lastHitBy = activator;
      target.lastHitByCard = currentCard;

      final isOverkill = target.hp < 0 || (!currentCard.isTD && target.isBuggedOverkill);
      result.overkillStates.add(isOverkill);

      if (activator.isPlayer) {
        atkNpParameters.isOverkill = isOverkill;
        starParameters.isOverkill = isOverkill;
        final hitNpGain = calculateAttackNpGain(atkNpParameters);
        final previousNP = activator.np;
        final maxLimited = Ref<bool>(false);
        activator.changeNP(hitNpGain, maxLimited: maxLimited);
        result.npGains.add(activator.np - previousNP);
        result.npMaxLimited.add(maxLimited.value);

        final hitStar = calculateStar(starParameters);
        result.stars.add(hitStar);
      }

      if (target.isPlayer) {
        defNpParameters.isOverkill = isOverkill;
        final hitNpGain = calculateDefendNpGain(defNpParameters);

        final previousNP = target.np;
        final maxLimited = Ref<bool>(false);
        target.changeNP(hitNpGain, maxLimited: maxLimited);
        result.defNpGains.add(target.np - previousNP);
        result.defNpMaxLimited.add(maxLimited.value);
      }
    }
    target.addAccumulationDamage(totalDamage - remainingDamage);
    target.attacked = true;

    return result;
  }

  static Future<bool> shouldSkipDamage(
    final BattleData battleData,
    final BattleServantData activator,
    final BattleServantData target,
    final CommandCardData currentCard,
  ) async {
    final hasSpecialInvincible = await target.hasBuffOnAction(battleData, BuffAction.specialInvincible);
    final hasPierceInvincible = await activator.hasBuffOnAction(battleData, BuffAction.pierceInvincible);
    if (hasSpecialInvincible) {
      return true;
    }
    final hasInvincible = await target.hasBuffOnAction(battleData, BuffAction.invincible);
    if (hasPierceInvincible) {
      return false;
    }
    final hasBreakAvoidance = await activator.hasBuffOnAction(battleData, BuffAction.breakAvoidance);
    if (hasInvincible) {
      return true;
    }
    final hasAvoidance = await target.hasBuffOnAction(battleData, BuffAction.avoidance) ||
        await target.hasBuffOnAction(battleData, BuffAction.avoidanceIndividuality);
    return !hasBreakAvoidance && hasAvoidance;
  }

  static Future<int> getClassRelation(
    final BattleData battleData,
    final BattleServantData activator,
    final BattleServantData target,
  ) async {
    int relation = ConstData.getClassIdRelation(activator.classId, target.classId);
    relation = await activator.getClassRelation(battleData, relation, target, false);
    relation = await target.getClassRelation(battleData, relation, activator, true);

    return relation;
  }
}
