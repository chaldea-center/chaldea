// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/func.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NiceFunction _$NiceFunctionFromJson(Map json) => NiceFunction(
  funcId: (json['funcId'] as num).toInt(),
  funcType: json['funcType'] == null
      ? FuncType.unknown
      : const FuncTypeConverter().fromJson(json['funcType'] as String),
  funcTargetType: $enumDecode(_$FuncTargetTypeEnumMap, json['funcTargetType']),
  funcTargetTeam: json['funcTargetTeam'] == null
      ? FuncApplyTarget.all
      : const FuncApplyTargetConverter().fromJson(json['funcTargetTeam'] as String),
  funcPopupText: json['funcPopupText'] as String? ?? '',
  funcPopupIcon: json['funcPopupIcon'] as String?,
  functvals: json['functvals'] == null ? const [] : const TraitListConverter().fromJson(json['functvals'] as Object),
  overWriteTvalsList: json['overWriteTvalsList'] == null
      ? const []
      : const Trait2dListConverter().fromJson(json['overWriteTvalsList'] as List),
  funcquestTvals: json['funcquestTvals'] == null
      ? const []
      : const TraitListConverter().fromJson(json['funcquestTvals'] as Object),
  funcGroup:
      (json['funcGroup'] as List<dynamic>?)
          ?.map((e) => FuncGroup.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  traitVals: json['traitVals'] == null ? const [] : const TraitListConverter().fromJson(json['traitVals'] as Object),
  buffs:
      (json['buffs'] as List<dynamic>?)?.map((e) => Buff.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
  script: json['script'] == null ? null : FuncScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
  svals: (json['svals'] as List<dynamic>?)?.map((e) => DataVals.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
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

Map<String, dynamic> _$NiceFunctionToJson(NiceFunction instance) => <String, dynamic>{
  'funcId': instance.funcId,
  'funcType': const FuncTypeConverter().toJson(instance.funcType),
  'funcTargetType': _$FuncTargetTypeEnumMap[instance.funcTargetType]!,
  'funcTargetTeam': const FuncApplyTargetConverter().toJson(instance.funcTargetTeam),
  'funcPopupText': instance.funcPopupText,
  'funcPopupIcon': instance.funcPopupIcon,
  'functvals': const TraitListConverter().toJson(instance.functvals),
  'overWriteTvalsList': const Trait2dListConverter().toJson(instance.overWriteTvalsList),
  'funcquestTvals': const TraitListConverter().toJson(instance.funcquestTvals),
  'funcGroup': instance.funcGroup.map((e) => e.toJson()).toList(),
  'traitVals': const TraitListConverter().toJson(instance.traitVals),
  'buffs': instance.buffs.map((e) => e.toJson()).toList(),
  'script': instance.script?.toJson(),
  'svals': instance.svals.map((e) => e.toJson()).toList(),
  'svals2': instance.svals2?.map((e) => e.toJson()).toList(),
  'svals3': instance.svals3?.map((e) => e.toJson()).toList(),
  'svals4': instance.svals4?.map((e) => e.toJson()).toList(),
  'svals5': instance.svals5?.map((e) => e.toJson()).toList(),
  'followerVals': instance.followerVals?.map((e) => e.toJson()).toList(),
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
  FuncTargetType.enemyRange: 'enemyRange',
  FuncTargetType.handCommandcardRandomOne: 'handCommandcardRandomOne',
  FuncTargetType.fieldAll: 'fieldAll',
  FuncTargetType.noTarget: 'noTarget',
  FuncTargetType.fieldRandom: 'fieldRandom',
};

BaseFunction _$BaseFunctionFromJson(Map json) => BaseFunction(
  funcId: (json['funcId'] as num).toInt(),
  funcType: json['funcType'] == null
      ? FuncType.unknown
      : const FuncTypeConverter().fromJson(json['funcType'] as String),
  funcTargetType: $enumDecode(_$FuncTargetTypeEnumMap, json['funcTargetType']),
  funcTargetTeam: const FuncApplyTargetConverter().fromJson(json['funcTargetTeam'] as String),
  funcPopupText: json['funcPopupText'] as String? ?? '',
  funcPopupIcon: json['funcPopupIcon'] as String?,
  functvals: json['functvals'] == null ? const [] : const TraitListConverter().fromJson(json['functvals'] as Object),
  overWriteTvalsList: json['overWriteTvalsList'] == null
      ? const []
      : const Trait2dListConverter().fromJson(json['overWriteTvalsList'] as List),
  funcquestTvals: json['funcquestTvals'] == null
      ? const []
      : const TraitListConverter().fromJson(json['funcquestTvals'] as Object),
  funcGroup:
      (json['funcGroup'] as List<dynamic>?)
          ?.map((e) => FuncGroup.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList() ??
      const [],
  traitVals: json['traitVals'] == null ? const [] : const TraitListConverter().fromJson(json['traitVals'] as Object),
  buffs:
      (json['buffs'] as List<dynamic>?)?.map((e) => Buff.fromJson(Map<String, dynamic>.from(e as Map))).toList() ??
      const [],
  script: json['script'] == null ? null : FuncScript.fromJson(Map<String, dynamic>.from(json['script'] as Map)),
);

Map<String, dynamic> _$BaseFunctionToJson(BaseFunction instance) => <String, dynamic>{
  'funcId': instance.funcId,
  'funcType': const FuncTypeConverter().toJson(instance.funcType),
  'funcTargetType': _$FuncTargetTypeEnumMap[instance.funcTargetType]!,
  'funcTargetTeam': const FuncApplyTargetConverter().toJson(instance.funcTargetTeam),
  'funcPopupText': instance.funcPopupText,
  'funcPopupIcon': instance.funcPopupIcon,
  'functvals': const TraitListConverter().toJson(instance.functvals),
  'overWriteTvalsList': const Trait2dListConverter().toJson(instance.overWriteTvalsList),
  'funcquestTvals': const TraitListConverter().toJson(instance.funcquestTvals),
  'funcGroup': instance.funcGroup.map((e) => e.toJson()).toList(),
  'traitVals': const TraitListConverter().toJson(instance.traitVals),
  'buffs': instance.buffs.map((e) => e.toJson()).toList(),
  'script': instance.script?.toJson(),
};

FuncGroup _$FuncGroupFromJson(Map json) => FuncGroup(
  eventId: (json['eventId'] as num).toInt(),
  baseFuncId: (json['baseFuncId'] as num).toInt(),
  nameTotal: json['nameTotal'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String?,
  priority: (json['priority'] as num).toInt(),
  isDispValue: json['isDispValue'] as bool,
);

Map<String, dynamic> _$FuncGroupToJson(FuncGroup instance) => <String, dynamic>{
  'eventId': instance.eventId,
  'baseFuncId': instance.baseFuncId,
  'nameTotal': instance.nameTotal,
  'name': instance.name,
  'icon': instance.icon,
  'priority': instance.priority,
  'isDispValue': instance.isDispValue,
};

FuncScript _$FuncScriptFromJson(Map json) => FuncScript(
  overwriteTvals: _$JsonConverterFromJson<List<dynamic>, List<List<int>>>(
    json['overwriteTvals'],
    const Trait2dListConverter().fromJson,
  ),
  funcIndividuality: _$JsonConverterFromJson<Object, List<int>>(
    json['funcIndividuality'],
    const TraitListConverter().fromJson,
  ),
);

Map<String, dynamic> _$FuncScriptToJson(FuncScript instance) => <String, dynamic>{
  'overwriteTvals': _$JsonConverterToJson<List<dynamic>, List<List<int>>>(
    instance.overwriteTvals,
    const Trait2dListConverter().toJson,
  ),
  'funcIndividuality': _$JsonConverterToJson<Object, List<int>>(
    instance.funcIndividuality,
    const TraitListConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(Object? json, Value? Function(Json json) fromJson) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(Value? value, Json? Function(Value value) toJson) =>
    value == null ? null : toJson(value);

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
  FuncType.damageNpAndOrCheckIndividuality: 'damageNpAndOrCheckIndividuality',
  FuncType.absorbNpturn: 'absorbNpturn',
  FuncType.overwriteDeadType: 'overwriteDeadType',
  FuncType.forceAllBuffNoact: 'forceAllBuffNoact',
  FuncType.breakGaugeUp: 'breakGaugeUp',
  FuncType.breakGaugeDown: 'breakGaugeDown',
  FuncType.moveToLastSubmember: 'moveToLastSubmember',
  FuncType.extendUserEquipSkill: 'extendUserEquipSkill',
  FuncType.updateEnemyEntryMaxCountEachTurn: 'updateEnemyEntryMaxCountEachTurn',
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
  FuncType.lossCommandSpell: 'lossCommandSpell',
  FuncType.gainCommandSpell: 'gainCommandSpell',
  FuncType.updateEntryPositions: 'updateEntryPositions',
  FuncType.buddyPointUp: 'buddyPointUp',
  FuncType.addFieldChangeToField: 'addFieldChangeToField',
  FuncType.subFieldBuff: 'subFieldBuff',
  FuncType.eventFortificationPointUp: 'eventFortificationPointUp',
  FuncType.gainNpIndividualSum: 'gainNpIndividualSum',
  FuncType.setQuestRouteFlag: 'setQuestRouteFlag',
  FuncType.lastUsePlayerSkillCopy: 'lastUsePlayerSkillCopy',
  FuncType.changeEnemyMasterFace: 'changeEnemyMasterFace',
  FuncType.damageValueSafeOnce: 'damageValueSafeOnce',
  FuncType.addBattleValue: 'addBattleValue',
  FuncType.setBattleValue: 'setBattleValue',
  FuncType.gainMultiplyNp: 'gainMultiplyNp',
  FuncType.lossMultiplyNp: 'lossMultiplyNp',
  FuncType.addBattlePoint: 'addBattlePoint',
  FuncType.damageNpBattlePointPhase: 'damageNpBattlePointPhase',
  FuncType.setNpExecutedState: 'setNpExecutedState',
  FuncType.hideOverGauge: 'hideOverGauge',
  FuncType.gainNpTargetSum: 'gainNpTargetSum',
  FuncType.enemyCountChange: 'enemyCountChange',
  FuncType.displayBattleMessage: 'displayBattleMessage',
  FuncType.generateBattleSkillDrop: 'generateBattleSkillDrop',
  FuncType.changeMasterFace: 'changeMasterFace',
  FuncType.enableMasterSkill: 'enableMasterSkill',
  FuncType.enableMasterCommandSpell: 'enableMasterCommandSpell',
  FuncType.battleModelChange: 'battleModelChange',
  FuncType.gainNpCriticalstarSum: 'gainNpCriticalstarSum',
  FuncType.addBattleMissionValue: 'addBattleMissionValue',
  FuncType.setBattleMissionValue: 'setBattleMissionValue',
  FuncType.changeEnemyStatusUiType: 'changeEnemyStatusUiType',
  FuncType.swapFieldPosition: 'swapFieldPosition',
  FuncType.setDisplayDirectBattleMessageInFsm: 'setDisplayDirectBattleMessageInFsm',
};

const _$FuncApplyTargetEnumMap = {
  FuncApplyTarget.player: 'player',
  FuncApplyTarget.enemy: 'enemy',
  FuncApplyTarget.all: 'all',
};
