// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/userdata/battle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BattleSimSetting _$BattleSimSettingFromJson(Map json) => $checkedCreate(
      'BattleSimSetting',
      json,
      ($checkedConvert) {
        final val = BattleSimSetting(
          previousQuestPhase: $checkedConvert('previousQuestPhase', (v) => v as String?),
          preferPlayerData: $checkedConvert('preferPlayerData', (v) => v as bool? ?? true),
          pingedCEs: $checkedConvert('pingedCEs', (v) => (v as List<dynamic>?)?.map((e) => e as int).toSet()),
          pingedSvts: $checkedConvert('pingedSvts', (v) => (v as List<dynamic>?)?.map((e) => e as int).toSet()),
          defaultLvs: $checkedConvert('defaultLvs',
              (v) => v == null ? null : PlayerSvtDefaultData.fromJson(Map<String, dynamic>.from(v as Map))),
          formations: $checkedConvert(
              'formations',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => BattleTeamFormation.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          curFormationIndex: $checkedConvert('curFormationIndex', (v) => v as int? ?? 0),
        );
        return val;
      },
    );

Map<String, dynamic> _$BattleSimSettingToJson(BattleSimSetting instance) => <String, dynamic>{
      'previousQuestPhase': instance.previousQuestPhase,
      'preferPlayerData': instance.preferPlayerData,
      'pingedCEs': instance.pingedCEs.toList(),
      'pingedSvts': instance.pingedSvts.toList(),
      'defaultLvs': instance.defaultLvs.toJson(),
      'formations': instance.formations.map((e) => e.toJson()).toList(),
      'curFormationIndex': instance.curFormationIndex,
    };

BattleTeamFormation _$BattleTeamFormationFromJson(Map json) => $checkedCreate(
      'BattleTeamFormation',
      json,
      ($checkedConvert) {
        final val = BattleTeamFormation(
          name: $checkedConvert('name', (v) => v as String?),
          onFieldSvts: $checkedConvert(
              'onFieldSvts',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => e == null ? null : SvtSaveData.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          backupSvts: $checkedConvert(
              'backupSvts',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => e == null ? null : SvtSaveData.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          mysticCode: $checkedConvert(
              'mysticCode', (v) => v == null ? null : MysticCodeSaveData.fromJson(Map<String, dynamic>.from(v as Map))),
        );
        return val;
      },
    );

Map<String, dynamic> _$BattleTeamFormationToJson(BattleTeamFormation instance) => <String, dynamic>{
      'name': instance.name,
      'onFieldSvts': instance.onFieldSvts.map((e) => e?.toJson()).toList(),
      'backupSvts': instance.backupSvts.map((e) => e?.toJson()).toList(),
      'mysticCode': instance.mysticCode.toJson(),
    };

SvtSaveData _$SvtSaveDataFromJson(Map json) => $checkedCreate(
      'SvtSaveData',
      json,
      ($checkedConvert) {
        final val = SvtSaveData(
          svtId: $checkedConvert('svtId', (v) => v as int?),
          limitCount: $checkedConvert('limitCount', (v) => v as int? ?? 4),
          skillLvs: $checkedConvert('skillLvs', (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          skillIds: $checkedConvert('skillIds', (v) => (v as List<dynamic>?)?.map((e) => e as int?).toList()),
          appendLvs: $checkedConvert('appendLvs', (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          disabledExtraSkills:
              $checkedConvert('disabledExtraSkills', (v) => (v as List<dynamic>?)?.map((e) => e as int).toSet()),
          additionalPassives: $checkedConvert(
              'additionalPassives',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => BaseSkill.fromJson(Map<String, dynamic>.from(e as Map))).toList()),
          additionalPassiveLvs:
              $checkedConvert('additionalPassiveLvs', (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          tdLv: $checkedConvert('tdLv', (v) => v as int? ?? 5),
          tdId: $checkedConvert('tdId', (v) => v as int?),
          lv: $checkedConvert('lv', (v) => v as int? ?? 1),
          atkFou: $checkedConvert('atkFou', (v) => v as int? ?? 1000),
          hpFou: $checkedConvert('hpFou', (v) => v as int? ?? 1000),
          fixedAtk: $checkedConvert('fixedAtk', (v) => v as int?),
          fixedHp: $checkedConvert('fixedHp', (v) => v as int?),
          ceId: $checkedConvert('ceId', (v) => v as int?),
          ceLimitBreak: $checkedConvert('ceLimitBreak', (v) => v as bool? ?? false),
          ceLv: $checkedConvert('ceLv', (v) => v as int? ?? 0),
          isSupportSvt: $checkedConvert('isSupportSvt', (v) => v as bool? ?? false),
          cardStrengthens:
              $checkedConvert('cardStrengthens', (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          commandCodeIds:
              $checkedConvert('commandCodeIds', (v) => (v as List<dynamic>?)?.map((e) => e as int?).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$SvtSaveDataToJson(SvtSaveData instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'limitCount': instance.limitCount,
      'skillLvs': instance.skillLvs,
      'skillIds': instance.skillIds,
      'appendLvs': instance.appendLvs,
      'disabledExtraSkills': instance.disabledExtraSkills.toList(),
      'additionalPassives': instance.additionalPassives.map((e) => e.toJson()).toList(),
      'additionalPassiveLvs': instance.additionalPassiveLvs,
      'tdLv': instance.tdLv,
      'tdId': instance.tdId,
      'lv': instance.lv,
      'atkFou': instance.atkFou,
      'hpFou': instance.hpFou,
      'fixedAtk': instance.fixedAtk,
      'fixedHp': instance.fixedHp,
      'ceId': instance.ceId,
      'ceLimitBreak': instance.ceLimitBreak,
      'ceLv': instance.ceLv,
      'isSupportSvt': instance.isSupportSvt,
      'cardStrengthens': instance.cardStrengthens,
      'commandCodeIds': instance.commandCodeIds,
    };

MysticCodeSaveData _$MysticCodeSaveDataFromJson(Map json) => $checkedCreate(
      'MysticCodeSaveData',
      json,
      ($checkedConvert) {
        final val = MysticCodeSaveData(
          mysticCodeId: $checkedConvert('mysticCodeId', (v) => v as int? ?? 210),
          level: $checkedConvert('level', (v) => v as int? ?? 10),
        );
        return val;
      },
    );

Map<String, dynamic> _$MysticCodeSaveDataToJson(MysticCodeSaveData instance) => <String, dynamic>{
      'mysticCodeId': instance.mysticCodeId,
      'level': instance.level,
    };

PlayerSvtDefaultData _$PlayerSvtDefaultDataFromJson(Map json) => $checkedCreate(
      'PlayerSvtDefaultData',
      json,
      ($checkedConvert) {
        final val = PlayerSvtDefaultData(
          lv: $checkedConvert('lv', (v) => v as int? ?? 90),
          useMaxLv: $checkedConvert('useMaxLv', (v) => v as bool? ?? true),
          tdLv: $checkedConvert('tdLv', (v) => v as int? ?? 5),
          useDefaultTdLv: $checkedConvert('useDefaultTdLv', (v) => v as bool? ?? true),
          limitCount: $checkedConvert('limitCount', (v) => v as int? ?? 4),
          activeSkillLv: $checkedConvert('activeSkillLv', (v) => v as int? ?? 10),
          appendLvs: $checkedConvert('appendLvs', (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          atkFou: $checkedConvert('atkFou', (v) => v as int? ?? 100),
          hpFou: $checkedConvert('hpFou', (v) => v as int? ?? 100),
          cardStrengthens:
              $checkedConvert('cardStrengthens', (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
        );
        return val;
      },
    );

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
    };
