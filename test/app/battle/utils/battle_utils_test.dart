import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/basic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_init.dart';

void main() async {
  await initiateForTest();

  // test without ui, [silent] must set to silent
  final data = await GameDataLoader.instance.reload(offline: true, silent: true);
  print('Data version: ${data?.version.dateTime.toString()}');

  db.gameData = data!;

  group('calculateDamage', () {
    group('Altria (100100) vs Sky caster', () {
      var defenderClass = SvtClass.caster;
      var defenderAttribute = Attribute.sky;

      var altria = db.gameData.servantsById[100100]!;
      var level = 90;
      var classAdvantage = db.gameData.constData.classRelation[altria.className.id]![defenderClass.id];

      var upgradedNp = altria.noblePhantasms.last;
      var oc1Np1DataSpec = upgradedNp.functions.first.svals.first;
      var oc1Np1NpSpecificAtkRate = oc1Np1DataSpec.Correction ?? 1000;

      var baseParam = DamageParameters()
        ..attack = altria.atkGrowth[level - 1]
        ..attackerClass = altria.className
        ..defenderClass = defenderClass
        ..classAdvantage = classAdvantage!
        ..attackerAttribute = altria.attribute
        ..defenderAttribute = defenderAttribute
        ..fixedRandom = 0.9;

      var oc1Np1BaseParam = baseParam.copy()
        ..damageRate = oc1Np1DataSpec.Value!
        ..totalHits = Maths.sum(upgradedNp.npDistribution)
        ..npSpecificAttackRate = oc1Np1NpSpecificAtkRate
        ..isNp = true
        ..currentCardType = upgradedNp.card
        ..firstCardType = upgradedNp.card;

      var baseDamage = 12542;
      test('NP 1 OC 1 no fou as base', () {
        expect(calculateDamage(oc1Np1BaseParam), equals(baseDamage));
      });

      test('chainPos does not affect NP', () {
        var damageParameters = oc1Np1BaseParam.copy()..chainPos = 5;

        expect(calculateDamage(damageParameters), equals(baseDamage));
      });

      test('NP does not benefit from firstCardBonus', () {
        var damageParameters = oc1Np1BaseParam.copy()..firstCardType = CardType.buster;

        expect(calculateDamage(damageParameters), equals(baseDamage));
      });

      test('NP does not benefit from busterChainMod', () {
        expect(upgradedNp.card, equals(CardType.buster));

        var damageParameters = oc1Np1BaseParam.copy()
          ..firstCardType = CardType.buster
          ..isTypeChain = true;

        expect(calculateDamage(damageParameters), equals(baseDamage));
      });

      test('servant attack change', () {
        var damageParameters = oc1Np1BaseParam.copy()
          ..attack = altria.atkGrowth[120 - 1] + 2000 + 1000; // 2000 Atk CE & 1000 Atk Fou

        expect(calculateDamage(damageParameters), equals(19469));
      });

      test('damageRate change NP 5 OC 1 no fou', () {
        var oc1Np5DataSpec = upgradedNp.functions.first.svals.last;
        var oc1Np5NpSpecificAtkRate = oc1Np5DataSpec.Correction ?? 1000;

        var damageParameters = oc1Np1BaseParam.copy()
          ..damageRate = oc1Np5DataSpec.Value!
          ..npSpecificAttackRate = oc1Np5NpSpecificAtkRate;

        expect(calculateDamage(damageParameters), equals(18814));
      });

      test('cardBuff & cardResist', () {
        var damageParameters = oc1Np1BaseParam.copy()..cardBuff = 500; // 50% buster up

        var damage = calculateDamage(damageParameters);
        expect(damage, equals(18814));

        damageParameters
          ..cardBuff = 1137
          ..cardResist = 637;
        expect(calculateDamage(damageParameters), equals(damage));
      });

      test('fixed random change', () {
        var damageParameters = oc1Np1BaseParam.copy()..fixedRandom = 1.1;

        expect(calculateDamage(damageParameters), equals(15330));
      });

      test('attackBuff & defenseBuff', () {
        var damageParameters = oc1Np1BaseParam.copy()..attackBuff = 180; // 18% attack up

        var damage = calculateDamage(damageParameters);
        expect(damage, equals(14800));

        damageParameters
          ..attackBuff = 540
          ..defenseBuff = 360;
        expect(calculateDamage(damageParameters), equals(damage));
      });

      test('percentDefenseBuff', () {
        var damageParameters = oc1Np1BaseParam.copy()..percentDefenseBuff = 400;

        expect(calculateDamage(damageParameters), equals(7525));

        damageParameters.percentDefenseBuff = 2000;
        expect(calculateDamage(damageParameters), equals(0));
      });

      test('specificAttackBuff & specificDefenseBuff & npDamageBuff', () {
        var damageParameters = oc1Np1BaseParam.copy()..specificAttackBuff = 400;

        var damage = calculateDamage(damageParameters);
        expect(damage, equals(17559));

        damageParameters
          ..specificAttackBuff = 200
          ..npDamageBuff = 200;
        expect(calculateDamage(damageParameters), equals(damage));

        damageParameters
          ..specificAttackBuff = 375
          ..specificDefenseBuff = 300
          ..npDamageBuff = 325;
        expect(calculateDamage(damageParameters), equals(damage));
      });

      test('percentAttackBuff', () {
        var damageParameters = oc1Np1BaseParam.copy()..percentAttackBuff = 400;

        expect(calculateDamage(damageParameters), equals(17559));
      });

      test('damageAdditionBuff & damageReductionBuff', () {
        var damageParameters = oc1Np1BaseParam.copy()..damageAdditionBuff = 400;

        var damage = calculateDamage(damageParameters);
        expect(damage, equals(baseDamage + 400));

        damageParameters
          ..damageAdditionBuff = 675
          ..damageReductionBuff = 275;
        expect(calculateDamage(damageParameters), equals(damage));

        damageParameters.damageReductionBuff = 99999999;
        expect(calculateDamage(damageParameters), equals(0));
      });

      test('with 1000 Fou & double Koyanskaya of Light', () {
        var damageParameters = oc1Np1BaseParam.copy()
          ..attack = baseParam.attack + 1000
          ..attackBuff = 180
          ..cardBuff = 500 + 500 + 500
          ..npDamageBuff = 300;
        expect(calculateDamage(damageParameters), equals(52388));
      });

      var quickCard = altria.cardDetails[CardType.quick]!;
      var artsCard = altria.cardDetails[CardType.arts]!;
      var busterCard = altria.cardDetails[CardType.buster]!;
      var extraCard = altria.cardDetails[CardType.extra]!;

      test('firstCardBonus', () {
        var damageParameters = baseParam.copy()
          ..totalHits = Maths.sum(artsCard.hitsDistribution)
          ..chainPos = 2
          ..currentCardType = CardType.arts
          ..firstCardType = CardType.arts;

        var damageWithoutBonus = calculateDamage(damageParameters);
        expect(damageWithoutBonus, equals(2508));

        damageParameters.firstCardType = CardType.quick;

        expect(calculateDamage(damageParameters), equals(damageWithoutBonus));

        damageParameters.firstCardType = CardType.buster;

        var damageWithBonus = calculateDamage(damageParameters);
        expect(damageWithBonus, equals(3553));

        damageParameters
          ..firstCardType = CardType.quick
          ..isMightyChain = true;

        expect(calculateDamage(damageParameters), equals(damageWithBonus));
      });

      test('cardCorrection', () {
        var damageParameters = baseParam.copy()
          ..totalHits = Maths.sum(quickCard.hitsDistribution)
          ..cardBuff = 80 // passive
          ..chainPos = 1
          ..currentCardType = CardType.quick
          ..firstCardType = CardType.quick;

        expect(calculateDamage(damageParameters), equals(1806));

        damageParameters.chainPos = 2;

        expect(calculateDamage(damageParameters), equals(2167));

        damageParameters.chainPos = 3;

        expect(calculateDamage(damageParameters), equals(2528));
      });

      test('criticalDamageBuff', () {
        var damageParameters = baseParam.copy()
          ..totalHits = Maths.sum(busterCard.hitsDistribution)
          ..chainPos = 2
          ..isCritical = true
          ..currentCardType = CardType.buster
          ..firstCardType = CardType.arts;

        expect(calculateDamage(damageParameters), equals(7525));

        damageParameters.criticalDamageBuff = 800;

        var damage = calculateDamage(damageParameters);
        expect(damage, equals(13546));

        damageParameters.criticalDamageBuff = 500;
        damageParameters.specificAttackBuff = 300;

        expect(calculateDamage(damageParameters), equals(damage));
      });

      test('buster chain', () {
        var damageParameters = baseParam.copy()
          ..totalHits = Maths.sum(busterCard.hitsDistribution)
          ..chainPos = 1
          ..currentCardType = CardType.buster
          ..firstCardType = CardType.buster;

        expect(calculateDamage(damageParameters), equals(4180));

        damageParameters.isTypeChain = true;

        expect(calculateDamage(damageParameters), equals(6425));

        damageParameters.chainPos = 3;

        expect(calculateDamage(damageParameters), equals(7679));
      });

      test('extraModifier', () {
        var damageParameters = baseParam.copy()
          ..totalHits = Maths.sum(extraCard.hitsDistribution)
          ..chainPos = 4
          ..currentCardType = CardType.extra
          ..firstCardType = CardType.buster;

        expect(calculateDamage(damageParameters), equals(6271));

        damageParameters.isTypeChain = true;

        expect(calculateDamage(damageParameters), equals(10974));
      });
    });

    group('Altria (Alter) (Lancer) (301900)', () {
      var altria = db.gameData.servantsById[301900]!;
      var level = 80;
      var busterCard = altria.cardDetails[CardType.buster]!;

      var baseParam = DamageParameters()
        ..attack = altria.atkGrowth[level - 1] + 1000
        ..attackerClass = altria.className
        ..attackerAttribute = altria.attribute
        ..totalHits = Maths.sum(busterCard.hitsDistribution)
        ..chainPos = 1
        ..currentCardType = CardType.buster
        ..firstCardType = CardType.buster
        ..fixedRandom = 0.9;

      test('vs Sky Lancer', () {
        var defenderClass = SvtClass.lancer;
        var defenderAttribute = Attribute.sky;
        var classAdvantage = db.gameData.constData.classRelation[altria.className.id]![defenderClass.id]!;

        var damageParameters = baseParam.copy()
          ..defenderClass = defenderClass
          ..classAdvantage = classAdvantage
          ..defenderAttribute = defenderAttribute;

        expect(calculateDamage(damageParameters), equals(4767));
      });

      test('vs Earth Ruler', () {
        var defenderClass = SvtClass.ruler;
        var defenderAttribute = Attribute.earth;
        var classAdvantage = db.gameData.constData.classRelation[altria.className.id]![defenderClass.id]!;

        var damageParameters = baseParam.copy()
          ..defenderClass = defenderClass
          ..classAdvantage = classAdvantage
          ..defenderAttribute = defenderAttribute;

        expect(calculateDamage(damageParameters), equals(2622));
      });

      test('vs Human Archer', () {
        var defenderClass = SvtClass.archer;
        var defenderAttribute = Attribute.human;
        var classAdvantage = db.gameData.constData.classRelation[altria.className.id]![defenderClass.id]!;

        var damageParameters = baseParam.copy()
          ..defenderClass = defenderClass
          ..classAdvantage = classAdvantage
          ..defenderAttribute = defenderAttribute;

        expect(calculateDamage(damageParameters), equals(8582));
      });

      var extra = altria.cardDetails[CardType.extra]!;
      test('totalHits', () {
        var defenderClass = SvtClass.lancer;
        var defenderAttribute = Attribute.sky;
        var classAdvantage = db.gameData.constData.classRelation[altria.className.id]![defenderClass.id]!;

        var damageParameters = baseParam.copy()
          ..totalHits = Maths.sum(extra.hitsDistribution)
          ..chainPos = 4
          ..currentCardType = CardType.extra
          ..firstCardType = CardType.buster
          ..defenderClass = defenderClass
          ..classAdvantage = classAdvantage
          ..defenderAttribute = defenderAttribute;

        expect(calculateDamage(damageParameters), equals(7151));
      });
    });

    group('Yang Guifei (2500400)', () {
      var defenderClass = SvtClass.caster;
      var defenderAttribute = Attribute.sky;

      var yuyu = db.gameData.servantsById[2500400]!;
      var level = 90;
      var classAdvantage = db.gameData.constData.classRelation[yuyu.className.id]![defenderClass.id];

      var np = yuyu.noblePhantasms.last;
      var npDamageSpecs = np.functions.first;

      var baseParam = DamageParameters()
        ..attack = yuyu.atkGrowth[level - 1] + 1000
        ..attackerClass = yuyu.className
        ..defenderClass = defenderClass
        ..classAdvantage = classAdvantage!
        ..attackerAttribute = yuyu.attribute
        ..defenderAttribute = defenderAttribute
        ..totalHits = Maths.sum(np.npDistribution)
        ..isNp = true
        ..currentCardType = np.card
        ..firstCardType = np.card
        ..damageAdditionBuff = 175 // passive
        ..fixedRandom = 0.9;

      test('NP 5 OC 1 with no npSpecificDamage', () {
        var oc1Np5DataSpec = npDamageSpecs.svals.last;

        var damageParameters = baseParam.copy()
          ..damageRate = oc1Np5DataSpec.Value!
          ..npSpecificAttackRate = 1000;
        expect(calculateDamage(damageParameters), equals(45744));
      });

      test('NP 5 OC 3 with no npSpecificDamage', () {
        var oc3Np5DataSpec = npDamageSpecs.svals3!.last;

        var damageParameters = baseParam.copy()
          ..damageRate = oc3Np5DataSpec.Value!
          ..npSpecificAttackRate = 1000;
        expect(calculateDamage(damageParameters), equals(45744));
      });

      test('NP 5 OC 1 with npSpecificDamage', () {
        var oc1Np5DataSpec = npDamageSpecs.svals.last;

        var damageParameters = baseParam.copy()
          ..damageRate = oc1Np5DataSpec.Value!
          ..npSpecificAttackRate = oc1Np5DataSpec.Correction!;
        expect(calculateDamage(damageParameters), equals(68529));
      });

      test('NP 5 OC 3 with npSpecificDamage', () {
        var oc3Np5DataSpec = npDamageSpecs.svals3!.last;

        var damageParameters = baseParam.copy()
          ..damageRate = oc3Np5DataSpec.Value!
          ..npSpecificAttackRate = oc3Np5DataSpec.Correction!;
        expect(calculateDamage(damageParameters), equals(79921));
      });

      test('NP 5 OC 4 with npSpecificDamage', () {
        var oc4Np5DataSpec = npDamageSpecs.svals4!.last;

        var damageParameters = baseParam.copy()
          ..damageRate = oc4Np5DataSpec.Value!
          ..npSpecificAttackRate = oc4Np5DataSpec.Correction!;
        expect(calculateDamage(damageParameters), equals(85618));
      });

      test('NP 5 OC 5 with npSpecificDamage', () {
        var oc5Np5DataSpec = npDamageSpecs.svals5!.last;

        var damageParameters = baseParam.copy()
          ..damageRate = oc5Np5DataSpec.Value!
          ..npSpecificAttackRate = oc5Np5DataSpec.Correction!;
        expect(calculateDamage(damageParameters), equals(91314));
      });
    });
  });

  group('calculateAttackNpGain', () {
    test('float32 test in Atlas', () {
      var param = AttackNpGainParameters()
        ..firstCardType = CardType.quick
        ..isMightyChain = true
        ..currentCardType = CardType.arts
        ..chainPos = 3
        ..attackerNpCharge = 25
        ..defenderNpRate = 1000
        ..cardBuff = 1600
        ..cardResist = 800
        ..npGainBuff = 300
        ..isCritical = true;

      expect(calculateAttackNpGain(param), equals(766));
    });

    group('Yang Guifei (2500400) vs Caster', () {
      var defenderNpRate = 1200;

      var yuyu = db.gameData.servantsById[2500400]!;
      var np = yuyu.noblePhantasms.last;

      var baseParam = AttackNpGainParameters()..defenderNpRate = defenderNpRate;

      var npBaseParam = baseParam.copy()
        ..isNp = true
        ..attackerNpCharge = np.npGain.np.last
        ..currentCardType = np.card
        ..firstCardType = np.card;

      var baseHitNpGain = 183;
      test('NP 5 as base', () {
        expect(calculateAttackNpGain(npBaseParam), equals(baseHitNpGain));
      });

      test('chainPos does not affect NP', () {
        var param = npBaseParam.copy()..chainPos = 5;

        expect(calculateAttackNpGain(param), equals(baseHitNpGain));
      });

      test('NP does not benefit from firstCardBonus', () {
        var param = npBaseParam.copy()..firstCardType = CardType.quick;

        expect(calculateAttackNpGain(param), equals(baseHitNpGain));
      });

      test('cardBuff & cardResist', () {
        var param = npBaseParam.copy()..cardBuff = 500;

        var hitNpGain = calculateAttackNpGain(param);
        expect(hitNpGain, equals(275));

        param
          ..cardBuff = 800
          ..cardResist = 300;
        expect(calculateAttackNpGain(param), equals(hitNpGain));
      });

      test('npGainBuff', () {
        var param = npBaseParam.copy()..npGainBuff = 300;

        expect(calculateAttackNpGain(param), equals(238));
      });

      test('overkill', () {
        var param = npBaseParam.copy()..isOverkill = true;

        expect(calculateAttackNpGain(param), equals(274));
      });

      test('with double Altria Caster & overkill', () {
        var param = npBaseParam.copy()
          ..cardBuff = 1000
          ..npGainBuff = 600
          ..isOverkill = true;
        expect(calculateAttackNpGain(param), equals(880));
      });

      test('firstCardBonus', () {
        var params = baseParam.copy()
          ..attackerNpCharge = np.npGain.arts.last
          ..chainPos = 2
          ..currentCardType = CardType.arts
          ..firstCardType = CardType.quick;

        var hitNpGainWithoutBonus = calculateAttackNpGain(params);
        expect(hitNpGainWithoutBonus, equals(275));

        params.firstCardType = CardType.buster;

        expect(calculateAttackNpGain(params), equals(hitNpGainWithoutBonus));

        params.firstCardType = CardType.arts;

        var hitNpGainWithBonus = calculateAttackNpGain(params);
        expect(hitNpGainWithBonus, equals(336));

        params
          ..firstCardType = CardType.quick
          ..isMightyChain = true;

        expect(calculateAttackNpGain(params), equals(hitNpGainWithBonus));
      });

      test('cardCorrection', () {
        var params = baseParam.copy()
          ..attackerNpCharge = np.npGain.quick.last
          ..chainPos = 1
          ..currentCardType = CardType.quick
          ..firstCardType = CardType.quick;

        expect(calculateAttackNpGain(params), equals(61));

        params.chainPos = 2;

        expect(calculateAttackNpGain(params), equals(91));

        params.chainPos = 3;

        expect(calculateAttackNpGain(params), equals(122));

        params
          ..attackerNpCharge = np.npGain.buster.last
          ..chainPos = 2
          ..currentCardType = CardType.buster
          ..firstCardType = CardType.quick;

        expect(calculateAttackNpGain(params), equals(0));

        params.firstCardType = CardType.arts;

        expect(calculateAttackNpGain(params), equals(61));
      });

      test('criticalModifier', () {
        var params = baseParam.copy()
          ..attackerNpCharge = np.npGain.arts.last
          ..chainPos = 2
          ..isCritical = true
          ..currentCardType = CardType.arts
          ..firstCardType = CardType.arts;

        expect(calculateAttackNpGain(params), equals(673));
      });
    });

    test('Gilgamesh (Caster) (501800) vs Berserker', () {
      var defenderNpRate = 800;

      var gilgamesh = db.gameData.servantsById[501800]!;
      var np = gilgamesh.noblePhantasms.last;

      var param = AttackNpGainParameters()
        ..defenderNpRate = defenderNpRate
        ..isNp = true
        ..attackerNpCharge = np.npGain.np.last
        ..currentCardType = np.card
        ..firstCardType = np.card
        ..cardBuff = 100; // passive

      expect(calculateAttackNpGain(param), equals(42));
    });

    test('Minamoto-no-Raikou (Berserker) (702300) vs Lancer', () {
      var defenderNpRate = 1000;

      var raikou = db.gameData.servantsById[702300]!;
      var np = raikou.noblePhantasms.last;

      var param = AttackNpGainParameters()
        ..defenderNpRate = defenderNpRate
        ..attackerNpCharge = np.npGain.arts.last
        ..currentCardType = CardType.arts
        ..firstCardType = np.card
        ..isCritical = true
        ..npGainBuff = 450
        ..isOverkill = true;

      param.chainPos = 2;
      expect(calculateAttackNpGain(param), equals(900));

      param.chainPos = 3;
      expect(calculateAttackNpGain(param), equals(1200));

      param
        ..chainPos = 4
        ..currentCardType = CardType.extra
        ..isCritical = false;
      expect(calculateAttackNpGain(param), equals(99));
    });

    test('Abigail Williams (2500100) vs Beast III/R', () {
      var defenderNpRate = 1000;

      var abby = db.gameData.servantsById[2500100]!;
      var np = abby.noblePhantasms.last;

      var param = AttackNpGainParameters()
        ..defenderNpRate = defenderNpRate
        ..attackerNpCharge = np.npGain.arts.last
        ..currentCardType = CardType.arts
        ..firstCardType = CardType.arts
        ..isCritical = true
        ..cardBuff = 800
        ..npGainBuff = 300
        ..chainPos = 3
        ..isOverkill = true;

      expect(calculateAttackNpGain(param), equals(1149));
    });

    test('Vlad III (Berserker) (700700) vs Beast III/R', () {
      var defenderNpRate = 1000;

      var vlad = db.gameData.servantsById[700700]!;
      var np = vlad.noblePhantasms.last;

      var param = AttackNpGainParameters()
        ..defenderNpRate = defenderNpRate
        ..attackerNpCharge = np.npGain.arts.last
        ..currentCardType = CardType.arts
        ..firstCardType = CardType.arts
        ..isCritical = true
        ..cardBuff = 800
        ..npGainBuff = 300
        ..chainPos = 3
        ..isOverkill = true;

      expect(calculateAttackNpGain(param), equals(2299));
    });
  });

  group('calculateDefendNpGain', () {
    group('Yang Guifei (2500400) vs Caster', () {
      var attackerNpRate = 1200;

      var yuyu = db.gameData.servantsById[2500400]!;
      var np = yuyu.noblePhantasms.last;

      var baseParam = DefendNpGainParameters()
        ..defenderNpCharge = np.npGain.defence.last
        ..attackerNpRate = attackerNpRate;

      var baseHitNpGain = 360;
      test('NP 5 as base', () {
        expect(calculateDefendNpGain(baseParam), equals(baseHitNpGain));
      });

      test('npGainBuff', () {
        var param = baseParam.copy()..npGainBuff = 300;

        expect(calculateDefendNpGain(param), equals(467));
      });

      test('defNpGainBuff', () {
        var param = baseParam.copy()..defenseNpGainBuff = 200;

        expect(calculateDefendNpGain(param), equals(432));
      });

      test('overkill', () {
        var param = baseParam.copy()..isOverkill = true;

        expect(calculateDefendNpGain(param), equals(540));
      });
    });

    test('Gilgamesh (Caster) (501800) vs Berserker', () {
      var attackerNpRate = 800;

      var gilgamesh = db.gameData.servantsById[501800]!;
      var np = gilgamesh.noblePhantasms.last;

      var baseParam = DefendNpGainParameters()
        ..defenderNpCharge = np.npGain.defence.last
        ..attackerNpRate = attackerNpRate;

      expect(calculateDefendNpGain(baseParam), equals(240));
    });

    test('Ashiya Douman (1001000) vs Caster', () {
      var attackerNpRate = 1200;

      var douman = db.gameData.servantsById[1001000]!;
      var np = douman.noblePhantasms.last;

      var baseParam = DefendNpGainParameters()
        ..defenderNpCharge = np.npGain.defence.last
        ..attackerNpRate = attackerNpRate
        ..defenseNpGainBuff = 200;

      expect(calculateDefendNpGain(baseParam), equals(576));

      baseParam.npGainBuff = 300;

      expect(calculateDefendNpGain(baseParam), equals(748));
    });
  });

  group('calculateStar', () {
    group('Izumo no Okuni (504900) vs Rider', () {
      var defenderStarRate = 100;

      var okumi = db.gameData.servantsById[504900]!;
      var np = okumi.noblePhantasms.last;

      var baseParam = StarParameters()
        ..attackerStarGen = okumi.starGen
        ..defenderStarRate = defenderStarRate;

      var npBaseParam = baseParam.copy()
        ..isNp = true
        ..currentCardType = np.card
        ..firstCardType = np.card
        ..cardResist = -200; // np first function

      var baseHitStarGen = 1169;
      test('NP 5 as base', () {
        expect(calculateStar(npBaseParam), equals(baseHitStarGen));
      });

      test('chainPos does not affect NP', () {
        var param = npBaseParam.copy()..chainPos = 5;

        expect(calculateStar(param), equals(baseHitStarGen));
      });

      test('NP does not benefit from firstCardBonus', () {
        var param = npBaseParam.copy()..firstCardType = CardType.arts;

        expect(calculateStar(param), equals(baseHitStarGen));
      });

      test('cardBuff & cardResist', () {
        var param = npBaseParam.copy()..cardBuff = 500;

        var starGen = calculateStar(param);
        expect(starGen, equals(1569));

        param
          ..cardBuff = 800
          ..cardResist = 300 - 200;
        expect(calculateStar(param), equals(starGen));
      });

      test('starGenBuff & enemyStarGenResist', () {
        var param = npBaseParam.copy()..starGenBuff = 300;

        var starGen = calculateStar(param);
        expect(starGen, equals(1469));

        param
          ..starGenBuff = 800
          ..enemyStarGenResist = 500;
        expect(calculateStar(param), equals(starGen));
      });

      test('overkill', () {
        var param = npBaseParam.copy()..isOverkill = true;

        expect(calculateStar(param), equals(1469));
      });

      test('with double Scathach-Skadi (Rider) & overkill', () {
        var param = npBaseParam.copy()
          ..cardBuff = 1000
          ..isOverkill = true;
        expect(calculateStar(param), equals(2269));
      });

      test('firstCardBonus', () {
        var params = baseParam.copy()
          ..chainPos = 2
          ..currentCardType = CardType.buster
          ..firstCardType = CardType.buster;

        var hitStarGenWithoutBonus = calculateStar(params);
        expect(hitStarGenWithoutBonus, equals(359));

        params.firstCardType = CardType.arts;

        expect(calculateStar(params), equals(hitStarGenWithoutBonus));

        params.firstCardType = CardType.quick;

        var hitStarGenWithBonus = calculateStar(params);
        expect(hitStarGenWithBonus, equals(559));

        params
          ..firstCardType = CardType.arts
          ..isMightyChain = true;

        expect(calculateStar(params), equals(hitStarGenWithBonus));
      });

      test('cardCorrection', () {
        var params = baseParam.copy()
          ..chainPos = 1
          ..currentCardType = CardType.buster
          ..firstCardType = CardType.buster;

        expect(calculateStar(params), equals(309));

        params.chainPos = 2;

        expect(calculateStar(params), equals(359));

        params.chainPos = 3;

        expect(calculateStar(params), equals(409));

        params
          ..chainPos = 2
          ..currentCardType = CardType.arts
          ..firstCardType = CardType.buster;

        expect(calculateStar(params), equals(209));

        params.firstCardType = CardType.quick;

        expect(calculateStar(params), equals(409));
      });

      test('criticalModifier', () {
        var params = baseParam.copy()
          ..chainPos = 2
          ..isCritical = true
          ..currentCardType = CardType.quick
          ..firstCardType = CardType.quick;

        expect(calculateStar(params), equals(1909));
      });
    });

    test('Kama (Caster) (603700) vs Avenger', () {
      var defenderStarRate = -100;

      var kama = db.gameData.servantsById[603700]!;
      var np = kama.noblePhantasms.last;

      var param = StarParameters()
        ..attackerStarGen = kama.starGen
        ..defenderStarRate = defenderStarRate
        ..isNp = true
        ..currentCardType = np.card
        ..firstCardType = np.card
        ..cardBuff = 300; // passive + np first function

      expect(calculateStar(param), equals(1190));
    });
  });
}
