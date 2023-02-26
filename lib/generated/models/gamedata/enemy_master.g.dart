// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/enemy_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnemyMaster _$EnemyMasterFromJson(Map json) => EnemyMaster(
      id: json['id'] as int,
      name: json['name'] as String? ?? "",
      battles: (json['battles'] as List<dynamic>?)
              ?.map((e) => EnemyMasterBattle.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

EnemyMasterBattle _$EnemyMasterBattleFromJson(Map json) => EnemyMasterBattle(
      id: json['id'] as int,
      face: json['face'] as String,
      figure: json['figure'] as String,
      commandSpellIcon: json['commandSpellIcon'] as String,
      maxCommandSpell: json['maxCommandSpell'] as int,
      cutin:
          (json['cutin'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );
