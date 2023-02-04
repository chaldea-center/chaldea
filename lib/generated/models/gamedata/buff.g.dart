// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/buff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Buff _$BuffFromJson(Map json) => Buff(
      id: json['id'] as int,
      name: json['name'] as String,
      detail: json['detail'] as String,
      icon: json['icon'] as String?,
      type: json['type'] == null
          ? BuffType.unknown
          : const BuffTypeConverter().fromJson(json['type'] as String),
      buffGroup: json['buffGroup'] as int? ?? 0,
      script: json['script'] == null
          ? null
          : BuffScript.fromJson(
              Map<String, dynamic>.from(json['script'] as Map)),
      vals: (json['vals'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      ckSelfIndv: (json['ckSelfIndv'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      ckOpIndv: (json['ckOpIndv'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      maxRate: json['maxRate'] as int? ?? 0,
    );

BuffRelationOverwrite _$BuffRelationOverwriteFromJson(Map json) =>
    BuffRelationOverwrite(
      atkSide: (json['atkSide'] as Map).map(
        (k, e) => MapEntry(
            const SvtClassConverter().fromJson(k as String),
            (e as Map).map(
              (k, e) => MapEntry(
                  const SvtClassConverter().fromJson(k as String),
                  RelationOverwriteDetail.fromJson(
                      Map<String, dynamic>.from(e as Map))),
            )),
      ),
      defSide: (json['defSide'] as Map).map(
        (k, e) => MapEntry(
            const SvtClassConverter().fromJson(k as String),
            (e as Map).map(
              (k, e) => MapEntry(
                  const SvtClassConverter().fromJson(k as String),
                  RelationOverwriteDetail.fromJson(
                      Map<String, dynamic>.from(e as Map))),
            )),
      ),
    );

RelationOverwriteDetail _$RelationOverwriteDetailFromJson(Map json) =>
    RelationOverwriteDetail(
      damageRate: json['damageRate'] as int,
      type: $enumDecode(_$ClassRelationOverwriteTypeEnumMap, json['type']),
    );

const _$ClassRelationOverwriteTypeEnumMap = {
  ClassRelationOverwriteType.overwriteForce: 'overwriteForce',
  ClassRelationOverwriteType.overwriteMoreThanTarget: 'overwriteMoreThanTarget',
  ClassRelationOverwriteType.overwriteLessThanTarget: 'overwriteLessThanTarget',
};

BuffScript _$BuffScriptFromJson(Map json) => BuffScript(
      checkIndvType: json['checkIndvType'] as int?,
      CheckOpponentBuffTypes: (json['CheckOpponentBuffTypes'] as List<dynamic>?)
          ?.map((e) => const BuffTypeConverter().fromJson(e as String))
          .toList(),
      relationId: json['relationId'] == null
          ? null
          : BuffRelationOverwrite.fromJson(
              Map<String, dynamic>.from(json['relationId'] as Map)),
      ReleaseText: json['ReleaseText'] as String?,
      DamageRelease: json['DamageRelease'] as int?,
      INDIVIDUALITIE: json['INDIVIDUALITIE'] == null
          ? null
          : NiceTrait.fromJson(
              Map<String, dynamic>.from(json['INDIVIDUALITIE'] as Map)),
      INDIVIDUALITIE_COUNT_ABOVE: json['INDIVIDUALITIE_COUNT_ABOVE'] as int?,
      UpBuffRateBuffIndiv: (json['UpBuffRateBuffIndiv'] as List<dynamic>?)
          ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      HP_LOWER: json['HP_LOWER'] as int?,
      HP_HIGHER: json['HP_HIGHER'] as int?,
      CounterMessage: json['CounterMessage'] as String?,
      avoidanceText: json['avoidanceText'] as String?,
      gutsText: json['gutsText'] as String?,
      missText: json['missText'] as String?,
      AppId: json['AppId'] as String?,
      IncludeIgnoreIndividuality: json['IncludeIgnoreIndividuality'] as int?,
      ProgressSelfTurn: json['ProgressSelfTurn'] as int?,
      TargetIndiv: json['TargetIndiv'] == null
          ? null
          : NiceTrait.fromJson(
              Map<String, dynamic>.from(json['TargetIndiv'] as Map)),
      extendLowerLimit: json['extendLowerLimit'] as int?,
      convert: json['convert'] == null
          ? null
          : BuffConvert.fromJson(
              Map<String, dynamic>.from(json['convert'] as Map)),
    );

BuffConvert _$BuffConvertFromJson(Map json) => BuffConvert(
      targetLimit: $enumDecodeNullable(
              _$BuffConvertLimitTypeEnumMap, json['targetLimit']) ??
          BuffConvertLimitType.all,
      convertType:
          $enumDecodeNullable(_$BuffConvertTypeEnumMap, json['convertType']) ??
              BuffConvertType.none,
      targets: json['targets'] as List<dynamic>? ?? const [],
      convertBuffs: (json['convertBuffs'] as List<dynamic>?)
              ?.map((e) => Buff.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: json['script'] == null
          ? null
          : BuffConvertScript.fromJson(
              Map<String, dynamic>.from(json['script'] as Map)),
      effectId: json['effectId'] as int? ?? 0,
    );

const _$BuffConvertLimitTypeEnumMap = {
  BuffConvertLimitType.all: 'all',
  BuffConvertLimitType.self: 'self',
};

const _$BuffConvertTypeEnumMap = {
  BuffConvertType.none: 'none',
  BuffConvertType.buff: 'buff',
  BuffConvertType.individuality: 'individuality',
};

BuffConvertScript _$BuffConvertScriptFromJson(Map json) => BuffConvertScript(
      OverwritePopupText: (json['OverwritePopupText'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

const _$BuffTypeEnumMap = {
  BuffType.unknown: 'unknown',
  BuffType.none: 'none',
  BuffType.upCommandatk: 'upCommandatk',
  BuffType.upStarweight: 'upStarweight',
  BuffType.upCriticalpoint: 'upCriticalpoint',
  BuffType.downCriticalpoint: 'downCriticalpoint',
  BuffType.regainNp: 'regainNp',
  BuffType.regainStar: 'regainStar',
  BuffType.regainHp: 'regainHp',
  BuffType.reduceHp: 'reduceHp',
  BuffType.upAtk: 'upAtk',
  BuffType.downAtk: 'downAtk',
  BuffType.upDamage: 'upDamage',
  BuffType.downDamage: 'downDamage',
  BuffType.addDamage: 'addDamage',
  BuffType.subDamage: 'subDamage',
  BuffType.upNpdamage: 'upNpdamage',
  BuffType.downNpdamage: 'downNpdamage',
  BuffType.upDropnp: 'upDropnp',
  BuffType.upCriticaldamage: 'upCriticaldamage',
  BuffType.downCriticaldamage: 'downCriticaldamage',
  BuffType.upSelfdamage: 'upSelfdamage',
  BuffType.downSelfdamage: 'downSelfdamage',
  BuffType.addSelfdamage: 'addSelfdamage',
  BuffType.subSelfdamage: 'subSelfdamage',
  BuffType.avoidance: 'avoidance',
  BuffType.breakAvoidance: 'breakAvoidance',
  BuffType.invincible: 'invincible',
  BuffType.upGrantstate: 'upGrantstate',
  BuffType.downGrantstate: 'downGrantstate',
  BuffType.upTolerance: 'upTolerance',
  BuffType.downTolerance: 'downTolerance',
  BuffType.avoidState: 'avoidState',
  BuffType.donotAct: 'donotAct',
  BuffType.donotSkill: 'donotSkill',
  BuffType.donotNoble: 'donotNoble',
  BuffType.donotRecovery: 'donotRecovery',
  BuffType.disableGender: 'disableGender',
  BuffType.guts: 'guts',
  BuffType.upHate: 'upHate',
  BuffType.addIndividuality: 'addIndividuality',
  BuffType.subIndividuality: 'subIndividuality',
  BuffType.upDefence: 'upDefence',
  BuffType.downDefence: 'downDefence',
  BuffType.upCommandstar: 'upCommandstar',
  BuffType.upCommandnp: 'upCommandnp',
  BuffType.upCommandall: 'upCommandall',
  BuffType.downCommandall: 'downCommandall',
  BuffType.downStarweight: 'downStarweight',
  BuffType.reduceNp: 'reduceNp',
  BuffType.downDropnp: 'downDropnp',
  BuffType.upGainHp: 'upGainHp',
  BuffType.downGainHp: 'downGainHp',
  BuffType.downCommandatk: 'downCommandatk',
  BuffType.downCommanstar: 'downCommanstar',
  BuffType.downCommandnp: 'downCommandnp',
  BuffType.upCriticalrate: 'upCriticalrate',
  BuffType.downCriticalrate: 'downCriticalrate',
  BuffType.pierceInvincible: 'pierceInvincible',
  BuffType.avoidInstantdeath: 'avoidInstantdeath',
  BuffType.upResistInstantdeath: 'upResistInstantdeath',
  BuffType.upNonresistInstantdeath: 'upNonresistInstantdeath',
  BuffType.delayFunction: 'delayFunction',
  BuffType.regainNpUsedNoble: 'regainNpUsedNoble',
  BuffType.deadFunction: 'deadFunction',
  BuffType.upMaxhp: 'upMaxhp',
  BuffType.downMaxhp: 'downMaxhp',
  BuffType.addMaxhp: 'addMaxhp',
  BuffType.subMaxhp: 'subMaxhp',
  BuffType.battlestartFunction: 'battlestartFunction',
  BuffType.wavestartFunction: 'wavestartFunction',
  BuffType.selfturnendFunction: 'selfturnendFunction',
  BuffType.damageFunction: 'damageFunction',
  BuffType.upGivegainHp: 'upGivegainHp',
  BuffType.downGivegainHp: 'downGivegainHp',
  BuffType.commandattackFunction: 'commandattackFunction',
  BuffType.deadattackFunction: 'deadattackFunction',
  BuffType.upSpecialdefence: 'upSpecialdefence',
  BuffType.downSpecialdefence: 'downSpecialdefence',
  BuffType.upDamagedropnp: 'upDamagedropnp',
  BuffType.downDamagedropnp: 'downDamagedropnp',
  BuffType.entryFunction: 'entryFunction',
  BuffType.upChagetd: 'upChagetd',
  BuffType.reflectionFunction: 'reflectionFunction',
  BuffType.upGrantSubstate: 'upGrantSubstate',
  BuffType.downGrantSubstate: 'downGrantSubstate',
  BuffType.upToleranceSubstate: 'upToleranceSubstate',
  BuffType.downToleranceSubstate: 'downToleranceSubstate',
  BuffType.upGrantInstantdeath: 'upGrantInstantdeath',
  BuffType.downGrantInstantdeath: 'downGrantInstantdeath',
  BuffType.gutsRatio: 'gutsRatio',
  BuffType.upDefencecommandall: 'upDefencecommandall',
  BuffType.downDefencecommandall: 'downDefencecommandall',
  BuffType.overwriteBattleclass: 'overwriteBattleclass',
  BuffType.overwriteClassrelatioAtk: 'overwriteClassrelatioAtk',
  BuffType.overwriteClassrelatioDef: 'overwriteClassrelatioDef',
  BuffType.upDamageIndividuality: 'upDamageIndividuality',
  BuffType.downDamageIndividuality: 'downDamageIndividuality',
  BuffType.upDamageIndividualityActiveonly: 'upDamageIndividualityActiveonly',
  BuffType.downDamageIndividualityActiveonly:
      'downDamageIndividualityActiveonly',
  BuffType.upNpturnval: 'upNpturnval',
  BuffType.downNpturnval: 'downNpturnval',
  BuffType.multiattack: 'multiattack',
  BuffType.upGiveNp: 'upGiveNp',
  BuffType.downGiveNp: 'downGiveNp',
  BuffType.upResistanceDelayNpturn: 'upResistanceDelayNpturn',
  BuffType.downResistanceDelayNpturn: 'downResistanceDelayNpturn',
  BuffType.pierceDefence: 'pierceDefence',
  BuffType.upGutsHp: 'upGutsHp',
  BuffType.downGutsHp: 'downGutsHp',
  BuffType.upFuncgainNp: 'upFuncgainNp',
  BuffType.downFuncgainNp: 'downFuncgainNp',
  BuffType.upFuncHpReduce: 'upFuncHpReduce',
  BuffType.downFuncHpReduce: 'downFuncHpReduce',
  BuffType.upDefencecommanDamage: 'upDefencecommanDamage',
  BuffType.downDefencecommanDamage: 'downDefencecommanDamage',
  BuffType.npattackPrevBuff: 'npattackPrevBuff',
  BuffType.fixCommandcard: 'fixCommandcard',
  BuffType.donotGainnp: 'donotGainnp',
  BuffType.fieldIndividuality: 'fieldIndividuality',
  BuffType.donotActCommandtype: 'donotActCommandtype',
  BuffType.upDamageEventPoint: 'upDamageEventPoint',
  BuffType.upDamageSpecial: 'upDamageSpecial',
  BuffType.attackFunction: 'attackFunction',
  BuffType.commandcodeattackFunction: 'commandcodeattackFunction',
  BuffType.donotNobleCondMismatch: 'donotNobleCondMismatch',
  BuffType.donotSelectCommandcard: 'donotSelectCommandcard',
  BuffType.donotReplace: 'donotReplace',
  BuffType.shortenUserEquipSkill: 'shortenUserEquipSkill',
  BuffType.tdTypeChange: 'tdTypeChange',
  BuffType.overwriteClassRelation: 'overwriteClassRelation',
  BuffType.tdTypeChangeArts: 'tdTypeChangeArts',
  BuffType.tdTypeChangeBuster: 'tdTypeChangeBuster',
  BuffType.tdTypeChangeQuick: 'tdTypeChangeQuick',
  BuffType.commandattackBeforeFunction: 'commandattackBeforeFunction',
  BuffType.gutsFunction: 'gutsFunction',
  BuffType.upCriticalRateDamageTaken: 'upCriticalRateDamageTaken',
  BuffType.downCriticalRateDamageTaken: 'downCriticalRateDamageTaken',
  BuffType.upCriticalStarDamageTaken: 'upCriticalStarDamageTaken',
  BuffType.downCriticalStarDamageTaken: 'downCriticalStarDamageTaken',
  BuffType.skillRankUp: 'skillRankUp',
  BuffType.avoidanceIndividuality: 'avoidanceIndividuality',
  BuffType.changeCommandCardType: 'changeCommandCardType',
  BuffType.specialInvincible: 'specialInvincible',
  BuffType.preventDeathByDamage: 'preventDeathByDamage',
  BuffType.commandcodeattackAfterFunction: 'commandcodeattackAfterFunction',
  BuffType.attackBeforeFunction: 'attackBeforeFunction',
  BuffType.donotSkillSelect: 'donotSkillSelect',
  BuffType.buffRate: 'buffRate',
  BuffType.invisibleBattleChara: 'invisibleBattleChara',
  BuffType.counterFunction: 'counterFunction',
  BuffType.notTargetSkill: 'notTargetSkill',
  BuffType.hpReduceToRegain: 'hpReduceToRegain',
  BuffType.selfturnstartFunction: 'selfturnstartFunction',
  BuffType.overwriteDeadType: 'overwriteDeadType',
  BuffType.upActionCount: 'upActionCount',
  BuffType.downActionCount: 'downActionCount',
  BuffType.shiftGuts: 'shiftGuts',
  BuffType.shiftGutsRatio: 'shiftGutsRatio',
  BuffType.masterSkillValueUp: 'masterSkillValueUp',
  BuffType.buffConvert: 'buffConvert',
  BuffType.subFieldIndividuality: 'subFieldIndividuality',
  BuffType.toFieldChangeField: 'toFieldChangeField',
  BuffType.toFieldAvoidBuff: 'toFieldAvoidBuff',
  BuffType.toFieldSubIndividualityField: 'toFieldSubIndividualityField',
};
