// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/drop_rate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DropRateData _$DropRateDataFromJson(Map json) => DropRateData(
      updatedAt: json['updatedAt'] as int? ?? 0,
      newData:
          json['newData'] == null ? null : DropRateSheet.fromJson(Map<String, dynamic>.from(json['newData'] as Map)),
      legacyData: json['legacyData'] == null
          ? null
          : DropRateSheet.fromJson(Map<String, dynamic>.from(json['legacyData'] as Map)),
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
