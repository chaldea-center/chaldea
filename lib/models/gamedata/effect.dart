// ignore_for_file: unused_element

import 'common.dart';
import 'mappings.dart';
import 'skill.dart';

class SkillEffect {
  String effectType;
  List<FuncType> funcTypes;
  List<BuffType> buffTypes;
  // Transl<String, String> Function(SkillEffect effect) name;
  bool Function(NiceFunction func)? validate;

  SkillEffect(
    this.effectType, {
    this.funcTypes = const [],
    this.buffTypes = const [],
    this.validate,
  }) : assert(funcTypes.isNotEmpty || buffTypes.isNotEmpty);

  Transl<String, String> get transl {
    var mapping = Transl.md.enums.effectType[effectType];
    if (mapping != null) {
      return Transl(Transl.md.enums.effectType, effectType, effectType);
    }
    if (buffTypes.isNotEmpty) {
      return Transl.buffType(buffTypes.first);
    }
    return Transl.funcType(funcTypes.first);
  }

  bool match(NiceFunction func) {
    if (funcTypes.contains(func.funcType) ||
        func.buffs.any((buff) => buffTypes.contains(buff.type))) {
      if (validate != null) return validate!(func);
      return true;
    }
    return false;
  }

  SkillEffect._buff(
    this.effectType,
    BuffType buffType, {
    this.validate,
  })  : buffTypes = [buffType],
        funcTypes = [];
  SkillEffect._func(
    this.effectType,
    FuncType funcType, {
    this.validate,
  })  : buffTypes = [],
        funcTypes = [funcType];

  static List<SkillEffect> values = [
    damageNpSP,
    upAtk,
    upQuick,
    upArts,
    upBuster,
    upDamange,
    addDamage,
    upCriticaldamage,
    upCriticalpoint,
    upStarweight,
    gainStar,
    regainStar,
    upNpdamage,
    gainNp,
    regainNp,
    upDropnp,
    upChagetd,
    breakAvoidance,
    pierceInvincible,
    pierceDefence,
    upDefence,
    subSelfdamage,
    avoidance,
    invincible,
    guts,
    upHate,
    downCriticalRateDamageTaken,
    gainHp,
    upGainHp,
    regainHp,
    addMaxhp,
    upTolerance,
    avoidState,
    upGrantstate,
    upReceivePositiveEffect,
    upToleranceSubstate,
    upResistInstantdeath,
    upGrantInstantdeath,
    avoidInstantdeath,
    friendPointUp,
    expUp,
    userEquipExpUp,
    servantFriendshipUp,
    qpUp,
    triggerFunc,
    eventDropUp,
  ];

  static List<SkillEffect> svtIgnores = [
    SkillEffect.friendPointUp,
    SkillEffect.expUp,
    SkillEffect.userEquipExpUp,
    SkillEffect.servantFriendshipUp,
    SkillEffect.qpUp,
    SkillEffect.eventDropUp,
  ];
  static List<SkillEffect> ceIgnores = [
    SkillEffect.damageNpSP,
  ];
  static List<SkillEffect> ccIgnores = [
    SkillEffect.damageNpSP,
    // SkillEffect.upAtk,
    SkillEffect.regainStar,
    SkillEffect.regainNp,
    SkillEffect.upChagetd,
    // SkillEffect.upDefence,
    SkillEffect.avoidance,
    SkillEffect.invincible,
    SkillEffect.guts,
    SkillEffect.upHate,
    SkillEffect.downCriticalRateDamageTaken,
    SkillEffect.regainHp,
    SkillEffect.addMaxhp,
    SkillEffect.upGrantstate,
    SkillEffect.upResistInstantdeath,
    SkillEffect.upGrantInstantdeath,
    SkillEffect.avoidInstantdeath,
    ...svtIgnores,
  ];

  /// most in official CE filter
  static SkillEffect damageNpSP = SkillEffect(
    'damageNpSP',
    funcTypes: [
      FuncType.damageNpIndividual,
      FuncType.damageNpIndividualSum,
      FuncType.damageNpRare,
      FuncType.damageNpStateIndividualFix,
      FuncType.damageNpHpratioLow,
      // FuncType.damageNpStateIndividual,
      // FuncType.damageNpAndCheckIndividuality,
      // FuncType.damageNpHpratioHigh
    ],
  );

  /// attack side
  static SkillEffect upAtk = SkillEffect(
    'upAtk',
    buffTypes: [BuffType.upAtk, BuffType.upCommandatk],
  );
  static SkillEffect upQuick = SkillEffect(
    'upQuick',
    buffTypes: [BuffType.upCommandall],
    validate: (func) => func.buffs.any((buff) =>
        buff.ckSelfIndv.any((trait) => trait.name == Trait.cardQuick)),
  );
  static SkillEffect upArts = SkillEffect(
    'upArts',
    buffTypes: [BuffType.upCommandall],
    validate: (func) => func.buffs.any(
        (buff) => buff.ckSelfIndv.any((trait) => trait.name == Trait.cardArts)),
  );
  static SkillEffect upBuster = SkillEffect(
    'upBuster',
    buffTypes: [BuffType.upCommandall],
    validate: (func) => func.buffs.any((buff) =>
        buff.ckSelfIndv.any((trait) => trait.name == Trait.cardBuster)),
  );
  // static SkillEffect upExtraAttack=SkillEffect(
  //   'upExtraAttack',
  //   buffTypes: [BuffType.upCommandall],
  //   validate: (func)=>func.buffs.any((buff) => buff.ckSelfIndv.any((trait) => trait.name==Trait.cardExtra)),
  // );
  static SkillEffect upDamange = SkillEffect(
    'upDamange',
    buffTypes: [BuffType.upDamage, BuffType.upDamageIndividualityActiveonly],
  );
  static SkillEffect addDamage =
      SkillEffect._buff('addDamage', BuffType.addDamage);
  static SkillEffect upCriticaldamage =
      SkillEffect._buff('upCriticaldamage', BuffType.upCriticaldamage);
  static SkillEffect upCriticalpoint =
      SkillEffect._buff('upCriticalpoint', BuffType.upCriticalpoint);
  static SkillEffect upStarweight =
      SkillEffect._buff('upStarweight', BuffType.upStarweight);
  static SkillEffect gainStar =
      SkillEffect._func('gainStar', FuncType.gainStar);
  static SkillEffect regainStar =
      SkillEffect._buff('regainStar', BuffType.regainStar);
  static SkillEffect upNpdamage =
      SkillEffect._buff('upNpdamage', BuffType.upNpdamage);
  static SkillEffect gainNp = SkillEffect('gainNp', funcTypes: [
    FuncType.gainNp,
    FuncType.gainNpFromTargets,
    FuncType.gainNpBuffIndividualSum
  ]);
  static SkillEffect regainNp =
      SkillEffect._buff('regainNp', BuffType.regainNp);
  static SkillEffect upDropnp =
      SkillEffect._buff('upDropnp', BuffType.upDropnp);
  static SkillEffect upChagetd =
      SkillEffect._buff('upChagetd', BuffType.upChagetd);
  static SkillEffect breakAvoidance =
      SkillEffect._buff('breakAvoidance', BuffType.breakAvoidance);
  static SkillEffect pierceInvincible =
      SkillEffect._buff('pierceInvincible', BuffType.pierceInvincible);
  static SkillEffect pierceDefence = SkillEffect(
    'pierceDefence',
    buffTypes: [BuffType.pierceDefence],
    funcTypes: [FuncType.damageNpPierce],
  );

  /// defense side
  static SkillEffect upDefence =
      SkillEffect._buff('upDefence', BuffType.upDefence);
  static SkillEffect subSelfdamage =
      SkillEffect._buff('subSelfdamage', BuffType.subSelfdamage);
  static SkillEffect avoidance = SkillEffect('avoidance',
      buffTypes: [BuffType.avoidance, BuffType.avoidanceIndividuality]);
  static SkillEffect invincible =
      SkillEffect._buff('invincible', BuffType.invincible);
  static SkillEffect guts =
      SkillEffect('guts', buffTypes: [BuffType.guts, BuffType.gutsRatio]);
  static SkillEffect upHate = SkillEffect._buff('upHate', BuffType.upHate);
  static SkillEffect downCriticalRateDamageTaken = SkillEffect._buff(
      'downCriticalRateDamageTaken', BuffType.downCriticalRateDamageTaken);
  static SkillEffect gainHp = SkillEffect('gainHp', funcTypes: [
    FuncType.gainHp,
    FuncType.gainHpFromTargets,
    FuncType.gainHpPer
  ]);
  static SkillEffect upGainHp = SkillEffect('upGainHp',
      buffTypes: [BuffType.upGainHp, BuffType.upGivegainHp]);
  static SkillEffect regainHp =
      SkillEffect._buff('regainHp', BuffType.regainHp);
  static SkillEffect addMaxhp =
      SkillEffect._buff('addMaxhp', BuffType.addMaxhp);

  /// 状态异常系
  // 弱体耐性提升
  static SkillEffect upTolerance = SkillEffect(
    'upTolerance',
    buffTypes: [BuffType.upTolerance],
    validate: (func) => func.buffs.first.ckOpIndv.every((trait) => ![
          Trait.buffPositiveEffect,
          Trait.buffIncreaseDamage
        ].contains(trait.name)),
  );
  // 弱体无效
  static SkillEffect avoidState = SkillEffect(
    'avoidState',
    buffTypes: [BuffType.avoidState],
    validate: (func) => func.buffs.first.ckOpIndv.every((trait) => ![
          Trait.buffPositiveEffect,
          Trait.buffIncreaseDamage
        ].contains(trait.name)),
  );
  // 状态付与成功率提升
  static SkillEffect upGrantstate =
      SkillEffect._buff('upGrantstate', BuffType.upGrantstate);
  // 被强化成功率提升
  static SkillEffect upReceivePositiveEffect = SkillEffect(
    'upReceivePositiveEffect',
    buffTypes: [BuffType.downTolerance],
    validate: (func) => func.buffs.first.ckOpIndv
        .any((trait) => trait.name == Trait.buffPositiveEffect),
  );
  // 强化解除耐性提升
  static SkillEffect upToleranceSubstate =
      SkillEffect._buff('upToleranceSubstate', BuffType.upToleranceSubstate);
  // 即死耐性提升
  static SkillEffect upResistInstantdeath =
      SkillEffect._buff('upResistInstantdeath', BuffType.upResistInstantdeath);
  // 即死成功率提升
  static SkillEffect upGrantInstantdeath =
      SkillEffect._buff('upGrantInstantdeath', BuffType.upGrantInstantdeath);
  // 即死无效
  static SkillEffect avoidInstantdeath =
      SkillEffect._buff('avoidInstantdeath', BuffType.avoidInstantdeath);

  /// 辅助系
  static SkillEffect friendPointUp = SkillEffect(
    'friendPointUp',
    funcTypes: [FuncType.friendPointUp, FuncType.friendPointUpDuplicate],
  );
  static SkillEffect expUp = SkillEffect._func('expUp', FuncType.expUp);
  static SkillEffect userEquipExpUp =
      SkillEffect._func('userEquipExpUp', FuncType.userEquipExpUp);
  static SkillEffect servantFriendshipUp =
      SkillEffect._func('servantFriendshipUp', FuncType.servantFriendshipUp);
  static SkillEffect qpUp = SkillEffect(
    'qpUp',
    funcTypes: [FuncType.qpUp, FuncType.qpDropUp],
  );
  static SkillEffect eventDropUp = SkillEffect(
    'eventDropUp',
    funcTypes: [
      FuncType.eventDropUp,
      FuncType.eventDropRateUp,
      FuncType.dropUp
    ],
  );
  // 特定时发动
  static SkillEffect triggerFunc = SkillEffect(
    'triggerFunc',
    funcTypes: [FuncType.addState, FuncType.addStateShort],
    validate: (func) =>
        kBuffValueTriggerTypes.containsKey(func.buffs.first.type),
  );
}
