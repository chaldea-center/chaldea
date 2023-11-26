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
import 'package:octo_image/octo_image.dart';
import 'package:path/path.dart' as pathlib;
import 'package:uuid/uuid.dart';

import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/utils.dart';
import '../../app/tools/icon_cache_manager.dart';
import '../../models/userdata/remote_config.dart';
import '../../packages/network.dart';
import '../layout_try_builder.dart';
import 'cached_image_option.dart';
import 'fullscreen_image_viewer.dart';
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
  final bool viewFullOnTap;
  final VoidCallback? onTap;

  const CachedImage({
    super.key,
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
    bool? viewFullOnTap,
    this.onTap,
  })  : imageProvider = null,
        viewFullOnTap = viewFullOnTap ?? showSaveOnLongPress;

  const CachedImage.fromProvider({
    super.key,
    required this.imageProvider,
    this.showSaveOnLongPress = false,
    this.width,
    this.height,
    this.aspectRatio,
    this.placeholder,
    this.cachedOption = const CachedImageOption(),
    this.photoViewOption,
    bool? viewFullOnTap,
    this.onTap,
  })  : imageUrl = null,
        cacheDir = null,
        cacheName = null,
        viewFullOnTap = viewFullOnTap ?? showSaveOnLongPress;

  @override
  _CachedImageState createState() => _CachedImageState();

  /// If download is available, use [CircularProgressIndicator].
  /// Otherwise, use an empty Container.
  static Widget defaultProgressPlaceholder(BuildContext context, String? url) {
    return LayoutTryBuilder(
      builder: (context, constraints) {
        double width = 0.3 * min(constraints.biggest.width, constraints.biggest.height);
        if (width.isFinite) width = min(width, 50);
        if (width.isFinite) {
          return Center(
            child: SizedBox(
              width: width,
              height: width,
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  static Widget defaultErrorWidget(BuildContext context, String? url, dynamic error) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Image(image: db.errorImage),
    );
  }

  static Widget sizeChild({required Widget child, double? width, double? height, double? aspectRatio}) {
    if (aspectRatio != null) {
      child = AspectRatio(aspectRatio: aspectRatio, child: child);
    }
    if (width != null || height != null) {
      child = SizedBox(width: width, height: height, child: child);
    }
    return child;
  }

  /// host            html  canvaskit
  /// fgo.wiki        √     x
  /// fate-go.jp      √     x
  /// fate-go.us      √     x
  /// fate-go.com.tw  √     x
  /// i0.hdslb.com    x     x
  /// *.pstatic.net   x     x
  static String corsProxyImage(String url) {
    if (url.contains('fgo.wiki')) {
      url = url.split('?sha').first;
    }
    if (!kIsWeb) return url;
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    bool cors = false;
    if (kPlatformMethods.rendererCanvasKit) {
      cors = const [
        'fgo.wiki',
        'fate-go.jp',
        'fate-go.us',
        'fate-go.com.tw',
        'hdslb.com',
        'pstatic.net',
      ].any((e) => uri.host.endsWith(e));
    } else {
      cors = const [
        'hdslb.com',
        'pstatic.net',
      ].any((e) => uri.host.endsWith(e));
    }
    if (cors) {
      return Uri.parse(HostsX.workerHost).replace(path: '/corsproxy/', queryParameters: {'url': url}).toString();
    }
    return url;
  }
}

class _CachedImageState extends State<CachedImage> {
  static final _loader = AtlasIconLoader.i;

  CachedImageOption get cachedOption => widget.cachedOption ?? const CachedImageOption();

  Future<void> _resolve(String? url) async {
    if (url != null && _loader.shouldCacheImage(url)) {
      await _loader.get(url);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget child = resolveChild();
    child = CachedImage.sizeChild(
      child: child,
      width: widget.width,
      height: widget.height,
      aspectRatio: widget.aspectRatio,
    );
    VoidCallback? onTap = widget.onTap;
    if (onTap == null && widget.viewFullOnTap) {
      onTap = () {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (context, _, __) => FullscreenImageViewer(children: [
              CachedImage(
                imageUrl: widget.imageUrl,
                cacheDir: widget.cacheDir,
                cacheName: widget.cacheName,
                showSaveOnLongPress: true,
                placeholder: widget.placeholder,
                // cachedOption: widget.cachedOption,
                // photoViewOption: widget.photoViewOption,
                viewFullOnTap: false,
                onTap: null,
              )
            ]),
          ),
        );
      };
    }
    if (onTap != null) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      );
    }
    return child;
  }

  Widget resolveChild() {
    if (widget.imageProvider != null) {
      return _withProvider(widget.imageProvider!, onClearCache: () {
        imageCache.evict(widget.imageProvider!);
        return Future.value();
      });
    }
    String? url = widget.imageUrl;
    if (url == null) return _withPlaceholder(context, '');
    if (_loader.shouldCacheImage(url)) {
      return _localCache(context, url);
    }
    return _withCached(url);
  }

  Widget _localCache(BuildContext context, String url) {
    final fp = AtlasIconLoader.i.getCached(url);
    if (fp != null) {
      final provider = FileImage(File(fp));
      return _withProvider(
        provider,
        onClearCache: () async {
          for (final _url in [url, widget.imageUrl]) {
            if (_url == null) continue;
            await _loader.deleteFromDisk(_url);
            _loader.evict(_url);
            imageCache.evict(provider);
          }
          if (mounted) setState(() {});
          _resolve(widget.imageUrl);
        },
      );
    } else if (AtlasIconLoader.i.isFailed(url)) {
      final reason = AtlasIconLoader.i.failReason(url);
      if (reason?.statusCode == 404 && url.endsWith('_bordered.png') && !url.contains('FFO')) {
        return _localCache(context, url.replaceFirst('_bordered.png', '.png'));
      }
      return _withError(context, url);
    } else {
      _resolve(url);
    }
    return _withPlaceholder(context, url);
  }

  Widget _withError(BuildContext context, String url, [Object? error]) {
    return cachedOption.errorWidget?.call(context, url, error ?? "") ?? const SizedBox();
  }

  Widget _withProvider(ImageProvider provider, {Future<void> Function()? onClearCache}) {
    Widget child = _withOcto(context, provider);
    if (widget.showSaveOnLongPress) {
      child = GestureDetector(
        child: child,
        onLongPress: () async {
          Uint8List? bytes;
          String? srcFp;
          String? fn;
          final imageUrl = widget.imageUrl;
          if (provider is FileImage) {
            srcFp = provider.file.path;
          } else {
            try {
              final img = await ImageActions.resolveImage(provider);
              bytes = (await img?.toByteData(format: ui.ImageByteFormat.png))?.buffer.asUint8List();
            } catch (e, s) {
              logger.e('resolve image provider failed', e, s);
            }
            if (bytes == null) {
              EasyLoading.showError('Failed');
              if (imageUrl != null) copyToClipboard(imageUrl);
              return;
            }
          }

          if (!mounted) return;

          Uri? uri;
          if (imageUrl != null) uri = Uri.tryParse(imageUrl);
          if (uri != null && uri.pathSegments.isNotEmpty) {
            fn = UriX.tryDecodeComponent(uri.pathSegments.last) ?? uri.pathSegments.last;
          }
          fn ??= bytes == null
              ? '${const Uuid().v4()}.png'
              : '${const Uuid().v5(Uuid.NAMESPACE_URL, sha1.convert(bytes).toString())}.png';
          ImageActions.showSaveShare(
            context: context,
            data: bytes,
            url: imageUrl,
            destFp: joinPaths(db.paths.downloadDir, fn),
            srcFp: srcFp,
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
    final _cacheManager = cachedOption.cacheManager ?? ImageViewerCacheManager();
    String url = CachedImage.corsProxyImage(fullUrl);

    final provider = CachedNetworkImageProvider(
      url,
      headers: cachedOption.httpHeaders,
      cacheManager: _cacheManager,
      cacheKey: cachedOption.cacheKey ?? url,
      imageRenderMethodForWeb: cachedOption.imageRenderMethodForWeb,
      maxWidth: cachedOption.maxWidthDiskCache,
      maxHeight: cachedOption.maxHeightDiskCache,
    );

    Widget child = _withOcto(context, provider);
    if (widget.showSaveOnLongPress) {
      Future<void> onClearCache() async {
        await _cacheManager.removeFile(cachedOption.cacheKey ?? url);
        imageCache.evict(provider);
        if (mounted) setState(() {});
      }

      child = GestureDetector(
        child: child,
        onLongPress: () async {
          if (kIsWeb) {
            return ImageActions.showSaveShare(
              context: context,
              srcFp: fullUrl,
              url: widget.imageUrl,
              onClearCache: onClearCache,
            );
          } else {
            File file = File((await _cacheManager.getSingleFile(fullUrl)).path);
            String fn = pathlib.basename(file.path);
            if (!mounted) return;
            return ImageActions.showSaveShare(
              context: context,
              srcFp: file.path,
              url: widget.imageUrl,
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
      child:
          network.available && url.isNotEmpty ? CachedImage.defaultProgressPlaceholder(context, url) : const SizedBox(),
    );
  }

  Widget _withOcto(BuildContext context, ImageProvider image) {
    return OctoImage(
      image: image,
      imageBuilder:
          cachedOption.imageBuilder == null ? null : (context, _) => cachedOption.imageBuilder!(context, image),
      placeholderBuilder: (context) => _withPlaceholder(context, widget.imageUrl ?? ''),
      progressIndicatorBuilder: cachedOption.progressIndicatorBuilder == null
          ? null
          : (context, progress) => cachedOption.progressIndicatorBuilder!(
                context,
                widget.imageUrl ?? "",
                DownloadProgress(
                    widget.imageUrl ?? "", progress?.expectedTotalBytes, progress?.cumulativeBytesLoaded ?? 0),
              ),
      errorBuilder: (context, e, s) => _withError(context, widget.imageUrl ?? ""),
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
      color: cachedOption.color,
      filterQuality: cachedOption.filterQuality,
      colorBlendMode: cachedOption.colorBlendMode,
      placeholderFadeInDuration: cachedOption.placeholderFadeInDuration,
      gaplessPlayback: cachedOption.useOldImageOnUrlChange,
      memCacheWidth: cachedOption.memCacheWidth,
      memCacheHeight: cachedOption.memCacheHeight,
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
      : super(Config(key, stalePeriod: const Duration(days: 30), fileService: _MyHttpFileService()));
}

class _MyHttpFileService extends FileService {
  final http.Client _httpClient;

  _MyHttpFileService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    final uri = Uri.parse(url);
    final req = http.Request('GET', uri);
    if (headers != null) {
      req.headers.addAll(headers);
    }
    try {
      final httpResponse = await _httpClient.send(req);
      if ([
        'fgo.wiki',
        'fate-go.jp',
        'fate-go.us',
        'fate-go.com.tw',
        'hdslb.com',
        'pstatic.net',
      ].any((e) => uri.host.contains(e))) {
        // 30days=2,592,000
        String? controlHeader = httpResponse.headers[HttpHeaders.cacheControlHeader];
        if (controlHeader == null) {
          httpResponse.headers[HttpHeaders.cacheControlHeader] = 'max-age=2592000';
        } else {
          controlHeader = controlHeader.replaceFirstMapped(RegExp(r'max-age=(\d+)'), (match) {
            final maxAge = int.tryParse(match.group(1) ?? '');
            if (maxAge != null && maxAge < 2592000) {
              return 'max-age=2592000';
            } else {
              return match.group(0)!;
            }
          });
          httpResponse.headers[HttpHeaders.cacheControlHeader] = controlHeader;
        }
      }
      return HttpGetResponse(httpResponse);
    } catch (e) {
      return HttpGetResponse(http.StreamedResponse(Stream.fromIterable([]), 400));
    }
  }
}
