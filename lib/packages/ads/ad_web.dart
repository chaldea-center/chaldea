import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:admanager_web/admanager_web.dart';

import './interface.dart';

class AppAdImpl implements AppAdInterface {
  @override
  final bool supported = kIsWeb;

  bool _initialized = false;
  @override
  bool get initialized => _initialized;

  @override
  Future<void> init() async {
    if (initialized) return;
    if (supported) {
      AdManagerWeb.init();
      _initialized = true;
    }
    return;
  }

  @override
  Widget build(BuildContext context, AdOptions options, WidgetBuilder? placeholder) {
    AdBlockSize adBlockSize = AdBlockSize(width: options.size.width, height: options.size.height);
    if (!_initialized) {
      return placeholder?.call(context) ?? const SizedBox.shrink();
    }
    return SizedBox(
      width: adBlockSize.width.toDouble(),
      height: adBlockSize.height.toDouble(),
      child: AdBlock(
        size: [adBlockSize],
        adUnitId: "/xxx",
      ),
    );
  }
}
