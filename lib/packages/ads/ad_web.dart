import 'dart:js_interop';
import 'dart:ui_web' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:web/web.dart' as web;

import './interface.dart';

/// Web platform ad implementation
/// Only maintains API-level interface consistency, does not implement actual ad functionality
/// Web platform ad functionality is currently disabled (supported = false)
class AppAdImpl implements AppAdInterface {
  @override
  final bool supported = kIsWeb && false;

  @override
  late final bool supportBannerAd = supported;

  @override
  final bool supportAppOpenAd = false;

  @override
  final bool supportInterstitialAd = false;

  bool _initialized = false;

  @override
  bool get initialized => _initialized;

  @override
  Future<void> init() async {
    if (initialized) return;
    if (supported) {
      // Web platform ad initialization (currently disabled)
      _initialized = true;
    }
    return;
  }

  @override
  Future<void> initAppOpenAd() => Future.value();

  @override
  Future<void> showAppOpenAdIfAvailable() => Future.value();

  @override
  Future<void> showInterstitialAd(String posId) => Future.value();

  @override
  Widget buildBanner(BuildContext context, AdOptions options, WidgetBuilder? placeholder) {
    if (!_initialized) {
      return placeholder?.call(context) ?? const SizedBox.shrink();
    }
    final viewID = options.name;
    ui.platformViewRegistry.registerViewFactory(
      viewID,
      (int id) => web.HTMLIFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..srcdoc =
            '''
<amp-ad width="100vw" height="320"
     type="adsense"
     data-ad-client="ca-pub-1170355046794925"
     data-ad-slot="${options.webId}"
     data-auto-format="rspv"
     data-full-width="">
  <div overflow=""></div>
</amp-ad>         
 '''
                .toJS,
    );

    return SizedBox(
      // width: adBlockSize.width.toDouble(),
      // height: adBlockSize.height.toDouble(),
      child: HtmlElementView(viewType: viewID),
    );
  }

  @override
  Widget? buildAppOpen(BuildContext context, AdOptions options) {
    return null;
  }

  @override
  void setAdEventListener(AdEventCallback? callback) {
    // Ad events not supported on web platform
  }

  @override
  Future<bool?> requestAttPermission() => Future.value(null);
}
