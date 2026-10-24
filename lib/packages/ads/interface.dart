import 'package:material_ui/material_ui.dart';

import 'package:chaldea/models/userdata/remote_config.dart';

class AppAdSize {
  final int width;
  final int height;
  const AppAdSize(this.width, this.height);
}

class AdFeatureDecision {
  AdFeatureDecision._();

  /// Remote `forcedOn`/`off` wins; otherwise local state, then [fallback].
  static bool shouldEnable(AdFeatureState remoteState, AdFeatureState localState, {bool fallback = true}) {
    if (remoteState == AdFeatureState.forcedOn) return true;
    if (remoteState == AdFeatureState.off) return false;
    if (localState == AdFeatureState.off) return false;
    if (localState == AdFeatureState.on) return true;
    return fallback;
  }
}

enum AdEventType { loaded, present, exposure, clicked, closed, skipped, completed, error, reward }

class AdEventData {
  final String adId;

  final AdEventType type;

  /// Only for [AdEventType.error].
  final int? errCode;

  /// Only for [AdEventType.error].
  final String? errMsg;

  /// Only for [AdEventType.reward].
  final bool? rewardVerify;

  /// Only for [AdEventType.reward].
  final int? rewardAmount;

  /// Only for [AdEventType.reward].
  final String? rewardName;

  const AdEventData({
    required this.adId,
    required this.type,
    this.errCode,
    this.errMsg,
    this.rewardVerify,
    this.rewardAmount,
    this.rewardName,
  });

  @override
  String toString() {
    return 'AdEventData(adId: $adId, type: $type, errCode: $errCode, errMsg: $errMsg)';
  }
}

typedef AdEventCallback = void Function(AdEventData event);

class AdsConfig {
  AdsConfig._();

  static const String appId = 'YOUR_GROMORE_APP_ID';
}

class AdOptions {
  final String name;

  final AppAdSize size;

  /// Universal id; platform-specific ids take precedence.
  final String? posId;

  final String? androidPosId;

  final String? iosPosId;

  /// Google AdSense id for web.
  final String? webId;

  final bool cached;

  const AdOptions({
    required this.name,
    required this.size,
    this.posId,
    this.androidPosId,
    this.iosPosId,
    this.webId,
    this.cached = true,
  });

  String? effectivePosId({bool isAndroid = false, bool isIOS = false}) {
    if (isAndroid) return androidPosId ?? posId;
    if (isIOS) return iosPosId ?? posId;
    return posId;
  }

  AdOptions copyWith({
    String? name,
    AppAdSize? size,
    String? posId,
    String? androidPosId,
    String? iosPosId,
    String? webId,
    bool? cached,
  }) {
    return AdOptions(
      name: name ?? this.name,
      size: size ?? this.size,
      posId: posId ?? this.posId,
      androidPosId: androidPosId ?? this.androidPosId,
      iosPosId: iosPosId ?? this.iosPosId,
      webId: webId ?? this.webId,
      cached: cached ?? this.cached,
    );
  }

  /// Home page carousel banner ad slot
  static const homeCarousel = AdOptions(
    name: "home-carousel",
    size: AppAdSize(300, 75),
    posId: 'YOUR_GROMORE_BANNER_POS_ID',
    webId: '9573402336',
  );

  /// App open ad slot
  static const appOpen = AdOptions(name: 'app-open', size: AppAdSize(800, 800), posId: 'YOUR_GROMORE_SPLASH_POS_ID');
}

abstract class AppAdInterface {
  bool get supported;

  bool get supportBannerAd;

  bool get supportAppOpenAd;

  bool get supportInterstitialAd;

  bool get initialized;

  Future<void> init();

  Future<void> initAppOpenAd();

  Future<void> showAppOpenAdIfAvailable();

  Future<void> showInterstitialAd(String posId);

  Widget buildBanner(BuildContext context, AdOptions options, WidgetBuilder? placeholder);

  Widget? buildAppOpen(BuildContext context, AdOptions options);

  void setAdEventListener(AdEventCallback? callback);

  /// Returns true/false for the ATT decision, null when not applicable.
  Future<bool?> requestAttPermission();
}
