import 'package:flutter/material.dart';

import 'package:chaldea/models/userdata/remote_config.dart';

/// Ad size configuration
class AppAdSize {
  final int width;
  final int height;
  const AppAdSize(this.width, this.height);
}

/// Ad feature status decision utility
/// Unified handling of remote config and local settings state merging logic
class AdFeatureDecision {
  AdFeatureDecision._();

  /// Merge remote config and local settings, return final decision state
  ///
  /// Priority rules:
  /// 1. Remote forcedOn → Force enabled (ignore local settings)
  /// 2. Remote off → Force disabled (ignore local settings)
  /// 3. Local off → Disabled (user explicitly turned off)
  /// 4. Local on → Enabled
  /// 5. Both defaults → Use [fallback] default value
  static bool shouldEnable(AdFeatureState remoteState, AdFeatureState localState, {bool fallback = true}) {
    // Remote force enabled → ignore local settings
    if (remoteState == AdFeatureState.forcedOn) return true;
    // Remote disabled → ignore local settings
    if (remoteState == AdFeatureState.off) return false;
    // Local disabled → respect user choice
    if (localState == AdFeatureState.off) return false;
    // Local enabled → enable
    if (localState == AdFeatureState.on) return true;
    // Both default → use fallback
    return fallback;
  }
}

/// Ad event types
enum AdEventType {
  /// Ad loaded successfully
  loaded,

  /// Ad presented
  present,

  /// Ad exposed
  exposure,

  /// Ad clicked
  clicked,

  /// Ad closed
  closed,

  /// Ad skipped (app open ad)
  skipped,

  /// Ad playback/timer completed
  completed,

  /// Ad error
  error,

  /// Reward received (reward video ad)
  reward,
}

/// Ad event data
class AdEventData {
  /// Ad slot ID
  final String adId;

  /// Event type
  final AdEventType type;

  /// Error code (valid only for error type)
  final int? errCode;

  /// Error message (valid only for error type)
  final String? errMsg;

  /// Whether reward is valid (valid only for reward type)
  final bool? rewardVerify;

  /// Reward amount (valid only for reward type)
  final int? rewardAmount;

  /// Reward name (valid only for reward type)
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

/// Ad event callback
typedef AdEventCallback = void Function(AdEventData event);

/// GroMore ad global configuration
class AdsConfig {
  AdsConfig._();

  /// GroMore app ID (apply on Pangle/GroMore platform)
  /// TODO: Replace with actual app ID
  static const String appId = 'YOUR_GROMORE_APP_ID';
}

/// Ad configuration options, defining parameters for each ad slot
class AdOptions {
  /// Ad slot name identifier
  final String name;

  /// Ad size
  final AppAdSize size;

  /// GroMore ad slot ID (universal for mobile, can be overridden by androidPosId/iosPosId)
  final String? posId;

  /// Android-specific GroMore ad slot ID (prioritized over posId)
  final String? androidPosId;

  /// iOS-specific GroMore ad slot ID (prioritized over posId)
  final String? iosPosId;

  /// Web platform ad slot ID (Google AdSense)
  final String? webId;

  /// Whether to cache ad instance
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

  /// Get the effective GroMore ad slot ID for the current platform
  /// Platform-specific IDs are prioritized, followed by the universal posId
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
  /// TODO: Replace posId with actual GroMore banner ad slot ID
  static const homeCarousel = AdOptions(
    name: "home-carousel",
    size: AppAdSize(300, 75),
    posId: 'YOUR_GROMORE_BANNER_POS_ID',
    webId: '9573402336',
  );

  /// App open ad slot
  /// TODO: Replace posId with actual GroMore app open ad slot ID
  static const appOpen = AdOptions(name: 'app-open', size: AppAdSize(800, 800), posId: 'YOUR_GROMORE_SPLASH_POS_ID');
}

/// Ad interface - all platform implementations must follow this interface
abstract class AppAdInterface {
  /// Whether ads are supported on the current platform
  bool get supported;

  /// Whether banner ads are supported
  bool get supportBannerAd;

  /// Whether app open ads are supported
  bool get supportAppOpenAd;

  /// Whether interstitial ads are supported
  bool get supportInterstitialAd;

  /// Whether SDK has been initialized
  bool get initialized;

  /// Initialize ad SDK
  Future<void> init();

  /// Initialize app open ad (set lifecycle listeners, etc.)
  Future<void> initAppOpenAd();

  /// Show app open ad when conditions allow
  Future<void> showAppOpenAdIfAvailable();

  /// Show interstitial ad
  /// [posId] GroMore ad slot ID
  Future<void> showInterstitialAd(String posId);

  /// Build banner ad widget
  Widget buildBanner(BuildContext context, AdOptions options, WidgetBuilder? placeholder);

  /// Build app open ad widget (may return null on some platforms)
  Widget? buildAppOpen(BuildContext context, AdOptions options);

  /// Set ad event listener
  void setAdEventListener(AdEventCallback? callback);

  /// Request ATT permission (iOS only)
  /// Returns: true=authorized, false=denied, null=not supported
  Future<bool?> requestAttPermission();
}
