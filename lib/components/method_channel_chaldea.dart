import 'package:flutter/services.dart';

// default channel
const MethodChannel kMethodChannel = MethodChannel('chaldea.narumi.cc/chaldea');

class MethodChannelChaldea {
  /// Send app to background rather exit when pop root route
  ///
  /// only available on Android
  static Future<void> sendBackground() async {
    return kMethodChannel.invokeMethod('sendBackground');
  }

  /// Set window always on top
  ///
  /// only available on macOS
  static Future<void> setAlwaysOnTop(bool onTop) async {
    return kMethodChannel.invokeMethod<bool?>(
      'alwaysOnTop',
      <String, dynamic>{
        'onTop': onTop,
      },
    ).then((value) => print('alwaysOnTop success = $value'));
  }
}
