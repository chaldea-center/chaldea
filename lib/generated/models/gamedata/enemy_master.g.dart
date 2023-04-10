// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/enemy_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnemyMaster _$EnemyMasterFromJson(Map json) => EnemyMaster(
      id: json['id'] as int,
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
      id: json['id'] as int,
      face: json['face'] as String,
      figure: json['figure'] as String,
      commandSpellIcon: json['commandSpellIcon'] as String,
      maxCommandSpell: json['maxCommandSpell'] as int,
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
