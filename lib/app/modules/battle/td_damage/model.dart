import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
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
  late BattleServantData actor;
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
      await EasyThrottle.throttleAsync('td_dmg_calculate', _calculate);
      await EasyLoading.dismiss();
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
    for (final (idx, svt) in servants.indexed) {
      if (!svt.isUserSvt) continue;
      try {
        final List<int> limitsToAdd = [];
        if (!options.simpleMode || idx % 17 == 0) {
          EasyLoading.showProgress(
            idx / servants.length,
            status: '$idx / ${servants.length}',
            maskType: EasyLoadingMaskType.clear,
          );
          await Future.delayed(const Duration(milliseconds: 5));
        }

        if (options.simpleMode) {
          limitsToAdd.add(4);
          if (svt.id == 304800 || svt.id == 205000) {
            limitsToAdd.add(1);
          }
        } else {
          final limits = [...svt.limits.keys.toList().sortReturn((a, b) => b.compareTo(a)), ...svt.costume.keys];
          final List<Set<int>> recordedTraits = [];
          for (final limit in limits) {
            final Set<int> traitIdSet = svt.getIndividuality(null, limit).map((trait) => trait.signedId).toSet();
            if (recordedTraits.every((recorded) => !setEquals(recorded, traitIdSet))) {
              limitsToAdd.add(limit);
            } else {
              recordedTraits.add(traitIdSet);
            }
          }
        }

        final variants = <PlayerSvtData?>[];

        for (final limitToAdd in limitsToAdd) {
          final baseSvt = getSvtData(svt, limitToAdd);
          variants.add(getSvtData(svt, limitToAdd));
          if (svt.id == 304800 && [0, 1, 2, 304830, 304840].contains(limitToAdd)) {
            // Melusine
            variants.add(getSvtData(svt, limitToAdd)?..skills[2] = null);
          } else if (svt.id == 205000) {
            // Ptolemaios
            if ([0, 1, 2].contains(limitToAdd)) {
              variants.add(getSvtData(svt, limitToAdd)?..skills[2] = null);
            } else if ([3, 4].contains(limitToAdd)) {
              variants.add(getSvtData(svt, limitToAdd)?..skills[2] = null);
            }
          } else {
            //
          }

          // tdTypeChanges
          final baseTd = baseSvt?.td;
          if (baseSvt != null && baseTd != null) {
            final tdTypeChangeIds = baseTd.script?.tdTypeChangeIDs ?? const [];
            // tdChangeByBattlePoint_{}_{}
            for (final tdId in tdTypeChangeIds) {
              if (tdId == baseTd.id) continue;
              final tdChange = baseSvt.svt?.noblePhantasms.firstWhereOrNull((e) => e.id == tdId);
              if (tdChange != null) {
                final tdChangeSvt = baseSvt.copy()..td = tdChange;
                if (tdChange.id == 800108) {
                  // Mash
                  variants.add(tdChangeSvt..skills[1] = await AtlasApi.skill(2477450));
                } else {
                  variants.add(tdChangeSvt);
                }
              }
            }
          }
        }

        final Map<int, TdDmgResult> resultRecord = {};
        for (final svtData in variants) {
          if (svtData == null) continue;
          final result = await calcOneSvt(svtData, quest, mcData, delegate);
          if (result == null) continue;

          if (resultRecord.containsKey(result.totalDamage)) {
            final recorded = resultRecord[result.totalDamage]!;
            final currentLimitCount = result.actor.limitCount;
            final recordedLimitCount = recorded.actor.limitCount;
            if ((currentLimitCount < recordedLimitCount && recordedLimitCount != 4) || currentLimitCount == 4) {
              resultRecord[result.totalDamage] = result;
              if (recorded.actor.getNPCard()?.cardType != result.actor.getNPCard()?.cardType) {
                results.add(recorded);
              }
            }
          } else {
            resultRecord[result.totalDamage] = result;
          }
        }
        results.addAll(resultRecord.values);
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
          ),
        ],
        svals: [
          DataVals({"Rate": 5000, "Turn": -1, "Count": -1, "ForceAddState": 1, "UnSubState": 1}),
        ],
      ),
    ],
  );

  Future<TdDmgResult?> calcOneSvt(
    PlayerSvtData svtData,
    QuestPhase quest,
    MysticCodeData mcData,
    BattleDelegate delegate,
  ) async {
    final battleData = BattleData();
    final data = TdDmgResult(svtData, battleData);
    final attacker = data.originalSvtData.copy();
    battleData.delegate = delegate;
    battleData.options
      ..random = options.random
      ..threshold = options.probabilityThreshold;
    final svt = attacker.svt!;
    if (attacker.td == null) {
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

    if (svt.id == 2501400) {
      // Aoko
      if (options.enableActiveSkills) {
        await battleData.activateSvtSkill(0, 2);
      }
      final card = actor.getNPCard();
      if (card != null) {
        await battleData.playerTurn([CombatAction(actor, card)]);
      }
      actor.np = ConstData.constants.fullTdPoint;
    }

    if (options.enableActiveSkills) {
      await _activateActiveSkills(battleData, 0);
    }

    if (options.twiceActiveSkill && options.enableActiveSkills) {
      if (options.twiceSkillOnTurn3) {
        await battleData.skipTurn();
        await battleData.skipTurn();
      } else {
        for (int index = 0; index < actor.skillInfoList.length; index++) {
          final skill = actor.skillInfoList[index];
          skill.chargeTurn -= 2;
          if (skill.chargeTurn < 0) skill.chargeTurn = 0;
          // if (skill.chargeTurn == 0) {
          //   await battleData.activateSvtSkill(0, index);
          // }
        }
      }
    }

    for (final svtId in options.supports) {
      final svt = db.gameData.servantsById[svtId];
      if (svt == null) continue;
      final sdata = PlayerSvtData.svt(svt);
      sdata.updateRankUps(region: options.region);
      BattleServantData support = BattleServantData.fromPlayerSvtData(
        sdata,
        battleData.getNextUniqueId(),
        isUseGrandBoard: battleData.isUseGrandBoard,
      );
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
    data.grandSvt = options.grandSvt;
    if (data.grandSvt && !options.grandBoard.isNone) {
      if (options.equip2Type != BondEquipType.none) {
        final equip2 = db.gameData.craftEssencesById[svt.bondEquip];
        if (equip2 != null) {
          data.equip2 = SvtEquipData(ce: equip2, limitBreak: true, lv: equip2.lvMax);
        }
      }
      if (options.equip2Type == BondEquipType.skillChange) {
        data.classBoardData.grandBondEquipSkillChange = true;
      }
      final equip3 = db.gameData.craftEssencesById[options.equip3];
      data.equip3 = SvtEquipData(ce: equip3, lv: equip3?.lvMax ?? 1, limitBreak: true);
    }
    final baseBoard = ClassBoard.getClassBoard(svt.classId);
    if (baseBoard != null) {
      data.classBoardData.classBoardSquares = options.classBoard.getPlan(baseBoard).enhancedSquares.toList();
    }
    final grandBoard = options.isUseGrandBoard ? ClassBoard.getGrandClassBoard(svt.classId) : null;
    if (grandBoard != null) {
      data.classBoardData.grandClassBoardSquares = options.grandBoard.getPlan(grandBoard).enhancedSquares.toList();
      data.classBoardData.classStatistics = [
        for (final type in CondParamValType.values)
          ClassStatisticsInfo(classId: svt.classId, type: type.value, typeVal: 10000),
      ];
    }

    data.limitCount = limitCount;
    data.updateRankUps(region: options.region);
    if (!options.enableActiveSkills) {
      data.skills.fillRange(0, data.skills.length, null);
    }
    for (int index = 0; index < data.appendLvs.length; index++) {
      data.appendLvs[index] = (options.appendSkills.getOrNull(index) ?? false) ? 10 : 0;
    }

    final extraBuffs = options.extraBuffs.buildSkill();
    if (extraBuffs != null) {
      data.addCustomPassive(extraBuffs, extraBuffs.maxLv);
    }
    // CE
    final ce = db.gameData.craftEssencesById[options.ceId];
    if (ce != null) {
      data.equip1 = SvtEquipData(
        ce: ce,
        lv: options.ceLv.clamp(0, ce.lvMax), // allow lv0 for ignore CE ATK/HP
        limitBreak: options.ceMLB,
      );
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
      stages: [Stage(wave: 1, enemyFieldPosCount: max(3, enemies.length), enemies: enemies)],
      extraDetail: QuestPhaseExtraDetail(isUseGrandBoard: options.grandBoard.isNone ? null : 1),
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
        } else if (funcType == FuncType.damageNpBattlePointPhase) {
          return DamageNpSEDecision(useCorrection: true, indivSumCount: options.damageNpIndivSumCount ?? 10);
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
