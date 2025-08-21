import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/battle/interactions/_delegate.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:chaldea/models/models.dart';
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
          ..hpFou = 0,
      ];

      test('NP 1 OC 1 no fou as base', () async {
        final battle = BattleData();
        await battle.init(
          db.gameData.questPhases[9300040603]!,
          altriaSettings,
          null,
        ); // this stage has a sky caster in wave 1 at index 1

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
            ..hpFou = 0,
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
          ..equip1 = getNP100Equip(),
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
            ..equip1 = getNP100Equip(),
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
            ..hpFou = 0,
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
          ..equip1 = getNP100Equip(),
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
            ..equip1 = getNP100Equip(),
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
            ..hpFou = 0,
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
          ..appendLvs = [10, 10, 10, 0, 0]
          ..equip1 = SvtEquipData(
            ce: db.gameData.craftEssencesById[9401850], // Magical Girl of Sapphire
            lv: 100,
            limitBreak: true,
          ),
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
    final List<PlayerSvtData> lipAndJinako = [PlayerSvtData.id(1000100)..lv = 80, PlayerSvtData.id(2300300)..lv = 90];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, lipAndJinako, null);

    await battle.activateSvtSkill(0, 0);

    final avoidStateBuff = collectBuffsPerType(
      battle.onFieldAllyServants[0]!.battleBuff.validBuffs,
      BuffType.avoidState,
    ).first;

    expect(avoidStateBuff.count, 3);

    await battle.activateSvtSkill(0, 2);

    expect(avoidStateBuff.count, 2);

    await battle.activateSvtSkill(1, 2);

    expect(avoidStateBuff.count, 1);
  });

  test('Stun does not provide firstCardBonus before 7th anni', () async {
    final List<PlayerSvtData> lipAndJinako = [PlayerSvtData.id(1000100)..lv = 80, PlayerSvtData.id(2300300)..lv = 90];
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
    final List<PlayerSvtData> lipAndJinako = [PlayerSvtData.id(1000100)..lv = 80, PlayerSvtData.id(2300300)..lv = 90];
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
    final List<PlayerSvtData> lipAndJinako = [PlayerSvtData.id(1000100)..lv = 80, PlayerSvtData.id(2300300)..lv = 90];
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
      CombatAction(jinako, jinako.getCards()[2]),
    ]);
    expect(lip.np, 0);

    await battle.playerTurn([
      CombatAction(lip, lip.getCards()[1]),
      CombatAction(jinako, jinako.getCards()[1]),
      CombatAction(jinako, jinako.getCards()[2]),
    ]);
    expect(lip.np, greaterThan(20));
  });

  test('Stun does not provide braveChain', () async {
    final List<PlayerSvtData> lipAndJinako = [PlayerSvtData.id(1000100)..lv = 80, PlayerSvtData.id(2300300)..lv = 90];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, lipAndJinako, null);

    final lip = battle.onFieldAllyServants[0]!;
    final enemy = battle.onFieldEnemies[0]!;

    await battle.activateSvtSkill(0, 2); // lip is stunned

    final previousHp = enemy.hp;
    await battle.playerTurn([
      CombatAction(lip, lip.getCards()[1]),
      CombatAction(lip, lip.getCards()[2]),
      CombatAction(lip, lip.getCards()[3]),
    ]);
    expect(enemy.hp, previousHp);
  });

  test('Nitocris (Alter) bug', () async {
    final List<PlayerSvtData> lipAndJinako = [PlayerSvtData.id(1101500)..lv = 90];
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
    final List<PlayerSvtData> setting = [PlayerSvtData.id(604700)..lv = 90, PlayerSvtData.id(604700)..lv = 90];
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
    expect(
      await tezcatlipoca.getBuffValue(
        battle,
        BuffAction.npdamage,
        opponent: battle.onFieldEnemies[0]!,
        card: tezcatlipoca.getNPCard(),
      ),
      420,
    );

    await battle.activateMysticCodeSkill(1);
    expect(tezcatlipoca.np, 1200);
    expect(battle.criticalStars, moreOrLessEquals(18, epsilon: 0.001));

    await battle.activateMysticCodeSkill(2);
    expect(tezcatlipoca.hp, 15535 + 3600);
  });

  test('deathEffect clear accumulation damage', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(702800)
        ..lv = 60
        ..setNpStrengthenLv(2)
        ..equip1 = getNP100Equip(),
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9303101303]!, setting, null);

    final bunyan = battle.onFieldAllyServants[0]!;
    await battle.skipWave();
    await battle.activateSvtSkill(0, 0);
    await battle.playerTurn([CombatAction(bunyan, bunyan.getNPCard()!), CombatAction(bunyan, bunyan.getCards()[1])]);
    expect(bunyan.np, 993);
  });

  test('attacker must be on field (dead)', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(201300)
        ..lv = 1
        ..setNpStrengthenLv(2)
        ..atkFou = 1000
        ..equip1 = getNP100Equip(),
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
        ..equip1 = SvtEquipData(
          ce: db.gameData.craftEssencesById[9404120], // 20 star on entry
          lv: 100,
          limitBreak: true,
        ),
      PlayerSvtData.id(504600)
        ..lv = 80
        ..equip1 = getNP100Equip(),
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
        ..equip1 = getNP100Equip(),
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
        ..equip1 = getNP100Equip(),
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
        ..equip1 = SvtEquipData(
          ce: db.gameData.craftEssencesById[9400730], // 500 Year
          lv: 100,
          limitBreak: true,
        ),
      PlayerSvtData.id(504400)
        ..lv = 90
        ..tdLv = 5
        ..equip1 = getNP100Equip(),
      PlayerSvtData.id(500300)..lv = 90,
    ];
    final battle = BattleData();
    await battle.init(db.gameData.questPhases[9300040603]!, setting, null);

    final chenGong = battle.onFieldAllyServants[1]!;
    expect(battle.canSelectNp(1), true);
    expect(chenGong.hp, 11210);

    await battle.playerTurn([CombatAction(chenGong, chenGong.getNPCard()!)]);

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
        ..equip1 = getNP100Equip(),
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
    await battle.playerTurn([CombatAction(archtypeEarth, archtypeEarth.getNPCard()!)]);

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
        ..equip1 = SvtEquipData(
          ce: db.gameData.craftEssencesById[9405160], // crane event point buff ce
          lv: 100,
          limitBreak: true,
        ),
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    final questIndivs = quest.questIndividuality;
    questIndivs.add(NiceTrait(id: 94000119));
    quest.phaseIndividuality = null;
    quest.individuality = questIndivs;

    battle.options.pointBuffs = {
      0: EventPointBuff(
        id: 0,
        funcIds: [6912],
        eventPoint: 0,
        name: '',
        icon: '',
        background: ItemBGType.zero,
        value: 100,
      ),
      1: EventPointBuff(
        id: 1,
        funcIds: [6913],
        eventPoint: 0,
        name: '',
        icon: '',
        background: ItemBGType.zero,
        value: 200,
      ),
    };

    await battle.init(quest, setting, null);

    final archtypeEarth = battle.onFieldAllyServants[0]!;
    final enemy1 = battle.onFieldEnemies[0]!;
    final previousHp1 = enemy1.hp;
    await battle.playerTurn([CombatAction(archtypeEarth, archtypeEarth.getCards()[0])]);

    expect(previousHp1 - enemy1.hp, 2659);

    final previousHp2 = enemy1.hp;
    await battle.playerTurn([CombatAction(archtypeEarth, archtypeEarth.getCards()[2])]);

    expect(previousHp2 - enemy1.hp, 4062);
  });

  test('Imperial Consort of the Heavenly Emperor', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(502600)
        ..lv = 80
        ..commandCodes = [null, db.gameData.commandCodesById[8400770], null, null, null],
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final eliz = battle.onFieldAllyServants[0]!;
    final enemy1 = battle.onFieldEnemies[0]!;
    final previousHp1 = enemy1.hp;
    await battle.playerTurn([CombatAction(eliz, eliz.getCards()[2]..critical = true)]);

    expect(previousHp1 - enemy1.hp, 4256);

    await battle.activateSvtSkill(0, 1);
    final previousHp2 = enemy1.hp;
    await battle.playerTurn([CombatAction(eliz, eliz.getCards()[1]..critical = true)]);

    expect(previousHp2 - enemy1.hp, 5533 + 300); // 300 burn damage
  });

  test('Super Buyan passive, call functionAttackAfter after NP', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(1001300)
        ..lv = 90
        ..tdLv = 1,
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
        ..equip1 = getNP100Equip(),
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
        ..equip1 = SvtEquipData(
          ce: db.gameData.craftEssencesById[9405550], // The Dwarf Tailor (debuff immune once)
          lv: 15,
          limitBreak: true,
        ),
      PlayerSvtData.id(1101100)..lv = 90, // avenger
      PlayerSvtData.id(901100)
        ..lv = 90
        ..equip1 = SvtEquipData(
          ce: db.gameData.craftEssencesById[9405550], // The Dwarf Tailor (debuff immune once)
          lv: 15,
          limitBreak: true,
        ),
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

  test('Hokusai\'s functionNpAttack happens after NP', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(2500200)
        ..lv = 90
        ..tdLv = 3
        ..skillLvs = [9, 9, 9]
        ..setSkillStrengthenLvs([1, 1, 2])
        ..equip1 = getNP100Equip(),
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
    expect(battle.criticalStars, moreOrLessEquals(14.5, epsilon: 0.001)); // end of Turn 10 star if everyone full health

    await battle.activateSvtSkill(1, 0); // this has hp drain
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

    expect(aoko.np, 4121); // test AoE card with Mage of Flowers does not stack, also test transformSvt adds new passive
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
        ..equip1 = SvtEquipData(
          ce: db.gameData.craftEssencesById[9400340], // Kaleidoscope
          limitBreak: true,
        ),
      PlayerSvtData.id(603700) // Kama
        ..lv = 120
        ..tdLv = 5
        ..cardStrengthens = [500, 500, 500, 500, 500]
        ..commandCodes = [db.gameData.commandCodesById[8400650], null, null, null, null],
      PlayerSvtData.id(901400)..skillLvs = [10, 5, 10], // swimsuit Skadi
      PlayerSvtData.id(503900)..equip1 = SvtEquipData(ce: db.gameData.craftEssencesById[9302920]), // Skadi with bond CE
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
    battle.delegate?.damageRandom = (random) async => [171908, 54773][count++];

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

  test('Append 5 & transformSvt', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(304800)
        ..limitCount = 0
        ..skillLvs = [10, 10, 10]
        ..appendLvs = [10, 10, 10, 10, 10],
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final maqin = battle.onFieldAllyServants[0]!;
    await battle.activateSvtSkill(0, 0);
    expect(maqin.skillInfoList[0].chargeTurn, 5); // her default is 6, so count in append should be 5

    await battle.resetPlayerSkillCD(isMysticCode: false, svt: maqin);
    await battle.activateSvtSkill(0, 0);
    expect(maqin.skillInfoList[0].chargeTurn, 6);

    await battle.activateSvtSkill(0, 1);
    expect(maqin.skillInfoList[1].chargeTurn, 4);
    await battle.activateSvtSkill(0, 2);
    expect(maqin.skillInfoList[2].chargeTurn, 4);

    await battle.resetPlayerSkillCD(isMysticCode: false, svt: maqin);
    await battle.activateSvtSkill(0, 0);
    expect(maqin.skillInfoList[0].chargeTurn, 6);
    await battle.activateSvtSkill(0, 1);
    expect(maqin.skillInfoList[1].chargeTurn, 5);
    await battle.activateSvtSkill(0, 2);
    expect(maqin.skillInfoList[2].chargeTurn, 5);
  });

  test('hitting invincible enemy', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(2800100)
        ..tdLv = 1
        ..lv = 1
        ..atkFou = 0,
      PlayerSvtData.id(1100600)
        ..tdLv = 1
        ..lv = 1
        ..atkFou = 0
        ..skillLvs = [1, 1, 1],
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final enemy = battle.onFieldEnemies[0]!;
    expect(await enemy.getBuffValue(battle, BuffAction.defence), 1000);

    await battle.activateSvtSkill(1, 2);
    expect(await enemy.getBuffValue(battle, BuffAction.defence), 800);
    final previousHp = enemy.hp;

    final oberon = battle.onFieldAllyServants[0]!;
    final salieri = battle.onFieldAllyServants[1]!;
    oberon.np = 10000;
    await battle.playerTurn([
      CombatAction(oberon, oberon.getNPCard()!),
      CombatAction(salieri, salieri.getCards()[0]),
      CombatAction(salieri, salieri.getCards()[1]),
    ]);

    expect(await enemy.getBuffValue(battle, BuffAction.defence), 1000);
    expect(previousHp - enemy.hp, 2753);
  });

  test('buffScript IndvAddBuffPassive', () async {
    final List<PlayerSvtData?> setting = [
      PlayerSvtData.id(2300600),
      PlayerSvtData.id(1101900), // alignment balanced, should not trigger bb's passive
      PlayerSvtData.id(1101900),
      PlayerSvtData.id(703400)
        ..equip1 = SvtEquipData(ce: db.gameData.craftEssencesById[9303870]), // sp against good for party if on field
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, MysticCodeData());

    final bb = battle.onFieldAllyServants[0]!;
    final svtWithoutPassive = battle.onFieldAllyServants[2]!;
    final defenceWithoutPassive = await bb.getBuffValue(battle, BuffAction.atk, opponent: svtWithoutPassive);
    expect(defenceWithoutPassive, 1000);

    battle.delegate = BattleDelegate();
    battle.delegate?.replaceMember = (onFieldSvts, backupSvts) async {
      return Tuple2(onFieldSvts[1]!, backupSvts[0]!);
    };
    await battle.activateMysticCodeSkill(2);
    final svtWithPassive = battle.onFieldAllyServants[2]!;
    final defenceWithPassive = await bb.getBuffValue(battle, BuffAction.atk, opponent: svtWithPassive);
    expect(defenceWithPassive, 1100);
  });

  test('CommandCode are active skills', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(703300)
        ..lv = 90
        ..tdLv = 5
        ..skillLvs = [10, 10, 10]
        ..commandCodes = [db.gameData.commandCodesById[8400950], null, null, null, null],
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final arjuna = battle.onFieldAllyServants[0]!;
    await battle.activateSvtSkill(0, 0);
    final enemy = battle.onFieldEnemies[0]!;
    final previousHp = enemy.hp;

    await battle.playerTurn([CombatAction(arjuna, arjuna.getCards()[0])]);
    expect(previousHp - enemy.hp, 7000);
  });

  test('KazuraDrop related tests', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(1001800)
        ..lv = 90
        ..tdLv = 5
        ..skillLvs = [10, 10, 10],
      PlayerSvtData.id(1001800)
        ..lv = 90
        ..tdLv = 5
        ..skillLvs = [10, 10, 10],
      PlayerSvtData.id(2501600), // non Sakura series
      PlayerSvtData.id(1001800)
        ..lv = 90
        ..tdLv = 5
        ..skillLvs = [10, 10, 10],
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, MysticCodeData());

    final kazura1 = battle.onFieldAllyServants[0]!;
    final kazura2 = battle.onFieldAllyServants[1]!;
    expect(kazura1.np, 0);
    await battle.activateSvtSkill(0, 1);
    expect(kazura1.np, 10000);

    battle.delegate = BattleDelegate();
    battle.delegate?.replaceMember = (onFieldSvts, backupSvts) async {
      return Tuple2(onFieldSvts[2]!, backupSvts[0]!);
    };
    await battle.activateMysticCodeSkill(2);

    expect(kazura2.np, 0);
    await battle.activateSvtSkill(1, 1);
    expect(kazura2.np, 15000);

    expect(kazura1.logicalClassId, SvtClass.alterego.value);
    final traitIdsBefore1 = kazura1.getTraits().map((niceTrait) => niceTrait.id).toList();
    expect(traitIdsBefore1.contains(ConstData.classInfo[SvtClass.alterego.value]!.individuality), true);
    expect(traitIdsBefore1.contains(ConstData.classInfo[SvtClass.saber.value]!.individuality), false);
    for (final relationTraitId in ConstData.classInfo[SvtClass.saber.value]!.relationSvtIndividuality) {
      expect(traitIdsBefore1.contains(relationTraitId), false);
    }
    await battle.activateSvtSkill(0, 2);
    expect(kazura1.logicalClassId, SvtClass.saber.value);
    final traitIdsAfter1 = kazura1.getTraits().map((niceTrait) => niceTrait.id).toList();
    expect(traitIdsAfter1.contains(ConstData.classInfo[SvtClass.alterego.value]!.individuality), false);
    expect(traitIdsAfter1.contains(ConstData.classInfo[SvtClass.saber.value]!.individuality), true);
    for (final relationTraitId in ConstData.classInfo[SvtClass.saber.value]!.relationSvtIndividuality) {
      expect(traitIdsAfter1.contains(relationTraitId), true);
    }

    battle.enemyTargetIndex = 1;
    expect(kazura2.logicalClassId, SvtClass.alterego.value);
    final traitIdsBefore2 = kazura2.getTraits().map((niceTrait) => niceTrait.id).toList();
    expect(traitIdsBefore2.contains(ConstData.classInfo[SvtClass.alterego.value]!.individuality), true);
    expect(traitIdsBefore2.contains(ConstData.classInfo[SvtClass.caster.value]!.individuality), false);
    for (final relationTraitId in ConstData.classInfo[SvtClass.caster.value]!.relationSvtIndividuality) {
      expect(traitIdsBefore2.contains(relationTraitId), false);
    }
    await battle.activateSvtSkill(1, 2);
    expect(kazura2.logicalClassId, SvtClass.caster.value);
    final traitIdsAfter2 = kazura2.getTraits().map((niceTrait) => niceTrait.id).toList();
    expect(traitIdsAfter2.contains(ConstData.classInfo[SvtClass.alterego.value]!.individuality), false);
    expect(traitIdsAfter2.contains(ConstData.classInfo[SvtClass.caster.value]!.individuality), true);
    for (final relationTraitId in ConstData.classInfo[SvtClass.caster.value]!.relationSvtIndividuality) {
      expect(traitIdsAfter2.contains(relationTraitId), true);
    }

    battle.enemyTargetIndex = 0;
    final enemy = battle.onFieldEnemies[0]!;

    // test Kazura's passive
    final previousHp1 = enemy.hp;
    await battle.playerTurn([CombatAction(kazura1, kazura1.getCards()[0])]);
    expect(previousHp1 - enemy.hp, 4780);

    final previousHp2 = enemy.hp;
    await battle.playerTurn([CombatAction(kazura2, kazura2.getCards()[0])]);
    expect(previousHp2 - enemy.hp, 2458);

    // test start of turn effects
    await battle.activateSvtSkill(0, 0);
    await battle.activateSvtSkill(1, 0);
    await battle.skipTurn();
    final previousHp3 = enemy.hp;
    await battle.playerTurn([CombatAction(kazura1, kazura1.getCards()[0])]);
    expect(previousHp3 - enemy.hp, 1821);
  });

  test('KazuraDrop skill 2 reduce cd', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(1001800)
        ..lv = 90
        ..tdLv = 5
        ..skillLvs = [10, 10, 10],
      PlayerSvtData.id(2501600), // non Sakura series
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, MysticCodeData());

    final kazura = battle.onFieldAllyServants[0]!;
    await battle.activateSvtSkill(0, 0);
    expect(kazura.skillInfoList[0].chargeTurn, 6);
    await battle.activateSvtSkill(0, 1);
    expect(kazura.skillInfoList[0].chargeTurn, 5);
  });

  group('Summer Eresh related tests', () {
    test('bond & starting position & dmgBattlePoint', () async {
      final List<PlayerSvtData?> setting = [
        PlayerSvtData.id(3300200)..lv = 90,
        PlayerSvtData.id(3300200)
          ..lv = 90
          ..supportType = SupportSvtType.friend,
        null,
        PlayerSvtData.id(3300200)..lv = 90,
      ];
      final battle = BattleData();
      final quest = db.gameData.questPhases[9300040603]!;
      await battle.init(quest, setting, null);

      final eresh1 = battle.onFieldAllyServants[0]!;
      final eresh2 = battle.onFieldAllyServants[1]!;
      final eresh3 = battle.onFieldAllyServants[2]!;

      expect(eresh1.curBattlePoints[3300200], 10);
      expect(eresh2.curBattlePoints[3300200], null);
      expect(eresh3.curBattlePoints[3300200], 5);

      eresh1.np = 10000;
      eresh2.np = 10000;
      eresh3.np = 10000;

      final enemy1 = battle.onFieldEnemies[0]!;
      final previousHp1 = enemy1.hp;
      await battle.playerTurn([CombatAction(eresh1, eresh1.getNPCard()!)]);
      expect(previousHp1 - enemy1.hp, 23291);

      final enemy2 = battle.onFieldEnemies[0]!;
      final previousHp2 = enemy2.hp;
      await battle.playerTurn([CombatAction(eresh2, eresh2.getNPCard()!)]);
      expect(previousHp2 - enemy2.hp, 19432);

      final enemy3 = battle.onFieldEnemies[0]!;
      final previousHp3 = enemy3.hp;
      await battle.playerTurn([CombatAction(eresh3, eresh3.getNPCard()!)]);
      expect(previousHp3 - enemy3.hp, 21362);
    });

    test('how points can be added', () async {
      final List<PlayerSvtData?> setting = [
        PlayerSvtData.id(3300200)
          ..lv = 1
          ..tdLv = 1
          ..atkFou = 0,
        PlayerSvtData.id(2500900), // dark Koyan for OC + 2
        PlayerSvtData.id(304000), // summer lambda for shoreline
      ];
      final battle = BattleData();
      final quest = db.gameData.questPhases[9300040603]!;
      await battle.init(quest, setting, null);
      const bpId = 3300200;

      final eresh = battle.onFieldAllyServants[0]!;
      expect(eresh.curBattlePoints[bpId], 10);
      expect(eresh.determineBattlePointPhase(bpId), 2);

      expect(battle.isFirstSkillInTurn, true);
      await battle.activateSvtSkill(0, 0);
      expect(eresh.curBattlePoints[3300200], 15); // + 3 (skill) + 2 (first use this turn)
      expect(eresh.determineBattlePointPhase(bpId), 2);

      await battle.activateSvtSkill(2, 1); // add shoreline
      expect(eresh.curBattlePoints[3300200], 25); // + 10 shoreline
      expect(eresh.determineBattlePointPhase(bpId), 3);

      eresh.np = 10000;
      await battle.playerTurn([
        CombatAction(eresh, eresh.getNPCard()!),
        CombatAction(eresh, eresh.getCards()[0]),
        CombatAction(eresh, eresh.getCards()[1]),
      ]);
      expect(eresh.curBattlePoints[3300200], 37); // brave chain + 3 + 3 + 6
      expect(eresh.determineBattlePointPhase(bpId), 4);

      await battle.activateSvtSkill(0, 1);
      expect(eresh.curBattlePoints[3300200], 42); // + 3 (skill) + 2 (first use this turn)
      expect(eresh.determineBattlePointPhase(bpId), 5);

      await battle.activateSvtSkill(1, 1); // add OC 2
      eresh.np = 30000;
      await battle.playerTurn([
        CombatAction(eresh, eresh.getNPCard()!),
        CombatAction(eresh, eresh.getCards()[0]),
        CombatAction(eresh, eresh.getCards()[1]),
      ]);
      expect(eresh.curBattlePoints[3300200], 74); // OC5 + 20 brave chain + 3 + 3 + 6
      expect(eresh.determineBattlePointPhase(bpId), 8);

      await battle.activateSvtSkill(1, 0); // skill before summer eresh
      await battle.activateSvtSkill(0, 2);
      expect(eresh.curBattlePoints[3300200], 77); // + 3 skill
      expect(eresh.determineBattlePointPhase(bpId), 8);

      await battle.playerTurn([
        CombatAction(eresh, eresh.getCards()[0]),
        CombatAction(eresh, eresh.getCards()[1]),
        CombatAction(eresh, eresh.getCards()[2]),
      ]);
      expect(eresh.curBattlePoints[3300200], 92); // full brave chain + 15
      expect(eresh.determineBattlePointPhase(bpId), 10);

      await battle.playerTurn([
        CombatAction(eresh, eresh.getCards()[0]),
        CombatAction(eresh, eresh.getCards()[1]),
        CombatAction(eresh, eresh.getCards()[2]),
      ]);
      expect(eresh.curBattlePoints[3300200], 107); // full brave chain + 15
      expect(eresh.determineBattlePointPhase(bpId), 10);
    });

    test('only valid command card add points', () async {
      final List<PlayerSvtData?> setting = [
        PlayerSvtData.id(3300200),
        PlayerSvtData.id(2501200), // Cnoc for arts seal
      ];
      final battle = BattleData();
      final quest = db.gameData.questPhases[9300040603]!;
      await battle.init(quest, setting, null);
      const bpId = 3300200;

      final eresh = battle.onFieldAllyServants[0]!;
      expect(eresh.curBattlePoints[bpId], 10);
      expect(eresh.determineBattlePointPhase(bpId), 2);

      final cnoc = battle.onFieldAllyServants[1]!;

      // do four times since Eresh has debuff immune
      for (int idx = 0; idx < 4; idx += 1) {
        await battle.activateSvtSkill(1, 2); // arts seal
        await battle.resetPlayerSkillCD(isMysticCode: false, svt: cnoc);
      }

      eresh.np = 10000;
      await battle.playerTurn([
        CombatAction(eresh, eresh.getNPCard()!),
        CombatAction(eresh, eresh.getCards()[0]),
        CombatAction(eresh, eresh.getCards()[1]),
      ]);
      expect(eresh.curBattlePoints[3300200], 13); // attempt N Q A Ex, only Q valid
      expect(eresh.determineBattlePointPhase(bpId), 2);
    });

    test('commandSpell & mysticCode', () async {
      final List<PlayerSvtData?> setting = [
        PlayerSvtData.id(3300200),
        PlayerSvtData.id(901400),
        PlayerSvtData.id(901400),
        PlayerSvtData.id(901400),
      ];
      final battle = BattleData();
      final quest = db.gameData.questPhases[9300040603]!;
      await battle.init(quest, setting, MysticCodeData());
      const bpId = 3300200;

      final eresh = battle.onFieldAllyServants[0]!;
      expect(eresh.curBattlePoints[bpId], 10);
      expect(eresh.determineBattlePointPhase(bpId), 2);

      await battle.activateSvtSkill(1, 1); // other's skills do not affect Eresh
      expect(eresh.curBattlePoints[bpId], 10);
      expect(eresh.determineBattlePointPhase(bpId), 2);

      await battle.activateSvtSkill(1, 2); // other's skills do not affect Eresh
      expect(eresh.curBattlePoints[bpId], 10);
      expect(eresh.determineBattlePointPhase(bpId), 2);

      await battle.activateMysticCodeSkill(0); // mystic add 5 points even for ptAll buffs
      expect(eresh.curBattlePoints[bpId], 15);
      expect(eresh.determineBattlePointPhase(bpId), 2);

      await battle.commandSpellReleaseNP(); // command spell add 10 points
      expect(eresh.curBattlePoints[bpId], 25);
      expect(eresh.determineBattlePointPhase(bpId), 3);

      await battle.commandSpellRepairHp(); // command spell add 10 points
      expect(eresh.curBattlePoints[bpId], 35);
      expect(eresh.determineBattlePointPhase(bpId), 4);

      // just realized this test is useless since current implementation doesn't select any svts as actual targets
      // for replace member. Kept for safety measures on this mechanism I guess
      battle.delegate = BattleDelegate();
      battle.delegate?.replaceMember = (onFieldSvts, backupSvts) async {
        return Tuple2(onFieldSvts[0]!, backupSvts[0]!);
      };
      await battle.activateMysticCodeSkill(2);
      expect(eresh.curBattlePoints[bpId], 35);
      expect(eresh.determineBattlePointPhase(bpId), 4);
    });

    test('mysticCode party gainStar', () async {
      final List<PlayerSvtData?> setting = [PlayerSvtData.id(3300200), PlayerSvtData.id(2501200)];
      final battle = BattleData();
      final quest = db.gameData.questPhases[9300040603]!;
      await battle.init(quest, setting, MysticCodeData()..mysticCode = db.gameData.mysticCodes[130]);
      const bpId = 3300200;

      final eresh = battle.onFieldAllyServants[0]!;
      expect(eresh.curBattlePoints[bpId], 10);
      expect(eresh.determineBattlePointPhase(bpId), 2);

      await battle.activateMysticCodeSkill(2); // mystic code +5
      expect(eresh.curBattlePoints[bpId], 15);
      expect(eresh.determineBattlePointPhase(bpId), 2);

      battle.playerTargetIndex = 1; // not eresh
      await battle.activateMysticCodeSkill(1); // gainStar on party, so still add points
      expect(eresh.curBattlePoints[bpId], 20);
      expect(eresh.determineBattlePointPhase(bpId), 3);
    });

    test('mysticCode shuffle', () async {
      final List<PlayerSvtData?> setting = [
        PlayerSvtData.id(3300200),
        PlayerSvtData.id(3300200),
        PlayerSvtData.id(504400),
      ];
      final battle = BattleData();
      final quest = db.gameData.questPhases[9300040603]!;
      await battle.init(quest, setting, MysticCodeData()..mysticCode = db.gameData.mysticCodes[30]);
      const bpId = 3300200;

      final eresh1 = battle.onFieldAllyServants[0]!;
      final eresh2 = battle.onFieldAllyServants[1]!;
      expect(eresh1.curBattlePoints[bpId], 10);
      expect(eresh1.determineBattlePointPhase(bpId), 2);
      expect(eresh2.curBattlePoints[bpId], 10);
      expect(eresh2.determineBattlePointPhase(bpId), 2);

      battle.playerTargetIndex = 1; // not eresh
      await battle.activateMysticCodeSkill(2); // mystic code +5 only for first alive ally
      expect(eresh1.curBattlePoints[bpId], 15);
      expect(eresh1.determineBattlePointPhase(bpId), 2);
      expect(eresh2.curBattlePoints[bpId], 10);
      expect(eresh2.determineBattlePointPhase(bpId), 2);

      await battle.resetPlayerSkillCD(isMysticCode: true, svt: null);
      final chenGong = battle.onFieldAllyServants[2]!;
      chenGong.np = 10000;
      await battle.playerTurn([CombatAction(chenGong, chenGong.getNPCard()!)]); // kill first eresh

      expect(eresh2.curBattlePoints[bpId], 10);
      expect(eresh2.determineBattlePointPhase(bpId), 2);
      await battle.activateMysticCodeSkill(2); // mystic code +5 only for first alive ally
      expect(eresh2.curBattlePoints[bpId], 15);
      expect(eresh2.determineBattlePointPhase(bpId), 2);
    });

    test('passive avoidState vs Passive debuff', () async {
      final List<PlayerSvtData?> setting = [
        PlayerSvtData.id(3300200),
        PlayerSvtData.id(1101900), // avenger
        PlayerSvtData.id(1101900), // avenger
        PlayerSvtData.id(1101900), // avenger
      ];
      final battle = BattleData();
      final quest = db.gameData.questPhases[9300040603]!;
      await battle.init(quest, setting, null);

      final eresh = battle.onFieldAllyServants[0]!;
      final avoidStates = collectBuffsPerAction(eresh.battleBuff.validBuffs, BuffAction.avoidState);
      expect(avoidStates.length, 2);
      expect(avoidStates[0].count, 3);
    });
  });

  group('Battle Popup Related Funcs', () {
    test('act set select', () async {
      final List<PlayerSvtData?> setting = [
        PlayerSvtData.id(101000)..setSkillStrengthenLvs([1, 1, 2]), // Saber Eliz
      ];
      final battle = BattleData();
      final quest = db.gameData.questPhases[9300040603]!;
      await battle.init(quest, setting, MysticCodeData());

      final eliz = battle.onFieldAllyServants[0]!;

      int count = 0;
      battle.delegate = BattleDelegate();
      battle.delegate?.actWeight = (_actor) async => [4, 0, 5][count++]; // atk up, gain star, skip

      eliz.np = 10000;
      await battle.activateSvtSkill(0, 2);
      expect(await eliz.getBuffValue(battle, BuffAction.atk), 1500);
      expect(battle.criticalStars, moreOrLessEquals(0, epsilon: 0.1));

      eliz.np = 10000;
      await battle.resetPlayerSkillCD(isMysticCode: false, svt: eliz);
      await battle.activateSvtSkill(0, 2);
      expect(await eliz.getBuffValue(battle, BuffAction.atk), 1500);
      expect(battle.criticalStars, moreOrLessEquals(0, epsilon: 0.1));

      eliz.np = 10000;
      await battle.resetPlayerSkillCD(isMysticCode: false, svt: eliz);
      await battle.activateSvtSkill(0, 2);
      expect(await eliz.getBuffValue(battle, BuffAction.atk), 1500);
      expect(battle.criticalStars, moreOrLessEquals(50, epsilon: 0.1));
    });

    test('replace member', () async {
      final List<PlayerSvtData?> setting = [
        PlayerSvtData.id(3300200),
        PlayerSvtData.id(901400),
        PlayerSvtData.id(901400),
        PlayerSvtData.id(901400),
      ];
      final battle = BattleData();
      final quest = db.gameData.questPhases[9300040603]!;
      await battle.init(quest, setting, MysticCodeData());

      final pos1svt = battle.onFieldAllyServants[0]!;
      final backupSvt = battle.backupAllyServants[0]!;

      battle.delegate = BattleDelegate();
      battle.delegate?.replaceMember = (onFieldSvts, backupSvts) async {
        return Tuple2(onFieldSvts[0]!, backupSvts[0]!);
      };
      await battle.activateMysticCodeSkill(2);
      expect(battle.onFieldAllyServants[0]!, backupSvt);
      expect(battle.backupAllyServants[0]!, pos1svt);
    });

    test('skill act select', () async {
      final List<PlayerSvtData?> setting = [
        PlayerSvtData.id(2501100), // kuku
        PlayerSvtData.id(604200), // Koyan
      ];
      final battle = BattleData();
      final quest = db.gameData.questPhases[9300040603]!;
      await battle.init(quest, setting, MysticCodeData());

      final kuku = battle.onFieldAllyServants[0]!;
      final btn = kuku.skillInfoList.first.skillScript!.SelectAddInfo![0].btn;
      expect(btn.first.conds.first.cond, SkillScriptCond.none);
      expect(btn.last.conds.first.cond, SkillScriptCond.starHigher);
      expect(btn.last.conds.first.value, 10);

      int count = 0;
      battle.delegate = BattleDelegate();
      battle.delegate?.skillActSelect = (_actor) async => [1, 0, 1][count++]; // consume 10, don't, consume 10

      await battle.activateSvtSkill(1, 1);
      expect(battle.criticalStars, moreOrLessEquals(20, epsilon: 0.1));

      await battle.activateSvtSkill(0, 0);
      final attack = await kuku.getBuffValue(battle, BuffAction.atk);
      expect(attack, 1500);
      expect(battle.criticalStars, moreOrLessEquals(10, epsilon: 0.1));

      await battle.activateSvtSkill(0, 1);
      expect(kuku.np, 5000);
      expect(battle.criticalStars, moreOrLessEquals(10, epsilon: 0.1));

      await battle.activateSvtSkill(0, 2);
      final npDmg = await kuku.getBuffValue(battle, BuffAction.npdamage);
      expect(npDmg, 300);
      expect(battle.criticalStars, moreOrLessEquals(0, epsilon: 0.1));
    });

    test('tailored execution can activate', () async {
      final List<PlayerSvtData?> setting = [
        PlayerSvtData.id(100500), // Nero
      ];
      final battle = BattleData();
      final quest = db.gameData.questPhases[9300040603]!;
      await battle.init(quest, setting, MysticCodeData());

      final nero = battle.onFieldAllyServants[0]!;

      int count = 0;
      battle.delegate = BattleDelegate();
      battle.delegate?.canActivate = (_actor) async => [true, false, false, true][count++]; // act, miss, miss, act
      battle.options.tailoredExecution = true;

      expect(await nero.getBuffValue(battle, BuffAction.atk), 1000);
      expect(await nero.getBuffValue(battle, BuffAction.defence), 1000);

      await battle.activateSvtSkill(0, 1);
      expect(await nero.getBuffValue(battle, BuffAction.atk), 1440);
      expect(await nero.getBuffValue(battle, BuffAction.defence), 1000);

      await battle.resetPlayerSkillCD(isMysticCode: false, svt: nero);
      await battle.activateSvtSkill(0, 1);
      expect(await nero.getBuffValue(battle, BuffAction.atk), 1440);
      expect(await nero.getBuffValue(battle, BuffAction.defence), 1440);
    });

    test('td type change', () async {
      final List<PlayerSvtData?> setting = [
        PlayerSvtData.id(200100)..setSkillStrengthenLvs([1, 1, 3]), // Emiya
        PlayerSvtData.id(2300600), // new summer BB
      ];
      final battle = BattleData();
      final quest = db.gameData.questPhases[9300040603]!;
      await battle.init(quest, setting, MysticCodeData());

      final emiya = battle.onFieldAllyServants[0]!;

      final nps = emiya.niceSvt!.noblePhantasms;
      expect(nps.length, 4);
      expect(nps.first.script!.tdTypeChangeIDs!.first, 200198);
      expect(nps.first.script!.excludeTdChangeTypes!.first, 3);

      int count = 0;
      battle.delegate = BattleDelegate();
      battle.delegate?.tdTypeChange = (_actor, _list) async => [
        CardType.arts.value, // Emiya select arts
        CardType.buster.value, // Emiya select buster
        1, // summer bb select dmg type
        2, // summer bb select support type
      ][count++];

      expect(emiya.getNPCard()!.cardType, CardType.buster);

      await battle.activateSvtSkill(0, 2);
      expect(emiya.getNPCard()!.cardType, CardType.arts);

      await battle.skipTurn(); // skip so tdTypeChangeBuff expires
      await battle.resetPlayerSkillCD(isMysticCode: false, svt: emiya);
      expect(emiya.getNPCard()!.cardType, CardType.buster);
      await battle.activateSvtSkill(0, 2);
      expect(emiya.getNPCard()!.cardType, CardType.buster);

      final bb = battle.onFieldAllyServants[1]!;
      expect(bb.getNPCard()!.cardType, CardType.arts);
      expect(bb.getNPCard()!.td?.damageType, TdEffectFlag.attackEnemyAll);

      await battle.activateSvtSkill(1, 2);
      expect(bb.getNPCard()!.cardType, CardType.arts);
      expect(bb.getNPCard()!.td?.damageType, TdEffectFlag.attackEnemyAll);

      for (int idx = 0; idx < 3; idx += 1) {
        await battle.skipTurn(); // skip so tdTypeChangeBuff expires
      }
      await battle.resetPlayerSkillCD(isMysticCode: false, svt: bb);
      expect(bb.getNPCard()!.cardType, CardType.arts);
      expect(bb.getNPCard()!.td?.damageType, TdEffectFlag.attackEnemyAll);
      await battle.activateSvtSkill(1, 2);
      expect(bb.getNPCard()!.cardType, CardType.arts);
      expect(bb.getNPCard()!.td?.damageType, TdEffectFlag.support);
    });
  });

  test('Event indiv checks old format & new format', () async {
    final List<PlayerSvtData> setting = [PlayerSvtData.id(703300)];
    final battle1 = BattleData();
    final quest1 = await AtlasApi.questPhase(94087109, 1);
    await battle1.init(quest1!, setting, null);

    expect(battle1.getQuestIndividuality().map((trait) => trait.id).contains(94000146), true);
    expect(battle1.getQuestIndividuality().map((trait) => trait.id).contains(2038), true);

    final battle2 = BattleData();
    final quest2 = await AtlasApi.questPhase(94101308, 1);
    await battle2.init(quest2!, setting, null);

    expect(battle2.getQuestIndividuality().map((trait) => trait.id).contains(94000159), true);
    expect(battle2.getQuestIndividuality().map((trait) => trait.id).contains(2038), true);
  });

  test('Can clear wave using dot', () async {
    final List<PlayerSvtData> setting = [PlayerSvtData.id(1001000)];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9303070203]!;
    await battle.init(quest, setting, null);

    final enemy = battle.onFieldEnemies[1]!;
    enemy.hp = 2000;
    await battle.activateSvtSkill(0, 2);
    await battle.skipTurn();

    expect(enemy.hp, 0);
    expect(battle.waveCount, 2);
    expect(battle.nonnullEnemies.length, 1);
    expect(battle.nonnullEnemies.first.hp, 100357);
  });

  test('Caster Cu', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(502100)
        ..lv = 90
        ..setSkillStrengthenLvs([1, 1, 2]),
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9303070203]!;
    await battle.init(quest, setting, null);

    final cu = battle.onFieldAllyServants[0]!;
    expect(cu.hp, 12880);
    expect(cu.np, 0);

    await battle.activateSvtSkill(0, 2);
    await battle.skipTurn();

    expect(cu.hp, 3000);
    expect(cu.np, 8000);
  });

  test('Transform & other svt s classPassive', () async {
    final List<PlayerSvtData> setting = [
      PlayerSvtData.id(304800)
        ..limitCount = 0
        ..lv = 90
        ..equip1 = SvtEquipData(
          ce: db.gameData.craftEssencesById[9402750], // 50% np + 2 passives
          limitBreak: true,
        ),
      PlayerSvtData.id(1101100), // gives passives to all allies
      PlayerSvtData.id(2800100), // gives passives to all allies
    ];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final melusine = battle.onFieldAllyServants[0]!;
    expect(melusine.np, 5000);
    expect(melusine.battleBuff.getPassiveList().length, 6);

    await battle.activateSvtSkill(0, 2);

    expect(melusine.np, 15000);
    expect(melusine.battleBuff.getPassiveList().length, 6);
  });

  test('OverwriteSvtCardBuff - Phantas Moon', () async {
    final List<PlayerSvtData> setting = [PlayerSvtData.id(2800900)];
    final battle = BattleData();
    final quest = db.gameData.questPhases[9300040603]!;
    await battle.init(quest, setting, null);

    final phantasMoon = battle.onFieldAllyServants[0]!;
    final baseExtraCard = phantasMoon.getExtraCard()!;
    expect(baseExtraCard.cardType, CardType.extra);
    expect(baseExtraCard.cardDetail.damageRate, null);

    await battle.activateSvtSkill(0, 1);

    final updatedExtraCard = phantasMoon.getExtraCard()!;
    expect(updatedExtraCard.cardType, CardType.extra2);
    expect(updatedExtraCard.cardDetail.damageRate, 500);
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
      expect(
        checkSignedIndividualities2(
          myTraits: card.traits,
          requiredTraits: [NiceTrait(id: Trait.criticalHit.value)],
        ),
        true,
      );
    });

    // test('Combo related', () async {
    //   final List<PlayerSvtData?> setting = [
    //     PlayerSvtData.id(3300200),
    //     PlayerSvtData.id(3300200),
    //   ];
    //   final battle = BattleData();
    //   final quest = db.gameData.questPhases[9300040603]!;
    //   await battle.init(quest, setting, null);

    //   final actor1 = battle.onFieldAllyServants[0]!;
    //   final actor2 = battle.onFieldAllyServants[1]!;

    //   final comboWith3Cards = [
    //     CombatAction(actor1, actor1.getCards()[4]),
    //     CombatAction(actor1, actor1.getCards()[1]),
    //     CombatAction(actor1, actor1.getCards()[2]),
    //   ];
    //   expect(BattleData.isComboStart(comboWith3Cards, 0), true);
    //   expect(BattleData.isComboStart(comboWith3Cards, 1), false);
    //   expect(BattleData.isComboStart(comboWith3Cards, 2), false);
    //   expect(BattleData.isComboEnd(comboWith3Cards, 0), false);
    //   expect(BattleData.isComboEnd(comboWith3Cards, 1), false);
    //   expect(BattleData.isComboEnd(comboWith3Cards, 2), true);

    //   final comboAfterAnotherCard = [
    //     CombatAction(actor1, actor1.getNPCard()!),
    //     CombatAction(actor1, actor1.getCards()[1]),
    //     CombatAction(actor1, actor1.getCards()[2]),
    //   ];
    //   expect(BattleData.isComboStart(comboAfterAnotherCard, 0), false);
    //   expect(BattleData.isComboStart(comboAfterAnotherCard, 1), true);
    //   expect(BattleData.isComboStart(comboAfterAnotherCard, 2), false);
    //   expect(BattleData.isComboEnd(comboAfterAnotherCard, 0), false);
    //   expect(BattleData.isComboEnd(comboAfterAnotherCard, 1), false);
    //   expect(BattleData.isComboEnd(comboAfterAnotherCard, 2), true);

    //   final comboBeforeAnotherCard = [
    //     CombatAction(actor1, actor1.getCards()[2]),
    //     CombatAction(actor1, actor1.getCards()[1]),
    //     CombatAction(actor2, actor1.getCards()[2]),
    //   ];
    //   expect(BattleData.isComboStart(comboBeforeAnotherCard, 0), true);
    //   expect(BattleData.isComboStart(comboBeforeAnotherCard, 1), false);
    //   expect(BattleData.isComboStart(comboBeforeAnotherCard, 2), false);
    //   expect(BattleData.isComboEnd(comboBeforeAnotherCard, 0), false);
    //   expect(BattleData.isComboEnd(comboBeforeAnotherCard, 1), true);
    //   expect(BattleData.isComboEnd(comboBeforeAnotherCard, 2), false);

    //   final comboInterrupted = [
    //     CombatAction(actor1, actor1.getCards()[2]),
    //     CombatAction(actor2, actor1.getCards()[2]),
    //     CombatAction(actor1, actor1.getCards()[1]),
    //   ];
    //   expect(BattleData.isComboStart(comboInterrupted, 0), false);
    //   expect(BattleData.isComboStart(comboInterrupted, 1), false);
    //   expect(BattleData.isComboStart(comboInterrupted, 2), false);
    //   expect(BattleData.isComboEnd(comboInterrupted, 0), false);
    //   expect(BattleData.isComboEnd(comboInterrupted, 1), false);
    //   expect(BattleData.isComboEnd(comboInterrupted, 2), false);
    // });
  });
}
