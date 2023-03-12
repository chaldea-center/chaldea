// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/drop_rate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DropData _$DropDataFromJson(Map json) => DropData(
      domusVer: json['domusVer'] as int? ?? 0,
      domusAurea: json['domusAurea'] == null
          ? null
          : DropRateSheet.fromJson(Map<String, dynamic>.from(json['domusAurea'] as Map)),
      fixedDrops: (json['fixedDrops'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), QuestDropData.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
      freeDrops: (json['freeDrops'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), QuestDropData.fromJson(Map<String, dynamic>.from(e as Map))),
          ) ??
          const {},
    );

DropRateSheet _$DropRateSheetFromJson(Map json) => DropRateSheet(
      itemIds: (json['itemIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      questIds: (json['questIds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      apCosts: (json['apCosts'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      runs: (json['runs'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      bonds: (json['bonds'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      exps: (json['exps'] as List<dynamic>?)?.map((e) => e as int).toList() ?? const [],
      sparseMatrix: (json['sparseMatrix'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                (e as Map).map(
                  (k, e) => MapEntry(int.parse(k as String), (e as num).toDouble()),
                )),
          ) ??
          const {},
    );

QuestDropData _$QuestDropDataFromJson(Map json) => QuestDropData(
      runs: json['runs'] as int? ?? 0,
      items: (json['items'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), e as int),
          ) ??
          const {},
    );
