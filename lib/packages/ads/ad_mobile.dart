import 'package:flutter/material.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:chaldea/models/db.dart';
import '../platform/platform.dart';
import './interface.dart';

class AppAdImpl implements AppAdInterface {
  @override
  final bool supported = (PlatformU.isAndroid || PlatformU.isIOS) && db.settings.launchTimes > 5;
  bool _initialized = false;
  @override
  bool get initialized => _initialized;

  @override
  Future<void> init() async {
    if (supported) {
      await MobileAds.instance.initialize();
      _initialized = true;
    }
    return;
  }

  @override
  Widget build(BuildContext context, AdOptions options, WidgetBuilder? placeholder) {
    if (!_initialized) {
      return placeholder?.call(context) ?? const SizedBox.shrink();
    }
    return _BannerAdWidget(options: options, placeholder: placeholder);
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
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
          _loadedAds.remove(key);
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
