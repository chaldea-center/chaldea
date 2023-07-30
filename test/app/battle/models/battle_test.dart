import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import '../../../test_init.dart';

void main() async {
  await initiateForTest();

  group('Combat integration', () {
    group('Altria (100100) vs Sky caster', () {
      final List<PlayerSvtData> altriaSettings = [
        PlayerSvtData.id(100100)
          ..setSkillStrengthenLvs([1, 2, 1])
          ..tdLv = 1
          ..setNpStrengthenLv(2)
          ..lv = 90
          ..atkFou = 0
          ..hpFou = 0
      ];

      test('NP 1 OC 1 no fou as base', () async {
        final battle = BattleData();
        await battle.init(db.gameData.questPhases[9300040603]!, altriaSettings,
            null); // this stage has a sky caster in wave 1 at index 1

        final altria = battle.targetedAlly!;
        altria.np = 10000;
        final npActions = [CombatAction(altria, altria.getNPCard(battle)!)];

        final hpBeforeDamage = battle.onFieldEnemies[1]!.hp;
        await battle.playerTurn(npActions);
        final hpAfterDamage = battle.onFieldEnemies[1]!.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(12542));
      });

      test('chainPos does not affect NP', () async {
        final battle = BattleData();
        await battle.init(db.gameData.questPhases[9300040603]!, altriaSettings, null);

        final altria = battle.targetedAlly!;
        altria.np = 10000;
        final npActions = [
          CombatAction(altria, altria.getCards(battle)[4]),
          CombatAction(altria, altria.getNPCard(battle)!)
        ];

        final hpBeforeDamage = battle.onFieldEnemies[1]!.hp;
        await battle.playerTurn(npActions);
        final hpAfterDamage = battle.onFieldEnemies[1]!.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(12542));
      });

      test('B A B EX', () async {
        final battle = BattleData();
        await battle.init(db.gameData.questPhases[9300040603]!, altriaSettings, null);

        final altria = battle.targetedAlly!;
        final busterArtsBuster = [
          CombatAction(altria, altria.getCards(battle)[4]),
          CombatAction(altria, altria.getCards(battle)[1]),
          CombatAction(altria, altria.getCards(battle)[3]),
        ];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.onFieldEnemies[1]!;
        final hpBeforeDamage = skyCaster.hp;
        await battle.playerTurn(busterArtsBuster);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(4180 + 3553 + 5435 + 6271));
        expect(altria.np, equals(1390)); // ex is overkill
        expect(battle.criticalStars, moreOrLessEquals(5.20, epsilon: 0.001));
      });

      test('with 1000 Fou & double Koyanskaya of Light', () async {
        final List<PlayerSvtData> altriaWithDoubleKoyan = [
          PlayerSvtData.id(100100)
            ..setSkillStrengthenLvs([1, 2, 1])
            ..tdLv = 1
            ..setNpStrengthenLv(2)
            ..lv = 90
            ..atkFou = 1000
            ..hpFou = 0,
          PlayerSvtData.id(604200)
            ..setSkillStrengthenLvs([1, 1, 1])
            ..tdLv = 1
            ..setNpStrengthenLv(1)
            ..lv = 90
            ..atkFou = 0
            ..hpFou = 0,
          PlayerSvtData.id(604200)
            ..setSkillStrengthenLvs([1, 1, 1])
            ..tdLv = 1
            ..setNpStrengthenLv(1)
            ..lv = 90
            ..atkFou = 0
            ..hpFou = 0
        ];
        final battle = BattleData();
        await battle.init(db.gameData.questPhases[9300040603]!, altriaWithDoubleKoyan, null);

        await battle.activateSvtSkill(0, 0);
        await battle.activateSvtSkill(0, 1);
        await battle.activateSvtSkill(1, 0);
        await battle.activateSvtSkill(1, 2);
        await battle.activateSvtSkill(2, 0);
        await battle.activateSvtSkill(2, 2);
        final altria = battle.targetedAlly!;
        final npActions = [CombatAction(altria, altria.getNPCard(battle)!)];

        final skyCaster = battle.onFieldEnemies[1]!;
        final hpBeforeDamage = skyCaster.hp;
        await battle.playerTurn(npActions);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(52388));
      });
    });

    group('Yang Guifei (2500400) vs Sky caster', () {
      final List<PlayerSvtData> yuyuSettings = [
        PlayerSvtData.id(2500400)
          ..setSkillStrengthenLvs([2, 1, 1])
          ..tdLv = 5
          ..setNpStrengthenLv(1)
          ..lv = 90
          ..atkFou = 1000
          ..hpFou = 1000
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true
      ];

      test('NP 5 OC 1 as base', () async {
        final battle = BattleData();
        await battle.init(db.gameData.questPhases[9300040603]!, yuyuSettings, null);

        final yuyu = battle.targetedAlly!;
        final npActions = [CombatAction(yuyu, yuyu.getNPCard(battle)!)];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.targetedEnemy!;
        final hpBeforeDamage = skyCaster.hp;
        await battle.playerTurn(npActions);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(52575));
        expect(yuyu.np, equals(914)); // 2 hits overkill
        expect(battle.criticalStars, moreOrLessEquals(3.20, epsilon: 0.001)); // include okuni's passive
      });

      test('A Q A EX', () async {
        final battle = BattleData();
        await battle.init(db.gameData.questPhases[9300040603]!, yuyuSettings, null);

        final yuyu = battle.targetedAlly!;
        final artsQuickArts = [
          CombatAction(yuyu, yuyu.getCards(battle)[3]),
          CombatAction(yuyu, yuyu.getCards(battle)[0]),
          CombatAction(yuyu, yuyu.getCards(battle)[2]),
        ];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.targetedEnemy!;
        final hpBeforeDamage = skyCaster.hp;
        await battle.playerTurn(artsQuickArts);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(3668 + 3528 + 5065 + 7161));
        expect(yuyu.np, equals(14246)); // A: no Overkill, Q: no Overkill, A: 1 hits Overkill, EX: 4 hits Overkill
        expect(battle.criticalStars, moreOrLessEquals(15.10, epsilon: 0.001)); // include okuni's passive
      });

      test('with 1000 Fou & double Altria Caster', () async {
        final List<PlayerSvtData> yuyuWithDoubleCastoria = [
          PlayerSvtData.id(2500400)
            ..setSkillStrengthenLvs([2, 1, 1])
            ..tdLv = 5
            ..setNpStrengthenLv(1)
            ..lv = 90
            ..atkFou = 1000
            ..hpFou = 1000
            ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
            ..ceLv = 100
            ..ceLimitBreak = true,
          PlayerSvtData.id(504500)
            ..setSkillStrengthenLvs([1, 1, 1])
            ..tdLv = 1
            ..setNpStrengthenLv(1)
            ..lv = 90
            ..atkFou = 0
            ..hpFou = 0,
          PlayerSvtData.id(504500)
            ..setSkillStrengthenLvs([1, 1, 1])
            ..tdLv = 1
            ..setNpStrengthenLv(1)
            ..lv = 90
            ..atkFou = 0
            ..hpFou = 0
        ];
        final battle = BattleData();
        await battle.init(db.gameData.questPhases[9300040603]!, yuyuWithDoubleCastoria, null);

        await battle.activateSvtSkill(1, 0);
        await battle.activateSvtSkill(1, 1);
        await battle.activateSvtSkill(1, 2);
        await battle.activateSvtSkill(2, 0);
        await battle.activateSvtSkill(2, 1);
        await battle.activateSvtSkill(2, 2);
        final yuyu = battle.targetedAlly!;
        final npActions = [CombatAction(yuyu, yuyu.getNPCard(battle)!)];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.targetedEnemy!;
        final hpBeforeDamage = skyCaster.hp;
        await battle.playerTurn(npActions);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(146896));
        expect(yuyu.np, equals(3227)); // 3 hits overkill
        expect(battle.criticalStars, moreOrLessEquals(3.50, epsilon: 0.001)); // include okuni's passive
      });
    });

    group('Izumo no Okuni (504900) vs Sky caster', () {
      final List<PlayerSvtData> okuniSettings = [
        PlayerSvtData.id(504900)
          ..setSkillStrengthenLvs([1, 1, 1])
          ..tdLv = 5
          ..setNpStrengthenLv(1)
          ..lv = 90
          ..atkFou = 1000
          ..hpFou = 1000
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true
      ];

      test('NP 5 OC 1 as base', () async {
        final battle = BattleData();
        await battle.init(db.gameData.questPhases[9300040603]!, okuniSettings, null);

        final okuni = battle.targetedAlly!;
        final npActions = [CombatAction(okuni, okuni.getNPCard(battle)!)];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.targetedEnemy!;
        final hpBeforeDamage = skyCaster.hp;
        await battle.playerTurn(npActions);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(56556));
        expect(okuni.np, equals(1435)); // 2 hits overkill
        expect(battle.criticalStars, moreOrLessEquals(14.19, epsilon: 0.001)); // include okuni's passive
      });

      test('Q B Q EX', () async {
        final battle = BattleData();
        await battle.init(db.gameData.questPhases[9300040603]!, okuniSettings, null);

        final okuni = battle.targetedAlly!;
        final quickBusterQuick = [
          CombatAction(okuni, okuni.getCards(battle)[0]),
          CombatAction(okuni, okuni.getCards(battle)[4]),
          CombatAction(okuni, okuni.getCards(battle)[1]),
        ];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.targetedEnemy!;
        final hpBeforeDamage = skyCaster.hp;
        await battle.playerTurn(quickBusterQuick);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(2356 + 5302 + 3299 + 5891));
        expect(okuni.np, equals(11968)); // A: no Overkill, Q: no Overkill, A: 1 hits Overkill, EX: 5 hits Overkill
        expect(battle.criticalStars, moreOrLessEquals(24.594, epsilon: 0.001)); // include okuni's passive
      });

      test('with 1000 Fou & double Scathach-Skadi (Caster)', () async {
        final List<PlayerSvtData> okuniWithDoubleCba = [
          PlayerSvtData.id(504900)
            ..setSkillStrengthenLvs([1, 1, 1])
            ..tdLv = 5
            ..setNpStrengthenLv(1)
            ..lv = 90
            ..atkFou = 1000
            ..hpFou = 1000
            ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
            ..ceLv = 100
            ..ceLimitBreak = true,
          PlayerSvtData.id(503900)
            ..setSkillStrengthenLvs([1, 1, 1])
            ..tdLv = 1
            ..setNpStrengthenLv(1)
            ..lv = 90
            ..atkFou = 0
            ..hpFou = 0,
          PlayerSvtData.id(503900)
            ..setSkillStrengthenLvs([1, 1, 1])
            ..tdLv = 1
            ..setNpStrengthenLv(1)
            ..lv = 90
            ..atkFou = 0
            ..hpFou = 0
        ];
        final battle = BattleData();
        await battle.init(db.gameData.questPhases[9300040603]!, okuniWithDoubleCba, null);

        await battle.activateSvtSkill(1, 0);
        await battle.activateSvtSkill(1, 2);
        await battle.activateSvtSkill(2, 0);
        await battle.activateSvtSkill(2, 2);
        final okuni = battle.targetedAlly!;
        final npActions = [CombatAction(okuni, okuni.getNPCard(battle)!)];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.targetedEnemy!;
        final hpBeforeDamage = skyCaster.hp;
        await battle.playerTurn(npActions);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(103687));
        expect(okuni.np, equals(2740)); // 6 hits overkill
        expect(battle.criticalStars, moreOrLessEquals(22.49, epsilon: 0.001)); // include okuni's passive
      });
    });

    test('Kama 3 turn loop & double Castoria', () async {
      final List<PlayerSvtData> kamaWithDoubleCastoria = [
        PlayerSvtData.id(1101100)
          ..tdLv = 5
          ..lv = 120
          ..atkFou = 2000
          ..hpFou = 2000
          ..appendLvs = [10, 10, 10]
          ..ce = db.gameData.craftEssencesById[9401850] // Magical Girl of Sapphire
          ..ceLv = 100
          ..ceLimitBreak = true,
        PlayerSvtData.id(504500)..lv = 90,
        PlayerSvtData.id(504500)..lv = 90,
      ];
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, kamaWithDoubleCastoria, null);

      expect(battle.waveCount, 1);
      expect(battle.totalTurnCount, 1);
      expect(battle.turnCount, 1);
      final kama = battle.targetedAlly!;
      expect(kama.fieldIndex, 0);
      expect(kama.battleBuff.allBuffs.length, 13);
      await battle.activateSvtSkill(0, 0);
      expect(kama.battleBuff.allBuffs.length, 15);
      await battle.activateSvtSkill(1, 1);
      await battle.activateSvtSkill(1, 2);
      expect(kama.battleBuff.allBuffs.length, 19);
      await battle.activateSvtSkill(2, 1);
      await battle.activateSvtSkill(2, 2);
      expect(kama.battleBuff.allBuffs.length, 22);
      final npActions = [CombatAction(kama, kama.getNPCard(battle)!)];

      battle.enemyTargetIndex = 1;
      final skyCaster = battle.targetedEnemy!;
      expect(skyCaster.fieldIndex, 1);
      final hpBeforeDamage = skyCaster.hp;
      await battle.playerTurn(npActions);
      final hpAfterDamage = skyCaster.hp;

      expect(kama.battleBuff.allBuffs.length, 21);
      expect(hpBeforeDamage - hpAfterDamage, 82618);
      expect(kama.np, 12422); // np from each hit is added one by one, so would trigger np pity (> 9900) immediately
      expect(battle.criticalStars, moreOrLessEquals(3.432, epsilon: 0.001));
      expect(battle.isActorOnField(skyCaster.uniqueId), isFalse);
      expect(battle.isBattleFinished, isFalse);
      expect(battle.waveCount, 2);
      expect(battle.totalTurnCount, 2);
      expect(battle.turnCount, 1);
      expect(skyCaster.fieldIndex, -1);

      final wave2enemy = battle.targetedEnemy!;
      expect(wave2enemy.fieldIndex, 0);
      expect(wave2enemy.uniqueId, 7);
      final hpBeforeDamageWave2 = wave2enemy.hp;
      await battle.playerTurn(npActions);
      final hpAfterDamageWave2 = wave2enemy.hp;

      expect(kama.battleBuff.allBuffs.length, 21);
      expect(hpBeforeDamageWave2 - hpAfterDamageWave2, 82618);
      expect(kama.np, 11584 + 380);
      expect(battle.criticalStars, moreOrLessEquals(2.532, epsilon: 0.001));
      expect(battle.isActorOnField(wave2enemy.uniqueId), isFalse);
      expect(battle.isBattleFinished, isFalse);
      expect(battle.waveCount, 3);
      expect(battle.totalTurnCount, 3);
      expect(battle.turnCount, 1);
      expect(wave2enemy.fieldIndex, -1);

      await battle.activateSvtSkill(0, 1);
      await battle.activateSvtSkill(0, 2);
      await battle.activateSvtSkill(1, 0);
      await battle.activateSvtSkill(2, 0);
      expect(kama.battleBuff.allBuffs.length, 26);

      final wave3enemy = battle.targetedEnemy!;
      expect(wave3enemy.fieldIndex, 0);
      expect(wave3enemy.uniqueId, 10);
      final hpBeforeDamageWave3 = wave3enemy.hp;
      await battle.playerTurn([
        CombatAction(kama, kama.getCards(battle)[3]),
        CombatAction(kama, kama.getCards(battle)[2]..isCritical = true),
        CombatAction(kama, kama.getNPCard(battle)!),
      ]);
      final hpAfterDamageWave3 = wave3enemy.hp;

      expect(kama.battleBuff.allBuffs.length, 18);
      expect(hpBeforeDamageWave3 - hpAfterDamageWave3, 15605 + 44520 + 282836);
      expect(kama.np, 3744 + 380);
      expect(battle.criticalStars, moreOrLessEquals(0.184 + 0.784 + 1.143, epsilon: 0.001));
      expect(battle.isActorOnField(wave3enemy.uniqueId), isFalse);
      expect(battle.isBattleFinished, isTrue);
      expect(wave3enemy.fieldIndex, -1);
    });
  });

  test('Activate skill checks buff status', () async {
    final List<PlayerSvtData> lipAndJinako = [
      PlayerSvtData.id(1000100)..lv = 80,
      PlayerSvtData.id(2300300)..lv = 90,
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, lipAndJinako, null);

    await battle.activateSvtSkill(0, 0);

    final avoidStateBuff =
        collectBuffsPerType(battle.onFieldAllyServants[0]!.battleBuff.allBuffs, BuffType.avoidState).first;

    expect(avoidStateBuff.count, 3);

    await battle.activateSvtSkill(0, 2);

    expect(avoidStateBuff.count, 2);

    await battle.activateSvtSkill(1, 2);

    expect(avoidStateBuff.count, 1);
  });

  test('Stun does not provide firstCardBonus before 7th anni', () async {
    final List<PlayerSvtData> lipAndJinako = [
      PlayerSvtData.id(1000100)..lv = 80,
      PlayerSvtData.id(2300300)..lv = 90,
    ];
    final battle = BattleData();
    battle.options.isAfter7thAnni = false;
    await battle.init(db.gameData.questPhases[9300040603]!, lipAndJinako, null);

    final lip = battle.onFieldAllyServants[0]!;
    final jinako = battle.onFieldAllyServants[1]!;

    await battle.activateSvtSkill(0, 2); // lip is stunned

    expect(jinako.np, 0);
    await battle
        .playerTurn([CombatAction(lip, lip.getCards(battle)[1]), CombatAction(jinako, jinako.getCards(battle)[4])]);
    expect(jinako.np, 0);
    expect(lip.canCommandCard(battle), isTrue);
    await battle
        .playerTurn([CombatAction(lip, lip.getCards(battle)[1]), CombatAction(jinako, jinako.getCards(battle)[4])]);
    expect(jinako.np, greaterThan(0));
  });

  test('Stun provides firstCardBonus after 7th anni', () async {
    final List<PlayerSvtData> lipAndJinako = [
      PlayerSvtData.id(1000100)..lv = 80,
      PlayerSvtData.id(2300300)..lv = 90,
    ];
    final battle = BattleData();
    battle.options.isAfter7thAnni = true;
    await battle.init(db.gameData.questPhases[9300040603]!, lipAndJinako, null);

    final lip = battle.onFieldAllyServants[0]!;
    final jinako = battle.onFieldAllyServants[1]!;

    await battle.activateSvtSkill(0, 2); // lip is stunned

    expect(jinako.np, 0);
    expect(lip.canCommandCard(battle), false);
    await battle
        .playerTurn([CombatAction(lip, lip.getCards(battle)[1]), CombatAction(jinako, jinako.getCards(battle)[4])]);
    expect(jinako.np, greaterThan(0));
  });

  test('Stun does not provide typeChain before 7th anni', () async {
    final List<PlayerSvtData> lipAndJinako = [
      PlayerSvtData.id(1000100)..lv = 80,
      PlayerSvtData.id(2300300)..lv = 90,
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, lipAndJinako, null);

    battle.options.isAfter7thAnni = false;
    final lip = battle.onFieldAllyServants[0]!;
    final jinako = battle.onFieldAllyServants[1]!;

    await battle.activateSvtSkill(0, 2); // lip is stunned

    expect(lip.np, 0);
    await battle.playerTurn([
      CombatAction(lip, lip.getCards(battle)[1]),
      CombatAction(jinako, jinako.getCards(battle)[1]),
      CombatAction(jinako, jinako.getCards(battle)[2])
    ]);
    expect(lip.np, 0);

    await battle.playerTurn([
      CombatAction(lip, lip.getCards(battle)[1]),
      CombatAction(jinako, jinako.getCards(battle)[1]),
      CombatAction(jinako, jinako.getCards(battle)[2])
    ]);
    expect(lip.np, greaterThan(20));
  });

  test('Stun does not provide braveChain', () async {
    final List<PlayerSvtData> lipAndJinako = [
      PlayerSvtData.id(1000100)..lv = 80,
      PlayerSvtData.id(2300300)..lv = 90,
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, lipAndJinako, null);

    final lip = battle.onFieldAllyServants[0]!;
    final enemy = battle.onFieldEnemies[0]!;

    await battle.activateSvtSkill(0, 2); // lip is stunned

    final previousHp = enemy.hp;
    await battle.playerTurn([
      CombatAction(lip, lip.getCards(battle)[1]),
      CombatAction(lip, lip.getCards(battle)[2]),
      CombatAction(lip, lip.getCards(battle)[3])
    ]);
    expect(enemy.hp, previousHp);
  });

  test('Nitocris (Alter) bug', () async {
    final List<PlayerSvtData> lipAndJinako = [
      PlayerSvtData.id(1101500)..lv = 90,
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, lipAndJinako, null);

    final nito = battle.onFieldAllyServants[0]!;
    expect(nito.battleBuff.allBuffs.length, 5);
    await battle.activateSvtSkill(0, 1);
    expect(nito.battleBuff.allBuffs.length, 7);
    await battle.activateSvtSkill(0, 2);
    expect(nito.battleBuff.allBuffs.length, 11);
  });

  test('Tezcatlipoca passive', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(604700)..lv = 90,
      PlayerSvtData.id(604700)..lv = 90,
    ];
    final mysticCode = MysticCodeData()
      ..mysticCode = db.gameData.mysticCodes[130]!
      ..level = 10;
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, setting, mysticCode);

    final tezcatlipoca = battle.onFieldAllyServants[0]!;
    expect(tezcatlipoca.hp, 15535);
    expect(tezcatlipoca.np, 0);
    expect(battle.criticalStars, moreOrLessEquals(0, epsilon: 0.001));
    await battle.activateMysticCodeSKill(0);
    await battle.activateMysticCodeSKill(1);
    await battle.activateMysticCodeSKill(2);
    expect(tezcatlipoca.hp, 15535 + 3600);
    expect(tezcatlipoca.np, 1200);
    expect(battle.criticalStars, moreOrLessEquals(18, epsilon: 0.001));

    await battle.withActivator(tezcatlipoca, () async {
      await battle.withTarget(battle.onFieldEnemies[0]!, () async {
        await battle.withCard(tezcatlipoca.getNPCard(battle), () async {
          expect(await tezcatlipoca.getBuffValueOnAction(battle, BuffAction.npdamage), 420);
        });
      });
    });
  });

  test('deathEffect clear accumulation damage', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(702800)
        ..lv = 60
        ..setNpStrengthenLv(2)
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9303101303]!, setting, null);

    final bunyan = battle.onFieldAllyServants[0]!;
    await battle.skipWave();
    await battle.activateSvtSkill(0, 0);
    await battle.playerTurn([
      CombatAction(bunyan, bunyan.getNPCard(battle)!),
      CombatAction(bunyan, bunyan.getCards(battle)[1]),
    ]);
    expect(bunyan.np, 993);
  });

  test('attacker must be on field (dead)', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(201300)
        ..lv = 1
        ..setNpStrengthenLv(2)
        ..atkFou = 1000
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
      PlayerSvtData.id(701400)
        ..lv = 90
        ..setSkillStrengthenLvs([2, 1, 1]),
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

    final arash = battle.onFieldAllyServants[0]!;
    final enemy1 = battle.onFieldEnemies[0]!;
    final enemy2 = battle.onFieldEnemies[1]!;
    final previousHp1 = enemy1.hp;
    final previousHp2 = enemy2.hp;
    await battle.activateSvtSkill(1, 0);
    await battle.playerTurn([
      CombatAction(arash, arash.getNPCard(battle)!),
      CombatAction(arash, arash.getCards(battle)[0]),
      CombatAction(arash, arash.getCards(battle)[1]),
    ]);

    expect(arash.hp, 0);
    expect(previousHp1 - enemy1.hp, 25849);
    expect(previousHp2 - enemy2.hp, 12924);
  });

  test('attacker must be on field (crane)', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(201300)..lv = 1,
      PlayerSvtData.id(2300300)
        ..lv = 90
        ..ce = db.gameData.craftEssencesById[9404120] // 20 star on entry
        ..ceLv = 100
        ..ceLimitBreak = true,
      PlayerSvtData.id(504600)
        ..lv = 80
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

    final crane = battle.onFieldAllyServants[2]!;
    final enemy1 = battle.onFieldEnemies[0]!;
    final previousHp1 = enemy1.hp;
    await battle.playerTurn([
      CombatAction(crane, crane.getNPCard(battle)!),
      CombatAction(crane, crane.getCards(battle)[0]),
      CombatAction(crane, crane.getCards(battle)[1]),
    ]);

    expect(previousHp1, enemy1.hp);
  });

  test('brave chain bug on kill', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(901400)
        ..lv = 90
        ..tdLv = 1
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
      PlayerSvtData.id(701400)
        ..lv = 90
        ..setSkillStrengthenLvs([2, 1, 1]),
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

    final rba = battle.onFieldAllyServants[0]!;
    final enemy1 = battle.onFieldEnemies[0]!;
    final previousHp1 = enemy1.hp;
    await battle.playerTurn([
      CombatAction(rba, rba.getNPCard(battle)!),
      CombatAction(rba, rba.getCards(battle)[0]),
      CombatAction(rba, rba.getCards(battle)[1]),
    ]);

    expect(previousHp1 - enemy1.hp, 15407 + 3281 + 3786 + 11302);
  });

  test('Buffs status should be updated only after aoe np damage calculation', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(1100900)
        ..lv = 90
        ..tdLv = 5
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

    await battle.activateSvtSkill(0, 1);
    final spaceIshtar = battle.onFieldAllyServants[0]!;
    final enemy1 = battle.onFieldEnemies[0]!;
    final enemy2 = battle.onFieldEnemies[1]!;
    final previousHp1 = enemy1.hp;
    final previousHp2 = enemy2.hp;
    await battle.playerTurn([
      CombatAction(spaceIshtar, spaceIshtar.getNPCard(battle)!),
      CombatAction(spaceIshtar, spaceIshtar.getCards(battle)[0]),
      CombatAction(spaceIshtar, spaceIshtar.getCards(battle)[1]),
    ]);

    expect(previousHp1 - enemy1.hp, 37595);
    expect(previousHp2 - enemy2.hp, 37595);
  });

  test('Chen Gong vs 500 year', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(501900)
        ..lv = 90
        ..tdLv = 5
        ..ce = db.gameData.craftEssencesById[9400730] // 500 Year
        ..ceLv = 100
        ..ceLimitBreak = true,
      PlayerSvtData.id(504400)
        ..lv = 90
        ..tdLv = 5
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
      PlayerSvtData.id(500300)..lv = 90,
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

    final chenGong = battle.onFieldAllyServants[1]!;
    expect(battle.canSelectNp(1), true);
    expect(chenGong.hp, 11210);

    await battle.playerTurn([
      CombatAction(chenGong, chenGong.getNPCard(battle)!),
    ]);

    chenGong.np = 10000;
    expect(battle.canSelectNp(1), false);
    expect(battle.canUseNp(1), false);
    expect(chenGong.hp, 9210);

    await battle.skipWave();
    expect(battle.canSelectNp(1), true);
    expect(battle.canUseNp(1), true);
    expect(chenGong.hp, 7210);
  });

  test('Archtype: Earth passive', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(2300500)
        ..lv = 90
        ..tdLv = 5
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

    final archtypeEarth = battle.onFieldAllyServants[0]!;
    final enemy1 = battle.onFieldEnemies[0]!;
    final previousHp1 = enemy1.hp;
    await battle.playerTurn([
      CombatAction(archtypeEarth, archtypeEarth.getCards(battle)[4]),
      CombatAction(archtypeEarth, archtypeEarth.getCards(battle)[2]),
      CombatAction(archtypeEarth, archtypeEarth.getCards(battle)[0]),
    ]);

    expect(previousHp1 - enemy1.hp, 6044 + 5573 + 4896 + 9067);

    final enemy2 = battle.onFieldEnemies[1]!;
    final enemy3 = battle.onFieldEnemies[2]!;
    final previousHp2 = enemy2.hp;
    final previousHp3 = enemy3.hp;
    await battle.playerTurn([
      CombatAction(archtypeEarth, archtypeEarth.getNPCard(battle)!),
    ]);

    expect(previousHp2 - enemy2.hp, 29468);
    expect(previousHp3 - enemy3.hp, 29468);

    final enemy4 = battle.onFieldEnemies[0]!;
    final previousHp4 = enemy4.hp;
    await battle.playerTurn([
      CombatAction(archtypeEarth, archtypeEarth.getCards(battle)[4]),
      CombatAction(archtypeEarth, archtypeEarth.getCards(battle)[2]),
      CombatAction(archtypeEarth, archtypeEarth.getCards(battle)[0]),
    ]);

    expect(previousHp4 - enemy4.hp, 7404 + 6661 + 5911 + 9067);
  });

  test('PointBuff', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(2300500)
        ..lv = 90
        ..tdLv = 5
        ..ce = db.gameData.craftEssencesById[9405160] // crane event point buff ce
        ..ceLv = 100
        ..ceLimitBreak = true,
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    quest.individuality = quest.individuality.toList();
    quest.individuality.add(NiceTrait(id: 94000119));

    battle.options.pointBuffs = {
      0: EventPointBuff(
          id: 0, funcIds: [6912], eventPoint: 0, name: '', icon: '', background: ItemBGType.zero, value: 100),
      1: EventPointBuff(
          id: 1, funcIds: [6913], eventPoint: 0, name: '', icon: '', background: ItemBGType.zero, value: 200),
    };

    await battle.init(quest, setting, null);

    final archtypeEarth = battle.onFieldAllyServants[0]!;
    final enemy1 = battle.onFieldEnemies[0]!;
    final previousHp1 = enemy1.hp;
    await battle.playerTurn([
      CombatAction(archtypeEarth, archtypeEarth.getCards(battle)[0]),
    ]);

    expect(previousHp1 - enemy1.hp, 2659);

    final previousHp2 = enemy1.hp;
    await battle.playerTurn([
      CombatAction(archtypeEarth, archtypeEarth.getCards(battle)[2]),
    ]);

    expect(previousHp2 - enemy1.hp, 4062);
  });

  test('Imperial Consort of the Heavenly Emperor', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(502600)
        ..lv = 80
        ..commandCodes = [null, db.gameData.commandCodesById[8400770], null, null, null]
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final eliz = battle.onFieldAllyServants[0]!;
    final enemy1 = battle.onFieldEnemies[0]!;
    final previousHp1 = enemy1.hp;
    await battle.playerTurn([
      CombatAction(eliz, eliz.getCards(battle)[2]..isCritical = true),
    ]);

    expect(previousHp1 - enemy1.hp, 4256);

    await battle.activateSvtSkill(0, 1);
    final previousHp2 = enemy1.hp;
    await battle.playerTurn([
      CombatAction(eliz, eliz.getCards(battle)[1]..isCritical = true),
    ]);

    expect(previousHp2 - enemy1.hp, 5533 + 300); // 300 burn damage
  });

  test('Super Buyan passive, call functionAttackAfter after NP', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(1001300)
        ..lv = 90
        ..tdLv = 1
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final buyan = battle.onFieldAllyServants[0]!;
    final enemy1 = battle.onFieldEnemies[0]!;

    final previousHp1 = enemy1.hp;
    buyan.np = 10000;
    await battle.playerTurn([CombatAction(buyan, buyan.getNPCard(battle)!)]);
    expect(previousHp1 - enemy1.hp, 10517);

    final previousHp2 = enemy1.hp;
    buyan.np = 10000;
    await battle.playerTurn([CombatAction(buyan, buyan.getNPCard(battle)!)]);
    expect(previousHp2 - enemy1.hp, 12147);
  });

  test('Musashi NP always super effective bug', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(101700)
        ..lv = 90
        ..tdLv = 5
        ..setNpStrengthenLv(3)
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final musashi = battle.onFieldAllyServants[0]!;
    final enemy1 = battle.onFieldEnemies[0]!;

    final previousHp1 = enemy1.hp;
    await battle.playerTurn([CombatAction(musashi, musashi.getNPCard(battle)!)]);
    expect(previousHp1 - enemy1.hp, 80119);

    final enemy2 = battle.onFieldEnemies[1]!;
    final previousHp2 = enemy2.hp;
    enemy2.niceEnemy!.traits = enemy2.niceEnemy!.traits.toList()..add(NiceTrait(id: 109));
    musashi.np = 10000;
    await battle.playerTurn([CombatAction(musashi, musashi.getNPCard(battle)!)]);
    expect(previousHp2 - enemy2.hp, 120179);

    final enemy3 = battle.onFieldEnemies[2]!;
    final previousHp3 = enemy3.hp;
    enemy3.niceEnemy!.traits = enemy3.niceEnemy!.traits.toList()
      ..add(NiceTrait(id: 115))
      ..add(NiceTrait(id: 109));
    musashi.np = 10000;
    await battle.playerTurn([CombatAction(musashi, musashi.getNPCard(battle)!)]);
    expect(previousHp3 - enemy3.hp, 120179);
  });

  test('Svt passive skill & CE skill order', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(901100)
        ..lv = 90
        ..ce = db.gameData.craftEssencesById[9405550] // The Dwarf Tailor (debuff immune once)
        ..ceLv = 15
        ..ceLimitBreak = true,
      PlayerSvtData.id(1101100)..lv = 90, // avenger
      PlayerSvtData.id(901100)
        ..lv = 90
        ..ce = db.gameData.craftEssencesById[9405550] // The Dwarf Tailor (debuff immune once)
        ..ceLv = 15
        ..ceLimitBreak = true,
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final karen1 = battle.onFieldAllyServants[0]!;
    final karen2 = battle.onFieldAllyServants[2]!;
    final enemy1 = battle.onFieldEnemies[0]!;

    final previousHp1 = enemy1.hp;
    await battle.playerTurn([CombatAction(karen2, karen2.getCards(battle)[4])]);
    expect(previousHp1 - enemy1.hp, 6974);

    final previousHp2 = enemy1.hp;
    await battle.playerTurn([CombatAction(karen1, karen1.getCards(battle)[4])]);
    expect(previousHp2 - enemy1.hp, 6974);
  });

  test('functionNpAttack should happen after NP', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(2500200)
        ..lv = 90
        ..tdLv = 3
        ..skillLvs = [9, 9, 9]
        ..setSkillStrengthenLvs([1, 1, 2])
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLv = 100
        ..ceLimitBreak = true,
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final hokusai = battle.onFieldAllyServants[0]!;
    final enemy1 = battle.onFieldEnemies[0]!;
    final enemy2 = battle.onFieldEnemies[1]!;

    await battle.activateSvtSkill(0, 2);

    final previousHp1 = enemy1.hp;
    final previousHp2 = enemy2.hp;
    await battle.playerTurn([CombatAction(hokusai, hokusai.getNPCard(battle)!)]);
    expect(previousHp1 - enemy1.hp, 24311);
    expect(previousHp2 - enemy2.hp, 24311);

    await battle.skipWave();

    final enemy3 = battle.onFieldEnemies[0]!;
    final previousHp3 = enemy3.hp;
    hokusai.np = 10000;
    await battle.playerTurn([CombatAction(hokusai, hokusai.getNPCard(battle)!)]);
    expect(previousHp3 - enemy3.hp, 24311);

    // should have one stack of defDown from skill 3
    final previousHp4 = enemy3.hp;
    hokusai.np = 10000;
    await battle.playerTurn([CombatAction(hokusai, hokusai.getNPCard(battle)!)]);
    expect(previousHp4 - enemy3.hp, 28656);
  });

  test('melusine st np addSelfDamage buff', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(304800)
        ..lv = 100
        ..tdLv = 5
        ..limitCount = 1,
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    await battle.skipWave();
    await battle.skipWave();

    final melusine = battle.onFieldAllyServants[0]!;
    final enemy1 = battle.onFieldEnemies[0]!;

    final previousHp1 = enemy1.hp;
    melusine.np = 10000;
    await battle.playerTurn([CombatAction(melusine, melusine.getNPCard(battle)!)]);
    expect(previousHp1 - enemy1.hp, 22874);

    final previousHp2 = enemy1.hp;
    melusine.np = 10000;
    await battle.playerTurn([CombatAction(melusine, melusine.getNPCard(battle)!)]);
    expect(previousHp2 - enemy1.hp, 23874);
  });

  test('Summer Morgan', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(505300)
        ..lv = 90
        ..atkFou = 1000
        ..skillLvs = [10, 10, 10]
        ..tdLv = 5,
      PlayerSvtData.id(604200)
        ..lv = 90
        ..tdLv = 5,
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final morgan = battle.onFieldAllyServants[0]!;
    expect(morgan.skillInfoList[2].chargeTurn, 5);

    await battle.activateSvtSkill(0, 1);
    morgan.np = 10000;
    await battle.playerTurn([CombatAction(morgan, morgan.getNPCard(battle)!)]);
    expect(morgan.skillInfoList[1].chargeTurn, 4);
    expect(morgan.skillInfoList[2].chargeTurn, 3);
    expect(battle.criticalStars, moreOrLessEquals(14.488, epsilon: 0.001));

    await battle.activateSvtSkill(1, 0);
    expect(morgan.skillInfoList[1].chargeTurn, 2);
    expect(morgan.skillInfoList[2].chargeTurn, 1);

    morgan.np = 10000;
    await battle.playerTurn([CombatAction(morgan, morgan.getNPCard(battle)!)]);
    expect(morgan.skillInfoList[1].chargeTurn, 1);
    expect(morgan.skillInfoList[2].chargeTurn, 0);
    expect(battle.criticalStars, moreOrLessEquals(4.187, epsilon: 0.001)); // one enemy not killed
  });

  group('Method tests', () {
    final List<PlayerSvtData> okuniWithDoubleCba = [
      PlayerSvtData.id(504900)..lv = 90,
      PlayerSvtData.id(503900)..lv = 90,
      PlayerSvtData.id(503900)..lv = 90,
    ];

    test('Test checkTrait with no provided traits or no required traits', () async {
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, okuniWithDoubleCba, null);

      final divinityCheck = [NiceTrait(id: Trait.divine.id)];
      expect(
        battle.checkTraits(CheckTraitParameters(
          requiredTraits: divinityCheck,
        )),
        false,
      );

      expect(
        battle.checkTraits(CheckTraitParameters(
          requiredTraits: divinityCheck,
          checkIndivType: 3,
        )),
        false,
      );

      expect(
        battle.checkTraits(CheckTraitParameters(
          requiredTraits: [],
        )),
        true,
      );

      expect(
        battle.checkTraits(CheckTraitParameters(
          requiredTraits: [],
          checkIndivType: 3,
        )),
        true,
      );

      final okuni = battle.onFieldAllyServants[0]!;
      expect(
        battle.checkTraits(CheckTraitParameters(
          requiredTraits: [],
          actor: okuni,
          checkActorTraits: true,
        )),
        true,
      );

      expect(
        battle.checkTraits(CheckTraitParameters(
          requiredTraits: [],
          actor: okuni,
          checkActorTraits: true,
          checkIndivType: 3,
        )),
        true,
      );
    });

    test('Test checkTargetTraits & checkActivatorTraits', () async {
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, okuniWithDoubleCba, null);
      final okuni = battle.onFieldAllyServants[0]!;
      final cba = battle.onFieldAllyServants[1]!;
      final divinityCheck = [NiceTrait(id: Trait.divine.id)];
      battle.withActivatorSync(cba, () {
        battle.withTargetSync(okuni, () {
          expect(
            battle.checkTraits(CheckTraitParameters(
              requiredTraits: divinityCheck,
              actor: cba,
              checkActorTraits: true,
            )),
            true,
          );
          expect(
            battle.checkTraits(CheckTraitParameters(
              requiredTraits: divinityCheck,
              actor: okuni,
              checkActorTraits: true,
            )),
            false,
          );
        });
      });

      final buff = BuffData(Buff(id: -1, name: '', detail: '', vals: divinityCheck), DataVals());
      battle.withActivatorSync(okuni, () {
        battle.withBuffSync(buff, () {
          expect(
            battle.checkTraits(CheckTraitParameters(
              requiredTraits: divinityCheck,
              actor: okuni,
              checkActorTraits: true,
              checkCurrentBuffTraits: true,
            )),
            true,
          );
          expect(
            battle.checkTraits(CheckTraitParameters(
              requiredTraits: divinityCheck,
              actor: okuni,
              checkActorTraits: true,
              checkCurrentBuffTraits: true,
            )),
            true,
          );
        });

        expect(
          battle.checkTraits(CheckTraitParameters(
            requiredTraits: divinityCheck,
            actor: okuni,
            checkActorTraits: true,
            checkCurrentBuffTraits: true,
          )),
          false,
        );
        expect(
          battle.checkTraits(CheckTraitParameters(
            requiredTraits: divinityCheck,
            actor: okuni,
            checkActorTraits: true,
            checkCurrentBuffTraits: true,
          )),
          false,
        );
      });
    });

    test('Check isActorOnField', () async {
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, okuniWithDoubleCba, null);
      expect(battle.isActorOnField(1), isTrue);
      expect(battle.isActorOnField(3), isTrue);
      expect(battle.isActorOnField(7), isFalse);

      await battle.skipWave();
      expect(battle.isActorOnField(7), isTrue);
      expect(battle.isActorOnField(10), isFalse);
    });

    test('Critical Trait', () async {
      final battle = BattleData();
      await battle.init(db.gameData.questPhases[9300040603]!, okuniWithDoubleCba, null);

      battle.withCardSync(battle.onFieldAllyServants[0]!.getCards(battle)[0], () {
        battle.currentCard!.isCritical = true;

        expect(
          battle.checkTraits(CheckTraitParameters(
            requiredTraits: [NiceTrait(id: Trait.criticalHit.id)],
            checkCurrentCardTraits: true,
          )),
          true,
        );
      });
    });
  });
}
