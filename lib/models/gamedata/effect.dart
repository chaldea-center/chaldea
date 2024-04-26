// ignore_for_file: unused_element

import 'package:chaldea/utils/utils.dart';
import 'common.dart';
import 'mappings.dart';
import 'skill.dart';

class SkillEffect {
  String effectType;
  List<FuncType> funcTypes;
  List<BuffType> buffTypes;
  // Transl<String, String> Function(SkillEffect effect) name;
  bool Function(BaseFunction func)? validate;

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
    final fistType = buffTypes.getOrNull(0)?.name ?? funcTypes.getOrNull(0)?.name;
    if (effectType != fistType) {
      return Transl.string({}, effectType);
    }
    if (buffTypes.isNotEmpty) {
      return Transl.buffType(buffTypes.first);
    }
    return Transl.funcType(funcTypes.first);
  }

  String get lName {
    String s = transl.l;
    return validate == null ? s : '$s*';
  }

  bool match(BaseFunction func) {
    if (funcTypes.contains(func.funcType) || func.buffs.any((buff) => buffTypes.contains(buff.type))) {
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

  static List<SkillEffect> values = [...kAttack, ...kDefence, ...kDebuffRelated, ...kOthers];
  static List<SkillEffect> kAttack = [
    upAtk,
    upQuick,
    upArts,
    upBuster,
    upDamage,
    addDamage,
    upCriticaldamage,
    upCriticalpoint,
    upStarweight,
    gainStar,
    regainStar,
    damageNpSP,
    upNpdamage,
    gainNp,
    regainNp,
    upDropnp,
    upChagetd,
    breakAvoidance,
    pierceInvincible,
    pierceDefence,
  ];
  static List<SkillEffect> kDefence = [
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
  ];
  static List<SkillEffect> kDebuffRelated = [
    reduceHp,
    upTolerance,
    avoidStateNegative,
    upGrantstate,
    upGrantstatePositive,
    upGrantstateNegative,
    upReceivePositiveEffect,
    subState,
    subStatePositive,
    subStateNegative,
    upToleranceSubstate,
    instantDeath,
    upResistInstantdeath,
    upGrantInstantdeath,
    avoidInstantdeath,
  ];
  static List<SkillEffect> kOthers = [
    friendPointUp,
    expUp,
    userEquipExpUp,
    servantFriendshipUp,
    qpUp,
    eventDropUp,
    triggerFunc,
    shortenSkill,
    fieldIndividuality,
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
    SkillEffect.subStatePositive,
    SkillEffect.shortenSkill,
    SkillEffect.fieldIndividuality,
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
    SkillEffect.upGrantstatePositive,
    SkillEffect.upGrantstateNegative,
    SkillEffect.instantDeath,
    SkillEffect.upResistInstantdeath,
    SkillEffect.upGrantInstantdeath,
    SkillEffect.avoidInstantdeath,
    SkillEffect.subStatePositive,
    SkillEffect.shortenSkill,
    SkillEffect.fieldIndividuality,
    ...svtIgnores,
  ];

  static List<SkillEffect> get mcIgnores => [
        SkillEffect.upDamage,
        SkillEffect.addDamage,
        SkillEffect.regainStar,
        SkillEffect.damageNpSP,
        SkillEffect.regainNp,
        SkillEffect.upDefence,
        SkillEffect.subSelfdamage,
        SkillEffect.upHate,
        SkillEffect.downCriticalRateDamageTaken,
        SkillEffect.upGainHp,
        SkillEffect.upTolerance,
        SkillEffect.upGrantstate,
        SkillEffect.upGrantstatePositive,
        SkillEffect.upGrantstateNegative,
        SkillEffect.upReceivePositiveEffect,
        SkillEffect.subStatePositive,
        SkillEffect.instantDeath,
        SkillEffect.upResistInstantdeath,
        SkillEffect.upGrantInstantdeath,
        SkillEffect.avoidInstantdeath,
        SkillEffect.friendPointUp,
        SkillEffect.expUp,
        SkillEffect.userEquipExpUp,
        SkillEffect.servantFriendshipUp,
        SkillEffect.qpUp,
        SkillEffect.eventDropUp,
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
    validate: (func) => func.buffs.any((buff) => buff.ckSelfIndv.any((trait) => trait.name == Trait.cardQuick)),
  );
  static SkillEffect upArts = SkillEffect(
    'upArts',
    buffTypes: [BuffType.upCommandall],
    validate: (func) => func.buffs.any((buff) => buff.ckSelfIndv.any((trait) => trait.name == Trait.cardArts)),
  );
  static SkillEffect upBuster = SkillEffect(
    'upBuster',
    buffTypes: [BuffType.upCommandall],
    validate: (func) => func.buffs.any((buff) => buff.ckSelfIndv.any((trait) => trait.name == Trait.cardBuster)),
  );
  // static SkillEffect upExtraAttack=SkillEffect(
  //   'upExtraAttack',
  //   buffTypes: [BuffType.upCommandall],
  //   validate: (func)=>func.buffs.any((buff) => buff.ckSelfIndv.any((trait) => trait.name==Trait.cardExtra)),
  // );
  static SkillEffect upDamage = SkillEffect(
    'upDamage',
    buffTypes: [BuffType.upDamage, BuffType.upDamageIndividuality, BuffType.upDamageIndividualityActiveonly],
  );
  static SkillEffect addDamage = SkillEffect._buff('addDamage', BuffType.addDamage);
  static SkillEffect upCriticaldamage = SkillEffect._buff('upCriticaldamage', BuffType.upCriticaldamage);
  static SkillEffect upCriticalpoint = SkillEffect._buff('upCriticalpoint', BuffType.upCriticalpoint);
  static SkillEffect upStarweight = SkillEffect._buff('upStarweight', BuffType.upStarweight);
  static SkillEffect gainStar = SkillEffect._func('gainStar', FuncType.gainStar);
  static SkillEffect regainStar = SkillEffect._buff('regainStar', BuffType.regainStar);
  static SkillEffect upNpdamage = SkillEffect._buff('upNpdamage', BuffType.upNpdamage);
  static SkillEffect gainNp = SkillEffect('gainNp', funcTypes: [
    FuncType.gainNp,
    FuncType.gainNpFromTargets,
    FuncType.gainNpBuffIndividualSum,
    FuncType.gainMultiplyNp
  ]);
  static SkillEffect regainNp = SkillEffect._buff('regainNp', BuffType.regainNp);
  static SkillEffect upDropnp = SkillEffect._buff('upDropnp', BuffType.upDropnp);
  static SkillEffect upChagetd = SkillEffect._buff('upChagetd', BuffType.upChagetd);
  static SkillEffect breakAvoidance = SkillEffect._buff('breakAvoidance', BuffType.breakAvoidance);
  static SkillEffect pierceInvincible = SkillEffect._buff('pierceInvincible', BuffType.pierceInvincible);
  static SkillEffect pierceDefence = SkillEffect(
    'pierceDefence',
    buffTypes: [BuffType.pierceDefence],
    funcTypes: [FuncType.damageNpPierce],
  );

  /// defense side
  static SkillEffect upDefence = SkillEffect._buff('upDefence', BuffType.upDefence);
  static SkillEffect subSelfdamage = SkillEffect._buff('subSelfdamage', BuffType.subSelfdamage);
  static SkillEffect avoidance =
      SkillEffect('avoidance', buffTypes: [BuffType.avoidance, BuffType.avoidanceIndividuality]);
  static SkillEffect invincible = SkillEffect._buff('invincible', BuffType.invincible);
  static SkillEffect guts = SkillEffect('guts', buffTypes: [BuffType.guts, BuffType.gutsRatio]);
  static SkillEffect upHate = SkillEffect._buff('upHate', BuffType.upHate);
  static SkillEffect downCriticalRateDamageTaken =
      SkillEffect._buff('downCriticalRateDamageTaken', BuffType.downCriticalRateDamageTaken);
  static SkillEffect gainHp =
      SkillEffect('gainHp', funcTypes: [FuncType.gainHp, FuncType.gainHpFromTargets, FuncType.gainHpPer]);
  static SkillEffect upGainHp = SkillEffect('upGainHp', buffTypes: [BuffType.upGainHp, BuffType.upGivegainHp]);
  static SkillEffect regainHp = SkillEffect._buff('regainHp', BuffType.regainHp);
  static SkillEffect addMaxhp = SkillEffect._buff('addMaxhp', BuffType.addMaxhp);

  /// 状态异常系
  // 弱体耐性提升
  static SkillEffect reduceHp = SkillEffect._buff('reduceHp', BuffType.reduceHp);
  static SkillEffect upTolerance = SkillEffect(
    'upTolerance',
    buffTypes: [BuffType.upTolerance],
    validate: (func) => func.buffs.first.ckOpIndv
        .every((trait) => ![Trait.buffPositiveEffect, Trait.buffIncreaseDamage].contains(trait.name)),
  );
  // 弱体无效
  static SkillEffect avoidStateNegative = SkillEffect(
    'avoidStateNegative',
    buffTypes: [BuffType.avoidState],
    validate: (func) => func.buffs.first.ckOpIndv
        .every((trait) => ![Trait.buffPositiveEffect, Trait.buffIncreaseDamage].contains(trait.name)),
  );
  // 状态付与成功率提升
  static SkillEffect upGrantstate = SkillEffect._buff('upGrantstate', BuffType.upGrantstate);
  static SkillEffect upGrantstatePositive = SkillEffect._buff('upGrantstatePositive', BuffType.upGrantstate,
      validate: (func) =>
          func.buffs.any((buff) => buff.ckSelfIndv.any((trait) => trait.name == Trait.buffPositiveEffect)));
  static SkillEffect upGrantstateNegative = SkillEffect._buff('upGrantstateNegative', BuffType.upGrantstate,
      validate: (func) =>
          func.buffs.any((buff) => buff.ckSelfIndv.any((trait) => trait.name == Trait.buffNegativeEffect)));
  // 被强化成功率提升
  static SkillEffect upReceivePositiveEffect = SkillEffect(
    'upReceivePositiveEffect',
    buffTypes: [BuffType.downTolerance],
    validate: (func) => func.buffs.first.ckOpIndv.any((trait) => trait.name == Trait.buffPositiveEffect),
  );
  // 解除Buff
  static SkillEffect subState = SkillEffect._func('subState', FuncType.subState);
  static SkillEffect subStatePositive = SkillEffect._func('subStatePositive', FuncType.subState,
      validate: (func) => func.traitVals.any((e) => e.name == Trait.buffPositiveEffect));
  static SkillEffect subStateNegative = SkillEffect._func('subStateNegative', FuncType.subState,
      validate: (func) => func.traitVals.any((e) => e.name == Trait.buffNegativeEffect));
  // 强化解除耐性提升
  static SkillEffect upToleranceSubstate = SkillEffect._buff('upToleranceSubstate', BuffType.upToleranceSubstate);
  // 即死
  static SkillEffect instantDeath =
      SkillEffect('instantDeath', funcTypes: [FuncType.instantDeath, FuncType.forceInstantDeath]);
  // 即死耐性提升
  static SkillEffect upResistInstantdeath = SkillEffect._buff('upResistInstantdeath', BuffType.upResistInstantdeath);
  // 即死成功率提升
  static SkillEffect upGrantInstantdeath = SkillEffect._buff('upGrantInstantdeath', BuffType.upGrantInstantdeath);
  // 即死无效
  static SkillEffect avoidInstantdeath = SkillEffect._buff('avoidInstantdeath', BuffType.avoidInstantdeath);
  // special
  static SkillEffect shortenSkill = SkillEffect._func('shortenSkill', FuncType.shortenSkill);
  static SkillEffect fieldIndividuality =
      SkillEffect('fieldIndividuality', buffTypes: [BuffType.fieldIndividuality, BuffType.toFieldChangeField]);

  /// 辅助系
  static SkillEffect friendPointUp = SkillEffect(
    'friendPointUp',
    funcTypes: [FuncType.friendPointUp, FuncType.friendPointUpDuplicate],
  );
  static SkillEffect expUp = SkillEffect._func('expUp', FuncType.expUp);
  static SkillEffect userEquipExpUp = SkillEffect._func('userEquipExpUp', FuncType.userEquipExpUp);
  static SkillEffect servantFriendshipUp = SkillEffect._func('servantFriendshipUp', FuncType.servantFriendshipUp);
  static SkillEffect qpUp = SkillEffect(
    'qpUp',
    funcTypes: [FuncType.qpUp, FuncType.qpDropUp],
  );
  static SkillEffect eventDropUp = SkillEffect(
    'eventDropUp',
    funcTypes: [
      FuncType.eventDropUp,
      FuncType.eventDropRateUp,
      FuncType.dropUp,
      FuncType.classDropUp,
      FuncType.eventPointUp,
      FuncType.eventFortificationPointUp,
      FuncType.buddyPointUp,
    ],
  );
  // 特定时发动
  static SkillEffect triggerFunc = SkillEffect(
    'triggerFunc',
    funcTypes: [FuncType.addState, FuncType.addStateShort],
    validate: (func) => kBuffValueTriggerTypes.containsKey(func.buffs.first.type),
  );
}
