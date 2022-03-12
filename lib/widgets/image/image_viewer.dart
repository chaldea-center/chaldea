import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaldea/components/wiki_util.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart' show join, basename;
import 'package:string_validator/string_validator.dart' as validator;
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

  /// If [isMCFile] is null, check it is a valid url
  final bool? isMCFile;

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
    this.isMCFile,
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
        isMCFile = false,
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
      child: Image(image: db2.errorImage),
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
  bool _isMcFile = false;

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

  bool _shouldFadeIn = false;

  Widget resolveChild() {
    if (widget.imageProvider != null) {
      return _withProvider(widget.imageProvider!);
    }
    if (widget.imageUrl == null) return _withPlaceholder(context, '');
    _isMcFile = widget.isMCFile ?? !_isValidUrl(widget.imageUrl!);
    if (!_isMcFile) return _withCached(widget.imageUrl!);
    if (!PlatformU.isWeb && widget.cacheDir != null) {
      String? savePath;
      savePath = join(widget.cacheDir!, widget.cacheName ?? widget.imageUrl!);
      if (_existIcon(savePath)) {
        Widget child = _withProvider(FileImage(File(savePath)));
        return _shouldFadeIn ? _FadeIn(child: child) : child;
      } else {
        _shouldFadeIn = true;
        WikiUtil.resolveFileUrl(widget.imageUrl!, savePath).then((_url) {
          if (_url != null && mounted) {
            setState(() {});
          }
        });
        return _withPlaceholder(context, widget.imageUrl!);
      }
    } else {
      String? trueUrl = WikiUtil.getCachedUrl(widget.imageUrl!);
      if (trueUrl != null) {
        return _withCached(trueUrl);
      }
      WikiUtil.resolveFileUrl(widget.imageUrl!).then((_url) {
        if (_url != null && mounted) {
          setState(() {});
        }
      });
      return _withPlaceholder(context, widget.imageUrl!);
    }
  }

  /// Don't check image file exists or not every frame
  static final HashSet<String> _existsIcons =
      HashSet(isValidKey: (k) => k != null && k is String);

  bool _existIcon(String fp) {
    if (_existsIcons.contains(fp)) return true;
    if (File(fp).existsSync()) {
      _existsIcons.add(fp);
      return true;
    }
    return false;
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
              destFp: join(db2.paths.downloadDir, fn),
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
    final _cacheManager = cachedOption.cacheManager ??
        (_isMcFile ? WikiUtil.wikiFileCache : DefaultCacheManager());

    if (kPlatformMethods.rendererCanvasKit) {
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
            destFp: join(db2.paths.downloadDir, fn),
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
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
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
