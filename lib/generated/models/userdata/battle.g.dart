// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/userdata/battle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BattleSimUserData _$BattleSimUserDataFromJson(Map json) => $checkedCreate('BattleSimUserData', json, ($checkedConvert) {
  final val = BattleSimUserData(
    pingedCEs: $checkedConvert('pingedCEs', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
    pingedSvts: $checkedConvert('pingedSvts', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
    favoriteTeams: $checkedConvert(
      'favoriteTeams',
      (v) => (v as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), (e as List<dynamic>).map((e) => (e as num).toInt()).toSet()),
      ),
    ),
    teams: $checkedConvert(
      'teams',
      (v) => (v as List<dynamic>?)?.map((e) => BattleShareData.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$BattleSimUserDataToJson(BattleSimUserData instance) => <String, dynamic>{
  'pingedCEs': instance.pingedCEs.toList(),
  'pingedSvts': instance.pingedSvts.toList(),
  'favoriteTeams': instance.favoriteTeams.map((k, e) => MapEntry(k.toString(), e.toList())),
  'teams': instance.teams.map((e) => e.toJson()).toList(),
};

BattleSimSetting _$BattleSimSettingFromJson(Map json) => $checkedCreate('BattleSimSetting', json, ($checkedConvert) {
  final val = BattleSimSetting(
    playerRegion: $checkedConvert(
      'playerRegion',
      (v) => _$JsonConverterFromJson<String, Region>(v, const RegionConverter().fromJson),
    ),
    playerDataSource: $checkedConvert(
      'playerDataSource',
      (v) => $enumDecodeNullable(_$PreferPlayerSvtDataSourceEnumMap, v) ?? PreferPlayerSvtDataSource.current,
    ),
    previousQuestPhase: $checkedConvert('previousQuestPhase', (v) => v as String?),
    defaultLvs: $checkedConvert(
      'defaultLvs',
      (v) => v == null ? null : PlayerSvtDefaultData.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    curTeam: $checkedConvert(
      'curTeam',
      (v) => v == null ? null : BattleShareData.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    svtFilterData: $checkedConvert(
      'svtFilterData',
      (v) => v == null ? null : SvtFilterData.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    craftFilterData: $checkedConvert(
      'craftFilterData',
      (v) => v == null ? null : CraftFilterData.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    tdDmgOptions: $checkedConvert(
      'tdDmgOptions',
      (v) => v == null ? null : TdDamageOptions.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    recordScreenshotJpg: $checkedConvert('recordScreenshotJpg', (v) => v as bool? ?? false),
    recordScreenshotRatio: $checkedConvert('recordScreenshotRatio', (v) => (v as num?)?.toInt() ?? 10),
    recordShowTwoColumn: $checkedConvert('recordShowTwoColumn', (v) => v as bool? ?? false),
    manualAllySkillTarget: $checkedConvert('manualAllySkillTarget', (v) => v as bool? ?? false),
  );
  return val;
});

Map<String, dynamic> _$BattleSimSettingToJson(BattleSimSetting instance) => <String, dynamic>{
  'playerRegion': _$JsonConverterToJson<String, Region>(instance.playerRegion, const RegionConverter().toJson),
  'playerDataSource': _$PreferPlayerSvtDataSourceEnumMap[instance.playerDataSource]!,
  'previousQuestPhase': instance.previousQuestPhase,
  'defaultLvs': instance.defaultLvs.toJson(),
  'curTeam': instance.curTeam.toJson(),
  'svtFilterData': instance.svtFilterData.toJson(),
  'craftFilterData': instance.craftFilterData.toJson(),
  'tdDmgOptions': instance.tdDmgOptions.toJson(),
  'recordScreenshotJpg': instance.recordScreenshotJpg,
  'recordScreenshotRatio': instance.recordScreenshotRatio,
  'recordShowTwoColumn': instance.recordShowTwoColumn,
  'manualAllySkillTarget': instance.manualAllySkillTarget,
};

Value? _$JsonConverterFromJson<Json, Value>(Object? json, Value? Function(Json json) fromJson) =>
    json == null ? null : fromJson(json as Json);

const _$PreferPlayerSvtDataSourceEnumMap = {
  PreferPlayerSvtDataSource.none: 'none',
  PreferPlayerSvtDataSource.current: 'current',
  PreferPlayerSvtDataSource.target: 'target',
};

Json? _$JsonConverterToJson<Json, Value>(Value? value, Json? Function(Value value) toJson) =>
    value == null ? null : toJson(value);

BattleShareData _$BattleShareDataFromJson(Map json) => $checkedCreate('BattleShareData', json, ($checkedConvert) {
  final val = BattleShareData(
    minBuild: $checkedConvert('minBuild', (v) => (v as num?)?.toInt()),
    appBuild: $checkedConvert('appBuild', (v) => (v as num?)?.toInt()),
    quest: $checkedConvert(
      'quest',
      (v) => v == null ? null : BattleQuestInfo.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    options: $checkedConvert(
      'options',
      (v) => v == null ? null : BattleShareDataOption.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    formation: $checkedConvert('team', (v) => BattleTeamFormation.fromJson(Map<String, dynamic>.from(v as Map))),
    delegate: $checkedConvert(
      'delegate',
      (v) => v == null ? null : BattleReplayDelegateData.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    actions: $checkedConvert(
      'actions',
      (v) => (v as List<dynamic>?)?.map((e) => BattleRecordData.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
    isCritTeam: $checkedConvert('isCritTeam', (v) => v as bool? ?? false),
  );
  return val;
}, fieldKeyMap: const {'formation': 'team'});

Map<String, dynamic> _$BattleShareDataToJson(BattleShareData instance) => <String, dynamic>{
  if (instance.minBuild case final value?) 'minBuild': value,
  if (instance.appBuild case final value?) 'appBuild': value,
  if (instance.quest?.toJson() case final value?) 'quest': value,
  'options': instance.options.toJson(),
  'team': instance.formation.toJson(),
  if (instance.delegate?.toJson() case final value?) 'delegate': value,
  'actions': instance.actions.map((e) => e.toJson()).toList(),
  'isCritTeam': instance.isCritTeam,
};

BattleShareDataOption _$BattleShareDataOptionFromJson(Map json) => $checkedCreate('BattleShareDataOption', json, (
  $checkedConvert,
) {
  final val = BattleShareDataOption(
    mightyChain: $checkedConvert('mightyChain', (v) => v as bool? ?? true),
    disableEvent: $checkedConvert('disableEvent', (v) => v as bool?),
    pointBuffs: $checkedConvert(
      'pointBuffs',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
    ),
    simulateAi: $checkedConvert('simulateAi', (v) => v as bool?),
    enemyRateUp: $checkedConvert('enemyRateUp', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
  );
  return val;
});

Map<String, dynamic> _$BattleShareDataOptionToJson(BattleShareDataOption instance) => <String, dynamic>{
  'mightyChain': instance.mightyChain,
  'disableEvent': instance.disableEvent,
  'pointBuffs': instance.pointBuffs?.map((k, e) => MapEntry(k.toString(), e)),
  'simulateAi': instance.simulateAi,
  'enemyRateUp': instance.enemyRateUp?.toList(),
};

BattleQuestInfo _$BattleQuestInfoFromJson(Map json) => $checkedCreate('BattleQuestInfo', json, ($checkedConvert) {
  final val = BattleQuestInfo(
    id: $checkedConvert('id', (v) => (v as num).toInt()),
    phase: $checkedConvert('phase', (v) => (v as num).toInt()),
    enemyHash: $checkedConvert('enemyHash', (v) => v as String?),
    region: $checkedConvert(
      'region',
      (v) => _$JsonConverterFromJson<String, Region>(v, const RegionConverter().fromJson),
    ),
  );
  return val;
});

Map<String, dynamic> _$BattleQuestInfoToJson(BattleQuestInfo instance) => <String, dynamic>{
  'id': instance.id,
  'phase': instance.phase,
  if (instance.enemyHash case final value?) 'enemyHash': value,
  if (_$JsonConverterToJson<String, Region>(instance.region, const RegionConverter().toJson) case final value?)
    'region': value,
};

BattleTeamFormation _$BattleTeamFormationFromJson(Map json) =>
    $checkedCreate('BattleTeamFormation', json, ($checkedConvert) {
      final val = BattleTeamFormation(
        name: $checkedConvert('name', (v) => v as String?),
        mysticCode: $checkedConvert(
          'mysticCode',
          (v) => v == null ? null : MysticCodeSaveData.fromJson(Map<String, dynamic>.from(v as Map)),
        ),
        onFieldSvts: $checkedConvert(
          'onFieldSvts',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => e == null ? null : SvtSaveData.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList(),
        ),
        backupSvts: $checkedConvert(
          'backupSvts',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => e == null ? null : SvtSaveData.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BattleTeamFormationToJson(BattleTeamFormation instance) => <String, dynamic>{
  'name': instance.name,
  'mysticCode': instance.mysticCode.toJson(),
  'onFieldSvts': instance.onFieldSvts.map((e) => e?.toJson()).toList(),
  'backupSvts': instance.backupSvts.map((e) => e?.toJson()).toList(),
};

SvtSaveData _$SvtSaveDataFromJson(Map json) => $checkedCreate('SvtSaveData', json, ($checkedConvert) {
  final val = SvtSaveData(
    svtId: $checkedConvert('svtId', (v) => (v as num?)?.toInt()),
    limitCount: $checkedConvert('limitCount', (v) => (v as num?)?.toInt() ?? 4),
    skillLvs: $checkedConvert('skillLvs', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
    skillIds: $checkedConvert('skillIds', (v) => (v as List<dynamic>?)?.map((e) => (e as num?)?.toInt()).toList()),
    appendLvs: $checkedConvert('appendLvs', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
    tdId: $checkedConvert('tdId', (v) => (v as num?)?.toInt() ?? 0),
    tdLv: $checkedConvert('tdLv', (v) => (v as num?)?.toInt() ?? 5),
    lv: $checkedConvert('lv', (v) => (v as num?)?.toInt() ?? 1),
    atkFou: $checkedConvert('atkFou', (v) => (v as num?)?.toInt() ?? 1000),
    hpFou: $checkedConvert('hpFou', (v) => (v as num?)?.toInt() ?? 1000),
    fixedAtk: $checkedConvert('fixedAtk', (v) => (v as num?)?.toInt()),
    fixedHp: $checkedConvert('fixedHp', (v) => (v as num?)?.toInt()),
    ceId: $checkedConvert('ceId', (v) => (v as num?)?.toInt()),
    ceLimitBreak: $checkedConvert('ceLimitBreak', (v) => v as bool? ?? false),
    ceLv: $checkedConvert('ceLv', (v) => (v as num?)?.toInt() ?? 0),
    equip1: $checkedConvert(
      'equip1',
      (v) => v == null ? null : SvtEquipSaveData.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    equip2: $checkedConvert(
      'equip2',
      (v) => v == null ? null : SvtEquipSaveData.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    equip3: $checkedConvert(
      'equip3',
      (v) => v == null ? null : SvtEquipSaveData.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    supportType: $checkedConvert(
      'supportType',
      (v) => $enumDecodeNullable(_$SupportSvtTypeEnumMap, v) ?? SupportSvtType.none,
    ),
    cardStrengthens: $checkedConvert(
      'cardStrengthens',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
    commandCodeIds: $checkedConvert(
      'commandCodeIds',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num?)?.toInt()).toList(),
    ),
    disabledExtraSkills: $checkedConvert(
      'disabledExtraSkills',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet(),
    ),
    allowedExtraSkills: $checkedConvert(
      'allowedExtraSkills',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet(),
    ),
    customPassives: $checkedConvert(
      'customPassives',
      (v) => (v as List<dynamic>?)?.map((e) => BaseSkill.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
    customPassiveLvs: $checkedConvert(
      'customPassiveLvs',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
    grandSvt: $checkedConvert('grandSvt', (v) => v as bool? ?? false),
    classBoardData: $checkedConvert(
      'classBoardData',
      (v) => v == null ? null : ClassBoardStatisticsData.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
  );
  return val;
});

Map<String, dynamic> _$SvtSaveDataToJson(SvtSaveData instance) => <String, dynamic>{
  if (instance.svtId case final value?) 'svtId': value,
  'limitCount': instance.limitCount,
  'skillIds': instance.skillIds,
  'skillLvs': instance.skillLvs,
  'appendLvs': instance.appendLvs,
  if (instance.tdId case final value?) 'tdId': value,
  'tdLv': instance.tdLv,
  'lv': instance.lv,
  'atkFou': instance.atkFou,
  'hpFou': instance.hpFou,
  if (instance.fixedAtk case final value?) 'fixedAtk': value,
  if (instance.fixedHp case final value?) 'fixedHp': value,
  if (instance.ceId case final value?) 'ceId': value,
  'ceLimitBreak': instance.ceLimitBreak,
  'ceLv': instance.ceLv,
  'equip1': instance.equip1.toJson(),
  if (instance.equip2?.toJson() case final value?) 'equip2': value,
  if (instance.equip3?.toJson() case final value?) 'equip3': value,
  'supportType': _$SupportSvtTypeEnumMap[instance.supportType]!,
  'cardStrengthens': instance.cardStrengthens,
  'commandCodeIds': instance.commandCodeIds,
  'disabledExtraSkills': instance.disabledExtraSkills.toList(),
  'allowedExtraSkills': instance.allowedExtraSkills.toList(),
  'customPassives': instance.customPassives.map((e) => e.toJson()).toList(),
  'customPassiveLvs': instance.customPassiveLvs,
  'grandSvt': instance.grandSvt,
  if (instance.classBoardData?.toJson() case final value?) 'classBoardData': value,
};

const _$SupportSvtTypeEnumMap = {
  SupportSvtType.none: 'none',
  SupportSvtType.friend: 'friend',
  SupportSvtType.npc: 'npc',
};

SvtEquipSaveData _$SvtEquipSaveDataFromJson(Map json) => $checkedCreate('SvtEquipSaveData', json, ($checkedConvert) {
  final val = SvtEquipSaveData(
    id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
    limitBreak: $checkedConvert('limitBreak', (v) => v as bool? ?? false),
    lv: $checkedConvert('lv', (v) => (v as num?)?.toInt() ?? 0),
  );
  return val;
});

Map<String, dynamic> _$SvtEquipSaveDataToJson(SvtEquipSaveData instance) => <String, dynamic>{
  'id': instance.id,
  'limitBreak': instance.limitBreak,
  'lv': instance.lv,
};

MysticCodeSaveData _$MysticCodeSaveDataFromJson(Map json) =>
    $checkedCreate('MysticCodeSaveData', json, ($checkedConvert) {
      final val = MysticCodeSaveData(
        mysticCodeId: $checkedConvert('mysticCodeId', (v) => (v as num?)?.toInt()),
        level: $checkedConvert('level', (v) => (v as num?)?.toInt() ?? 0),
      );
      return val;
    });

Map<String, dynamic> _$MysticCodeSaveDataToJson(MysticCodeSaveData instance) => <String, dynamic>{
  'mysticCodeId': instance.mysticCodeId,
  'level': instance.level,
};

ClassBoardStatisticsData _$ClassBoardStatisticsDataFromJson(Map json) =>
    $checkedCreate('ClassBoardStatisticsData', json, ($checkedConvert) {
      final val = ClassBoardStatisticsData(
        classBoardSquares: $checkedConvert(
          'classBoardSquares',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        grandClassBoardSquares: $checkedConvert(
          'grandClassBoardSquares',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        classStatistics: $checkedConvert(
          'classStatistics',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => ClassStatisticsInfo.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ClassBoardStatisticsDataToJson(ClassBoardStatisticsData instance) => <String, dynamic>{
  'classBoardSquares': instance.classBoardSquares,
  'grandClassBoardSquares': instance.grandClassBoardSquares,
  'classStatistics': instance.classStatistics.map((e) => e.toJson()).toList(),
};

ClassStatisticsInfo _$ClassStatisticsInfoFromJson(Map json) =>
    $checkedCreate('ClassStatisticsInfo', json, ($checkedConvert) {
      final val = ClassStatisticsInfo(
        classId: $checkedConvert('classId', (v) => (v as num?)?.toInt() ?? 0),
        type: $checkedConvert('type', (v) => (v as num?)?.toInt() ?? 0),
        typeVal: $checkedConvert('typeVal', (v) => (v as num?)?.toInt() ?? 0),
      );
      return val;
    });

Map<String, dynamic> _$ClassStatisticsInfoToJson(ClassStatisticsInfo instance) => <String, dynamic>{
  'classId': instance.classId,
  'type': instance.type,
  'typeVal': instance.typeVal,
};

PlayerSvtDefaultData _$PlayerSvtDefaultDataFromJson(Map json) =>
    $checkedCreate('PlayerSvtDefaultData', json, ($checkedConvert) {
      final val = PlayerSvtDefaultData(
        lv: $checkedConvert('lv', (v) => (v as num?)?.toInt() ?? 90),
        useMaxLv: $checkedConvert('useMaxLv', (v) => v as bool? ?? true),
        tdLv: $checkedConvert('tdLv', (v) => (v as num?)?.toInt() ?? 5),
        useDefaultTdLv: $checkedConvert('useDefaultTdLv', (v) => v as bool? ?? true),
        limitCount: $checkedConvert('limitCount', (v) => (v as num?)?.toInt() ?? 4),
        activeSkillLv: $checkedConvert('activeSkillLv', (v) => (v as num?)?.toInt() ?? 10),
        appendLvs: $checkedConvert('appendLvs', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
        atkFou: $checkedConvert('atkFou', (v) => (v as num?)?.toInt() ?? 100),
        hpFou: $checkedConvert('hpFou', (v) => (v as num?)?.toInt() ?? 100),
        cardStrengthens: $checkedConvert(
          'cardStrengthens',
          (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        ),
        ceMaxLimitBreak: $checkedConvert('ceMaxLimitBreak', (v) => v as bool? ?? false),
        ceMaxLv: $checkedConvert('ceMaxLv', (v) => v as bool? ?? false),
      );
      return val;
    });

Map<String, dynamic> _$PlayerSvtDefaultDataToJson(PlayerSvtDefaultData instance) => <String, dynamic>{
  'useMaxLv': instance.useMaxLv,
  'lv': instance.lv,
  'useDefaultTdLv': instance.useDefaultTdLv,
  'tdLv': instance.tdLv,
  'limitCount': instance.limitCount,
  'activeSkillLv': instance.activeSkillLv,
  'appendLvs': instance.appendLvs,
  'atkFou': instance.atkFou,
  'hpFou': instance.hpFou,
  'cardStrengthens': instance.cardStrengthens,
  'ceMaxLimitBreak': instance.ceMaxLimitBreak,
  'ceMaxLv': instance.ceMaxLv,
};

CustomSkillData _$CustomSkillDataFromJson(Map json) => $checkedCreate('CustomSkillData', json, ($checkedConvert) {
  final val = CustomSkillData(
    skillId: $checkedConvert('skillId', (v) => (v as num?)?.toInt()),
    name: $checkedConvert('name', (v) => v as String? ?? ''),
    cd: $checkedConvert('cd', (v) => (v as num?)?.toInt() ?? 0),
    skillType: $checkedConvert('skillType', (v) => $enumDecodeNullable(_$SkillTypeEnumMap, v) ?? SkillType.passive),
    effects: $checkedConvert(
      'effects',
      (v) => (v as List<dynamic>?)?.map((e) => CustomFuncData.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
    buffOnly: $checkedConvert('buffOnly', (v) => v as bool? ?? false),
    hasTurnCount: $checkedConvert('hasTurnCount', (v) => v as bool? ?? true),
  );
  return val;
});

Map<String, dynamic> _$CustomSkillDataToJson(CustomSkillData instance) => <String, dynamic>{
  'skillId': instance.skillId,
  'name': instance.name,
  'cd': instance.cd,
  'skillType': _$SkillTypeEnumMap[instance.skillType]!,
  'effects': instance.effects.map((e) => e.toJson()).toList(),
  'buffOnly': instance.buffOnly,
  'hasTurnCount': instance.hasTurnCount,
};

const _$SkillTypeEnumMap = {SkillType.active: 'active', SkillType.passive: 'passive'};

CustomFuncData _$CustomFuncDataFromJson(Map json) => $checkedCreate('CustomFuncData', json, ($checkedConvert) {
  final val = CustomFuncData(
    funcId: $checkedConvert('funcId', (v) => (v as num?)?.toInt()),
    buffId: $checkedConvert('buffId', (v) => (v as num?)?.toInt()),
    turn: $checkedConvert('turn', (v) => (v as num?)?.toInt() ?? -1),
    count: $checkedConvert('count', (v) => (v as num?)?.toInt() ?? -1),
    rate: $checkedConvert('rate', (v) => (v as num?)?.toInt() ?? 5000),
    value: $checkedConvert('value', (v) => (v as num?)?.toInt() ?? 0),
    enabled: $checkedConvert('enabled', (v) => v as bool? ?? false),
    useValue: $checkedConvert('useValue', (v) => v as bool? ?? true),
    target: $checkedConvert('target', (v) => $enumDecodeNullable(_$FuncTargetTypeEnumMap, v) ?? FuncTargetType.self),
  );
  return val;
});

Map<String, dynamic> _$CustomFuncDataToJson(CustomFuncData instance) => <String, dynamic>{
  'funcId': instance.funcId,
  'buffId': instance.buffId,
  'turn': instance.turn,
  'count': instance.count,
  'rate': instance.rate,
  'value': instance.value,
  'enabled': instance.enabled,
  'useValue': instance.useValue,
  'target': _$FuncTargetTypeEnumMap[instance.target]!,
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
};

TdDamageOptions _$TdDamageOptionsFromJson(Map json) => $checkedCreate('TdDamageOptions', json, ($checkedConvert) {
  final val = TdDamageOptions(
    enemy: $checkedConvert(
      'enemy',
      (v) => _$JsonConverterFromJson<Map<dynamic, dynamic>, QuestEnemy>(v, const _QuestEnemyConverter().fromJson),
    ),
    supports: $checkedConvert('supports', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
    enemyCount: $checkedConvert('enemyCount', (v) => (v as num?)?.toInt() ?? 1),
    usePlayerSvt: $checkedConvert(
      'usePlayerSvt',
      (v) => $enumDecodeNullable(_$PreferPlayerSvtDataSourceEnumMap, v) ?? PreferPlayerSvtDataSource.none,
    ),
    classBoard: $checkedConvert(
      'classBoard',
      (v) => $enumDecodeNullable(_$PreferClassBoardDataSourceEnumMap, v) ?? PreferClassBoardDataSource.none,
    ),
    addDebuffImmune: $checkedConvert('addDebuffImmune', (v) => v as bool? ?? true),
    addDebuffImmuneEnemy: $checkedConvert('addDebuffImmuneEnemy', (v) => v as bool? ?? false),
    upResistSubState: $checkedConvert('upResistSubState', (v) => v as bool? ?? true),
    enableActiveSkills: $checkedConvert('enableActiveSkills', (v) => v as bool? ?? true),
    twiceActiveSkill: $checkedConvert('twiceActiveSkill', (v) => v as bool? ?? false),
    twiceSkillOnTurn3: $checkedConvert('twiceSkillOnTurn3', (v) => v as bool? ?? false),
    appendSkills: $checkedConvert('appendSkills', (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList()),
    svtLv: $checkedConvert('svtLv', (v) => $enumDecodeNullable(_$SvtLvEnumMap, v) ?? SvtLv.maxLv),
    fouHpAtk: $checkedConvert('fouHpAtk', (v) => (v as num?)?.toInt() ?? 1000),
    tdR3: $checkedConvert('tdR3', (v) => (v as num?)?.toInt() ?? 5),
    tdR4: $checkedConvert('tdR4', (v) => (v as num?)?.toInt() ?? 2),
    tdR5: $checkedConvert('tdR5', (v) => (v as num?)?.toInt() ?? 1),
    oc: $checkedConvert('oc', (v) => (v as num?)?.toInt() ?? 1),
    fixedOC: $checkedConvert('fixedOC', (v) => v as bool? ?? true),
    region: $checkedConvert('region', (v) => v == null ? Region.jp : const RegionConverter().fromJson(v as String)),
    ceId: $checkedConvert('ceId', (v) => (v as num?)?.toInt()),
    ceLv: $checkedConvert('ceLv', (v) => (v as num?)?.toInt() ?? 0),
    ceMLB: $checkedConvert('ceMLB', (v) => v as bool? ?? true),
    mcId: $checkedConvert('mcId', (v) => (v as num?)?.toInt()),
    mcLv: $checkedConvert('mcLv', (v) => (v as num?)?.toInt() ?? 10),
    extraBuffs: $checkedConvert(
      'extraBuffs',
      (v) => v == null ? null : CustomSkillData.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    fieldTraits: $checkedConvert('fieldTraits', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
    warId: $checkedConvert('warId', (v) => (v as num?)?.toInt() ?? 0),
    random: $checkedConvert('random', (v) => (v as num?)?.toInt() ?? 1000),
    probabilityThreshold: $checkedConvert('probabilityThreshold', (v) => (v as num?)?.toInt() ?? 1000),
    forceDamageNpSe: $checkedConvert('forceDamageNpSe', (v) => v as bool? ?? false),
    damageNpIndivSumCount: $checkedConvert('damageNpIndivSumCount', (v) => (v as num?)?.toInt()),
    damageNpHpRatioMax: $checkedConvert('damageNpHpRatioMax', (v) => v as bool? ?? false),
  );
  return val;
});

Map<String, dynamic> _$TdDamageOptionsToJson(TdDamageOptions instance) => <String, dynamic>{
  'enemy': const _QuestEnemyConverter().toJson(instance.enemy),
  'supports': instance.supports,
  'enemyCount': instance.enemyCount,
  'usePlayerSvt': _$PreferPlayerSvtDataSourceEnumMap[instance.usePlayerSvt]!,
  'classBoard': _$PreferClassBoardDataSourceEnumMap[instance.classBoard]!,
  'addDebuffImmune': instance.addDebuffImmune,
  'addDebuffImmuneEnemy': instance.addDebuffImmuneEnemy,
  'upResistSubState': instance.upResistSubState,
  'enableActiveSkills': instance.enableActiveSkills,
  'twiceActiveSkill': instance.twiceActiveSkill,
  'twiceSkillOnTurn3': instance.twiceSkillOnTurn3,
  'appendSkills': instance.appendSkills,
  'svtLv': _$SvtLvEnumMap[instance.svtLv]!,
  'fouHpAtk': instance.fouHpAtk,
  'tdR3': instance.tdR3,
  'tdR4': instance.tdR4,
  'tdR5': instance.tdR5,
  'oc': instance.oc,
  'fixedOC': instance.fixedOC,
  'region': const RegionConverter().toJson(instance.region),
  'ceId': instance.ceId,
  'ceLv': instance.ceLv,
  'ceMLB': instance.ceMLB,
  'mcId': instance.mcId,
  'mcLv': instance.mcLv,
  'extraBuffs': instance.extraBuffs.toJson(),
  'fieldTraits': instance.fieldTraits,
  'warId': instance.warId,
  'random': instance.random,
  'probabilityThreshold': instance.probabilityThreshold,
  'forceDamageNpSe': instance.forceDamageNpSe,
  'damageNpIndivSumCount': instance.damageNpIndivSumCount,
  'damageNpHpRatioMax': instance.damageNpHpRatioMax,
};

const _$PreferClassBoardDataSourceEnumMap = {
  PreferClassBoardDataSource.none: 'none',
  PreferClassBoardDataSource.current: 'current',
  PreferClassBoardDataSource.target: 'target',
  PreferClassBoardDataSource.full: 'full',
};

const _$SvtLvEnumMap = {SvtLv.maxLv: 'maxLv', SvtLv.lv90: 'lv90', SvtLv.lv100: 'lv100', SvtLv.lv120: 'lv120'};

BattleReplayDelegateData _$BattleReplayDelegateDataFromJson(Map json) => $checkedCreate(
  'BattleReplayDelegateData',
  json,
  ($checkedConvert) {
    final val = BattleReplayDelegateData(
      actWeightSelections: $checkedConvert(
        'actWeightSelections',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num?)?.toInt()).toList(),
      ),
      skillActSelectSelections: $checkedConvert(
        'skillActSelectSelections',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num?)?.toInt()).toList(),
      ),
      tdTypeChanges: $checkedConvert(
        'tdTypeChanges',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
        readValue: BattleReplayDelegateData._readTdTypeChanges,
      ),
      ptRandomIndexes: $checkedConvert(
        'ptRandomIndexes',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num?)?.toInt()).toList(),
      ),
      canActivateDecisions: $checkedConvert(
        'canActivateDecisions',
        (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList(),
      ),
      damageSelections: $checkedConvert(
        'damageSelections',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      replaceMemberIndexes: $checkedConvert(
        'replaceMemberIndexes',
        (v) => (v as List<dynamic>?)?.map((e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList()).toList(),
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$BattleReplayDelegateDataToJson(BattleReplayDelegateData instance) => <String, dynamic>{
  'actWeightSelections': instance.actWeightSelections,
  'skillActSelectSelections': instance.skillActSelectSelections,
  'tdTypeChanges': instance.tdTypeChanges,
  'ptRandomIndexes': instance.ptRandomIndexes,
  'canActivateDecisions': instance.canActivateDecisions,
  'damageSelections': instance.damageSelections,
  'replaceMemberIndexes': instance.replaceMemberIndexes,
};

BattleActionOptions _$BattleActionOptionsFromJson(Map json) =>
    $checkedCreate('BattleActionOptions', json, ($checkedConvert) {
      final val = BattleActionOptions(
        playerTarget: $checkedConvert('playerTarget', (v) => (v as num?)?.toInt() ?? 0),
        enemyTarget: $checkedConvert('enemyTarget', (v) => (v as num?)?.toInt() ?? 0),
        random: $checkedConvert('random', (v) => (v as num?)?.toInt() ?? 900),
        threshold: $checkedConvert('threshold', (v) => (v as num?)?.toInt() ?? 1000),
      );
      return val;
    });

Map<String, dynamic> _$BattleActionOptionsToJson(BattleActionOptions instance) => <String, dynamic>{
  'playerTarget': instance.playerTarget,
  'enemyTarget': instance.enemyTarget,
  'random': instance.random,
  'threshold': instance.threshold,
};

BattleRecordData _$BattleRecordDataFromJson(Map json) => $checkedCreate('BattleRecordData', json, ($checkedConvert) {
  final val = BattleRecordData(
    options: $checkedConvert(
      'options',
      (v) => v == null ? null : BattleActionOptions.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
  );
  $checkedConvert('type', (v) => val.type = $enumDecode(_$BattleRecordDataTypeEnumMap, v));
  $checkedConvert('svt', (v) => val.svt = (v as num?)?.toInt());
  $checkedConvert('skill', (v) => val.skill = (v as num?)?.toInt());
  $checkedConvert(
    'attacks',
    (v) =>
        val.attacks =
            (v as List<dynamic>?)
                ?.map((e) => BattleAttackRecordData.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList(),
  );
  return val;
});

Map<String, dynamic> _$BattleRecordDataToJson(BattleRecordData instance) => <String, dynamic>{
  'type': _$BattleRecordDataTypeEnumMap[instance.type]!,
  if (instance.svt case final value?) 'svt': value,
  if (instance.skill case final value?) 'skill': value,
  if (instance.attacks?.map((e) => e.toJson()).toList() case final value?) 'attacks': value,
  'options': instance.options.toJson(),
};

const _$BattleRecordDataTypeEnumMap = {
  BattleRecordDataType.base: 'base',
  BattleRecordDataType.skill: 'skill',
  BattleRecordDataType.attack: 'attack',
};

BattleAttackRecordData _$BattleAttackRecordDataFromJson(Map json) =>
    $checkedCreate('BattleAttackRecordData', json, ($checkedConvert) {
      final val = BattleAttackRecordData(
        svt: $checkedConvert('svt', (v) => (v as num?)?.toInt() ?? 0),
        card: $checkedConvert('card', (v) => (v as num?)?.toInt()),
        isTD: $checkedConvert('isTD', (v) => v as bool? ?? false),
        critical: $checkedConvert('critical', (v) => v as bool? ?? false),
        cardType: $checkedConvert('cardType', (v) => v == null ? CardType.none : const CardTypeConverter().fromJson(v)),
      );
      return val;
    });

Map<String, dynamic> _$BattleAttackRecordDataToJson(BattleAttackRecordData instance) => <String, dynamic>{
  'svt': instance.svt,
  'card': instance.card,
  'isTD': instance.isTD,
  'critical': instance.critical,
  'cardType': const CardTypeConverter().toJson(instance.cardType),
};
