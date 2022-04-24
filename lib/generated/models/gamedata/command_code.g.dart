// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/command_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandCode _$CommandCodeFromJson(Map json) => CommandCode(
      id: json['id'] as int,
      collectionNo: json['collectionNo'] as int,
      name: json['name'] as String,
      ruby: json['ruby'] as String? ?? "",
      rarity: json['rarity'] as int,
      extraAssets: ExtraCCAssets.fromJson(
          Map<String, dynamic>.from(json['extraAssets'] as Map)),
      skills: (json['skills'] as List<dynamic>)
          .map((e) => NiceSkill.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      illustrator: json['illustrator'] as String,
      comment: json['comment'] as String,
    );
