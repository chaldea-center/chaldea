import 'package:flutter/material.dart';

import 'package:flutter_gromore_ads/flutter_gromore_ads.dart';

import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/extension.dart';
import '../platform/platform.dart';
import './interface.dart';

/// Mobile ad implementation (iOS/Android), based on flutter_gromore_ads SDK
class AppAdImpl implements AppAdInterface {
  @override
  final bool supported = PlatformU.isMobile;

  @override
  late final bool supportBannerAd = supported;

  @override
  late final bool supportAppOpenAd = supported;

  @override
  late final bool supportInterstitialAd = supported;

  bool _initialized = false;

  @override
  bool get initialized => _initialized;

  AdEventCallback? _eventCallback;

  _AdLifecycleObserver? _lifecycleObserver;

  @override
  Future<void> init() async {
    if (!supported) return;
    try {
      // 1. Request platform permissions (only request ATT when personalized ads are allowed)
      await _requestPermissions();

      // 2. Set global ad event listener
      FlutterGromoreAds.onEventListener(_handleAdEvent);

      // 3. Initialize GroMore SDK, pass limitPersonalAds based on personalized ads setting
      final limitPersonalAds = _shouldPersonalizeAds ? 0 : 1;
      final result = await FlutterGromoreAds.initAd(AdsConfig.appId, limitPersonalAds: limitPersonalAds);

      if (result) {
        _initialized = true;
        debugPrint('GroMore Ads SDK initialized successfully');
        // Initialize app open ad listener
        await initAppOpenAd();
      } else {
        debugPrint('GroMore Ads SDK initialization failed');
      }
    } catch (e, s) {
      debugPrint('Ad initialization error: $e\n$s');
    }
  }

  /// Determine if personalized ads are allowed (inline decision logic to avoid circular references)
  bool get _shouldPersonalizeAds {
    final remoteConfig = db.settings.remoteConfig.ad;
    if (remoteConfig.forceNonPersonalized) return false;
    return db.settings.display.ad.shouldPersonalizeAds;
  }

  /// Request platform-related permissions
  /// Only request when user allows personalized ads and ATT is not denied
  Future<void> _requestPermissions() async {
    try {
      if (PlatformU.isIOS) {
        // iOS: Only request ATT when personalized ads are allowed
        if (_shouldPersonalizeAds && db.settings.display.ad.canRequestAtt) {
          final result = await FlutterGromoreAds.requestIDFA;
          db.settings.display.ad.attAuthorized = result;
          db.settings.display.ad.lastAttRequestTime = DateTime.now().timestamp;
        }
      } else if (PlatformU.isAndroid) {
        // Android: Request runtime permissions
        await FlutterGromoreAds.requestPermissionIfNecessary;
      }
    } catch (e) {
      logger.e('Request ad permissions failed: $e');
    }
  }

  /// Handle GroMore ad events, convert to unified AdEventData format
  void _handleAdEvent(AdEvent event) {
    final eventData = _convertEvent(event);
    if (eventData != null) {
      _eventCallback?.call(eventData);
    }
  }

  /// Convert GroMore SDK events to AdEventData
  AdEventData? _convertEvent(AdEvent event) {
    if (event is AdErrorEvent) {
      return AdEventData(adId: event.adId, type: AdEventType.error, errCode: event.errCode, errMsg: event.errMsg);
    }

    final eventType = _mapActionToType(event.action);
    if (eventType == null) return null;

    return AdEventData(adId: event.adId, type: eventType);
  }

  /// Map GroMore event action strings to AdEventType
  AdEventType? _mapActionToType(String action) {
    switch (action) {
      case AdEventAction.onAdLoaded:
        return AdEventType.loaded;
      case AdEventAction.onAdPresent:
        return AdEventType.present;
      case AdEventAction.onAdExposure:
        return AdEventType.exposure;
      case AdEventAction.onAdClicked:
        return AdEventType.clicked;
      case AdEventAction.onAdClosed:
        return AdEventType.closed;
      case AdEventAction.onAdSkip:
        return AdEventType.skipped;
      case AdEventAction.onAdComplete:
        return AdEventType.completed;
      case AdEventAction.onAdReward:
        return AdEventType.reward;
      case AdEventAction.onAdError:
        return AdEventType.error;
      default:
        return null;
    }
  }

  @override
  Future<void> initAppOpenAd() async {
    if (!supported || !_initialized) return;
    // Register app lifecycle observer to listen for foreground/background transitions
    _lifecycleObserver = _AdLifecycleObserver(showAppOpenAdIfAvailable);
    WidgetsBinding.instance.addObserver(_lifecycleObserver!);
  }

  @override
  Future<void> showAppOpenAdIfAvailable() async {
    if (!_initialized) return;
    // Use AdFeatureDecision for unified decision making
    final adSetting = db.settings.display.ad;
    final remoteAd = db.settings.remoteConfig.ad;
    if (!AdFeatureDecision.shouldEnable(remoteAd.appOpenEnabled, adSetting.appOpen, fallback: true)) {
      return;
    }
    // Frequency limit
    final minInterval = remoteAd.appOpenMinInterval;
    if (minInterval > 0) {
      final elapsed = DateTime.now().timestamp - adSetting.lastAppOpen;
      if (elapsed < minInterval) return;
    }

    final posId = AdOptions.appOpen.effectivePosId(isAndroid: PlatformU.isAndroid, isIOS: PlatformU.isIOS);
    if (posId == null) return;

    try {
      debugPrint('Showing splash ad: $posId');
      await FlutterGromoreAds.showSplashAd(posId, timeout: 3.5);
      db.settings.display.ad.lastAppOpen = DateTime.now().timestamp;
    } catch (e) {
      debugPrint('Show splash ad failed: $e');
    }
  }

  @override
  Widget buildBanner(BuildContext context, AdOptions options, WidgetBuilder? placeholder) {
    if (!_initialized) {
      return placeholder?.call(context) ?? const SizedBox.shrink();
    }

    final posId = options.effectivePosId(isAndroid: PlatformU.isAndroid, isIOS: PlatformU.isIOS);
    if (posId == null) {
      return placeholder?.call(context) ?? const SizedBox.shrink();
    }

    return _GromoreBannerAdWidget(
      posId: posId,
      width: options.size.width,
      height: options.size.height,
      placeholder: placeholder,
    );
  }

  @override
  Future<void> showInterstitialAd(String posId) async {
    if (!_initialized) return;
    try {
      debugPrint('Showing interstitial ad: $posId');
      await FlutterGromoreAds.showInterstitialAd(posId);
    } catch (e) {
      debugPrint('Show interstitial ad failed: $e');
    }
  }

  @override
  Widget? buildAppOpen(BuildContext context, AdOptions options) {
    // GroMore splash ads are shown via showSplashAd, no need to build Widget
    return null;
  }

  @override
  void setAdEventListener(AdEventCallback? callback) {
    _eventCallback = callback;
  }

  @override
  Future<bool?> requestAttPermission() async {
    if (!PlatformU.isIOS) return null;
    try {
      final result = await FlutterGromoreAds.requestIDFA;
      return result;
    } catch (e) {
      debugPrint('Request ATT permission failed: $e');
      return null;
    }
  }
}

/// App lifecycle observer for listening to foreground/background transitions to show app open ads
class _AdLifecycleObserver with WidgetsBindingObserver {
  final VoidCallback onForeground;

  _AdLifecycleObserver(this.onForeground);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onForeground();
    }
  }
}

/// GroMore Banner ad wrapper widget
/// Wraps flutter_gromore_ads' AdBannerWidget with placeholder and loading state management
class _GromoreBannerAdWidget extends StatefulWidget {
  final String posId;
  final int width;
  final int height;
  final WidgetBuilder? placeholder;

  const _GromoreBannerAdWidget({required this.posId, required this.width, required this.height, this.placeholder});

  @override
  State<_GromoreBannerAdWidget> createState() => _GromoreBannerAdWidgetState();
}

class _GromoreBannerAdWidgetState extends State<_GromoreBannerAdWidget> {
  /// Whether loading failed (don't retry within 10 minutes after failure)
  bool _loadFailed = false;

  /// Cache loaded banner ad instances (cached by posId + size)
  static final Map<String, bool> _loadedAds = {};

  /// Record failed ad loads (don't retry within 10 minutes)
  static final Map<String, DateTime> _loadFailedAds = {};

  @override
  void initState() {
    super.initState();
    _checkCache();
  }

  /// Check if there's a cached ad
  void _checkCache() {
    final failedTime = _loadFailedAds[widget.posId];
    if (failedTime != null && DateTime.now().isBefore(failedTime.add(const Duration(minutes: 10)))) {
      _loadFailed = true;
    }
  }

  String get _cacheKey => '${widget.posId}-${widget.width}-${widget.height}';

  @override
  Widget build(BuildContext context) {
    // Show placeholder if loading failed and still in cooldown period
    if (_loadFailed) {
      return widget.placeholder?.call(context) ?? const SizedBox.shrink();
    }

    final size = Size(widget.width.toDouble(), widget.height.toDouble());

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Bottom layer: placeholder (shown before/during ad loading)
          if (_loadedAds[_cacheKey] != true && widget.placeholder != null)
            Positioned.fill(child: widget.placeholder!(context)),
          // Top layer: GroMore Banner ad
          AdBannerWidget(posId: widget.posId, width: widget.width, height: widget.height, show: true),
        ],
      ),
    );
  }
}
