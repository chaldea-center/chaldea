import 'package:flutter/material.dart';

import './interface.dart';

class AppAdImpl implements AppAdInterface {
  @override
  final bool supported = false;
  @override
  final bool supportBannerAd = false;
  @override
  final bool supportAppOpenAd = false;
  @override
  bool get initialized => false;
  @override
  Future<void> init() => Future.value();
  @override
  Future<void> initAppOpenAd() => Future.value();

  @override
  Widget buildBanner(BuildContext context, AdOptions options, WidgetBuilder? placeholder) {
    return placeholder?.call(context) ?? const SizedBox.shrink();
  }

  @override
  Widget? buildAppOpen(BuildContext context, AdOptions options) {
    return null;
  }
}
