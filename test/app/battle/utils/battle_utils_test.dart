import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/utils/battle_utils.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import 'package:chaldea/utils/basic.dart';
import '../../../test_init.dart';

void main() async {
  await initiateForTest();

  group('calculateDamage', () {
    group('Altria (100100) vs Sky caster', () {
      const defenderClass = SvtClass.caster;
      const defenderAttribute = Attribute.sky;

      final altria = db.gameData.servantsById[100100]!;
      const level = 90;
      final classAdvantage = ConstData.getClassRelation(altria.className, defenderClass);

      final upgradedNp = altria.noblePhantasms.last;
      final oc1Np1DataSpec = upgradedNp.functions.first.svals.first;
      final oc1Np1NpSpecificAtkRate = oc1Np1DataSpec.Correction ?? 1000;

      final baseParam = DamageParameters()
        ..attack = altria.atkGrowth[level - 1]
        ..attackerClass = altria.classId
        ..defenderClass = defenderClass.id
        ..classAdvantage = classAdvantage
        ..attackerAttribute = altria.attribute
        ..defenderAttribute = defenderAttribute
        ..fixedRandom = 900;

      final oc1Np1BaseParam = baseParam.copy()
        ..damageRate = oc1Np1DataSpec.Value!
        ..totalHits = Maths.sum(upgradedNp.svt.damage)
        ..npSpecificAttackRate = oc1Np1NpSpecificAtkRate
        ..isNp = true
        ..currentCardType = upgradedNp.svt.card
        ..firstCardType = upgradedNp.svt.card;

      const baseDamage = 12542;
      test('NP 1 OC 1 no fou as base', () {
        expect(calculateDamage(oc1Np1BaseParam), equals(baseDamage));
      });

      test('chainPos does not affect NP', () {
        final damageParameters = oc1Np1BaseParam.copy()..chainPos = 5;

        expect(calculateDamage(damageParameters), equals(baseDamage));
      });

      test('NP does not benefit from firstCardBonus', () {
        final damageParameters = oc1Np1BaseParam.copy()..firstCardType = CardType.buster;

        expect(calculateDamage(damageParameters), equals(baseDamage));
      });

      test('NP does not benefit from busterChainMod', () {
        expect(upgradedNp.svt.card, equals(CardType.buster));

        final damageParameters = oc1Np1BaseParam.copy()
          ..firstCardType = CardType.buster
          ..isTypeChain = true;

        expect(calculateDamage(damageParameters), equals(baseDamage));
      });

      test('servant attack change', () {
        final damageParameters = oc1Np1BaseParam.copy()
          ..attack = altria.atkGrowth[120 - 1] + 2000 + 1000; // 2000 Atk CE & 1000 Atk Fou

        expect(calculateDamage(damageParameters), equals(19469));
      });

      test('damageRate change NP 5 OC 1 no fou', () {
        final oc1Np5DataSpec = upgradedNp.functions.first.svals.last;
        final oc1Np5NpSpecificAtkRate = oc1Np5DataSpec.Correction ?? 1000;

        final damageParameters = oc1Np1BaseParam.copy()
          ..damageRate = oc1Np5DataSpec.Value!
          ..npSpecificAttackRate = oc1Np5NpSpecificAtkRate;

        expect(calculateDamage(damageParameters), equals(18814));
      });

      test('cardBuff & cardResist', () {
        final damageParameters = oc1Np1BaseParam.copy()..cardBuff = 1500; // 50% buster up

        final damage = calculateDamage(damageParameters);
        expect(damage, equals(18814));

        damageParameters
          ..cardBuff = 2137
          ..cardResist = 1637;
        expect(calculateDamage(damageParameters), equals(damage));
      });

      test('fixed random change', () {
        final damageParameters = oc1Np1BaseParam.copy()..fixedRandom = 1100;

        expect(calculateDamage(damageParameters), equals(15330));
      });

      test('attackBuff & defenseBuff', () {
        final damageParameters = oc1Np1BaseParam.copy()..attackBuff = 1180; // 18% attack up

        final damage = calculateDamage(damageParameters);
        expect(damage, equals(14800));

        damageParameters
          ..attackBuff = 1540
          ..defenseBuff = 1360;
        expect(calculateDamage(damageParameters), equals(damage));
      });

      test('percentDefenseBuff', () {
        final damageParameters = oc1Np1BaseParam.copy()..percentDefenseBuff = 400;

        expect(calculateDamage(damageParameters), equals(7525));

        damageParameters.percentDefenseBuff = 2000;
        expect(calculateDamage(damageParameters), equals(0));
      });

      test('specificAttackBuff & specificDefenseBuff & npDamageBuff', () {
        final damageParameters = oc1Np1BaseParam.copy()..specificAttackBuff = 400;

        final damage = calculateDamage(damageParameters);
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
        final damageParameters = oc1Np1BaseParam.copy()..percentAttackBuff = 400;

        expect(calculateDamage(damageParameters), equals(17559));
      });

      test('damageAdditionBuff & damageReductionBuff', () {
        final damageParameters = oc1Np1BaseParam.copy()..damageAdditionBuff = 400;

        final damage = calculateDamage(damageParameters);
        expect(damage, equals(baseDamage + 400));

        damageParameters
          ..damageAdditionBuff = 675
          ..damageReceiveAdditionBuff = -275;
        expect(calculateDamage(damageParameters), equals(damage));

        damageParameters.damageReceiveAdditionBuff = -99999999;
        expect(calculateDamage(damageParameters), equals(0));
      });

      test('with 1000 Fou & double Koyanskaya of Light', () {
        final damageParameters = oc1Np1BaseParam.copy()
          ..attack = baseParam.attack + 1000
          ..attackBuff = 1180
          ..cardBuff = 500 + 500 + 500 + 1000
          ..npDamageBuff = 300;
        expect(calculateDamage(damageParameters), equals(52388));
      });

      final quickCard = altria.cardDetails[CardType.quick]!;
      final artsCard = altria.cardDetails[CardType.arts]!;
      final busterCard = altria.cardDetails[CardType.buster]!;
      final extraCard = altria.cardDetails[CardType.extra]!;

      test('firstCardBonus', () {
        final damageParameters = baseParam.copy()
          ..totalHits = Maths.sum(artsCard.hitsDistribution)
          ..chainPos = 2
          ..currentCardType = CardType.arts
          ..firstCardType = CardType.arts;

        final damageWithoutBonus = calculateDamage(damageParameters);
        expect(damageWithoutBonus, equals(2508));

        damageParameters.firstCardType = CardType.quick;

        expect(calculateDamage(damageParameters), equals(damageWithoutBonus));

        damageParameters.firstCardType = CardType.buster;

        final damageWithBonus = calculateDamage(damageParameters);
        expect(damageWithBonus, equals(3553));

        damageParameters
          ..firstCardType = CardType.quick
          ..isMightyChain = true;

        expect(calculateDamage(damageParameters), equals(damageWithBonus));
      });

      test('cardCorrection', () {
        final damageParameters = baseParam.copy()
          ..totalHits = Maths.sum(quickCard.hitsDistribution)
          ..cardBuff = 1080 // passive
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
        final damageParameters = baseParam.copy()
          ..totalHits = Maths.sum(busterCard.hitsDistribution)
          ..chainPos = 2
          ..isCritical = true
          ..currentCardType = CardType.buster
          ..firstCardType = CardType.arts;

        expect(calculateDamage(damageParameters), equals(7525));

        damageParameters.criticalDamageBuff = 800;

        final damage = calculateDamage(damageParameters);
        expect(damage, equals(13546));

        damageParameters.criticalDamageBuff = 500;
        damageParameters.specificAttackBuff = 300;

        expect(calculateDamage(damageParameters), equals(damage));
      });

      test('buster chain', () {
        final damageParameters = baseParam.copy()
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
        final damageParameters = baseParam.copy()
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
      final altria = db.gameData.servantsById[301900]!;
      const level = 80;
      final busterCard = altria.cardDetails[CardType.buster]!;

      final baseParam = DamageParameters()
        ..attack = altria.atkGrowth[level - 1] + 1000
        ..attackerClass = altria.classId
        ..attackerAttribute = altria.attribute
        ..totalHits = Maths.sum(busterCard.hitsDistribution)
        ..chainPos = 1
        ..currentCardType = CardType.buster
        ..firstCardType = CardType.buster
        ..fixedRandom = 900;

      test('vs Sky Lancer', () {
        const defenderClass = SvtClass.lancer;
        const defenderAttribute = Attribute.sky;
        final classAdvantage = ConstData.getClassRelation(altria.className, defenderClass);

        final damageParameters = baseParam.copy()
          ..defenderClass = defenderClass.id
          ..classAdvantage = classAdvantage
          ..defenderAttribute = defenderAttribute;

        expect(calculateDamage(damageParameters), equals(4767));
      });

      test('vs Earth Ruler', () {
        const defenderClass = SvtClass.ruler;
        const defenderAttribute = Attribute.earth;
        final classAdvantage = ConstData.getClassRelation(altria.className, defenderClass);

        final damageParameters = baseParam.copy()
          ..defenderClass = defenderClass.id
          ..classAdvantage = classAdvantage
          ..defenderAttribute = defenderAttribute;

        expect(calculateDamage(damageParameters), equals(2622));
      });

      test('vs Human Archer', () {
        const defenderClass = SvtClass.archer;
        const defenderAttribute = Attribute.human;
        final classAdvantage = ConstData.getClassRelation(altria.className, defenderClass);

        final damageParameters = baseParam.copy()
          ..defenderClass = defenderClass.id
          ..classAdvantage = classAdvantage
          ..defenderAttribute = defenderAttribute;

        expect(calculateDamage(damageParameters), equals(8582));
      });

      final extra = altria.cardDetails[CardType.extra]!;
      test('totalHits', () {
        const defenderClass = SvtClass.lancer;
        const defenderAttribute = Attribute.sky;
        final classAdvantage = ConstData.getClassRelation(altria.className, defenderClass);

        final damageParameters = baseParam.copy()
          ..totalHits = Maths.sum(extra.hitsDistribution)
          ..chainPos = 4
          ..currentCardType = CardType.extra
          ..firstCardType = CardType.buster
          ..defenderClass = defenderClass.id
          ..classAdvantage = classAdvantage
          ..defenderAttribute = defenderAttribute;

        expect(calculateDamage(damageParameters), equals(7151));
      });
    });

    group('Yang Guifei (2500400)', () {
      const defenderClass = SvtClass.caster;
      const defenderAttribute = Attribute.sky;

      final yuyu = db.gameData.servantsById[2500400]!;
      const level = 90;
      final classAdvantage = ConstData.getClassRelation(yuyu.className, defenderClass);

      final np = yuyu.noblePhantasms.last;
      final npDamageSpecs = np.functions.first;

      final baseParam = DamageParameters()
        ..attack = yuyu.atkGrowth[level - 1] + 1000
        ..attackerClass = yuyu.classId
        ..defenderClass = defenderClass.id
        ..classAdvantage = classAdvantage
        ..attackerAttribute = yuyu.attribute
        ..defenderAttribute = defenderAttribute
        ..totalHits = Maths.sum(np.svt.damage)
        ..isNp = true
        ..currentCardType = np.svt.card
        ..firstCardType = np.svt.card
        ..damageAdditionBuff = 175 // passive
        ..fixedRandom = 900;

      test('NP 5 OC 1 with no npSpecificDamage', () {
        final oc1Np5DataSpec = npDamageSpecs.svals.last;

        final damageParameters = baseParam.copy()
          ..damageRate = oc1Np5DataSpec.Value!
          ..npSpecificAttackRate = 1000;
        expect(calculateDamage(damageParameters), equals(45744));
      });

      test('NP 5 OC 3 with no npSpecificDamage', () {
        final oc3Np5DataSpec = npDamageSpecs.svals3!.last;

        final damageParameters = baseParam.copy()
          ..damageRate = oc3Np5DataSpec.Value!
          ..npSpecificAttackRate = 1000;
        expect(calculateDamage(damageParameters), equals(45744));
      });

      test('NP 5 OC 1 with npSpecificDamage', () {
        final oc1Np5DataSpec = npDamageSpecs.svals.last;

        final damageParameters = baseParam.copy()
          ..damageRate = oc1Np5DataSpec.Value!
          ..npSpecificAttackRate = oc1Np5DataSpec.Correction!;
        expect(calculateDamage(damageParameters), equals(68529));
      });

      test('NP 5 OC 3 with npSpecificDamage', () {
        final oc3Np5DataSpec = npDamageSpecs.svals3!.last;

        final damageParameters = baseParam.copy()
          ..damageRate = oc3Np5DataSpec.Value!
          ..npSpecificAttackRate = oc3Np5DataSpec.Correction!;
        expect(calculateDamage(damageParameters), equals(79921));
      });

      test('NP 5 OC 4 with npSpecificDamage', () {
        final oc4Np5DataSpec = npDamageSpecs.svals4!.last;

        final damageParameters = baseParam.copy()
          ..damageRate = oc4Np5DataSpec.Value!
          ..npSpecificAttackRate = oc4Np5DataSpec.Correction!;
        expect(calculateDamage(damageParameters), equals(85617));
      });

      test('NP 5 OC 5 with npSpecificDamage', () {
        final oc5Np5DataSpec = npDamageSpecs.svals5!.last;

        final damageParameters = baseParam.copy()
          ..damageRate = oc5Np5DataSpec.Value!
          ..npSpecificAttackRate = oc5Np5DataSpec.Correction!;
        expect(calculateDamage(damageParameters), equals(91314));
      });
    });

    test('Vald III vs Caenis 1.099', () {
      const defenderClass = SvtClass.lancer;
      const defenderAttribute = Attribute.earth;

      final vald = db.gameData.servantsById[700700]!;
      const level = 120;
      final classAdvantage = ConstData.getClassRelation(vald.className, defenderClass);

      final np = vald.noblePhantasms.last;
      final npDamageSpecs = np.functions.first;
      final oc1Np5DataSpec = npDamageSpecs.svals.last;

      final damageParameters = DamageParameters()
        ..attack = vald.atkGrowth[level - 1] + 1000 + 1000 + 2400
        ..attackerClass = vald.classId
        ..defenderClass = defenderClass.id
        ..classAdvantage = classAdvantage
        ..attackerAttribute = vald.attribute
        ..defenderAttribute = defenderAttribute
        ..totalHits = Maths.sum(np.svt.damage)
        ..isNp = true
        ..currentCardType = np.svt.card
        ..firstCardType = np.svt.card
        ..fixedRandom = 1099
        ..attackBuff = 1700
        ..cardBuff = 2000
        ..npDamageBuff = 950
        ..damageRate = oc1Np5DataSpec.Value!
        ..npSpecificAttackRate = 1000;
      expect(calculateDamage(damageParameters), equals(954401));
    });
  });

  group('calculateAttackNpGain', () {
    test('float32 test in Atlas', () {
      final param = AttackNpGainParameters()
        ..firstCardType = CardType.quick
        ..isMightyChain = true
        ..currentCardType = CardType.arts
        ..chainPos = 3
        ..attackerNpCharge = 25
        ..defenderNpRate = 1000
        ..cardBuff = 2600
        ..cardResist = 1800
        ..npGainBuff = 1300
        ..isCritical = true;

      expect(calculateAttackNpGain(param), equals(766));
    });

    group('Yang Guifei (2500400) vs Caster', () {
      const defenderNpRate = 1200;

      final yuyu = db.gameData.servantsById[2500400]!;
      final np = yuyu.noblePhantasms.last;

      final baseParam = AttackNpGainParameters()..defenderNpRate = defenderNpRate;

      final npBaseParam = baseParam.copy()
        ..isNp = true
        ..attackerNpCharge = np.npGain.np.last
        ..currentCardType = np.svt.card
        ..firstCardType = np.svt.card;

      const baseHitNpGain = 183;
      test('NP 5 as base', () {
        expect(calculateAttackNpGain(npBaseParam), equals(baseHitNpGain));
      });

      test('chainPos does not affect NP', () {
        final param = npBaseParam.copy()..chainPos = 5;

        expect(calculateAttackNpGain(param), equals(baseHitNpGain));
      });

      test('NP does not benefit from firstCardBonus', () {
        final param = npBaseParam.copy()..firstCardType = CardType.quick;

        expect(calculateAttackNpGain(param), equals(baseHitNpGain));
      });

      test('cardBuff & cardResist', () {
        final param = npBaseParam.copy()..cardBuff = 1500;

        final hitNpGain = calculateAttackNpGain(param);
        expect(hitNpGain, equals(275));

        param
          ..cardBuff = 1800
          ..cardResist = 1300;
        expect(calculateAttackNpGain(param), equals(hitNpGain));

        param
          ..cardBuff = 1000
          ..cardResist = 50000;
        expect(calculateAttackNpGain(param), equals(0));
      });

      test('npGainBuff', () {
        final param = npBaseParam.copy()..npGainBuff = 1300;

        expect(calculateAttackNpGain(param), equals(238));
      });

      test('overkill', () {
        final param = npBaseParam.copy()..isOverkill = true;

        expect(calculateAttackNpGain(param), equals(274));
      });

      test('with double Altria Caster & overkill', () {
        final param = npBaseParam.copy()
          ..cardBuff = 2000
          ..npGainBuff = 1600
          ..isOverkill = true;
        expect(calculateAttackNpGain(param), equals(880));
      });

      test('firstCardBonus', () {
        final params = baseParam.copy()
          ..attackerNpCharge = np.npGain.arts.last
          ..chainPos = 2
          ..currentCardType = CardType.arts
          ..firstCardType = CardType.quick;

        final hitNpGainWithoutBonus = calculateAttackNpGain(params);
        expect(hitNpGainWithoutBonus, equals(275));

        params.firstCardType = CardType.buster;

        expect(calculateAttackNpGain(params), equals(hitNpGainWithoutBonus));

        params.firstCardType = CardType.arts;

        final hitNpGainWithBonus = calculateAttackNpGain(params);
        expect(hitNpGainWithBonus, equals(336));

        params
          ..firstCardType = CardType.quick
          ..isMightyChain = true;

        expect(calculateAttackNpGain(params), equals(hitNpGainWithBonus));
      });

      test('cardCorrection', () {
        final params = baseParam.copy()
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
        final params = baseParam.copy()
          ..attackerNpCharge = np.npGain.arts.last
          ..chainPos = 2
          ..isCritical = true
          ..currentCardType = CardType.arts
          ..firstCardType = CardType.arts;

        expect(calculateAttackNpGain(params), equals(673));
      });
    });

    test('Gilgamesh (Caster) (501800) vs Berserker', () {
      const defenderNpRate = 800;

      final gilgamesh = db.gameData.servantsById[501800]!;
      final np = gilgamesh.noblePhantasms.last;

      final param = AttackNpGainParameters()
        ..defenderNpRate = defenderNpRate
        ..isNp = true
        ..attackerNpCharge = np.npGain.np.last
        ..currentCardType = np.svt.card
        ..firstCardType = np.svt.card
        ..cardBuff = 1100; // passive

      expect(calculateAttackNpGain(param), equals(42));
    });

    test('Minamoto-no-Raikou (Berserker) (702300) vs Lancer', () {
      const defenderNpRate = 1000;

      final raikou = db.gameData.servantsById[702300]!;
      final np = raikou.noblePhantasms.last;

      final param = AttackNpGainParameters()
        ..defenderNpRate = defenderNpRate
        ..attackerNpCharge = np.npGain.arts.last
        ..currentCardType = CardType.arts
        ..firstCardType = np.svt.card
        ..isCritical = true
        ..npGainBuff = 1450
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
      const defenderNpRate = 1000;

      final abby = db.gameData.servantsById[2500100]!;
      final np = abby.noblePhantasms.last;

      final param = AttackNpGainParameters()
        ..defenderNpRate = defenderNpRate
        ..attackerNpCharge = np.npGain.arts.last
        ..currentCardType = CardType.arts
        ..firstCardType = CardType.arts
        ..isCritical = true
        ..cardBuff = 1800
        ..npGainBuff = 1300
        ..chainPos = 3
        ..isOverkill = true;

      expect(calculateAttackNpGain(param), equals(1149));
    });

    test('Vlad III (Berserker) (700700) vs Beast III/R', () {
      const defenderNpRate = 1000;

      final vlad = db.gameData.servantsById[700700]!;
      final np = vlad.noblePhantasms.last;

      final param = AttackNpGainParameters()
        ..defenderNpRate = defenderNpRate
        ..attackerNpCharge = np.npGain.arts.last
        ..currentCardType = CardType.arts
        ..firstCardType = CardType.arts
        ..isCritical = true
        ..cardBuff = 1800
        ..npGainBuff = 1300
        ..chainPos = 3
        ..isOverkill = true;

      expect(calculateAttackNpGain(param), equals(2299));
    });
  });

  group('calculateDefendNpGain', () {
    group('Yang Guifei (2500400) vs Caster', () {
      const attackerNpRate = 1200;

      final yuyu = db.gameData.servantsById[2500400]!;
      final np = yuyu.noblePhantasms.last;

      final baseParam = DefendNpGainParameters()
        ..defenderNpGainRate = np.npGain.defence.last
        ..attackerNpRate = attackerNpRate;

      const baseHitNpGain = 360;
      test('NP 5 as base', () {
        expect(calculateDefendNpGain(baseParam), equals(baseHitNpGain));
      });

      test('npGainBuff', () {
        final param = baseParam.copy()..npGainBuff = 1300;

        expect(calculateDefendNpGain(param), equals(467));
      });

      test('defNpGainBuff', () {
        final param = baseParam.copy()..defenseNpGainBuff = 1200;

        expect(calculateDefendNpGain(param), equals(432));
      });

      test('overkill', () {
        final param = baseParam.copy()..isOverkill = true;

        expect(calculateDefendNpGain(param), equals(540));
      });
    });

    test('Gilgamesh (Caster) (501800) vs Berserker', () {
      const attackerNpRate = 800;

      final gilgamesh = db.gameData.servantsById[501800]!;
      final np = gilgamesh.noblePhantasms.last;

      final baseParam = DefendNpGainParameters()
        ..defenderNpGainRate = np.npGain.defence.last
        ..attackerNpRate = attackerNpRate;

      expect(calculateDefendNpGain(baseParam), equals(240));
    });

    test('Ashiya Douman (1001000) vs Caster', () {
      const attackerNpRate = 1200;

      final douman = db.gameData.servantsById[1001000]!;
      final np = douman.noblePhantasms.last;

      final baseParam = DefendNpGainParameters()
        ..defenderNpGainRate = np.npGain.defence.last
        ..attackerNpRate = attackerNpRate
        ..defenseNpGainBuff = 1200;

      expect(calculateDefendNpGain(baseParam), equals(576));

      baseParam.npGainBuff = 1300;

      expect(calculateDefendNpGain(baseParam), equals(748));
    });
  });

  group('calculateStar', () {
    group('Izumo no Okuni (504900) vs Rider', () {
      const defenderStarRate = 100;

      final okumi = db.gameData.servantsById[504900]!;
      final np = okumi.noblePhantasms.last;

      final baseParam = StarParameters()
        ..attackerStarGen = okumi.starGen
        ..defenderStarRate = defenderStarRate;

      final npBaseParam = baseParam.copy()
        ..isNp = true
        ..currentCardType = np.svt.card
        ..firstCardType = np.svt.card
        ..cardResist = 800; // np first function

      const baseHitStarGen = 1169;
      test('NP 5 as base', () {
        expect(calculateStar(npBaseParam).toDouble(), moreOrLessEquals(baseHitStarGen.toDouble(), epsilon: 1));
      });

      test('chainPos does not affect NP', () {
        final param = npBaseParam.copy()..chainPos = 5;

        expect(calculateStar(param).toDouble(), moreOrLessEquals(baseHitStarGen.toDouble(), epsilon: 1));
      });

      test('NP does not benefit from firstCardBonus', () {
        final param = npBaseParam.copy()..firstCardType = CardType.arts;

        expect(calculateStar(param).toDouble(), moreOrLessEquals(baseHitStarGen.toDouble(), epsilon: 1));
      });

      test('cardBuff & cardResist', () {
        final param = npBaseParam.copy()..cardBuff = 1500;

        final starGen = calculateStar(param).toDouble();
        expect(starGen, moreOrLessEquals(1569, epsilon: 1));

        param
          ..cardBuff = 1800
          ..cardResist = 1300 - 200;
        expect(calculateStar(param).toDouble(), moreOrLessEquals(starGen, epsilon: 1));
      });

      test('starGenBuff & enemyStarGenResist', () {
        final param = npBaseParam.copy()..starGenBuff = 300;

        final starGen = calculateStar(param).toDouble();
        expect(starGen, moreOrLessEquals(1469, epsilon: 1));

        param
          ..starGenBuff = 800
          ..enemyStarGenResist = 500;
        expect(calculateStar(param).toDouble(), moreOrLessEquals(starGen, epsilon: 1));

        param
          ..starGenBuff = 0
          ..enemyStarGenResist = 50000;
        expect(calculateStar(param).toDouble(), equals(0));

        param
          ..starGenBuff = 50000
          ..enemyStarGenResist = 0;
        expect(calculateStar(param).toDouble(), equals(ConstData.constants.starRateMax));
      });

      test('overkill', () {
        final param = npBaseParam.copy()..isOverkill = true;

        expect(calculateStar(param).toDouble(), moreOrLessEquals(1469, epsilon: 1));
      });

      test('with double Scathach-Skadi (Caster) & overkill', () {
        final param = npBaseParam.copy()
          ..cardBuff = 2000
          ..isOverkill = true;
        expect(calculateStar(param).toDouble(), moreOrLessEquals(2269, epsilon: 1));
      });

      test('firstCardBonus', () {
        final params = baseParam.copy()
          ..chainPos = 2
          ..currentCardType = CardType.buster
          ..firstCardType = CardType.buster;

        final hitStarGenWithoutBonus = calculateStar(params).toDouble();
        expect(hitStarGenWithoutBonus, moreOrLessEquals(359, epsilon: 1));

        params.firstCardType = CardType.arts;

        expect(calculateStar(params).toDouble(), moreOrLessEquals(hitStarGenWithoutBonus, epsilon: 1));

        params.firstCardType = CardType.quick;

        final hitStarGenWithBonus = calculateStar(params).toDouble();
        expect(hitStarGenWithBonus, moreOrLessEquals(559, epsilon: 1));

        params
          ..firstCardType = CardType.arts
          ..isMightyChain = true;

        expect(calculateStar(params).toDouble(), moreOrLessEquals(hitStarGenWithBonus, epsilon: 1));
      });

      test('cardCorrection', () {
        final params = baseParam.copy()
          ..chainPos = 1
          ..currentCardType = CardType.buster
          ..firstCardType = CardType.buster;

        expect(calculateStar(params).toDouble(), moreOrLessEquals(309, epsilon: 1));

        params.chainPos = 2;

        expect(calculateStar(params).toDouble(), moreOrLessEquals(359, epsilon: 1));

        params.chainPos = 3;

        expect(calculateStar(params).toDouble(), moreOrLessEquals(409, epsilon: 1));

        params
          ..chainPos = 2
          ..currentCardType = CardType.arts
          ..firstCardType = CardType.buster;

        expect(calculateStar(params).toDouble(), moreOrLessEquals(209, epsilon: 1));

        params.firstCardType = CardType.quick;

        expect(calculateStar(params).toDouble(), moreOrLessEquals(409, epsilon: 1));
      });

      test('criticalModifier', () {
        final params = baseParam.copy()
          ..chainPos = 2
          ..isCritical = true
          ..currentCardType = CardType.quick
          ..firstCardType = CardType.quick;

        expect(calculateStar(params).toDouble(), moreOrLessEquals(1909, epsilon: 1));
      });
    });

    test('Kama (Caster) (603700) vs Avenger', () {
      const defenderStarRate = -100;

      final kama = db.gameData.servantsById[603700]!;
      final np = kama.noblePhantasms.last;

      final param = StarParameters()
        ..attackerStarGen = kama.starGen
        ..defenderStarRate = defenderStarRate
        ..isNp = true
        ..currentCardType = np.svt.card
        ..firstCardType = np.svt.card
        ..cardBuff = 1300; // passive + np first function

      expect(calculateStar(param).toDouble(), moreOrLessEquals(1189, epsilon: 1));
    });
  });
}
