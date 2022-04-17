import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart' show join, basename;
import 'package:uuid/uuid.dart';

import '../../packages/network.dart';
import 'cached_image_option.dart';
import 'image_actions.dart';
import 'photo_view_option.dart';

export 'cached_image_option.dart';
export 'fullscreen_image_viewer.dart';
export 'image_actions.dart';
export 'photo_view_option.dart';

class CachedImage extends StatefulWidget {
  final ImageProvider? imageProvider;

  final String? imageUrl;

  /// Save only if the image is wiki file
  final String? cacheDir;
  final String? cacheName;
  final bool showSaveOnLongPress;
  final double? aspectRatio;

  /// [width], [height], [placeholder] will override [cachedOption]
  final double? width; //2
  final double? height; //2
  final PlaceholderWidgetBuilder? placeholder; //2

  final CachedImageOption? cachedOption;
  final PhotoViewOption? photoViewOption;
  final VoidCallback? onTap;

  const CachedImage({
    Key? key,
    required this.imageUrl,
    this.cacheDir,
    this.cacheName,
    this.showSaveOnLongPress = false,
    this.width,
    this.height,
    this.aspectRatio,
    this.placeholder,
    this.cachedOption,
    this.photoViewOption,
    this.onTap,
  })  : imageProvider = null,
        super(key: key);

  const CachedImage.fromProvider({
    Key? key,
    required this.imageProvider,
    this.showSaveOnLongPress = false,
    this.width,
    this.height,
    this.aspectRatio,
    this.placeholder,
    this.cachedOption = const CachedImageOption(),
    this.photoViewOption,
    this.onTap,
  })  : imageUrl = null,
        cacheDir = null,
        cacheName = null,
        super(key: key);

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
            child: const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  static Widget defaultErrorWidget(
      BuildContext context, String? url, dynamic error) {
    return Padding(
      padding: const EdgeInsets.all(10),
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
      child = SizedBox(width: width, height: height, child: child);
    }
    return child;
  }
}

class _CachedImageState extends State<CachedImage> {
  CachedImageOption get cachedOption =>
      widget.cachedOption ?? const CachedImageOption();

  ImageStreamListener? _imageStreamListener;

  @override
  Widget build(BuildContext context) {
    Widget child = resolveChild();
    child = CachedImage.sizeChild(
      child: child,
      width: widget.width,
      height: widget.height,
      aspectRatio: widget.aspectRatio,
    );
    if (widget.onTap != null) {
      child = GestureDetector(
        child: child,
        onTap: widget.onTap,
      );
    }
    return child;
  }

  Widget resolveChild() {
    if (widget.imageProvider != null) {
      return _withProvider(widget.imageProvider!);
    }
    if (widget.imageUrl == null) return _withPlaceholder(context, '');
    return _withCached(widget.imageUrl!);
  }

  Widget _withProvider(ImageProvider provider) {
    Widget child = Image(
      image: provider,
      // frameBuilder:null,
      // loadingBuilder: null,
      errorBuilder: cachedOption.errorWidget == null
          ? (ctx, e, s) => CachedImage.defaultErrorWidget(ctx, '', e)
          : (ctx, e, s) => cachedOption.errorWidget!(ctx, '', e),
      // semanticLabel:null,
      // excludeFromSemantics : false,
      // width: widget.width,
      // height: widget.height,
      color: cachedOption.color,
      colorBlendMode: cachedOption.colorBlendMode,
      fit: cachedOption.fit,
      alignment: cachedOption.alignment,
      repeat: cachedOption.repeat,
      // centerSlice:null,
      matchTextDirection: cachedOption.matchTextDirection,
      // gaplessPlayback : false,
      // isAntiAlias :false,
      filterQuality: cachedOption.filterQuality,
    );
    if (widget.showSaveOnLongPress) {
      child = GestureDetector(
        child: child,
        onLongPress: () async {
          _imageStreamListener ??= ImageStreamListener((info, sycCall) async {
            final bytes =
                await info.image.toByteData(format: ui.ImageByteFormat.png);
            final data = bytes?.buffer.asUint8List();
            if (data == null) {
              EasyLoading.showError('Failed');
              return;
            }
            if (!mounted) return;
            // some sha1 hash value for same data
            String fn = const Uuid()
                    .v5(Uuid.NAMESPACE_URL, sha1.convert(data).toString()) +
                '.png';
            ImageActions.showSaveShare(
              context: context,
              data: data,
              destFp: join(db.paths.downloadDir, fn),
              gallery: true,
              share: true,
            );
          });
          widget.imageProvider!.resolve(ImageConfiguration.empty)
            ..removeListener(_imageStreamListener!)
            ..addListener(_imageStreamListener!);
        },
      );
    }
    return child;
  }

  Widget _withCached(String fullUrl) {
    final _cacheManager = cachedOption.cacheManager ?? DefaultCacheManager();
    Uri? uri = Uri.tryParse(fullUrl);
    if (uri != null && uri.host == 'fgo.wiki') {
      final hashValue = uri.queryParameters['sha1'];
      if (hashValue != null) {
        if (kIsWeb && kPlatformMethods.rendererCanvasKit) {
          fullUrl = '$kStaticHostRoot/${uri.host}/$hashValue';
        } else {
          fullUrl = fullUrl.split('?').first;
        }
      }
    }
    if (kIsWeb && kPlatformMethods.rendererCanvasKit) {
      final uri = Uri.tryParse(fullUrl);
      if (uri != null && uri.host == 'fgo.wiki') {
        final hashValue = uri.queryParameters['sha1'];
        if (hashValue != null && hashValue.length == 40) {
          fullUrl = '$kStaticHostRoot/${uri.host}/$hashValue';
        }
      }
    }

    Widget child = CachedNetworkImage(
      imageUrl: fullUrl,
      httpHeaders: cachedOption.httpHeaders,
      imageBuilder: cachedOption.imageBuilder,
      placeholder: _withPlaceholder,
      progressIndicatorBuilder: cachedOption.progressIndicatorBuilder,
      errorWidget: cachedOption.errorWidget ?? CachedImage.defaultErrorWidget,
      fadeOutDuration: cachedOption.fadeOutDuration,
      fadeOutCurve: cachedOption.fadeOutCurve,
      fadeInDuration: cachedOption.fadeInDuration,
      fadeInCurve: cachedOption.fadeInCurve,
      width: widget.width ?? cachedOption.width,
      height: widget.height ?? cachedOption.height,
      fit: cachedOption.fit,
      alignment: cachedOption.alignment,
      repeat: cachedOption.repeat,
      matchTextDirection: cachedOption.matchTextDirection,
      cacheManager: _cacheManager,
      useOldImageOnUrlChange: cachedOption.useOldImageOnUrlChange,
      color: cachedOption.color,
      filterQuality: cachedOption.filterQuality,
      colorBlendMode: cachedOption.colorBlendMode,
      placeholderFadeInDuration: cachedOption.placeholderFadeInDuration,
      memCacheWidth: cachedOption.memCacheWidth,
      memCacheHeight: cachedOption.memCacheHeight,
      cacheKey: cachedOption.cacheKey,
      maxWidthDiskCache: cachedOption.maxWidthDiskCache,
      maxHeightDiskCache: cachedOption.maxHeightDiskCache,
    );

    if (!PlatformU.isWeb && widget.showSaveOnLongPress) {
      child = GestureDetector(
        child: child,
        onLongPress: () async {
          File file = File((await _cacheManager.getSingleFile(fullUrl)).path);
          String fn = basename(file.path);
          return ImageActions.showSaveShare(
            context: context,
            srcFp: file.path,
            destFp: join(db.paths.downloadDir, fn),
            gallery: true,
            share: true,
            shareText: fn,
          );
        },
      );
    }
    return child;
  }

  Widget _withPlaceholder(BuildContext context, String url) {
    if (widget.placeholder != null) return widget.placeholder!(context, url);
    if (cachedOption.placeholder != null) {
      return cachedOption.placeholder!(context, url);
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: network.available
          ? CachedImage.defaultProgressPlaceholder(context, url)
          : Container(), // TODO: add no-network icon
    );
  }
}

class _FadeIn extends StatefulWidget {
  final Widget child;

  const _FadeIn({Key? key, required this.child}) : super(key: key);

  @override
  __FadeInState createState() => __FadeInState();
}

class __FadeInState extends State<_FadeIn> {
  double? opacity = 0;

  @override
  Widget build(BuildContext context) {
    if (opacity == null) return widget.child;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        setState(() {
          opacity = 1;
        });
      }
    });
    return AnimatedOpacity(
      opacity: opacity!,
      duration: const Duration(milliseconds: 300),
      child: widget.child,
      onEnd: () {
        if (mounted) {
          setState(() {
            opacity = null;
          });
        }
      },
    );
  }
}
