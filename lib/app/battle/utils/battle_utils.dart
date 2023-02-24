import 'dart:math';

import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';

/// Referencing:
/// https://apps.atlasacademy.io/fgo-docs/deeper/battle/damage.html
/// DamageMod caps are applied when gathering the parameters.
int calculateDamage(final DamageParameters param) {
  var constData = db.gameData.constData;

  if (!constData.classInfo.containsKey(param.attackerClass.id)) {
    throw "Invalid class: ${param.attackerClass}";
  }

  var classAttackCorrection = toModifier(constData.classInfo[param.attackerClass.id]!.attackRate);

  if (!constData.attributeRelation.containsKey(param.attackerAttribute) ||
      !constData.attributeRelation[param.attackerAttribute]!.containsKey(param.defenderAttribute)) {
    throw "Invalid attributes: attacker: ${param.attackerAttribute}, defender: ${param.defenderAttribute}";
  }
  var attributeAdvantage = toModifier(constData.attributeRelation[param.attackerAttribute]![param.defenderAttribute]!);

  if (!constData.cardInfo.containsKey(param.currentCardType)) {
    throw "Invalid current card type: ${param.currentCardType}";
  }

  var chainPos = param.isNp ? 1 : param.chainPos;
  var cardCorrection = toModifier(constData.cardInfo[param.currentCardType]![chainPos]!.adjustAtk);
  var classAdvantage = toModifier(param.classAdvantage);

  if (!constData.cardInfo.containsKey(param.firstCardType)) {
    throw "Invalid first card type: ${param.firstCardType}";
  }
  var firstCardBonus = param.isNp ? 0 : toModifier(constData.cardInfo[param.firstCardType]![1]!.addAtk);

  var criticalModifier = param.isCritical ? toModifier(constData.constants.criticalAttackRate) : 1;

  var extraRate = param.currentCardType == CardType.extra
      ? param.isTypeChain && param.firstCardType == CardType.buster
          ? constData.constants.extraAttackRateGrand
          : constData.constants.extraAttackRateSingle
      : 1000;
  var extraModifier = toModifier(extraRate);

  var damageRate = toModifier(param.damageRate);
  var npSpecificAttackRate = toModifier(param.npSpecificAttackRate);
  var cardBuff = toModifier(param.cardBuff);
  var cardResist = toModifier(param.cardResist);
  var attackBuff = toModifier(param.attackBuff);
  var defenseBuff = toModifier(param.defenseBuff);
  var specificAttackBuff = toModifier(param.specificAttackBuff);
  var specificDefenseBuff = toModifier(param.specificDefenseBuff);
  var criticalDamageBuff = param.isCritical ? toModifier(param.criticalDamageBuff) : 0;
  var npDamageBuff = param.isNp ? toModifier(param.npDamageBuff) : 0;
  var percentAttackBuff = toModifier(param.percentAttackBuff);
  var percentDefenseBuff = toModifier(param.percentDefenseBuff);

  final int totalDamage = (param.attack *
              damageRate *
              (firstCardBonus + cardCorrection * max(1 + cardBuff - cardResist, 0)) *
              classAttackCorrection *
              classAdvantage *
              attributeAdvantage *
              param.fixedRandom *
              toModifier(constData.constants.attackRate) *
              max(1 + attackBuff - defenseBuff, 0) *
              criticalModifier *
              extraModifier *
              max(1 - percentDefenseBuff, 0) *
              max(1 + specificAttackBuff - specificDefenseBuff + criticalDamageBuff + npDamageBuff, 0.001) *
              max(1 + percentAttackBuff, 0.001) *
              npSpecificAttackRate *
              (param.totalHits / 100.0) +
          param.damageAdditionBuff -
          param.damageReductionBuff)
      .toInt();

  return max(0, totalDamage);
}

double toModifier(final int value) {
  return 0.001 * value;
}

class DamageParameters {
  int attack = 0;
  int damageRate = 1000;
  int totalHits = 100;
  int npSpecificAttackRate = 1000;
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
  bool isCritical = false;
  int cardBuff = 1000;
  int cardResist = 1000;
  int attackBuff = 1000;
  int defenseBuff = 1000;
  int specificAttackBuff = 0;
  int specificDefenseBuff = 0; // this maps to selfDamageMod, can rename after I see an instance of this buff
  int criticalDamageBuff = 0;
  int npDamageBuff = 0;
  int percentAttackBuff = 0;
  int percentDefenseBuff = 0;
  int damageAdditionBuff = 0;
  int damageReductionBuff = 0;
  double fixedRandom = 0;

  @override
  String toString() {
    return "attack: $attack, "
        "damageRate: $damageRate, "
        "totalHits: $totalHits, "
        "npSpecificAttackRate: $npSpecificAttackRate, "
        "attackerClass: $attackerClass, "
        "defenderClass: $defenderClass, "
        "classAdvantage: $classAdvantage, "
        "attackerAttribute: $attackerAttribute, "
        "defenderAttribute: $defenderAttribute, "
        "isNp: $isNp, "
        "chainPos: $chainPos, "
        "currentCardType: $currentCardType, "
        "firstCardType: $firstCardType, "
        "isTypeChain: $isTypeChain, "
        "isCritical: $isCritical, "
        "cardBuff: $cardBuff, "
        "cardResist: $cardResist, "
        "attackBuff: $attackBuff, "
        "defenseBuff: $defenseBuff, "
        "specificAttackBuff: $specificAttackBuff, "
        "specificDefenseBuff: $specificDefenseBuff, "
        "criticalDamageBuff: $criticalDamageBuff, "
        "npDamageBuff: $npDamageBuff, "
        "percentAttackBuff: $percentAttackBuff, "
        "percentDefenseBuff, $percentDefenseBuff, "
        "damageAdditionBuff, $damageAdditionBuff, "
        "damageReductionBuff: $damageReductionBuff, "
        "fixedRandom: $fixedRandom";
  }
}
