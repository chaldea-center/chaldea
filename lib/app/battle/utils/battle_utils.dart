import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/utils/battle_exception.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/packages/float.dart';
import 'package:chaldea/utils/extension.dart';
import '../../../utils/basic.dart';
import 'battle_logger.dart';

const kBattleFuncMiss = 'MISS';
const kBattleFuncNoEffect = 'NO EFFECT';
const kBattleFuncGUARD = 'GUARD';

double toModifier(final int value) {
  return 0.001 * value;
}

Float toModifierFloat(int value) {
  return toModifier(value).toFloat();
}

/// Referencing:
/// https://apps.atlasacademy.io/fgo-docs/deeper/battle/damage.html
/// DamageMod caps are applied when gathering the parameters.
int calculateDamage(final DamageParameters param) {
  if (!ConstData.classInfo.containsKey(param.attackerClass)) {
    throw BattleException('Invalid class: ${param.attackerClass}');
  }

  final Float classAttackCorrection = toModifierFloat(ConstData.classInfo[param.attackerClass]?.attackRate ?? 1000);
  final Float classAdvantage =
      toModifierFloat(param.classAdvantage); // class relation is provisioned due to overwriteClassRelation

  final Float attributeAdvantage =
      toModifierFloat(ConstData.getAttributeRelation(param.attackerAttribute, param.defenderAttribute));

  if (!ConstData.cardInfo.containsKey(param.currentCardType)) {
    throw BattleException('Invalid current card type: ${param.currentCardType}');
  }

  final int chainPos = param.isNp ? 1 : param.chainPos;
  final Float cardCorrection = toModifierFloat(ConstData.cardInfo[param.currentCardType]![chainPos]!.adjustAtk);

  final Float firstCardBonus = shouldIgnoreFirstCardBonus(param.isNp, param.firstCardType)
      ? 0.toFloat()
      : param.isMightyChain
          ? toModifierFloat(ConstData.cardInfo[CardType.buster]![1]!.addAtk)
          : toModifierFloat(ConstData.cardInfo[param.firstCardType]![1]!.addAtk);

  final Float criticalModifier = param.critical ? toModifierFloat(ConstData.constants.criticalAttackRate) : 1.toFloat();

  final int extraRate = param.currentCardType == CardType.extra
      ? param.isTypeChain
          ? ConstData.constants.extraAttackRateGrand
          : ConstData.constants.extraAttackRateSingle
      : 1000;
  final extraModifier = toModifierFloat(extraRate);

  final Float busterChainMod = !param.isNp && param.currentCardType == CardType.buster && param.isTypeChain
      ? toModifierFloat(ConstData.constants.chainbonusBusterRate) * param.attack.toFloat()
      : 0.toFloat();

  final Float damageRate = toModifierFloat(param.damageRate);
  final Float npSpecificAttackRate = toModifierFloat(param.npSpecificAttackRate);
  final Float cardBuff = toModifierFloat(param.cardBuff);
  final Float cardResist = toModifierFloat(param.cardResist);
  final Float attackBuff = toModifierFloat(param.attackBuff);
  final Float defenseBuff = toModifierFloat(param.defenseBuff);
  final Float specificAttackBuff = toModifierFloat(param.specificAttackBuff);
  final Float specificDefenseBuff = toModifierFloat(param.specificDefenseBuff);
  final Float criticalDamageBuff = param.critical ? toModifierFloat(param.criticalDamageBuff) : 0.toFloat();
  final Float npDamageBuff = param.isNp ? toModifierFloat(param.npDamageBuff) : 0.toFloat();
  final Float percentAttackBuff = toModifierFloat(param.percentAttackBuff);
  final Float percentDefenseBuff = toModifierFloat(param.percentDefenseBuff);

  final Float random = toModifierFloat(param.random);
  final Float attackRate = toModifierFloat(ConstData.constants.attackRate);
  final Float hits = (param.totalHits / 100.0).toFloat();

  final totalDamage = param.attack.toFloat() *
          damageRate *
          (firstCardBonus + cardCorrection * (1.toFloat() + cardBuff - cardResist).ofMax(0)) *
          classAttackCorrection *
          classAdvantage *
          attributeAdvantage *
          random *
          attackRate *
          (1.toFloat() + attackBuff - defenseBuff).ofMax(0) *
          criticalModifier *
          extraModifier *
          (1.toFloat() - percentDefenseBuff).ofMax(0) *
          (1.toFloat() + specificAttackBuff - specificDefenseBuff + criticalDamageBuff + npDamageBuff).ofMax(0.001) *
          (1.toFloat() + percentAttackBuff).ofMax(0.001) *
          npSpecificAttackRate *
          hits +
      param.damageAdditionBuff.toFloat() +
      param.damageReceiveAdditionBuff.toFloat() +
      busterChainMod;

  return totalDamage.ofMax(0).floor();
}

int calculateDamageNoError(final DamageParameters param) {
  try {
    return calculateDamage(param);
  } catch (e, s) {
    print('calculateDamage failed: $e');
    print(s);
    return 0;
  }
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
  final cardCorrection = toModifierFloat(ConstData.cardInfo[param.currentCardType]![chainPos]!.adjustTdGauge);

  final firstCardBonus = shouldIgnoreFirstCardBonus(param.isNp, param.firstCardType)
      ? 0.toFloat()
      : param.isMightyChain
          ? toModifierFloat(ConstData.cardInfo[CardType.arts]![1]!.addTdGauge)
          : toModifierFloat(ConstData.cardInfo[param.firstCardType]![1]!.addTdGauge);
  final criticalModifier = param.critical ? toModifierFloat(ConstData.constants.criticalTdPointRate) : 1.toFloat();
  final cardBuff = toModifierFloat(param.cardBuff);
  final cardResist = toModifierFloat(param.cardResist);
  final npGainBuff = toModifierFloat(param.npGainBuff);
  final defenderNpRate = toModifierFloat(param.defenderNpRate);
  final cardAttackNpRate = toModifierFloat(param.cardAttackNpRate);
  final overkillModifier = param.isOverkill ? toModifierFloat(ConstData.constants.overKillNpRate) : 1.toFloat();

  final beforeOverkill = param.attackerNpCharge.toFloat() *
      criticalModifier *
      defenderNpRate *
      (firstCardBonus + cardCorrection * (1.toFloat() + cardBuff - cardResist).ofMax(0)) *
      npGainBuff *
      cardAttackNpRate;
  return (beforeOverkill.floor().toFloat() * overkillModifier).floor();
}

/// Referencing:
/// https://atlasacademy.github.io/fgo-docs/deeper/battle/np.html
/// Float arithmetic used due to:
/// https://atlasacademy.github.io/fgo-docs/deeper/battle/32-bit-float.html
int calculateDefendNpGain(final DefendNpGainParameters param) {
  final Float attackerNpRate = toModifierFloat(param.attackerNpRate);
  final Float npGainBuff = toModifierFloat(param.npGainBuff);
  final Float defenseNpGainBuff = toModifierFloat(param.defenseNpGainBuff);
  final Float cardDefenseNpRate = toModifierFloat(param.cardDefNpRate);
  final Float beforeOverkill =
      param.defenderNpGainRate.toFloat() * attackerNpRate * npGainBuff * defenseNpGainBuff * cardDefenseNpRate;
  final Float overkillModifier = param.isOverkill ? toModifierFloat(ConstData.constants.overKillNpRate) : 1.toFloat();
  return (beforeOverkill.floor().toFloat() * overkillModifier).floor();
}

/// Referencing:
/// https://atlasacademy.github.io/fgo-docs/deeper/battle/critstars.html
int calculateStar(final StarParameters param) {
  if (!ConstData.cardInfo.containsKey(param.currentCardType)) {
    throw 'Invalid current card type: ${param.currentCardType}';
  }

  final int chainPos = param.isNp ? 1 : param.chainPos;
  final int cardCorrection = ConstData.cardInfo[param.currentCardType]![chainPos]!.adjustCritical;

  final int firstCardBonus = shouldIgnoreFirstCardBonus(param.isNp, param.firstCardType)
      ? 0
      : param.isMightyChain
          ? ConstData.cardInfo[CardType.quick]![1]!.addCritical
          : ConstData.cardInfo[param.firstCardType]![1]!.addCritical;
  final int criticalModifier = param.critical ? ConstData.constants.criticalStarRate : 0;

  final int defenderStarRate = param.defenderStarRate;

  final Float cardBuff = toModifierFloat(param.cardBuff);
  final Float cardResist = toModifierFloat(param.cardResist);

  final Float cardDropStarRate = toModifierFloat(param.cardDropStarRate);

  final Float overkillModifier = param.isOverkill ? toModifierFloat(ConstData.constants.overKillStarRate) : 1.toFloat();
  final int overkillAdd = param.isOverkill ? ConstData.constants.overKillStarAdd : 0;

  // not converted to modifier since mostly just additions.
  final Float cardGain = (cardCorrection.toFloat() * (1.toFloat() + cardBuff - cardResist).ofMax(0));
  final Float rawDropRate = param.attackerStarGen.toFloat() +
      firstCardBonus.toFloat() +
      cardGain +
      defenderStarRate.toFloat() +
      param.starGenBuff.toFloat() -
      param.enemyStarGenResist.toFloat() +
      criticalModifier.toFloat();
  final Float dropRate = rawDropRate * cardDropStarRate * overkillModifier + overkillAdd.toFloat();
  return dropRate.toInt().clamp(0, ConstData.constants.starRateMax);
}

bool shouldIgnoreFirstCardBonus(final bool isNP, final CardType firstCardType) {
  return isNP || !ConstData.cardInfo.containsKey(firstCardType) || firstCardType == CardType.blank;
}

class DamageParameters {
  int attack = 0; // servantAtk
  int damageRate = 1000; // npDamageMultiplier
  int totalHits = 100;
  int npSpecificAttackRate = 1000; // superEffectiveModifier = function Correction value
  int attackerClass = 0;
  int defenderClass = 0;
  int classAdvantage = 0;
  Attribute attackerAttribute = Attribute.void_;
  Attribute defenderAttribute = Attribute.void_;
  bool isNp = false;
  int chainPos = 1;
  CardType currentCardType = CardType.none;
  CardType firstCardType = CardType.none;
  bool isTypeChain = false;
  bool isMightyChain = false;
  bool critical = false;
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
  int damageReceiveAdditionBuff = 0; // selfDmgCutAdd = target.receiveDamage
  int random = 0;

  NiceFunction? damageFunction;

  bool get isNotMinRoll => random != ConstData.constants.attackRateRandomMin;

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
        'critical: $critical, '
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
        'damageReceiveAdditionBuff: $damageReceiveAdditionBuff, '
        'random: $random'
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
      ..critical = critical
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
      ..damageReceiveAdditionBuff = damageReceiveAdditionBuff
      ..random = random
      ..damageFunction = damageFunction;
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
  bool critical = false;
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
        'critical: $critical, '
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
      ..critical = critical
      ..cardBuff = cardBuff
      ..cardResist = cardResist
      ..npGainBuff = npGainBuff
      ..isOverkill = isOverkill;
  }
}

class DefendNpGainParameters {
  int defenderNpGainRate = 0; // defenceNpGain
  int attackerNpRate = 0; // enemyTdAttackRate
  int cardDefNpRate = 1000; // Olga
  int npGainBuff = 1000; // npChargeRateMod = defSvt.dropNp
  int defenseNpGainBuff = 1000; // defensiveChargeRateMod = defSvt.dropNpDamage
  bool isOverkill = false;

  @override
  String toString() {
    return 'DefendNpGainParameters: {'
        'defenderNpGainMod: $defenderNpGainRate, '
        'attackerNpRate: $attackerNpRate, '
        'cardDefNpRate: $cardDefNpRate, '
        'npGainBuff: $npGainBuff, '
        'defenseNpGainBuff: $defenseNpGainBuff, '
        'isOverkill: $isOverkill'
        '}';
  }

  DefendNpGainParameters copy() {
    return DefendNpGainParameters()
      ..defenderNpGainRate = defenderNpGainRate
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
  bool critical = false;
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
        'critical: $critical, '
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
      ..critical = critical
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
  List<bool> npMaxLimited = [];
  List<int> defNpGains = [];
  List<bool> defNpMaxLimited = [];
  List<int> stars = [];
  List<bool> overkillStates = [];

  int get totalDamage => Maths.sum(damages);
  int get totalNpGains => Maths.sum(npGains);
  int get totalDefNpGains => Maths.sum(defNpGains);
  int get totalStars => Maths.sum(stars);
  int get overkillCount => overkillStates.where((e) => e).length;

  DamageResult copy() {
    return DamageResult()
      ..stars = stars.toList()
      ..damages = damages.toList()
      ..npGains = npGains.toList()
      ..npMaxLimited = npMaxLimited.toList()
      ..defNpGains = defNpGains.toList()
      ..defNpMaxLimited = defNpMaxLimited.toList()
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
    dependFunction = db.gameData.baseFunctions[dataVals.DependFuncId!] ??
        await showEasyLoading(() => AtlasApi.func(dataVals.DependFuncId!), mask: true);
  }
  if (dependFunction == null) {
    logger.error('DependFunctionId=${dataVals.DependFuncId} not found');
    throw ArgumentError('DependFunctionId=${dataVals.DependFuncId} not found');
  }
  return dependFunction;
}

class BattleUtils {
  const BattleUtils._();

  static int limitCountToDisp(int dispLimitCount) {
    return {0: 0, 1: 2, 2: 2, 3: 3, 4: 4}[dispLimitCount] ?? dispLimitCount;
  }

  static final List<int> costumeOrtinaxIds = [12, 800140, 13, 800150];
  static final List<int> melusineDragonIds = [3, 4, 13, 304850];
  static final List<int> ptolemaiosAsc3Ids = [3, 4, 205020];

  static List<NiceTd> getShownTds(final Servant svt, final int limitCount) {
    // only case where we different groups of noblePhantasms exist are for tdTypeChanges or enemy tds
    final List<NiceTd> shownTds = svt.groupedNoblePhantasms[1]?.toList() ?? <NiceTd>[];

    final hideTds = ConstData.getSvtLimitHides(svt.id, limitCount).expand((e) => e.tds).toList();

    shownTds.removeWhere((niceTd) => hideTds.contains(niceTd.id));
    return shownTds;
  }

  static List<NiceSkill> getShownSkills(final Servant svt, final int limitCount, final int skillNum) {
    final List<NiceSkill> shownSkills = [];
    for (final skill in svt.groupedActiveSkills[skillNum] ?? <NiceSkill>[]) {
      if (shownSkills.every((storeSkill) => storeSkill.id != skill.id)) {
        shownSkills.add(skill);
      }
    }

    final hideActives =
        ConstData.getSvtLimitHides(svt.id, limitCount).expand((e) => e.activeSkills[skillNum] ?? []).toList();
    shownSkills.removeWhere((niceSkill) => hideActives.contains(niceSkill.id));
    return shownSkills;
  }
}
