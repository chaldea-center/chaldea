// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/skill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseSkill _$BaseSkillFromJson(Map json) => BaseSkill(
      id: json['id'] as int,
      name: json['name'] as String,
      ruby: json['ruby'] as String? ?? '',
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      type: $enumDecode(_$SkillTypeEnumMap, json['type']),
      icon: json['icon'] as String?,
      coolDown:
          (json['coolDown'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      actIndividuality: (json['actIndividuality'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: json['script'] == null
          ? null
          : SkillScript.fromJson(
              Map<String, dynamic>.from(json['script'] as Map)),
      skillAdd: (json['skillAdd'] as List<dynamic>?)
              ?.map(
                  (e) => SkillAdd.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      aiIds: (json['aiIds'] as Map?)?.map(
        (k, e) => MapEntry($enumDecode(_$AiTypeEnumMap, k),
            (e as List<dynamic>).map((e) => e as int).toList()),
      ),
      functions: (json['functions'] as List<dynamic>)
          .map(
              (e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

const _$SkillTypeEnumMap = {
  SkillType.active: 'active',
  SkillType.passive: 'passive',
};

const _$AiTypeEnumMap = {
  AiType.svt: 'svt',
  AiType.field: 'field',
};

NiceSkill _$NiceSkillFromJson(Map json) => NiceSkill(
      id: json['id'] as int,
      name: json['name'] as String,
      ruby: json['ruby'] as String? ?? '',
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      type: $enumDecode(_$SkillTypeEnumMap, json['type']),
      icon: json['icon'] as String?,
      coolDown:
          (json['coolDown'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      actIndividuality: (json['actIndividuality'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: json['script'] == null
          ? null
          : SkillScript.fromJson(
              Map<String, dynamic>.from(json['script'] as Map)),
      extraPassive: (json['extraPassive'] as List<dynamic>?)
              ?.map((e) =>
                  ExtraPassive.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      skillAdd: (json['skillAdd'] as List<dynamic>?)
              ?.map(
                  (e) => SkillAdd.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      aiIds: (json['aiIds'] as Map?)?.map(
        (k, e) => MapEntry($enumDecode(_$AiTypeEnumMap, k),
            (e as List<dynamic>).map((e) => e as int).toList()),
      ),
      functions: (json['functions'] as List<dynamic>?)
              ?.map((e) =>
                  NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      num: json['num'] as int? ?? 0,
      strengthStatus: json['strengthStatus'] as int? ?? 0,
      priority: json['priority'] as int? ?? 0,
      condQuestId: json['condQuestId'] as int? ?? 0,
      condQuestPhase: json['condQuestPhase'] as int? ?? 0,
      condLv: json['condLv'] as int? ?? 0,
      condLimitCount: json['condLimitCount'] as int? ?? 0,
    );

BaseTd _$BaseTdFromJson(Map json) => BaseTd(
      id: json['id'] as int,
      card: $enumDecode(_$CardTypeEnumMap, json['card']),
      name: json['name'] as String,
      ruby: json['ruby'] as String? ?? '',
      icon: json['icon'] as String?,
      rank: json['rank'] as String,
      type: json['type'] as String,
      effectFlags: (json['effectFlags'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$TdEffectFlagEnumMap, e))
              .toList() ??
          const [],
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      npGain: NpGain.fromJson(Map<String, dynamic>.from(json['npGain'] as Map)),
      npDistribution: (json['npDistribution'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      individuality: (json['individuality'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: json['script'] == null
          ? null
          : SkillScript.fromJson(
              Map<String, dynamic>.from(json['script'] as Map)),
      functions: (json['functions'] as List<dynamic>)
          .map(
              (e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

const _$CardTypeEnumMap = {
  CardType.none: 'none',
  CardType.arts: 'arts',
  CardType.buster: 'buster',
  CardType.quick: 'quick',
  CardType.extra: 'extra',
  CardType.blank: 'blank',
  CardType.weak: 'weak',
  CardType.strength: 'strength',
};

const _$TdEffectFlagEnumMap = {
  TdEffectFlag.support: 'support',
  TdEffectFlag.attackEnemyAll: 'attackEnemyAll',
  TdEffectFlag.attackEnemyOne: 'attackEnemyOne',
};

NiceTd _$NiceTdFromJson(Map json) => NiceTd(
      id: json['id'] as int,
      num: json['num'] as int,
      card: $enumDecode(_$CardTypeEnumMap, json['card']),
      name: json['name'] as String,
      ruby: json['ruby'] as String? ?? "",
      icon: json['icon'] as String?,
      rank: json['rank'] as String,
      type: json['type'] as String,
      effectFlags: (json['effectFlags'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$TdEffectFlagEnumMap, e))
              .toList() ??
          const [],
      unmodifiedDetail: json['unmodifiedDetail'] as String?,
      npGain: NpGain.fromJson(Map<String, dynamic>.from(json['npGain'] as Map)),
      npDistribution: (json['npDistribution'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      individuality: (json['individuality'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      script: json['script'] == null
          ? null
          : SkillScript.fromJson(
              Map<String, dynamic>.from(json['script'] as Map)),
      functions: (json['functions'] as List<dynamic>)
          .map(
              (e) => NiceFunction.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      strengthStatus: json['strengthStatus'] as int? ?? 0,
      priority: json['priority'] as int,
      condQuestId: json['condQuestId'] as int? ?? 0,
      condQuestPhase: json['condQuestPhase'] as int? ?? 0,
    );

CommonRelease _$CommonReleaseFromJson(Map json) => CommonRelease(
      id: json['id'] as int,
      priority: json['priority'] as int,
      condGroup: json['condGroup'] as int,
      condType: const CondTypeConverter().fromJson(json['condType'] as String),
      condId: json['condId'] as int,
      condNum: json['condNum'] as int,
    );

ExtraPassive _$ExtraPassiveFromJson(Map json) => ExtraPassive(
      num: json['num'] as int,
      priority: json['priority'] as int,
      condQuestId: json['condQuestId'] as int? ?? 0,
      condQuestPhase: json['condQuestPhase'] as int? ?? 0,
      condLv: json['condLv'] as int? ?? 0,
      condLimitCount: json['condLimitCount'] as int? ?? 0,
      condFriendshipRank: json['condFriendshipRank'] as int? ?? 0,
      eventId: json['eventId'] as int? ?? 0,
      flag: json['flag'] as int? ?? 0,
      startedAt: json['startedAt'] as int,
      endedAt: json['endedAt'] as int,
    );

SkillScript _$SkillScriptFromJson(Map json) => SkillScript(
      NP_HIGHER:
          (json['NP_HIGHER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      NP_LOWER:
          (json['NP_LOWER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      STAR_HIGHER: (json['STAR_HIGHER'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      STAR_LOWER:
          (json['STAR_LOWER'] as List<dynamic>?)?.map((e) => e as int).toList(),
      HP_VAL_HIGHER: (json['HP_VAL_HIGHER'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      HP_VAL_LOWER: (json['HP_VAL_LOWER'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      HP_PER_HIGHER: (json['HP_PER_HIGHER'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      HP_PER_LOWER: (json['HP_PER_LOWER'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      additionalSkillId: (json['additionalSkillId'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      additionalSkillLv: (json['additionalSkillLv'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      additionalSkillActorType:
          (json['additionalSkillActorType'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList(),
      tdTypeChangeIDs: (json['tdTypeChangeIDs'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      excludeTdChangeTypes: (json['excludeTdChangeTypes'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      SelectAddInfo: (json['SelectAddInfo'] as List<dynamic>?)
          ?.map((e) =>
              SkillSelectAddInfo.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

SkillSelectAddInfo _$SkillSelectAddInfoFromJson(Map json) => SkillSelectAddInfo(
      title: json['title'] as String? ?? '',
      btn: (json['btn'] as List<dynamic>?)
              ?.map((e) => SkillSelectAddInfoBtn.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

SkillSelectAddInfoBtn _$SkillSelectAddInfoBtnFromJson(Map json) =>
    SkillSelectAddInfoBtn(
      name: json['name'] as String? ?? '',
      conds: (json['conds'] as List<dynamic>?)
              ?.map((e) => SkillSelectAddInfoBtnCond.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

SkillSelectAddInfoBtnCond _$SkillSelectAddInfoBtnCondFromJson(Map json) =>
    SkillSelectAddInfoBtnCond(
      cond: $enumDecodeNullable(_$SkillScriptCondEnumMap, json['cond']) ??
          SkillScriptCond.none,
      value: json['value'] as int?,
    );

const _$SkillScriptCondEnumMap = {
  SkillScriptCond.none: 'NONE',
  SkillScriptCond.npHigher: 'NP_HIGHER',
  SkillScriptCond.npLower: 'NP_LOWER',
  SkillScriptCond.starHigher: 'STAR_HIGHER',
  SkillScriptCond.starLower: 'STAR_LOWER',
  SkillScriptCond.hpValHigher: 'HP_VAL_HIGHER',
  SkillScriptCond.hpValLower: 'HP_VAL_LOWER',
  SkillScriptCond.hpPerHigher: 'HP_PER_HIGHER',
  SkillScriptCond.hpPerLower: 'HP_PER_LOWER',
};

SkillAdd _$SkillAddFromJson(Map json) => SkillAdd(
      priority: json['priority'] as int,
      releaseConditions: (json['releaseConditions'] as List<dynamic>)
          .map((e) =>
              CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      name: json['name'] as String,
      ruby: json['ruby'] as String,
    );

NpGain _$NpGainFromJson(Map json) => NpGain(
      buster: (json['buster'] as List<dynamic>).map((e) => e as int).toList(),
      arts: (json['arts'] as List<dynamic>).map((e) => e as int).toList(),
      quick: (json['quick'] as List<dynamic>).map((e) => e as int).toList(),
      extra: (json['extra'] as List<dynamic>).map((e) => e as int).toList(),
      np: (json['np'] as List<dynamic>).map((e) => e as int).toList(),
      defence: (json['defence'] as List<dynamic>).map((e) => e as int).toList(),
    );
