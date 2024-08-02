import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/interactions/_delegate.dart';
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

        final altria = battle.targetedPlayer!;
        altria.np = 10000;
        final npActions = [CombatAction(altria, altria.getNPCard()!)];

        final hpBeforeDamage = battle.onFieldEnemies[1]!.hp;
        await battle.playerTurn(npActions);
        final hpAfterDamage = battle.onFieldEnemies[1]!.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(12542));
      });

      test('chainPos does not affect NP', () async {
        final battle = BattleData();
        await battle.init(db.gameData.questPhases[9300040603]!, altriaSettings, null);

        final altria = battle.targetedPlayer!;
        altria.np = 10000;
        final npActions = [CombatAction(altria, altria.getCards()[4]), CombatAction(altria, altria.getNPCard()!)];

        final hpBeforeDamage = battle.onFieldEnemies[1]!.hp;
        await battle.playerTurn(npActions);
        final hpAfterDamage = battle.onFieldEnemies[1]!.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(12542));
      });

      test('B A B EX', () async {
        final battle = BattleData();
        await battle.init(db.gameData.questPhases[9300040603]!, altriaSettings, null);

        final altria = battle.targetedPlayer!;
        final busterArtsBuster = [
          CombatAction(altria, altria.getCards()[4]),
          CombatAction(altria, altria.getCards()[1]),
          CombatAction(altria, altria.getCards()[3]),
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
        final altria = battle.targetedPlayer!;
        final npActions = [CombatAction(altria, altria.getNPCard()!)];

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

        final yuyu = battle.targetedPlayer!;
        final npActions = [CombatAction(yuyu, yuyu.getNPCard()!)];

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

        final yuyu = battle.targetedPlayer!;
        final artsQuickArts = [
          CombatAction(yuyu, yuyu.getCards()[3]),
          CombatAction(yuyu, yuyu.getCards()[0]),
          CombatAction(yuyu, yuyu.getCards()[2]),
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
        final yuyu = battle.targetedPlayer!;
        final npActions = [CombatAction(yuyu, yuyu.getNPCard()!)];

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

        final okuni = battle.targetedPlayer!;
        final npActions = [CombatAction(okuni, okuni.getNPCard()!)];

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

        final okuni = battle.targetedPlayer!;
        final quickBusterQuick = [
          CombatAction(okuni, okuni.getCards()[0]),
          CombatAction(okuni, okuni.getCards()[4]),
          CombatAction(okuni, okuni.getCards()[1]),
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
        final okuni = battle.targetedPlayer!;
        final npActions = [CombatAction(okuni, okuni.getNPCard()!)];

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
      final kama = battle.targetedPlayer!;
      expect(kama.fieldIndex, 0);
      expect(kama.battleBuff.getAllBuffs().length, 13);
      await battle.activateSvtSkill(0, 0);
      expect(kama.battleBuff.getAllBuffs().length, 15);
      await battle.activateSvtSkill(1, 1);
      await battle.activateSvtSkill(1, 2);
      expect(kama.battleBuff.getAllBuffs().length, 19);
      await battle.activateSvtSkill(2, 1);
      await battle.activateSvtSkill(2, 2);
      expect(kama.battleBuff.getAllBuffs().length, 22);
      final npActions = [CombatAction(kama, kama.getNPCard()!)];

      battle.enemyTargetIndex = 1;
      final skyCaster = battle.targetedEnemy!;
      expect(skyCaster.fieldIndex, 1);
      final hpBeforeDamage = skyCaster.hp;
      await battle.playerTurn(npActions);
      final hpAfterDamage = skyCaster.hp;

      expect(kama.battleBuff.getAllBuffs().length, 21);
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

      expect(kama.battleBuff.getAllBuffs().length, 21);
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
      expect(kama.battleBuff.getAllBuffs().length, 26);

      final wave3enemy = battle.targetedEnemy!;
      expect(wave3enemy.fieldIndex, 0);
      expect(wave3enemy.uniqueId, 10);
      final hpBeforeDamageWave3 = wave3enemy.hp;
      await battle.playerTurn([
        CombatAction(kama, kama.getCards()[3]),
        CombatAction(kama, kama.getCards()[2]..critical = true),
        CombatAction(kama, kama.getNPCard()!),
      ]);
      final hpAfterDamageWave3 = wave3enemy.hp;

      expect(kama.battleBuff.getAllBuffs().length, 18);
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
        collectBuffsPerType(battle.onFieldAllyServants[0]!.battleBuff.validBuffs, BuffType.avoidState).first;

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
    battle.options.mightyChain = false;
    await battle.init(db.gameData.questPhases[9300040603]!, lipAndJinako, null);

    final lip = battle.onFieldAllyServants[0]!;
    final jinako = battle.onFieldAllyServants[1]!;

    await battle.activateSvtSkill(0, 2); // lip is stunned

    expect(jinako.np, 0);
    await battle.playerTurn([CombatAction(lip, lip.getCards()[1]), CombatAction(jinako, jinako.getCards()[4])]);
    expect(jinako.np, 0);
    expect(lip.canAttack(), isTrue);
    await battle.playerTurn([CombatAction(lip, lip.getCards()[1]), CombatAction(jinako, jinako.getCards()[4])]);
    expect(jinako.np, greaterThan(0));
  });

  test('Stun provides firstCardBonus after 7th anni', () async {
    final List<PlayerSvtData> lipAndJinako = [
      PlayerSvtData.id(1000100)..lv = 80,
      PlayerSvtData.id(2300300)..lv = 90,
    ];
    final battle = BattleData();
    battle.options.mightyChain = true;
    await battle.init(db.gameData.questPhases[9300040603]!, lipAndJinako, null);

    final lip = battle.onFieldAllyServants[0]!;
    final jinako = battle.onFieldAllyServants[1]!;

    await battle.activateSvtSkill(0, 2); // lip is stunned

    expect(jinako.np, 0);
    expect(lip.canAttack(), false);
    await battle.playerTurn([CombatAction(lip, lip.getCards()[1]), CombatAction(jinako, jinako.getCards()[4])]);
    expect(jinako.np, greaterThan(0));
  });

  test('Stun does not provide typeChain before 7th anni', () async {
    final List<PlayerSvtData> lipAndJinako = [
      PlayerSvtData.id(1000100)..lv = 80,
      PlayerSvtData.id(2300300)..lv = 90,
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, lipAndJinako, null);

    battle.options.mightyChain = false;
    final lip = battle.onFieldAllyServants[0]!;
    final jinako = battle.onFieldAllyServants[1]!;

    await battle.activateSvtSkill(0, 2); // lip is stunned

    expect(lip.np, 0);
    await battle.playerTurn([
      CombatAction(lip, lip.getCards()[1]),
      CombatAction(jinako, jinako.getCards()[1]),
      CombatAction(jinako, jinako.getCards()[2])
    ]);
    expect(lip.np, 0);

    await battle.playerTurn([
      CombatAction(lip, lip.getCards()[1]),
      CombatAction(jinako, jinako.getCards()[1]),
      CombatAction(jinako, jinako.getCards()[2])
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
      CombatAction(lip, lip.getCards()[1]),
      CombatAction(lip, lip.getCards()[2]),
      CombatAction(lip, lip.getCards()[3])
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
    expect(nito.battleBuff.getAllBuffs().length, 5);
    await battle.activateSvtSkill(0, 1);
    expect(nito.battleBuff.getAllBuffs().length, 7);
    await battle.activateSvtSkill(0, 2);
    expect(nito.battleBuff.getAllBuffs().length, 11);
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
    await battle.activateMysticCodeSkill(0);
    await battle.activateMysticCodeSkill(1);
    await battle.activateMysticCodeSkill(2);
    expect(tezcatlipoca.hp, 15535 + 3600);
    expect(tezcatlipoca.np, 1200);
    expect(battle.criticalStars, moreOrLessEquals(18, epsilon: 0.001));

    expect(
        await tezcatlipoca.getBuffValue(
          battle,
          BuffAction.npdamage,
          other: battle.onFieldEnemies[0]!,
          card: tezcatlipoca.getNPCard(),
        ),
        420);
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
      CombatAction(bunyan, bunyan.getNPCard()!),
      CombatAction(bunyan, bunyan.getCards()[1]),
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
      CombatAction(arash, arash.getNPCard()!),
      CombatAction(arash, arash.getCards()[0]),
      CombatAction(arash, arash.getCards()[1]),
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
      CombatAction(crane, crane.getNPCard()!),
      CombatAction(crane, crane.getCards()[0]),
      CombatAction(crane, crane.getCards()[1]),
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
      CombatAction(rba, rba.getNPCard()!),
      CombatAction(rba, rba.getCards()[0]),
      CombatAction(rba, rba.getCards()[1]),
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
      CombatAction(spaceIshtar, spaceIshtar.getNPCard()!),
      CombatAction(spaceIshtar, spaceIshtar.getCards()[0]),
      CombatAction(spaceIshtar, spaceIshtar.getCards()[1]),
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
      CombatAction(chenGong, chenGong.getNPCard()!),
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
      CombatAction(archtypeEarth, archtypeEarth.getCards()[4]),
      CombatAction(archtypeEarth, archtypeEarth.getCards()[2]),
      CombatAction(archtypeEarth, archtypeEarth.getCards()[0]),
    ]);

    expect(previousHp1 - enemy1.hp, 6044 + 5573 + 4896 + 9067);

    final enemy2 = battle.onFieldEnemies[1]!;
    final enemy3 = battle.onFieldEnemies[2]!;
    final previousHp2 = enemy2.hp;
    final previousHp3 = enemy3.hp;
    await battle.playerTurn([
      CombatAction(archtypeEarth, archtypeEarth.getNPCard()!),
    ]);

    expect(previousHp2 - enemy2.hp, 29468);
    expect(previousHp3 - enemy3.hp, 29468);

    final enemy4 = battle.onFieldEnemies[0]!;
    final previousHp4 = enemy4.hp;
    await battle.playerTurn([
      CombatAction(archtypeEarth, archtypeEarth.getCards()[4]),
      CombatAction(archtypeEarth, archtypeEarth.getCards()[2]),
      CombatAction(archtypeEarth, archtypeEarth.getCards()[0]),
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
      CombatAction(archtypeEarth, archtypeEarth.getCards()[0]),
    ]);

    expect(previousHp1 - enemy1.hp, 2659);

    final previousHp2 = enemy1.hp;
    await battle.playerTurn([
      CombatAction(archtypeEarth, archtypeEarth.getCards()[2]),
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
      CombatAction(eliz, eliz.getCards()[2]..critical = true),
    ]);

    expect(previousHp1 - enemy1.hp, 4256);

    await battle.activateSvtSkill(0, 1);
    final previousHp2 = enemy1.hp;
    await battle.playerTurn([
      CombatAction(eliz, eliz.getCards()[1]..critical = true),
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
    await battle.playerTurn([CombatAction(buyan, buyan.getNPCard()!)]);
    expect(previousHp1 - enemy1.hp, 10517);

    final previousHp2 = enemy1.hp;
    buyan.np = 10000;
    await battle.playerTurn([CombatAction(buyan, buyan.getNPCard()!)]);
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
    await battle.playerTurn([CombatAction(musashi, musashi.getNPCard()!)]);
    expect(previousHp1 - enemy1.hp, 80119);

    final enemy2 = battle.onFieldEnemies[1]!;
    final previousHp2 = enemy2.hp;
    enemy2.niceEnemy!.traits = enemy2.niceEnemy!.traits.toList()..add(NiceTrait(id: 109));
    musashi.np = 10000;
    await battle.playerTurn([CombatAction(musashi, musashi.getNPCard()!)]);
    expect(previousHp2 - enemy2.hp, 120179);

    final enemy3 = battle.onFieldEnemies[2]!;
    final previousHp3 = enemy3.hp;
    enemy3.niceEnemy!.traits = enemy3.niceEnemy!.traits.toList()
      ..add(NiceTrait(id: 115))
      ..add(NiceTrait(id: 109));
    musashi.np = 10000;
    await battle.playerTurn([CombatAction(musashi, musashi.getNPCard()!)]);
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
    await battle.playerTurn([CombatAction(karen2, karen2.getCards()[4])]);
    expect(previousHp1 - enemy1.hp, 6974);

    final previousHp2 = enemy1.hp;
    await battle.playerTurn([CombatAction(karen1, karen1.getCards()[4])]);
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
    await battle.playerTurn([CombatAction(hokusai, hokusai.getNPCard()!)]);
    expect(previousHp1 - enemy1.hp, 24311);
    expect(previousHp2 - enemy2.hp, 24311);

    await battle.skipWave();

    final enemy3 = battle.onFieldEnemies[0]!;
    final previousHp3 = enemy3.hp;
    hokusai.np = 10000;
    await battle.playerTurn([CombatAction(hokusai, hokusai.getNPCard()!)]);
    expect(previousHp3 - enemy3.hp, 24311);

    // should have one stack of defDown from skill 3
    final previousHp4 = enemy3.hp;
    hokusai.np = 10000;
    await battle.playerTurn([CombatAction(hokusai, hokusai.getNPCard()!)]);
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
    await battle.playerTurn([CombatAction(melusine, melusine.getNPCard()!)]);
    expect(previousHp1 - enemy1.hp, 22874);

    final previousHp2 = enemy1.hp;
    melusine.np = 10000;
    await battle.playerTurn([CombatAction(melusine, melusine.getNPCard()!)]);
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
    await battle.playerTurn([CombatAction(morgan, morgan.getNPCard()!)]);
    expect(morgan.skillInfoList[1].chargeTurn, 4);
    expect(morgan.skillInfoList[2].chargeTurn, 3);
    expect(battle.criticalStars, moreOrLessEquals(14.5, epsilon: 0.001));

    await battle.activateSvtSkill(1, 0);
    expect(morgan.skillInfoList[1].chargeTurn, 2);
    expect(morgan.skillInfoList[2].chargeTurn, 1);

    morgan.np = 10000;
    await battle.playerTurn([CombatAction(morgan, morgan.getNPCard()!)]);
    expect(morgan.skillInfoList[1].chargeTurn, 1);
    expect(morgan.skillInfoList[2].chargeTurn, 0);
    expect(battle.criticalStars, moreOrLessEquals(4.2, epsilon: 0.001)); // one enemy not killed
  });

  test('Check Duplicate vs Attack trigger functions', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(100200)
        ..lv = 80
        ..atkFou = 1000
        ..skillLvs = [10, 10, 10]
        ..setSkillStrengthenLvs([2, 2, 1])
        ..tdLv = 5,
      PlayerSvtData.id(404800)
        ..lv = 90
        ..tdLv = 5,
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final altriaAlter = battle.onFieldAllyServants[0]!;
    await battle.activateSvtSkill(0, 0);
    altriaAlter.np = 10000;
    await battle.playerTurn([CombatAction(altriaAlter, altriaAlter.getNPCard()!)]);
    expect(altriaAlter.np, 4000);

    final bakin = battle.onFieldAllyServants[1]!;
    await battle.activateSvtSkill(1, 2);
    bakin.np = 10000;
    final previousBuffCount1 = altriaAlter.battleBuff.getAllBuffs().length;
    final previousBuffCount2 = bakin.battleBuff.getAllBuffs().length;
    await battle.playerTurn([CombatAction(bakin, bakin.getNPCard()!)]);
    expect(altriaAlter.battleBuff.getAllBuffs().length, previousBuffCount1 + 1);
    expect(bakin.battleBuff.getAllBuffs().length, previousBuffCount2 + 1);
  });

  test('AOE NP vs AttackTriggerFunc with enemyOne target', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(2500900)
        ..lv = 1
        ..tdLv = 1,
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final koyan = battle.onFieldAllyServants[0]!;
    await battle.activateSvtSkill(0, 2);
    koyan.np = 10000;

    final enemy1 = battle.onFieldEnemies[0]!;
    final enemy2 = battle.onFieldEnemies[1]!;
    final enemy3 = battle.onFieldEnemies[2]!;
    final previousBuffCount1 = enemy1.battleBuff.getAllBuffs().length;
    final previousBuffCount2 = enemy2.battleBuff.getAllBuffs().length;
    final previousBuffCount3 = enemy3.battleBuff.getAllBuffs().length;
    await battle.playerTurn([CombatAction(koyan, koyan.getNPCard()!)]);
    expect(enemy1.battleBuff.getAllBuffs().length, previousBuffCount1 + 4);
    expect(enemy2.battleBuff.getAllBuffs().length, previousBuffCount2 + 4);
    expect(enemy3.battleBuff.getAllBuffs().length, previousBuffCount3 + 4);
  });

  test('AOE NP vs AttackTriggerFunc with added damage buffs', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(404800)
        ..lv = 1
        ..tdLv = 1,
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final maqin = battle.onFieldAllyServants[0]!;
    await battle.activateSvtSkill(0, 2);
    maqin.np = 10000;

    final enemy1 = battle.onFieldEnemies[0]!;
    final enemy2 = battle.onFieldEnemies[1]!;
    final enemy3 = battle.onFieldEnemies[2]!;
    final previousHp1 = enemy1.hp;
    final previousHp2 = enemy2.hp;
    final previousHp3 = enemy3.hp;
    await battle.playerTurn([CombatAction(maqin, maqin.getNPCard()!)]);
    final afterHp1 = enemy1.hp;
    final afterHp2 = enemy2.hp;
    final afterHp3 = enemy3.hp;
    expect(afterHp1, previousHp1 - 3689);
    expect(afterHp2, previousHp2 - 7228);
    expect(afterHp3, previousHp3 - 3689);

    maqin.np = 10000;
    await battle.playerTurn([CombatAction(maqin, maqin.getNPCard()!)]);
    expect(enemy1.hp, afterHp1 - 3866);
    expect(enemy2.hp, afterHp2 - 7582);
    expect(enemy3.hp, afterHp3 - 3866);
  });

  test('OC NP vs AttackTriggerFunc', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(305400)
        ..lv = 90
        ..tdLv = 5
        ..skillLvs = [10, 10, 10],
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final bhima = battle.onFieldAllyServants[0]!;
    await battle.activateSvtSkill(0, 2);
    bhima.np = 20000;

    await battle.playerTurn([CombatAction(bhima, bhima.getNPCard()!)]);
    expect(battle.criticalStars, moreOrLessEquals(9.030, epsilon: 0.001));
  });

  test('Andersen skill upgrade', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(500500)
        ..skillLvs = [10, 10, 10]
        ..setSkillStrengthenLvs([2, 1, 1]),
      PlayerSvtData.id(703300)
        ..lv = 90
        ..atkFou = 1000
        ..tdLv = 5
        ..skillLvs = [10, 10, 10],
      PlayerSvtData.id(703500)
        ..lv = 90
        ..atkFou = 1000
        ..tdLv = 5
        ..skillLvs = [10, 10, 10],
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final ajAlter = battle.onFieldAllyServants[1]!;
    final enemy1 = battle.onFieldEnemies[0]!;
    final enemy2 = battle.onFieldEnemies[1]!;
    final enemy3 = battle.onFieldEnemies[2]!;

    await battle.activateSvtSkill(0, 0);
    ajAlter.np = 10000;

    final previousHp1 = enemy1.hp;
    final previousHp2 = enemy2.hp;
    final previousHp3 = enemy3.hp;
    await battle.playerTurn([CombatAction(ajAlter, ajAlter.getNPCard()!)]);
    expect(previousHp1 - enemy1.hp, 51655);
    expect(previousHp2 - enemy2.hp, 51655);
    expect(previousHp3 - enemy3.hp, 51655);
    expect(battle.criticalStars, moreOrLessEquals(12.945, epsilon: 0.001));

    final mori = battle.onFieldAllyServants[2]!;
    final enemy4 = battle.onFieldEnemies[0]!;
    final previousHp4 = enemy4.hp;
    await battle.playerTurn([CombatAction(mori, mori.getCards()[4]..critical = true)]);
    expect(previousHp4 - enemy4.hp, 27764);
    expect(battle.criticalStars, moreOrLessEquals(1.006, epsilon: 0.001));
  });

  test('Summer Chloe additionalSkillId moveToLastSubmember', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(1101600)..skillLvs = [10, 10, 10],
      PlayerSvtData.id(800100),
      PlayerSvtData.id(100100),
      PlayerSvtData.id(100200),
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final chloe = battle.onFieldAllyServants[0]!;

    expect(battle.onFieldAllyServants[0]?.svtId, 1101600);
    expect(battle.onFieldAllyServants[1]?.svtId, 800100);
    expect(battle.onFieldAllyServants[2]?.svtId, 100100);
    expect(battle.nonnullBackupPlayers[0].svtId, 100200);

    await battle.activateSvtSkill(0, 1);
    await battle.playerTurn([CombatAction(chloe, chloe.getCards()[0])]);

    expect(battle.onFieldAllyServants[0]?.svtId, 100200);
    expect(battle.onFieldAllyServants[1]?.svtId, 800100);
    expect(battle.onFieldAllyServants[2]?.svtId, 100100);
    expect(battle.nonnullBackupPlayers[0].svtId, 1101600);
  });

  test('aoko related tests', () async {
    final battle = BattleData();
    final playerSettings = [
      PlayerSvtData.id(2501400)
        ..lv = 90
        ..tdLv = 5
        ..commandCodes = [
          null,
          null,
          null,
          null,
          db.gameData.commandCodesById[8400460]!, // Mage of Flowers on aoe buster card
        ],
      PlayerSvtData.id(2800100),
    ];
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

    final aoko = battle.onFieldAllyServants[0]!;
    expect(aoko.hp, 15250);
    expect(aoko.maxHp, 15250);
    expect(aoko.atk, 12319);
    aoko.np = 10000;
    final npCard = aoko.getNPCard()!;
    final aokoFixedBusterCard = aoko.getCards()[4];
    final aokoBusterCardThatWillChangeToArts = aoko.getCards()[3];

    final enemy1 = battle.onFieldEnemies[0]!;
    final enemy2 = battle.onFieldEnemies[1]!;
    final enemy3 = battle.onFieldEnemies[2]!;
    await battle.playerTurn([
      CombatAction(aoko, npCard),
      CombatAction(aoko, aokoBusterCardThatWillChangeToArts)..cardData.critical = true,
      CombatAction(aoko, aokoFixedBusterCard)..cardData.critical = true,
    ]);
    // test battle gets actual card for removeDeadActor and damage
    expect(enemy1.hp, -368);
    expect(enemy2.hp, 2603);
    expect(enemy3.hp, 4363);

    expect(aoko.np, 3901); // test AoE card with Mage of Flowers does not stack, also test transformSvt adds new passive
    expect(aoko.hp, 14230); // transformSvt change hp & maxHp & atk
    expect(aoko.maxHp, 14230);
    expect(aoko.atk, 13584);

    final magicBulletTrait = [NiceTrait(id: 2885)];
    expect(aoko.getBuffsWithTraits(magicBulletTrait).length, 2);

    await battle.skipWave();
    await battle.activateSvtSkill(0, 0);
    expect(aoko.getBuffsWithTraits(magicBulletTrait).length, 10);
    final enemy4 = battle.onFieldEnemies[0]!;
    final enemy5 = battle.onFieldEnemies[1]!;
    final enemy6 = battle.onFieldEnemies[2]!;
    await battle.playerTurn([
      CombatAction(aoko, aoko.getCards()[0]),
      CombatAction(aoko, aoko.getCards()[2]),
      CombatAction(aoko, aoko.getCards()[4]),
    ]);
    expect(enemy4.hp, -21825);
    expect(enemy5.hp, -4909);
    expect(enemy6.hp, -7553);
    expect(aoko.getBuffsWithTraits(magicBulletTrait).length, 2); // ex consumes all remaining

    await battle.skipTurn();
    await battle.skipTurn();
    await battle.skipTurn();
    expect(aoko.getBuffsWithTraits(magicBulletTrait).length, 8);
    await battle.activateSvtSkill(0, 0);
    expect(aoko.getBuffsWithTraits(magicBulletTrait).length, 14);
    await battle.activateSvtSkill(1, 1); // verify oberon's selfTurnEnd is after aoko
    final enemy7 = battle.onFieldEnemies[0]!;
    await battle.playerTurn([CombatAction(aoko, aoko.getNPCard()!)]);
    expect(enemy7.hp, 63007);
    expect(aoko.getBuffsWithTraits(magicBulletTrait).length, 6);
    expect(aoko.np, 1000);
  });

  test('Kiyohime skill upgrade vs Buff Burn', () async {
    final battle = BattleData();
    final playerSettings = [
      PlayerSvtData.id(701300)..setSkillStrengthenLvs([2, 2, 1]), // Kiyohime
      PlayerSvtData.id(502600), // caster Eliz
    ];
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

    await battle.activateSvtSkill(1, 1); // buff burn on all enemies
    final kiyohime = battle.onFieldAllyServants[0]!;
    await battle.activateSvtSkill(0, 1);
    kiyohime.np = 10000;
    await battle.playerTurn([CombatAction(kiyohime, kiyohime.getNPCard()!)]);
    expect(kiyohime.np, 3000);
  });

  test('Alice Skill 3 seal after 13 uses', () async {
    final battle = BattleData();
    final playerSettings = [PlayerSvtData.id(505500)];
    await battle.init(db.gameData.questPhases[9300040603]!, playerSettings, null);

    final alice = battle.onFieldAllyServants[0]!;
    for (int idx = 1; idx <= 12; idx += 1) {
      await battle.activateSvtSkill(0, 2);
      expect(alice.isDonotSkillSelect(3), false);
      await battle.resetPlayerSkillCD(isMysticCode: false, svt: alice);
    }
    await battle.activateSvtSkill(0, 2);
    expect(alice.isDonotSkillSelect(3), true);
  });

  test('Overkill clear after NP', () async {
    final battle = BattleData();
    final quest = await AtlasApi.questPhase(94073901, 1);
    final playerSettings = [
      PlayerSvtData.id(900500) // Sherlock
        ..tdLv = 5
        ..setSkillStrengthenLvs([2, 1, 1])
        ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
        ..ceLimitBreak = true,
      PlayerSvtData.id(603700) // Kama
        ..lv = 120
        ..tdLv = 5
        ..cardStrengthens = [500, 500, 500, 500, 500]
        ..commandCodes = [db.gameData.commandCodesById[8400650], null, null, null, null],
      PlayerSvtData.id(901400)..skillLvs = [10, 5, 10], // swimsuit Skadi
      PlayerSvtData.id(503900)..ce = db.gameData.craftEssencesById[9302920], // Skadi with bond CE
    ];
    final mysticCode = MysticCodeData()
      ..mysticCode = db.gameData.mysticCodes[20]!
      ..level = 10;
    await battle.init(quest!, playerSettings, mysticCode);

    final sherlock = battle.onFieldAllyServants[0]!;
    final kama = battle.onFieldAllyServants[1]!;

    battle.delegate = BattleDelegate();
    battle.delegate?.replaceMember = (onFieldSvts, backupSvts) async {
      return Tuple2(onFieldSvts[2]!, backupSvts[0]!);
    };
    int count = 0;
    battle.delegate?.damageRandom = (random) async {
      if (count == 0) {
        count += 1;
        return 171908;
      } else {
        return 54773;
      }
    };

    await battle.activateSvtSkill(0, 0);
    await battle.activateSvtSkill(1, 1);
    await battle.activateMysticCodeSkill(1);

    battle.playerTargetIndex = 1;
    await battle.activateSvtSkill(2, 0);
    await battle.activateSvtSkill(2, 1);
    await battle.activateSvtSkill(2, 2);

    await battle.activateMysticCodeSkill(2);
    await battle.activateSvtSkill(2, 2);

    battle.options.tailoredExecution = true;
    await battle.playerTurn([
      CombatAction(kama, kama.getNPCard()!),
      CombatAction(sherlock, sherlock.getNPCard()!),
      CombatAction(kama, kama.getCards()[0])..cardData.critical = true,
    ]);
    expect(kama.np, 3882);
  });

  group('Method tests', () {
    final List<PlayerSvtData> okuniWithDoubleCba = [
      PlayerSvtData.id(504900)..lv = 90,
      PlayerSvtData.id(503900)..lv = 90,
      PlayerSvtData.id(503900)..lv = 90,
    ];

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

      final card = battle.onFieldAllyServants[0]!.getCards()[0];
      card.critical = true;
      expect(checkTraitFunction(myTraits: card.traits, requiredTraits: [NiceTrait(id: Trait.criticalHit.value)]), true);
    });
  });
}
