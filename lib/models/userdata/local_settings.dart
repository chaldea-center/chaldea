import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/utils/utils.dart';

import '../../packages/language.dart';
import '../api/api.dart';
import '../gamedata/gamedata.dart';
import '_helper.dart';
import 'autologin.dart';
import 'battle.dart';
import 'filter_data.dart';
import 'remote_config.dart';
import 'version.dart';

export 'battle.dart';
export 'filter_data.dart';
export 'remote_config.dart';

part '../../generated/models/userdata/local_settings.g.dart';

@JsonSerializable(converters: [RegionConverter()])
class LocalSettings {
  /// LocalSettings data format version.
  /// 1: legacy flat layout (before the settings group refactor).
  /// 2: nested groups (appearance/platform/network/locale/gameplay/...).
  static const int kSettingsFormatVersion = 2;

  @JsonKey(defaultValue: kSettingsFormatVersion)
  int formatVersion;

  String? _language;

  AppearanceSettings appearance;
  PlatformSettings platform;
  NetworkSettings network;
  LocaleSettings locale;
  GameplaySettings gameplay;

  DisplaySettings display;
  CarouselSetting carousel;
  GithubSetting github;
  TipsSetting tips;
  BattleSimSetting battleSim;
  LocalDataFilters filters;
  FakerSettings fakerSettings;
  RemoteConfig remoteConfig;
  BookmarkHistory bookmarks;
  _MiscSettings misc;
  _SecretsData secrets;

  LocalSettings({
    int? formatVersion,
    this._language,
    AppearanceSettings? appearance,
    PlatformSettings? platform,
    NetworkSettings? network,
    LocaleSettings? locale,
    GameplaySettings? gameplay,
    DisplaySettings? display,
    CarouselSetting? carousel,
    GithubSetting? github,
    TipsSetting? tips,
    BattleSimSetting? battleSim,
    LocalDataFilters? filters,
    FakerSettings? fakerSettings,
    RemoteConfig? remoteConfig,
    BookmarkHistory? bookmarks,
    _MiscSettings? misc,
    _SecretsData? secrets,
  }) : formatVersion = formatVersion ?? kSettingsFormatVersion,
       appearance = appearance ?? AppearanceSettings(),
       platform = platform ?? PlatformSettings(),
       network = network ?? NetworkSettings(),
       locale = locale ?? LocaleSettings(),
       gameplay =
           gameplay ??
           GameplaySettings(
             // same first-launch default as the pre-refactor constructor
             preferredFavorite: (misc?.launchTimes ?? 0) == 0 ? FavoriteState.all : null,
           ),
       display = display ?? DisplaySettings(),
       carousel = carousel ?? CarouselSetting(),
       github = github ?? GithubSetting(),
       tips = tips ?? TipsSetting(),
       battleSim = battleSim ?? BattleSimSetting(),
       filters = filters ?? LocalDataFilters(),
       fakerSettings = fakerSettings ?? FakerSettings(),
       remoteConfig = remoteConfig ?? RemoteConfig(),
       bookmarks = bookmarks ?? BookmarkHistory(),
       misc = misc ?? _MiscSettings(),
       secrets = secrets ?? _SecretsData();

  String? get language => _language;

  Future<S> setLanguage(Language lang) {
    _language = Intl.defaultLocale = lang.code;
    return S.load(lang.locale, override: true);
  }

  ThemeMode get themeMode => appearance.themeMode;

  List<Region> get resolvedPreferredRegions => locale.resolvedPreferredRegions(_language);

  bool get hideApple => PlatformU.isApple && misc.launchTimes < 5;

  factory LocalSettings.fromJson(Map<String, dynamic> rawJson, {BattleSimUserData? legacyPins}) {
    final formatVersion = rawJson['formatVersion'];
    final json = formatVersion is int && formatVersion >= kSettingsFormatVersion
        ? Map<String, dynamic>.of(rawJson)
        : _migrateLegacyV1(rawJson);
    if (legacyPins != null) {
      final gameplay = Map<String, dynamic>.from(json['gameplay'] as Map? ?? {});
      // Existing shared fields, including explicit empty arrays, take precedence.
      // ignore: invalid_use_of_protected_member
      gameplay.putIfAbsent('pinnedSvtIds', () => legacyPins.pingedSvts.toList());
      // ignore: invalid_use_of_protected_member
      gameplay.putIfAbsent('pinnedSvtEquipIds', () => legacyPins.pingedCEs.toList());
      json['gameplay'] = gameplay;
    }
    final settings = _$LocalSettingsFromJson(json);
    if (legacyPins != null) {
      // Clear only after settings have been deserialized successfully.
      // ignore: invalid_use_of_protected_member
      legacyPins.pingedSvts.clear();
      // ignore: invalid_use_of_protected_member
      legacyPins.pingedCEs.clear();
    }
    return settings;
  }

  Map<String, dynamic> toJson() {
    final json = _$LocalSettingsToJson(this);
    _writeLegacyV1Mirrors(json);
    return json;
  }

  static void _writeLegacyV1Mirrors(Map<String, dynamic> json) {
    void mirror(String group, Iterable<String> keys) {
      final src = (json[group] as Map?)?.cast<String, dynamic>();
      if (src == null) return;
      for (final k in keys) {
        if (src.containsKey(k)) json[k] ??= src[k];
      }
    }

    mirror('appearance', [
      'themeMode',
      'useMaterial3',
      'flexScheme',
      'flexSurfaceMode',
      'flexBlendLevel',
      'flexSchemeVariant',
      'colorSeedInt',
    ]);
    mirror('platform', ['alwaysOnTop', 'windowPosition', 'showSystemTray', 'autoRotate']);
    mirror('network', [
      'autoUpdateData',
      'updateDataBeforeStart',
      'checkDataHash',
      'autoUpdateApp',
      'forceOnline',
      'alertUploadUserData',
    ]);
    // v1 stored the proxy object at root level
    final proxy = json['network']?['proxy'];
    if (proxy is Map) json['proxy'] = proxy;
    mirror('locale', ['preferredRegions', 'preferredQuestRegion']);
    mirror('gameplay', ['preferApRate', 'preferredFavorite', 'priorityTags', 'eventItemCalc', 'masterMissionOptions']);
    mirror('display', ['enableMouseDrag', 'globalSelection', 'forceEdgeSwipePopGesture', 'galleries', 'showDebugFab']);
    mirror('filters', [
      'spoilerRegion',
      'removeOldDataRegion',
      'autoResetFilter',
      'hideUnreleasedCard',
      'hideUnreleasedEnemyCollection',
    ]);
    mirror('misc', ['launchTimes', 'lastLaunchTime', 'lastBackup']);
  }

  static Map<String, dynamic> _migrateLegacyV1(Map<String, dynamic> rawJson) {
    Map<String, dynamic> nested(String key, Iterable<String> legacyKeys) {
      final source = (rawJson[key] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      final target = Map.of(source);
      for (final k in legacyKeys) {
        if (target[k] == null && rawJson.containsKey(k)) target[k] = rawJson[k];
      }
      return target;
    }

    final json = Map.of(rawJson);

    json['appearance'] = nested('appearance', [
      'themeMode',
      'useMaterial3',
      'flexScheme',
      'flexSurfaceMode',
      'flexBlendLevel',
      'flexSchemeVariant',
      'colorSeedInt',
    ]);
    json['platform'] = nested('platform', ['alwaysOnTop', 'windowPosition', 'showSystemTray', 'autoRotate']);

    final networkMap = nested('network', [
      'autoUpdateData',
      'updateDataBeforeStart',
      'checkDataHash',
      'autoUpdateApp',
      'forceOnline',
      'alertUploadUserData',
    ]);
    // Fold the root-level proxy object and the legacy 'proxyServer' mirror
    // switch into network.proxy (single source of truth).
    final proxyMap = Map.of((rawJson['proxy'] as Map?)?.cast<String, dynamic>() ?? {});
    if (proxyMap['proxy'] == null && rawJson.containsKey('proxyServer')) {
      proxyMap['proxy'] = rawJson['proxyServer'];
    }
    networkMap['proxy'] = proxyMap;
    json['network'] = networkMap;

    json['locale'] = nested('locale', ['preferredRegions', 'preferredQuestRegion']);

    final gameplayMap = nested('gameplay', ['preferApRate', 'preferredFavorite', 'eventItemCalc', 'priorityTags']);
    // masterMissionOptions moves one level down into gameplay.
    if (gameplayMap['masterMissionOptions'] == null && rawJson.containsKey('masterMissionOptions')) {
      gameplayMap['masterMissionOptions'] = rawJson['masterMissionOptions'];
    }
    // same default injection as the pre-refactor factory
    gameplayMap['preferredFavorite'] ??= _$FavoriteStateEnumMap[FavoriteState.all];
    json['gameplay'] = gameplayMap;

    json['display'] = nested('display', [
      'enableMouseDrag',
      'globalSelection',
      'forceEdgeSwipePopGesture',
      'galleries',
      'showDebugFab',
    ]);
    json['filters'] = nested('filters', [
      'spoilerRegion',
      'removeOldDataRegion',
      'autoResetFilter',
      'hideUnreleasedCard',
      'hideUnreleasedEnemyCollection',
    ]);
    json['misc'] = nested('misc', ['launchTimes', 'lastLaunchTime', 'lastBackup']);

    final fakerMap = Map.of((rawJson['fakerSettings'] as Map?)?.cast<String, dynamic>() ?? {});
    if (fakerMap['jpAutoLogins'] == null && rawJson.containsKey('autologins')) {
      fakerMap['jpAutoLogins'] = rawJson['autologins'];
    }
    if (fakerMap['cnAutoLogins'] == null && rawJson.containsKey('cnAutoLogins')) {
      fakerMap['cnAutoLogins'] = rawJson['cnAutoLogins'];
    }
    json['fakerSettings'] = fakerMap;

    return json;
  }
}

@JsonSerializable()
class AppearanceSettings {
  ThemeMode themeMode;
  bool useMaterial3;
  FlexScheme? flexScheme;
  FlexSurfaceMode? flexSurfaceMode;
  int? flexBlendLevel;
  FlexSchemeVariant? flexSchemeVariant;
  int? colorSeedInt;

  AppearanceSettings({
    this.themeMode = ThemeMode.system,
    this.useMaterial3 = false,
    this.flexScheme,
    this.flexSurfaceMode,
    this.flexBlendLevel,
    this.flexSchemeVariant,
    this.colorSeedInt,
  });

  FlexScheme get resolvedFlexScheme => flexScheme ?? .tealM3;

  bool get isResolvedDarkMode {
    if (themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }

  Color? get colorSeed {
    if (colorSeedInt == null) return null;
    try {
      return Color(colorSeedInt!);
    } catch (e) {
      colorSeedInt = null;
      return null;
    }
  }

  factory AppearanceSettings.fromJson(Map<String, dynamic> json) => _$AppearanceSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AppearanceSettingsToJson(this);
}

@JsonSerializable()
class PlatformSettings {
  bool alwaysOnTop;
  List<int>? windowPosition;
  bool showSystemTray;
  bool autoRotate;

  PlatformSettings({
    this.alwaysOnTop = false,
    this.windowPosition,
    this.showSystemTray = false,
    this.autoRotate = true,
  });

  factory PlatformSettings.fromJson(Map<String, dynamic> json) => _$PlatformSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformSettingsToJson(this);
}

@JsonSerializable()
class NetworkSettings {
  bool autoUpdateData; // dataset
  bool updateDataBeforeStart;
  bool checkDataHash;
  bool autoUpdateApp;
  bool forceOnline;
  bool alertUploadUserData;
  ProxySettings proxy;

  NetworkSettings({
    this.autoUpdateData = true,
    this.updateDataBeforeStart = false,
    this.checkDataHash = true,
    this.autoUpdateApp = true,
    this.forceOnline = false,
    this.alertUploadUserData = false,
    ProxySettings? proxy,
  }) : proxy = proxy ?? ProxySettings();

  factory NetworkSettings.fromJson(Map<String, dynamic> json) => _$NetworkSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkSettingsToJson(this);
}

/// Region preferences.
@JsonSerializable(converters: [RegionConverter()])
class LocaleSettings {
  List<Region>? preferredRegions;
  Region? preferredQuestRegion;

  LocaleSettings({List<Region>? preferredRegions, this.preferredQuestRegion})
    : preferredRegions = preferredRegions == null
          ? null
          : (List.of(Region.values)..sort2((e) => preferredRegions.indexOf(e) % Region.values.length));

  List<Region> resolvedPreferredRegions(String? language) {
    if (preferredRegions != null && preferredRegions!.isNotEmpty) {
      return preferredRegions!;
    }
    switch (Language.getLanguage(language)) {
      case Language.jp:
        return [Region.jp, Region.na, Region.cn, Region.tw, Region.kr];
      case Language.chs:
        return [Region.cn, Region.tw, Region.jp, Region.na, Region.kr];
      case Language.cht:
        return [Region.tw, Region.cn, Region.jp, Region.na, Region.kr];
      case Language.ko:
        return [Region.kr, Region.na, Region.jp, Region.cn, Region.tw];
      default:
        return [Region.na, Region.jp, Region.cn, Region.tw, Region.kr];
    }
  }

  factory LocaleSettings.fromJson(Map<String, dynamic> json) => _$LocaleSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LocaleSettingsToJson(this);
}

@JsonSerializable()
class GameplaySettings {
  Set<int> pinnedSvtIds;
  Set<int> pinnedSvtEquipIds;

  bool preferApRate;
  FavoriteState? preferredFavorite;
  Map<int, String> priorityTags;
  Map<int, EventItemCalcParams> eventItemCalc;
  MasterMissionOptions masterMissionOptions;

  GameplaySettings({
    Set<int>? pinnedSvtIds,
    Set<int>? pinnedSvtEquipIds,
    this.preferApRate = true,
    this.preferredFavorite,
    Map<int, String>? priorityTags,
    Map<int, EventItemCalcParams>? eventItemCalc,
    MasterMissionOptions? masterMissionOptions,
  }) : pinnedSvtIds = pinnedSvtIds ?? {503900, 504500, 604200, 2800100, 901400},
       pinnedSvtEquipIds = pinnedSvtEquipIds ?? {9400180, 9400280, 9400340, 9400480, 9403990},
       priorityTags = priorityTags ?? {},
       eventItemCalc = eventItemCalc ?? {},
       masterMissionOptions = masterMissionOptions ?? MasterMissionOptions();

  factory GameplaySettings.fromJson(Map<String, dynamic> json) => _$GameplaySettingsFromJson(json);

  /// Normalize persisted collection numbers once valid game data is available.
  bool normalizePinnedIds(GameData gameData) {
    if (!gameData.isValid) return false;
    final svtIds = pinnedSvtIds
        .map((value) => (gameData.servantsById[value] ?? gameData.servantsNoDup[value])?.id)
        .whereType<int>()
        .toSet();
    final equipIds = pinnedSvtEquipIds
        .map((value) => (gameData.craftEssencesById[value] ?? gameData.craftEssences[value])?.id)
        .whereType<int>()
        .toSet();
    final changed =
        !pinnedSvtIds.containsAll(svtIds) ||
        pinnedSvtIds.length != svtIds.length ||
        !pinnedSvtEquipIds.containsAll(equipIds) ||
        pinnedSvtEquipIds.length != equipIds.length;
    pinnedSvtIds = svtIds;
    pinnedSvtEquipIds = equipIds;
    return changed;
  }

  List<List<int>> pinnedSvtEquipGroups(Quest? quest, Servant? svt) {
    final event = quest?.war?.event;
    return [
      pinnedSvtEquipIds.toList(),
      if (event != null)
        [
          for (final ce in db.gameData.craftEssences.values)
            if (ce.eventSkills(event.id).isNotEmpty) ce.id,
        ],
      svt?.bondEquips.toList() ?? [],
    ];
  }

  Map<String, dynamic> toJson() => _$GameplaySettingsToJson(this);
}

@JsonSerializable()
class ProxySettings {
  bool proxy;
  bool api;
  bool worker;
  bool data;
  bool atlasApi;
  bool atlasAsset;

  bool enableHttpProxy = false;
  String? proxyHost;
  int? proxyPort;

  ProxySettings({
    this.proxy = false,
    bool? api,
    bool? worker,
    bool? data,
    bool? atlasApi,
    bool? atlasAsset,
    this.enableHttpProxy = false,
    this.proxyHost,
    this.proxyPort,
  }) : api = api ?? proxy,
       worker = worker ?? proxy,
       data = data ?? proxy,
       atlasApi = atlasApi ?? proxy,
       atlasAsset = atlasAsset ?? false;

  void setAll(bool v) {
    proxy = api = worker = data = atlasApi = v;
  }

  factory ProxySettings.fromJson(Map<String, dynamic> data) => _$ProxySettingsFromJson(data);

  Map<String, dynamic> toJson() => _$ProxySettingsToJson(this);
}

@JsonSerializable()
class DisplaySettings {
  bool showWindowFab;
  int? maxWindowWidth; // web only
  bool enableSplitView;
  int? splitMasterRatio;

  bool showAccountAtHome;

  SvtListClassFilterStyle classFilterStyle;

  SvtPlanInputMode svtPlanInputMode;
  bool autoTurnOnPlanNotReach;
  bool onlyAppendUnlocked;
  bool planPageFullScreen;
  List<SvtPlanDetail> hideSvtPlanDetails;

  List<SvtTab> sortedSvtTabs;

  ItemDetailViewType itemDetailViewType;
  ItemDetailSvtSort itemDetailSvtSort;
  bool itemQuestsSortByAp;

  bool showOriginalMissionText;

  Map<String, bool> galleries;
  GalleryIconSize galleryIconSize = .medium;

  bool enableMouseDrag;
  bool globalSelection;
  bool forceEdgeSwipePopGesture;

  AdSetting ad;
  PrivacySetting privacy;

  bool showDebugFab;

  DisplaySettings({
    this.showWindowFab = true,
    this.maxWindowWidth,
    this.enableSplitView = true,
    this.splitMasterRatio,
    this.showAccountAtHome = true,
    this.classFilterStyle = SvtListClassFilterStyle.auto,
    this.svtPlanInputMode = SvtPlanInputMode.dropdown,
    this.autoTurnOnPlanNotReach = false,
    this.onlyAppendUnlocked = true,
    this.planPageFullScreen = false,
    List<SvtPlanDetail?>? hideSvtPlanDetails,
    List<SvtTab?>? sortedSvtTabs,
    this.itemDetailViewType = ItemDetailViewType.separated,
    this.itemDetailSvtSort = ItemDetailSvtSort.collectionNo,
    this.itemQuestsSortByAp = true,
    this.showOriginalMissionText = false,
    Map<String, bool>? galleries,
    this.galleryIconSize = .medium,
    this.enableMouseDrag = true,
    this.globalSelection = false,
    this.forceEdgeSwipePopGesture = false,
    AdSetting? ad,
    PrivacySetting? privacy,
    this.showDebugFab = false,
  }) : sortedSvtTabs = sortedSvtTabs?.whereType<SvtTab>().toList() ?? List.of(SvtTab.values),
       hideSvtPlanDetails = hideSvtPlanDetails?.whereType<SvtPlanDetail>().toList() ?? [],
       ad = ad ?? AdSetting(),
       privacy = privacy ?? PrivacySetting(),
       galleries = galleries ?? {} {
    validateSvtTabs();
  }

  void validateSvtTabs() {
    final _unsorted = List.of(sortedSvtTabs);
    sortedSvtTabs = List.of(SvtTab.values);
    sortedSvtTabs.sort2((a) {
      int index = _unsorted.indexOf(a);
      return index >= 0 ? index : SvtTab.values.indexOf(a);
    });
    hideSvtPlanDetails.remove(SvtPlanDetail.activeSkill);
    hideSvtPlanDetails.remove(SvtPlanDetail.appendSkill);
  }

  factory DisplaySettings.fromJson(Map<String, dynamic> data) => _$DisplaySettingsFromJson(data);

  Map<String, dynamic> toJson() => _$DisplaySettingsToJson(this);
}

const int kPrivacyPolicyVersion = 1;

/// Master switch for the consent gate. Temporarily off: no dialog is shown and
/// no consent state is written, so the app starts straight into data loading.
/// Flip to true when the policy text is ready for release.
const bool kPrivacyConsentEnabled = false || kDebugMode;

@JsonSerializable()
class PrivacySetting {
  bool accepted;
  int acceptedVersion;
  bool consentAsked;
  bool crashReportEnabled;
  bool analyticsEnabled;

  PrivacySetting({
    this.accepted = false,
    this.acceptedVersion = 0,
    this.consentAsked = false,
    this.crashReportEnabled = true,
    this.analyticsEnabled = true,
  });

  bool get needsConsent =>
      kPrivacyConsentEnabled && (accepted ? acceptedVersion != kPrivacyPolicyVersion : !consentAsked);

  bool get consentSatisfied => !kPrivacyConsentEnabled || (accepted && acceptedVersion == kPrivacyPolicyVersion);

  factory PrivacySetting.fromJson(Map<String, dynamic> data) => _$PrivacySettingFromJson(data);

  Map<String, dynamic> toJson() => _$PrivacySettingToJson(this);
}

enum PrivacyPermissionGroup { network, files, photos, phone, notifications, install, advertising, other }

@JsonSerializable(createToJson: false)
class PrivacyPermissionDeclaration {
  final String kind;
  final String name;
  @JsonKey(readValue: _readAttributes)
  final Map<String, dynamic> attributes;

  PrivacyPermissionDeclaration({required this.kind, required this.name, required Map<String, dynamic> attributes})
    : attributes = Map.unmodifiable(attributes);

  factory PrivacyPermissionDeclaration.fromJson(Map<String, dynamic> json) =>
      _$PrivacyPermissionDeclarationFromJson(json);

  // Preserve platform-specific and future declaration fields from the flat artifact schema.
  static Object _readAttributes(Map json, String key) => Map<String, dynamic>.from(json)
    ..remove('kind')
    ..remove('name');

  PrivacyPermissionGroup get group {
    // Definitions and unfamiliar names remain visible without inventing a purpose.
    if (kind == 'permission') return PrivacyPermissionGroup.other;
    if (kind == 'background-mode') {
      return name == 'remote-notification' ? PrivacyPermissionGroup.notifications : PrivacyPermissionGroup.other;
    }
    if (kind == 'usage-description') {
      return switch (name) {
        'NSPhotoLibraryAddUsageDescription' => PrivacyPermissionGroup.photos,
        'NSUserTrackingUsageDescription' => PrivacyPermissionGroup.advertising,
        _ => PrivacyPermissionGroup.other,
      };
    }
    if (kind == 'entitlement') {
      if (name == 'com.apple.security.network.client') return PrivacyPermissionGroup.network;
      if (name.startsWith('com.apple.security.files.')) return PrivacyPermissionGroup.files;
      return PrivacyPermissionGroup.other;
    }
    if (kind != 'uses-permission' && kind != 'uses-permission-sdk-23') return PrivacyPermissionGroup.other;
    return switch (name) {
      'android.permission.INTERNET' ||
      'android.permission.ACCESS_NETWORK_STATE' ||
      'android.permission.ACCESS_WIFI_STATE' => PrivacyPermissionGroup.network,
      'android.permission.READ_EXTERNAL_STORAGE' ||
      'android.permission.WRITE_EXTERNAL_STORAGE' => PrivacyPermissionGroup.files,
      'android.permission.READ_PHONE_STATE' => PrivacyPermissionGroup.phone,
      'android.permission.POST_NOTIFICATIONS' ||
      'android.permission.RECEIVE_BOOT_COMPLETED' ||
      'android.permission.SCHEDULE_EXACT_ALARM' ||
      'android.permission.USE_EXACT_ALARM' ||
      'android.permission.USE_FULL_SCREEN_INTENT' ||
      'android.permission.ACCESS_NOTIFICATION_POLICY' => PrivacyPermissionGroup.notifications,
      'android.permission.REQUEST_INSTALL_PACKAGES' => PrivacyPermissionGroup.install,
      'com.google.android.gms.permission.AD_ID' ||
      'com.asus.msa.SupplementaryDID.ACCESS' => PrivacyPermissionGroup.advertising,
      _ => PrivacyPermissionGroup.other,
    };
  }

  String get details => [
    kind,
    for (final entry in attributes.entries)
      '${entry.key}: ${entry.value is String ? entry.value : jsonEncode(entry.value)}',
  ].join('\n');
}

@JsonSerializable(createToJson: false)
class PrivacyPermissionTarget {
  final String platform;
  final String? flavor;
  final String status;
  @JsonKey(name: 'application_id')
  final String? applicationId;
  @JsonKey(name: 'version_name')
  final String? versionName;
  @JsonKey(name: 'build_number')
  final String? buildNumber;
  final List<PrivacyPermissionDeclaration> declarations;

  PrivacyPermissionTarget({
    required this.platform,
    this.flavor,
    required this.status,
    this.applicationId,
    this.versionName,
    this.buildNumber,
    required List<PrivacyPermissionDeclaration> declarations,
  }) : declarations = List.unmodifiable(declarations);

  factory PrivacyPermissionTarget.fromJson(Map<String, dynamic> json) => _$PrivacyPermissionTargetFromJson(json);

  bool get isPartial => status == 'partial';

  Map<PrivacyPermissionGroup, List<PrivacyPermissionDeclaration>> get groups {
    final result = <PrivacyPermissionGroup, List<PrivacyPermissionDeclaration>>{};
    for (final declaration in declarations) {
      (result[declaration.group] ??= []).add(declaration);
    }
    return result;
  }
}

@JsonSerializable(createToJson: false)
class PrivacyPermissionCatalog {
  static const assetPath = 'res/assets/privacy_permissions.json';

  final List<PrivacyPermissionTarget> targets;

  PrivacyPermissionCatalog({required List<PrivacyPermissionTarget> targets}) : targets = List.unmodifiable(targets);

  factory PrivacyPermissionCatalog.fromJson(Map<String, dynamic> json) => _$PrivacyPermissionCatalogFromJson(json);

  factory PrivacyPermissionCatalog.decode(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    if (json['schema_version'] != 1 ||
        json['scope'] != 'package_declarations' ||
        json['runtime_authorization_verified'] != false) {
      throw const FormatException('Unsupported permission catalog');
    }
    return PrivacyPermissionCatalog.fromJson(json);
  }

  PrivacyPermissionTarget? select({
    required String platform,
    required String? flavor,
    required String applicationId,
    required String versionName,
    required String buildNumber,
  }) {
    // A missing Android flavor must not silently become the GitHub or Play inventory.
    if (platform == 'android' && (flavor == null || flavor.isEmpty)) return null;
    final matches = targets.where((target) => target.platform == platform && target.flavor == flavor).toList();
    if (matches.length != 1) return null;
    final target = matches.single;
    if ((target.status != 'inspected' && target.status != 'partial') ||
        target.applicationId != applicationId ||
        target.versionName != versionName ||
        target.buildNumber != buildNumber) {
      return null;
    }
    return target;
  }
}

@JsonSerializable()
class AdSetting {
  /// Local settings never use [AdFeatureState.forcedOn]; that value is server-only.
  AdFeatureState enabled;
  AdFeatureState banner;
  AdFeatureState appOpen;
  AdFeatureState interstitial;

  bool? personalizedAds;
  bool? attAuthorized;
  int lastAttRequestTime;

  int lastAppOpen;

  bool get shouldPersonalizeAds => personalizedAds ?? true;

  bool get canRequestAtt {
    if (attAuthorized != null) return false;
    if (lastAttRequestTime == 0) return true;
    final elapsed = DateTime.now().timestamp - lastAttRequestTime;
    return elapsed > 30 * 24 * 3600;
  }

  AdSetting({
    this.enabled = .defaults,
    this.banner = .defaults,
    this.appOpen = .defaults,
    this.interstitial = .defaults,
    this.personalizedAds,
    this.attAuthorized,
    this.lastAttRequestTime = 0,
    this.lastAppOpen = 0,
  });

  factory AdSetting.fromJson(Map<String, dynamic> data) => _$AdSettingFromJson(data);

  Map<String, dynamic> toJson() => _$AdSettingToJson(this);
}

@JsonSerializable()
class CarouselSetting {
  int? ver;
  int? updateTime;
  List<CarouselItem> items;
  bool enabled;
  bool enableChaldea;
  bool enableMooncell;
  bool enableJP;
  bool enableCN;
  bool enableNA;
  bool enableTW;
  bool enableKR;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool needUpdate = false;

  CarouselSetting({
    this.ver,
    this.updateTime,
    List<CarouselItem>? items,
    this.enabled = true,
    this.enableChaldea = true,
    this.enableMooncell = false,
    this.enableJP = false,
    this.enableCN = false,
    this.enableNA = false,
    this.enableTW = false,
    // KR is blocked in CN, thus disable it by default
    this.enableKR = false,
  }) : items = items ?? [] {
    enabled = true;
    if (ver == null) {
      enableJP = enableCN = enableTW = enableNA = enableKR = enableMooncell = false;
      ver = 2;
    }
  }

  List<bool> get options => [enableChaldea, enableMooncell, enableJP, enableCN, enableNA, enableTW, enableKR];

  bool get shouldUpdate {
    if (updateTime == null) return true;
    if (items.isEmpty && options.contains(true)) {
      return true;
    }
    DateTime lastTime = DateTime.fromMillisecondsSinceEpoch(updateTime! * 1000).toUtc(), now = DateTime.now().toUtc();
    int hours = now.difference(lastTime).inHours;
    if (hours > 24 || hours < 0) return true;
    // update at 17:00(+08), 18:00(+09) => 9:00(+00)
    int hour = (9 - lastTime.hour) % 24 + lastTime.hour;
    final time1 = DateTime.utc(lastTime.year, lastTime.month, lastTime.day, hour, 10);
    if (now.isAfter(time1)) return true;
    return false;
  }

  void enableFor(Region region) {
    enableJP = enableCN = enableTW = enableNA = enableKR = enableMooncell = false;
    switch (region) {
      case Region.jp:
        enableJP = true;
        break;
      case Region.cn:
        enableCN = enableMooncell = true;
        break;
      case Region.tw:
        enableTW = true;
        break;
      case Region.na:
        enableNA = true;
        break;
      case Region.kr:
        enableKR = true;
        break;
    }
  }

  factory CarouselSetting.fromJson(Map<String, dynamic> data) => _$CarouselSettingFromJson(data);

  Map<String, dynamic> toJson() => _$CarouselSettingToJson(this);
}

@JsonSerializable()
class CarouselItem {
  // 0-default, 1-sticky
  int type;
  int priority; // if <0, only used for debug
  DateTime startTime;
  DateTime endTime;
  String? title;
  String? title2;
  String? content;
  String? content2;
  String? image;
  String? image2;
  String? link;
  String? link2;
  bool md;
  AppVersion? verMin;
  AppVersion? verMax;
  List<int> eventIds;
  List<int> warIds;
  List<String> summonIds;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Widget? child;
  @JsonKey(includeFromJson: false, includeToJson: false)
  BoxFit? fit;

  static const int defaultPriority = 99999;

  CarouselItem({
    this.type = 0,
    this.priority = CarouselItem.defaultPriority,
    DateTime? startTime,
    DateTime? endTime,
    this.title,
    this.title2,
    this.content,
    this.content2,
    this.image,
    this.image2,
    this.link,
    this.link2,
    this.md = false,
    this.verMin,
    this.verMax,
    List<int>? eventIds,
    List<int>? warIds,
    List<String>? summonIds,
    this.child,
    this.fit,
  }) : startTime = startTime ?? DateTime(2000),
       endTime = endTime ?? DateTime(2099),
       eventIds = eventIds ?? [],
       warIds = warIds ?? [],
       summonIds = summonIds ?? [];

  factory CarouselItem.fromJson(Map<String, dynamic> data) => _$CarouselItemFromJson(data);

  Map<String, dynamic> toJson() => _$CarouselItemToJson(this);

  String? getLink() => Language.isZH ? link2 ?? link : link;
  String? getTitle() => Language.isZH ? title2 ?? title : title;
  String? getContent() => Language.isZH ? content2 ?? content : content;
  String? getImage() => Language.isZH ? image2 ?? image : image;
}

@JsonSerializable()
class GithubSetting {
  String owner;
  String repo;
  String path;
  @JsonKey(fromJson: _readToken, toJson: _writeToken)
  String token;
  String branch;
  String? sha;
  bool indent;

  GithubSetting({
    this.owner = '',
    this.repo = '',
    this.path = '',
    this.token = '',
    this.branch = '',
    this.sha,
    this.indent = false,
  });

  factory GithubSetting.fromJson(Map<String, dynamic> data) => _$GithubSettingFromJson(data);

  Map<String, dynamic> toJson() => _$GithubSettingToJson(this);

  static String _writeToken(String token) {
    return base64Encode(utf8.encode(token).reversed.toList());
  }

  static String _readToken(String token) {
    return utf8.decode(base64Decode(token).reversed.toList());
  }
}

/// true: should should show
/// n>0: show tips after n times entrance
/// n<=0: don't show tips
@JsonSerializable()
class TipsSetting {
  bool starter;
  int servantList;
  int servantDetail;

  TipsSetting({this.starter = true, this.servantList = 2, this.servantDetail = 2});

  factory TipsSetting.fromJson(Map<String, dynamic> json) => _$TipsSettingFromJson(json);

  Map<String, dynamic> toJson() => _$TipsSettingToJson(this);
}

// key: warId
@JsonSerializable()
class EventItemCalcParams {
  Map<int, int> itemCounts;
  List<QuestBonusPlan> bonusPlans;

  EventItemCalcParams({Map<int, int>? itemCounts, List<QuestBonusPlan>? bonusPlans})
    : itemCounts = itemCounts ?? {},
      bonusPlans = bonusPlans ?? [];

  int getItemDemand(int itemId) {
    return max(0, (itemCounts[itemId] ?? 0) - (db.curUser.items[itemId] ?? 0));
  }

  factory EventItemCalcParams.fromJson(Map<String, dynamic> json) => _$EventItemCalcParamsFromJson(json);

  Map<String, dynamic> toJson() => _$EventItemCalcParamsToJson(this);
}

@JsonSerializable()
class QuestBonusPlan {
  bool enabled = true;
  int questId;
  int index;
  String name;
  Map<int, int> bonus = {};

  @JsonKey(includeFromJson: false, includeToJson: false)
  int ap = 999999;
  @JsonKey(includeFromJson: false, includeToJson: false)
  QuestDropData drops = QuestDropData();

  QuestBonusPlan({this.enabled = true, this.questId = 0, this.index = 0, this.name = "", Map<int, int>? bonus})
    : bonus = bonus ?? {};

  int getBonus(int itemId) => bonus[itemId] ?? 0;

  factory QuestBonusPlan.fromJson(Map<String, dynamic> json) => _$QuestBonusPlanFromJson(json);

  Map<String, dynamic> toJson() => _$QuestBonusPlanToJson(this);

  String getName({bool withName = true, bool withLv = false}) {
    String s = Quest.getName(questId);
    final quest = db.gameData.quests[questId];
    if (withLv && quest != null) s = 'Lv.${quest.recommendLv} $s';
    if (index == 0) return s;
    s += ' @$index';
    if (withName && name.isNotEmpty) s += ' ($name)';
    return s;
  }

  QuestBonusPlan copy(int index) {
    return QuestBonusPlan(enabled: enabled, questId: questId, index: index, bonus: Map.of(bonus))
      ..ap = ap
      ..drops = drops;
  }
}

@JsonSerializable()
class MasterMissionOptions {
  Set<int> blacklist;
  bool excludeRandomEnemyQuests;

  MasterMissionOptions({Set<int>? blacklist, this.excludeRandomEnemyQuests = false}) : blacklist = blacklist ?? {};

  factory MasterMissionOptions.fromJson(Map<String, dynamic> json) => _$MasterMissionOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$MasterMissionOptionsToJson(this);
}

@JsonSerializable()
class _MiscSettings {
  int launchTimes;
  int lastLaunchTime;
  int lastBackup;

  // CharaFigure
  Set<int> nonSvtCharaFigureIds;
  Map<int, int> markedCharaFigureSvtIds;
  Set<String> nonSvtCharaImageIds;
  Map<String, int> markedCharaImageSvtIds;

  _MiscSettings({
    this.launchTimes = 0,
    this.lastLaunchTime = 0,
    this.lastBackup = 0,
    Set<int>? nonSvtCharaFigureIds,
    Map<int, int>? markedCharaFigureSvtIds,
    Set<String>? nonSvtCharaImageIds,
    Map<String, int>? markedCharaImageSvtIds,
  }) : nonSvtCharaFigureIds = nonSvtCharaFigureIds ?? <int>{},
       markedCharaFigureSvtIds = markedCharaFigureSvtIds ?? {},
       nonSvtCharaImageIds = nonSvtCharaImageIds ?? <String>{},
       markedCharaImageSvtIds = markedCharaImageSvtIds ?? {};

  factory _MiscSettings.fromJson(Map<String, dynamic> json) => _$MiscSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$MiscSettingsToJson(this);
}

@JsonSerializable()
class _SecretsData {
  final ChaldeaUser user;
  String? explorerAuth;
  String atlasReloadKey;
  String atlasExportKey;

  _SecretsData({ChaldeaUser? user, this.explorerAuth, this.atlasReloadKey = "", this.atlasExportKey = ""})
    : user = user ?? ChaldeaUser();

  bool get isLoggedIn => user.accessToken?.isNotEmpty == true;

  factory _SecretsData.fromJson(Map<String, dynamic> json) => _$SecretsDataFromJson(json);

  Map<String, dynamic> toJson() => _$SecretsDataToJson(this);
}

@JsonSerializable()
class BookmarkHistory {
  List<BookmarkEntry> bookmarks;

  BookmarkHistory({List<BookmarkEntry>? bookmarks}) : bookmarks = bookmarks ?? [];

  factory BookmarkHistory.fromJson(Map<String, dynamic> json) => _$BookmarkHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$BookmarkHistoryToJson(this);
}

@JsonSerializable()
class BookmarkEntry {
  String? name;
  String url;
  int createdAt;

  BookmarkEntry({this.name, required this.url, int? createdAt}) : createdAt = createdAt ?? DateTime.now().timestamp;

  factory BookmarkEntry.fromJson(Map<String, dynamic> json) => _$BookmarkEntryFromJson(json);

  Map<String, dynamic> toJson() => _$BookmarkEntryToJson(this);
}

enum SvtListClassFilterStyle {
  auto,
  singleRow,
  singleRowExpanded, // scrollable
  twoRow,
  doNotShow;

  String get shownName => switch (this) {
    auto => S.current.svt_class_filter_auto,
    singleRow => S.current.svt_class_filter_single_row,
    singleRowExpanded => S.current.svt_class_filter_single_row_expanded,
    twoRow => S.current.svt_class_filter_two_row,
    doNotShow => S.current.svt_class_filter_hide,
  };
}

enum SvtTab { plan, skill, np, info, spDmg, lore, illustration, relatedCards, summon, voice, quest }

enum SvtPlanDetail {
  ascension,
  activeSkill,
  appendSkill,
  costume,
  coin,
  grail,
  noblePhantasm,
  fou5,
  fou4,
  fou3,
  bondLimit,
  commandCode,
}

enum SvtPlanInputMode {
  dropdown,
  slider,
  // input,
}

enum ItemDetailViewType { separated, grid, list }

enum ItemDetailSvtSort { collectionNo, clsName, rarity }

enum ColorSeed {
  baseColor('M3 Baseline', Color(0xff6750a4)),
  indigo('Indigo', Colors.indigo),
  blue('Blue', Colors.blue),
  teal('Teal', Colors.teal),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  orange('Orange', Colors.orange),
  deepOrange('Deep Orange', Colors.deepOrange),
  pink('Pink', Colors.pink);

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}

enum GalleryIconSize {
  small,
  medium,
  large;

  String get zhName => switch (this) {
    small => '小',
    medium => '中',
    large => '大',
  };
}
