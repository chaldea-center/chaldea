import 'dart:math';
import 'dart:typed_data';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'battle_logger.dart';

const kBattleFuncMiss = 'MISS';
const kBattleFuncNoEffect = 'NO EFFECT';
const kBattleFuncGUARD = 'GUARD';

/// Referencing:
/// https://apps.atlasacademy.io/fgo-docs/deeper/battle/damage.html
/// DamageMod caps are applied when gathering the parameters.
int calculateDamage(final DamageParameters param) {
  // TODO: use classId, log error and return 0
  if (!ConstData.classInfo.containsKey(param.attackerClass.id)) {
    // throw 'Invalid class: ${param.attackerClass}';
    return 0;
  }

  final classAttackCorrection = toModifier(ConstData.classInfo[param.attackerClass.id]?.attackRate ?? 1000);
  final classAdvantage =
      toModifier(param.classAdvantage); // class relation is provisioned due to overwriteClassRelation

  final attributeAdvantage =
      toModifier(ConstData.getAttributeRelation(param.attackerAttribute, param.defenderAttribute));

  if (!ConstData.cardInfo.containsKey(param.currentCardType)) {
    throw 'Invalid current card type: ${param.currentCardType}';
  }

  final chainPos = param.isNp ? 1 : param.chainPos;
  final cardCorrection = toModifier(ConstData.cardInfo[param.currentCardType]![chainPos]!.adjustAtk);

  final firstCardBonus = shouldIgnoreFirstCardBonus(param.isNp, param.firstCardType)
      ? 0
      : param.isMightyChain
          ? toModifier(ConstData.cardInfo[CardType.buster]![1]!.addAtk)
          : toModifier(ConstData.cardInfo[param.firstCardType]![1]!.addAtk);

  final criticalModifier = param.isCritical ? toModifier(ConstData.constants.criticalAttackRate) : 1;

  final extraRate = param.currentCardType == CardType.extra
      ? param.isTypeChain
          ? ConstData.constants.extraAttackRateGrand
          : ConstData.constants.extraAttackRateSingle
      : 1000;
  final extraModifier = toModifier(extraRate);

  final busterChainMod = !param.isNp && param.currentCardType == CardType.buster && param.isTypeChain
      ? toModifier(ConstData.constants.chainbonusBusterRate) * param.attack
      : 0;

  final damageRate = toModifier(param.damageRate);
  final npSpecificAttackRate = toModifier(param.npSpecificAttackRate);
  final cardBuff = toModifier(param.cardBuff);
  final cardResist = toModifier(param.cardResist);
  final attackBuff = toModifier(param.attackBuff);
  final defenseBuff = toModifier(param.defenseBuff);
  final specificAttackBuff = toModifier(param.specificAttackBuff);
  final specificDefenseBuff = toModifier(param.specificDefenseBuff);
  final criticalDamageBuff = param.isCritical ? toModifier(param.criticalDamageBuff) : 0;
  final npDamageBuff = param.isNp ? toModifier(param.npDamageBuff) : 0;
  final percentAttackBuff = toModifier(param.percentAttackBuff);
  final percentDefenseBuff = toModifier(param.percentDefenseBuff);

  final fixedRandom = toModifier(param.fixedRandom);

  final int totalDamage = (param.attack *
              damageRate *
              (firstCardBonus + cardCorrection * max(1 + cardBuff - cardResist, 0)) *
              classAttackCorrection *
              classAdvantage *
              attributeAdvantage *
              fixedRandom *
              toModifier(ConstData.constants.attackRate) *
              max(1 + attackBuff - defenseBuff, 0) *
              criticalModifier *
              extraModifier *
              max(1 - percentDefenseBuff, 0) *
              max(1 + specificAttackBuff - specificDefenseBuff + criticalDamageBuff + npDamageBuff, 0.001) *
              max(1 + percentAttackBuff, 0.001) *
              npSpecificAttackRate *
              (param.totalHits / 100.0) +
          param.damageAdditionBuff -
          param.damageReductionBuff +
          busterChainMod)
      .toInt();

  return max(0, totalDamage);
}

/// Referencing:
/// https://atlasacademy.github.io/fgo-docs/deeper/battle/np.html
/// Float arithmetic used due to:
/// https://atlasacademy.github.io/fgo-docs/deeper/battle/32-bit-float.html
int calculateAttackNpGain(final AttackNpGainParameters param) {
  if (!ConstData.cardInfo.containsKey(param.currentCardType)) {
    throw 'Invalid current card type: ${param.currentCardType}';
  }

  final chainPos = param.isNp ? 1 : param.chainPos;
  final cardCorrection = toModifier(ConstData.cardInfo[param.currentCardType]![chainPos]!.adjustTdGauge);

  final firstCardBonus = shouldIgnoreFirstCardBonus(param.isNp, param.firstCardType)
      ? 0
      : param.isMightyChain
          ? toModifier(ConstData.cardInfo[CardType.arts]![1]!.addTdGauge)
          : toModifier(ConstData.cardInfo[param.firstCardType]![1]!.addTdGauge);
  final criticalModifier = param.isCritical ? toModifier(ConstData.constants.criticalTdPointRate) : 1.0;

  final cardBuff = toModifier(param.cardBuff);
  final cardResist = toModifier(param.cardResist);
  final npGainBuff = toModifier(param.npGainBuff);

  final ByteData float = ByteData(4);
  float.setFloat32(0, cardBuff - cardResist);
  float.setFloat32(0, max(1 + float.getFloat32(0), 0));
  float.setFloat32(0, cardCorrection * float.getFloat32(0));
  float.setFloat32(0, firstCardBonus + float.getFloat32(0));
  final cardGain = float.getFloat32(0);

  float.setFloat32(0, npGainBuff);
  final npBonusGain = float.getFloat32(0);

  final defenderNpRate = toModifier(param.defenderNpRate);
  final cardAttackNpRate = toModifier(param.cardAttackNpRate);

  float.setFloat32(0, param.attackerNpCharge * criticalModifier);
  float.setFloat32(0, defenderNpRate * float.getFloat32(0));
  float.setFloat32(0, cardGain * float.getFloat32(0));
  float.setFloat32(0, npBonusGain * float.getFloat32(0));
  float.setFloat32(0, cardAttackNpRate * float.getFloat32(0));
  final beforeOverkill = float.getFloat32(0).floor();

  final overkillModifier = param.isOverkill ? toModifier(ConstData.constants.overKillNpRate) : 1.0;
  float.setFloat32(0, beforeOverkill * overkillModifier);
  return float.getFloat32(0).floor();
}

/// Referencing:
/// https://atlasacademy.github.io/fgo-docs/deeper/battle/np.html
/// Float arithmetic used due to:
/// https://atlasacademy.github.io/fgo-docs/deeper/battle/32-bit-float.html
int calculateDefendNpGain(final DefendNpGainParameters param) {
  final attackerNpRate = toModifier(param.attackerNpRate);
  final npGainBuff = toModifier(param.npGainBuff);
  final defenseNpGainBuff = toModifier(param.defenseNpGainBuff);

  final ByteData float = ByteData(4);
  float.setFloat32(0, npGainBuff);
  final npBonusGain = float.getFloat32(0);

  float.setFloat32(0, defenseNpGainBuff);
  final defNpBonusGain = float.getFloat32(0);

  final cardDefenseNpRate = toModifier(param.cardDefNpRate);

  float.setFloat32(0, param.defenderNpCharge * attackerNpRate);
  float.setFloat32(0, npBonusGain * float.getFloat32(0));
  float.setFloat32(0, defNpBonusGain * float.getFloat32(0));
  float.setFloat32(0, cardDefenseNpRate * float.getFloat32(0));
  final beforeOverkill = float.getFloat32(0);

  final overkillModifier = param.isOverkill ? toModifier(ConstData.constants.overKillNpRate) : 1.0;
  float.setFloat32(0, beforeOverkill * overkillModifier);
  return float.getFloat32(0).floor();
}

/// Referencing:
/// https://atlasacademy.github.io/fgo-docs/deeper/battle/critstars.html
int calculateStar(final StarParameters param) {
  if (!ConstData.cardInfo.containsKey(param.currentCardType)) {
    throw 'Invalid current card type: ${param.currentCardType}';
  }

  final chainPos = param.isNp ? 1 : param.chainPos;
  final cardCorrection = ConstData.cardInfo[param.currentCardType]![chainPos]!.adjustCritical;

  final firstCardBonus = shouldIgnoreFirstCardBonus(param.isNp, param.firstCardType)
      ? 0
      : param.isMightyChain
          ? ConstData.cardInfo[CardType.quick]![1]!.addCritical
          : ConstData.cardInfo[param.firstCardType]![1]!.addCritical;
  final criticalModifier = param.isCritical ? ConstData.constants.criticalStarRate : 0;

  final defenderStarRate = param.defenderStarRate;

  final cardBuff = toModifier(param.cardBuff);
  final cardResist = toModifier(param.cardResist);

  final cardDropStarRate = toModifier(param.cardDropStarRate);

  final overkillModifier = param.isOverkill ? toModifier(ConstData.constants.overKillStarRate) : 1;
  final overkillAdd = param.isOverkill ? ConstData.constants.overKillStarAdd : 0;

  // not converted to modifier since mostly just additions.
  final dropRate = ((param.attackerStarGen +
                  firstCardBonus +
                  (cardCorrection * max(1 + cardBuff - cardResist, 0)) +
                  defenderStarRate +
                  param.starGenBuff -
                  param.enemyStarGenResist +
                  criticalModifier) *
              cardDropStarRate *
              overkillModifier +
          overkillAdd)
      .toInt();

  return dropRate.clamp(0, ConstData.constants.starRateMax);
}

bool shouldIgnoreFirstCardBonus(final bool isNP, final CardType firstCardType) {
  return isNP || !ConstData.cardInfo.containsKey(firstCardType) || firstCardType == CardType.blank;
}

double toModifier(final int value) {
  return 0.001 * value;
}

class DamageParameters {
  int attack = 0; // servantAtk
  int damageRate = 1000; // npDamageMultiplier
  int totalHits = 100;
  int npSpecificAttackRate = 1000; // superEffectiveModifier = function Correction value
  SvtClass attackerClass = SvtClass.none;
  SvtClass defenderClass = SvtClass.none;
  int classAdvantage = 0;
  Attribute attackerAttribute = Attribute.void_;
  Attribute defenderAttribute = Attribute.void_;
  bool isNp = false;
  int chainPos = 1;
  CardType currentCardType = CardType.none;
  CardType firstCardType = CardType.none;
  bool isTypeChain = false;
  bool isMightyChain = false;
  bool isCritical = false;
  int cardBuff = 1000; // cardMod = actor.commandAtk
  int cardResist = 1000; // cardMod = target.commandDef
  int attackBuff = 1000; // atkMod = actor.atk
  int defenseBuff = 1000; // defMod = target.defence or target.defencePierce
  int specificAttackBuff =
      0; // powerMod = actor.damage + actor.damageIndividuality + actor.damageIndividualityActiveonly + actor.damageEventPoint
  int specificDefenseBuff = 0; // selfDamageMod = target.selfDamage, can rename after I see an instance of this buff
  int criticalDamageBuff = 0; // critDamageMod = actor.criticalDamage
  int npDamageBuff = 0; // npDamageMod = actor.npdamage
  int percentAttackBuff = 0; // damageSpecialMod = actor.damageSpecial
  int percentDefenseBuff = 0; // specialDefMod = target.specialdefence
  int damageAdditionBuff = 0; // dmgPlusAdd = actor.givenDamage
  int damageReductionBuff = 0; // selfDmgCutAdd = target.receiveDamage
  int fixedRandom = 0;

  @override
  String toString() {
    return 'DamageParameters: {'
        'attack: $attack, '
        'damageRate: $damageRate, '
        'totalHits: $totalHits, '
        'npSpecificAttackRate: $npSpecificAttackRate, '
        'attackerClass: $attackerClass, '
        'defenderClass: $defenderClass, '
        'classAdvantage: $classAdvantage, '
        'attackerAttribute: $attackerAttribute, '
        'defenderAttribute: $defenderAttribute, '
        'isNp: $isNp, '
        'chainPos: $chainPos, '
        'currentCardType: $currentCardType, '
        'firstCardType: $firstCardType, '
        'isTypeChain: $isTypeChain, '
        'isMightyChain: $isMightyChain, '
        'isCritical: $isCritical, '
        'cardBuff: $cardBuff, '
        'cardResist: $cardResist, '
        'attackBuff: $attackBuff, '
        'defenseBuff: $defenseBuff, '
        'specificAttackBuff: $specificAttackBuff, '
        'specificDefenseBuff: $specificDefenseBuff, '
        'criticalDamageBuff: $criticalDamageBuff, '
        'npDamageBuff: $npDamageBuff, '
        'percentAttackBuff: $percentAttackBuff, '
        'percentDefenseBuff: $percentDefenseBuff, '
        'damageAdditionBuff: $damageAdditionBuff, '
        'damageReductionBuff: $damageReductionBuff, '
        'fixedRandom: $fixedRandom'
        '}';
  }

  DamageParameters copy() {
    return DamageParameters()
      ..attack = attack
      ..damageRate = damageRate
      ..totalHits = totalHits
      ..npSpecificAttackRate = npSpecificAttackRate
      ..attackerClass = attackerClass
      ..defenderClass = defenderClass
      ..classAdvantage = classAdvantage
      ..attackerAttribute = attackerAttribute
      ..defenderAttribute = defenderAttribute
      ..isNp = isNp
      ..chainPos = chainPos
      ..currentCardType = currentCardType
      ..firstCardType = firstCardType
      ..isTypeChain = isTypeChain
      ..isMightyChain = isMightyChain
      ..isCritical = isCritical
      ..cardBuff = cardBuff
      ..cardResist = cardResist
      ..attackBuff = attackBuff
      ..defenseBuff = defenseBuff
      ..specificAttackBuff = specificAttackBuff
      ..specificDefenseBuff = specificDefenseBuff
      ..criticalDamageBuff = criticalDamageBuff
      ..npDamageBuff = npDamageBuff
      ..percentAttackBuff = percentAttackBuff
      ..percentDefenseBuff = percentDefenseBuff
      ..damageAdditionBuff = damageAdditionBuff
      ..damageReductionBuff = damageReductionBuff
      ..fixedRandom = fixedRandom;
  }
}

class AttackNpGainParameters {
  int attackerNpCharge = 0;
  int defenderNpRate = 0;
  int cardAttackNpRate = 1000;
  bool isNp = false;
  int chainPos = 1;
  CardType currentCardType = CardType.none;
  CardType firstCardType = CardType.none;
  bool isMightyChain = false;
  bool isCritical = false;
  int cardBuff = 1000; // cardMod = atkSvt.commandNpAtk
  int cardResist = 1000; // cardMod = target.commandNpDef
  int npGainBuff = 1000; // npChargeRateMod = atkSvt.dropNp
  bool isOverkill = false;

  @override
  String toString() {
    return 'AttackNpGainParameters: {'
        'attackerNpCharge: $attackerNpCharge, '
        'defenderNpRate: $defenderNpRate, '
        'cardAttackNpRate: $cardAttackNpRate, '
        'isNp: $isNp, '
        'chainPos: $chainPos, '
        'currentCardType: $currentCardType, '
        'firstCardType: $firstCardType, '
        'isMightyChain: $isMightyChain, '
        'isCritical: $isCritical, '
        'cardBuff: $cardBuff, '
        'cardResist: $cardResist, '
        'npGainBuff: $npGainBuff, '
        'isOverkill: $isOverkill'
        '}';
  }

  AttackNpGainParameters copy() {
    return AttackNpGainParameters()
      ..attackerNpCharge = attackerNpCharge
      ..defenderNpRate = defenderNpRate
      ..cardAttackNpRate = cardAttackNpRate
      ..isNp = isNp
      ..chainPos = chainPos
      ..currentCardType = currentCardType
      ..firstCardType = firstCardType
      ..isMightyChain = isMightyChain
      ..isCritical = isCritical
      ..cardBuff = cardBuff
      ..cardResist = cardResist
      ..npGainBuff = npGainBuff
      ..isOverkill = isOverkill;
  }
}

class DefendNpGainParameters {
  int defenderNpCharge = 0;
  int attackerNpRate = 0;
  int cardDefNpRate = 1000;
  int npGainBuff = 1000; // npChargeRateMod = defSvt.dropNp
  int defenseNpGainBuff = 1000; // defensiveChargeRateMod = defSvt.dropNpDamage
  bool isOverkill = false;

  @override
  String toString() {
    return 'DefendNpGainParameters: {'
        'defenderNpCharge: $defenderNpCharge, '
        'attackerNpRate: $attackerNpRate, '
        'cardDefNpRate: $cardDefNpRate, '
        'npGainBuff: $npGainBuff, '
        'defenseNpGainBuff: $defenseNpGainBuff, '
        'isOverkill: $isOverkill'
        '}';
  }

  DefendNpGainParameters copy() {
    return DefendNpGainParameters()
      ..defenderNpCharge = defenderNpCharge
      ..attackerNpRate = attackerNpRate
      ..cardDefNpRate = cardDefNpRate
      ..npGainBuff = npGainBuff
      ..defenseNpGainBuff = defenseNpGainBuff
      ..isOverkill = isOverkill;
  }
}

class StarParameters {
  int attackerStarGen = 0;
  int defenderStarRate = 0;
  int cardDropStarRate = 1000;
  bool isNp = false;
  int chainPos = 1;
  CardType currentCardType = CardType.none;
  CardType firstCardType = CardType.none;
  bool isMightyChain = false;
  bool isCritical = false;
  int cardBuff = 1000; // cardMod = atkSvt.commandStarAtk
  int cardResist = 1000; // cardMod = defSvt.commandStarDef
  int starGenBuff = 0; // starDropMod = atkSvt.criticalPoint
  int enemyStarGenResist = 0; // enemyStarDropMod = defSvt.criticalStarDamageTaken
  bool isOverkill = false;

  @override
  String toString() {
    return 'StarParameters: {'
        'attackerStarGen: $attackerStarGen, '
        'defenderStarRate: $defenderStarRate, '
        'cardDropStarRate: $cardDropStarRate, '
        'isNp: $isNp, '
        'chainPos: $chainPos, '
        'currentCardType: $currentCardType, '
        'firstCardType: $firstCardType, '
        'isMightyChain: $isMightyChain, '
        'isCritical: $isCritical, '
        'cardBuff: $cardBuff, '
        'cardResist: $cardResist, '
        'starGenBuff: $starGenBuff, '
        'enemyStarGenResist: $enemyStarGenResist, '
        'isOverkill: $isOverkill'
        '}';
  }

  StarParameters copy() {
    return StarParameters()
      ..attackerStarGen = attackerStarGen
      ..defenderStarRate = defenderStarRate
      ..cardDropStarRate = cardDropStarRate
      ..isNp = isNp
      ..chainPos = chainPos
      ..currentCardType = currentCardType
      ..firstCardType = firstCardType
      ..isMightyChain = isMightyChain
      ..isCritical = isCritical
      ..cardBuff = cardBuff
      ..cardResist = cardResist
      ..starGenBuff = starGenBuff
      ..isOverkill = isOverkill;
  }
}

class DamageResult {
  List<int> cardHits = [];
  List<int> damages = [];
  List<int> npGains = [];
  List<int> defNpGains = [];
  List<int> stars = [];
  List<bool> overkillStates = [];

  DamageResult copy() {
    return DamageResult()
      ..stars = stars.toList()
      ..damages = damages.toList()
      ..npGains = npGains.toList()
      ..defNpGains = defNpGains.toList()
      ..cardHits = cardHits.toList()
      ..overkillStates = overkillStates.toList();
  }
}

class InstantDeathParameters {
  bool isForce = false;
  bool immune = false;
  int functionRate = 0;
  int deathRate = 0;
  int buffRate = 0;

  int activateRate = 0;
  bool success = false;
  String resultString = '';

  InstantDeathParameters copy() {
    return InstantDeathParameters()
      ..isForce = isForce
      ..immune = immune
      ..functionRate = functionRate
      ..deathRate = deathRate
      ..buffRate = buffRate
      ..activateRate = activateRate
      ..success = success
      ..resultString = resultString;
  }

  bool get isManualSuccess => success && activateRate > 0 && activateRate < 1000;
}

Future<BaseFunction> getDependFunc(BattleLogger logger, DataVals dataVals) async {
  BaseFunction? dependFunction;
  if (dataVals.DependFuncId != null) {
    dependFunction = db.gameData.baseFunctions[dataVals.DependFuncId!] ?? await AtlasApi.func(dataVals.DependFuncId!);
  }
  if (dependFunction == null) {
    logger.error('DependFunctionId=${dataVals.DependFuncId} not found');
    throw ArgumentError('DependFunctionId=${dataVals.DependFuncId} not found');
  }
  return dependFunction;
}

class BattleUtils {
  const BattleUtils._();

  static final List<int> costumeOrtinaxIds = [12, 800140, 13, 800150];
  static final List<int> melusineDragonIds = [3, 4, 13, 304850];

  static List<NiceTd> getShownTds(final Servant svt, final int ascension) {
    final List<NiceTd> shownTds = svt.groupedNoblePhantasms[1]?.toList() ?? <NiceTd>[];
    // only case where we different groups of noblePhantasms exist are for npCardTypeChange

    // Servant specific
    final List<int> removeTdIdList = [];
    if (svt.collectionNo == 1) {
      // Mash
      if (costumeOrtinaxIds.contains(ascension)) {
        removeTdIdList.addAll([800100, 800101, 800104]);
      } else {
        removeTdIdList.add(800105);
      }
    } else if (svt.collectionNo == 312) {
      // Melusine
      if (melusineDragonIds.contains(ascension)) {
        removeTdIdList.add(304801);
      } else {
        removeTdIdList.add(304802);
      }
    }

    shownTds.removeWhere((niceTd) => removeTdIdList.contains(niceTd.id));
    return shownTds;
  }

  static List<NiceSkill> getShownSkills(final Servant svt, final int ascension, final int skillNum) {
    final List<NiceSkill> shownSkills = [];
    for (final skill in svt.groupedActiveSkills[skillNum] ?? <NiceSkill>[]) {
      if (shownSkills.every((storeSkill) => storeSkill.id != skill.id)) {
        shownSkills.add(skill);
      }
    }

    // Servant specific
    final List<int> removeSkillIdList = [];
    if (svt.collectionNo == 1) {
      // Mash
      if (costumeOrtinaxIds.contains(ascension)) {
        if (skillNum == 1) {
          removeSkillIdList.addAll([1000, 236000]);
        } else if (skillNum == 2) {
          removeSkillIdList.addAll([2000]);
        } else {
          removeSkillIdList.addAll([133000]);
        }
      } else {
        if (skillNum == 1) {
          removeSkillIdList.addAll([459550, 744450]);
        } else if (skillNum == 2) {
          removeSkillIdList.addAll([460250]);
        } else {
          removeSkillIdList.addAll([457000, 2162350]);
        }
      }
    } else if (svt.collectionNo == 312 && skillNum == 3) {
      // Melusine
      if (melusineDragonIds.contains(ascension)) {
        removeSkillIdList.add(888550);
      } else {
        removeSkillIdList.add(888575);
      }
    }

    shownSkills.removeWhere((niceSkill) => removeSkillIdList.contains(niceSkill.id));
    return shownSkills;
  }
}
