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

  /// during damage calculation, due to buffs potentially having only one count remaining, checkBuffStatus should
  /// not be called to avoid removing applied buffs
  static Future<void> damage(
    final BattleData battleData,
    final NiceFunction? damageFunction,
    final DataVals dataVals,
    final BattleServantData activator,
    final Iterable<BattleServantData> targets,
    final CommandCardData currentCard, {
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

    final List<AttackResultDetail> targetResults = [];

    final checkHpRatioHigh = funcType == FuncType.damageNpHpratioHigh;
    final checkHpRatioLow = funcType == FuncType.damageNpHpratioLow;
    final checkHpRatio = checkHpRatioHigh || checkHpRatioLow;

    if (shouldTrigger) {
      for (final target in targets) {
        final isMainTarget = battleData.isActorMainTarget(target);
        await activator.activateBuffs(
          battleData,
          [
            BuffAction.functionCommandcodeattackBefore,
            if (isMainTarget) BuffAction.functionCommandcodeattackBeforeMainOnly,
          ],
          other: target,
          addTraits: currentCard.traits,
        );
        await activator.activateBuffs(
          battleData,
          [
            if (!currentCard.isTD) BuffAction.functionCommandattackBefore,
            if (!currentCard.isTD && isMainTarget) BuffAction.functionCommandattackBeforeMainOnly,
            BuffAction.functionAttackBefore,
            if (isMainTarget) BuffAction.functionAttackBeforeMainOnly
          ],
          other: target,
          addTraits: currentCard.traits,
        );
      }
    }

    for (final target in targets) {
      final targetBefore = target.copy();

      final classAdvantage = await getClassRelation(battleData, activator, target, currentCard);

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
                  ignoreIndivUnreleaseable: dataVals.IgnoreIndivUnreleaseable == 1) +
              countTarget.countTrait(requiredTraits);
          final useCorrection = damageNpSEDecision?.useCorrection ?? useCount > 0;
          useCount = damageNpSEDecision?.indivSumCount ?? useCount;
          if (dataVals.ParamAddMaxCount != null && dataVals.ParamAddMaxCount! > 0) {
            useCount = min(useCount, dataVals.ParamAddMaxCount!);
          }
          if (useCorrection) {
            specificAttackRate = dataVals.Value2! + useCount * dataVals.Correction!;
          }
        } else if (funcType == FuncType.damageNpIndividual) {
          final damageNpSEDecision = battleData.delegate?.damageNpSE?.call(activator, damageFunction, dataVals);

          final useCorrection = damageNpSEDecision?.useCorrection ??
              checkTraitFunction(myTraits: target.getTraits(), requiredTraits: [NiceTrait(id: dataVals.Target!)]);

          if (useCorrection) {
            specificAttackRate = dataVals.Correction!;
          }
        } else if (funcType == FuncType.damageNpStateIndividualFix) {
          final damageNpSEDecision = battleData.delegate?.damageNpSE?.call(activator, damageFunction, dataVals);
          final ignoreIrremovable = dataVals.IgnoreIndivUnreleaseable == 1;
          final includeIgnoreIndividuality = dataVals.IncludeIgnoreIndividuality == 1;

          final useCorrection = damageNpSEDecision?.useCorrection ??
              checkTraitFunction(
                myTraits: target.getBuffTraits(
                  ignoreIndivUnreleaseable: ignoreIrremovable,
                  includeIgnoreIndiv: includeIgnoreIndividuality,
                ),
                requiredTraits: [NiceTrait(id: dataVals.Target!)],
              );

          if (useCorrection) {
            specificAttackRate = dataVals.Correction!;
          }
        }
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
        ..cardBuff = await activator.getBuffValue(
          battleData,
          BuffAction.commandAtk,
          other: target,
          addTraits: currentCard.traits,
        )
        ..attackBuff = await activator.getBuffValue(
          battleData,
          BuffAction.atk,
          other: target,
          addTraits: currentCard.traits,
        )
        ..specificAttackBuff = await getSpecificDamage(battleData, activator, target, currentCard)
        ..criticalDamageBuff = currentCard.critical
            ? await activator.getBuffValue(
                battleData,
                BuffAction.criticalDamage,
                other: target,
                addTraits: currentCard.traits,
              )
            : 0
        ..npDamageBuff = currentCard.isTD
            ? await activator.getBuffValue(
                battleData,
                BuffAction.npdamage,
                other: target,
                addTraits: currentCard.traits,
              )
            : 0
        ..percentAttackBuff = await activator.getBuffValue(
          battleData,
          BuffAction.damageSpecial,
          other: target,
          addTraits: currentCard.traits,
        )
        ..damageAdditionBuff = await activator.getBuffValue(
          battleData,
          BuffAction.givenDamage,
          other: target,
          addTraits: currentCard.traits,
        )
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
          ..cardBuff = await activator.getBuffValue(
            battleData,
            BuffAction.commandNpAtk,
            other: target,
            addTraits: currentCard.traits,
          )
          ..npGainBuff = await activator.getBuffValue(
            battleData,
            BuffAction.dropNp,
            other: target,
            addTraits: currentCard.traits,
          );

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
          ..cardBuff = await activator.getBuffValue(
            battleData,
            BuffAction.commandStarAtk,
            other: target,
            addTraits: currentCard.traits,
          )
          ..starGenBuff = await activator.getBuffValue(
            battleData,
            BuffAction.criticalPoint,
            other: target,
            addTraits: currentCard.traits,
          );
      } else {
        defNpParameters
          ..defenderNpGainRate = target.defenceNpGain
          ..attackerNpRate = activator.enemyTdAttackRate
          ..cardDefNpRate = currentCard.cardDetail.damageRate ?? 1000
          ..npGainBuff = await target.getBuffValue(
            battleData,
            BuffAction.dropNp,
            other: activator,
            otherAddTraits: currentCard.traits,
          )
          // very weird as in code it shows selfTrait is on attacker, although no real application to confirm this
          ..defenseNpGainBuff = await target.getBuffValueOnTraits(
            battleData,
            BuffAction.dropNpDamage,
            selfTraits: activator.getTraits(addTraits: currentCard.traits),
            otherTraits: target.getTraits(),
            other: activator,
          );

        // Also, I did not implement def star gen
      }

      final skipDamage = await shouldSkipDamage(battleData, activator, target, currentCard);
      if (!skipDamage) {
        final hasPierceDefense = await activator.hasBuff(
          battleData,
          BuffAction.pierceDefence,
          other: target,
          addTraits: currentCard.traits,
        );
        // no corresponding code found, copying logic of pierceDefence
        final hasPierceSubDamage = await activator.hasBuff(
          battleData,
          BuffAction.pierceSubdamage,
          other: target,
          addTraits: currentCard.traits,
        );

        damageParameters
          ..cardResist = await target.getBuffValue(
            battleData,
            BuffAction.commandDef,
            other: activator,
            otherAddTraits: currentCard.traits,
          )
          ..defenseBuff = damageFunction?.funcType == FuncType.damageNpPierce || hasPierceDefense
              ? await target.getBuffValue(
                  battleData,
                  BuffAction.defencePierce,
                  other: activator,
                  otherAddTraits: currentCard.traits,
                )
              : await target.getBuffValue(
                  battleData,
                  BuffAction.defence,
                  other: activator,
                  otherAddTraits: currentCard.traits,
                )
          ..specificDefenseBuff = await target.getBuffValue(
            battleData,
            BuffAction.selfdamage,
            other: activator,
            otherAddTraits: currentCard.traits,
          )
          ..percentDefenseBuff = await target.getBuffValue(
            battleData,
            BuffAction.specialdefence,
            other: activator,
            otherAddTraits: currentCard.traits,
          )
          ..damageReceiveAdditionBuff = (hasPierceSubDamage
                  ? await target.getBuffValue(
                      battleData,
                      BuffAction.receiveDamagePierce,
                      other: activator,
                      otherAddTraits: currentCard.traits,
                    )
                  : await target.getBuffValue(
                      battleData,
                      BuffAction.receiveDamage,
                      other: activator,
                      otherAddTraits: currentCard.traits,
                    )) +
              await target.getBuffValue(
                battleData,
                BuffAction.specialReceiveDamage,
                other: activator,
                otherAddTraits: currentCard.traits,
              );

        atkNpParameters.cardResist = await target.getBuffValue(
          battleData,
          BuffAction.commandNpDef,
          other: activator,
          otherAddTraits: currentCard.traits,
        );

        starParameters
          ..cardResist = await target.getBuffValue(
            battleData,
            BuffAction.commandStarDef,
            other: activator,
            otherAddTraits: currentCard.traits,
          )
          ..enemyStarGenResist = await target.getBuffValue(
            battleData,
            BuffAction.criticalStarDamageTaken,
            other: activator,
            otherAddTraits: currentCard.traits,
          );
      }
      final multiAttack = await activator.getMultiAttackBuffValue(battleData, currentCard, target);

      // real
      final int totalDamage = await DamageAdjustor.show(battleData, activator, target, damageParameters);

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

      final previousHp = target.hp;
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

      target.lastHitBy = activator;
      target.lastHitByCard = currentCard;
      target.lastHitByFunc = damageFunction;

      if (await shouldSkipLethalDamage(battleData, activator, target, currentCard)) {
        target.setHp(previousHp);
      }

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

      battleData.setFuncResult(target.uniqueId, true);

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
    }

    if (shouldTrigger) {
      for (final target in targets) {
        final isMainTarget = battleData.isActorMainTarget(target);
        await activator.activateBuffs(
          battleData,
          [
            BuffAction.functionCommandcodeattackAfter,
            if (isMainTarget) BuffAction.functionCommandcodeattackAfterMainOnly,
          ],
          other: target,
          addTraits: currentCard.traits,
        );
        await activator.activateBuffs(
          battleData,
          [
            if (!currentCard.isTD) BuffAction.functionCommandattackAfter,
            if (!currentCard.isTD && isMainTarget) BuffAction.functionCommandattackAfterMainOnly,
            BuffAction.functionAttackAfter,
            if (isMainTarget) BuffAction.functionAttackAfterMainOnly,
          ],
          other: target,
          addTraits: currentCard.traits,
        );
      }
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

  static Future<int> getSpecificDamage(
    final BattleData battleData,
    final BattleServantData activator,
    final BattleServantData target,
    final CommandCardData currentCard,
  ) async {
    int specificAttackBuff = 0;
    specificAttackBuff += await activator.getBuffValue(
      battleData,
      BuffAction.damage,
      other: target,
      addTraits: currentCard.traits,
    );

    // does not look for target's traits
    specificAttackBuff += await activator.getBuffValue(
      battleData,
      BuffAction.damageIndividuality,
      addTraits: currentCard.traits,
      otherAddTraits: target.getBuffTraits(activeOnly: false),
    );

    // does not look for target's traits
    specificAttackBuff += await activator.getBuffValue(
      battleData,
      BuffAction.damageIndividualityActiveonly,
      addTraits: currentCard.traits,
      otherAddTraits: target.getBuffTraits(activeOnly: true, ignoreIndivUnreleaseable: true), // TODO: figure out ignoreIndivUnreleaseable
    );

    // does not look for target's traits
    specificAttackBuff += await activator.getBuffValue(
      battleData,
      BuffAction.damageEventPoint,
      addTraits: currentCard.traits,
      otherAddTraits: target.getBuffTraits(activeOnly: true),
    );

    return specificAttackBuff;
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

        final previousHp = target.hp;
        target.receiveDamage(hitDamage);
        if (target != activator) {
          target.procAccumulationDamage(previousHp);
        }
      }

      target.actionHistory.add(BattleServantActionHistory(
        actType:
            currentCard.isTD ? BattleServantActionHistoryType.damageTd : BattleServantActionHistoryType.damageCommand,
        targetUniqueId: activator.uniqueId,
        isOpponent: activator.isPlayer != target.isPlayer,
      ));

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
    target.addReducedHp(totalDamage - remainingDamage);
    target.attacked = true;

    return result;
  }

  static Future<bool> shouldSkipDamage(
    final BattleData battleData,
    final BattleServantData activator,
    final BattleServantData target,
    final CommandCardData currentCard,
  ) async {
    // this one is different as it ignores all pierce effects
    // no corresponding code found, copying logic for avoidance
    final hasAvoidanceIndividuality = await target.hasBuff(
      battleData,
      BuffAction.avoidanceIndividuality,
      other: activator,
      otherAddTraits: currentCard.traits,
    );
    if (hasAvoidanceIndividuality) {
      return true;
    }

    // ordered this way to ensure relevant buffs are still used regardless of damage being skipped or not
    final hasSpecialInvincible = await target.hasBuff(
      battleData,
      BuffAction.specialInvincible, // no corresponding code found, copying logic for avoidance
      other: activator,
      otherAddTraits: currentCard.traits,
    );
    final hasPierceInvincible = await activator.hasBuff(
      battleData,
      BuffAction.pierceInvincible,
      other: target,
      addTraits: currentCard.traits,
    );
    if (hasSpecialInvincible) {
      return true;
    }

    final hasInvincible = await target.hasBuff(
      battleData,
      BuffAction.invincible,
      other: activator,
      otherAddTraits: currentCard.traits,
    );
    if (hasPierceInvincible) {
      return false;
    }

    final hasBreakAvoidance = await activator.hasBuff(
      battleData,
      BuffAction.breakAvoidance,
      other: target,
      addTraits: currentCard.traits,
    );
    if (hasInvincible) {
      return true;
    }

    final hasAvoidance = await target.hasBuff(
      battleData,
      BuffAction.avoidance,
      other: activator,
      otherAddTraits: currentCard.traits,
    );
    return !hasBreakAvoidance && hasAvoidance;
  }

  static Future<bool> shouldSkipLethalDamage(
    final BattleData battleData,
    final BattleServantData activator,
    final BattleServantData target,
    final CommandCardData currentCard,
  ) async {
    final hasPierceInvincible = await activator.hasBuff(
      battleData,
      BuffAction.pierceInvincible,
      other: target,
      addTraits: currentCard.traits,
    );
    final hasBreakAvoidance = await activator.hasBuff(
      battleData,
      BuffAction.breakAvoidance,
      other: target,
      addTraits: currentCard.traits,
    );
    final hasAvoidanceAttackDeathDamage = await target.hasBuff(
      battleData,
      BuffAction.avoidanceAttackDeathDamage,
      other: activator,
      otherAddTraits: currentCard.traits,
    );
    if (hasPierceInvincible || hasBreakAvoidance) {
      return false;
    }
    return target.hp <= 0 && hasAvoidanceAttackDeathDamage;
  }

  static Future<int> getClassRelation(
    final BattleData battleData,
    final BattleServantData activator,
    final BattleServantData target, [
    final CommandCardData? cardData,
  ]) async {
    int relation;
    relation = await activator.getClassRelation(battleData, target, cardData, false);
    relation = await target.getClassRelation(battleData, activator, cardData, true);

    return relation;
  }
}
