import 'package:flutter/foundation.dart';

import 'package:material_ui/material_ui.dart';

import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/extension.dart';

import 'ad_stub.dart' if (dart.library.io) 'ad_mobile.dart' if (dart.library.js) 'ad_web.dart';
import 'interface.dart';

export 'interface.dart';

class AppAds {
  const AppAds._();

  static final instance = AppAdImpl();

  static bool _initiated = false;

  static Future<void> init() async {
    if (_initiated) return;
    if (!db.settings.display.privacy.consentSatisfied) return;
    if (!isAdsEnabled) return;

    await Future.delayed(const Duration(milliseconds: 300));
    await instance.init();
    _initiated = true;
  }

  static void resetInitState() => _initiated = false;

  static bool get isAdsEnabled {
    if (!kDebugMode) return false;
    return AdFeatureDecision.shouldEnable(
      db.settings.remoteConfig.ad.enabled,
      db.settings.display.ad.enabled,
      fallback: false, // Ads are disabled by default (requires explicit remote or local enable)
    );
  }

  static bool get shouldPersonalizeAds {
    final remoteConfig = db.settings.remoteConfig.ad;
    if (remoteConfig.forceNonPersonalized) return false;
    return db.settings.display.ad.shouldPersonalizeAds;
  }

  static bool get canShowAds =>
      instance.supported && instance.initialized && isAdsEnabled && db.settings.display.privacy.consentSatisfied;

  static bool shouldShowBannerAd(BuildContext? context) {
    if (!canShowAds || !instance.supportBannerAd) return false;
    if (!AdFeatureDecision.shouldEnable(
      db.settings.remoteConfig.ad.bannerEnabled,
      db.settings.display.ad.banner,
      fallback: true,
    )) {
      return false;
    }
    // Page condition: only show on home page
    return context == null || AppRouter.of(context)?.index == 0;
  }

  static bool shouldShowAppOpenAd() {
    if (!canShowAds || !instance.supportAppOpenAd) return false;
    if (!AdFeatureDecision.shouldEnable(
      db.settings.remoteConfig.ad.appOpenEnabled,
      db.settings.display.ad.appOpen,
      fallback: true,
    )) {
      return false;
    }
    final minInterval = db.settings.remoteConfig.ad.appOpenMinInterval;
    if (minInterval > 0) {
      final lastShow = db.settings.display.ad.lastAppOpen;
      if (DateTime.now().timestamp - lastShow < minInterval) return false;
    }
    return true;
  }

  static bool shouldShowInterstitialAd() {
    if (!canShowAds || !instance.supportInterstitialAd) return false;
    return AdFeatureDecision.shouldEnable(
      db.settings.remoteConfig.ad.interstitialEnabled,
      db.settings.display.ad.interstitial,
      fallback: true,
    );
  }

  static int get bannerFrequency => db.settings.remoteConfig.ad.bannerFrequency;

  static Future<void> showAppOpenAd() async {
    if (shouldShowAppOpenAd()) {
      await instance.showAppOpenAdIfAvailable();
    }
  }

  static Future<void> showInterstitialAd(String posId) async {
    if (shouldShowInterstitialAd()) {
      await instance.showInterstitialAd(posId);
    }
  }

  static void setAdEventListener(AdEventCallback? callback) {
    instance.setAdEventListener(callback);
  }

  static Future<bool?> requestAttPermission() async {
    if (!PlatformU.isIOS) return null;
    final setting = db.settings.display.ad;
    if (!setting.canRequestAtt) return setting.attAuthorized;
    final result = await instance.requestAttPermission();
    if (result != null) {
      setting.attAuthorized = result;
      setting.lastAttRequestTime = DateTime.now().timestamp;
    }
    return result;
  }

  static void onPersonalizedAdsChanged(bool enabled) {
    _initiated = false;
    init();
  }
}

class BannerAdWidget extends StatelessWidget {
  final AdOptions options;
  final WidgetBuilder? placeholder;

  BannerAdWidget({super.key, required this.options, this.placeholder});

  @override
  Widget build(BuildContext context) {
    return AppAds.instance.buildBanner(context, options, placeholder);
  }
}
