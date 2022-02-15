import 'package:flutter/services.dart';

import '../../models/db.dart';
import '../platform/platform.dart';

// default channel
const MethodChannel kMethodChannel = MethodChannel('chaldea.narumi.cc/chaldea');

class MethodChannelChaldeaNext {
  static void configMethodChannel() {
    kMethodChannel.setMethodCallHandler((call) async {
      print('[dart] on call: ${call.method}, ${call.arguments}');
      if (call.method == 'onWindowPos') {
        if (call.arguments != null && call.arguments['pos'] != null) {
          // print('onWindowRect: args=${call.arguments}');
          db2.settings.windowPosition = call.arguments['pos'];
          return;
        } else {
          print('onWindowRect invalid args=${call.arguments}');
          return;
        }
      } else if (call.method == 'onCloseWindow') {
        // not always successful
        db2.saveAll();
        // db.cfg.close();
        print('[dart] onCloseWindow');
      }
    });
  }

  /// Send app to background rather exit when pop root route
  ///
  /// only available on Android
  static Future<void> sendBackground() async {
    return kMethodChannel.invokeMethod('sendBackground');
  }

  /// Set window always on top
  ///
  /// only available on macOS
  static Future<void> setAlwaysOnTop([bool? onTop]) async {
    if (PlatformU.isWindows || PlatformU.isMacOS) {
      onTop ??= db2.settings.alwaysOnTop;
      return kMethodChannel.invokeMethod<bool?>(
        'alwaysOnTop',
        <String, dynamic>{
          'onTop': onTop,
        },
      ).then((value) => print('alwaysOnTop success = $value'));
    }
  }

  static Future<void> setWindowPos([dynamic rect]) async {
    if (PlatformU.isWindows) {
      rect ??= db2.settings.windowPosition;
      print('rect ${rect.runtimeType}: $rect');
      if (rect != null &&
          rect is List &&
          rect.length == 4 &&
          rect.any((e) => e is int && e > 0)) {
        print('ready to set window rect: $rect');
        return kMethodChannel.invokeMethod('setWindowRect', <String, dynamic>{
          'pos': rect,
        });
      }
    }
  }
}
