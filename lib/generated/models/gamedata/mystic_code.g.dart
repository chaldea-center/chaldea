// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/mystic_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MysticCode _$MysticCodeFromJson(Map json) => MysticCode(
      id: json['id'] as int,
      name: json['name'] as String,
      detail: json['detail'] as String,
      extraAssets: ExtraMCAssets.fromJson(Map<String, dynamic>.from(json['extraAssets'] as Map)),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      expRequired: (json['expRequired'] as List<dynamic>).map((e) => e as int).toList(),
      costumes: (json['costumes'] as List<dynamic>?)
              ?.map((e) => MysticCodeCostume.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
    );

MCAssets _$MCAssetsFromJson(Map json) => MCAssets(
      male: json['male'] as String,
      female: json['female'] as String,
    );

ExtraMCAssets _$ExtraMCAssetsFromJson(Map json) => ExtraMCAssets(
      item: MCAssets.fromJson(Map<String, dynamic>.from(json['item'] as Map)),
      masterFace: MCAssets.fromJson(Map<String, dynamic>.from(json['masterFace'] as Map)),
      masterFigure: MCAssets.fromJson(Map<String, dynamic>.from(json['masterFigure'] as Map)),
    );

MysticCodeCostume _$MysticCodeCostumeFromJson(Map json) => MysticCodeCostume(
      id: json['id'] as int,
      releaseConditions: (json['releaseConditions'] as List<dynamic>?)
              ?.map((e) => CommonRelease.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      extraAssets: ExtraMCAssets.fromJson(Map<String, dynamic>.from(json['extraAssets'] as Map)),
    );
