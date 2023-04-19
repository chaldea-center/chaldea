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
