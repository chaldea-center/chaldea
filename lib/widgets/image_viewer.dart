import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chaldea/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' show basename;
import 'package:string_validator/string_validator.dart' as validator;

import '../components/config.dart';

class FullscreenWidget extends StatefulWidget {
  final WidgetBuilder builder;

  const FullscreenWidget({Key? key, required this.builder}) : super(key: key);

  Future<T?> push<T>(BuildContext context, [bool opaque = false]) {
    return Navigator.of(context).push<T>(PageRouteBuilder(
      fullscreenDialog: true,
      opaque: opaque,
      pageBuilder: (context, _, __) => this,
    ));
  }

  @override
  _FullscreenWidgetState createState() => _FullscreenWidgetState();
}

class _FullscreenWidgetState extends State<FullscreenWidget> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: widget.builder(context),
    );
  }
}

class FullScreenImageSlider extends StatefulWidget {
  final List<String?> imgUrls;
  final bool? isMcFile;
  final bool allowSave;
  final int initialPage;
  final bool? downloadEnabled;
  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;

  const FullScreenImageSlider({
    Key? key,
    required this.imgUrls,
    this.isMcFile,
    this.allowSave = false,
    this.initialPage = 0,
    this.downloadEnabled,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  _FullScreenImageSliderState createState() => _FullScreenImageSliderState();

  Future push(BuildContext context) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        fullscreenDialog: true,
        pageBuilder: (context, _, __) => this,
      ),
    );
  }
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
          body: CarouselSlider(
            items: List.generate(
              widget.imgUrls.length,
              (index) => CachedImage(
                imageUrl: widget.imgUrls[index],
                isMCFile: widget.isMcFile,
                allowSave: widget.allowSave,
                placeholder: widget.placeholder,
              ),
            ),
            options: CarouselOptions(
              autoPlay: false,
              viewportFraction: 1.0,
              height: MediaQuery.of(context).size.height,
              enableInfiniteScroll: false,
              initialPage: _curIndex,
              onPageChanged: (v, _) => _curIndex = v,
            ),
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

  /// wiki file cache dir
  final String? saveDir;
  final bool allowSave;
  final ImageWidgetBuilder? imageBuilder;
  final PlaceholderWidgetBuilder? placeholder;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final Map<String, String>? httpHeaders;
  final Duration fadeOutDuration;
  final Curve fadeOutCurve;
  final Duration fadeInDuration;
  final Curve fadeInCurve;
  final double? width;
  final double? height;
  final double? aspectRatio;
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
    this.allowSave = false,
    this.imageBuilder,
    this.placeholder,
    this.progressIndicatorBuilder,
    this.errorWidget,
    this.httpHeaders,
    this.fadeOutDuration = const Duration(milliseconds: 1000),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.fadeInCurve = Curves.easeIn,
    this.width,
    this.height,
    this.aspectRatio,
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
        width = min(width, 50);
        return Center(
          child: SizedBox(
            width: width,
            height: width,
            child: Center(child: CircularProgressIndicator()),
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

  static Widget sizeChild(
      {required Widget child,
      double? width,
      double? height,
      double? aspectRatio}) {
    if (aspectRatio != null) {
      child = AspectRatio(aspectRatio: aspectRatio, child: child);
    }
    if (width != null || height != null) {
      child = Container(width: width, height: height, child: child);
    }
    return child;
  }
}

class _CachedImageState extends State<CachedImage> {
  BaseCacheManager get cacheManager =>
      widget.cacheManager ?? DefaultCacheManager();
  bool _isMcFile = false;

  String? getRealUrl() {
    if (widget.imageUrl == null) return null;
    bool _isMcFile = widget.isMCFile ?? !_isValidUrl(widget.imageUrl!);
    if (!_isMcFile) return widget.imageUrl;
    String? url = WikiUtil.getCachedUrl(widget.imageUrl!);
    if (url != null) {
      return url;
    } else {
      String? savePath;
      if (widget.saveDir != null)
        savePath = join(widget.saveDir!, widget.imageUrl!);
      WikiUtil.resolveFileUrl(widget.imageUrl!, savePath).then((url) {
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
    } else if (db.hasNetwork) {
      // use CachedNetworkImage
      usePlaceholder = false;
    } else {
      usePlaceholder = true;
    }

    Widget Function(BuildContext, String?) placeholder = widget.placeholder ??
        (context, url) => Container(
              width: widget.width,
              height: widget.height,
          child: db.hasNetwork
                  ? CachedImage.defaultProgressPlaceholder(context, url)
                  : Container(),
            );
    if (usePlaceholder) {
      child = placeholder(context, realUrl ?? widget.imageUrl);
    } else {
      final _cacheManager = widget.cacheManager ??
          (_isMcFile ? WikiUtil.wikiFileCache : DefaultCacheManager());
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
        cacheManager: _cacheManager,
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

      if (widget.allowSave) {
        child = GestureDetector(
          child: child,
          onLongPress: () async {
            final file = await _cacheManager.getSingleFile(realUrl);
            final savePath = join(db.paths.downloadDir, basename(file.path));
            SimpleCancelOkDialog.showSave(
                context: context, srcFile: file, savePath: savePath);
          },
        );
      }
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
    return CachedImage.sizeChild(
        child: child,
        width: widget.width,
        height: widget.height,
        aspectRatio: widget.aspectRatio);
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
