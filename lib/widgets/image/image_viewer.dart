import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaldea/components/components.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:string_validator/string_validator.dart' as validator;
import 'package:uuid/uuid.dart';

import 'cached_image_option.dart';
import 'image_action_mixin.dart';
import 'photo_view_option.dart';

export 'cached_image_option.dart';
export 'fullscreen_image_viewer.dart';
export 'image_action_mixin.dart';
export 'photo_view_option.dart';

class CachedImage extends StatefulWidget {
  final ImageProvider? imageProvider;

  final String? imageUrl;

  /// If [isMCFile] is null, check it is a valid url
  final bool? isMCFile;

  /// Save only if the image is wiki file
  final String? cacheDir;
  final bool showSaveOnLongPress;
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
    this.cacheDir,
    this.showSaveOnLongPress = false,
    this.width,
    this.height,
    this.aspectRatio,
    this.placeholder,
    this.cachedOption = const CachedImageOption(),
    this.photoViewOption,
  })  : imageProvider = null,
        super(key: key);

  CachedImage.fromProvider({
    Key? key,
    required this.imageProvider,
    this.showSaveOnLongPress = false,
    this.width,
    this.height,
    this.aspectRatio,
    this.placeholder,
    this.cachedOption = const CachedImageOption(),
    this.photoViewOption,
  })  : imageUrl = null,
        isMCFile = false,
        cacheDir = null,
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

class _CachedImageState extends State<CachedImage> with ImageActionMixin {
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
      if (widget.cacheDir != null)
        savePath = join(widget.cacheDir!, widget.imageUrl!);
      WikiUtil.resolveFileUrl(widget.imageUrl!, savePath).then((url) {
        if (url != null && mounted) {
          setState(() {});
        }
      });
    }
  }

  ImageStreamListener? _imageStreamListener;

  @override
  Widget build(BuildContext context) {
    late Widget child;

    if (widget.imageProvider != null) {
      child = Image(
        image: widget.imageProvider!,
        // frameBuilder:null,
        // loadingBuilder:null,
        errorBuilder: option.errorWidget == null
            ? null
            : (ctx, e, s) => option.errorWidget!(ctx, '', e),
        // semanticLabel:null,
        // excludeFromSemantics : false,
        width: widget.width,
        height: widget.height,
        color: option.color,
        colorBlendMode: option.colorBlendMode,
        fit: option.fit,
        alignment: option.alignment,
        repeat: option.repeat,
        // centerSlice:null,
        matchTextDirection: option.matchTextDirection,
        // gaplessPlayback : false,
        // isAntiAlias :false,
        filterQuality: option.filterQuality,
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
              String fn =
                  Uuid().v5(Uuid.NAMESPACE_URL, sha1.convert(data).toString()) +
                      '.png';
              showSaveShare(
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
    } else {
      bool usePlaceholder = true;
      String? realUrl = getRealUrl();
      if (realUrl?.isNotEmpty != true) {
        usePlaceholder = true;
      } else if (db.hasNetwork) {
        // use CachedNetworkImage
        usePlaceholder = false;
      } else {
        usePlaceholder = true;
      }

      if (usePlaceholder) {
        child = parsedPlaceholder(context, realUrl ?? widget.imageUrl ?? '');
      } else {
        final _cacheManager = option.cacheManager ??
            (_isMcFile ? WikiUtil.wikiFileCache : DefaultCacheManager());
        child = CachedNetworkImage(
          imageUrl: realUrl!,
          httpHeaders: option.httpHeaders,
          imageBuilder: option.imageBuilder,
          placeholder: parsedPlaceholder,
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

        if (widget.showSaveOnLongPress) {
          child = GestureDetector(
            child: child,
            onLongPress: () async {
              final file = await _cacheManager.getSingleFile(realUrl);
              return showSaveShare(
                context: context,
                srcFp: file.path,
                destFp: join(db.paths.downloadDir, file.basename),
                gallery: true,
                share: true,
              );
            },
          );
        }
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
      aspectRatio: widget.aspectRatio,
    );
  }

  Widget parsedPlaceholder(BuildContext context, String url) {
    if (widget.placeholder != null) return widget.placeholder!(context, url);
    if (option.placeholder != null) return option.placeholder!(context, url);
    return Container(
      width: widget.width,
      height: widget.height,
      child: db.hasNetwork
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
