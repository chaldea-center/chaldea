import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaldea/components/components.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:string_validator/string_validator.dart' as validator;

import 'config.dart';

class FullScreenImageSlider extends StatefulWidget {
  final List<String?> imgUrls;
  final bool? isMcFile;
  final int initialPage;
  final ConnectivityResult? connectivity;
  final bool? downloadEnabled;
  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;

  const FullScreenImageSlider({
    Key? key,
    required this.imgUrls,
    this.isMcFile,
    this.initialPage = 0,
    this.connectivity,
    this.downloadEnabled,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  _FullScreenImageSliderState createState() => _FullScreenImageSliderState();
}

class _FullScreenImageSliderState extends State<FullScreenImageSlider> {
  int _curIndex = 0;

  @override
  void initState() {
    super.initState();
    _curIndex = widget.initialPage;
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  Future<void> resetSystemUI() async {
    await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await resetSystemUI();
        Navigator.of(context).pop(_curIndex);
        return false;
      },
      child: GestureDetector(
        onTap: () async {
          await resetSystemUI();
          Navigator.of(context).pop(_curIndex);
        },
        child: Scaffold(
          body: GFCarousel(
            items: List.generate(
              widget.imgUrls.length,
              (index) => CachedImage(
                imageUrl: widget.imgUrls[index],
                isMCFile: widget.isMcFile,
                placeholder: widget.placeholder,
                connectivity: widget.connectivity,
              ),
            ),
            autoPlay: false,
            viewportFraction: 1.0,
            height: MediaQuery.of(context).size.height,
            enableInfiniteScroll: false,
            initialPage: _curIndex,
            onPageChanged: (v) => _curIndex = v,
          ),
        ),
      ),
    );
  }
}

typedef PlaceholderWidgetBuilder = Widget Function(
  BuildContext context,
  String? url,
);

class CachedImage extends StatefulWidget {
  final String? imageUrl;

  /// If [isMCFile] is null, check it is a valid url
  final bool? isMCFile;
  final String? saveDir;
  final ImageWidgetBuilder? imageBuilder;
  final PlaceholderWidgetBuilder? placeholder;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final LoadingErrorWidgetBuilder? errorWidget;

  /// [ConnectivityResult.none] or others
  final ConnectivityResult? connectivity;

  final Map<String, String>? httpHeaders;
  final Duration fadeOutDuration;
  final Curve fadeOutCurve;
  final Duration fadeInDuration;
  final Curve fadeInCurve;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final BaseCacheManager? cacheManager;
  final bool useOldImageOnUrlChange;
  final Color? color;
  final FilterQuality filterQuality;
  final BlendMode? colorBlendMode;
  final Duration? placeholderFadeInDuration;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final String? cacheKey;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;

  CachedImage({
    Key? key,
    required this.imageUrl,
    this.isMCFile,
    this.saveDir,
    this.imageBuilder,
    this.placeholder,
    this.progressIndicatorBuilder,
    this.errorWidget,
    this.connectivity,
    this.httpHeaders,
    this.fadeOutDuration = const Duration(milliseconds: 1000),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.fadeInCurve = Curves.easeIn,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.cacheManager,
    this.useOldImageOnUrlChange = false,
    this.color,
    this.filterQuality = FilterQuality.low,
    this.colorBlendMode,
    this.placeholderFadeInDuration,
    this.memCacheWidth,
    this.memCacheHeight,
    this.cacheKey,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
  }) : super(key: key);

  @override
  _CachedImageState createState() => _CachedImageState();

  /// If download is available, use [CircularProgressIndicator].
  /// Otherwise, use an empty Container.
  static Widget defaultProgressPlaceholder(BuildContext context, String? url) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width =
            0.3 * min(constraints.biggest.width, constraints.biggest.height);
        width = min(width, 100);
        return Center(
          child: SizedBox(
            width: width,
            height: width,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  static Widget defaultErrorWidget(
      BuildContext context, String? url, dynamic error) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Image(image: db.errorImage),
    );
  }
}

class _CachedImageState extends State<CachedImage> {
  BaseCacheManager get cacheManager =>
      widget.cacheManager ?? DefaultCacheManager();

  String? getRealUrl() {
    if (widget.imageUrl == null) return null;
    bool isMCFile = widget.isMCFile ?? !_isValidUrl(widget.imageUrl!);
    if (!isMCFile) return widget.imageUrl;
    String? url = db.prefs.getRealUrl(widget.imageUrl!);
    if (url != null) {
      return url;
    } else {
      String? savePath;
      if (widget.saveDir != null)
        savePath = join(widget.saveDir!, widget.imageUrl!);
      MooncellUtil.resolveFileUrl(widget.imageUrl!, savePath).then((url) {
        if (url != null && mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool usePlaceholder = true;
    late Widget child;
    String? realUrl = getRealUrl();
    if (realUrl?.isNotEmpty != true) {
      usePlaceholder = true;
    } else if (canDownload()) {
      // use CachedNetworkImage
      usePlaceholder = false;
    } else {
      usePlaceholder = true;
    }

    Widget Function(BuildContext, String?) placeholder = widget.placeholder ??
        (context, url) => Container(
              width: widget.width,
              height: widget.height,
              child: canDownload()
                  ? CachedImage.defaultProgressPlaceholder(context, url)
                  : Container(),
            );
    if (usePlaceholder) {
      child = placeholder(context, realUrl ?? widget.imageUrl);
    } else {
      child = CachedNetworkImage(
        imageUrl: realUrl!,
        httpHeaders: widget.httpHeaders,
        imageBuilder: widget.imageBuilder,
        placeholder: placeholder,
        progressIndicatorBuilder: widget.progressIndicatorBuilder,
        errorWidget: widget.errorWidget ?? CachedImage.defaultErrorWidget,
        fadeOutDuration: widget.fadeOutDuration,
        fadeOutCurve: widget.fadeOutCurve,
        fadeInDuration: widget.fadeInDuration,
        fadeInCurve: widget.fadeInCurve,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        alignment: widget.alignment,
        repeat: widget.repeat,
        matchTextDirection: widget.matchTextDirection,
        cacheManager: widget.cacheManager,
        useOldImageOnUrlChange: widget.useOldImageOnUrlChange,
        color: widget.color,
        filterQuality: widget.filterQuality,
        colorBlendMode: widget.colorBlendMode,
        placeholderFadeInDuration: widget.placeholderFadeInDuration,
        memCacheWidth: widget.memCacheWidth,
        memCacheHeight: widget.memCacheHeight,
        cacheKey: widget.cacheKey,
        maxWidthDiskCache: widget.maxWidthDiskCache,
        maxHeightDiskCache: widget.maxHeightDiskCache,
      );
    }
    // if (realUrl != null)
    //   child = GestureDetector(
    //     onLongPress: () {
    //       SimpleCancelOkDialog(
    //         title: Text(S.of(context).clear_cache),
    //         content: Text(realUrl),
    //         onTapOk: () async {
    //           /// clear cache in filesystem
    //           /// will cause error
    //           await cacheManager.removeFile(realUrl);
    //
    //           /// This will clear all cached images in memory
    //           /// enhance: `imageCache.evict(key)` or `ImageProvider.evict()`
    //           imageCache?.clear();
    //
    //           if (mounted) {
    //             setState(() {});
    //           }
    //         },
    //       ).show(context);
    //     },
    //     child: child,
    //   );
    return child;
  }

  bool canDownload() {
    return (widget.connectivity ?? db.connectivity) != ConnectivityResult.none;
  }
}

bool _isValidUrl(String str) {
  if (validator.isURL(str)) {
    str = str.toLowerCase();
    if (str.endsWith('.png') ||
        str.endsWith('.jpg') ||
        str.endsWith('.mp3') ||
        str.endsWith('.wav')) {
      return str.contains('/');
    }
    return true;
  } else {
    return false;
  }
}
