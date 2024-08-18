// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/enemy_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnemyMaster _$EnemyMasterFromJson(Map json) => EnemyMaster(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? "",
      battles: (json['battles'] as List<dynamic>?)
              ?.map((e) => EnemyMasterBattle.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EnemyMasterToJson(EnemyMaster instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'battles': instance.battles.map((e) => e.toJson()).toList(),
    };

EnemyMasterBattle _$EnemyMasterBattleFromJson(Map json) => EnemyMasterBattle(
      id: (json['id'] as num).toInt(),
      face: json['face'] as String,
      figure: json['figure'] as String,
      commandSpellIcon: json['commandSpellIcon'] as String,
      maxCommandSpell: (json['maxCommandSpell'] as num).toInt(),
      cutin: (json['cutin'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );

Map<String, dynamic> _$EnemyMasterBattleToJson(EnemyMasterBattle instance) => <String, dynamic>{
      'id': instance.id,
      'face': instance.face,
      'figure': instance.figure,
      'commandSpellIcon': instance.commandSpellIcon,
      'maxCommandSpell': instance.maxCommandSpell,
      'cutin': instance.cutin,
    };

BattleMasterImage _$BattleMasterImageFromJson(Map json) => BattleMasterImage(
      id: (json['id'] as num).toInt(),
      type: $enumDecodeNullable(_$GenderEnumMap, json['type']) ?? Gender.unknown,
      faceIcon: json['faceIcon'] as String?,
      skillCutin: json['skillCutin'] as String?,
      skillCutinOffsetX: (json['skillCutinOffsetX'] as num?)?.toInt() ?? 0,
      skillCutinOffsetY: (json['skillCutinOffsetY'] as num?)?.toInt() ?? 0,
      commandSpellCutin: json['commandSpellCutin'] as String?,
      commandSpellCutinOffsetX: (json['commandSpellCutinOffsetX'] as num?)?.toInt() ?? 0,
      commandSpellCutinOffsetY: (json['commandSpellCutinOffsetY'] as num?)?.toInt() ?? 0,
      resultImage: json['resultImage'] as String?,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BattleMasterImageToJson(BattleMasterImage instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$GenderEnumMap[instance.type]!,
      'faceIcon': instance.faceIcon,
      'skillCutin': instance.skillCutin,
      'skillCutinOffsetX': instance.skillCutinOffsetX,
      'skillCutinOffsetY': instance.skillCutinOffsetY,
      'commandSpellCutin': instance.commandSpellCutin,
      'commandSpellCutinOffsetX': instance.commandSpellCutinOffsetX,
      'commandSpellCutinOffsetY': instance.commandSpellCutinOffsetY,
      'resultImage': instance.resultImage,
      'releaseConditions': instance.releaseConditions.map((e) => e.toJson()).toList(),
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.unknown: 'unknown',
};
