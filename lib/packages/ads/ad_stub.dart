import 'package:flutter/material.dart';

import './interface.dart';

/// Ad stub implementation for platforms that don't support ads
class AppAdImpl implements AppAdInterface {
  @override
  final bool supported = false;

  @override
  final bool supportBannerAd = false;

  @override
  final bool supportAppOpenAd = false;

  @override
  final bool supportInterstitialAd = false;

  @override
  bool get initialized => false;

  @override
  Future<void> init() => Future.value();

  @override
  Future<void> initAppOpenAd() => Future.value();

  @override
  Future<void> showAppOpenAdIfAvailable() => Future.value();

  @override
  Future<void> showInterstitialAd(String posId) => Future.value();

  @override
  Widget buildBanner(BuildContext context, AdOptions options, WidgetBuilder? placeholder) {
    return placeholder?.call(context) ?? const SizedBox.shrink();
  }

  @override
  Widget? buildAppOpen(BuildContext context, AdOptions options) {
    return null;
  }

  @override
  void setAdEventListener(AdEventCallback? callback) {
    // Stub: Ad events not supported
  }

  @override
  Future<bool?> requestAttPermission() => Future.value(null);
}
