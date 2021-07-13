import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewOption {
  // final ImageProvider? imageProvider;
  // final Widget? child;
  // final Size? childSize;

  // some ("x") is configured in not included in [PhotoViewGalleryPageOptions]
  final BoxDecoration? backgroundDecoration; //x
  final PhotoViewHeroAttributes? heroAttributes;
  final ValueChanged<PhotoViewScaleState>? scaleStateChangedCallback; //x
  final bool enableRotation; //x
  final PhotoViewController? controller;
  final PhotoViewScaleStateController? scaleStateController;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final Alignment? basePosition;
  final ScaleStateCycle? scaleStateCycle;
  final PhotoViewImageTapUpCallback? onTapUp;
  final PhotoViewImageTapDownCallback? onTapDown;
  final Size? customSize;
  final HitTestBehavior? gestureDetectorBehavior;
  final bool? tightMode;
  final FilterQuality? filterQuality;
  final bool? disableGestures;
  final ImageErrorWidgetBuilder? errorBuilder;

  const PhotoViewOption({
    this.backgroundDecoration = const BoxDecoration(color: Colors.transparent),
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.controller,
    this.scaleStateController,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.customSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableGestures,
    this.errorBuilder,
  });

  static PhotoViewOption limited({double minScale = 0.4, dynamic maxScale}) {
    return PhotoViewOption(
      minScale: PhotoViewComputedScale.contained * minScale,
      maxScale: maxScale,
    );
  }

  PhotoViewOption copyWith({
    BoxDecoration? backgroundDecoration,
    PhotoViewHeroAttributes? heroAttributes,
    ValueChanged<PhotoViewScaleState>? scaleStateChangedCallback,
    bool? enableRotation,
    PhotoViewController? controller,
    PhotoViewScaleStateController? scaleStateController,
    dynamic minScale,
    dynamic maxScale,
    dynamic initialScale,
    Alignment? basePosition,
    ScaleStateCycle? scaleStateCycle,
    PhotoViewImageTapUpCallback? onTapUp,
    PhotoViewImageTapDownCallback? onTapDown,
    Size? customSize,
    HitTestBehavior? gestureDetectorBehavior,
    bool? tightMode,
    FilterQuality? filterQuality,
    bool? disableGestures,
    ImageErrorWidgetBuilder? errorBuilder,
  }) {
    return PhotoViewOption(
      backgroundDecoration: backgroundDecoration ?? this.backgroundDecoration,
      heroAttributes: heroAttributes ?? this.heroAttributes,
      scaleStateChangedCallback:
          scaleStateChangedCallback ?? this.scaleStateChangedCallback,
      enableRotation: enableRotation ?? this.enableRotation,
      controller: controller ?? this.controller,
      scaleStateController: scaleStateController ?? this.scaleStateController,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      initialScale: initialScale ?? this.initialScale,
      basePosition: basePosition ?? this.basePosition,
      scaleStateCycle: scaleStateCycle ?? this.scaleStateCycle,
      onTapUp: onTapUp ?? this.onTapUp,
      onTapDown: onTapDown ?? this.onTapDown,
      customSize: customSize ?? this.customSize,
      gestureDetectorBehavior:
          gestureDetectorBehavior ?? this.gestureDetectorBehavior,
      tightMode: tightMode ?? this.tightMode,
      filterQuality: filterQuality ?? this.filterQuality,
      disableGestures: disableGestures ?? this.disableGestures,
      errorBuilder: errorBuilder ?? this.errorBuilder,
    );
  }

  PhotoViewGalleryPageOptions toOriginal(ImageProvider imageProvider) {
    return PhotoViewGalleryPageOptions(
      imageProvider: imageProvider,
      heroAttributes: heroAttributes,
      minScale: minScale,
      maxScale: maxScale,
      initialScale: initialScale,
      controller: controller,
      scaleStateController: scaleStateController,
      basePosition: basePosition,
      scaleStateCycle: scaleStateCycle,
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      gestureDetectorBehavior: gestureDetectorBehavior,
      tightMode: tightMode,
      filterQuality: filterQuality,
      disableGestures: disableGestures,
      errorBuilder: errorBuilder,
    );
  }

  PhotoViewGalleryPageOptions toOriginalWithChild(Widget child,
      [Size? childSize]) {
    return PhotoViewGalleryPageOptions.customChild(
      child: child,
      childSize: childSize,
      heroAttributes: heroAttributes,
      minScale: minScale,
      maxScale: maxScale,
      initialScale: initialScale,
      controller: controller,
      scaleStateController: scaleStateController,
      basePosition: basePosition,
      scaleStateCycle: scaleStateCycle,
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      gestureDetectorBehavior: gestureDetectorBehavior,
      tightMode: tightMode,
      filterQuality: filterQuality,
      disableGestures: disableGestures,
    );
  }
}

class PhotoViewGalleryOption {
  // final List<PhotoViewGalleryPageOptions>? pageOptions;
  // final int? itemCount;
  // final PhotoViewGalleryBuilder? builder;
  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final bool gaplessPlayback;
  final bool reverse;
  final PageController? pageController;
  final PhotoViewGalleryPageChangedCallback? onPageChanged;
  final ValueChanged<PhotoViewScaleState>? scaleStateChangedCallback;
  final bool enableRotation;
  final ScrollPhysics? scrollPhysics;
  final Axis scrollDirection;
  final Size? customSize;

  const PhotoViewGalleryOption({
    this.loadingBuilder,
    this.backgroundDecoration = const BoxDecoration(color: Colors.transparent),
    this.gaplessPlayback = false,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
    this.customSize,
  });

  PhotoViewGalleryOption copyWith({
    LoadingBuilder? loadingBuilder,
    BoxDecoration? backgroundDecoration,
    bool? gaplessPlayback,
    bool? reverse,
    PageController? pageController,
    PhotoViewGalleryPageChangedCallback? onPageChanged,
    ValueChanged<PhotoViewScaleState>? scaleStateChangedCallback,
    bool? enableRotation,
    ScrollPhysics? scrollPhysics,
    Axis? scrollDirection,
    Size? customSize,
  }) {
    return PhotoViewGalleryOption(
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      backgroundDecoration: backgroundDecoration ?? this.backgroundDecoration,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      reverse: reverse ?? this.reverse,
      pageController: pageController ?? this.pageController,
      onPageChanged: onPageChanged ?? this.onPageChanged,
      scaleStateChangedCallback:
          scaleStateChangedCallback ?? this.scaleStateChangedCallback,
      enableRotation: enableRotation ?? this.enableRotation,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      customSize: customSize ?? this.customSize,
    );
  }
}
