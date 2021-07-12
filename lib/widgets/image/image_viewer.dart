import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chaldea/components/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' show basename;
import 'package:photo_view/photo_view.dart';
import 'package:string_validator/string_validator.dart' as validator;

import 'cached_image_option.dart';
import 'photo_view_option.dart';

export 'cached_image_option.dart';
export 'photo_view_option.dart';

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

class CachedImage extends StatefulWidget {
  final String? imageUrl;

  /// If [isMCFile] is null, check it is a valid url
  final bool? isMCFile;

  /// Save only if the image is wiki file
  final String? saveDir;
  final bool allowSave;

  final double? aspectRatio;

  /// [width], [height], [placeholder] will override [cachedOption]
  final double? width; //2
  final double? height; //2
  final PlaceholderWidgetBuilder? placeholder; //2

  final CachedImageOption cachedOption;
  final PhotoViewOption? photoViewOption;

  CachedImage({
    Key? key,
    required this.imageUrl,
    this.isMCFile,
    this.saveDir,
    this.allowSave = false,
    this.width,
    this.height,
    this.aspectRatio,
    this.placeholder,
    this.cachedOption = const CachedImageOption(),
    this.photoViewOption,
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
  bool _isMcFile = false;

  CachedImageOption get option => widget.cachedOption;

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

    Widget Function(BuildContext, String) placeholder = widget.placeholder ??
        option.placeholder ??
        (context, url) => Container(
              width: widget.width,
              height: widget.height,
              child: db.hasNetwork
                  ? CachedImage.defaultProgressPlaceholder(context, url)
                  : Container(), // TODO: add no-network icon
            );
    if (usePlaceholder) {
      child = placeholder(context, realUrl ?? widget.imageUrl ?? '');
    } else {
      final _cacheManager = option.cacheManager ??
          (_isMcFile ? WikiUtil.wikiFileCache : DefaultCacheManager());
      child = CachedNetworkImage(
        imageUrl: realUrl!,
        httpHeaders: option.httpHeaders,
        imageBuilder: option.imageBuilder,
        placeholder: placeholder,
        progressIndicatorBuilder: option.progressIndicatorBuilder,
        errorWidget: option.errorWidget ?? CachedImage.defaultErrorWidget,
        fadeOutDuration: option.fadeOutDuration,
        fadeOutCurve: option.fadeOutCurve,
        fadeInDuration: option.fadeInDuration,
        fadeInCurve: option.fadeInCurve,
        width: widget.width ?? option.width,
        height: widget.height ?? option.height,
        fit: option.fit,
        alignment: option.alignment,
        repeat: option.repeat,
        matchTextDirection: option.matchTextDirection,
        cacheManager: _cacheManager,
        useOldImageOnUrlChange: option.useOldImageOnUrlChange,
        color: option.color,
        filterQuality: option.filterQuality,
        colorBlendMode: option.colorBlendMode,
        placeholderFadeInDuration: option.placeholderFadeInDuration,
        memCacheWidth: option.memCacheWidth,
        memCacheHeight: option.memCacheHeight,
        cacheKey: option.cacheKey,
        maxWidthDiskCache: option.maxWidthDiskCache,
        maxHeightDiskCache: option.maxHeightDiskCache,
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
      if (widget.photoViewOption != null) {
        final pvOption = widget.photoViewOption!;
        child = PhotoView.customChild(
          child: child,
          backgroundDecoration: pvOption.backgroundDecoration,
          heroAttributes: pvOption.heroAttributes,
          scaleStateChangedCallback: pvOption.scaleStateChangedCallback,
          enableRotation: pvOption.enableRotation,
          controller: pvOption.controller,
          scaleStateController: pvOption.scaleStateController,
          minScale: pvOption.minScale,
          maxScale: pvOption.maxScale,
          initialScale: pvOption.initialScale,
          basePosition: pvOption.basePosition,
          scaleStateCycle: pvOption.scaleStateCycle,
          onTapUp: pvOption.onTapUp,
          onTapDown: pvOption.onTapDown,
          customSize: pvOption.customSize,
          gestureDetectorBehavior: pvOption.gestureDetectorBehavior,
          tightMode: pvOption.tightMode,
          filterQuality: pvOption.filterQuality,
          disableGestures: pvOption.disableGestures,
        );
      }
    }
    return CachedImage.sizeChild(
        child: child,
        width: widget.width,
        height: widget.height,
        aspectRatio: widget.aspectRatio);
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
}
