import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/extension.dart';
import 'ad_stub.dart' if (dart.library.io) 'ad_mobile.dart' if (dart.library.js) 'ad_web.dart';
import 'interface.dart';

export 'interface.dart';

/// Global entry point for ad services
/// Unified management of ad SDK initialization, configuration, and invocation
///
/// Decision priority (handled uniformly by AdFeatureDecision.shouldEnable):
/// 1. Remote forcedOn → Force enabled (ignore local settings)
/// 2. Remote off → Force disabled (ignore local settings)
/// 3. Local off → Disabled (user explicitly turned off)
/// 4. Local on → Enabled
/// 5. Both defaults → Use app built-in default value
class AppAds {
  const AppAds._();

  /// Ad implementation instance (auto-selected based on platform)
  static final instance = AppAdImpl();

  /// Whether initialization has completed
  static bool _initiated = false;

  /// Initialize ad SDK
  static Future<void> init() async {
    if (_initiated) return;
    if (!_isPrivacyPolicyAccepted()) return;
    if (!isAdsEnabled) return;

    await Future.delayed(const Duration(milliseconds: 300));
    await instance.init();
    _initiated = true;
  }

  /// Check if privacy policy has been accepted
  static bool _isPrivacyPolicyAccepted() {
    return db.settings.display.ad.privacyPolicyAccepted;
  }

  /// Set privacy policy acceptance status
  static void setPrivacyPolicyAccepted(bool accepted) {
    db.settings.display.ad.privacyPolicyAccepted = accepted;
  }

  /// Whether ads are enabled (combined judgment of local and remote configurations)
  /// Uses AdFeatureDecision for unified decision making
  static bool get isAdsEnabled {
    if (!kDebugMode) return false;
    return AdFeatureDecision.shouldEnable(
      db.settings.remoteConfig.ad.enabled,
      db.settings.display.ad.enabled,
      fallback: false, // Ads are disabled by default (requires explicit remote or local enable)
    );
  }

  /// Whether personalized ads are allowed
  static bool get shouldPersonalizeAds {
    final remoteConfig = db.settings.remoteConfig.ad;
    if (remoteConfig.forceNonPersonalized) return false;
    return db.settings.display.ad.shouldPersonalizeAds;
  }

  /// Whether ads can be shown (platform supported, SDK initialized, and ads enabled)
  static bool get canShowAds => instance.supported && instance.initialized && isAdsEnabled;

  /// Whether banner ad should be shown
  static bool shouldShowBannerAd(BuildContext? context) {
    if (!canShowAds || !instance.supportBannerAd) return false;
    // Use AdFeatureDecision for decision making
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

  /// Whether app open ad should be shown
  static bool shouldShowAppOpenAd() {
    if (!canShowAds || !instance.supportAppOpenAd) return false;
    if (!AdFeatureDecision.shouldEnable(
      db.settings.remoteConfig.ad.appOpenEnabled,
      db.settings.display.ad.appOpen,
      fallback: true,
    )) {
      return false;
    }
    // Frequency limit
    final minInterval = db.settings.remoteConfig.ad.appOpenMinInterval;
    if (minInterval > 0) {
      final lastShow = db.settings.display.ad.lastAppOpen;
      if (DateTime.now().timestamp - lastShow < minInterval) return false;
    }
    return true;
  }

  /// Whether interstitial ad should be shown
  static bool shouldShowInterstitialAd() {
    if (!canShowAds || !instance.supportInterstitialAd) return false;
    return AdFeatureDecision.shouldEnable(
      db.settings.remoteConfig.ad.interstitialEnabled,
      db.settings.display.ad.interstitial,
      fallback: true,
    );
  }

  /// Get banner ad display frequency
  static int get bannerFrequency => db.settings.remoteConfig.ad.bannerFrequency;

  /// Show app open ad if conditions allow
  static Future<void> showAppOpenAd() async {
    if (shouldShowAppOpenAd()) {
      await instance.showAppOpenAdIfAvailable();
    }
  }

  /// Show interstitial ad
  static Future<void> showInterstitialAd(String posId) async {
    if (shouldShowInterstitialAd()) {
      await instance.showInterstitialAd(posId);
    }
  }

  /// Set ad event listener
  static void setAdEventListener(AdEventCallback? callback) {
    instance.setAdEventListener(callback);
  }

  /// Request ATT permission (iOS only)
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

  /// Callback when personalized ads setting changes
  static void onPersonalizedAdsChanged(bool enabled) {
    _initiated = false;
    init();
  }
}

/// Banner ad widget
class BannerAdWidget extends StatelessWidget {
  final AdOptions options;
  final WidgetBuilder? placeholder;

  BannerAdWidget({super.key, required this.options, this.placeholder});

  @override
  Widget build(BuildContext context) {
    return AppAds.instance.buildBanner(context, options, placeholder);
  }
}
