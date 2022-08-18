import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as pathlib;
import 'package:uuid/uuid.dart';

import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import '../../app/tools/icon_cache_manager.dart';
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

  static String proxyMooncellImage(String url) {
    Uri? uri = Uri.tryParse(url);
    if (uri == null) return url;
    if (!uri.host.contains('fgo.wiki')) return url;
    final hashValue = uri.queryParameters['sha1'];
    if (hashValue == null) return url;
    if (kIsWeb && kPlatformMethods.rendererCanvasKit) {
      return '$kStaticHostRoot/${uri.host}/$hashValue';
    } else {
      return url.split('?').first;
    }
  }
}

class _CachedImageState extends State<CachedImage> {
  static final _loader = AtlasIconLoader.i;

  CachedImageOption get cachedOption =>
      widget.cachedOption ?? const CachedImageOption();

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
        onTap: widget.onTap,
        child: child,
      );
    }
    return child;
  }

  Widget resolveChild() {
    if (widget.imageProvider != null) {
      return _withProvider(widget.imageProvider!);
    }
    String? url = widget.imageUrl;
    if (url == null) return _withPlaceholder(context, '');
    url = Atlas.proxyAssetUrl(url);
    url = CachedImage.proxyMooncellImage(url);
    if (AtlasIconLoader.i.shouldCacheImage(url)) {
      String? _cachedPath = _loader.getCached(url);
      if (_cachedPath != null) {
        final provider = FileImage(File(_cachedPath));
        return _withProvider(provider, onClearCache: () async {
          AtlasIconLoader.i.evict(url!);
          if (provider.file.existsSync()) {
            provider.file.deleteSync();
          }
          await provider.evict();
          if (mounted) setState(() {});
        });
      } else if (!_loader.isFailed(url)) {
        _loader.get(url).then((localPath) {
          if (mounted) setState(() {});
        });
        return _withPlaceholder(context, url);
      } else {
        return _withError(context, url);
      }
    }
    return _withCached(url);
  }

  Widget _withError(BuildContext context, String url, [dynamic error]) {
    return cachedOption.errorWidget?.call(context, url, error) ??
        const SizedBox();
  }

  Widget _withProvider(ImageProvider provider,
      {Future<void> Function()? onClearCache}) {
    Widget child = FadeInImage(
      placeholder: MemoryImage(kOnePixel),
      image: provider,
      imageErrorBuilder: cachedOption.errorWidget == null
          ? (ctx, e, s) => CachedImage.defaultErrorWidget(ctx, '', e)
          : (ctx, e, s) => cachedOption.errorWidget!(ctx, '', e),
      placeholderErrorBuilder: (ctx, e, s) => const SizedBox(),
      // width: widget.width,
      // height: widget.height,
      fit: cachedOption.fit,
      alignment: cachedOption.alignment,
      repeat: cachedOption.repeat,
      matchTextDirection: cachedOption.matchTextDirection,
      fadeInCurve: cachedOption.fadeInCurve,
      fadeOutCurve: cachedOption.fadeOutCurve,
      fadeInDuration: cachedOption.fadeInDuration,
      fadeOutDuration: cachedOption.fadeOutDuration,
    );
    if (widget.showSaveOnLongPress) {
      child = GestureDetector(
        child: child,
        onLongPress: () async {
          final img = await ImageActions.resolveImage(provider);
          final bytes = (await img?.toByteData(format: ui.ImageByteFormat.png))
              ?.buffer
              .asUint8List();
          if (bytes == null) {
            EasyLoading.showError('Failed');
            return;
          }
          if (!mounted) return;
          String fn =
              '${const Uuid().v5(Uuid.NAMESPACE_URL, sha1.convert(bytes).toString())}.png';
          ImageActions.showSaveShare(
            context: context,
            data: bytes,
            destFp: joinPaths(db.paths.downloadDir, fn),
            gallery: true,
            share: true,
            onClearCache: onClearCache,
          );
        },
      );
    }
    return child;
  }

  Widget _withCached(String fullUrl) {
    final _cacheManager =
        cachedOption.cacheManager ?? ImageViewerCacheManager();
    Uri? uri = Uri.tryParse(fullUrl);
    if (uri != null && uri.host == 'fgo.wiki') {
      final hashValue = uri.queryParameters['sha1'];
      if (hashValue != null) {
        if (kIsWeb && kPlatformMethods.rendererCanvasKit) {
          fullUrl = '$kStaticHostRoot/${uri.host}/$hashValue';
        } else {
          fullUrl = fullUrl.split('?sha1').first;
        }
        uri = Uri.tryParse(fullUrl);
      }
    }
    if (kIsWeb &&
        kPlatformMethods.rendererCanvasKit &&
        fullUrl.contains('fgo.wiki')) {
      return _withError(context, fullUrl);
    }

    String url = uri?.toString() ?? fullUrl;

    Widget child = CachedNetworkImage(
      imageUrl: url,
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
    if (widget.showSaveOnLongPress) {
      Future<void> onClearCache() async {
        await _cacheManager.removeFile(cachedOption.cacheKey ?? url);
        if (mounted) setState(() {});
      }

      child = GestureDetector(
        child: child,
        onLongPress: () async {
          if (kIsWeb) {
            return ImageActions.showSaveShare(
              context: context,
              srcFp: fullUrl,
              onClearCache: onClearCache,
            );
          } else {
            File file = File((await _cacheManager.getSingleFile(fullUrl)).path);
            String fn = pathlib.basename(file.path);
            return ImageActions.showSaveShare(
              context: context,
              srcFp: file.path,
              destFp: joinPaths(db.paths.downloadDir, fn),
              gallery: true,
              share: true,
              shareText: fn,
              onClearCache: onClearCache,
            );
          }
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
          : const SizedBox(),
    );
  }
}

class ImageViewerCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'chaldeaCachedImageData';

  static final ImageViewerCacheManager _instance = ImageViewerCacheManager._();
  factory ImageViewerCacheManager() {
    return _instance;
  }

  ImageViewerCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 30),
          fileService: _MyHttpFileService(),
        ));
}

class _MyHttpFileService extends FileService {
  final http.Client _httpClient;

  _MyHttpFileService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String>? headers}) async {
    final uri = Uri.parse(url);
    final req = http.Request('GET', uri);
    if (headers != null) {
      req.headers.addAll(headers);
    }
    final httpResponse = await _httpClient.send(req);
    if ([
      'webview.fate-go.jp',
      'news.fate-go.jp',
      'i0.hdslb.com',
      'webview.fate-go.us',
      'static.fate-go.com.tw',
    ].contains(uri.host)) {
      // 30days=2,592,000
      httpResponse.headers
          .addAll({HttpHeaders.cacheControlHeader: 'max-age=2592000'});
    }
    return HttpGetResponse(httpResponse);
  }
}
