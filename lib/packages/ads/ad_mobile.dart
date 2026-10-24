import 'package:flutter_gromore_ads/flutter_gromore_ads.dart';
import 'package:material_ui/material_ui.dart';

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
      await _requestPermissions();
      FlutterGromoreAds.onEventListener(_handleAdEvent);
      final limitPersonalAds = _shouldPersonalizeAds ? 0 : 1;
      final result = await FlutterGromoreAds.initAd(AdsConfig.appId, limitPersonalAds: limitPersonalAds);

      if (result) {
        _initialized = true;
        debugPrint('GroMore Ads SDK initialized successfully');
        await initAppOpenAd();
      } else {
        debugPrint('GroMore Ads SDK initialization failed');
      }
    } catch (e, s) {
      debugPrint('Ad initialization error: $e\n$s');
    }
  }

  bool get _shouldPersonalizeAds {
    final remoteConfig = db.settings.remoteConfig.ad;
    if (remoteConfig.forceNonPersonalized) return false;
    return db.settings.display.ad.shouldPersonalizeAds;
  }

  Future<void> _requestPermissions() async {
    try {
      if (PlatformU.isIOS) {
        if (_shouldPersonalizeAds && db.settings.display.ad.canRequestAtt) {
          final result = await FlutterGromoreAds.requestIDFA;
          db.settings.display.ad.attAuthorized = result;
          db.settings.display.ad.lastAttRequestTime = DateTime.now().timestamp;
        }
      } else if (PlatformU.isAndroid) {
        await FlutterGromoreAds.requestPermissionIfNecessary;
      }
    } catch (e) {
      logger.e('Request ad permissions failed: $e');
    }
  }

  void _handleAdEvent(AdEvent event) {
    final eventData = _convertEvent(event);
    if (eventData != null) {
      _eventCallback?.call(eventData);
    }
  }

  AdEventData? _convertEvent(AdEvent event) {
    if (event is AdErrorEvent) {
      return AdEventData(adId: event.adId, type: AdEventType.error, errCode: event.errCode, errMsg: event.errMsg);
    }

    final eventType = _mapActionToType(event.action);
    if (eventType == null) return null;

    return AdEventData(adId: event.adId, type: eventType);
  }

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
    _lifecycleObserver = _AdLifecycleObserver(showAppOpenAdIfAvailable);
    WidgetsBinding.instance.addObserver(_lifecycleObserver!);
  }

  @override
  Future<void> showAppOpenAdIfAvailable() async {
    if (!_initialized) return;
    final adSetting = db.settings.display.ad;
    final remoteAd = db.settings.remoteConfig.ad;
    if (!AdFeatureDecision.shouldEnable(remoteAd.appOpenEnabled, adSetting.appOpen, fallback: true)) {
      return;
    }
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
    // Splash ads are shown imperatively, no widget needed.
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
  bool _loadFailed = false;

  static final Map<String, bool> _loadedAds = {};

  static final Map<String, DateTime> _loadFailedAds = {};

  @override
  void initState() {
    super.initState();
    _checkCache();
  }

  void _checkCache() {
    final failedTime = _loadFailedAds[widget.posId];
    if (failedTime != null && DateTime.now().isBefore(failedTime.add(const Duration(minutes: 10)))) {
      _loadFailed = true;
    }
  }

  String get _cacheKey => '${widget.posId}-${widget.width}-${widget.height}';

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) {
      return widget.placeholder?.call(context) ?? const SizedBox.shrink();
    }

    final size = Size(widget.width.toDouble(), widget.height.toDouble());

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          if (_loadedAds[_cacheKey] != true && widget.placeholder != null)
            Positioned.fill(child: widget.placeholder!(context)),
          AdBannerWidget(posId: widget.posId, width: widget.width, height: widget.height, show: true),
        ],
      ),
    );
  }
}
