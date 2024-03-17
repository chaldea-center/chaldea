// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:admanager_web/admanager_web.dart';

import './interface.dart';

class AppAdImpl implements AppAdInterface {
  @override
  final bool supported = kIsWeb && false;

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
    final viewID = options.name;
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
        viewID,
        (int id) => html.IFrameElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none'
          ..srcdoc = '''
<amp-ad width="100vw" height="320"
     type="adsense"
     data-ad-client="ca-pub-1170355046794925"
     data-ad-slot="${options.webId}"
     data-auto-format="rspv"
     data-full-width="">
  <div overflow=""></div>
</amp-ad>         
 ''');

    return SizedBox(
      width: adBlockSize.width.toDouble(),
      height: adBlockSize.height.toDouble(),
      child: HtmlElementView(viewType: viewID),
    );
  }
}
