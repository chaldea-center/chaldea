import 'package:chaldea/components/datatypes/datatypes.dart';
import 'package:chaldea/components/localized/localized_base.dart';

import 'buff_type.dart';
import 'func_buff_type_base.dart';
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
    name: const LocalizedText(chs: '状态解除', jpn: '状態解除', eng: 'Remove Effects', kor: '상태 해제'),
  );

  static EffectType gainStar = EffectType(
    key: 'gainStar',
    funcs: [FuncTypes.gainStar],
    name: const LocalizedText(chs: '暴击星获得', jpn: 'スター獲得', eng: 'Gain Stars', kor: '스타 발생'),
  );

  static EffectType regainStar = EffectType(
    key: 'regainStar',
    buffs: [BuffTypes.regainStar],
    name: const LocalizedText(
        chs: '每回合暴击星', jpn: '毎ターンスター獲得', eng: 'Stars per Turn', kor: '턴마다 스타 발생'),
  );

  static EffectType gainHp = EffectType(
    key: 'gainHp',
    funcs: [FuncTypes.gainHp, FuncTypes.gainHpPer, FuncTypes.gainHpFromTargets],
    name: const LocalizedText(chs: 'HP回复', jpn: 'HP回復', eng: 'Restore HP', kor: 'HP회복'),
  );

  static EffectType gainNp = EffectType(
    key: 'gainNp',
    funcs: [
      FuncTypes.gainNp,
      FuncTypes.gainNpFromTargets,
      FuncTypes.gainNpFromTargets,
      // FuncTypes.absorbNpturn,
      FuncTypes.gainNpBuffIndividualSum,
    ],
    name: const LocalizedText(chs: 'NP増加', jpn: 'NP増加', eng: 'Charge NP', kor: 'NP차지'),
  );

  static EffectType shortenSkill = EffectType(
    key: 'shortenSkill',
    funcs: [FuncTypes.shortenSkill],
    name: const LocalizedText(
        chs: '技能冷却减小', jpn: 'スキルターン減少', eng: 'Reduce Cooldowns', kor: '스킬 쿨타임 감소'),
  );

  static EffectType pierceDefence = EffectType(
    key: 'pierceDefence',
    funcs: [FuncTypes.damageNpPierce],
    buffs: [BuffTypes.pierceDefence],
    name: const LocalizedText(chs: '无视防御', jpn: '防御無視', eng: 'Pierce Defense', kor: '방어 무시'),
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
    name: const LocalizedText(
        chs: '宝具特攻', jpn: '宝具特攻', eng: 'NP supereffective damage', kor: '보구 특공'),
  );

  static EffectType expUp = EffectType(
    key: 'expUp',
    funcs: [FuncTypes.expUp],
    name: const LocalizedText(chs: '御主EXP', jpn: 'マスターEXP', eng: 'Master EXP', kor: '마스터 EXP'),
  );
  static EffectType qpUp = EffectType(
    key: 'qpUp',
    funcs: [FuncTypes.qpUp, FuncTypes.qpDropUp],
    name: const LocalizedText(chs: 'QP', jpn: 'QP', eng: 'QP', kor: 'QP'),
  );
  static EffectType friendPointUp = EffectType(
    key: 'friendPointUp',
    funcs: [FuncTypes.friendPointUp, FuncTypes.friendPointUpDuplicate],
    name: const LocalizedText(chs: '友情点', jpn: 'フレンドポイント', eng: 'Friend Point', kor: '친구 포인트'),
  );
  static EffectType bondPointUp = EffectType(
    key: 'bondPointUp',
    funcs: [FuncTypes.servantFriendshipUp],
    name: const LocalizedText(chs: '羁绊', jpn: '絆', eng: 'Bond Point', kor: '인연 포인트'),
  );
  static EffectType userEquipExpUp = EffectType(
    key: 'userEquipExpUp',
    funcs: [FuncTypes.userEquipExpUp],
    name: const LocalizedText(chs: '魔术礼装', jpn: '魔術礼装', eng: 'Mystic Code', kor: '마술 예장'),
  );

  // buffs

  static EffectType artsPerform = EffectType(
    key: 'artsPerform',
    buffs: [BuffTypes.upCommandall],
    name: const LocalizedText(chs: 'Arts', jpn: 'Arts', eng: 'Arts', kor: 'Arts'),
    testBuff: (buff) => buff.name.contains('Arts'),
  );
  static EffectType quickPerform = EffectType(
    key: 'quickPerform',
    buffs: [BuffTypes.upCommandall],
    name: const LocalizedText(chs: 'Quick', jpn: 'Quick', eng: 'Quick', kor: 'Quick'),
    testBuff: (buff) => buff.name.contains('Quick'),
  );
  static EffectType busterPerform = EffectType(
    key: 'busterPerform',
    buffs: [
      BuffTypes.upCommandall,
      BuffTypes.downCommandall,
      BuffTypes.downDefencecommandall
    ],
    name: const LocalizedText(chs: 'Buster', jpn: 'Buster', eng: 'Buster', kor: 'Buster'),
    testBuff: (buff) => buff.name.contains('Buster'),
  );

  static EffectType starWeight = EffectType(
    key: 'starWeight',
    buffs: [BuffTypes.upStarweight, BuffTypes.downStarweight],
    name: const LocalizedText(chs: '集星', jpn: 'スター集中', eng: 'Star Weight', kor: '스타 집중'),
  );

  static EffectType starRate = EffectType(
    key: 'starRate',
    buffs: [BuffTypes.upCriticalpoint, BuffTypes.downCriticalpoint],
    name: const LocalizedText(chs: '出星率', jpn: 'スター発生', eng: 'Star Drop Rate', kor: '스타 발생율'),
  );

  static EffectType regainNp = EffectType(
    key: 'regainNp',
    buffs: [BuffTypes.regainNp],
    name: const LocalizedText(chs: '每回合NP', jpn: '毎ターンNP', eng: 'NP per turn', kor: '턴당 NP 차지'),
  );

  static EffectType regainHp = EffectType(
    key: 'regainHp',
    buffs: [BuffTypes.regainHp],
    name: const LocalizedText(chs: '每回合HP', jpn: '毎ターンHP', eng: 'HP per turn', kor: '턴당 HP 회복'),
  );

  static EffectType upAtk = EffectType(
    key: 'upAtk',
    buffs: [BuffTypes.upAtk],
    name: const LocalizedText(chs: '攻击力', jpn: '攻撃力', eng: 'Attack Up', kor: '공격력 증가'),
  );

  static EffectType upDamage = EffectType(
    key: 'upDamage',
    buffs: [BuffTypes.upDamage, BuffTypes.upDamageIndividualityActiveonly],
    name: const LocalizedText(chs: '威力提升', jpn: '威力アップ', eng: 'SP.DMG Up', kor: '위력 증가'),
  );

  static EffectType addDamage = EffectType(
    key: 'addDamage',
    buffs: [BuffTypes.addDamage],
    name: const LocalizedText(chs: '附加伤害', jpn: '威力アップ', eng: 'Damage Plus', kor: '데미지 플러스'),
  );

  static EffectType npDamage = EffectType(
    key: 'npDamage',
    buffs: [BuffTypes.upNpdamage, BuffTypes.downNpdamage],
    name: const LocalizedText(chs: '宝威', jpn: '宝具威力', eng: 'NP Damage Up', kor: '보구 데미지 증가'),
  );

  static EffectType upDropnp = EffectType(
    key: 'upDropnp',
    buffs: [BuffTypes.upDropnp, BuffTypes.upDamagedropnp],
    name: const LocalizedText(chs: 'NP获得率', jpn: 'NP獲得率', eng: 'NP Gain Up', kor: 'NP수급률 증가'),
  );

  static EffectType upCriticaldamage = EffectType(
    key: 'upCriticaldamage',
    buffs: [BuffTypes.upCriticaldamage],
    name: const LocalizedText(
        chs: '暴击威力', jpn: 'クリティカル威力', eng: 'Critical Damage', kor: '크리티컬 데미지'),
  );

  static EffectType subSelfdamage = EffectType(
    key: 'subSelfdamage',
    buffs: [BuffTypes.subSelfdamage],
    name: const LocalizedText(chs: '减伤', jpn: '被ダメージカット', eng: 'Damage Cut', kor: '데미지 컷'),
  );

  static EffectType avoidance = EffectType(
    key: 'avoidance',
    buffs: [BuffTypes.avoidance],
    name: const LocalizedText(chs: '回避', jpn: '回避', eng: 'Evade', kor: '회피'),
  );

  static EffectType breakAvoidance = EffectType(
    key: 'breakAvoidance',
    buffs: [BuffTypes.breakAvoidance],
    name: const LocalizedText(chs: '必中', jpn: '必中', eng: 'Sure Hit', kor: '필중'),
  );

  static EffectType invincible = EffectType(
    key: 'invincible',
    buffs: [BuffTypes.invincible],
    name: const LocalizedText(chs: '无敌', jpn: '無敵', eng: 'Invincible', kor: '무적'),
  );

  static EffectType pierceInvincible = EffectType(
    key: 'pierceInvincible',
    buffs: [BuffTypes.pierceInvincible],
    name:
        const LocalizedText(chs: '无敌贯通', jpn: '無敵貫通', eng: 'Ignore Invincible', kor: '무적 관통'),
  );

  static EffectType upGrantstate = EffectType(
    key: 'upGrantstate',
    buffs: [BuffTypes.upGrantstate],
    name: const LocalizedText(
        chs: '状态赋予率', jpn: '状態付与率', eng: 'Effect Chance Up', kor: '상태 부여 확률'),
  );

  static EffectType upTolerance = EffectType(
    key: 'upTolerance',
    buffs: [BuffTypes.upTolerance],
    name:
        const LocalizedText(chs: '耐性提升', jpn: '耐性アップ', eng: 'Debuff Tolerance', kor: '디버프 내성'),
  );

  static EffectType avoidState = EffectType(
    key: 'avoidState',
    buffs: [BuffTypes.avoidState],
    name: const LocalizedText(
        chs: '弱体无效', jpn: '弱体無効', eng: 'Immunity vs Debuff', kor: '약체 무효'),
  );

  static EffectType donotAct = EffectType(
    key: 'donotAct',
    buffs: [BuffTypes.donotAct],
    name: const LocalizedText(chs: '行动不能', jpn: '行動不能', eng: 'Donot Act', kor: '행동 불가'),
  );

  static EffectType donotSkill = EffectType(
    key: 'donotSkill',
    buffs: [BuffTypes.donotSkill],
    name: const LocalizedText(chs: '技能封印', jpn: 'スキル封印', eng: 'Skill Seal', kor: '스킬 봉인'),
  );

  static EffectType donotNoble = EffectType(
    key: 'donotNoble',
    buffs: [BuffTypes.donotNoble],
    name: const LocalizedText(chs: '宝具封印', jpn: '宝具封印', eng: 'NP Seal', kor: '보구 봉인'),
  );

  static EffectType guts = EffectType(
    key: 'guts',
    buffs: [BuffTypes.guts, BuffTypes.gutsRatio],
    name: const LocalizedText(chs: '毅力', jpn: 'ガッツ', eng: 'Guts', kor: '거츠'),
  );

  static EffectType upHate = EffectType(
    key: 'upHate',
    buffs: [BuffTypes.upHate],
    name: const LocalizedText(chs: '目标集中度', jpn: 'タゲ集中', eng: 'Taunt', kor: '스턴'),
  );

  static EffectType upDefence = EffectType(
    key: 'upDefence',
    buffs: [BuffTypes.upDefence],
    name: const LocalizedText(chs: '防御力提升', jpn: '防御力アップ', eng: 'Defence Up', kor: '방어력 증가'),
  );

  static EffectType downDefence = EffectType(
    key: 'downDefence',
    buffs: [BuffTypes.downDefence],
    name: const LocalizedText(chs: '防御力下降', jpn: '防御力ダウン', eng: 'Defence Down', kor: '방어력 감소'),
  );

  static EffectType avoidInstantdeath = EffectType(
    key: 'avoidInstantdeath',
    buffs: [BuffTypes.avoidInstantdeath],
    name: const LocalizedText(chs: '即死无效', jpn: '即死無効', eng: 'Immune to Death', kor: '즉사 무효'),
  );

  static EffectType resistInstantdeath = EffectType(
    key: 'resistInstantdeath',
    buffs: [
      BuffTypes.upResistInstantdeath,
      BuffTypes.upGrantInstantdeath,
      BuffTypes.upNonresistInstantdeath
    ],
    name: const LocalizedText(chs: '即死耐性', jpn: '即死耐性', eng: 'Death Resist', kor: '즉사 내성'),
  );
  static EffectType delayFunction = EffectType(
    key: 'delayFunction',
    buffs: [BuffTypes.delayFunction],
    name: const LocalizedText(chs: '延迟发动', jpn: '遅延発動', eng: 'Delayed Skill', kor: '지연 발동'),
  );
  static EffectType deadFunction = EffectType(
    key: 'deadFunction',
    buffs: [BuffTypes.deadFunction],
    name: const LocalizedText(chs: '死亡时发动', jpn: '死亡時発動', eng: 'Skill on Dead', kor: '사망시 발동'),
  );
  static EffectType entryFunction = EffectType(
    key: 'entryFunction',
    buffs: [BuffTypes.entryFunction],
    name: const LocalizedText(chs: '登场时发动', jpn: '登場時発動', eng: 'Skill on come', kor: '등장시 발동'),
  );
  static EffectType turnendFunction = EffectType(
    key: 'turnendFunction',
    buffs: [BuffTypes.selfturnendFunction],
    name: const LocalizedText(
        chs: '每回合发动', jpn: '毎ターン発動', eng: 'Skill every Turn', kor: '매 턴 발동'),
  );
  static EffectType upGainHp = EffectType(
    key: 'upGainHp',
    buffs: [BuffTypes.upGivegainHp, BuffTypes.upGainHp],
    name: const LocalizedText(chs: 'HP回复量', jpn: 'HP回復量', eng: 'Healing Up', kor: 'HP회복량'),
  );
  static EffectType upChagetd = EffectType(
    key: 'upChagetd',
    buffs: [BuffTypes.upChagetd],
    name: const LocalizedText(chs: 'OC', jpn: 'オーバーチャージ', eng: 'Over Charge', kor: '오버차지'),
  );
  static EffectType upToleranceSubstate = EffectType(
    key: 'upToleranceSubstate',
    buffs: [BuffTypes.upToleranceSubstate],
    name: const LocalizedText(
        chs: '强化解除耐性', jpn: '強化解除耐性', eng: 'Buff Removal Resistance', kor: '강화해제내성'),
  );
  static EffectType upFuncHpReduce = EffectType(
    key: 'upFuncHpReduce',
    buffs: [BuffTypes.upFuncHpReduce],
    name: const LocalizedText(
        chs: '呪厄/延焼/蝕毒', jpn: '呪厄/延焼/蝕毒', eng: 'DoT Effectiveness Up', kor: '주액/연소/식독'),
  );
  static EffectType fieldIndividuality = EffectType(
    key: 'fieldIndividuality',
    buffs: [BuffTypes.fieldIndividuality],
    name: const LocalizedText(
        chs: '场地特性赋予', jpn: 'フィールドセット', eng: 'Change Field Type', kor: '필드 변경'),
  );
  static EffectType commandattackFunction = EffectType(
    key: 'commandattackFunction',
    buffs: [BuffTypes.commandattackFunction],
    name: const LocalizedText(
        chs: '攻击时发动', jpn: '攻撃時発動', eng: 'Trigger Skill on Cards', kor: '공격시 발동'),
  );

  static EffectType commandcodeattackFunction = EffectType(
    key: 'commandcodeattackFunction',
    buffs: [BuffTypes.commandcodeattackFunction],
    name: const LocalizedText(
        chs: '指令纹章攻击时追加效果',
        jpn: 'コマンドコード攻撃時追加効果',
        eng: 'Cmd Code Effect when Attack', 
        kor: '공격시 커맨드 코드 발동'),
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
    gainStar, regainStar, starWeight, starRate,
    upGrantstate, upTolerance, resistInstantdeath, avoidInstantdeath,

    subState, avoidState, guts, upHate, shortenSkill,

    donotAct, donotNoble, donotSkill,

    commandattackFunction, deadFunction, turnendFunction, fieldIndividuality,
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
    gainStar, regainStar, starWeight, starRate,
    upGrantstate, upTolerance, resistInstantdeath,

    avoidState, guts, upHate,

    commandattackFunction, deadFunction, entryFunction,
  ];
  static final List<EffectType> cmdCodeEffects = [
    ...craftEffects,
    commandcodeattackFunction,
  ];

  static final Map<String, EffectType> svtEffectsMap = {
    for (final eff in svtEffects) eff.key: eff,
  };

  static final Map<String, EffectType> craftEffectsMap = {
    for (final eff in craftEffects) eff.key: eff,
  };
  static final Map<String, EffectType> cmdCodeEffectsMap = {
    for (final eff in cmdCodeEffects) eff.key: eff,
  };

  static final Map<String, EffectType> validEffectsMap = {
    for (final eff in svtEffects) eff.key: eff,
    for (final eff in craftEffects) eff.key: eff,
  };

  static Map<String, FuncBuffTypeBase> get allFuncBuff => Map.fromEntries([
        ...FuncTypes.withoutAddState.entries,
        ...BuffTypes.all.entries,
      ]);
}

void initiateFuncBuffInstances() {
  // static fields and library variables are only initiated when called once
  FuncTypes.addState.nameCn + BuffTypes.regainNp.nameCn;

  final sortedFuncs = Map.fromEntries(
      FuncTypes.all.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  FuncTypes.all
    ..clear()
    ..addAll(sortedFuncs);
  final sortedBuffs = Map.fromEntries(
      BuffTypes.all.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  BuffTypes.all
    ..clear()
    ..addAll(sortedBuffs);

  print('${FuncTypes.all.length} FuncTypes, ${BuffTypes.all.length} BuffTypes');
}
