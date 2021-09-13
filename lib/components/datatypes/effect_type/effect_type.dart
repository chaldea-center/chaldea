import 'package:chaldea/components/datatypes/datatypes.dart';
import 'package:chaldea/components/localized/localized_base.dart';

import 'buff_type.dart';
import 'func_type.dart';

export 'buff_type.dart';
export 'func_type.dart';

class EffectType {
  String key;
  List<FuncType> funcs;
  List<BuffType> buffs;
  LocalizedText? name;
  bool Function(NiceFunction)? testFunc;
  bool Function(NiceBuff)? testBuff;

  EffectType({
    required this.key,
    this.funcs = const [],
    this.buffs = const [],
    required this.name,
    this.testFunc,
    this.testBuff,
  }) : assert(funcs.isNotEmpty || buffs.isNotEmpty);

  String get shownName {
    if (name != null) return name!.localized;
    if (buffs.isNotEmpty) return buffs.first.shownName;
    return funcs.first.shownName;
  }

  bool test(List<NiceFunction> functions) {
    if (functions.isEmpty) return false;

    if (funcs.isNotEmpty) {
      if (testFunc != null) {
        if (functions.any((e) => testFunc!(e))) {
          return true;
        }
      } else {
        if (functions
            .any((e) => funcs.any((funcType) => funcType.type == e.funcType))) {
          return true;
        }
      }
    }
    List<NiceBuff> niceBuffs = [for (final f in functions) ...f.buffs];
    if (niceBuffs.isEmpty) return false;
    if (buffs.isNotEmpty) {
      if (testBuff != null) {
        if (niceBuffs.any((e) => testBuff!(e))) {
          return true;
        }
      } else {
        if (niceBuffs
            .any((e) => buffs.any((buffType) => buffType.type == e.type))) {
          return true;
        }
      }
    }
    return false;
  }

  static EffectType subState = EffectType(
    key: 'subState',
    funcs: [FuncTypes.subState],
    name: LocalizedText(chs: '强化解除', jpn: '強化解除', eng: 'Remove Effects'),
  );

  static EffectType gainStar = EffectType(
    key: 'gainStar',
    buffs: [BuffTypes.regainStar],
    funcs: [FuncTypes.gainStar],
    name: LocalizedText(chs: '暴击星获得', jpn: 'スター獲得', eng: 'Gain Stars'),
  );

  static EffectType gainHp = EffectType(
    key: 'gainHp',
    funcs: [FuncTypes.gainHp, FuncTypes.gainHpPer, FuncTypes.gainHpFromTargets],
    name: LocalizedText(chs: 'HP回复', jpn: 'HP回復', eng: 'Restore HP'),
  );

  static EffectType gainNp = EffectType(
    key: 'gainNp',
    funcs: [
      FuncTypes.gainNp,
      FuncTypes.gainNpFromTargets,
      FuncTypes.gainNpFromTargets,
      FuncTypes.absorbNpturn,
      FuncTypes.gainNpBuffIndividualSum,
    ],
    name: LocalizedText(chs: 'NP増加', jpn: 'NP増加', eng: 'Charge NP'),
  );

  static EffectType shortenSkill = EffectType(
    key: 'shortenSkill',
    funcs: [FuncTypes.shortenSkill],
    name:
        LocalizedText(chs: '技能冷却减小', jpn: 'スキルターン減少', eng: 'Reduce Cooldowns'),
  );

  static EffectType pierceDefence = EffectType(
    key: 'pierceDefence',
    funcs: [FuncTypes.damageNpPierce],
    buffs: [BuffTypes.pierceDefence],
    name: LocalizedText(chs: '无视防御', jpn: '防御無視', eng: 'Pierce Defense'),
  );

  static EffectType npTegong = EffectType(
    key: 'npTegong',
    funcs: [
      FuncTypes.damageNpHpratioLow,
      FuncTypes.damageNpIndividual,
      FuncTypes.damageNpIndividualSum,
      FuncTypes.damageNpRare,
      FuncTypes.damageNpStateIndividual,
      FuncTypes.damageNpStateIndividualFix,
    ],
    name: LocalizedText(chs: '宝具特攻', jpn: 'jpn', eng: 'eng'),
  );

  static EffectType expUp = EffectType(
    key: 'expUp',
    funcs: [FuncTypes.expUp],
    name: LocalizedText(chs: '御主EXP', jpn: 'マスターEXP', eng: 'Master EXP'),
  );
  static EffectType qpUp = EffectType(
    key: 'qpUp',
    funcs: [FuncTypes.qpUp, FuncTypes.qpDropUp],
    name: LocalizedText(chs: 'QP', jpn: 'QP', eng: 'QP'),
  );
  static EffectType friendPointUp = EffectType(
    key: 'friendPointUp',
    funcs: [FuncTypes.friendPointUp, FuncTypes.friendPointUpDuplicate],
    name: LocalizedText(chs: '友情点', jpn: 'フレンドポイント', eng: 'Friend Point'),
  );
  static EffectType bondPointUp = EffectType(
    key: 'bondPointUp',
    funcs: [FuncTypes.servantFriendshipUp],
    name: LocalizedText(chs: '羁绊', jpn: '絆', eng: 'Bond Point'),
  );
  static EffectType userEquipExpUp = EffectType(
    key: 'userEquipExpUp',
    funcs: [FuncTypes.userEquipExpUp],
    name: LocalizedText(chs: '魔术礼装', jpn: '魔術礼装', eng: 'Mystic Code'),
  );

  // buffs

  static EffectType artsPerform = EffectType(
    key: 'artsPerform',
    buffs: [BuffTypes.upCommandall],
    name: LocalizedText(chs: 'Arts', jpn: 'Arts', eng: 'Arts'),
    testBuff: (buff) => buff.name.contains('Arts'),
  );
  static EffectType quickPerform = EffectType(
    key: 'quickPerform',
    buffs: [BuffTypes.upCommandall],
    name: LocalizedText(chs: 'Quick', jpn: 'Quick', eng: 'Quick'),
    testBuff: (buff) => buff.name.contains('Quick'),
  );
  static EffectType busterPerform = EffectType(
    key: 'busterPerform',
    buffs: [
      BuffTypes.upCommandall,
      BuffTypes.downCommandall,
      BuffTypes.downDefencecommandall
    ],
    name: LocalizedText(chs: 'Buster', jpn: 'Buster', eng: 'Buster'),
    testBuff: (buff) => buff.name.contains('Buster'),
  );

  static EffectType starWeight = EffectType(
    key: 'starWeight',
    buffs: [BuffTypes.upStarweight, BuffTypes.downStarweight],
    name: LocalizedText(chs: '集星', jpn: 'スター集中', eng: 'Star Weight'),
  );

  static EffectType starRate = EffectType(
    key: 'starRate',
    buffs: [BuffTypes.upCriticalpoint, BuffTypes.downCriticalpoint],
    name: LocalizedText(chs: '出星率', jpn: 'スター発生', eng: 'Star Drop Rate'),
  );

  static EffectType regainNp = EffectType(
    key: 'regainNp',
    buffs: [BuffTypes.regainNp],
    name: LocalizedText(chs: '每回合NP', jpn: '毎ターンNP', eng: 'NP per turn'),
  );

  static EffectType regainHp = EffectType(
    key: 'regainHp',
    buffs: [BuffTypes.regainHp],
    name: LocalizedText(chs: '每回合HP', jpn: '毎ターンHP', eng: 'HP per turn'),
  );

  static EffectType upAtk = EffectType(
    key: 'upAtk',
    buffs: [BuffTypes.upAtk],
    name: LocalizedText(chs: '攻击力', jpn: '攻撃力', eng: 'Attack Up'),
  );

  static EffectType upDamage = EffectType(
    key: 'upDamage',
    buffs: [BuffTypes.upDamage, BuffTypes.upDamageIndividualityActiveonly],
    name: LocalizedText(chs: '威力提升', jpn: '威力アップ', eng: 'SP.DMG Up'),
  );

  static EffectType addDamage = EffectType(
    key: 'addDamage',
    buffs: [BuffTypes.addDamage],
    name: LocalizedText(chs: '附加伤害', jpn: '威力アップ', eng: 'Damage Plus'),
  );

  static EffectType npDamage = EffectType(
    key: 'npDamage',
    buffs: [BuffTypes.upNpdamage, BuffTypes.downNpdamage],
    name: LocalizedText(chs: '宝威', jpn: '宝具威力', eng: 'NP Damage Up'),
  );

  static EffectType upDropnp = EffectType(
    key: 'upDropnp',
    buffs: [BuffTypes.upDropnp, BuffTypes.upDamagedropnp],
    name: LocalizedText(chs: 'NP获得率', jpn: 'NP獲得率', eng: 'NP Gain Up'),
  );

  static EffectType upCriticaldamage = EffectType(
    key: 'upCriticaldamage',
    buffs: [BuffTypes.upCriticaldamage],
    name: LocalizedText(chs: '暴击威力', jpn: 'クリティカル威力', eng: 'Critical Damage'),
  );

  static EffectType subSelfdamage = EffectType(
    key: 'subSelfdamage',
    buffs: [BuffTypes.subSelfdamage],
    name: LocalizedText(chs: '减伤', jpn: '被ダメージカット', eng: 'Damage Cut'),
  );

  static EffectType avoidance = EffectType(
    key: 'avoidance',
    buffs: [BuffTypes.avoidance],
    name: LocalizedText(chs: '回避', jpn: '回避', eng: 'Evade'),
  );

  static EffectType breakAvoidance = EffectType(
    key: 'breakAvoidance',
    buffs: [BuffTypes.breakAvoidance],
    name: LocalizedText(chs: '必中', jpn: '必中', eng: 'Sure Hit'),
  );

  static EffectType invincible = EffectType(
    key: 'invincible',
    buffs: [BuffTypes.invincible],
    name: LocalizedText(chs: '无敌', jpn: '無敵', eng: 'Invincible'),
  );

  static EffectType pierceInvincible = EffectType(
    key: 'pierceInvincible',
    buffs: [BuffTypes.pierceInvincible],
    name: LocalizedText(chs: '无敌贯通', jpn: '無敵貫通', eng: 'Ignore Invincible'),
  );

  static EffectType upGrantstate = EffectType(
    key: 'upGrantstate',
    buffs: [BuffTypes.upGrantstate],
    name: LocalizedText(chs: '状态赋予率', jpn: '状態付与率', eng: 'Effect Chance Up'),
  );

  static EffectType upTolerance = EffectType(
    key: 'upTolerance',
    buffs: [BuffTypes.upTolerance],
    name: LocalizedText(chs: '耐性提升', jpn: '耐性アップ', eng: 'Debuff Tolerance'),
  );

  static EffectType avoidState = EffectType(
    key: 'avoidState',
    buffs: [BuffTypes.avoidState],
    name: LocalizedText(chs: '弱体无效', jpn: '弱体無効', eng: 'Immunity vs Debuff'),
  );

  static EffectType donotAct = EffectType(
    key: 'donotAct',
    buffs: [BuffTypes.donotAct],
    name: LocalizedText(chs: '行动不能', jpn: '行動不能', eng: 'Donot Act'),
  );

  static EffectType donotSkill = EffectType(
    key: 'donotSkill',
    buffs: [BuffTypes.donotSkill],
    name: LocalizedText(chs: '技能封印', jpn: 'スキル封印', eng: 'Skill Seal'),
  );

  static EffectType donotNoble = EffectType(
    key: 'donotNoble',
    buffs: [BuffTypes.donotNoble],
    name: LocalizedText(chs: '宝具封印', jpn: '宝具封印', eng: 'NP Seal'),
  );

  static EffectType guts = EffectType(
    key: 'guts',
    buffs: [BuffTypes.guts, BuffTypes.gutsRatio],
    name: LocalizedText(chs: '毅力', jpn: 'ガッツ', eng: 'Guts'),
  );

  static EffectType upHate = EffectType(
    key: 'upHate',
    buffs: [BuffTypes.upHate],
    name: LocalizedText(chs: '目标集中度', jpn: 'タゲ集中', eng: 'Taunt'),
  );

  static EffectType upDefence = EffectType(
    key: 'upDefence',
    buffs: [BuffTypes.upDefence],
    name: LocalizedText(chs: '防御力提升', jpn: '防御力アップ', eng: 'Defence Up'),
  );

  static EffectType downDefence = EffectType(
    key: 'downDefence',
    buffs: [BuffTypes.downDefence],
    name: LocalizedText(chs: '防御力下降', jpn: '防御力ダウン', eng: 'Defence Down'),
  );

  static EffectType avoidInstantdeath = EffectType(
    key: 'avoidInstantdeath',
    buffs: [BuffTypes.avoidInstantdeath],
    name: LocalizedText(chs: '即死无效', jpn: '即死無効', eng: 'Immune to Death'),
  );

  static EffectType resistInstantdeath = EffectType(
    key: 'resistInstantdeath',
    buffs: [
      BuffTypes.upResistInstantdeath,
      BuffTypes.upGrantInstantdeath,
      BuffTypes.upNonresistInstantdeath
    ],
    name: LocalizedText(chs: '即死耐性', jpn: '即死耐性', eng: 'Death Resist'),
  );
  static EffectType delayFunction = EffectType(
    key: 'delayFunction',
    buffs: [BuffTypes.delayFunction],
    name: LocalizedText(chs: '延迟发动', jpn: '遅延発動', eng: 'Delayed Skill'),
  );
  static EffectType deadFunction = EffectType(
    key: 'deadFunction',
    buffs: [BuffTypes.deadFunction],
    name: LocalizedText(chs: '死亡时发动', jpn: '死亡時発動', eng: 'Skill on Dead'),
  );
  static EffectType entryFunction = EffectType(
    key: 'entryFunction',
    buffs: [BuffTypes.entryFunction],
    name: LocalizedText(chs: '登场时发动', jpn: '登場時発動', eng: 'Skill on Dead'),
  );
  static EffectType turnendFunction = EffectType(
    key: 'turnendFunction',
    buffs: [BuffTypes.selfturnendFunction],
    name: LocalizedText(chs: '每回合发动', jpn: '毎ターン発動', eng: 'Skill every Turn'),
  );
  static EffectType upGainHp = EffectType(
    key: 'upGainHp',
    buffs: [BuffTypes.upGivegainHp, BuffTypes.upGainHp],
    name: LocalizedText(chs: 'HP回复量', jpn: 'HP回復量', eng: 'Healing Up'),
  );
  static EffectType upChagetd = EffectType(
    key: 'upChagetd',
    buffs: [BuffTypes.upChagetd],
    name: LocalizedText(chs: 'OC', jpn: 'オーバーチャージ', eng: 'Over Charge'),
  );
  static EffectType upToleranceSubstate = EffectType(
    key: 'upToleranceSubstate',
    buffs: [BuffTypes.upToleranceSubstate],
    name: LocalizedText(
        chs: '强化解除耐性', jpn: '強化解除耐性', eng: 'Buff Removal Resistance'),
  );
  static EffectType upFuncHpReduce = EffectType(
    key: 'upFuncHpReduce',
    buffs: [BuffTypes.upFuncHpReduce],
    name: LocalizedText(
        chs: '呪厄/延焼/蝕毒', jpn: '呪厄/延焼/蝕毒', eng: 'DoT Effectiveness Up'),
  );
  static EffectType fieldIndividuality = EffectType(
    key: 'fieldIndividuality',
    buffs: [BuffTypes.fieldIndividuality],
    name:
        LocalizedText(chs: '场地特性赋予', jpn: 'フィールドセット', eng: 'Change Field Type'),
  );

  static final List<EffectType> svtEffects = [
    //
    gainNp, regainNp, upDropnp,
    artsPerform, quickPerform, busterPerform,
    avoidance, breakAvoidance, invincible, pierceInvincible,
    npTegong, upDamage, npDamage, upChagetd, upAtk, addDamage,
    upCriticaldamage, upFuncHpReduce,

    pierceDefence, subSelfdamage, upDefence,

    gainHp, regainHp, upGainHp,
    gainStar, starWeight, starRate,
    upGrantstate, upTolerance, resistInstantdeath, avoidInstantdeath,

    subState, avoidState, guts, upHate, shortenSkill,

    donotAct, donotNoble, donotSkill,

    deadFunction, turnendFunction, fieldIndividuality,
  ];

  static final List<EffectType> craftEffects = [
    //
    expUp, qpUp, friendPointUp, bondPointUp, userEquipExpUp,
    gainNp, regainNp, upDropnp,
    artsPerform, quickPerform, busterPerform,
    avoidance, breakAvoidance, invincible, pierceInvincible,
    upAtk, upDamage, npDamage, upChagetd, addDamage, upCriticaldamage,
    pierceDefence, subSelfdamage, upDefence,

    regainHp, upGainHp,
    gainStar, starWeight, starRate,
    upGrantstate, upTolerance, resistInstantdeath,

    avoidState, guts, upHate,

    deadFunction, entryFunction,
  ];

  static final Map<String, EffectType> svtEffectsMap = {
    for (final eff in svtEffects) eff.key: eff,
  };

  static final Map<String, EffectType> craftEffectsMap = {
    for (final eff in craftEffects) eff.key: eff,
  };

  static final Map<String, EffectType> validEffectsMap = {
    for (final eff in svtEffects) eff.key: eff,
    for (final eff in craftEffects) eff.key: eff,
  };
}

void initiateFuncBuffInstances() {
  // static fields and library variables are only initiated when called once
  FuncTypes.addState.nameCn + BuffTypes.regainNp.nameCn;
  print('${FuncTypes.all.length} FuncTypes, ${BuffTypes.all.length} BuffTypes');
}
