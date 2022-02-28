// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/userdata/local_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalSettings _$LocalSettingsFromJson(Map json) => $checkedCreate(
      'LocalSettings',
      json,
      ($checkedConvert) {
        final val = LocalSettings(
          beta: $checkedConvert('beta', (v) => v as bool? ?? false),
          showWindowFab:
              $checkedConvert('showWindowFab', (v) => v as bool? ?? true),
          showDebugFab:
              $checkedConvert('showDebugFab', (v) => v as bool? ?? false),
          alwaysOnTop:
              $checkedConvert('alwaysOnTop', (v) => v as bool? ?? false),
          windowPosition: $checkedConvert('windowPosition',
              (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          launchTimes: $checkedConvert('launchTimes', (v) => v as int? ?? 1),
          themeMode: $checkedConvert(
              'themeMode',
              (v) =>
                  $enumDecodeNullable(_$ThemeModeEnumMap, v) ??
                  ThemeMode.system),
          language: $checkedConvert('language', (v) => v as String?),
          preferredRegions: $checkedConvert(
              'preferredRegions',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => $enumDecode(_$RegionEnumMap, e))
                  .toList()),
          autoUpdateData:
              $checkedConvert('autoUpdateData', (v) => v as bool? ?? true),
          autoUpdateApp:
              $checkedConvert('autoUpdateApp', (v) => v as bool? ?? true),
          autoRotate: $checkedConvert('autoRotate', (v) => v as bool? ?? true),
          autoResetFilter:
              $checkedConvert('autoResetFilter', (v) => v as bool? ?? true),
          useProxy: $checkedConvert('useProxy', (v) => v as bool? ?? false),
          favoritePreferred: $checkedConvert('favoritePreferred',
              (v) => $enumDecodeNullable(_$FavoriteStateEnumMap, v)),
          priorityTags: $checkedConvert(
              'priorityTags',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), e as String),
                  )),
          galleries: $checkedConvert(
              'galleries',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, e as bool),
                  )),
          display: $checkedConvert(
              'display',
              (v) => v == null
                  ? null
                  : DisplaySettings.fromJson(
                      Map<String, dynamic>.from(v as Map))),
          carousel: $checkedConvert(
              'carousel',
              (v) => v == null
                  ? null
                  : CarouselSetting.fromJson(
                      Map<String, dynamic>.from(v as Map))),
          tips: $checkedConvert(
              'tips',
              (v) => v == null
                  ? null
                  : TipsSetting.fromJson(Map<String, dynamic>.from(v as Map))),
          svtFilterData: $checkedConvert(
              'svtFilterData',
              (v) => v == null
                  ? null
                  : SvtFilterData.fromJson(
                      Map<String, dynamic>.from(v as Map))),
          craftFilterData: $checkedConvert(
              'craftFilterData',
              (v) => v == null
                  ? null
                  : CraftFilterData.fromJson(
                      Map<String, dynamic>.from(v as Map))),
        );
        $checkedConvert(
            'useAndroidExternal', (v) => val.useAndroidExternal = v as bool);
        return val;
      },
    );

Map<String, dynamic> _$LocalSettingsToJson(LocalSettings instance) =>
    <String, dynamic>{
      'beta': instance.beta,
      'showWindowFab': instance.showWindowFab,
      'showDebugFab': instance.showDebugFab,
      'alwaysOnTop': instance.alwaysOnTop,
      'windowPosition': instance.windowPosition,
      'launchTimes': instance.launchTimes,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode],
      'preferredRegions':
          instance.preferredRegions?.map((e) => _$RegionEnumMap[e]).toList(),
      'autoUpdateData': instance.autoUpdateData,
      'autoUpdateApp': instance.autoUpdateApp,
      'autoRotate': instance.autoRotate,
      'autoResetFilter': instance.autoResetFilter,
      'useProxy': instance.useProxy,
      'favoritePreferred': _$FavoriteStateEnumMap[instance.favoritePreferred],
      'priorityTags':
          instance.priorityTags.map((k, e) => MapEntry(k.toString(), e)),
      'galleries': instance.galleries,
      'display': instance.display.toJson(),
      'carousel': instance.carousel.toJson(),
      'tips': instance.tips.toJson(),
      'useAndroidExternal': instance.useAndroidExternal,
      'svtFilterData': instance.svtFilterData.toJson(),
      'craftFilterData': instance.craftFilterData.toJson(),
      'language': instance.language,
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$RegionEnumMap = {
  Region.jp: 'jp',
  Region.cn: 'cn',
  Region.tw: 'tw',
  Region.na: 'na',
  Region.kr: 'kr',
};

const _$FavoriteStateEnumMap = {
  FavoriteState.all: 'all',
  FavoriteState.owned: 'owned',
  FavoriteState.planned: 'planned',
  FavoriteState.other: 'other',
};

DisplaySettings _$DisplaySettingsFromJson(Map json) => $checkedCreate(
      'DisplaySettings',
      json,
      ($checkedConvert) {
        final val = DisplaySettings(
          showAccountAtHome:
              $checkedConvert('showAccountAtHome', (v) => v as bool? ?? false),
          svtPlanInputMode: $checkedConvert(
              'svtPlanInputMode',
              (v) =>
                  $enumDecodeNullable(_$SvtPlanInputModeEnumMap, v) ??
                  SvtPlanInputMode.dropdown),
          itemDetailViewType: $checkedConvert(
              'itemDetailViewType',
              (v) =>
                  $enumDecodeNullable(_$ItemDetailViewTypeEnumMap, v) ??
                  ItemDetailViewType.separated),
          itemDetailSvtSort: $checkedConvert(
              'itemDetailSvtSort',
              (v) =>
                  $enumDecodeNullable(_$ItemDetailSvtSortEnumMap, v) ??
                  ItemDetailSvtSort.collectionNo),
          itemQuestsSortByAp:
              $checkedConvert('itemQuestsSortByAp', (v) => v as bool? ?? true),
          classFilterStyle: $checkedConvert(
              'classFilterStyle',
              (v) =>
                  $enumDecodeNullable(_$SvtListClassFilterStyleEnumMap, v) ??
                  SvtListClassFilterStyle.auto),
          onlyAppendSkillTwo:
              $checkedConvert('onlyAppendSkillTwo', (v) => v as bool? ?? true),
          planPageFullScreen:
              $checkedConvert('planPageFullScreen', (v) => v as bool? ?? false),
          eventsShowOutdated:
              $checkedConvert('eventsShowOutdated', (v) => v as bool? ?? false),
          eventsReversed:
              $checkedConvert('eventsReversed', (v) => v as bool? ?? true),
          sortedSvtTabs: $checkedConvert(
              'sortedSvtTabs',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => $enumDecodeNullable(_$SvtTabEnumMap, e))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$DisplaySettingsToJson(DisplaySettings instance) =>
    <String, dynamic>{
      'showAccountAtHome': instance.showAccountAtHome,
      'svtPlanInputMode': _$SvtPlanInputModeEnumMap[instance.svtPlanInputMode],
      'itemDetailViewType':
          _$ItemDetailViewTypeEnumMap[instance.itemDetailViewType],
      'itemDetailSvtSort':
          _$ItemDetailSvtSortEnumMap[instance.itemDetailSvtSort],
      'itemQuestsSortByAp': instance.itemQuestsSortByAp,
      'classFilterStyle':
          _$SvtListClassFilterStyleEnumMap[instance.classFilterStyle],
      'onlyAppendSkillTwo': instance.onlyAppendSkillTwo,
      'planPageFullScreen': instance.planPageFullScreen,
      'eventsShowOutdated': instance.eventsShowOutdated,
      'eventsReversed': instance.eventsReversed,
      'sortedSvtTabs':
          instance.sortedSvtTabs.map((e) => _$SvtTabEnumMap[e]).toList(),
    };

const _$SvtPlanInputModeEnumMap = {
  SvtPlanInputMode.dropdown: 'dropdown',
  SvtPlanInputMode.slider: 'slider',
  SvtPlanInputMode.input: 'input',
};

const _$ItemDetailViewTypeEnumMap = {
  ItemDetailViewType.separated: 'separated',
  ItemDetailViewType.grid: 'grid',
  ItemDetailViewType.list: 'list',
};

const _$ItemDetailSvtSortEnumMap = {
  ItemDetailSvtSort.collectionNo: 'collectionNo',
  ItemDetailSvtSort.clsName: 'clsName',
  ItemDetailSvtSort.rarity: 'rarity',
};

const _$SvtListClassFilterStyleEnumMap = {
  SvtListClassFilterStyle.auto: 'auto',
  SvtListClassFilterStyle.singleRow: 'singleRow',
  SvtListClassFilterStyle.singleRowExpanded: 'singleRowExpanded',
  SvtListClassFilterStyle.twoRow: 'twoRow',
  SvtListClassFilterStyle.doNotShow: 'doNotShow',
};

const _$SvtTabEnumMap = {
  SvtTab.plan: 'plan',
  SvtTab.skill: 'skill',
  SvtTab.np: 'np',
  SvtTab.info: 'info',
  SvtTab.illustration: 'illustration',
  SvtTab.relatedCards: 'relatedCards',
  SvtTab.summon: 'summon',
  SvtTab.voice: 'voice',
  SvtTab.quest: 'quest',
};

CarouselSetting _$CarouselSettingFromJson(Map json) => $checkedCreate(
      'CarouselSetting',
      json,
      ($checkedConvert) {
        final val = CarouselSetting(
          updateTime: $checkedConvert('updateTime', (v) => v as int?),
          items: $checkedConvert(
              'items',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => CarouselItem.fromJson(
                      Map<String, dynamic>.from(e as Map)))
                  .toList()),
          enabled: $checkedConvert('enabled', (v) => v as bool? ?? true),
          enableMooncell:
              $checkedConvert('enableMooncell', (v) => v as bool? ?? true),
          enableJp: $checkedConvert('enableJp', (v) => v as bool? ?? true),
          enableUs: $checkedConvert('enableUs', (v) => v as bool? ?? true),
        );
        return val;
      },
    );

Map<String, dynamic> _$CarouselSettingToJson(CarouselSetting instance) =>
    <String, dynamic>{
      'updateTime': instance.updateTime,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'enabled': instance.enabled,
      'enableMooncell': instance.enableMooncell,
      'enableJp': instance.enableJp,
      'enableUs': instance.enableUs,
    };

CarouselItem _$CarouselItemFromJson(Map json) => $checkedCreate(
      'CarouselItem',
      json,
      ($checkedConvert) {
        final val = CarouselItem(
          image: $checkedConvert('image', (v) => v as String?),
          text: $checkedConvert('text', (v) => v as String?),
          link: $checkedConvert('link', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$CarouselItemToJson(CarouselItem instance) =>
    <String, dynamic>{
      'image': instance.image,
      'text': instance.text,
      'link': instance.link,
    };

TipsSetting _$TipsSettingFromJson(Map json) => $checkedCreate(
      'TipsSetting',
      json,
      ($checkedConvert) {
        final val = TipsSetting(
          starter: $checkedConvert('starter', (v) => v as bool? ?? true),
          servantList: $checkedConvert('servantList', (v) => v as int? ?? 2),
          servantDetail:
              $checkedConvert('servantDetail', (v) => v as int? ?? 2),
        );
        return val;
      },
    );

Map<String, dynamic> _$TipsSettingToJson(TipsSetting instance) =>
    <String, dynamic>{
      'starter': instance.starter,
      'servantList': instance.servantList,
      'servantDetail': instance.servantDetail,
    };
