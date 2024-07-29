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
              $checkedConvert('windowPosition', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
          showSystemTray: $checkedConvert('showSystemTray', (v) => v as bool? ?? false),
          launchTimes: $checkedConvert('launchTimes', (v) => (v as num?)?.toInt() ?? 0),
          lastLaunchTime: $checkedConvert('lastLaunchTime', (v) => (v as num?)?.toInt() ?? 0),
          lastBackup: $checkedConvert('lastBackup', (v) => (v as num?)?.toInt() ?? 0),
          themeMode:
              $checkedConvert('themeMode', (v) => $enumDecodeNullable(_$ThemeModeEnumMap, v) ?? ThemeMode.system),
          useMaterial3: $checkedConvert('useMaterial3', (v) => v as bool? ?? false),
          colorSeed: $checkedConvert('colorSeed', (v) => $enumDecodeNullable(_$ColorSeedEnumMap, v)),
          enableMouseDrag: $checkedConvert('enableMouseDrag', (v) => v as bool? ?? true),
          globalSelection: $checkedConvert('globalSelection', (v) => v as bool? ?? false),
          language: $checkedConvert('language', (v) => v as String?),
          preferredRegions: $checkedConvert('preferredRegions',
              (v) => (v as List<dynamic>?)?.map((e) => const RegionConverter().fromJson(e as String)).toList()),
          autoUpdateData: $checkedConvert('autoUpdateData', (v) => v as bool? ?? true),
          updateDataBeforeStart: $checkedConvert('updateDataBeforeStart', (v) => v as bool? ?? false),
          checkDataHash: $checkedConvert('checkDataHash', (v) => v as bool? ?? true),
          proxyServer: $checkedConvert('proxyServer', (v) => v as bool? ?? false),
          proxy: $checkedConvert(
              'proxy', (v) => v == null ? null : ProxySettings.fromJson(Map<String, dynamic>.from(v as Map))),
          autoUpdateApp: $checkedConvert('autoUpdateApp', (v) => v as bool? ?? true),
          autoRotate: $checkedConvert('autoRotate', (v) => v as bool? ?? true),
          enableEdgeSwipePopGesture: $checkedConvert('enableEdgeSwipePopGesture', (v) => v as bool? ?? true),
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
          eventItemCalc: $checkedConvert(
              'eventItemCalc',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(
                        int.parse(k as String), EventItemCalcParams.fromJson(Map<String, dynamic>.from(e as Map))),
                  )),
          spoilerRegion: $checkedConvert(
              'spoilerRegion', (v) => v == null ? Region.jp : const RegionConverter().fromJson(v as String)),
          autoResetFilter: $checkedConvert('autoResetFilter', (v) => v as bool? ?? true),
          hideUnreleasedCard: $checkedConvert('hideUnreleasedCard', (v) => v as bool? ?? false),
          hideUnreleasedEnemyCollection: $checkedConvert('hideUnreleasedEnemyCollection', (v) => v as bool? ?? false),
          filters: $checkedConvert(
              'filters', (v) => v == null ? null : LocalDataFilters.fromJson(Map<String, dynamic>.from(v as Map))),
          autologins: $checkedConvert(
              'autologins',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => AutoLoginData.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          remoteConfig: $checkedConvert(
              'remoteConfig', (v) => v == null ? null : RemoteConfig.fromJson(Map<String, dynamic>.from(v as Map))),
          masterMissionOptions: $checkedConvert('masterMissionOptions',
              (v) => v == null ? null : MasterMissionOptions.fromJson(Map<String, dynamic>.from(v as Map))),
          bookmarks: $checkedConvert(
              'bookmarks', (v) => v == null ? null : BookmarkHistory.fromJson(Map<String, dynamic>.from(v as Map))),
          misc: $checkedConvert(
              'misc', (v) => v == null ? null : _MiscSettings.fromJson(Map<String, dynamic>.from(v as Map))),
          secrets: $checkedConvert(
              'secrets', (v) => v == null ? null : _SecretsData.fromJson(Map<String, dynamic>.from(v as Map))),
        );
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
      'lastLaunchTime': instance.lastLaunchTime,
      'lastBackup': instance.lastBackup,
      'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
      'useMaterial3': instance.useMaterial3,
      'colorSeed': _$ColorSeedEnumMap[instance.colorSeed],
      'enableMouseDrag': instance.enableMouseDrag,
      'globalSelection': instance.globalSelection,
      'preferredRegions': instance.preferredRegions?.map(const RegionConverter().toJson).toList(),
      'autoUpdateData': instance.autoUpdateData,
      'updateDataBeforeStart': instance.updateDataBeforeStart,
      'checkDataHash': instance.checkDataHash,
      'autoUpdateApp': instance.autoUpdateApp,
      'proxyServer': instance.proxyServer,
      'proxy': instance.proxy.toJson(),
      'autoRotate': instance.autoRotate,
      'enableEdgeSwipePopGesture': instance.enableEdgeSwipePopGesture,
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
      'eventItemCalc': instance.eventItemCalc.map((k, e) => MapEntry(k.toString(), e.toJson())),
      'spoilerRegion': const RegionConverter().toJson(instance.spoilerRegion),
      'autoResetFilter': instance.autoResetFilter,
      'hideUnreleasedCard': instance.hideUnreleasedCard,
      'hideUnreleasedEnemyCollection': instance.hideUnreleasedEnemyCollection,
      'filters': instance.filters.toJson(),
      'autologins': instance.autologins.map((e) => e.toJson()).toList(),
      'remoteConfig': instance.remoteConfig.toJson(),
      'masterMissionOptions': instance.masterMissionOptions.toJson(),
      'bookmarks': instance.bookmarks.toJson(),
      'misc': instance.misc.toJson(),
      'secrets': instance.secrets.toJson(),
      'language': instance.language,
      'preferredFavorite': _$FavoriteStateEnumMap[instance.preferredFavorite],
    };

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};

const _$ColorSeedEnumMap = {
  ColorSeed.baseColor: 'baseColor',
  ColorSeed.indigo: 'indigo',
  ColorSeed.blue: 'blue',
  ColorSeed.teal: 'teal',
  ColorSeed.green: 'green',
  ColorSeed.yellow: 'yellow',
  ColorSeed.orange: 'orange',
  ColorSeed.deepOrange: 'deepOrange',
  ColorSeed.pink: 'pink',
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

ProxySettings _$ProxySettingsFromJson(Map json) => $checkedCreate(
      'ProxySettings',
      json,
      ($checkedConvert) {
        final val = ProxySettings(
          proxy: $checkedConvert('proxy', (v) => v as bool? ?? false),
          api: $checkedConvert('api', (v) => v as bool?),
          worker: $checkedConvert('worker', (v) => v as bool?),
          data: $checkedConvert('data', (v) => v as bool?),
          atlasApi: $checkedConvert('atlasApi', (v) => v as bool?),
          atlasAsset: $checkedConvert('atlasAsset', (v) => v as bool?),
        );
        return val;
      },
    );

Map<String, dynamic> _$ProxySettingsToJson(ProxySettings instance) => <String, dynamic>{
      'proxy': instance.proxy,
      'api': instance.api,
      'worker': instance.worker,
      'data': instance.data,
      'atlasApi': instance.atlasApi,
      'atlasAsset': instance.atlasAsset,
    };

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
          showOriginalMissionText: $checkedConvert('showOriginalMissionText', (v) => v as bool? ?? false),
          maxWindowWidth: $checkedConvert('maxWindowWidth', (v) => (v as num?)?.toInt()),
          splitMasterRatio: $checkedConvert('splitMasterRatio', (v) => (v as num?)?.toInt()),
          enableSplitView: $checkedConvert('enableSplitView', (v) => v as bool? ?? true),
          ad: $checkedConvert('ad', (v) => v == null ? null : AdSetting.fromJson(Map<String, dynamic>.from(v as Map))),
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
      'showOriginalMissionText': instance.showOriginalMissionText,
      'maxWindowWidth': instance.maxWindowWidth,
      'splitMasterRatio': instance.splitMasterRatio,
      'enableSplitView': instance.enableSplitView,
      'ad': instance.ad.toJson(),
    };

const _$SvtPlanInputModeEnumMap = {
  SvtPlanInputMode.dropdown: 'dropdown',
  SvtPlanInputMode.slider: 'slider',
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
  SvtTab.spDmg: 'spDmg',
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

AdSetting _$AdSettingFromJson(Map json) => $checkedCreate(
      'AdSetting',
      json,
      ($checkedConvert) {
        final val = AdSetting(
          enabled: $checkedConvert('enabled', (v) => v as bool?),
          banner: $checkedConvert('banner', (v) => v as bool?),
          appOpen: $checkedConvert('appOpen', (v) => v as bool?),
          lastAppOpen: $checkedConvert('lastAppOpen', (v) => (v as num?)?.toInt() ?? 0),
        );
        return val;
      },
    );

Map<String, dynamic> _$AdSettingToJson(AdSetting instance) => <String, dynamic>{
      'enabled': instance.enabled,
      'banner': instance.banner,
      'appOpen': instance.appOpen,
      'lastAppOpen': instance.lastAppOpen,
    };

CarouselSetting _$CarouselSettingFromJson(Map json) => $checkedCreate(
      'CarouselSetting',
      json,
      ($checkedConvert) {
        final val = CarouselSetting(
          ver: $checkedConvert('ver', (v) => (v as num?)?.toInt()),
          updateTime: $checkedConvert('updateTime', (v) => (v as num?)?.toInt()),
          items: $checkedConvert(
              'items',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => CarouselItem.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
          enabled: $checkedConvert('enabled', (v) => v as bool? ?? true),
          enableChaldea: $checkedConvert('enableChaldea', (v) => v as bool? ?? true),
          enableMooncell: $checkedConvert('enableMooncell', (v) => v as bool? ?? false),
          enableJP: $checkedConvert('enableJP', (v) => v as bool? ?? false),
          enableCN: $checkedConvert('enableCN', (v) => v as bool? ?? false),
          enableNA: $checkedConvert('enableNA', (v) => v as bool? ?? false),
          enableTW: $checkedConvert('enableTW', (v) => v as bool? ?? false),
          enableKR: $checkedConvert('enableKR', (v) => v as bool? ?? false),
        );
        return val;
      },
    );

Map<String, dynamic> _$CarouselSettingToJson(CarouselSetting instance) => <String, dynamic>{
      'ver': instance.ver,
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
          type: $checkedConvert('type', (v) => (v as num?)?.toInt() ?? 0),
          priority: $checkedConvert('priority', (v) => (v as num?)?.toInt() ?? CarouselItem.defaultPriority),
          startTime: $checkedConvert('startTime', (v) => v == null ? null : DateTime.parse(v as String)),
          endTime: $checkedConvert('endTime', (v) => v == null ? null : DateTime.parse(v as String)),
          title: $checkedConvert('title', (v) => v as String?),
          title2: $checkedConvert('title2', (v) => v as String?),
          content: $checkedConvert('content', (v) => v as String?),
          content2: $checkedConvert('content2', (v) => v as String?),
          image: $checkedConvert('image', (v) => v as String?),
          image2: $checkedConvert('image2', (v) => v as String?),
          link: $checkedConvert('link', (v) => v as String?),
          link2: $checkedConvert('link2', (v) => v as String?),
          md: $checkedConvert('md', (v) => v as bool? ?? false),
          verMin: $checkedConvert(
              'verMin', (v) => _$JsonConverterFromJson<String, AppVersion>(v, const AppVersionConverter().fromJson)),
          verMax: $checkedConvert(
              'verMax', (v) => _$JsonConverterFromJson<String, AppVersion>(v, const AppVersionConverter().fromJson)),
          eventIds: $checkedConvert('eventIds', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
          warIds: $checkedConvert('warIds', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
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
      'title2': instance.title2,
      'content': instance.content,
      'content2': instance.content2,
      'image': instance.image,
      'image2': instance.image2,
      'link': instance.link,
      'link2': instance.link2,
      'md': instance.md,
      'verMin': _$JsonConverterToJson<String, AppVersion>(instance.verMin, const AppVersionConverter().toJson),
      'verMax': _$JsonConverterToJson<String, AppVersion>(instance.verMax, const AppVersionConverter().toJson),
      'eventIds': instance.eventIds,
      'warIds': instance.warIds,
      'summonIds': instance.summonIds,
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
          servantList: $checkedConvert('servantList', (v) => (v as num?)?.toInt() ?? 2),
          servantDetail: $checkedConvert('servantDetail', (v) => (v as num?)?.toInt() ?? 2),
        );
        return val;
      },
    );

Map<String, dynamic> _$TipsSettingToJson(TipsSetting instance) => <String, dynamic>{
      'starter': instance.starter,
      'servantList': instance.servantList,
      'servantDetail': instance.servantDetail,
    };

EventItemCalcParams _$EventItemCalcParamsFromJson(Map json) => $checkedCreate(
      'EventItemCalcParams',
      json,
      ($checkedConvert) {
        final val = EventItemCalcParams(
          itemCounts: $checkedConvert(
              'itemCounts',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), (e as num).toInt()),
                  )),
          bonusPlans: $checkedConvert(
              'bonusPlans',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => QuestBonusPlan.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$EventItemCalcParamsToJson(EventItemCalcParams instance) => <String, dynamic>{
      'itemCounts': instance.itemCounts.map((k, e) => MapEntry(k.toString(), e)),
      'bonusPlans': instance.bonusPlans.map((e) => e.toJson()).toList(),
    };

QuestBonusPlan _$QuestBonusPlanFromJson(Map json) => $checkedCreate(
      'QuestBonusPlan',
      json,
      ($checkedConvert) {
        final val = QuestBonusPlan(
          enabled: $checkedConvert('enabled', (v) => v as bool? ?? true),
          questId: $checkedConvert('questId', (v) => (v as num?)?.toInt() ?? 0),
          index: $checkedConvert('index', (v) => (v as num?)?.toInt() ?? 0),
          name: $checkedConvert('name', (v) => v as String? ?? ""),
          bonus: $checkedConvert(
              'bonus',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), (e as num).toInt()),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$QuestBonusPlanToJson(QuestBonusPlan instance) => <String, dynamic>{
      'enabled': instance.enabled,
      'questId': instance.questId,
      'index': instance.index,
      'name': instance.name,
      'bonus': instance.bonus.map((k, e) => MapEntry(k.toString(), e)),
    };

MasterMissionOptions _$MasterMissionOptionsFromJson(Map json) => $checkedCreate(
      'MasterMissionOptions',
      json,
      ($checkedConvert) {
        final val = MasterMissionOptions(
          blacklist: $checkedConvert('blacklist', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
          excludeRandomEnemyQuests: $checkedConvert('excludeRandomEnemyQuests', (v) => v as bool? ?? false),
        );
        return val;
      },
    );

Map<String, dynamic> _$MasterMissionOptionsToJson(MasterMissionOptions instance) => <String, dynamic>{
      'blacklist': instance.blacklist.toList(),
      'excludeRandomEnemyQuests': instance.excludeRandomEnemyQuests,
    };

_MiscSettings _$MiscSettingsFromJson(Map json) => $checkedCreate(
      '_MiscSettings',
      json,
      ($checkedConvert) {
        final val = _MiscSettings(
          nonSvtCharaFigureIds: $checkedConvert(
              'nonSvtCharaFigureIds', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
          markedCharaFigureSvtIds: $checkedConvert(
              'markedCharaFigureSvtIds',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(int.parse(k as String), (e as num).toInt()),
                  )),
          nonSvtCharaImageIds:
              $checkedConvert('nonSvtCharaImageIds', (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet()),
          markedCharaImageSvtIds: $checkedConvert(
              'markedCharaImageSvtIds',
              (v) => (v as Map?)?.map(
                    (k, e) => MapEntry(k as String, (e as num).toInt()),
                  )),
        );
        return val;
      },
    );

Map<String, dynamic> _$MiscSettingsToJson(_MiscSettings instance) => <String, dynamic>{
      'nonSvtCharaFigureIds': instance.nonSvtCharaFigureIds.toList(),
      'markedCharaFigureSvtIds': instance.markedCharaFigureSvtIds.map((k, e) => MapEntry(k.toString(), e)),
      'nonSvtCharaImageIds': instance.nonSvtCharaImageIds.toList(),
      'markedCharaImageSvtIds': instance.markedCharaImageSvtIds,
    };

_SecretsData _$SecretsDataFromJson(Map json) => $checkedCreate(
      '_SecretsData',
      json,
      ($checkedConvert) {
        final val = _SecretsData(
          user: $checkedConvert(
              'user', (v) => v == null ? null : ChaldeaUser.fromJson(Map<String, dynamic>.from(v as Map))),
          explorerAuth: $checkedConvert('explorerAuth', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$SecretsDataToJson(_SecretsData instance) => <String, dynamic>{
      'user': instance.user?.toJson(),
      'explorerAuth': instance.explorerAuth,
    };

BookmarkHistory _$BookmarkHistoryFromJson(Map json) => $checkedCreate(
      'BookmarkHistory',
      json,
      ($checkedConvert) {
        final val = BookmarkHistory(
          bookmarks: $checkedConvert(
              'bookmarks',
              (v) => (v as List<dynamic>?)
                  ?.map((e) => BookmarkEntry.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()),
        );
        return val;
      },
    );

Map<String, dynamic> _$BookmarkHistoryToJson(BookmarkHistory instance) => <String, dynamic>{
      'bookmarks': instance.bookmarks.map((e) => e.toJson()).toList(),
    };

BookmarkEntry _$BookmarkEntryFromJson(Map json) => $checkedCreate(
      'BookmarkEntry',
      json,
      ($checkedConvert) {
        final val = BookmarkEntry(
          name: $checkedConvert('name', (v) => v as String?),
          url: $checkedConvert('url', (v) => v as String),
          createdAt: $checkedConvert('createdAt', (v) => (v as num?)?.toInt()),
        );
        return val;
      },
    );

Map<String, dynamic> _$BookmarkEntryToJson(BookmarkEntry instance) => <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'createdAt': instance.createdAt,
    };
