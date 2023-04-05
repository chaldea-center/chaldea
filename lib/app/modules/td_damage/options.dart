import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/atlas.dart';

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

class TdDamageOption {
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
    return QuestEnemy(
      deckId: 1,
      name: enemy.name,
      svt: BasicServant(
        id: enemy.svt.id,
        collectionNo: enemy.svt.collectionNo,
        name: enemy.svt.name,
        type: enemy.svt.type,
        flag: enemy.svt.flag,
        classId: enemy.svt.classId,
        className: enemy.svt.className,
        attribute: enemy.svt.attribute,
        rarity: enemy.svt.rarity,
        atkMax: enemy.svt.atkMax,
        hpMax: enemy.svt.hpMax,
        // ignore: invalid_use_of_protected_member
        face: enemy.svt.face,
      ),
      lv: enemy.lv,
      atk: enemy.atk,
      hp: enemy.hp,
      deathRate: enemy.deathRate,
      criticalRate: enemy.criticalRate,
      adjustAtk: enemy.adjustAtk,
      adjustHp: enemy.adjustHp,
      recover: enemy.recover,
      chargeTurn: enemy.chargeTurn,
      serverMod: EnemyServerMod(
        tdRate: enemy.serverMod.tdRate,
        tdAttackRate: enemy.serverMod.tdAttackRate,
        starRate: enemy.serverMod.starRate,
      ),
      traits: enemy.traits.toList(),
      classPassive: EnemyPassive(
        classPassive: enemy.classPassive.classPassive.toList(),
        addPassive: enemy.classPassive.addPassive.toList(),
        appendPassiveSkillIds: enemy.classPassive.appendPassiveSkillIds?.toList(),
        appendPassiveSkillLvs: enemy.classPassive.appendPassiveSkillLvs?.toList(),
      ),
      skills: EnemySkill(
        skillId1: enemy.skills.skillId1,
        skillId2: enemy.skills.skillId3,
        skillId3: enemy.skills.skillId3,
        skill1: enemy.skills.skill1,
        skill2: enemy.skills.skill3,
        skill3: enemy.skills.skill3,
        skillLv1: enemy.skills.skillLv1,
        skillLv2: enemy.skills.skillLv3,
        skillLv3: enemy.skills.skillLv3,
      ),
      noblePhantasm: EnemyTd(
        noblePhantasmId: enemy.noblePhantasm.noblePhantasmId,
        noblePhantasm: enemy.noblePhantasm.noblePhantasm,
        noblePhantasmLv: enemy.noblePhantasm.noblePhantasmLv,
        noblePhantasmLv1: enemy.noblePhantasm.noblePhantasmLv1,
        noblePhantasmLv2: enemy.noblePhantasm.noblePhantasmLv2,
        noblePhantasmLv3: enemy.noblePhantasm.noblePhantasmLv3,
      ),
      enemyScript: EnemyScript.fromJson(enemy.enemyScript.source),
      infoScript: enemy.infoScript == null ? null : EnemyInfoScript.fromJson(enemy.infoScript!.source),
      limit: enemy.limit == null ? null : EnemyLimit(limitCount: enemy.limit!.limitCount),
    );
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
        className: SvtClass.ALL,
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
      traits: [],
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
