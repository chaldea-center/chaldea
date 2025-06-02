import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/extension.dart';
import '../platform/platform.dart';
import './interface.dart';

class AppAdImpl implements AppAdInterface {
  @override
  final bool supported = (PlatformU.isAndroid || PlatformU.isIOS) && db.settings.launchTimes > 5 && false;
  @override
  late final bool supportBannerAd = supported;
  @override
  late final bool supportAppOpenAd = supported;
  bool _initialized = false;
  @override
  bool get initialized => _initialized;

  @override
  Future<void> init() async {
    if (supported) {
      await MobileAds.instance.initialize();
      _initialized = true;
      initAppOpenAd();
    }
    return;
  }

  @override
  Widget buildBanner(BuildContext context, AdOptions options, WidgetBuilder? placeholder) {
    if (!_initialized) {
      return placeholder?.call(context) ?? const SizedBox.shrink();
    }
    return _BannerAdWidget(options: options, placeholder: placeholder);
  }

  /// App Open Ad
  @override
  Future<void> initAppOpenAd() async {
    loadAppOpenAd();
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((AppState appState) {
      debugPrint('New AppState state: $appState');
      if (appState == AppState.foreground) {
        showAppOpenAdIfAvailable();
      }
    });
  }

  AppOpenAd? _appOpenAd;
  bool _isShowingAppOpenAd = false;
  DateTime? _appOpenLoadTime;
  DateTime? _lastAppOpenShowTime;
  int _appOpenAdLoadedCount = 0;

  void loadAppOpenAd() {
    final adUnitId = PlatformU.isAndroid
        ? AdOptions.appOpen.androidId
        : PlatformU.isIOS
        ? AdOptions.appOpen.iosId
        : null;
    if (adUnitId == null) return;
    if (!db.settings.display.ad.shouldShowAppOpen) return;
    print("loading app open ad $adUnitId...");
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          print('app open ad loaded: $ad');
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
          // Handle the error.
        },
      ),
    );
  }

  void showAppOpenAdIfAvailable() {
    print("showAppOpenAdIfAvailable...");
    if (!db.settings.display.ad.shouldShowAppOpen) return;
    if (_appOpenLoadTime != null &&
        _appOpenAd != null &&
        DateTime.now().isAfter(_appOpenLoadTime!.add(const Duration(hours: 4)))) {
      _appOpenAd!.dispose();
      _appOpenAd = null;
      return;
    }
    if (_isShowingAppOpenAd) return;
    final appOpenAd = _appOpenAd;
    if (appOpenAd == null) {
      loadAppOpenAd();
      return;
    }
    if (!kDebugMode &&
        _lastAppOpenShowTime != null &&
        DateTime.now().isBefore(_appOpenLoadTime!.add(const Duration(minutes: 10)))) {
      return;
    }
    if (_appOpenAdLoadedCount > 1) return;
    appOpenAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAppOpenAd = true;
        _appOpenAdLoadedCount += 1;
        print('$ad onAdShowedFullScreenContent');
        // const showingDuration = Duration(seconds: 3);
        // Future.delayed(showingDuration, () {
        //   if (_appOpenAd == appOpenAd && _isShowingAd) {
        //     print('dispose app open ad after $showingDuration');
        //     appOpenAd.dispose();
        //     _isShowingAd = false;
        //     _appOpenAd = null;
        //   }
        // });
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );
    appOpenAd.show();
    db.settings.display.ad.lastAppOpen = DateTime.now().timestamp;
    _lastAppOpenShowTime = DateTime.now();
  }

  @override
  Widget? buildAppOpen(BuildContext context, AdOptions options) {
    return null;
  }
}

class _BannerAdWidget extends StatefulWidget {
  final AdOptions options;
  final WidgetBuilder? placeholder;
  _BannerAdWidget({required this.options, this.placeholder});

  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  String? get adUnitId => PlatformU.isAndroid
      ? widget.options.androidId
      : PlatformU.isIOS
      ? widget.options.iosId
      : null;

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  // Ensure only one Ad in widget tree, otherwise create new instance
  static final Map<String, BannerAd> _loadedAds = {};
  static final Map<String, DateTime> _loadFailedAds = {};

  void loadAd() {
    final adId = adUnitId;
    if (adId == null) return;
    _isLoaded = false;
    final options = widget.options;
    final size = options.size;
    String key = '$adId-${size.width}-${size.height}';
    if (options.cached && _loadedAds[key] != null) {
      _bannerAd = _loadedAds[key]!;
      _isLoaded = true;
      return;
    }
    final lastFailed = _loadFailedAds[adId];
    if (lastFailed != null && DateTime.now().isBefore(lastFailed.add(const Duration(minutes: 10)))) {
      return;
    }
    _bannerAd = BannerAd(
      adUnitId: adId,
      request: const AdRequest(),
      size: AdSize(width: size.width, height: size.height),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // debugPrint('${ad.adUnitId} loaded.');
          if (mounted) {
            setState(() {
              _isLoaded = true;
              if (options.cached && ad is BannerAd) {
                _loadedAds[key] = ad;
              }
            });
          }
          _loadFailedAds.remove(ad.adUnitId);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
          _loadedAds.remove(key);
          _loadFailedAds[ad.adUnitId] = DateTime.now();
          if (mounted) setState(() {});
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;
    if (ad == null || !_isLoaded) {
      return widget.placeholder?.call(context) ?? const SizedBox.shrink();
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
