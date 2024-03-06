import 'package:flutter/material.dart';

import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/extension.dart';
import 'ad_stub.dart' if (dart.library.io) 'ad_mobile.dart' if (dart.library.js) 'ad_web.dart';
import 'interface.dart';

export 'interface.dart';

class BannerAdWidget extends StatelessWidget {
  final AdOptions options;
  final WidgetBuilder? placeholder;
  BannerAdWidget({super.key, required this.options, this.placeholder});

  static final instance = AppAdImpl();
  static bool _initiated = false;
  static Future<void> init() async {
    if (_initiated) return;
    await Future.delayed(const Duration(milliseconds: 300));
    await instance.init();
    _initiated = true;
  }

  static bool get shouldShowAds =>
      // kDebugMode &&
      instance.supported && instance.initialized && db.settings.display.hideAdsUntil < DateTime.now().timestamp;

  @override
  Widget build(BuildContext context) {
    return instance.build(context, options, placeholder);
  }
}
