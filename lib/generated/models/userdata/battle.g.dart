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
              (v) =>
                  (v as List<dynamic>?)?.map((e) => Formation.fromJson(Map<String, dynamic>.from(e as Map))).toList()),
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
    };

Formation _$FormationFromJson(Map json) => $checkedCreate(
      'Formation',
      json,
      ($checkedConvert) {
        final val = Formation(
          name: $checkedConvert('name', (v) => v as String?),
          onFieldSvtDataList: $checkedConvert(
              'onFieldSvtDataList',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => StoredSvtData.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          backupSvtDataList: $checkedConvert(
              'backupSvtDataList',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => StoredSvtData.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          mysticCodeData: $checkedConvert('mysticCodeData',
              (v) => v == null ? null : StoredMysticCodeData.fromJson(Map<String, dynamic>.from(v as Map))),
        );
        return val;
      },
    );

Map<String, dynamic> _$FormationToJson(Formation instance) => <String, dynamic>{
      'name': instance.name,
      'onFieldSvtDataList': instance.onFieldSvtDataList.map((e) => e.toJson()).toList(),
      'backupSvtDataList': instance.backupSvtDataList.map((e) => e.toJson()).toList(),
      'mysticCodeData': instance.mysticCodeData.toJson(),
    };

StoredSvtData _$StoredPlayerSvtDataFromJson(Map json) => $checkedCreate(
      'StoredPlayerSvtData',
      json,
      ($checkedConvert) {
        final val = StoredSvtData(
          svtId: $checkedConvert('svtId', (v) => v as int?),
          limitCount: $checkedConvert('limitCount', (v) => v as int? ?? 4),
          skillLvs: $checkedConvert('skillLvs', (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          skillIds: $checkedConvert('skillIds', (v) => (v as List<dynamic>?)?.map((e) => e as int?).toList()),
          appendLvs: $checkedConvert('appendLvs', (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          extraPassiveIds:
              $checkedConvert('extraPassiveIds', (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
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

Map<String, dynamic> _$StoredPlayerSvtDataToJson(StoredSvtData instance) => <String, dynamic>{
      'svtId': instance.svtId,
      'limitCount': instance.limitCount,
      'skillLvs': instance.skillLvs,
      'skillIds': instance.skillIds,
      'appendLvs': instance.appendLvs,
      'extraPassiveIds': instance.extraPassiveIds,
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

StoredMysticCodeData _$StoredMysticCodeDataFromJson(Map json) => $checkedCreate(
      'StoredMysticCodeData',
      json,
      ($checkedConvert) {
        final val = StoredMysticCodeData(
          mysticCodeId: $checkedConvert('mysticCodeId', (v) => v as int?),
          level: $checkedConvert('level', (v) => v as int? ?? 10),
        );
        return val;
      },
    );

Map<String, dynamic> _$StoredMysticCodeDataToJson(StoredMysticCodeData instance) => <String, dynamic>{
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
