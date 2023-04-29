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

Map<String, dynamic> _$DropDataToJson(DropData instance) => <String, dynamic>{
      'domusVer': instance.domusVer,
      'domusAurea': instance.domusAurea.toJson(),
      'fixedDrops': instance.fixedDrops.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'freeDrops': instance.freeDrops.map((k, e) => MapEntry(k.toString(), e.toJson())),
    };

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

Map<String, dynamic> _$DropRateSheetToJson(DropRateSheet instance) => <String, dynamic>{
      'itemIds': instance.itemIds,
      'questIds': instance.questIds,
      'apCosts': instance.apCosts,
      'runs': instance.runs,
      'bonds': instance.bonds,
      'exps': instance.exps,
      'sparseMatrix':
          instance.sparseMatrix.map((k, e) => MapEntry(k.toString(), e.map((k, e) => MapEntry(k.toString(), e)))),
    };

QuestDropData _$QuestDropDataFromJson(Map json) => QuestDropData(
      runs: json['runs'] as int? ?? 0,
      items: (json['items'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), e as int),
          ) ??
          const {},
      groups: (json['groups'] as Map?)?.map(
            (k, e) => MapEntry(int.parse(k as String), e as int),
          ) ??
          const {},
    );

Map<String, dynamic> _$QuestDropDataToJson(QuestDropData instance) => <String, dynamic>{
      'runs': instance.runs,
      'items': instance.items.map((k, e) => MapEntry(k.toString(), e)),
      'groups': instance.groups.map((k, e) => MapEntry(k.toString(), e)),
    };
