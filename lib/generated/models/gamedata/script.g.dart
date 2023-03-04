// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/script.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NiceScript _$NiceScriptFromJson(Map json) => NiceScript(
      scriptId: json['scriptId'] as String,
      scriptSizeBytes: json['scriptSizeBytes'] as int,
      script: json['script'] as String,
      quests:
          (json['quests'] as List<dynamic>).map((e) => Quest.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    );

ScriptLink _$ScriptLinkFromJson(Map json) => ScriptLink(
      scriptId: json['scriptId'] as String,
      script: json['script'] as String,
    );

ValentineScript _$ValentineScriptFromJson(Map json) => ValentineScript(
      scriptId: json['scriptId'] as String,
      script: json['script'] as String,
      scriptName: json['scriptName'] as String,
    );

StageLink _$StageLinkFromJson(Map json) => StageLink(
      questId: json['questId'] as int,
      phase: json['phase'] as int,
      stage: json['stage'] as int,
    );
