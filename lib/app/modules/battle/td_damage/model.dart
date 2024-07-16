import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

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

class TdDmgResult {
  final PlayerSvtData originalSvtData;
  final Servant svt;
  BattleServantData? actor;
  List<BattleRecord> attacks = [];
  BattleData battleData;
  int totalDamage = 0;
  int attackNp = 0;
  int totalNp = 0;

  TdDmgResult(this.originalSvtData, this.battleData) : svt = originalSvtData.svt!;

  bool get hasInstantDeath {
    return attacks.whereType<BattleInstantDeathRecord>().isNotEmpty;
  }

  bool get hasInstantDeathSuccess {
    return attacks.whereType<BattleInstantDeathRecord>().any((e) => e.hasSuccess);
  }
}

class TdDmgSolver {
  TdDamageOptions get options => db.settings.battleSim.tdDmgOptions;
  List<TdDmgResult> results = [];
  List errors = [];

  final running = ValueNotifier<bool>(false);
  Future<void> calculate() async {
    if (running.value) return;
    try {
      running.value = true;
      // let button update
      // await Future.delayed(const Duration(milliseconds: 200));
      await _calculate();
    } catch (e, s) {
      tryEasyLoading(() => EasyLoading.showError(e.toString()));
      logger.e('calc NP dmg ranking failed', e, s);
    } finally {
      running.value = false;
    }
  }

  Future<void> _calculate() async {
    results.clear();
    errors.clear();
    final List<Servant> servants;
    final releasedSvts = db.gameData.mappingData.entityRelease.ofRegion(options.region) ?? [];
    if (options.region != Region.jp && releasedSvts.isNotEmpty) {
      servants = releasedSvts.map((e) => db.gameData.servantsById[e]).whereType<Servant>().toList();
    } else {
      servants = db.gameData.servantsById.values.toList();
    }
    servants.sort2((e) => e.collectionNo);
    final quest = getQuest();
    final mcData = MysticCodeData();
    mcData
      ..mysticCode = db.gameData.mysticCodes[options.mcId]
      ..level = options.mcLv;
    final delegate = getDelegate();
    // final t = StopwatchX('calc');

    for (final svt in servants) {
      if (!svt.isUserSvt) continue;
      try {
        final baseSvt = getSvtData(svt, 4);
        final variants = <PlayerSvtData?>[baseSvt];

        if (svt.id == 304800) {
          // Melusine
          variants.add(getSvtData(svt, 1));
          variants.add(getSvtData(svt, 1)?..skills[2] = null);
        } else if (svt.id == 205000) {
          // Ptolemaios
          variants.add(getSvtData(svt, 4)?..skills[2] = null);
          variants.add(getSvtData(svt, 1));
          variants.add(getSvtData(svt, 1)?..skills[2] = null);
        } else {
          //
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
          final result = await calcOneSvt(svtData, quest, mcData, delegate);
          if (result == null) continue;
          results.add(result);
        }
        // if (svt.collectionNo % 100 == 0) await Future.delayed(const Duration(milliseconds: 1));
        // t.log('${svt.collectionNo}');
      } catch (e, s) {
        errors.add('SVT: ${svt.collectionNo} - ${svt.lName.l}\nError: $e');
        logger.e('calc svt ${svt.collectionNo} error', e, s);
      }
    }
  }

  final _debuffImmuneSkill = NiceSkill(
    id: -1000091,
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

  Future<TdDmgResult?> calcOneSvt(
      PlayerSvtData svtData, QuestPhase quest, MysticCodeData mcData, BattleDelegate delegate) async {
    final battleData = BattleData();
    final data = TdDmgResult(svtData, battleData);
    final attacker = data.originalSvtData.copy();
    battleData.delegate = delegate;
    battleData.options
      ..random = options.random
      ..threshold = options.probabilityThreshold;
    final svt = attacker.svt!;
    if (attacker.td == null || !attacker.td!.functions.any((func) => func.funcType.isDamageNp)) {
      return null;
    }

    if (options.addDebuffImmune) {
      attacker.addCustomPassive(_debuffImmuneSkill, 1);
    }

    final playerSettings = [attacker];

    await battleData.init(quest, playerSettings, mcData);
    final enemies = battleData.nonnullEnemies.toList();
    // final enemy = enemies.first;
    final actor = battleData.onFieldAllyServants[0]!;
    battleData.criticalStars = BattleData.kValidStarMax.toDouble();
    actor.np = ConstData.constants.fullTdPoint;
    if (options.enableActiveSkills) {
      await _activateActiveSkills(battleData, 0);
    }
    for (final svtId in options.supports) {
      final svt = db.gameData.servantsById[svtId];
      if (svt == null) continue;
      final sdata = PlayerSvtData.svt(svt);
      sdata.updateRankUps(region: options.region);
      BattleServantData support = BattleServantData.fromPlayerSvtData(sdata, battleData.getNextUniqueId());
      battleData.onFieldAllyServants[1] = support;
      await battleData.initActorSkills([support]);
      // await support.enterField(battle);
      await _activateActiveSkills(battleData, 1);
      battleData.onFieldAllyServants[1] = null;
    }
    for (int index = 0; index < battleData.masterSkillInfo.length; index++) {
      await battleData.activateMysticCodeSkill(index);
    }
    if (options.twiceActiveSkill && options.enableActiveSkills) {
      for (int index = 0; index < actor.skillInfoList.length; index++) {
        final skill = actor.skillInfoList[index];
        skill.chargeTurn -= 2;
        if (skill.chargeTurn < 0) skill.chargeTurn = 0;
        // if (skill.chargeTurn == 0) {
        //   await battleData.activateSvtSkill(0, index);
        // }
      }
      await _activateActiveSkills(battleData, 0);
    }
    actor.np = ConstData.constants.fullTdPoint;

    final card = actor.getNPCard();
    if (card == null) {
      print('svt ${svt.collectionNo}-${svt.lName.l}: No NP card');
      return null;
    }
    await battleData.playerTurn([CombatAction(actor, card)]);

    data.actor = actor;

    for (final record in battleData.recorder.records) {
      if (record is BattleAttackRecord) {
        if (record.attacker.uniqueId != actor.uniqueId || record.card == null) continue;
        final recordCopy = record.copy();
        recordCopy.targets.removeWhere((target) => enemies.every((e) => e.uniqueId != target.target.uniqueId));
        if (recordCopy.targets.isNotEmpty) {
          data.attacks.add(recordCopy);
          for (final target in recordCopy.targets) {
            data.attackNp += Maths.sum(target.result.npGains);
            data.totalDamage += Maths.sum(target.result.damages);
          }
        }
      } else if (record is BattleInstantDeathRecord) {
        if (record.activator?.uniqueId != actor.uniqueId) continue;
        final recordCopy = record.copy();
        recordCopy.targets.removeWhere((target) => enemies.every((e) => e.uniqueId != target.target.uniqueId));
        if (recordCopy.targets.isNotEmpty) {
          data.attacks.add(recordCopy);
        }
      }
    }
    data.totalNp = actor.np;

    if (data.attacks.isEmpty) return null;
    // print('${svt.collectionNo}-${svt.lName.l}: DMG ${result.totalDamage}');
    return data;
  }

  static const _fixedSvtSkillOrders = <int, List<int>>{
    100700: [2, 1, 3], // Gawain 高文
    100500: [3, 2, 1], // Nero Claudius (No.5)
    103900: [3, 2, 1], // Lakshmi Bai
    200800: [2, 1, 3], // Tristan 崔斯坦
    401200: [1, 3, 2], // Ozymandias 奥兹曼迪斯
    600300: [1, 2], // 百貌のハサン
    604700: [3, 1, 2], // Tezcatlipoca 烟雾镜
    700300: [3, 1, 2], // 吕布奉先
    703500: [3, 2, 1], // 森長可
    2500700: [3, 2, 1], // Abigail Williams (Summer)
    2501200: [2, 1, 3], // Cnoc na Riabh Yaraan-doo 诺克娜蕾
  };
  Future<void> _activateActiveSkills(BattleData battleData, int svtIndex) async {
    final svt = battleData.onFieldAllyServants.getOrNull(svtIndex)?.niceSvt;
    assert(svt != null);
    if (svt == null) return;
    List<int> skillNums = _fixedSvtSkillOrders[svt.id] ?? [1, 2, 3];
    for (final skillNum in skillNums) {
      // didn't check skill seal
      await battleData.activateSvtSkill(svtIndex, skillNum - 1);
    }
  }

  PlayerSvtData? getSvtData(Servant svt, int limitCount) {
    final data = PlayerSvtData.svt(svt);
    data.extraPassives = svt.extraPassive.toList();
    if (options.usePlayerSvt == PreferPlayerSvtDataSource.none) {
      data.lv = options.svtLv == SvtLv.maxLv ? svt.lvMax : options.svtLv.lv!;
      data.hpFou = data.atkFou = options.fouHpAtk;

      if (svt.rarity <= 3 || svt.obtains.contains(SvtObtain.eventReward)) {
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
        limitCount: limitCount,
      );
    }
    final board =
        db.gameData.classBoards.values.firstWhereOrNull((e) => e.classes.any((cls) => cls.classId == svt.classId));
    if (board != null) {
      NiceSkill? skill = switch (options.classBoard) {
        PreferClassBoardDataSource.none => null,
        PreferClassBoardDataSource.current => board.toSkill(db.curUser.classBoardStatusOf(board.id)),
        PreferClassBoardDataSource.target => board.toSkill(db.curPlan_.classBoardPlan(board.id)),
        PreferClassBoardDataSource.full => board.toSkill(ClassBoardPlan.full(board)),
      };
      if (skill != null) {
        data.addCustomPassive(skill, skill.maxLv);
      }
    }

    data.limitCount = limitCount;
    data.updateRankUps(region: options.region);
    if (!options.enableActiveSkills) {
      data.skills.fillRange(0, 3, null);
    }
    if (options.enableAppendSkills) {
      data.appendLvs.fillRange(0, 3, 10);
    }

    final extraBuffs = options.extraBuffs.buildSkill();
    if (extraBuffs != null) {
      data.addCustomPassive(extraBuffs, extraBuffs.maxLv);
    }
    // CE
    final ce = db.gameData.craftEssencesById[options.ceId];
    if (ce != null) {
      data.ce = ce;
      data.ceLv = options.ceLv.clamp(0, ce.lvMax); // allow lv0 for ignore CE ATK/HP
      data.ceLimitBreak = options.ceMLB;
    }
    return data;
  }

  QuestPhase getQuest() {
    List<QuestEnemy> enemies = [];
    options.enemyCount = options.enemyCount.clamp(1, 6);
    for (int index = 0; index < options.enemyCount; index++) {
      final enemy = TdDmgSolver.copyEnemy(options.enemy);
      enemy
        ..deckId = index + 1
        ..npcId = index + 11;
      if (options.addDebuffImmuneEnemy) {
        enemy.classPassive.addPassive.add(_debuffImmuneSkill);
      }
      for (final (skill, lv) in options.enemySkills) {
        enemy.classPassive.addPassive.add(skill.toNice());
        enemy.classPassive.addPassiveLvs.add(lv);
      }
      enemies.add(enemy);
    }

    return QuestPhase(
      name: 'TD DMG Test',
      id: -1,
      phase: 1,
      phases: [1],
      warId: options.warId,
      individuality: options.fieldTraits.map((e) => NiceTrait(id: e)).toList(),
      stages: [
        Stage(
          wave: 1,
          enemyFieldPosCount: max(3, enemies.length),
          enemies: enemies,
        )
      ],
    );
  }

  BattleDelegate getDelegate() {
    final delegate = BattleDelegate();
    delegate.decideOC = (_actor, baseOC, upOC) => options.fixedOC ? options.oc : options.oc + upOC;
    delegate.whetherTd = (_actor) => true;
    delegate.skillActSelect = (_actor) async {
      if (_actor?.svtId == 2501100) {
        return 1;
      }
      // if (_actor?.svtId == 204900) {
      //   return -1;
      // }
      return -1;
    };
    if (options.damageNpHpRatioMax) {
      delegate.hpRatio = (_actor, battleData, func, vals) {
        if (func?.funcType == FuncType.damageNpHpratioLow) {
          return 1;
        } else if (func?.funcType == FuncType.damageNpHpratioHigh) {
          return _actor.maxHp;
        }
        return null;
      };
    }
    if (options.forceDamageNpSe) {
      delegate.damageNpSE = (_actor, func, vals) {
        final funcType = func?.funcType;
        if ([
          FuncType.damageNpRare,
          FuncType.damageNpStateIndividualFix,
          FuncType.damageNpStateIndividual,
        ].contains(funcType)) {
          return DamageNpSEDecision(useCorrection: true);
        } else if (funcType == FuncType.damageNpIndividualSum) {
          return DamageNpSEDecision(
            useCorrection: true,
            indivSumCount: options.damageNpIndivSumCount ?? vals.ParamAddMaxCount,
          );
        }
        return null;
      };
    }

    return delegate;
  }

  static QuestEnemy copyEnemy(QuestEnemy enemy) {
    final enemy2 = QuestEnemy.fromJson(enemy.toJson());
    enemy2
      ..deck = DeckType.enemy
      ..deckId = 1;
    enemy.enemyScript.shift = null;
    return enemy2;
  }
}
