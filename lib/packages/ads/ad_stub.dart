import 'package:flutter/material.dart';

import './interface.dart';

class AppAdImpl implements AppAdInterface {
  @override
  bool get supported => false;
  @override
  bool get initialized => false;
  @override
  Future<void> init() => Future.value();

  @override
  Widget build(BuildContext context, AdOptions options, WidgetBuilder? placeholder) {
    return placeholder?.call(context) ?? const SizedBox.shrink();
  }
}
