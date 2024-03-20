import 'package:flutter/material.dart';

class AppAdSize {
  final int width;
  final int height;
  const AppAdSize(this.width, this.height);
}

class AdOptions {
  final String name;
  final AppAdSize size;
  final String? webId;
  final String? iosId;
  final String? androidId;
  final bool cached;

  const AdOptions({
    required this.name,
    required this.size,
    this.webId,
    this.iosId,
    this.androidId,
    this.cached = true,
  });

  AdOptions copyWith({String? name, AppAdSize? size, String? webId, String? iosId, String? androidId, bool? cached}) {
    return AdOptions(
      name: name ?? this.name,
      size: size ?? this.size,
      webId: webId ?? this.webId,
      iosId: iosId ?? this.iosId,
      androidId: androidId ?? this.androidId,
      cached: cached ?? this.cached,
    );
  }

  static const homeCarousel = AdOptions(
    name: "home-carousel",
    size: AppAdSize(320, 120),
    // androidId: 'ca-app-pub-3940256099942544/6300978111',
    // iosId: 'ca-app-pub-3940256099942544/2934735716',
    androidId: 'ca-app-pub-1170355046794925/8212269539',
    iosId: 'ca-app-pub-1170355046794925/3228031006',
    webId: '9573402336',
  );

  static AdOptions get appOpen => const AdOptions(
        name: 'app-open',
        size: AppAdSize(800, 800),
        // androidId: 'ca-app-pub-3940256099942544/9257395921',
        // iosId: 'ca-app-pub-3940256099942544/5575463023',
        androidId: 'ca-app-pub-1170355046794925/9012265171',
        iosId: 'ca-app-pub-1170355046794925/8214188824',
      );
}

abstract class AppAdInterface {
  bool get supported;
  bool get supportBannerAd;
  bool get supportAppOpenAd;
  bool get initialized;

  Future<void> init();

  Future<void> initAppOpenAd();

  Widget buildBanner(BuildContext context, AdOptions options, WidgetBuilder? placeholder);

  Widget? buildAppOpen(BuildContext context, AdOptions options);
}
