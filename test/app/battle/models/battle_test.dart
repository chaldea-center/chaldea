import 'package:chaldea/app/battle/utils/buff_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/models/buff.dart';
import 'package:chaldea/app/battle/models/card_dmg.dart';
import 'package:chaldea/app/battle/models/command_card.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/models/gamedata/gamedata.dart';
import '../../../test_init.dart';

void main() async {
  await initiateForTest();

  // test without ui, [silent] must set to silent
  final data = await GameDataLoader.instance.reload(offline: true, silent: true);
  print('Data version: ${data?.version.dateTime.toString()}');

  db.gameData = data!;

  group('Combat integration', () {
    group('Altria (100100) vs Sky caster', () {
      final List<PlayerSvtData> altriaSettings = [
        PlayerSvtData(100100)
          ..skillStrengthenLvs = [1, 2, 1]
          ..npLv = 1
          ..npStrengthenLv = 2
          ..lv = 90
          ..atkFou = 0
          ..hpFou = 0
      ];

      test('NP 1 OC 1 no fou as base', () {
        final battle = BattleData();
        battle.init(db.gameData.questPhases[9300040603]!, altriaSettings,
            null); // this stage has a sky caster in wave 1 at index 1

        final altria = battle.targetedAlly!;
        altria.np = 10000;
        final npActions = [CombatAction(altria, altria.getNPCard()!)];

        final hpBeforeDamage = battle.onFieldEnemies[1]!.hp;
        battle.playerTurn(npActions);
        final hpAfterDamage = battle.onFieldEnemies[1]!.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(12542));
      });

      test('chainPos does not affect NP', () {
        final battle = BattleData();
        battle.init(db.gameData.questPhases[9300040603]!, altriaSettings, null);

        final altria = battle.targetedAlly!;
        altria.np = 10000;
        final npActions = [CombatAction(altria, altria.getCards()[4]), CombatAction(altria, altria.getNPCard()!)];

        final hpBeforeDamage = battle.onFieldEnemies[1]!.hp;
        battle.playerTurn(npActions);
        final hpAfterDamage = battle.onFieldEnemies[1]!.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(12542));
      });

      test('B A B EX', () {
        final battle = BattleData();
        battle.init(db.gameData.questPhases[9300040603]!, altriaSettings, null);

        final altria = battle.targetedAlly!;
        final busterArtsBuster = [
          CombatAction(altria, altria.getCards()[4]),
          CombatAction(altria, altria.getCards()[1]),
          CombatAction(altria, altria.getCards()[3]),
        ];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.onFieldEnemies[1]!;
        final hpBeforeDamage = skyCaster.hp;
        battle.playerTurn(busterArtsBuster);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(4180 + 3553 + 5435 + 6271));
        expect(altria.np, equals(1390)); // ex is overkill
        expect(battle.criticalStars, moreOrLessEquals(5.20, epsilon: 0.001));
      });

      test('with 1000 Fou & double Koyanskaya of Light', () {
        final List<PlayerSvtData> altriaWithDoubleKoyan = [
          PlayerSvtData(100100)
            ..skillStrengthenLvs = [1, 2, 1]
            ..npLv = 1
            ..npStrengthenLv = 2
            ..lv = 90
            ..atkFou = 1000
            ..hpFou = 0,
          PlayerSvtData(604200)
            ..skillStrengthenLvs = [1, 1, 1]
            ..npLv = 1
            ..npStrengthenLv = 1
            ..lv = 90
            ..atkFou = 0
            ..hpFou = 0,
          PlayerSvtData(604200)
            ..skillStrengthenLvs = [1, 1, 1]
            ..npLv = 1
            ..npStrengthenLv = 1
            ..lv = 90
            ..atkFou = 0
            ..hpFou = 0
        ];
        final battle = BattleData();
        battle.init(db.gameData.questPhases[9300040603]!, altriaWithDoubleKoyan, null);

        battle.activateSvtSkill(0, 0);
        battle.activateSvtSkill(0, 1);
        battle.activateSvtSkill(1, 0);
        battle.activateSvtSkill(1, 2);
        battle.activateSvtSkill(2, 0);
        battle.activateSvtSkill(2, 2);
        final altria = battle.targetedAlly!;
        final npActions = [CombatAction(altria, altria.getNPCard()!)];

        final skyCaster = battle.onFieldEnemies[1]!;
        final hpBeforeDamage = skyCaster.hp;
        battle.playerTurn(npActions);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(52388));
      });
    });

    group('Yang Guifei (2500400) vs Sky caster', () {
      final List<PlayerSvtData> yuyuSettings = [
        PlayerSvtData(2500400)
          ..skillStrengthenLvs = [2, 1, 1]
          ..npLv = 5
          ..npStrengthenLv = 1
          ..lv = 90
          ..atkFou = 1000
          ..hpFou = 1000
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true
      ];

      test('NP 5 OC 1 as base', () {
        final battle = BattleData();
        battle.init(db.gameData.questPhases[9300040603]!, yuyuSettings, null);

        final yuyu = battle.targetedAlly!;
        final npActions = [CombatAction(yuyu, yuyu.getNPCard()!)];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.targetedEnemy!;
        final hpBeforeDamage = skyCaster.hp;
        battle.playerTurn(npActions);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(52575));
        expect(yuyu.np, equals(914)); // 2 hits overkill
        expect(battle.criticalStars, moreOrLessEquals(3.20, epsilon: 0.001)); // include okuni's passive
      });

      test('A Q A EX', () {
        final battle = BattleData();
        battle.init(db.gameData.questPhases[9300040603]!, yuyuSettings, null);

        final yuyu = battle.targetedAlly!;
        final artsQuickArts = [
          CombatAction(yuyu, yuyu.getCards()[3]),
          CombatAction(yuyu, yuyu.getCards()[0]),
          CombatAction(yuyu, yuyu.getCards()[2]),
        ];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.targetedEnemy!;
        final hpBeforeDamage = skyCaster.hp;
        battle.playerTurn(artsQuickArts);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(3668 + 3528 + 5065 + 7161));
        expect(yuyu.np, equals(14246)); // A: no Overkill, Q: no Overkill, A: 1 hits Overkill, EX: 4 hits Overkill
        expect(battle.criticalStars, moreOrLessEquals(15.10, epsilon: 0.001)); // include okuni's passive
      });

      test('with 1000 Fou & double Altria Caster', () {
        final List<PlayerSvtData> yuyuWithDoubleCastoria = [
          PlayerSvtData(2500400)
            ..skillStrengthenLvs = [2, 1, 1]
            ..npLv = 5
            ..npStrengthenLv = 1
            ..lv = 90
            ..atkFou = 1000
            ..hpFou = 1000
            ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
            ..ceLv = 100
            ..ceLimitBreak = true,
          PlayerSvtData(504500)
            ..skillStrengthenLvs = [1, 1, 1]
            ..npLv = 1
            ..npStrengthenLv = 1
            ..lv = 90
            ..atkFou = 0
            ..hpFou = 0,
          PlayerSvtData(504500)
            ..skillStrengthenLvs = [1, 1, 1]
            ..npLv = 1
            ..npStrengthenLv = 1
            ..lv = 90
            ..atkFou = 0
            ..hpFou = 0
        ];
        final battle = BattleData();
        battle.init(db.gameData.questPhases[9300040603]!, yuyuWithDoubleCastoria, null);

        battle.activateSvtSkill(1, 0);
        battle.activateSvtSkill(1, 1);
        battle.activateSvtSkill(1, 2);
        battle.activateSvtSkill(2, 0);
        battle.activateSvtSkill(2, 1);
        battle.activateSvtSkill(2, 2);
        final yuyu = battle.targetedAlly!;
        final npActions = [CombatAction(yuyu, yuyu.getNPCard()!)];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.targetedEnemy!;
        final hpBeforeDamage = skyCaster.hp;
        battle.playerTurn(npActions);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(146896));
        expect(yuyu.np, equals(3227)); // 3 hits overkill
        expect(battle.criticalStars, moreOrLessEquals(3.50, epsilon: 0.001)); // include okuni's passive
      });
    });

    group('Izumo no Okuni (504900) vs Sky caster', () {
      final List<PlayerSvtData> okuniSettings = [
        PlayerSvtData(504900)
          ..skillStrengthenLvs = [1, 1, 1]
          ..npLv = 5
          ..npStrengthenLv = 1
          ..lv = 90
          ..atkFou = 1000
          ..hpFou = 1000
          ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
          ..ceLv = 100
          ..ceLimitBreak = true
      ];

      test('NP 5 OC 1 as base', () {
        final battle = BattleData();
        battle.init(db.gameData.questPhases[9300040603]!, okuniSettings, null);

        final okuni = battle.targetedAlly!;
        final npActions = [CombatAction(okuni, okuni.getNPCard()!)];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.targetedEnemy!;
        final hpBeforeDamage = skyCaster.hp;
        battle.playerTurn(npActions);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(56556));
        expect(okuni.np, equals(1435)); // 2 hits overkill
        expect(battle.criticalStars, moreOrLessEquals(14.19, epsilon: 0.001)); // include okuni's passive
      });

      test('Q B Q EX', () {
        final battle = BattleData();
        battle.init(db.gameData.questPhases[9300040603]!, okuniSettings, null);

        final okuni = battle.targetedAlly!;
        final quickBusterQuick = [
          CombatAction(okuni, okuni.getCards()[0]),
          CombatAction(okuni, okuni.getCards()[4]),
          CombatAction(okuni, okuni.getCards()[1]),
        ];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.targetedEnemy!;
        final hpBeforeDamage = skyCaster.hp;
        battle.playerTurn(quickBusterQuick);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(2356 + 5302 + 3299 + 5891));
        expect(okuni.np, equals(11968)); // A: no Overkill, Q: no Overkill, A: 1 hits Overkill, EX: 5 hits Overkill
        expect(battle.criticalStars, moreOrLessEquals(24.594, epsilon: 0.001)); // include okuni's passive
      });

      test('with 1000 Fou & double Scathach-Skadi (Caster)', () {
        final List<PlayerSvtData> okuniWithDoubleCba = [
          PlayerSvtData(504900)
            ..skillStrengthenLvs = [1, 1, 1]
            ..npLv = 5
            ..npStrengthenLv = 1
            ..lv = 90
            ..atkFou = 1000
            ..hpFou = 1000
            ..ce = db.gameData.craftEssencesById[9400340] // Kaleidoscope
            ..ceLv = 100
            ..ceLimitBreak = true,
          PlayerSvtData(503900)
            ..skillStrengthenLvs = [1, 1, 1]
            ..npLv = 1
            ..npStrengthenLv = 1
            ..lv = 90
            ..atkFou = 0
            ..hpFou = 0,
          PlayerSvtData(503900)
            ..skillStrengthenLvs = [1, 1, 1]
            ..npLv = 1
            ..npStrengthenLv = 1
            ..lv = 90
            ..atkFou = 0
            ..hpFou = 0
        ];
        final battle = BattleData();
        battle.init(db.gameData.questPhases[9300040603]!, okuniWithDoubleCba, null);

        battle.activateSvtSkill(1, 0);
        battle.activateSvtSkill(1, 2);
        battle.activateSvtSkill(2, 0);
        battle.activateSvtSkill(2, 2);
        final okuni = battle.targetedAlly!;
        final npActions = [CombatAction(okuni, okuni.getNPCard()!)];

        battle.enemyTargetIndex = 1;
        final skyCaster = battle.targetedEnemy!;
        final hpBeforeDamage = skyCaster.hp;
        battle.playerTurn(npActions);
        final hpAfterDamage = skyCaster.hp;

        expect(hpBeforeDamage - hpAfterDamage, equals(103687));
        expect(okuni.np, equals(2740)); // 6 hits overkill
        expect(battle.criticalStars, moreOrLessEquals(22.49, epsilon: 0.001)); // include okuni's passive
      });
    });

    test('Kama 3 turn loop & double Castoria', () {
      final List<PlayerSvtData> kamaWithDoubleCastoria = [
        PlayerSvtData(1101100)
          ..npLv = 5
          ..lv = 120
          ..atkFou = 2000
          ..hpFou = 2000
          ..appendLvs = [10, 10, 10]
          ..ce = db.gameData.craftEssencesById[9401850] // Magical Girl of Sapphire
          ..ceLv = 100
          ..ceLimitBreak = true,
        PlayerSvtData(504500)
          ..lv = 90,
        PlayerSvtData(504500)
          ..lv = 90,
      ];
      final battle = BattleData();
      battle.init(db.gameData.questPhases[9300040603]!, kamaWithDoubleCastoria, null);

      battle.activateSvtSkill(0, 0);
      battle.activateSvtSkill(1, 1);
      battle.activateSvtSkill(1, 2);
      battle.activateSvtSkill(2, 1);
      battle.activateSvtSkill(2, 2);
      final kama = battle.targetedAlly!;
      final npActions = [CombatAction(kama, kama.getNPCard()!)];

      battle.enemyTargetIndex = 1;
      final skyCaster = battle.targetedEnemy!;
      final hpBeforeDamage = skyCaster.hp;
      battle.playerTurn(npActions);
      final hpAfterDamage = skyCaster.hp;

      expect(hpBeforeDamage - hpAfterDamage, 82618);
      expect(kama.np, 12422); // np from each hit is added one by one, so would trigger np pity (> 9900) immediately
      expect(battle.criticalStars, moreOrLessEquals(3.432, epsilon: 0.001));
      expect(battle.isActorOnField(skyCaster.uniqueId), isFalse);
      expect(battle.isBattleFinished, isFalse);
      expect(battle.waveCount, 2);
      expect(battle.totalTurnCount, 2);
      expect(battle.turnCount, 1);

      final wave2enemy = battle.targetedEnemy!;
      expect(wave2enemy.uniqueId, 7);
      final hpBeforeDamageWave2 = wave2enemy.hp;
      battle.playerTurn(npActions);
      final hpAfterDamageWave2 = wave2enemy.hp;

      expect(hpBeforeDamageWave2 - hpAfterDamageWave2, 82618);
      expect(kama.np, 11584 + 380);
      expect(battle.criticalStars, moreOrLessEquals(2.532, epsilon: 0.001));
      expect(battle.isActorOnField(wave2enemy.uniqueId), isFalse);
      expect(battle.isBattleFinished, isFalse);
      expect(battle.waveCount, 3);
      expect(battle.totalTurnCount, 3);
      expect(battle.turnCount, 1);

      battle.activateSvtSkill(0, 1);
      battle.activateSvtSkill(0, 2);
      battle.activateSvtSkill(1, 0);
      battle.activateSvtSkill(2, 0);

      final wave3enemy = battle.targetedEnemy!;
      expect(wave3enemy.uniqueId, 10);
      final hpBeforeDamageWave3 = wave3enemy.hp;
      battle.playerTurn(npActions);
      final hpAfterDamageWave3 = wave3enemy.hp;

      expect(hpBeforeDamageWave3 - hpAfterDamageWave3, 225160);
      expect(kama.np, 3404 + 380);
      expect(battle.criticalStars, moreOrLessEquals(0.844, epsilon: 0.001));
      expect(battle.isActorOnField(wave3enemy.uniqueId), isFalse);
      expect(battle.isBattleFinished, isTrue);
    });
  });

  test('Activate skill checks buff status', () {
    final List<PlayerSvtData> lipAndJinako = [
      PlayerSvtData(1000100)
        ..lv = 80,
      PlayerSvtData(2300300)
        ..lv = 90,
    ];
    final battle = BattleData();
    battle.init(db.gameData.questPhases[9300040603]!, lipAndJinako, null);

    battle.activateSvtSkill(0, 0);

    final avoidStateBuff = collectBuffsPerType(battle.onFieldAllyServants[0]!.battleBuff.allBuffs, BuffType.avoidState)
        .first;

    expect(avoidStateBuff.count, 3);

    battle.activateSvtSkill(0, 2);

    expect(avoidStateBuff.count, 2);

    battle.activateSvtSkill(1, 2);

    expect(avoidStateBuff.count, 1);
  });

  group('Method tests', () {
    final List<PlayerSvtData> okuniWithDoubleCba = [
      PlayerSvtData(504900)
        ..lv = 90,
      PlayerSvtData(503900)
        ..lv = 90,
      PlayerSvtData(503900)
        ..lv = 90,
    ];

    test('Test checkTargetTraits & checkActivatorTraits', () {
      final battle = BattleData();
      battle.init(db.gameData.questPhases[9300040603]!, okuniWithDoubleCba, null);
      final okuni = battle.onFieldAllyServants[0]!;
      final cba = battle.onFieldAllyServants[1]!;
      battle.setActivator(cba);
      battle.setTarget(okuni);

      final divinityCheck = [NiceTrait(id: Trait.divine.id)];
      expect(battle.checkActivatorTraits(divinityCheck), isTrue);
      expect(battle.checkTargetTraits(divinityCheck), isFalse);

      final buff = BuffData(Buff(id: -1, name: '', detail: '', vals: divinityCheck), DataVals());
      battle.setCurrentBuff(buff);
      battle.setActivator(okuni);
      expect(battle.checkActivatorTraits(divinityCheck), isTrue);
      expect(battle.checkTargetTraits(divinityCheck), isTrue);

      battle.unsetCurrentBuff();
      expect(battle.checkActivatorTraits(divinityCheck), isFalse);
      expect(battle.checkTargetTraits(divinityCheck), isFalse);
    });

    test('Check isActorOnField', () {
      final battle = BattleData();
      battle.init(db.gameData.questPhases[9300040603]!, okuniWithDoubleCba, null);
      expect(battle.isActorOnField(1), isTrue);
      expect(battle.isActorOnField(3), isTrue);
      expect(battle.isActorOnField(7), isFalse);

      battle.onFieldEnemies.clear();
      battle.nextWave();
      expect(battle.isActorOnField(7), isTrue);
      expect(battle.isActorOnField(10), isFalse);
    });
  });
}
