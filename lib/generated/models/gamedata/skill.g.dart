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
      condType: toEnumCondType(json['condType'] as Object),
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
    );

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

NiceFunction _$NiceFunctionFromJson(Map json) => NiceFunction(
      funcId: json['funcId'] as int,
      funcType: $enumDecodeNullable(_$FuncTypeEnumMap, json['funcType']) ??
          FuncType.unknown,
      funcTargetType:
          $enumDecode(_$FuncTargetTypeEnumMap, json['funcTargetType']),
      funcTargetTeam:
          $enumDecode(_$FuncApplyTargetEnumMap, json['funcTargetTeam']),
      funcPopupText: json['funcPopupText'] as String? ?? '',
      funcPopupIcon: json['funcPopupIcon'] as String?,
      functvals: (json['functvals'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      funcquestTvals: (json['funcquestTvals'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      funcGroup: (json['funcGroup'] as List<dynamic>?)
              ?.map((e) =>
                  FuncGroup.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      traitVals: (json['traitVals'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      buffs: (json['buffs'] as List<dynamic>?)
              ?.map((e) => Buff.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      svals: (json['svals'] as List<dynamic>?)
          ?.map((e) => DataVals.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      svals2: (json['svals2'] as List<dynamic>?)
          ?.map((e) => DataVals.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      svals3: (json['svals3'] as List<dynamic>?)
          ?.map((e) => DataVals.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      svals4: (json['svals4'] as List<dynamic>?)
          ?.map((e) => DataVals.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      svals5: (json['svals5'] as List<dynamic>?)
          ?.map((e) => DataVals.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      followerVals: (json['followerVals'] as List<dynamic>?)
          ?.map((e) => DataVals.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

const _$FuncTypeEnumMap = {
  FuncType.unknown: 'unknown',
  FuncType.none: 'none',
  FuncType.addState: 'addState',
  FuncType.subState: 'subState',
  FuncType.damage: 'damage',
  FuncType.damageNp: 'damageNp',
  FuncType.gainStar: 'gainStar',
  FuncType.gainHp: 'gainHp',
  FuncType.gainNp: 'gainNp',
  FuncType.lossNp: 'lossNp',
  FuncType.shortenSkill: 'shortenSkill',
  FuncType.extendSkill: 'extendSkill',
  FuncType.releaseState: 'releaseState',
  FuncType.lossHp: 'lossHp',
  FuncType.instantDeath: 'instantDeath',
  FuncType.damageNpPierce: 'damageNpPierce',
  FuncType.damageNpIndividual: 'damageNpIndividual',
  FuncType.addStateShort: 'addStateShort',
  FuncType.gainHpPer: 'gainHpPer',
  FuncType.damageNpStateIndividual: 'damageNpStateIndividual',
  FuncType.hastenNpturn: 'hastenNpturn',
  FuncType.delayNpturn: 'delayNpturn',
  FuncType.damageNpHpratioHigh: 'damageNpHpratioHigh',
  FuncType.damageNpHpratioLow: 'damageNpHpratioLow',
  FuncType.cardReset: 'cardReset',
  FuncType.replaceMember: 'replaceMember',
  FuncType.lossHpSafe: 'lossHpSafe',
  FuncType.damageNpCounter: 'damageNpCounter',
  FuncType.damageNpStateIndividualFix: 'damageNpStateIndividualFix',
  FuncType.damageNpSafe: 'damageNpSafe',
  FuncType.callServant: 'callServant',
  FuncType.ptShuffle: 'ptShuffle',
  FuncType.lossStar: 'lossStar',
  FuncType.changeServant: 'changeServant',
  FuncType.changeBg: 'changeBg',
  FuncType.damageValue: 'damageValue',
  FuncType.withdraw: 'withdraw',
  FuncType.fixCommandcard: 'fixCommandcard',
  FuncType.shortenBuffturn: 'shortenBuffturn',
  FuncType.extendBuffturn: 'extendBuffturn',
  FuncType.shortenBuffcount: 'shortenBuffcount',
  FuncType.extendBuffcount: 'extendBuffcount',
  FuncType.changeBgm: 'changeBgm',
  FuncType.displayBuffstring: 'displayBuffstring',
  FuncType.resurrection: 'resurrection',
  FuncType.gainNpBuffIndividualSum: 'gainNpBuffIndividualSum',
  FuncType.setSystemAliveFlag: 'setSystemAliveFlag',
  FuncType.forceInstantDeath: 'forceInstantDeath',
  FuncType.damageNpRare: 'damageNpRare',
  FuncType.gainNpFromTargets: 'gainNpFromTargets',
  FuncType.gainHpFromTargets: 'gainHpFromTargets',
  FuncType.lossHpPer: 'lossHpPer',
  FuncType.lossHpPerSafe: 'lossHpPerSafe',
  FuncType.shortenUserEquipSkill: 'shortenUserEquipSkill',
  FuncType.quickChangeBg: 'quickChangeBg',
  FuncType.shiftServant: 'shiftServant',
  FuncType.damageNpAndCheckIndividuality: 'damageNpAndCheckIndividuality',
  FuncType.absorbNpturn: 'absorbNpturn',
  FuncType.overwriteDeadType: 'overwriteDeadType',
  FuncType.forceAllBuffNoact: 'forceAllBuffNoact',
  FuncType.breakGaugeUp: 'breakGaugeUp',
  FuncType.breakGaugeDown: 'breakGaugeDown',
  FuncType.moveToLastSubmember: 'moveToLastSubmember',
  FuncType.expUp: 'expUp',
  FuncType.qpUp: 'qpUp',
  FuncType.dropUp: 'dropUp',
  FuncType.friendPointUp: 'friendPointUp',
  FuncType.eventDropUp: 'eventDropUp',
  FuncType.eventDropRateUp: 'eventDropRateUp',
  FuncType.eventPointUp: 'eventPointUp',
  FuncType.eventPointRateUp: 'eventPointRateUp',
  FuncType.transformServant: 'transformServant',
  FuncType.qpDropUp: 'qpDropUp',
  FuncType.servantFriendshipUp: 'servantFriendshipUp',
  FuncType.userEquipExpUp: 'userEquipExpUp',
  FuncType.classDropUp: 'classDropUp',
  FuncType.enemyEncountCopyRateUp: 'enemyEncountCopyRateUp',
  FuncType.enemyEncountRateUp: 'enemyEncountRateUp',
  FuncType.enemyProbDown: 'enemyProbDown',
  FuncType.getRewardGift: 'getRewardGift',
  FuncType.sendSupportFriendPoint: 'sendSupportFriendPoint',
  FuncType.movePosition: 'movePosition',
  FuncType.revival: 'revival',
  FuncType.damageNpIndividualSum: 'damageNpIndividualSum',
  FuncType.damageValueSafe: 'damageValueSafe',
  FuncType.friendPointUpDuplicate: 'friendPointUpDuplicate',
  FuncType.moveState: 'moveState',
  FuncType.changeBgmCostume: 'changeBgmCostume',
  FuncType.func126: 'func126',
  FuncType.func127: 'func127',
  FuncType.updateEntryPositions: 'updateEntryPositions',
  FuncType.buddyPointUp: 'buddyPointUp',
  FuncType.addFieldChangeToField: 'addFieldChangeToField',
  FuncType.subFieldBuff: 'subFieldBuff',
  FuncType.eventFortificationPointUp: 'eventFortificationPointUp',
  FuncType.gainNpIndividualSum: 'gainNpIndividualSum',
  FuncType.setQuestRouteFlag: 'setQuestRouteFlag',
};

const _$FuncTargetTypeEnumMap = {
  FuncTargetType.self: 'self',
  FuncTargetType.ptOne: 'ptOne',
  FuncTargetType.ptAnother: 'ptAnother',
  FuncTargetType.ptAll: 'ptAll',
  FuncTargetType.enemy: 'enemy',
  FuncTargetType.enemyAnother: 'enemyAnother',
  FuncTargetType.enemyAll: 'enemyAll',
  FuncTargetType.ptFull: 'ptFull',
  FuncTargetType.enemyFull: 'enemyFull',
  FuncTargetType.ptOther: 'ptOther',
  FuncTargetType.ptOneOther: 'ptOneOther',
  FuncTargetType.ptRandom: 'ptRandom',
  FuncTargetType.enemyOther: 'enemyOther',
  FuncTargetType.enemyRandom: 'enemyRandom',
  FuncTargetType.ptOtherFull: 'ptOtherFull',
  FuncTargetType.enemyOtherFull: 'enemyOtherFull',
  FuncTargetType.ptselectOneSub: 'ptselectOneSub',
  FuncTargetType.ptselectSub: 'ptselectSub',
  FuncTargetType.ptOneAnotherRandom: 'ptOneAnotherRandom',
  FuncTargetType.ptSelfAnotherRandom: 'ptSelfAnotherRandom',
  FuncTargetType.enemyOneAnotherRandom: 'enemyOneAnotherRandom',
  FuncTargetType.ptSelfAnotherFirst: 'ptSelfAnotherFirst',
  FuncTargetType.ptSelfBefore: 'ptSelfBefore',
  FuncTargetType.ptSelfAfter: 'ptSelfAfter',
  FuncTargetType.ptSelfAnotherLast: 'ptSelfAnotherLast',
  FuncTargetType.commandTypeSelfTreasureDevice: 'commandTypeSelfTreasureDevice',
  FuncTargetType.fieldOther: 'fieldOther',
  FuncTargetType.enemyOneNoTargetNoAction: 'enemyOneNoTargetNoAction',
  FuncTargetType.ptOneHpLowestValue: 'ptOneHpLowestValue',
  FuncTargetType.ptOneHpLowestRate: 'ptOneHpLowestRate',
};

const _$FuncApplyTargetEnumMap = {
  FuncApplyTarget.player: 'player',
  FuncApplyTarget.enemy: 'enemy',
  FuncApplyTarget.playerAndEnemy: 'playerAndEnemy',
};

BaseFunction _$BaseFunctionFromJson(Map json) => BaseFunction(
      funcId: json['funcId'] as int,
      funcType: $enumDecodeNullable(_$FuncTypeEnumMap, json['funcType']) ??
          FuncType.unknown,
      funcTargetType:
          $enumDecode(_$FuncTargetTypeEnumMap, json['funcTargetType']),
      funcTargetTeam:
          $enumDecode(_$FuncApplyTargetEnumMap, json['funcTargetTeam']),
      funcPopupText: json['funcPopupText'] as String? ?? '',
      funcPopupIcon: json['funcPopupIcon'] as String?,
      functvals: (json['functvals'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      funcquestTvals: (json['funcquestTvals'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      funcGroup: (json['funcGroup'] as List<dynamic>?)
              ?.map((e) =>
                  FuncGroup.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      traitVals: (json['traitVals'] as List<dynamic>?)
              ?.map((e) =>
                  NiceTrait.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      buffs: (json['buffs'] as List<dynamic>?)
              ?.map((e) => Buff.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

FuncGroup _$FuncGroupFromJson(Map json) => FuncGroup(
      eventId: json['eventId'] as int,
      baseFuncId: json['baseFuncId'] as int,
      nameTotal: json['nameTotal'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      priority: json['priority'] as int,
      isDispValue: json['isDispValue'] as bool,
    );

Buff _$BuffFromJson(Map json) => Buff(
      id: json['id'] as int,
      name: json['name'] as String,
      detail: json['detail'] as String,
      icon: json['icon'] as String?,
      type: $enumDecodeNullable(_$BuffTypeEnumMap, json['type']) ??
          BuffType.unknown,
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
  BuffType.toFieldChangeField: 'toFieldChangeField',
  BuffType.toFieldAvoidBuff: 'toFieldAvoidBuff',
};

BuffScript _$BuffScriptFromJson(Map json) => BuffScript(
      checkIndvType: json['checkIndvType'] as int?,
      CheckOpponentBuffTypes: (json['CheckOpponentBuffTypes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$BuffTypeEnumMap, e))
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
    );
