import 'dart:math';

import 'package:chaldea/app/battle/interactions/_delegate.dart';
import 'package:chaldea/app/battle/models/battle.dart';
import 'package:chaldea/app/battle/utils/battle_logger.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';

// (ATK * 0.23 * 宝具伤害倍率 * 指令卡伤害倍率
//  * (1 ± 指令卡性能BUFF ∓ 指令卡耐性)
//  * 职阶补正 * 职阶克制 * 隐藏属性克制
//  * (1 ± 攻击力BUFF ∓ 防御力BUFF - 特防状态BUFF)
//  * (1 + 特攻状态BUFF ± 宝具威力BUFF)
//  * 宝具特攻倍率
//  * (1 ∓ 特殊耐性BUFF)
//  * (1 ± 特殊威力BUFF)
//  * 随机数)
// ± 伤害附加与减免 ∓ 被伤害减免与提升

class TdDamageOptions {
  QuestEnemy enemy = getBlankEnemy();
  List<Servant> supports = [];

  // only use some fields
  // DamageParameters params = DamageParameters();
  int enemyCount = 1;
  PreferPlayerSvtDataSource usePlayerSvt = PreferPlayerSvtDataSource.none;
  bool addDebuffImmune = true;
  bool addDebuffImmuneEnemy = false;
  bool upResistSubState = true; // 5000
  bool enableActiveSkills = true;
  bool twiceActiveSkill = false;
  bool enableAppendSkills = false;
  // bool includeRefundAfterTd = true; // 重蓄力
  int tdR3 = 5;
  int tdR4 = 2;
  int tdR5 = 1;
  int oc = 1;
  bool fixedOC = true;
  Region region = Region.jp;

  static const List<int> optionalSupports = [37, 150, 215, 241, 284, 314, 316, 353, 357];

  static QuestEnemy copyEnemy(QuestEnemy enemy) {
    final enemy2 = QuestEnemy.fromJson(enemy.toJson());
    enemy2
      ..deck = DeckType.enemy
      ..deckId = 1;
    enemy.enemyScript.shift = null;
    return enemy2;
  }

  static QuestEnemy getBlankEnemy() {
    return QuestEnemy(
      deckId: 1,
      name: 'BlankEnemy',
      svt: BasicServant(
        id: 988888888,
        collectionNo: 0,
        name: 'BlankEnemy',
        type: SvtType.normal,
        flag: SvtFlag.normal,
        classId: SvtClass.ALL.id,
        attribute: Attribute.void_,
        rarity: 3,
        atkMax: 1000,
        hpMax: 10000,
        face: Atlas.common.unknownEnemyIcon,
      ),
      lv: 1,
      atk: 1000,
      hp: 1000,
      deathRate: 0,
      criticalRate: 0,
      serverMod: EnemyServerMod(),
    );
  }
}

class DmgBuffSet {
  // dmg
  int upAtk;
  int upDef;
  int upArts;
  int upQuick;
  int upBuster;
  int upNpDamage;
  int upDamage; // exclude upNpDamage
  int addDamage; // add-sub
  //
  int upDropNp;
  int upCriticalPoint;

  DmgBuffSet({
    this.upAtk = 0,
    this.upDef = 0,
    this.upArts = 0,
    this.upQuick = 0,
    this.upBuster = 0,
    this.upNpDamage = 0,
    this.upDamage = 0,
    this.addDamage = 0,
    this.upDropNp = 0,
    this.upCriticalPoint = 0,
  });
}

class DmgBuffPresets {
  DmgBuffPresets._();
}

class TdDmgResult {
  final PlayerSvtData originalSvtData;
  final Servant svt;
  BattleServantData? actor;
  List<BattleAttackRecord> attacks = [];
  int totalDamage = 0;
  int attackNp = 0;
  int totalNp = 0;

  TdDmgResult(this.originalSvtData) : svt = originalSvtData.svt!;
}

class TdDmgSolver {
  TdDamageOptions options = TdDamageOptions();
  List<TdDmgResult> results = [];
  List errors = [];

  Future<void> calculate() async {
    results.clear();
    errors.clear();
    final List<Servant> servants;
    final releasedSvts = db.gameData.mappingData.svtRelease.ofRegion(options.region) ?? [];
    if (options.region != Region.jp && releasedSvts.isNotEmpty) {
      servants = releasedSvts.map((e) => db.gameData.servantsNoDup[e]).whereType<Servant>().toList();
    } else {
      servants = db.gameData.servantsNoDup.values.toList();
    }
    servants.sort2((e) => e.collectionNo);
    final quest = getQuest();
    final t = StopwatchX('calc');

    for (final svt in servants) {
      try {
        final baseSvt = getSvtData(svt, 4);
        final variants = <PlayerSvtData?>[baseSvt];

        // Melusine
        if (svt.collectionNo == 312) {
          variants.add(getSvtData(svt, 1));
          variants.add(getSvtData(svt, 1)?..skills[2] = null);
        }

        // tdTypeChanges
        final baseTd = baseSvt?.td;
        if (baseSvt != null && baseTd != null) {
          final tdTypeChangeIds = baseTd.script?.tdTypeChangeIDs ?? const [];
          for (final tdId in tdTypeChangeIds) {
            if (tdId == baseTd.id) continue;
            final tdChange = baseSvt.svt?.noblePhantasms.firstWhereOrNull((e) => e.id == tdId);
            if (tdChange != null) {
              variants.add(baseSvt.copy()..td = tdChange);
            }
          }
        }
        for (final svtData in variants) {
          if (svtData == null) continue;
          final result = await calcOneSvt(TdDmgResult(svtData), quest);
          if (result == null) continue;
          results.add(result);
        }
        if (svt.collectionNo % 50 == 0) await Future.delayed(const Duration(milliseconds: 1));
        t.log('${svt.collectionNo}');
      } catch (e, s) {
        errors.add('SVT: ${svt.collectionNo} - ${svt.lName.l}\nError: $e');
        logger.e('calc svt ${svt.collectionNo} error', e, s);
      }
    }
  }

  final _debuffImmuneSkill = NiceSkill(
    id: 1,
    name: 'Debuff Immune',
    type: SkillType.passive,
    coolDown: [0],
    functions: [
      NiceFunction(
        funcId: 1,
        funcType: FuncType.addState,
        funcTargetType: FuncTargetType.self,
        buffs: [
          Buff(
            id: 1,
            name: 'Debuff Immune',
            detail: 'Manually added',
            type: BuffType.avoidState,
            ckOpIndv: [NiceTrait(id: 3005)],
          )
        ],
        svals: [
          DataVals({
            "Rate": 5000,
            "Turn": -1,
            "Count": -1,
            "ForceAddState": 1,
            "UnSubState": 1,
          })
        ],
      )
    ],
  );

  Future<TdDmgResult?> calcOneSvt(TdDmgResult data, QuestPhase quest) async {
    final attacker = data.originalSvtData.copy();
    final battleData = BattleData();
    final svt = attacker.svt!;
    if (attacker.td == null || !attacker.td!.functions.any((func) => func.funcType.isDamageNp)) {
      return null;
    }

    if (options.addDebuffImmune) {
      attacker.addCustomPassive(_debuffImmuneSkill, 1);
    }

    final playerSettings = [attacker];

    await battleData.init(quest, playerSettings, null);
    final enemies = battleData.nonnullEnemies.toList();
    // final enemy = enemies.first;
    final actor = battleData.onFieldAllyServants[0]!;
    battleData.criticalStars = BattleData.kValidStarMax.toDouble();
    actor.np = 100 * 100;
    if (options.enableActiveSkills) {
      await battleData.activateSvtSkill(0, 0);
      await battleData.activateSvtSkill(0, 1);
      await battleData.activateSvtSkill(0, 2);
    }
    for (final svt in options.supports) {
      final sdata = PlayerSvtData.svt(svt);
      // ignore: unused_local_variable
      BattleServantData support = BattleServantData.fromPlayerSvtData(sdata, battleData.getNextUniqueId());
      battleData.onFieldAllyServants[1] = support;
      // await support.enterField(battle);
      await battleData.activateSvtSkill(1, 0);
      await battleData.activateSvtSkill(1, 1);
      await battleData.activateSvtSkill(1, 2);
      // battleData.onFieldAllyServants[1] = null;
    }
    if (options.twiceActiveSkill && options.enableActiveSkills) {
      for (int index = 0; index < actor.skillInfoList.length; index++) {
        final skill = actor.skillInfoList[index];
        skill.chargeTurn -= 2;
        if (skill.chargeTurn < 0) skill.chargeTurn = 0;
        if (skill.chargeTurn == 0) {
          await battleData.activateSvtSkill(0, index);
        }
      }
    }
    actor.np = ConstData.constants.fullTdPoint;
    battleData.delegate = BattleDelegate(battleData);
    battleData.delegate!.decideOC = (_actor, baseOC, upOC) => options.fixedOC ? options.oc : options.oc + upOC;
    final card = actor.getNPCard(battleData);
    if (card == null) {
      print('svt ${svt.collectionNo}-${svt.lName.l}: No NP card');
      return null;
    }
    await battleData.playerTurn([CombatAction(actor, card)]);

    data.actor = actor;

    for (final record in battleData.recorder.records.whereType<BattleAttackRecord>()) {
      if (record.attacker.uniqueId != actor.uniqueId || record.card == null) continue;
      record.targets.removeWhere((target) => enemies.every((e) => e.uniqueId != target.target.uniqueId));
      if (record.targets.isNotEmpty) {
        data.attacks.add(record);
        for (final target in record.targets) {
          data.attackNp += Maths.sum(target.result.npGains);
          data.totalDamage += Maths.sum(target.result.damages);
        }
      }
    }
    data.totalNp = actor.np;

    if (data.attacks.isEmpty) return null;
    // print('${svt.collectionNo}-${svt.lName.l}: DMG ${result.totalDamage}');
    return data;
  }

  PlayerSvtData? getSvtData(Servant svt, int limitCount) {
    final data = PlayerSvtData.svt(svt)..limitCount = limitCount;
    if (options.usePlayerSvt == PreferPlayerSvtDataSource.none) {
      data.lv = svt.lvMax;
      if (svt.rarity <= 3 || svt.extra.obtains.contains(SvtObtain.eventReward)) {
        data.tdLv = options.tdR3;
      } else if (svt.rarity == 4) {
        data.tdLv = options.tdR4;
      } else if (svt.rarity == 5) {
        data.tdLv = options.tdR5;
      }
    } else {
      final status = svt.status;
      if (!status.favorite) return null;
      data.fromUserSvt(
        svt: svt,
        status: status,
        plan: options.usePlayerSvt == PreferPlayerSvtDataSource.current ? status.cur : svt.curPlan,
      );
    }
    data.updateRankUps(options.region);
    if (!options.enableActiveSkills) {
      data.skills.fillRange(0, 3, null);
    }
    if (options.enableAppendSkills) {
      data.appendLvs.fillRange(0, 3, 10);
    }
    return data;
  }

  QuestPhase getQuest() {
    List<QuestEnemy> enemies = [];
    options.enemyCount = options.enemyCount.clamp(1, 6);
    for (int index = 0; index < options.enemyCount; index++) {
      final enemy = TdDamageOptions.copyEnemy(options.enemy);
      enemy
        ..deckId = index + 1
        ..npcId = index + 11;
      if (options.addDebuffImmuneEnemy) {
        enemy.classPassive.addPassive.add(_debuffImmuneSkill);
      }
      enemies.add(enemy);
    }

    return QuestPhase(
      name: 'TD DMG Test',
      id: -1,
      phase: 1,
      phases: [1],
      stages: [
        Stage(
          wave: 1,
          enemyFieldPosCount: max(3, enemies.length),
          enemies: enemies,
        )
      ],
    );
  }
}
