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
          showDebugFab: $checkedConvert('showDebugFab', (v) => v as bool? ?? false),
          alwaysOnTop: $checkedConvert('alwaysOnTop', (v) => v as bool? ?? false),
          windowPosition:
              $checkedConvert('windowPosition', (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          showSystemTray: $checkedConvert('showSystemTray', (v) => v as bool? ?? false),
          launchTimes: $checkedConvert('launchTimes', (v) => v as int? ?? 0),
          lastBackup: $checkedConvert('lastBackup', (v) => v as int? ?? 0),
          themeMode:
              $checkedConvert('themeMode', (v) => $enumDecodeNullable(_$ThemeModeEnumMap, v) ?? ThemeMode.system),
          enableMouseDrag: $checkedConvert('enableMouseDrag', (v) => v as bool? ?? true),
          splitMasterRatio: $checkedConvert('splitMasterRatio', (v) => v as int?),
          globalSelection: $checkedConvert('globalSelection', (v) => v as bool? ?? false),
          language: $checkedConvert('language', (v) => v as String?),
          preferredRegions: $checkedConvert('preferredRegions',
              (v) => (v as List<dynamic>?)?.map((e) => const RegionConverter().fromJson(e as String)).toList()),
          autoUpdateData: $checkedConvert('autoUpdateData', (v) => v as bool? ?? true),
          updateDataBeforeStart: $checkedConvert('updateDataBeforeStart', (v) => v as bool? ?? false),
          checkDataHash: $checkedConvert('checkDataHash', (v) => v as bool? ?? true),
          proxyServer: $checkedConvert('proxyServer', (v) => v as bool? ?? false),
          autoUpdateApp: $checkedConvert('autoUpdateApp', (v) => v as bool? ?? true),
          autoRotate: $checkedConvert('autoRotate', (v) => v as bool? ?? true),
          autoResetFilter: $checkedConvert('autoResetFilter', (v) => v as bool? ?? true),
          hideUnreleasedCard: $checkedConvert('hideUnreleasedCard', (v) => v as bool? ?? false),
          preferredFavorite:
              $checkedConvert('preferredFavorite', (v) => $enumDecodeNullable(_$FavoriteStateEnumMap, v)),
          preferApRate: $checkedConvert('preferApRate', (v) => v as bool? ?? true),
          preferredQuestRegion: $checkedConvert('preferredQuestRegion',
              (v) => _$JsonConverterFromJson<String, Region>(v, const RegionConverter().fromJson)),
          alertUploadUserData: $checkedConvert('alertUploadUserData', (v) => v as bool? ?? false),
          forceOnline: $checkedConvert('forceOnline', (v) => v as bool? ?? false),
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
              'display', (v) => v == null ? null : DisplaySettings.fromJson(Map<String, dynamic>.from(v as Map))),
          carousel: $checkedConvert(
              'carousel', (v) => v == null ? null : CarouselSetting.fromJson(Map<String, dynamic>.from(v as Map))),
          github: $checkedConvert(
              'github', (v) => v == null ? null : GithubSetting.fromJson(Map<String, dynamic>.from(v as Map))),
          tips: $checkedConvert(
              'tips', (v) => v == null ? null : TipsSetting.fromJson(Map<String, dynamic>.from(v as Map))),
          battleSim: $checkedConvert(
              'battleSim', (v) => v == null ? null : BattleSimSetting.fromJson(Map<String, dynamic>.from(v as Map))),
          spoilerRegion: $checkedConvert(
              'spoilerRegion', (v) => v == null ? Region.jp : const RegionConverter().fromJson(v as String)),
          svtFilterData: $checkedConvert(
              'svtFilterData', (v) => v == null ? null : SvtFilterData.fromJson(Map<String, dynamic>.from(v as Map))),
          craftFilterData: $checkedConvert('craftFilterData',
              (v) => v == null ? null : CraftFilterData.fromJson(Map<String, dynamic>.from(v as Map))),
          cmdCodeFilterData: $checkedConvert('cmdCodeFilterData',
              (v) => v == null ? null : CmdCodeFilterData.fromJson(Map<String, dynamic>.from(v as Map))),
          eventFilterData: $checkedConvert('eventFilterData',
              (v) => v == null ? null : EventFilterData.fromJson(Map<String, dynamic>.from(v as Map))),
          summonFilterData: $checkedConvert('summonFilterData',
              (v) => v == null ? null : SummonFilterData.fromJson(Map<String, dynamic>.from(v as Map))),
          scriptReaderFilterData: $checkedConvert('scriptReaderFilterData',
              (v) => v == null ? null : ScriptReaderFilterData.fromJson(Map<String, dynamic>.from(v as Map))),
          autologins: $checkedConvert(
              'autologins',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => AutoLoginData.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
        );
        $checkedConvert('useAndroidExternal', (v) => val.useAndroidExternal = v as bool);
        return val;
      },
    );

Map<String, dynamic> _$LocalSettingsToJson(LocalSettings instance) => <String, dynamic>{
      'beta': instance.beta,
      'showDebugFab': instance.showDebugFab,
      'alwaysOnTop': instance.alwaysOnTop,
      'windowPosition': instance.windowPosition,
      'showSystemTray': instance.showSystemTray,
      'launchTimes': instance.launchTimes,
      'lastBackup': instance.lastBackup,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'enableMouseDrag': instance.enableMouseDrag,
      'splitMasterRatio': instance.splitMasterRatio,
      'globalSelection': instance.globalSelection,
      'preferredRegions': instance.preferredRegions?.map(const RegionConverter().toJson).toList(),
      'autoUpdateData': instance.autoUpdateData,
      'updateDataBeforeStart': instance.updateDataBeforeStart,
      'checkDataHash': instance.checkDataHash,
      'autoUpdateApp': instance.autoUpdateApp,
      'proxyServer': instance.proxyServer,
      'autoRotate': instance.autoRotate,
      'autoResetFilter': instance.autoResetFilter,
      'hideUnreleasedCard': instance.hideUnreleasedCard,
      'preferApRate': instance.preferApRate,
      'preferredQuestRegion':
          _$JsonConverterToJson<String, Region>(instance.preferredQuestRegion, const RegionConverter().toJson),
      'alertUploadUserData': instance.alertUploadUserData,
      'forceOnline': instance.forceOnline,
      'priorityTags': instance.priorityTags.map((k, e) => MapEntry(k.toString(), e)),
      'galleries': instance.galleries,
      'display': instance.display.toJson(),
      'carousel': instance.carousel.toJson(),
      'github': instance.github.toJson(),
      'tips': instance.tips.toJson(),
      'battleSim': instance.battleSim.toJson(),
      'useAndroidExternal': instance.useAndroidExternal,
      'spoilerRegion': const RegionConverter().toJson(instance.spoilerRegion),
      'svtFilterData': instance.svtFilterData.toJson(),
      'craftFilterData': instance.craftFilterData.toJson(),
      'cmdCodeFilterData': instance.cmdCodeFilterData.toJson(),
      'eventFilterData': instance.eventFilterData.toJson(),
      'summonFilterData': instance.summonFilterData.toJson(),
      'scriptReaderFilterData': instance.scriptReaderFilterData.toJson(),
      'autologins': instance.autologins.map((e) => e.toJson()).toList(),
      'language': instance.language,
      'preferredFavorite': _$FavoriteStateEnumMap[instance.preferredFavorite],
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$FavoriteStateEnumMap = {
  FavoriteState.all: 'all',
  FavoriteState.owned: 'owned',
  FavoriteState.other: 'other',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

DisplaySettings _$DisplaySettingsFromJson(Map json) => $checkedCreate(
      'DisplaySettings',
      json,
      ($checkedConvert) {
        final val = DisplaySettings(
          showAccountAtHome: $checkedConvert('showAccountAtHome', (v) => v as bool? ?? true),
          showWindowFab: $checkedConvert('showWindowFab', (v) => v as bool? ?? true),
          svtPlanInputMode: $checkedConvert('svtPlanInputMode',
              (v) => $enumDecodeNullable(_$SvtPlanInputModeEnumMap, v) ?? SvtPlanInputMode.dropdown),
          itemDetailViewType: $checkedConvert('itemDetailViewType',
              (v) => $enumDecodeNullable(_$ItemDetailViewTypeEnumMap, v) ?? ItemDetailViewType.separated),
          itemDetailSvtSort: $checkedConvert('itemDetailSvtSort',
              (v) => $enumDecodeNullable(_$ItemDetailSvtSortEnumMap, v) ?? ItemDetailSvtSort.collectionNo),
          itemQuestsSortByAp: $checkedConvert('itemQuestsSortByAp', (v) => v as bool? ?? true),
          autoTurnOnPlanNotReach: $checkedConvert('autoTurnOnPlanNotReach', (v) => v as bool? ?? false),
          classFilterStyle: $checkedConvert('classFilterStyle',
              (v) => $enumDecodeNullable(_$SvtListClassFilterStyleEnumMap, v) ?? SvtListClassFilterStyle.auto),
          onlyAppendSkillTwo: $checkedConvert('onlyAppendSkillTwo', (v) => v as bool? ?? true),
          onlyAppendUnlocked: $checkedConvert('onlyAppendUnlocked', (v) => v as bool? ?? true),
          planPageFullScreen: $checkedConvert('planPageFullScreen', (v) => v as bool? ?? false),
          sortedSvtTabs: $checkedConvert('sortedSvtTabs',
              (v) => (v as List<dynamic>?)?.map((e) => $enumDecodeNullable(_$SvtTabEnumMap, e)).toList()),
          hideSvtPlanDetails: $checkedConvert('hideSvtPlanDetails',
              (v) => (v as List<dynamic>?)?.map((e) => $enumDecodeNullable(_$SvtPlanDetailEnumMap, e)).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$DisplaySettingsToJson(DisplaySettings instance) => <String, dynamic>{
      'showAccountAtHome': instance.showAccountAtHome,
      'showWindowFab': instance.showWindowFab,
      'svtPlanInputMode': _$SvtPlanInputModeEnumMap[instance.svtPlanInputMode]!,
      'itemDetailViewType': _$ItemDetailViewTypeEnumMap[instance.itemDetailViewType]!,
      'itemDetailSvtSort': _$ItemDetailSvtSortEnumMap[instance.itemDetailSvtSort]!,
      'itemQuestsSortByAp': instance.itemQuestsSortByAp,
      'autoTurnOnPlanNotReach': instance.autoTurnOnPlanNotReach,
      'classFilterStyle': _$SvtListClassFilterStyleEnumMap[instance.classFilterStyle]!,
      'onlyAppendSkillTwo': instance.onlyAppendSkillTwo,
      'onlyAppendUnlocked': instance.onlyAppendUnlocked,
      'planPageFullScreen': instance.planPageFullScreen,
      'sortedSvtTabs': instance.sortedSvtTabs.map((e) => _$SvtTabEnumMap[e]!).toList(),
      'hideSvtPlanDetails': instance.hideSvtPlanDetails.map((e) => _$SvtPlanDetailEnumMap[e]!).toList(),
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
  SvtTab.lore: 'lore',
  SvtTab.illustration: 'illustration',
  SvtTab.relatedCards: 'relatedCards',
  SvtTab.summon: 'summon',
  SvtTab.voice: 'voice',
  SvtTab.quest: 'quest',
};

const _$SvtPlanDetailEnumMap = {
  SvtPlanDetail.ascension: 'ascension',
  SvtPlanDetail.activeSkill: 'activeSkill',
  SvtPlanDetail.appendSkill: 'appendSkill',
  SvtPlanDetail.costume: 'costume',
  SvtPlanDetail.coin: 'coin',
  SvtPlanDetail.grail: 'grail',
  SvtPlanDetail.noblePhantasm: 'noblePhantasm',
  SvtPlanDetail.fou4: 'fou4',
  SvtPlanDetail.fou3: 'fou3',
  SvtPlanDetail.bondLimit: 'bondLimit',
  SvtPlanDetail.commandCode: 'commandCode',
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
                  ?.map((e) => CarouselItem.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          enabled: $checkedConvert('enabled', (v) => v as bool? ?? true),
          enableChaldea: $checkedConvert('enableChaldea', (v) => v as bool? ?? true),
          enableMooncell: $checkedConvert('enableMooncell', (v) => v as bool? ?? true),
          enableJP: $checkedConvert('enableJP', (v) => v as bool? ?? true),
          enableCN: $checkedConvert('enableCN', (v) => v as bool? ?? true),
          enableNA: $checkedConvert('enableNA', (v) => v as bool? ?? true),
          enableTW: $checkedConvert('enableTW', (v) => v as bool? ?? true),
          enableKR: $checkedConvert('enableKR', (v) => v as bool? ?? false),
        );
        return val;
      },
    );

Map<String, dynamic> _$CarouselSettingToJson(CarouselSetting instance) => <String, dynamic>{
      'updateTime': instance.updateTime,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'enabled': instance.enabled,
      'enableChaldea': instance.enableChaldea,
      'enableMooncell': instance.enableMooncell,
      'enableJP': instance.enableJP,
      'enableCN': instance.enableCN,
      'enableNA': instance.enableNA,
      'enableTW': instance.enableTW,
      'enableKR': instance.enableKR,
    };

CarouselItem _$CarouselItemFromJson(Map json) => $checkedCreate(
      'CarouselItem',
      json,
      ($checkedConvert) {
        final val = CarouselItem(
          type: $checkedConvert('type', (v) => v as int? ?? 0),
          priority: $checkedConvert('priority', (v) => v as int? ?? 100),
          startTime: $checkedConvert('startTime', (v) => v as String? ?? ""),
          endTime: $checkedConvert('endTime', (v) => v as String? ?? ""),
          title: $checkedConvert('title', (v) => v as String?),
          content: $checkedConvert('content', (v) => v as String?),
          md: $checkedConvert('md', (v) => v as bool? ?? false),
          image: $checkedConvert('image', (v) => v as String?),
          link: $checkedConvert('link', (v) => v as String?),
          verMin: $checkedConvert(
              'verMin', (v) => _$JsonConverterFromJson<String, AppVersion>(v, const AppVersionConverter().fromJson)),
          verMax: $checkedConvert(
              'verMax', (v) => _$JsonConverterFromJson<String, AppVersion>(v, const AppVersionConverter().fromJson)),
          eventIds: $checkedConvert('eventIds', (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          warIds: $checkedConvert('warIds', (v) => (v as List<dynamic>?)?.map((e) => e as int).toList()),
          summonIds: $checkedConvert('summonIds', (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$CarouselItemToJson(CarouselItem instance) => <String, dynamic>{
      'type': instance.type,
      'priority': instance.priority,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'title': instance.title,
      'content': instance.content,
      'md': instance.md,
      'image': instance.image,
      'link': instance.link,
      'verMin': _$JsonConverterToJson<String, AppVersion>(instance.verMin, const AppVersionConverter().toJson),
      'verMax': _$JsonConverterToJson<String, AppVersion>(instance.verMax, const AppVersionConverter().toJson),
      'eventIds': instance.eventIds,
      'warIds': instance.warIds,
      'summonIds': instance.summonIds,
    };

RemoteConfig _$RemoteConfigFromJson(Map json) => $checkedCreate(
      'RemoteConfig',
      json,
      ($checkedConvert) {
        final val = RemoteConfig(
          blockedCarousels: $checkedConvert(
              'blockedCarousels', (v) => (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const []),
          blockedErrors: $checkedConvert(
              'blockedErrors', (v) => (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const []),
        );
        return val;
      },
    );

Map<String, dynamic> _$RemoteConfigToJson(RemoteConfig instance) => <String, dynamic>{
      'blockedCarousels': instance.blockedCarousels,
      'blockedErrors': instance.blockedErrors,
    };

GithubSetting _$GithubSettingFromJson(Map json) => $checkedCreate(
      'GithubSetting',
      json,
      ($checkedConvert) {
        final val = GithubSetting(
          owner: $checkedConvert('owner', (v) => v as String? ?? ''),
          repo: $checkedConvert('repo', (v) => v as String? ?? ''),
          path: $checkedConvert('path', (v) => v as String? ?? ''),
          token: $checkedConvert('token', (v) => v == null ? '' : GithubSetting._readToken(v as String)),
          branch: $checkedConvert('branch', (v) => v as String? ?? ''),
          sha: $checkedConvert('sha', (v) => v as String?),
          indent: $checkedConvert('indent', (v) => v as bool? ?? false),
        );
        return val;
      },
    );

Map<String, dynamic> _$GithubSettingToJson(GithubSetting instance) => <String, dynamic>{
      'owner': instance.owner,
      'repo': instance.repo,
      'path': instance.path,
      'token': GithubSetting._writeToken(instance.token),
      'branch': instance.branch,
      'sha': instance.sha,
      'indent': instance.indent,
    };

TipsSetting _$TipsSettingFromJson(Map json) => $checkedCreate(
      'TipsSetting',
      json,
      ($checkedConvert) {
        final val = TipsSetting(
          starter: $checkedConvert('starter', (v) => v as bool? ?? true),
          servantList: $checkedConvert('servantList', (v) => v as int? ?? 2),
          servantDetail: $checkedConvert('servantDetail', (v) => v as int? ?? 2),
        );
        return val;
      },
    );

Map<String, dynamic> _$TipsSettingToJson(TipsSetting instance) => <String, dynamic>{
      'starter': instance.starter,
      'servantList': instance.servantList,
      'servantDetail': instance.servantDetail,
    };

BattleSimSetting _$BattleSimSettingFromJson(Map json) => $checkedCreate(
      'BattleSimSetting',
      json,
      ($checkedConvert) {
        final val = BattleSimSetting(
          previousQuestPhase: $checkedConvert('previousQuestPhase', (v) => v as String?),
          preferPlayerData: $checkedConvert('preferPlayerData', (v) => v as bool? ?? true),
        );
        return val;
      },
    );

Map<String, dynamic> _$BattleSimSettingToJson(BattleSimSetting instance) => <String, dynamic>{
      'previousQuestPhase': instance.previousQuestPhase,
      'preferPlayerData': instance.preferPlayerData,
    };
