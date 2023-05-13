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
  bool usePlayerSvt = false;
  bool addDebuffImmune = true;
  bool upResistSubState = true; // 5000
  bool doubleActiveSkillIfCD6 = false;
  // bool includeRefundAfterTd = true; // 重蓄力
  int tdR3 = 5;
  int tdR4 = 2;
  int tdR5 = 1;
  int oc = 1;

  static const List<int> optionalSupports = [37, 150, 215, 241, 284, 314, 316, 353, 357];

  static QuestEnemy copyEnemy(QuestEnemy enemy) {
    final enemy2 = QuestEnemy.fromJson(enemy.toJson());
    enemy2
      ..deck = DeckType.enemy
      ..deckId = 1;
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
  final Servant svt;
  BattleServantData? entity;
  List<BattleAttackRecord> attacks = [];
  int totalDamage = 0;
  int attackNp = 0;
  int totalNp = 0;

  TdDmgResult(this.svt);
}

class TdDmgSolver {
  TdDamageOptions options = TdDamageOptions();
  List<TdDmgResult> results = [];
  List errors = [];

  Future<void> calculate() async {
    results.clear();
    errors.clear();
    final servants = db.gameData.servantsNoDup.values.toList();
    servants.sort2((e) => e.collectionNo);
    for (final svt in servants) {
      try {
        final result = await calcOneSvt(svt);
        if (result != null) results.add(result);
        await Future.delayed(const Duration(milliseconds: 1));
      } catch (e, s) {
        errors.add('SVT: ${svt.collectionNo} - ${svt.lName.l}\nError: $e');
        logger.e('calc svt ${svt.collectionNo} error', e, s);
      }
    }
  }

  Future<TdDmgResult?> calcOneSvt(Servant svt) async {
    final battleData = BattleData();
    final attacker = getSvtData(svt);
    if (attacker.td == null || !attacker.td!.functions.any((func) => func.funcType.isDamageNp)) {
      return null;
    }
    if (options.addDebuffImmune) {
      attacker.addCustomPassive(
        BaseSkill(
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
                Buff(id: 1, name: 'name', detail: '', type: BuffType.avoidState, ckOpIndv: [NiceTrait(id: 3005)])
              ],
              svals: [
                DataVals({
                  "Rate": 5000,
                  "Turn": -1,
                  "Count": -1,
                })
              ],
            )
          ],
        ),
        1,
      );
    }
    // if (options.upResistSubState) {}
    final playerSettings = [attacker];

    await battleData.init(getQuest(), playerSettings, null);
    final enemy = battleData.onFieldEnemies[0]!;
    final actor = battleData.onFieldAllyServants[0]!;
    await battleData.activateSvtSkill(0, 0);
    await battleData.activateSvtSkill(0, 1);
    await battleData.activateSvtSkill(0, 2);
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
    if (options.doubleActiveSkillIfCD6) {
      // Buster + w-Koyan + skip 2 turns
      // battle.onFieldAllyServants[1]!.skillInfoList.forEach((skill) {
      //   skill.chargeTurn = 0;
      // });
      // await battle.activateSvtSkill(0, 0);
      // await battle.activateSvtSkill(0, 1);
      // await battle.activateSvtSkill(0, 2);
    }
    actor.np = ConstData.constants.fullTdPoint;
    battleData.delegate = BattleDelegate(battleData);
    battleData.delegate!.decideOC = (_actor, baseOC, upOC) => options.oc;
    final card = actor.getNPCard(battleData);
    if (card == null) {
      print('svt ${svt.collectionNo}-${svt.lName.l}: No NP card');
      return null;
    }
    await battleData.playerTurn([CombatAction(actor, card)]);

    final result = TdDmgResult(svt)..entity = actor;

    for (final record in battleData.recorder.records.whereType<BattleAttackRecord>()) {
      if (record.attacker.uniqueId != actor.uniqueId) continue;

      record.targets.removeWhere((target) => target.target.uniqueId != enemy.uniqueId);
      if (record.targets.isNotEmpty && record.card != null) {
        result.attacks.add(record);
        for (final target in record.targets) {
          result.attackNp = Maths.sum(target.result.npGains);
        }
      }
    }
    result.totalDamage = Maths.sum([
      for (final attack in result.attacks)
        for (final target in attack.targets) ...target.result.damages,
    ]);
    result.totalNp = actor.np;

    if (result.attacks.isEmpty) return null;
    // print('${svt.collectionNo}-${svt.lName.l}: DMG ${result.totalDamage}');
    return result;
  }

  PlayerSvtData getSvtData(Servant svt) {
    final data = PlayerSvtData.svt(svt);
    data.lv = svt.lvMax;
    if (svt.rarity <= 3 || svt.extra.obtains.contains(SvtObtain.eventReward)) {
      data.tdLv = options.tdR3;
    } else if (svt.rarity == 4) {
      data.tdLv = options.tdR4;
    } else if (svt.rarity == 5) {
      data.tdLv = options.tdR5;
    }
    // data.skills;
    return data;
  }

  QuestPhase getQuest() {
    return QuestPhase(
      name: 'TD DMG Test',
      id: -1,
      phase: 1,
      phases: [1],
      stages: [
        Stage(wave: 1, enemies: [TdDamageOptions.copyEnemy(options.enemy)])
      ],
    );
  }
}
