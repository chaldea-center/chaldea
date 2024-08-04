// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/vals.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValCheckBattlePointPhaseRange _$ValCheckBattlePointPhaseRangeFromJson(Map json) => ValCheckBattlePointPhaseRange(
      battlePointId: (json['battlePointId'] as num).toInt(),
      range: (json['range'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ValCheckBattlePointPhaseRangeToJson(ValCheckBattlePointPhaseRange instance) => <String, dynamic>{
      'battlePointId': instance.battlePointId,
      'range': instance.range,
    };

ValDamageRateBattlePointPhase _$ValDamageRateBattlePointPhaseFromJson(Map json) => ValDamageRateBattlePointPhase(
      battlePointPhase: (json['battlePointPhase'] as num).toInt(),
      value: (json['value'] as num).toInt(),
    );

Map<String, dynamic> _$ValDamageRateBattlePointPhaseToJson(ValDamageRateBattlePointPhase instance) => <String, dynamic>{
      'battlePointPhase': instance.battlePointPhase,
      'value': instance.value,
    };
