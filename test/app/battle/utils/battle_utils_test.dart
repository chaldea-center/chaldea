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

  group('calculateDamage()', () {
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
          ..firstCardType = CardType.arts;

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
}
