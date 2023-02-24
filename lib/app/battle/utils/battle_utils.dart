import 'dart:math';

import 'package:chaldea/models/gamedata/gamedata.dart';

const double npDamageMultiplier = 0.23;

int calculateNpDamage(NpDamageParameters param) {
  var classAttackCorrection = classAttackCorrections[param.attackerClass] ?? 1;
  var attributeAdvantage = attributeAdvantages[param.attackerAttribute]
          ?[param.defenderAttribute] ??
      1;
  var cardCorrection = getCardCorrection(param.cardType, 0);
  var classAdvantage = getModifierWithCap(param.classAdvantage);

  var damageRate = getModifierWithCap(param.damageRate);
  var npSpecificAttackRate = getModifierWithCap(param.npSpecificAttackRate);
  var cardBuff = getModifierWithCap(param.cardBuff, 4000, -1000);
  var cardResist = getModifierWithCap(param.cardResist);
  var attackBuff = getModifierWithCap(param.attackBuff, 4000, -1000);
  var defenseBuff = getModifierWithCap(param.defenseBuff, null, -1000);
  var specificAttackBuff =
      getModifierWithCap(param.specificAttackBuff, 10000, -1000);
  var specificDefenseBuff = getModifierWithCap(param.specificDefenseBuff);
  var npDamageBuff = getModifierWithCap(param.cardBuff, 5000, -1000);
  var percentAttackBuff = getModifierWithCap(param.cardBuff, 10000, -1000);
  var percentDefenseBuff = getModifierWithCap(param.cardBuff, 1000, -1000);

  final int totalDamage = (param.attack *
              npDamageMultiplier *
              damageRate *
              cardCorrection *
              (1 + cardBuff - cardResist) *
              classAttackCorrection *
              classAdvantage *
              attributeAdvantage *
              (1 + attackBuff - defenseBuff - specificDefenseBuff) *
              (1 + specificAttackBuff + npDamageBuff) *
              npSpecificAttackRate *
              (1 - percentDefenseBuff) *
              (1 + percentAttackBuff) *
              (param.totalHits / 100.0) *
              param.fixedRandom +
          param.damageAdditionBuff -
          param.damageReductionBuff)
      .toInt();

  return max(0, totalDamage);
}

const Map<SvtClass, double> classAttackCorrections = {
  SvtClass.archer: 0.95,
  SvtClass.lancer: 1.05,
  SvtClass.caster: 0.9,
  SvtClass.assassin: 0.9,
  SvtClass.berserker: 1.1,
  SvtClass.ruler: 1.1,
  SvtClass.avenger: 1.1,
};

const Map<Attribute, Map<Attribute, double>> attributeAdvantages = {
  Attribute.sky: {
    Attribute.earth: 1.1,
    Attribute.human: 0.9,
  },
  Attribute.earth: {
    Attribute.sky: 0.9,
    Attribute.human: 1.1,
  },
  Attribute.human: {
    Attribute.sky: 1.1,
    Attribute.earth: 0.9,
  },
  Attribute.star: {Attribute.beast: 1.1},
  Attribute.beast: {
    Attribute.star: 1.1,
  },
};

const Map<CardType, List<double>> cardCorrections = {
  CardType.quick: [0.8, 0.96, 1.12],
  CardType.arts: [1, 1.2, 1.4],
  CardType.buster: [1.5, 1.8, 2.1],
  CardType.extra: [1],
};

double getCardCorrection(CardType cardType, int chainIndex) {
  var correctionList = cardCorrections[cardType];
  if (cardType == CardType.extra) {
    return correctionList![0];
  } else {
    return correctionList![chainIndex];
  }
}

double getModifierWithCap(int value, [int? upperBound, int? lowerBound]) {
  if (upperBound != null && value > upperBound) {
    value = upperBound;
  } else if (lowerBound != null && value < lowerBound) {
    value = lowerBound;
  }

  return 0.001 * value;
}

class NpDamageParameters {
  int attack = 0;
  int damageRate = 0;
  int totalHits = 0;
  int npSpecificAttackRate = 0;
  SvtClass attackerClass = SvtClass.none;
  SvtClass defenderClass = SvtClass.none;
  int classAdvantage = 0;
  Attribute attackerAttribute = Attribute.void_;
  Attribute defenderAttribute = Attribute.void_;
  CardType cardType = CardType.none;
  int cardBuff = 0;
  int cardResist = 0;
  int attackBuff = 0;
  int defenseBuff = 0;
  int specificAttackBuff = 0;
  int specificDefenseBuff = 0;
  int npDamageBuff = 0;
  int percentAttackBuff = 0;
  int percentDefenseBuff = 0;
  int damageAdditionBuff = 0;
  int damageReductionBuff = 0;
  double fixedRandom = 0;

  @override
  String toString() {
    return "attack: $attack, damageRate: $damageRate, totalHits: $totalHits, "
        "npSpecificAttackRate: $npSpecificAttackRate, attackerClass: $attackerClass, "
        "defenderClass: $defenderClass, classAdvantage: $classAdvantage, "
        "attackerAttribute: $attackerAttribute, defenderAttribute: $defenderAttribute, "
        "cardType: $cardType, cardBuff: $cardBuff, cardResist: $cardResist, "
        "attackBuff: $attackBuff, defenseBuff: $defenseBuff, specificAttackBuff: "
        "$specificAttackBuff, specificDefenseBuff: $specificDefenseBuff, "
        "npDamageBuff: $npDamageBuff, percentAttackBuff: $percentAttackBuff, "
        "percentDefenseBuff, $percentDefenseBuff, damageAdditionBuff, $damageAdditionBuff, "
        "damageReductionBuff: $damageReductionBuff, fixedRandom: $fixedRandom";
  }
}
