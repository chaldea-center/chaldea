import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Options for [CachedNetworkImage], excluding [imgUrl]
class CachedImageOption {
  final Map<String, String>? httpHeaders;
  final ImageWidgetBuilder? imageBuilder;
  final PlaceholderWidgetBuilder? placeholder; //2
  final ProgressIndicatorBuilder? progressIndicatorBuilder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final Duration fadeOutDuration;
  final Curve fadeOutCurve;
  final Duration fadeInDuration;
  final Curve fadeInCurve;
  final double? width; //2
  final double? height; //2
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
  final ImageRenderMethodForWeb imageRenderMethodForWeb;

  const CachedImageOption({
    this.httpHeaders,
    this.imageBuilder,
    this.placeholder,
    this.progressIndicatorBuilder,
    this.errorWidget,
    this.fadeOutDuration = const Duration(milliseconds: 500),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeInDuration = const Duration(milliseconds: 300),
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
    this.imageRenderMethodForWeb = ImageRenderMethodForWeb.HtmlImage,
  });

  CachedImageOption copyWith({
    Map<String, String>? httpHeaders,
    ImageWidgetBuilder? imageBuilder,
    PlaceholderWidgetBuilder? placeholder,
    ProgressIndicatorBuilder? progressIndicatorBuilder,
    LoadingErrorWidgetBuilder? errorWidget,
    Duration? fadeOutDuration,
    Curve? fadeOutCurve,
    Duration? fadeInDuration,
    Curve? fadeInCurve,
    double? width,
    double? height,
    BoxFit? fit,
    Alignment? alignment,
    ImageRepeat? repeat,
    bool? matchTextDirection,
    BaseCacheManager? cacheManager,
    bool? useOldImageOnUrlChange,
    Color? color,
    FilterQuality? filterQuality,
    BlendMode? colorBlendMode,
    Duration? placeholderFadeInDuration,
    int? memCacheWidth,
    int? memCacheHeight,
    String? cacheKey,
    int? maxWidthDiskCache,
    int? maxHeightDiskCache,
  }) {
    return CachedImageOption(
      httpHeaders: httpHeaders ?? this.httpHeaders,
      imageBuilder: imageBuilder ?? this.imageBuilder,
      placeholder: placeholder ?? this.placeholder,
      progressIndicatorBuilder:
          progressIndicatorBuilder ?? this.progressIndicatorBuilder,
      errorWidget: errorWidget ?? this.errorWidget,
      fadeOutDuration: fadeOutDuration ?? this.fadeOutDuration,
      fadeOutCurve: fadeOutCurve ?? this.fadeOutCurve,
      fadeInDuration: fadeInDuration ?? this.fadeInDuration,
      fadeInCurve: fadeInCurve ?? this.fadeInCurve,
      width: width ?? this.width,
      height: height ?? this.height,
      fit: fit ?? this.fit,
      alignment: alignment ?? this.alignment,
      repeat: repeat ?? this.repeat,
      matchTextDirection: matchTextDirection ?? this.matchTextDirection,
      cacheManager: cacheManager ?? this.cacheManager,
      useOldImageOnUrlChange:
          useOldImageOnUrlChange ?? this.useOldImageOnUrlChange,
      color: color ?? this.color,
      filterQuality: filterQuality ?? this.filterQuality,
      colorBlendMode: colorBlendMode ?? this.colorBlendMode,
      placeholderFadeInDuration:
          placeholderFadeInDuration ?? this.placeholderFadeInDuration,
      memCacheWidth: memCacheWidth ?? this.memCacheWidth,
      memCacheHeight: memCacheHeight ?? this.memCacheHeight,
      cacheKey: cacheKey ?? this.cacheKey,
      maxWidthDiskCache: maxWidthDiskCache ?? this.maxWidthDiskCache,
      maxHeightDiskCache: maxHeightDiskCache ?? this.maxHeightDiskCache,
    );
  }
}
