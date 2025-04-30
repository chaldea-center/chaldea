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
    final bool isComboStart = false,
    final bool isComboEnd = false,
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
          opponent: target,
          card: currentCard,
        );
        await activator.activateBuffs(
          battleData,
          [
            if (!currentCard.isTD) BuffAction.functionCommandattackBefore,
            if (!currentCard.isTD && isMainTarget) BuffAction.functionCommandattackBeforeMainOnly,
            BuffAction.functionAttackBefore,
            if (isMainTarget) BuffAction.functionAttackBeforeMainOnly,
            // if (isComboStart) BuffAction.functionComboStart,
          ],
          opponent: target,
          card: currentCard,
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
      final hpRatioDamageLow =
          checkHpRatioLow && dataVals.Target != null
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
          final ignoreIndivUnreleaseable = dataVals.IgnoreIndivUnreleaseable == 1;

          int useCount =
              countTarget.countBuffWithTrait(requiredTraits, ignoreIndivUnreleaseable: ignoreIndivUnreleaseable) +
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

          final useCorrection =
              damageNpSEDecision?.useCorrection ??
              checkSignedIndividualities2(
                myTraits: target.getTraits(),
                requiredTraits: [NiceTrait(id: dataVals.Target!)],
              );

          if (useCorrection) {
            specificAttackRate = dataVals.Correction!;
          }
        } else if (funcType == FuncType.damageNpAndOrCheckIndividuality) {
          final damageNpSEDecision = battleData.delegate?.damageNpSE?.call(activator, damageFunction, dataVals);

          final useCorrection =
              damageNpSEDecision?.useCorrection ?? damageNpAndOrCheckIndividualityDecision(target, dataVals);

          if (useCorrection) {
            specificAttackRate = dataVals.Correction!;
          }
        } else if (funcType == FuncType.damageNpStateIndividualFix) {
          final damageNpSEDecision = battleData.delegate?.damageNpSE?.call(activator, damageFunction, dataVals);
          final includeIgnoreIndividuality = dataVals.IncludeIgnoreIndividuality == 1;

          final useCorrection =
              damageNpSEDecision?.useCorrection ??
              checkSignedIndividualities2(
                myTraits: target.getBuffTraits(includeIgnoreIndiv: includeIgnoreIndividuality),
                requiredTraits: [NiceTrait(id: dataVals.Target!)],
              );

          if (useCorrection) {
            specificAttackRate = dataVals.Correction!;
          }
        } else if (funcType == FuncType.damageNpBattlePointPhase) {
          final damageNpSEDecision = battleData.delegate?.damageNpSE?.call(activator, damageFunction, dataVals);

          final battlePointId = dataVals.Target!;
          int curPhase = damageNpSEDecision?.indivSumCount ?? activator.determineBattlePointPhase(battlePointId);
          curPhase = curPhase.clamp(0, activator.getMaxBattlePointPhase(battlePointId));
          final specifiedPhase = dataVals.DamageRateBattlePointPhase?.firstWhereOrNull(
            (phase) => phase.battlePointPhase == curPhase,
          );

          if (specifiedPhase != null) {
            specificAttackRate = specifiedPhase.value;
          } else {
            specificAttackRate = dataVals.Value2! + dataVals.Correction! * curPhase;
          }
        }
      }

      final damageParameters =
          DamageParameters()
            ..attack = activator.atk + currentCard.cardStrengthen
            ..totalHits = Maths.sum(currentCard.cardDetail.hitsDistribution)
            ..damageRate =
                currentCard.isTD
                    ? dataVals.Value! + hpRatioDamageLow + hpRatioDamageHigh
                    : currentCard.cardDetail.damageRate ?? 1000
            ..damageRateModifier = getDamageRateModifier(battleData, currentCard, target)
            ..npSpecificAttackRate = specificAttackRate
            ..attackerClass = activator.logicalClassId
            ..defenderClass = target.logicalClassId
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
              opponent: target,
              card: currentCard,
            )
            ..attackBuff = await activator.getBuffValue(battleData, BuffAction.atk, opponent: target, card: currentCard)
            ..damageBuff = await getSpecificDamage(battleData, activator, target, currentCard)
            ..criticalDamageBuff =
                currentCard.critical
                    ? await activator.getBuffValue(
                      battleData,
                      BuffAction.criticalDamage,
                      opponent: target,
                      card: currentCard,
                    )
                    : 0
            ..npDamageBuff =
                currentCard.isTD
                    ? await activator.getBuffValue(battleData, BuffAction.npdamage, opponent: target, card: currentCard)
                    : 0
            ..specialDamageBuff = await activator.getBuffValue(
              battleData,
              BuffAction.damageSpecial,
              opponent: target,
              card: currentCard,
            )
            ..damageAdditionBuff = await activator.getBuffValue(
              battleData,
              BuffAction.givenDamage,
              opponent: target,
              card: currentCard,
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
          ..cardAttackNpRate = currentCard.cardDetail.attackNpRate ?? 1000
          ..isNp = currentCard.isTD
          ..chainPos = chainPos
          ..currentCardType = currentCard.cardType
          ..firstCardType = firstCardType
          ..isMightyChain = isMightyChain
          ..critical = currentCard.critical
          ..cardBuff = await activator.getBuffValue(
            battleData,
            BuffAction.commandNpAtk,
            opponent: target,
            card: currentCard,
          )
          ..npGainBuff = await activator.getBuffValue(
            battleData,
            BuffAction.dropNp,
            opponent: target,
            card: currentCard,
            isAttack: true,
          );

        starParameters
          ..attackerStarGen = activator.starGen
          ..defenderStarRate = target.enemyStarRate
          ..cardDropStarRate = currentCard.cardDetail.dropStarRate ?? 1000
          ..isNp = currentCard.isTD
          ..chainPos = chainPos
          ..currentCardType = currentCard.cardType
          ..firstCardType = firstCardType
          ..isMightyChain = isMightyChain
          ..critical = currentCard.critical
          ..cardBuff = await activator.getBuffValue(
            battleData,
            BuffAction.commandStarAtk,
            opponent: target,
            card: currentCard,
          )
          ..starGenBuff = await activator.getBuffValue(
            battleData,
            BuffAction.criticalPoint,
            opponent: target,
            card: currentCard,
            isAttack: true,
          );
      } else {
        defNpParameters
          ..defenderNpGainRate = target.defenceNpGain
          ..attackerNpRate = activator.enemyTdAttackRate
          ..cardDefNpRate = currentCard.cardDetail.defenseNpRate ?? 1000
          ..npGainBuff = await target.getBuffValue(
            battleData,
            BuffAction.dropNp,
            opponent: activator,
            card: currentCard,
            isAttack: false,
          )
          // very weird as in code it shows selfTrait is on attacker, although no real application to confirm this
          ..defenseNpGainBuff = await target.getBuffValueFixedTraits(
            battleData,
            BuffAction.dropNpDamage,
            selfTraits: activator.getTraits(addTraits: currentCard.traits),
            opponentTraits: target.getTraits(),
            opponent: activator,
          );

        // Also, I did not implement def star gen
      }

      final skipDamage = await shouldSkipDamage(battleData, activator, target, currentCard);
      final hasPierceDefense = await activator.hasBuff(
        battleData,
        BuffAction.pierceDefence,
        opponent: target,
        card: currentCard,
      );
      // no corresponding code found, copying logic of pierceDefence
      final hasPierceSubDamage = await activator.hasBuff(
        battleData,
        BuffAction.pierceSubdamage,
        opponent: target,
        card: currentCard,
      );

      damageParameters
        ..cardResist = await target.getBuffValue(
          battleData,
          BuffAction.commandDef,
          opponent: activator,
          card: currentCard,
          skipDamage: skipDamage,
        )
        ..defenseBuff = await target.getBuffValue(
          battleData,
          damageFunction?.funcType == FuncType.damageNpPierce || hasPierceDefense
              ? BuffAction.defencePierce
              : BuffAction.defence,
          opponent: activator,
          card: currentCard,
          skipDamage: skipDamage,
        )
        ..damageDefBuff = await target.getBuffValue(
          battleData,
          BuffAction.damageDef,
          opponent: activator,
          card: currentCard,
          skipDamage: skipDamage,
        )
        ..criticalDamageDefBuff =
            currentCard.critical
                ? await target.getBuffValue(
                  battleData,
                  BuffAction.criticalDamageDef,
                  opponent: activator,
                  card: currentCard,
                  skipDamage: skipDamage,
                )
                : 0
        ..npDamageDefBuff =
            currentCard.isTD
                ? await target.getBuffValue(
                  battleData,
                  BuffAction.npdamageDef,
                  opponent: activator,
                  card: currentCard,
                  skipDamage: skipDamage,
                )
                : 0
        ..specialDefenseBuff = await target.getBuffValue(
          battleData,
          BuffAction.specialdefence,
          opponent: activator,
          card: currentCard,
          skipDamage: skipDamage,
        )
        ..damageReceiveAdditionBuff =
            await target.getBuffValue(
              battleData,
              hasPierceSubDamage ? BuffAction.receiveDamagePierce : BuffAction.receiveDamage,
              opponent: activator,
              card: currentCard,
              skipDamage: skipDamage,
            ) +
            await target.getBuffValue(
              battleData,
              BuffAction.specialReceiveDamage,
              opponent: activator,
              card: currentCard,
              skipDamage: skipDamage,
            );

      atkNpParameters.cardResist = await target.getBuffValue(
        battleData,
        BuffAction.commandNpDef,
        opponent: activator,
        card: currentCard,
        skipDamage: skipDamage,
      );

      starParameters
        ..cardResist = await target.getBuffValue(
          battleData,
          BuffAction.commandStarDef,
          opponent: activator,
          card: currentCard,
          skipDamage: skipDamage,
        )
        ..enemyStarGenResist = await target.getBuffValue(
          battleData,
          BuffAction.criticalStarDamageTaken,
          opponent: activator,
          card: currentCard,
          skipDamage: skipDamage,
        );

      final multiAttack = await activator.getMultiAttackBuffValue(battleData, currentCard, target);

      // real
      int totalDamage = await DamageAdjustor.show(
        battleData,
        activator,
        target,
        damageParameters,
        currentCard,
        multiAttack,
      );
      if (funcType == FuncType.damageNpSafe && target.hp > 0 && totalDamage >= target.hp) {
        totalDamage = target.hp - 1;
      }

      // calc min/max first, since it doesn't change original target/activator
      final minResult = await _calc(
            totalDamage: calculateDamageNoError(
              damageParameters.copy()..random = ConstData.constants.attackRateRandomMin,
            ),
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
            totalDamage: calculateDamageNoError(
              damageParameters.copy()..random = ConstData.constants.attackRateRandomMax - 1,
            ),
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
      final starString =
          activator.isPlayer
              ? '${S.current.critical_star}: ${(Maths.sum(result.stars) / 1000).toStringAsFixed(3)} - '
              : '';
      battleData.battleLogger.action(
        '${activator.lBattleName} - ${currentCard.cardType.name.toUpperCase()} - '
        '${currentCard.isTD ? S.current.battle_np_card : S.current.battle_command_card} - '
        '${S.current.effect_target}: ${target.lBattleName} - '
        '${S.current.battle_damage}: $totalDamage - '
        '${S.current.battle_remaining_hp}: ${target.hp}/${target.maxHp} - '
        'NP: ${(Maths.sum(result.npGains) / 100).toStringAsFixed(2)}% - '
        '$starString'
        'Overkill: ${result.overkillStates.where((e) => e).length}/${currentCard.cardDetail.hitsDistribution.length}',
      );
      final hitStarString = activator.isPlayer ? ', ${S.current.critical_star}: ${result.stars}' : '';
      battleData.battleLogger.debug(
        '${S.current.details}: ${S.current.battle_damage}: ${result.damages}, NP: ${result.npGains}, '
        'DefNP: ${result.defNpGains}$hitStarString',
      );

      battleData.changeStar(toModifier(Maths.sum(result.stars)));

      if (shouldDamageRelease) {
        target.battleBuff.originalActiveList.removeWhere(
          (buff) => buff.checkAct() && buff.buff.script.DamageRelease == 1,
        );
        // passive should also be checked?
        target.battleBuff.originalPassiveList.removeWhere(
          (buff) => buff.checkAct() && buff.buff.script.DamageRelease == 1,
        );
      }

      battleData.setFuncResult(target.uniqueId, true);

      targetResults.add(
        AttackResultDetail(
          target: target,
          targetBefore: targetBefore,
          damageParams: damageParameters,
          attackNpParams: atkNpParameters,
          starParams: starParameters,
          defenseNpParams: defNpParameters,
          result: result,
          minResult: minResult,
          maxResult: maxResult,
        ),
      );
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
          opponent: target,
          card: currentCard,
        );
        await activator.activateBuffs(
          battleData,
          [
            if (!currentCard.isTD) BuffAction.functionCommandattackAfter,
            if (!currentCard.isTD && isMainTarget) BuffAction.functionCommandattackAfterMainOnly,
            BuffAction.functionAttackAfter,
            if (isMainTarget) BuffAction.functionAttackAfterMainOnly,
            // if (isComboEnd) BuffAction.functionComboEnd,
          ],
          opponent: target,
          card: currentCard,
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
    final CommandCardData card,
  ) async {
    int powerMod = 0;
    powerMod += await activator.getBuffValue(battleData, BuffAction.damage, opponent: target, card: card);
    powerMod += await activator.getBuffValue(battleData, BuffAction.damageIndividuality, opponent: target, card: card);
    powerMod += await activator.getBuffValue(
      battleData,
      BuffAction.damageIndividualityActiveonly,
      opponent: target,
      card: card,
    );
    powerMod += await activator.getBuffValue(battleData, BuffAction.damageEventPoint, opponent: target, card: card);

    return powerMod;
  }

  static int getDamageRateModifier(BattleData battleData, CommandCardData currentCard, BattleServantData target) {
    int damageRateModifier = 1000;
    final slideType = currentCard.cardDetail.positionDamageRatesSlideType;
    List<int> positionDamageRates = currentCard.cardDetail.positionDamageRates?.toList() ?? [];
    if (!currentCard.isTD &&
        currentCard.cardDetail.attackType == CommandCardAttackType.all &&
        (slideType != null && slideType != SvtCardPositionDamageRatesSlideType.none)) {
      List<BattleServantData?> svtList = target.isPlayer ? battleData.nonnullPlayers : battleData.nonnullEnemies;
      if (slideType == SvtCardPositionDamageRatesSlideType.back) {
        svtList = svtList.reversed.toList();
        positionDamageRates = positionDamageRates.reversed.toList();
      }
      int position = svtList.indexOf(target);
      int? positionDamageRate = positionDamageRates.getOrNull(position);
      if (positionDamageRate != null) {
        damageRateModifier = positionDamageRate;
      }
    }
    return damageRateModifier;
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

      target.actionHistory.add(
        BattleServantActionHistory(
          actType:
              currentCard.isTD ? BattleServantActionHistoryType.damageTd : BattleServantActionHistoryType.damageCommand,
          targetUniqueId: activator.uniqueId,
          isOpponent: activator.isPlayer != target.isPlayer,
        ),
      );

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

  static bool checkNotPierceIndividuality(final List<List<NiceTrait>> notPierceIndividuality, final BuffData buff) {
    // Currently assuming the first array is OR. Need more samples on this
    for (final requiredTraits in notPierceIndividuality) {
      final match = checkSignedIndividualities2(
        myTraits: buff.getTraits(),
        requiredTraits: requiredTraits,
        positiveMatchFunc: allMatch,
        negativeMatchFunc: allMatch,
      );
      if (match) {
        return true;
      }
    }
    return false;
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
      opponent: activator,
      card: currentCard,
    );
    if (hasAvoidanceIndividuality) {
      return true;
    }

    final pierceSpecialInvincible = await activator.getBuff(
      battleData,
      BuffAction.pierceSpecialInvincible,
      opponent: target,
      card: currentCard,
    );
    if (pierceSpecialInvincible != null) {
      final notPierceIndividuality = pierceSpecialInvincible.buff.script.NotPierceIndividuality;
      // assuming this is only used by pierceSpecialInvincible for now
      if (notPierceIndividuality != null) {
        final specialInvincible = await target.getBuff(
          battleData,
          BuffAction.specialInvincible,
          opponent: activator,
          card: currentCard,
        );
        if (specialInvincible != null && checkNotPierceIndividuality(notPierceIndividuality, specialInvincible)) {
          // cannot pierce special invincible, nothing can help, return true to skip damage
          return true;
        }

        final invincible = await target.getBuff(
          battleData,
          BuffAction.invincible,
          opponent: activator,
          card: currentCard,
          useBuff: false,
        );
        if (invincible != null && checkNotPierceIndividuality(notPierceIndividuality, invincible)) {
          // cannot pierce invincible, check pierceInvincible. Not having pierceInvincible => skipDamage => return true
          invincible.setUsed(target);
          return !await activator.hasBuff(battleData, BuffAction.pierceInvincible, opponent: target, card: currentCard);
        } else if (specialInvincible == null) {
          invincible?.setUsed(target);
        }

        final avoidance = await target.getBuff(
          battleData,
          BuffAction.avoidance,
          opponent: activator,
          card: currentCard,
          useBuff: false,
        );
        if (avoidance != null && checkNotPierceIndividuality(notPierceIndividuality, avoidance)) {
          // cannot pierce avoidance, check pierceInvincible & breakAvoidance
          avoidance.setUsed(target);
          return !await activator.hasBuff(
                battleData,
                BuffAction.pierceInvincible,
                opponent: target,
                card: currentCard,
              ) &&
              !await activator.hasBuff(battleData, BuffAction.breakAvoidance, opponent: target, card: currentCard);
        } else if (specialInvincible == null && invincible == null) {
          avoidance?.setUsed(target);
        }

        // pierce successful
        return false;
      } else {
        // consume one relevant defensive buff
        if (!await target.hasBuff(battleData, BuffAction.specialInvincible, opponent: activator, card: currentCard)) {
          if (!await target.hasBuff(battleData, BuffAction.invincible, opponent: activator, card: currentCard)) {
            await target.hasBuff(battleData, BuffAction.avoidance, opponent: activator, card: currentCard);
          }
        }

        return false;
      }
    }

    if (await target.hasBuff(battleData, BuffAction.specialInvincible, opponent: activator, card: currentCard)) {
      // consume one relevant offensive buff
      if (!await activator.hasBuff(battleData, BuffAction.pierceInvincible, opponent: target, card: currentCard)) {
        await activator.hasBuff(battleData, BuffAction.breakAvoidance, opponent: target, card: currentCard);
      }
      return true;
    }

    if (await activator.hasBuff(battleData, BuffAction.pierceInvincible, opponent: target, card: currentCard)) {
      // consume one relevant defensive buff
      if (!await target.hasBuff(battleData, BuffAction.invincible, opponent: activator, card: currentCard)) {
        await target.hasBuff(battleData, BuffAction.avoidance, opponent: activator, card: currentCard);
      }
      return false;
    }

    if (await target.hasBuff(battleData, BuffAction.invincible, opponent: activator, card: currentCard)) {
      // consume one relevant offensive buff
      await activator.hasBuff(battleData, BuffAction.breakAvoidance, opponent: target, card: currentCard);
      return true;
    }

    final hasBreakAvoidance = await activator.hasBuff(
      battleData,
      BuffAction.breakAvoidance,
      opponent: target,
      card: currentCard,
    );
    final hasAvoidance = await target.hasBuff(battleData, BuffAction.avoidance, opponent: activator, card: currentCard);
    return !hasBreakAvoidance && hasAvoidance;
  }

  static Future<bool> shouldSkipLethalDamage(
    final BattleData battleData,
    final BattleServantData activator,
    final BattleServantData target,
    final CommandCardData currentCard,
  ) async {
    if (target.hp > 0) {
      return false;
    }

    final avoidanceAttackDeathDamage = await target.getBuff(
      battleData,
      BuffAction.avoidanceAttackDeathDamage,
      opponent: activator,
      card: currentCard,
    );
    if (avoidanceAttackDeathDamage == null) {
      return false;
    }

    final pierceSpecialInvincible = await activator.getBuff(
      battleData,
      BuffAction.pierceSpecialInvincible,
      opponent: target,
      card: currentCard,
    );
    if (pierceSpecialInvincible != null) {
      final notPierceIndividuality = pierceSpecialInvincible.buff.script.NotPierceIndividuality;
      // assuming this is only used by pierceSpecialInvincible for now
      if (notPierceIndividuality != null &&
          checkNotPierceIndividuality(notPierceIndividuality, avoidanceAttackDeathDamage)) {
        // cannot pierce avoidance, check pierceInvincible & breakAvoidance
        return !await activator.hasBuff(battleData, BuffAction.pierceInvincible, opponent: target, card: currentCard) &&
            !await activator.hasBuff(battleData, BuffAction.breakAvoidance, opponent: target, card: currentCard);
      }

      // pierce successful
      return false;
    }

    if (await activator.hasBuff(battleData, BuffAction.pierceInvincible, opponent: target, card: currentCard)) {
      return false;
    }

    return !await activator.hasBuff(battleData, BuffAction.breakAvoidance, opponent: target, card: currentCard);
  }

  static Future<int> getClassRelation(
    final BattleData battleData,
    final BattleServantData activator,
    final BattleServantData target, [
    final CommandCardData? cardData,
  ]) async {
    int relation = ConstData.getClassIdRelation(activator.logicalClassId, target.logicalClassId);
    relation = await activator.getClassRelation(battleData, relation, target, cardData, false);
    relation = await target.getClassRelation(battleData, relation, activator, cardData, true);

    return relation;
  }

  static bool damageNpAndOrCheckIndividualityDecision(BattleServantData target, DataVals dataVals) {
    final List<List<int>> andListInOrList =
        dataVals.AndOrCheckIndividualityList ?? [dataVals.AndCheckIndividualityList ?? []];

    if (andListInOrList.every((andList) => andList.isEmpty)) return true;

    for (final List<int> traitAndList in andListInOrList) {
      if (traitAndList.isEmpty) continue;

      final andMatch = checkSignedIndividualities2(
        myTraits: target.getTraits(),
        requiredTraits: NiceTrait.list(traitAndList),
        positiveMatchFunc: allMatch,
        negativeMatchFunc: allMatch,
      );

      if (andMatch) {
        return andMatch;
      }
    }

    return false;
  }
}
