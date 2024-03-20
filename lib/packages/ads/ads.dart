import 'package:flutter/material.dart';

import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/models/db.dart';
import 'ad_stub.dart' if (dart.library.io) 'ad_mobile.dart' if (dart.library.js) 'ad_web.dart';
import 'interface.dart';

export 'interface.dart';

class AppAds {
  const AppAds._();

  static final instance = AppAdImpl();
  static bool _initiated = false;
  static Future<void> init() async {
    if (_initiated) return;
    await Future.delayed(const Duration(milliseconds: 300));
    await instance.init();
    _initiated = true;
  }

  static bool get canShowAds =>
      // kDebugMode &&
      instance.supported && instance.initialized;

  static bool shouldShowBannerAd(BuildContext? context) {
    return instance.supportBannerAd &&
        instance.initialized &&
        db.settings.display.ad.shouldShowBanner &&
        (context == null || AppRouter.of(context)?.index == 0);
  }

  static bool shouldShowAppOpenAd() {
    return instance.supportAppOpenAd && instance.initialized && db.settings.display.ad.shouldShowAppOpen;
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
