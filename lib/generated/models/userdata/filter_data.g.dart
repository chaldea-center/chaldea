// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/userdata/filter_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SvtFilterData _$SvtFilterDataFromJson(Map json) => $checkedCreate(
      'SvtFilterData',
      json,
      ($checkedConvert) {
        final val = SvtFilterData(
          useGrid: $checkedConvert('useGrid', (v) => v as bool? ?? false),
          favorite: $checkedConvert(
              'favorite',
              (v) =>
                  $enumDecodeNullable(_$FavoriteStateEnumMap, v) ??
                  FavoriteState.all),
          planFavorite: $checkedConvert(
              'planFavorite',
              (v) =>
                  $enumDecodeNullable(_$FavoriteStateEnumMap, v) ??
                  FavoriteState.all),
          sortKeys: $checkedConvert(
              'sortKeys',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => $enumDecodeNullable(_$SvtCompareEnumMap, e))
                  .toList()),
          sortReversed: $checkedConvert('sortReversed',
              (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$SvtFilterDataToJson(SvtFilterData instance) =>
    <String, dynamic>{
      'useGrid': instance.useGrid,
      'favorite': _$FavoriteStateEnumMap[instance.favorite],
      'planFavorite': _$FavoriteStateEnumMap[instance.planFavorite],
      'sortKeys': instance.sortKeys.map((e) => _$SvtCompareEnumMap[e]).toList(),
      'sortReversed': instance.sortReversed,
    };

const _$FavoriteStateEnumMap = {
  FavoriteState.all: 'all',
  FavoriteState.owned: 'owned',
  FavoriteState.planned: 'planned',
  FavoriteState.other: 'other',
};

const _$SvtCompareEnumMap = {
  SvtCompare.no: 'no',
  SvtCompare.className: 'className',
  SvtCompare.rarity: 'rarity',
  SvtCompare.atk: 'atk',
  SvtCompare.hp: 'hp',
  SvtCompare.priority: 'priority',
};

CraftFilterData _$CraftFilterDataFromJson(Map json) => $checkedCreate(
      'CraftFilterData',
      json,
      ($checkedConvert) {
        final val = CraftFilterData(
          useGrid: $checkedConvert('useGrid', (v) => v as bool? ?? false),
          favorite: $checkedConvert('favorite', (v) => v as bool? ?? false),
          sortKeys: $checkedConvert(
              'sortKeys',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => $enumDecodeNullable(_$CraftCompareEnumMap, e))
                  .toList()),
          sortReversed: $checkedConvert('sortReversed',
              (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$CraftFilterDataToJson(CraftFilterData instance) =>
    <String, dynamic>{
      'useGrid': instance.useGrid,
      'favorite': instance.favorite,
      'sortKeys':
          instance.sortKeys.map((e) => _$CraftCompareEnumMap[e]).toList(),
      'sortReversed': instance.sortReversed,
    };

const _$CraftCompareEnumMap = {
  CraftCompare.no: 'no',
  CraftCompare.rarity: 'rarity',
  CraftCompare.atk: 'atk',
  CraftCompare.hp: 'hp',
};

CmdCodeFilterData _$CmdCodeFilterDataFromJson(Map json) => $checkedCreate(
      'CmdCodeFilterData',
      json,
      ($checkedConvert) {
        final val = CmdCodeFilterData(
          useGrid: $checkedConvert('useGrid', (v) => v as bool? ?? false),
          favorite: $checkedConvert('favorite', (v) => v as bool? ?? false),
          sortKeys: $checkedConvert(
              'sortKeys',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => $enumDecodeNullable(_$CmdCodeCompareEnumMap, e))
                  .toList()),
          sortReversed: $checkedConvert('sortReversed',
              (v) => (v as List<dynamic>?)?.map((e) => e as bool).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$CmdCodeFilterDataToJson(CmdCodeFilterData instance) =>
    <String, dynamic>{
      'useGrid': instance.useGrid,
      'favorite': instance.favorite,
      'sortKeys':
          instance.sortKeys.map((e) => _$CmdCodeCompareEnumMap[e]).toList(),
      'sortReversed': instance.sortReversed,
    };

const _$CmdCodeCompareEnumMap = {
  CmdCodeCompare.no: 'no',
  CmdCodeCompare.rarity: 'rarity',
};
