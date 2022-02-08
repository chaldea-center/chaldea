// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/gamedata/drop_rate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DropRateData _$DropRateDataFromJson(Map json) => DropRateData(
      newData: json['newData'] == null
          ? const DropRateSheet()
          : DropRateSheet.fromJson(
              Map<String, dynamic>.from(json['newData'] as Map)),
      legacyData: json['legacyData'] == null
          ? const DropRateSheet()
          : DropRateSheet.fromJson(
              Map<String, dynamic>.from(json['legacyData'] as Map)),
    );

DropRateSheet _$DropRateSheetFromJson(Map json) => DropRateSheet(
      questIds:
          (json['questIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      itemIds:
          (json['itemIds'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      apCosts:
          (json['apCosts'] as List<dynamic>?)?.map((e) => e as int).toList() ??
              const [],
      runs: (json['runs'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          const [],
      sparseMatrix: (json['sparseMatrix'] as Map?)?.map(
            (k, e) => MapEntry(
                int.parse(k as String),
                (e as Map).map(
                  (k, e) =>
                      MapEntry(int.parse(k as String), (e as num).toDouble()),
                )),
          ) ??
          const {},
    );
