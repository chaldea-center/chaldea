// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/buff.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Buff _$BuffFromJson(Map json) => Buff(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  detail: json['detail'] as String,
  icon: json['icon'] as String?,
  type: json['type'] == null ? BuffType.unknown : const BuffTypeConverter().fromJson(json['type'] as String),
  buffGroup: (json['buffGroup'] as num?)?.toInt() ?? 0,
  script: json['script'] == null ? null : BuffScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
  originalScript: (json['originalScript'] as Map?)?.map((k, e) => MapEntry(k as String, e)),
  vals:
      (json['vals'] as List<dynamic>?)?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
  tvals:
      (json['tvals'] as List<dynamic>?)?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
  ckSelfIndv:
      (json['ckSelfIndv'] as List<dynamic>?)
          ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  ckOpIndv:
      (json['ckOpIndv'] as List<dynamic>?)
          ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  maxRate: (json['maxRate'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BuffToJson(Buff instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'detail': instance.detail,
  'icon': instance.icon,
  'type': const BuffTypeConverter().toJson(instance.type),
  'buffGroup': instance.buffGroup,
  'script': instance.script.toJson(),
  'originalScript': instance.originalScript,
  'vals': instance.vals.map((e) => e.toJson()).toList(),
  'tvals': instance.tvals.map((e) => e.toJson()).toList(),
  'ckSelfIndv': instance.ckSelfIndv.map((e) => e.toJson()).toList(),
  'ckOpIndv': instance.ckOpIndv.map((e) => e.toJson()).toList(),
  'maxRate': instance.maxRate,
};

BuffRelationOverwrite _$BuffRelationOverwriteFromJson(Map json) => BuffRelationOverwrite(
  atkSide:
      (json['atkSide'] as Map?)?.map(
        (k, e) => MapEntry(
          k,
          (e as Map).map((k, e) => MapEntry(k, RelationOverwriteDetail.fromJson(Map<String, dynamic>.from(e as Map)))),
        ),
      ) ??
      const {},
  defSide:
      (json['defSide'] as Map?)?.map(
        (k, e) => MapEntry(
          k,
          (e as Map).map((k, e) => MapEntry(k, RelationOverwriteDetail.fromJson(Map<String, dynamic>.from(e as Map)))),
        ),
      ) ??
      const {},
);

Map<String, dynamic> _$BuffRelationOverwriteToJson(BuffRelationOverwrite instance) => <String, dynamic>{
  'atkSide': instance.atkSide.map(
    (k, e) => MapEntry(k.toString(), e.map((k, e) => MapEntry(k.toString(), e.toJson()))),
  ),
  'defSide': instance.defSide.map(
    (k, e) => MapEntry(k.toString(), e.map((k, e) => MapEntry(k.toString(), e.toJson()))),
  ),
};

RelationOverwriteDetail _$RelationOverwriteDetailFromJson(Map json) => RelationOverwriteDetail(
  damageRate: (json['damageRate'] as num).toInt(),
  type: $enumDecode(_$ClassRelationOverwriteTypeEnumMap, json['type']),
);

Map<String, dynamic> _$RelationOverwriteDetailToJson(RelationOverwriteDetail instance) => <String, dynamic>{
  'damageRate': instance.damageRate,
  'type': _$ClassRelationOverwriteTypeEnumMap[instance.type]!,
};

const _$ClassRelationOverwriteTypeEnumMap = {
  ClassRelationOverwriteType.overwriteForce: 'overwriteForce',
  ClassRelationOverwriteType.overwriteMoreThanTarget: 'overwriteMoreThanTarget',
  ClassRelationOverwriteType.overwriteLessThanTarget: 'overwriteLessThanTarget',
};

BuffScript _$BuffScriptFromJson(Map json) => BuffScript(
  checkIndvType: (json['checkIndvType'] as num?)?.toInt(),
  CheckOpponentBuffTypes: (json['CheckOpponentBuffTypes'] as List<dynamic>?)
      ?.map((e) => const BuffTypeConverter().fromJson(e as String))
      .toList(),
  relationId: json['relationId'] == null
      ? null
      : BuffRelationOverwrite.fromJson(Map<String, dynamic>.from(json['relationId'] as Map)),
  INDIVIDUALITIE: json['INDIVIDUALITIE'] == null
      ? null
      : NiceTrait.fromJson(Map<String, dynamic>.from(json['INDIVIDUALITIE'] as Map)),
  INDIVIDUALITIE_AND: (json['INDIVIDUALITIE_AND'] as List<dynamic>?)
      ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  INDIVIDUALITIE_OR: (json['INDIVIDUALITIE_OR'] as List<dynamic>?)
      ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  UpBuffRateBuffIndiv: (json['UpBuffRateBuffIndiv'] as List<dynamic>?)
      ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  TargetIndiv: json['TargetIndiv'] == null
      ? null
      : NiceTrait.fromJson(Map<String, dynamic>.from(json['TargetIndiv'] as Map)),
  convert: json['convert'] == null ? null : BuffConvert.fromJson(Map<String, dynamic>.from(json['convert'] as Map)),
  NotPierceIndividuality: (json['NotPierceIndividuality'] as List<dynamic>?)
      ?.map((e) => (e as List<dynamic>).map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map))).toList())
      .toList(),
);

Map<String, dynamic> _$BuffScriptToJson(BuffScript instance) => <String, dynamic>{
  'checkIndvType': ?instance.checkIndvType,
  'CheckOpponentBuffTypes': ?instance.CheckOpponentBuffTypes?.map(const BuffTypeConverter().toJson).toList(),
  'relationId': ?instance.relationId?.toJson(),
  'INDIVIDUALITIE': ?instance.INDIVIDUALITIE?.toJson(),
  'INDIVIDUALITIE_AND': ?instance.INDIVIDUALITIE_AND?.map((e) => e.toJson()).toList(),
  'INDIVIDUALITIE_OR': ?instance.INDIVIDUALITIE_OR?.map((e) => e.toJson()).toList(),
  'UpBuffRateBuffIndiv': ?instance.UpBuffRateBuffIndiv?.map((e) => e.toJson()).toList(),
  'TargetIndiv': ?instance.TargetIndiv?.toJson(),
  'convert': ?instance.convert?.toJson(),
  'NotPierceIndividuality': ?instance.NotPierceIndividuality?.map((e) => e.map((e) => e.toJson()).toList()).toList(),
};

BuffConvert _$BuffConvertFromJson(Map json) => BuffConvert(
  targetLimit: $enumDecodeNullable(_$BuffConvertLimitTypeEnumMap, json['targetLimit']) ?? BuffConvertLimitType.all,
  convertType: $enumDecodeNullable(_$BuffConvertTypeEnumMap, json['convertType']) ?? BuffConvertType.none,
  targets: json['targets'] as List<dynamic>? ?? const [],
  targetBuffs:
      (json['targetBuffs'] as List<dynamic>?)
          ?.map((e) => Buff.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  targetIndividualities:
      (json['targetIndividualities'] as List<dynamic>?)
          ?.map((e) => NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  convertBuffs:
      (json['convertBuffs'] as List<dynamic>?)
          ?.map((e) => Buff.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  script: json['script'] == null ? null : BuffConvertScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
  effectId: (json['effectId'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BuffConvertToJson(BuffConvert instance) => <String, dynamic>{
  'targetLimit': _$BuffConvertLimitTypeEnumMap[instance.targetLimit]!,
  'convertType': _$BuffConvertTypeEnumMap[instance.convertType]!,
  'targets': instance.targets,
  'targetBuffs': instance.targetBuffs.map((e) => e.toJson()).toList(),
  'convertBuffs': instance.convertBuffs.map((e) => e.toJson()).toList(),
  'script': ?instance.script?.toJson(),
  'effectId': instance.effectId,
  'targetIndividualities': instance.targetIndividualities.map((e) => e.toJson()).toList(),
};

const _$BuffConvertLimitTypeEnumMap = {BuffConvertLimitType.all: 'all', BuffConvertLimitType.self: 'self'};

const _$BuffConvertTypeEnumMap = {
  BuffConvertType.none: 'none',
  BuffConvertType.buff: 'buff',
  BuffConvertType.individuality: 'individuality',
};

BuffConvertScript _$BuffConvertScriptFromJson(Map json) => BuffConvertScript(
  OverwritePopupText: (json['OverwritePopupText'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$BuffConvertScriptToJson(BuffConvertScript instance) => <String, dynamic>{
  'OverwritePopupText': instance.OverwritePopupText,
};

const _$BuffTypeEnumMap = {
  BuffType.unknown: 'unknown',
  BuffType.invalid: 'invalid',
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
  BuffType.downCommandnpLegacy: 'downCommandnpLegacy',
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
  BuffType.commandattackAfterFunction: 'commandattackAfterFunction',
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
  BuffType.downDamageIndividualityActiveonly: 'downDamageIndividualityActiveonly',
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
  BuffType.upDefenceCommanddamage: 'upDefenceCommanddamage',
  BuffType.downDefenceCommanddamage: 'downDefenceCommanddamage',
  BuffType.npattackPrevBuff: 'npattackPrevBuff',
  BuffType.fixCommandcard: 'fixCommandcard',
  BuffType.donotGainnp: 'donotGainnp',
  BuffType.fieldIndividuality: 'fieldIndividuality',
  BuffType.donotActCommandtype: 'donotActCommandtype',
  BuffType.upDamageEventPoint: 'upDamageEventPoint',
  BuffType.upDamageSpecial: 'upDamageSpecial',
  BuffType.attackAfterFunction: 'attackAfterFunction',
  BuffType.commandcodeattackBeforeFunction: 'commandcodeattackBeforeFunction',
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
  BuffType.commandcodeattackBeforeFunctionMainOnly: 'commandcodeattackBeforeFunctionMainOnly',
  BuffType.commandcodeattackAfterFunctionMainOnly: 'commandcodeattackAfterFunctionMainOnly',
  BuffType.commandattackBeforeFunctionMainOnly: 'commandattackBeforeFunctionMainOnly',
  BuffType.commandattackAfterFunctionMainOnly: 'commandattackAfterFunctionMainOnly',
  BuffType.attackBeforeFunctionMainOnly: 'attackBeforeFunctionMainOnly',
  BuffType.attackAfterFunctionMainOnly: 'attackAfterFunctionMainOnly',
  BuffType.warBoardNotAttacked: 'warBoardNotAttacked',
  BuffType.warBoardIgnoreDefeatpoint: 'warBoardIgnoreDefeatpoint',
  BuffType.skillAfterFunction: 'skillAfterFunction',
  BuffType.treasureDeviceAfterFunction: 'treasureDeviceAfterFunction',
  BuffType.skillAfterFunctionMainOnly: 'skillAfterFunctionMainOnly',
  BuffType.treasureDeviceAfterFunctionMainOnly: 'treasureDeviceAfterFunctionMainOnly',
  BuffType.preventInvisibleWhenInstantDeath: 'preventInvisibleWhenInstantDeath',
  BuffType.overwriteSubattribute: 'overwriteSubattribute',
  BuffType.avoidanceAttackDeathDamage: 'avoidanceAttackDeathDamage',
  BuffType.avoidFunctionExecuteSelf: 'avoidFunctionExecuteSelf',
  BuffType.pierceSubdamage: 'pierceSubdamage',
  BuffType.continueFunction: 'continueFunction',
  BuffType.addSpecialdamage: 'addSpecialdamage',
  BuffType.subSpecialdamage: 'subSpecialdamage',
  BuffType.addFuncHpReduce: 'addFuncHpReduce',
  BuffType.subFuncHpReduce: 'subFuncHpReduce',
  BuffType.changeBgm: 'changeBgm',
  BuffType.confirmCommandFunction: 'confirmCommandFunction',
  BuffType.skillBeforeFunction: 'skillBeforeFunction',
  BuffType.skillTargetedBeforeFunction: 'skillTargetedBeforeFunction',
  BuffType.fieldIndividualityChangedFunction: 'fieldIndividualityChangedFunction',
  BuffType.treasureDeviceBeforeFunction: 'treasureDeviceBeforeFunction',
  BuffType.stepInAfterFunction: 'stepInAfterFunction',
  BuffType.shortenSkillAfterUseSkill: 'shortenSkillAfterUseSkill',
  BuffType.pierceSpecialInvincible: 'pierceSpecialInvincible',
  BuffType.functionedFunction: 'functionedFunction',
  BuffType.donotActCommandcard: 'donotActCommandcard',
  BuffType.upNpdamageIndividualitySum: 'upNpdamageIndividualitySum',
  BuffType.comboStartFunction: 'comboStartFunction',
  BuffType.comboEndFunction: 'comboEndFunction',
  BuffType.overwriteSvtCardType: 'overwriteSvtCardType',
  BuffType.upDefenceDamage: 'upDefenceDamage',
  BuffType.downDefenceDamage: 'downDefenceDamage',
  BuffType.upDefenceCriticaldamage: 'upDefenceCriticaldamage',
  BuffType.downDefenceCriticaldamage: 'downDefenceCriticaldamage',
  BuffType.upDefenceNpdamage: 'upDefenceNpdamage',
  BuffType.downDefenceNpdamage: 'downDefenceNpdamage',
  BuffType.upDefenceCommandnp: 'upDefenceCommandnp',
  BuffType.downCommandnp: 'downCommandnp',
  BuffType.downDefenceCommandnp: 'downDefenceCommandnp',
  BuffType.upDefenceCommandstar: 'upDefenceCommandstar',
  BuffType.downCommandstar: 'downCommandstar',
  BuffType.downDefenceCommandstar: 'downDefenceCommandstar',
  BuffType.wavestartAnimationBeforeFunction: 'wavestartAnimationBeforeFunction',
  BuffType.subFixedSelfdamage: 'subFixedSelfdamage',
  BuffType.overwriteFixedDefenceDamage: 'overwriteFixedDefenceDamage',
  BuffType.extendActionCount: 'extendActionCount',
  BuffType.gutsBeforeFunction: 'gutsBeforeFunction',
  BuffType.overwriteBuffUseRate: 'overwriteBuffUseRate',
  BuffType.upBuffUseRate: 'upBuffUseRate',
  BuffType.downBuffUseRate: 'downBuffUseRate',
  BuffType.reactiveDamageGainHp: 'reactiveDamageGainHp',
  BuffType.upHateToGrantedOpponent: 'upHateToGrantedOpponent',
  BuffType.toFieldChangeField: 'toFieldChangeField',
  BuffType.toFieldAvoidBuff: 'toFieldAvoidBuff',
  BuffType.toFieldSubIndividualityField: 'toFieldSubIndividualityField',
  BuffType.classboardCommandSpellAfterFunction: 'classboardCommandSpellAfterFunction',
};
