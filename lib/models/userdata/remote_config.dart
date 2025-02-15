import 'package:chaldea/utils/utils.dart';
import '../db.dart';
import '_helper.dart';
import 'local_settings.dart';

part '../../generated/models/userdata/remote_config.g.dart';

@JsonSerializable()
class RemoteConfig {
  String? forceUpgradeVersion;
  List<String> blockedCarousels;
  List<String> blockedErrors;
  ServerUrlConfig urls;
  int silenceStart;
  int silenceEnd;
  AdConfig ad;

  RemoteConfig({
    this.forceUpgradeVersion,
    this.blockedCarousels = const [],
    this.blockedErrors = const [],
    ServerUrlConfig? urls,
    this.silenceStart = 0,
    this.silenceEnd = 0,
    AdConfig? ad,
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
      atlasAsset = UrlProxy(src: atlasApi, kGlobal: Hosts0.kAtlasAssetHostGlobal, kCN: Hosts0.kAtlasAssetHostCN);

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

  UrlProxy._({String? global, String? cn})
    : _global = _check(global),
      _cn = _check(cn),
      kGlobal = "",
      kCN = "",
      _post = null;

  UrlProxy({required UrlProxy? src, required this.kGlobal, required this.kCN, String Function(String url)? post})
    : _global = _check(src?.global),
      _cn = _check(src?.cn),
      _post = post;

  String get global => of(false);
  String get cn => of(true);

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

  Map<String, dynamic> toJson() => _$UrlProxyToJson(this);
}

@JsonSerializable()
class AdConfig {
  bool enabled;

  AdConfig({this.enabled = false});

  factory AdConfig.fromJson(Map<String, dynamic> data) => _$AdConfigFromJson(data);

  Map<String, dynamic> toJson() => _$AdConfigToJson(this);
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
