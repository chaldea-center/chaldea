import 'package:flutter/material.dart';

class AppAdSize {
  final int width;
  final int height;
  const AppAdSize(this.width, this.height);
}

class AdOptions {
  final AppAdSize size;
  final String? webId;
  final String? iosId;
  final String? androidId;
  final bool cached;

  const AdOptions({
    required this.size,
    this.webId,
    this.iosId,
    this.androidId,
    this.cached = true,
  });

  AdOptions copyWith({AppAdSize? size, String? webId, String? iosId, String? androidId, bool? cached}) {
    return AdOptions(
      size: size ?? this.size,
      webId: webId ?? this.webId,
      iosId: iosId ?? this.iosId,
      androidId: androidId ?? this.androidId,
      cached: cached ?? this.cached,
    );
  }

  static const homeCarousel = AdOptions(
    size: AppAdSize(320, 120),
    androidId: 'ca-app-pub-3940256099942544/6300978111',
    iosId: 'ca-app-pub-3940256099942544/2934735716',
    // androidId: 'ca-app-pub-3179193938592077/5027826704',
    // iosId: 'ca-app-pub-3179193938592077/6340908370',
  );
}

abstract class AppAdInterface {
  bool get supported;
  bool get initialized;

  Future<void> init();

  Widget build(BuildContext context, AdOptions options, WidgetBuilder? placeholder);
}
