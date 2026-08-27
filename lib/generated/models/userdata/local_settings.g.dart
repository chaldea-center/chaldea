// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/userdata/local_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalSettings _$LocalSettingsFromJson(Map json) => $checkedCreate('LocalSettings', json, ($checkedConvert) {
  final val = LocalSettings(
    formatVersion: $checkedConvert('formatVersion', (v) => (v as num?)?.toInt() ?? 2),
    language: $checkedConvert('language', (v) => v as String?),
    appearance: $checkedConvert(
      'appearance',
      (v) => v == null ? null : AppearanceSettings.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    platform: $checkedConvert(
      'platform',
      (v) => v == null ? null : PlatformSettings.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    network: $checkedConvert(
      'network',
      (v) => v == null ? null : NetworkSettings.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    locale: $checkedConvert(
      'locale',
      (v) => v == null ? null : LocaleSettings.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    gameplay: $checkedConvert(
      'gameplay',
      (v) => v == null ? null : GameplaySettings.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    display: $checkedConvert(
      'display',
      (v) => v == null ? null : DisplaySettings.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    carousel: $checkedConvert(
      'carousel',
      (v) => v == null ? null : CarouselSetting.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    github: $checkedConvert(
      'github',
      (v) => v == null ? null : GithubSetting.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    tips: $checkedConvert('tips', (v) => v == null ? null : TipsSetting.fromJson(Map<String, dynamic>.from(v as Map))),
    battleSim: $checkedConvert(
      'battleSim',
      (v) => v == null ? null : BattleSimSetting.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    filters: $checkedConvert(
      'filters',
      (v) => v == null ? null : LocalDataFilters.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    fakerSettings: $checkedConvert(
      'fakerSettings',
      (v) => v == null ? null : FakerSettings.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    remoteConfig: $checkedConvert(
      'remoteConfig',
      (v) => v == null ? null : RemoteConfig.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    bookmarks: $checkedConvert(
      'bookmarks',
      (v) => v == null ? null : BookmarkHistory.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    misc: $checkedConvert(
      'misc',
      (v) => v == null ? null : _MiscSettings.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
    secrets: $checkedConvert(
      'secrets',
      (v) => v == null ? null : _SecretsData.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
  );
  return val;
});

Map<String, dynamic> _$LocalSettingsToJson(LocalSettings instance) => <String, dynamic>{
  'formatVersion': instance.formatVersion,
  'appearance': instance.appearance.toJson(),
  'platform': instance.platform.toJson(),
  'network': instance.network.toJson(),
  'locale': instance.locale.toJson(),
  'gameplay': instance.gameplay.toJson(),
  'display': instance.display.toJson(),
  'carousel': instance.carousel.toJson(),
  'github': instance.github.toJson(),
  'tips': instance.tips.toJson(),
  'battleSim': instance.battleSim.toJson(),
  'filters': instance.filters.toJson(),
  'fakerSettings': instance.fakerSettings.toJson(),
  'remoteConfig': instance.remoteConfig.toJson(),
  'bookmarks': instance.bookmarks.toJson(),
  'misc': instance.misc.toJson(),
  'secrets': instance.secrets.toJson(),
  'language': instance.language,
};

AppearanceSettings _$AppearanceSettingsFromJson(Map json) => $checkedCreate('AppearanceSettings', json, (
  $checkedConvert,
) {
  final val = AppearanceSettings(
    themeMode: $checkedConvert('themeMode', (v) => $enumDecodeNullable(_$ThemeModeEnumMap, v) ?? ThemeMode.system),
    useMaterial3: $checkedConvert('useMaterial3', (v) => v as bool? ?? false),
    flexScheme: $checkedConvert('flexScheme', (v) => $enumDecodeNullable(_$FlexSchemeEnumMap, v)),
    flexSurfaceMode: $checkedConvert('flexSurfaceMode', (v) => $enumDecodeNullable(_$FlexSurfaceModeEnumMap, v)),
    flexBlendLevel: $checkedConvert('flexBlendLevel', (v) => (v as num?)?.toInt()),
    flexSchemeVariant: $checkedConvert('flexSchemeVariant', (v) => $enumDecodeNullable(_$FlexSchemeVariantEnumMap, v)),
    colorSeedInt: $checkedConvert('colorSeedInt', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$AppearanceSettingsToJson(AppearanceSettings instance) => <String, dynamic>{
  'themeMode': _$ThemeModeEnumMap[instance.themeMode]!,
  'useMaterial3': instance.useMaterial3,
  'flexScheme': _$FlexSchemeEnumMap[instance.flexScheme],
  'flexSurfaceMode': _$FlexSurfaceModeEnumMap[instance.flexSurfaceMode],
  'flexBlendLevel': instance.flexBlendLevel,
  'flexSchemeVariant': _$FlexSchemeVariantEnumMap[instance.flexSchemeVariant],
  'colorSeedInt': instance.colorSeedInt,
};

const _$ThemeModeEnumMap = {ThemeMode.system: 'system', ThemeMode.light: 'light', ThemeMode.dark: 'dark'};

const _$FlexSchemeEnumMap = {
  FlexScheme.material: 'material',
  FlexScheme.materialHc: 'materialHc',
  FlexScheme.blue: 'blue',
  FlexScheme.indigo: 'indigo',
  FlexScheme.hippieBlue: 'hippieBlue',
  FlexScheme.aquaBlue: 'aquaBlue',
  FlexScheme.brandBlue: 'brandBlue',
  FlexScheme.deepBlue: 'deepBlue',
  FlexScheme.sakura: 'sakura',
  FlexScheme.mandyRed: 'mandyRed',
  FlexScheme.red: 'red',
  FlexScheme.redWine: 'redWine',
  FlexScheme.purpleBrown: 'purpleBrown',
  FlexScheme.green: 'green',
  FlexScheme.money: 'money',
  FlexScheme.jungle: 'jungle',
  FlexScheme.greyLaw: 'greyLaw',
  FlexScheme.wasabi: 'wasabi',
  FlexScheme.gold: 'gold',
  FlexScheme.mango: 'mango',
  FlexScheme.amber: 'amber',
  FlexScheme.vesuviusBurn: 'vesuviusBurn',
  FlexScheme.deepPurple: 'deepPurple',
  FlexScheme.ebonyClay: 'ebonyClay',
  FlexScheme.barossa: 'barossa',
  FlexScheme.shark: 'shark',
  FlexScheme.bigStone: 'bigStone',
  FlexScheme.damask: 'damask',
  FlexScheme.bahamaBlue: 'bahamaBlue',
  FlexScheme.mallardGreen: 'mallardGreen',
  FlexScheme.espresso: 'espresso',
  FlexScheme.outerSpace: 'outerSpace',
  FlexScheme.blueWhale: 'blueWhale',
  FlexScheme.sanJuanBlue: 'sanJuanBlue',
  FlexScheme.rosewood: 'rosewood',
  FlexScheme.blumineBlue: 'blumineBlue',
  FlexScheme.flutterDash: 'flutterDash',
  FlexScheme.materialBaseline: 'materialBaseline',
  FlexScheme.verdunHemlock: 'verdunHemlock',
  FlexScheme.dellGenoa: 'dellGenoa',
  FlexScheme.redM3: 'redM3',
  FlexScheme.pinkM3: 'pinkM3',
  FlexScheme.purpleM3: 'purpleM3',
  FlexScheme.indigoM3: 'indigoM3',
  FlexScheme.blueM3: 'blueM3',
  FlexScheme.cyanM3: 'cyanM3',
  FlexScheme.tealM3: 'tealM3',
  FlexScheme.greenM3: 'greenM3',
  FlexScheme.limeM3: 'limeM3',
  FlexScheme.yellowM3: 'yellowM3',
  FlexScheme.orangeM3: 'orangeM3',
  FlexScheme.deepOrangeM3: 'deepOrangeM3',
  FlexScheme.blackWhite: 'blackWhite',
  FlexScheme.greys: 'greys',
  FlexScheme.sepia: 'sepia',
  FlexScheme.shadBlue: 'shadBlue',
  FlexScheme.shadGray: 'shadGray',
  FlexScheme.shadGreen: 'shadGreen',
  FlexScheme.shadNeutral: 'shadNeutral',
  FlexScheme.shadOrange: 'shadOrange',
  FlexScheme.shadRed: 'shadRed',
  FlexScheme.shadRose: 'shadRose',
  FlexScheme.shadSlate: 'shadSlate',
  FlexScheme.shadStone: 'shadStone',
  FlexScheme.shadViolet: 'shadViolet',
  FlexScheme.shadYellow: 'shadYellow',
  FlexScheme.shadZinc: 'shadZinc',
  FlexScheme.custom: 'custom',
};

const _$FlexSurfaceModeEnumMap = {
  FlexSurfaceMode.level: 'level',
  FlexSurfaceMode.highBackgroundLowScaffold: 'highBackgroundLowScaffold',
  FlexSurfaceMode.highSurfaceLowScaffold: 'highSurfaceLowScaffold',
  FlexSurfaceMode.highScaffoldLowSurface: 'highScaffoldLowSurface',
  FlexSurfaceMode.highScaffoldLevelSurface: 'highScaffoldLevelSurface',
  FlexSurfaceMode.levelSurfacesLowScaffold: 'levelSurfacesLowScaffold',
  FlexSurfaceMode.highScaffoldLowSurfaces: 'highScaffoldLowSurfaces',
  FlexSurfaceMode.levelSurfacesLowScaffoldVariantDialog: 'levelSurfacesLowScaffoldVariantDialog',
  FlexSurfaceMode.highScaffoldLowSurfacesVariantDialog: 'highScaffoldLowSurfacesVariantDialog',
  FlexSurfaceMode.custom: 'custom',
};

const _$FlexSchemeVariantEnumMap = {
  FlexSchemeVariant.tonalSpot: 'tonalSpot',
  FlexSchemeVariant.fidelity: 'fidelity',
  FlexSchemeVariant.monochrome: 'monochrome',
  FlexSchemeVariant.neutral: 'neutral',
  FlexSchemeVariant.vibrant: 'vibrant',
  FlexSchemeVariant.expressive: 'expressive',
  FlexSchemeVariant.content: 'content',
  FlexSchemeVariant.rainbow: 'rainbow',
  FlexSchemeVariant.fruitSalad: 'fruitSalad',
  FlexSchemeVariant.material: 'material',
  FlexSchemeVariant.material3Legacy: 'material3Legacy',
  FlexSchemeVariant.soft: 'soft',
  FlexSchemeVariant.vivid: 'vivid',
  FlexSchemeVariant.vividSurfaces: 'vividSurfaces',
  FlexSchemeVariant.highContrast: 'highContrast',
  FlexSchemeVariant.ultraContrast: 'ultraContrast',
  FlexSchemeVariant.jolly: 'jolly',
  FlexSchemeVariant.vividBackground: 'vividBackground',
  FlexSchemeVariant.oneHue: 'oneHue',
  FlexSchemeVariant.candyPop: 'candyPop',
  FlexSchemeVariant.chroma: 'chroma',
};

PlatformSettings _$PlatformSettingsFromJson(Map json) => $checkedCreate('PlatformSettings', json, ($checkedConvert) {
  final val = PlatformSettings(
    alwaysOnTop: $checkedConvert('alwaysOnTop', (v) => v as bool? ?? false),
    windowPosition: $checkedConvert(
      'windowPosition',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
    ),
    showSystemTray: $checkedConvert('showSystemTray', (v) => v as bool? ?? false),
    autoRotate: $checkedConvert('autoRotate', (v) => v as bool? ?? true),
  );
  return val;
});

Map<String, dynamic> _$PlatformSettingsToJson(PlatformSettings instance) => <String, dynamic>{
  'alwaysOnTop': instance.alwaysOnTop,
  'windowPosition': instance.windowPosition,
  'showSystemTray': instance.showSystemTray,
  'autoRotate': instance.autoRotate,
};

NetworkSettings _$NetworkSettingsFromJson(Map json) => $checkedCreate('NetworkSettings', json, ($checkedConvert) {
  final val = NetworkSettings(
    autoUpdateData: $checkedConvert('autoUpdateData', (v) => v as bool? ?? true),
    updateDataBeforeStart: $checkedConvert('updateDataBeforeStart', (v) => v as bool? ?? false),
    checkDataHash: $checkedConvert('checkDataHash', (v) => v as bool? ?? true),
    autoUpdateApp: $checkedConvert('autoUpdateApp', (v) => v as bool? ?? true),
    forceOnline: $checkedConvert('forceOnline', (v) => v as bool? ?? false),
    alertUploadUserData: $checkedConvert('alertUploadUserData', (v) => v as bool? ?? false),
    proxy: $checkedConvert(
      'proxy',
      (v) => v == null ? null : ProxySettings.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
  );
  return val;
});

Map<String, dynamic> _$NetworkSettingsToJson(NetworkSettings instance) => <String, dynamic>{
  'autoUpdateData': instance.autoUpdateData,
  'updateDataBeforeStart': instance.updateDataBeforeStart,
  'checkDataHash': instance.checkDataHash,
  'autoUpdateApp': instance.autoUpdateApp,
  'forceOnline': instance.forceOnline,
  'alertUploadUserData': instance.alertUploadUserData,
  'proxy': instance.proxy.toJson(),
};

LocaleSettings _$LocaleSettingsFromJson(Map json) => $checkedCreate('LocaleSettings', json, ($checkedConvert) {
  final val = LocaleSettings(
    preferredRegions: $checkedConvert(
      'preferredRegions',
      (v) => (v as List<dynamic>?)?.map((e) => const RegionConverter().fromJson(e as String)).toList(),
    ),
    preferredQuestRegion: $checkedConvert(
      'preferredQuestRegion',
      (v) => _$JsonConverterFromJson<String, Region>(v, const RegionConverter().fromJson),
    ),
  );
  return val;
});

Map<String, dynamic> _$LocaleSettingsToJson(LocaleSettings instance) => <String, dynamic>{
  'preferredRegions': instance.preferredRegions?.map(const RegionConverter().toJson).toList(),
  'preferredQuestRegion': _$JsonConverterToJson<String, Region>(
    instance.preferredQuestRegion,
    const RegionConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(Object? json, Value? Function(Json json) fromJson) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(Value? value, Json? Function(Value value) toJson) =>
    value == null ? null : toJson(value);

GameplaySettings _$GameplaySettingsFromJson(Map json) => $checkedCreate('GameplaySettings', json, ($checkedConvert) {
  final val = GameplaySettings(
    preferApRate: $checkedConvert('preferApRate', (v) => v as bool? ?? true),
    preferredFavorite: $checkedConvert('preferredFavorite', (v) => $enumDecodeNullable(_$FavoriteStateEnumMap, v)),
    priorityTags: $checkedConvert(
      'priorityTags',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), e as String)),
    ),
    eventItemCalc: $checkedConvert(
      'eventItemCalc',
      (v) => (v as Map?)?.map(
        (k, e) => MapEntry(int.parse(k as String), EventItemCalcParams.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
    ),
    masterMissionOptions: $checkedConvert(
      'masterMissionOptions',
      (v) => v == null ? null : MasterMissionOptions.fromJson(Map<String, dynamic>.from(v as Map)),
    ),
  );
  return val;
});

Map<String, dynamic> _$GameplaySettingsToJson(GameplaySettings instance) => <String, dynamic>{
  'preferApRate': instance.preferApRate,
  'preferredFavorite': _$FavoriteStateEnumMap[instance.preferredFavorite],
  'priorityTags': instance.priorityTags.map((k, e) => MapEntry(k.toString(), e)),
  'eventItemCalc': instance.eventItemCalc.map((k, e) => MapEntry(k.toString(), e.toJson())),
  'masterMissionOptions': instance.masterMissionOptions.toJson(),
};

const _$FavoriteStateEnumMap = {FavoriteState.all: 'all', FavoriteState.owned: 'owned', FavoriteState.other: 'other'};

ProxySettings _$ProxySettingsFromJson(Map json) => $checkedCreate('ProxySettings', json, ($checkedConvert) {
  final val = ProxySettings(
    proxy: $checkedConvert('proxy', (v) => v as bool? ?? false),
    api: $checkedConvert('api', (v) => v as bool?),
    worker: $checkedConvert('worker', (v) => v as bool?),
    data: $checkedConvert('data', (v) => v as bool?),
    atlasApi: $checkedConvert('atlasApi', (v) => v as bool?),
    atlasAsset: $checkedConvert('atlasAsset', (v) => v as bool?),
    enableHttpProxy: $checkedConvert('enableHttpProxy', (v) => v as bool? ?? false),
    proxyHost: $checkedConvert('proxyHost', (v) => v as String?),
    proxyPort: $checkedConvert('proxyPort', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$ProxySettingsToJson(ProxySettings instance) => <String, dynamic>{
  'proxy': instance.proxy,
  'api': instance.api,
  'worker': instance.worker,
  'data': instance.data,
  'atlasApi': instance.atlasApi,
  'atlasAsset': instance.atlasAsset,
  'enableHttpProxy': instance.enableHttpProxy,
  'proxyHost': instance.proxyHost,
  'proxyPort': instance.proxyPort,
};

DisplaySettings _$DisplaySettingsFromJson(Map json) => $checkedCreate('DisplaySettings', json, ($checkedConvert) {
  final val = DisplaySettings(
    showWindowFab: $checkedConvert('showWindowFab', (v) => v as bool? ?? true),
    maxWindowWidth: $checkedConvert('maxWindowWidth', (v) => (v as num?)?.toInt()),
    enableSplitView: $checkedConvert('enableSplitView', (v) => v as bool? ?? true),
    splitMasterRatio: $checkedConvert('splitMasterRatio', (v) => (v as num?)?.toInt()),
    showAccountAtHome: $checkedConvert('showAccountAtHome', (v) => v as bool? ?? true),
    classFilterStyle: $checkedConvert(
      'classFilterStyle',
      (v) => $enumDecodeNullable(_$SvtListClassFilterStyleEnumMap, v) ?? SvtListClassFilterStyle.auto,
    ),
    svtPlanInputMode: $checkedConvert(
      'svtPlanInputMode',
      (v) => $enumDecodeNullable(_$SvtPlanInputModeEnumMap, v) ?? SvtPlanInputMode.dropdown,
    ),
    autoTurnOnPlanNotReach: $checkedConvert('autoTurnOnPlanNotReach', (v) => v as bool? ?? false),
    onlyAppendUnlocked: $checkedConvert('onlyAppendUnlocked', (v) => v as bool? ?? true),
    planPageFullScreen: $checkedConvert('planPageFullScreen', (v) => v as bool? ?? false),
    hideSvtPlanDetails: $checkedConvert(
      'hideSvtPlanDetails',
      (v) => (v as List<dynamic>?)?.map((e) => $enumDecodeNullable(_$SvtPlanDetailEnumMap, e)).toList(),
    ),
    sortedSvtTabs: $checkedConvert(
      'sortedSvtTabs',
      (v) => (v as List<dynamic>?)?.map((e) => $enumDecodeNullable(_$SvtTabEnumMap, e)).toList(),
    ),
    itemDetailViewType: $checkedConvert(
      'itemDetailViewType',
      (v) => $enumDecodeNullable(_$ItemDetailViewTypeEnumMap, v) ?? ItemDetailViewType.separated,
    ),
    itemDetailSvtSort: $checkedConvert(
      'itemDetailSvtSort',
      (v) => $enumDecodeNullable(_$ItemDetailSvtSortEnumMap, v) ?? ItemDetailSvtSort.collectionNo,
    ),
    itemQuestsSortByAp: $checkedConvert('itemQuestsSortByAp', (v) => v as bool? ?? true),
    showOriginalMissionText: $checkedConvert('showOriginalMissionText', (v) => v as bool? ?? false),
    galleries: $checkedConvert('galleries', (v) => (v as Map?)?.map((k, e) => MapEntry(k as String, e as bool))),
    galleryIconSize: $checkedConvert(
      'galleryIconSize',
      (v) => $enumDecodeNullable(_$GalleryIconSizeEnumMap, v) ?? .medium,
    ),
    enableMouseDrag: $checkedConvert('enableMouseDrag', (v) => v as bool? ?? true),
    globalSelection: $checkedConvert('globalSelection', (v) => v as bool? ?? false),
    forceEdgeSwipePopGesture: $checkedConvert('forceEdgeSwipePopGesture', (v) => v as bool? ?? false),
    ad: $checkedConvert('ad', (v) => v == null ? null : AdSetting.fromJson(Map<String, dynamic>.from(v as Map))),
    showDebugFab: $checkedConvert('showDebugFab', (v) => v as bool? ?? false),
  );
  return val;
});

Map<String, dynamic> _$DisplaySettingsToJson(DisplaySettings instance) => <String, dynamic>{
  'showWindowFab': instance.showWindowFab,
  'maxWindowWidth': instance.maxWindowWidth,
  'enableSplitView': instance.enableSplitView,
  'splitMasterRatio': instance.splitMasterRatio,
  'showAccountAtHome': instance.showAccountAtHome,
  'classFilterStyle': _$SvtListClassFilterStyleEnumMap[instance.classFilterStyle]!,
  'svtPlanInputMode': _$SvtPlanInputModeEnumMap[instance.svtPlanInputMode]!,
  'autoTurnOnPlanNotReach': instance.autoTurnOnPlanNotReach,
  'onlyAppendUnlocked': instance.onlyAppendUnlocked,
  'planPageFullScreen': instance.planPageFullScreen,
  'hideSvtPlanDetails': instance.hideSvtPlanDetails.map((e) => _$SvtPlanDetailEnumMap[e]!).toList(),
  'sortedSvtTabs': instance.sortedSvtTabs.map((e) => _$SvtTabEnumMap[e]!).toList(),
  'itemDetailViewType': _$ItemDetailViewTypeEnumMap[instance.itemDetailViewType]!,
  'itemDetailSvtSort': _$ItemDetailSvtSortEnumMap[instance.itemDetailSvtSort]!,
  'itemQuestsSortByAp': instance.itemQuestsSortByAp,
  'showOriginalMissionText': instance.showOriginalMissionText,
  'galleries': instance.galleries,
  'galleryIconSize': _$GalleryIconSizeEnumMap[instance.galleryIconSize]!,
  'enableMouseDrag': instance.enableMouseDrag,
  'globalSelection': instance.globalSelection,
  'forceEdgeSwipePopGesture': instance.forceEdgeSwipePopGesture,
  'ad': instance.ad.toJson(),
  'showDebugFab': instance.showDebugFab,
};

const _$SvtListClassFilterStyleEnumMap = {
  SvtListClassFilterStyle.auto: 'auto',
  SvtListClassFilterStyle.singleRow: 'singleRow',
  SvtListClassFilterStyle.singleRowExpanded: 'singleRowExpanded',
  SvtListClassFilterStyle.twoRow: 'twoRow',
  SvtListClassFilterStyle.doNotShow: 'doNotShow',
};

const _$SvtPlanInputModeEnumMap = {SvtPlanInputMode.dropdown: 'dropdown', SvtPlanInputMode.slider: 'slider'};

const _$SvtPlanDetailEnumMap = {
  SvtPlanDetail.ascension: 'ascension',
  SvtPlanDetail.activeSkill: 'activeSkill',
  SvtPlanDetail.appendSkill: 'appendSkill',
  SvtPlanDetail.costume: 'costume',
  SvtPlanDetail.coin: 'coin',
  SvtPlanDetail.grail: 'grail',
  SvtPlanDetail.noblePhantasm: 'noblePhantasm',
  SvtPlanDetail.fou5: 'fou5',
  SvtPlanDetail.fou4: 'fou4',
  SvtPlanDetail.fou3: 'fou3',
  SvtPlanDetail.bondLimit: 'bondLimit',
  SvtPlanDetail.commandCode: 'commandCode',
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

const _$GalleryIconSizeEnumMap = {
  GalleryIconSize.small: 'small',
  GalleryIconSize.medium: 'medium',
  GalleryIconSize.large: 'large',
};

AdSetting _$AdSettingFromJson(Map json) => $checkedCreate('AdSetting', json, ($checkedConvert) {
  final val = AdSetting(
    enabled: $checkedConvert('enabled', (v) => $enumDecodeNullable(_$AdFeatureStateEnumMap, v) ?? .defaults),
    banner: $checkedConvert('banner', (v) => $enumDecodeNullable(_$AdFeatureStateEnumMap, v) ?? .defaults),
    appOpen: $checkedConvert('appOpen', (v) => $enumDecodeNullable(_$AdFeatureStateEnumMap, v) ?? .defaults),
    interstitial: $checkedConvert('interstitial', (v) => $enumDecodeNullable(_$AdFeatureStateEnumMap, v) ?? .defaults),
    personalizedAds: $checkedConvert('personalizedAds', (v) => v as bool?),
    lastAppOpen: $checkedConvert('lastAppOpen', (v) => (v as num?)?.toInt() ?? 0),
    lastAttRequestTime: $checkedConvert('lastAttRequestTime', (v) => (v as num?)?.toInt() ?? 0),
    attAuthorized: $checkedConvert('attAuthorized', (v) => v as bool?),
    privacyPolicyAccepted: $checkedConvert('privacyPolicyAccepted', (v) => v as bool? ?? false),
  );
  return val;
});

Map<String, dynamic> _$AdSettingToJson(AdSetting instance) => <String, dynamic>{
  'enabled': _$AdFeatureStateEnumMap[instance.enabled]!,
  'banner': _$AdFeatureStateEnumMap[instance.banner]!,
  'appOpen': _$AdFeatureStateEnumMap[instance.appOpen]!,
  'interstitial': _$AdFeatureStateEnumMap[instance.interstitial]!,
  'personalizedAds': instance.personalizedAds,
  'lastAppOpen': instance.lastAppOpen,
  'lastAttRequestTime': instance.lastAttRequestTime,
  'attAuthorized': instance.attAuthorized,
  'privacyPolicyAccepted': instance.privacyPolicyAccepted,
};

const _$AdFeatureStateEnumMap = {
  AdFeatureState.defaults: 'defaults',
  AdFeatureState.on: 'on',
  AdFeatureState.off: 'off',
  AdFeatureState.forcedOn: 'forcedOn',
};

CarouselSetting _$CarouselSettingFromJson(Map json) => $checkedCreate('CarouselSetting', json, ($checkedConvert) {
  final val = CarouselSetting(
    ver: $checkedConvert('ver', (v) => (v as num?)?.toInt()),
    updateTime: $checkedConvert('updateTime', (v) => (v as num?)?.toInt()),
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>?)?.map((e) => CarouselItem.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
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
});

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

CarouselItem _$CarouselItemFromJson(Map json) => $checkedCreate('CarouselItem', json, ($checkedConvert) {
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
    verMin: $checkedConvert('verMin', (v) => v == null ? null : AppVersion.fromJson(v as String)),
    verMax: $checkedConvert('verMax', (v) => v == null ? null : AppVersion.fromJson(v as String)),
    eventIds: $checkedConvert('eventIds', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
    warIds: $checkedConvert('warIds', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList()),
    summonIds: $checkedConvert('summonIds', (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
  );
  return val;
});

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
  'verMin': instance.verMin?.toJson(),
  'verMax': instance.verMax?.toJson(),
  'eventIds': instance.eventIds,
  'warIds': instance.warIds,
  'summonIds': instance.summonIds,
};

GithubSetting _$GithubSettingFromJson(Map json) => $checkedCreate('GithubSetting', json, ($checkedConvert) {
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
});

Map<String, dynamic> _$GithubSettingToJson(GithubSetting instance) => <String, dynamic>{
  'owner': instance.owner,
  'repo': instance.repo,
  'path': instance.path,
  'token': GithubSetting._writeToken(instance.token),
  'branch': instance.branch,
  'sha': instance.sha,
  'indent': instance.indent,
};

TipsSetting _$TipsSettingFromJson(Map json) => $checkedCreate('TipsSetting', json, ($checkedConvert) {
  final val = TipsSetting(
    starter: $checkedConvert('starter', (v) => v as bool? ?? true),
    servantList: $checkedConvert('servantList', (v) => (v as num?)?.toInt() ?? 2),
    servantDetail: $checkedConvert('servantDetail', (v) => (v as num?)?.toInt() ?? 2),
  );
  return val;
});

Map<String, dynamic> _$TipsSettingToJson(TipsSetting instance) => <String, dynamic>{
  'starter': instance.starter,
  'servantList': instance.servantList,
  'servantDetail': instance.servantDetail,
};

EventItemCalcParams _$EventItemCalcParamsFromJson(Map json) =>
    $checkedCreate('EventItemCalcParams', json, ($checkedConvert) {
      final val = EventItemCalcParams(
        itemCounts: $checkedConvert(
          'itemCounts',
          (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
        ),
        bonusPlans: $checkedConvert(
          'bonusPlans',
          (v) =>
              (v as List<dynamic>?)?.map((e) => QuestBonusPlan.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$EventItemCalcParamsToJson(EventItemCalcParams instance) => <String, dynamic>{
  'itemCounts': instance.itemCounts.map((k, e) => MapEntry(k.toString(), e)),
  'bonusPlans': instance.bonusPlans.map((e) => e.toJson()).toList(),
};

QuestBonusPlan _$QuestBonusPlanFromJson(Map json) => $checkedCreate('QuestBonusPlan', json, ($checkedConvert) {
  final val = QuestBonusPlan(
    enabled: $checkedConvert('enabled', (v) => v as bool? ?? true),
    questId: $checkedConvert('questId', (v) => (v as num?)?.toInt() ?? 0),
    index: $checkedConvert('index', (v) => (v as num?)?.toInt() ?? 0),
    name: $checkedConvert('name', (v) => v as String? ?? ""),
    bonus: $checkedConvert(
      'bonus',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
    ),
  );
  return val;
});

Map<String, dynamic> _$QuestBonusPlanToJson(QuestBonusPlan instance) => <String, dynamic>{
  'enabled': instance.enabled,
  'questId': instance.questId,
  'index': instance.index,
  'name': instance.name,
  'bonus': instance.bonus.map((k, e) => MapEntry(k.toString(), e)),
};

MasterMissionOptions _$MasterMissionOptionsFromJson(Map json) =>
    $checkedCreate('MasterMissionOptions', json, ($checkedConvert) {
      final val = MasterMissionOptions(
        blacklist: $checkedConvert('blacklist', (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet()),
        excludeRandomEnemyQuests: $checkedConvert('excludeRandomEnemyQuests', (v) => v as bool? ?? false),
      );
      return val;
    });

Map<String, dynamic> _$MasterMissionOptionsToJson(MasterMissionOptions instance) => <String, dynamic>{
  'blacklist': instance.blacklist.toList(),
  'excludeRandomEnemyQuests': instance.excludeRandomEnemyQuests,
};

_MiscSettings _$MiscSettingsFromJson(Map json) => $checkedCreate('_MiscSettings', json, ($checkedConvert) {
  final val = _MiscSettings(
    launchTimes: $checkedConvert('launchTimes', (v) => (v as num?)?.toInt() ?? 0),
    lastLaunchTime: $checkedConvert('lastLaunchTime', (v) => (v as num?)?.toInt() ?? 0),
    lastBackup: $checkedConvert('lastBackup', (v) => (v as num?)?.toInt() ?? 0),
    nonSvtCharaFigureIds: $checkedConvert(
      'nonSvtCharaFigureIds',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toSet(),
    ),
    markedCharaFigureSvtIds: $checkedConvert(
      'markedCharaFigureSvtIds',
      (v) => (v as Map?)?.map((k, e) => MapEntry(int.parse(k as String), (e as num).toInt())),
    ),
    nonSvtCharaImageIds: $checkedConvert(
      'nonSvtCharaImageIds',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet(),
    ),
    markedCharaImageSvtIds: $checkedConvert(
      'markedCharaImageSvtIds',
      (v) => (v as Map?)?.map((k, e) => MapEntry(k as String, (e as num).toInt())),
    ),
  );
  return val;
});

Map<String, dynamic> _$MiscSettingsToJson(_MiscSettings instance) => <String, dynamic>{
  'launchTimes': instance.launchTimes,
  'lastLaunchTime': instance.lastLaunchTime,
  'lastBackup': instance.lastBackup,
  'nonSvtCharaFigureIds': instance.nonSvtCharaFigureIds.toList(),
  'markedCharaFigureSvtIds': instance.markedCharaFigureSvtIds.map((k, e) => MapEntry(k.toString(), e)),
  'nonSvtCharaImageIds': instance.nonSvtCharaImageIds.toList(),
  'markedCharaImageSvtIds': instance.markedCharaImageSvtIds,
};

_SecretsData _$SecretsDataFromJson(Map json) => $checkedCreate('_SecretsData', json, ($checkedConvert) {
  final val = _SecretsData(
    user: $checkedConvert('user', (v) => v == null ? null : ChaldeaUser.fromJson(Map<String, dynamic>.from(v as Map))),
    explorerAuth: $checkedConvert('explorerAuth', (v) => v as String?),
    atlasReloadKey: $checkedConvert('atlasReloadKey', (v) => v as String? ?? ""),
    atlasExportKey: $checkedConvert('atlasExportKey', (v) => v as String? ?? ""),
  );
  return val;
});

Map<String, dynamic> _$SecretsDataToJson(_SecretsData instance) => <String, dynamic>{
  'user': instance.user.toJson(),
  'explorerAuth': instance.explorerAuth,
  'atlasReloadKey': instance.atlasReloadKey,
  'atlasExportKey': instance.atlasExportKey,
};

BookmarkHistory _$BookmarkHistoryFromJson(Map json) => $checkedCreate('BookmarkHistory', json, ($checkedConvert) {
  final val = BookmarkHistory(
    bookmarks: $checkedConvert(
      'bookmarks',
      (v) => (v as List<dynamic>?)?.map((e) => BookmarkEntry.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$BookmarkHistoryToJson(BookmarkHistory instance) => <String, dynamic>{
  'bookmarks': instance.bookmarks.map((e) => e.toJson()).toList(),
};

BookmarkEntry _$BookmarkEntryFromJson(Map json) => $checkedCreate('BookmarkEntry', json, ($checkedConvert) {
  final val = BookmarkEntry(
    name: $checkedConvert('name', (v) => v as String?),
    url: $checkedConvert('url', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$BookmarkEntryToJson(BookmarkEntry instance) => <String, dynamic>{
  'name': instance.name,
  'url': instance.url,
  'createdAt': instance.createdAt,
};
