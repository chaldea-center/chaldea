import 'package:chaldea/utils/utils.dart';
import '../db.dart';
import '_helper.dart';
import 'local_settings.dart';
import 'version.dart';

part '../../generated/models/userdata/remote_config.g.dart';

@JsonSerializable()
class RemoteConfig {
  List<String> blockedCarousels;
  List<String> blockedErrors;
  ServerUrlConfig urls;
  int silenceStart;
  int silenceEnd;
  AdConfig ad;
  VersionConstraintsSetting? versionConstraints;

  RemoteConfig({
    this.blockedCarousels = const [],
    this.blockedErrors = const [],
    ServerUrlConfig? urls,
    this.silenceStart = 0,
    this.silenceEnd = 0,
    AdConfig? ad,
    this.versionConstraints,
  }) : urls = urls ?? ServerUrlConfig(),
       ad = ad ?? AdConfig();

  factory RemoteConfig.fromJson(Map<String, dynamic> data) => _$RemoteConfigFromJson(data);

  Map<String, dynamic> toJson() => _$RemoteConfigToJson(this);

  bool get isSilence {
    final now = DateTime.now().timestamp;
    return now >= silenceStart && now <= silenceEnd;
  }
}

@JsonSerializable()
class ServerUrlConfig {
  final UrlProxy app = UrlProxy(src: UrlProxy._(), kGlobal: Hosts0.kAppHostGlobal, kCN: Hosts0.kAppHostCN);
  UrlProxy api;
  UrlProxy worker;
  UrlProxy data;
  UrlProxy atlasApi;
  UrlProxy atlasAsset;

  ServerUrlConfig({UrlProxy? api, UrlProxy? worker, UrlProxy? data, UrlProxy? atlasApi, UrlProxy? atlasAsset})
    : api = UrlProxy(src: api, kGlobal: Hosts0.kApiHostGlobal, kCN: Hosts0.kApiHostCN),
      worker = UrlProxy(src: worker, kGlobal: Hosts0.kWorkerHostGlobal, kCN: Hosts0.kWorkerHostCN),
      data = UrlProxy(src: data, kGlobal: Hosts0.kDataHostGlobal, kCN: Hosts0.kDataHostCN),
      atlasApi = UrlProxy(src: atlasApi, kGlobal: Hosts0.kAtlasApiHostGlobal, kCN: Hosts0.kAtlasApiHostCN),
      atlasAsset = UrlProxy(src: atlasAsset, kGlobal: Hosts0.kAtlasAssetHostGlobal, kCN: Hosts0.kAtlasAssetHostCN);

  factory ServerUrlConfig.fromJson(Map<String, dynamic> data) => _$ServerUrlConfigFromJson(data);

  Map<String, dynamic> toJson() => _$ServerUrlConfigToJson(this);
}

@JsonSerializable(constructor: '_')
class UrlProxy {
  final String? _global;
  final String? _cn;

  final String kGlobal;
  final String kCN;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final String Function(String url)? _post;

  String get global => of(false);
  String get cn => of(true);

  UrlProxy._({String? global, String? cn})
    : _global = _check(global),
      _cn = _check(cn),
      kGlobal = "",
      kCN = "",
      _post = null;

  UrlProxy({required UrlProxy? src, required this.kGlobal, required this.kCN, this._post})
    : _global = _check(src?.global),
      _cn = _check(src?.cn);

  String of(bool proxy) {
    String url = proxy ? (_cn ?? kCN) : (_global ?? kGlobal);
    if (_post != null) url = _post(url);
    return url;
  }

  static String? _check(String? url) {
    if (url == null) return null;
    final uri = Uri.tryParse(url);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) return url;
    return null;
  }

  factory UrlProxy.fromJson(Map<String, dynamic> data) => _$UrlProxyFromJson(data);

  Map<String, dynamic> toJson() {
    final map = _$UrlProxyToJson(this);
    if (_global == null) map.remove('global');
    if (_cn == null) map.remove('cn');
    return map;
  }
}

@JsonSerializable()
class AdConfig {
  /// 广告全局状态（服务器端控制）
  /// 值为 AdFeatureState 枚举的 value 字符串：defaults/on/off/forced_on
  AdFeatureState enabled;

  /// Banner广告状态
  AdFeatureState bannerEnabled;

  /// 开屏广告状态
  AdFeatureState appOpenEnabled;

  /// 插屏广告状态
  AdFeatureState interstitialEnabled;

  /// 开屏广告最小展示间隔（秒），默认7200秒（2小时）
  int appOpenMinInterval;

  /// Banner广告展示频率：每N个轮播项展示1个Banner，0=不限制
  int bannerFrequency;

  /// 插屏广告最小展示间隔（秒），0=不限制
  int interstitialMinInterval;

  /// 是否强制使用非个性化广告（合规紧急开关）
  bool forceNonPersonalized;

  AdConfig({
    this.enabled = .defaults,
    this.bannerEnabled = .defaults,
    this.appOpenEnabled = .defaults,
    this.interstitialEnabled = .defaults,
    this.appOpenMinInterval = 7200,
    this.bannerFrequency = 0,
    this.interstitialMinInterval = 0,
    this.forceNonPersonalized = false,
  });

  factory AdConfig.fromJson(Map<String, dynamic> data) => _$AdConfigFromJson(data);

  Map<String, dynamic> toJson() => _$AdConfigToJson(this);

  // ===== 状态枚举便捷访问 =====
  // AdFeatureState 定义在 packages/ads/interface.dart
  // 此处通过字符串值与枚举互转，避免 json_serializable 跨包类型问题

  /// 广告全局状态枚举
  // AdFeatureState get enabledState => AdFeatureState.fromValue(enabled);

  // /// Banner广告状态枚举
  // AdFeatureState get bannerEnabledState => AdFeatureState.fromValue(bannerEnabled);

  // /// 开屏广告状态枚举
  // AdFeatureState get appOpenEnabledState => AdFeatureState.fromValue(appOpenEnabled);

  // /// 插屏广告状态枚举
  // AdFeatureState get interstitialEnabledState => AdFeatureState.fromValue(interstitialEnabled);
}

/// 广告功能状态枚举
/// 用于远程配置和本地设置中的广告开关控制
///
/// 状态优先级（从高到低）：
/// forcedOn > off > on > defaults
///
/// 决策规则：
/// - 远程配置的 forcedOn/off 优先于本地设置
/// - 本地设置仅能控制 on/defaults，不能覆盖远程的 forcedOn/off
/// - defaults 表示未设置，遵循应用内置默认策略
enum AdFeatureState {
  /// 默认状态：遵循应用内置策略
  /// 本地设置：未显式设置，使用默认值
  /// 远程配置：未配置，由本地设置决定
  defaults(0),

  /// 开启：启用广告功能
  /// 本地设置：用户主动开启
  /// 远程配置：服务器端开启
  on(1),

  /// 关闭：禁用广告功能
  /// 本地设置：用户主动关闭
  /// 远程配置：服务器端关闭
  off(2),

  /// 强制开启：无视本地用户配置强制启用广告
  /// 仅远程配置可使用此状态
  /// 场景：合规要求、运营策略等需要确保广告展示
  forcedOn(3);

  const AdFeatureState(this.code);

  /// 序列化值（用于JSON存储和API交互）
  // final String value;

  /// 数字编码（用于紧凑存储和快速比较）
  final int code;

  /// 从序列化值解析
  static AdFeatureState fromValue(String? value) {
    if (value == null) return defaults;
    return AdFeatureState.values.firstWhere((e) => e.name == value, orElse: () => defaults);
  }

  /// 从数字编码解析
  static AdFeatureState fromCode(int? code) {
    if (code == null) return defaults;
    return AdFeatureState.values.firstWhere((e) => e.code == code, orElse: () => defaults);
  }

  /// 是否为启用状态（on 或 forcedOn）
  bool get isEnabled => this == on || this == forcedOn;

  /// 是否为禁用状态
  bool get isDisabled => this == off;

  /// 是否为强制状态
  bool get isForced => this == forcedOn;

  /// 是否为默认状态（未设置）
  bool get isDefault => this == defaults;
}

class HostsX {
  const HostsX._();
  static ServerUrlConfig get _config => db.settings.remoteConfig.urls;
  static ProxySettings get proxy => db.settings.proxy;

  static UrlProxy get app => _config.app;
  static String get appHost => _config.app.of(proxy.data);

  static UrlProxy get api => _config.api;
  static String get apiHost => _config.api.of(proxy.api);

  static UrlProxy get worker => _config.worker;
  static String get workerHost => _config.worker.of(proxy.worker);

  static UrlProxy get data => _config.data;
  static String get dataHost => _config.data.of(proxy.data);

  static UrlProxy get atlasApi => _config.atlasApi;
  static String get atlasApiHost => _config.atlasApi.of(proxy.atlasApi);

  static UrlProxy get atlasAsset => _config.atlasAsset;
  static String get atlasAssetHost {
    // if (kIsWeb || !proxy) return atlasAsset.global;
    // return _config.atlasAsset.of(Random().nextInt(10) > 6);
    return atlasAsset.of(proxy.atlasAsset);
  }

  static String proxyWorker(String url, {bool onlyCN = true}) {
    if (onlyCN && !proxy.worker) {
      return url;
    }
    return Uri.parse(workerHost).replace(path: '/proxy/custom', queryParameters: {'url': url}).toString();
  }

  static String corsProxy(String url) {
    return Uri.parse(HostsX.workerHost).replace(path: '/corsproxy/', queryParameters: {'url': url}).toString();
  }
}

class Hosts0 {
  const Hosts0._();

  static const kAppHostGlobal = 'https://chaldea.center';
  static const kAppHostCN = 'https://cn.chaldea.center';

  static const kDeepLink = 'https://link.chaldea.center';

  static const kApiHostGlobal = 'https://api.chaldea.center';
  static const kApiHostCN = 'https://api-cn.chaldea.center';

  static const kWorkerHostGlobal = 'https://worker.chaldea.center';
  static const kWorkerHostCN = 'https://worker-cn.chaldea.center';

  // FireFox may send OPTIONS request which cf pages denied
  @protected
  static const kDataHostGlobal = 'https://data.chaldea.center';
  static const kDataHostCN = 'https://data-cn.chaldea.center';

  static const kAtlasApiHostGlobal = 'https://api.atlasacademy.io';
  static const kAtlasApiHostCN = 'https://api.atlas.chaldea.center';

  static const kAtlasAssetHostGlobal = 'https://static.atlasacademy.io';
  static const kAtlasAssetHostCN = 'https://static.atlas.chaldea.center';
}
