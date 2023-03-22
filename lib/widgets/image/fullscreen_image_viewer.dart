import 'package:chaldea/utils/extension.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'image_viewer.dart';

double get _kBackGestureWidth => 40.0;

class FullscreenImageViewer extends StatefulWidget {
  final List<Widget> children;
  final bool fullscreen;
  final PhotoViewOption photoViewOption;
  final PhotoViewGalleryOption galleryOption;

  FullscreenImageViewer({
    super.key,
    required this.children,
    this.fullscreen = true,
    PhotoViewOption? photoViewOption,
    this.galleryOption = const PhotoViewGalleryOption(),
  }) : photoViewOption = photoViewOption ?? PhotoViewOption.limited();

  FullscreenImageViewer.fromUrls({
    super.key,
    required List<String> urls,
    this.fullscreen = true,
    this.photoViewOption = const PhotoViewOption(),
    this.galleryOption = const PhotoViewGalleryOption(),
    CachedImageOption? cachedImageOption,
    bool showSaveOnLongPress = false,
  }) : children = urls
            .map((e) => CachedImage(
                  imageUrl: e,
                  cachedOption: cachedImageOption,
                  photoViewOption: photoViewOption,
                  showSaveOnLongPress: showSaveOnLongPress,
                  viewFullOnTap: false,
                  onTap: null,
                ))
            .toList();

  /// mostly used
  static Future show({
    required BuildContext context,
    required List<String?> urls,
    PlaceholderWidgetBuilder? placeholder,
    int? initialPage,
    bool opaque = false,
  }) {
    urls.removeWhere((v) => v == null);
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: opaque, // to avoid create new state of lower routes
        // fullscreenDialog: true,
        // add transition
        pageBuilder: (context, _, __) => FullscreenImageViewer(
          galleryOption: PhotoViewGalleryOption(
            pageController: initialPage == null ? null : PageController(initialPage: initialPage),
          ),
          children: List.generate(
            urls.length,
            (index) => CachedImage(
              imageUrl: urls[index],
              placeholder: placeholder,
              showSaveOnLongPress: true,
              viewFullOnTap: false,
              onTap: null,
              photoViewOption: PhotoViewOption.limited(),
              cachedOption: const CachedImageOption(
                fadeOutDuration: Duration(milliseconds: 1200),
                fadeInDuration: Duration(milliseconds: 800),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  _FullscreenImageViewerState createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  // int? _curIndex = 0;
  bool showAppBar = false;

  @override
  void initState() {
    super.initState();
    // if (widget.fullscreen) {
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // }
  }

  @override
  void dispose() {
    super.dispose();
    // if (widget.fullscreen) {
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //       overlays: SystemUiOverlay.values);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        Theme.of(context).isDarkMode ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('Image'),
              backgroundColor: bgColor.withOpacity(0.4),
            )
          : null,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () {
          Navigator.maybeOf(context)?.pop();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: MediaQuery.of(context).padding.add(const EdgeInsets.all(6)),
                child: gallery,
              ),
            ),
            barrier(right: null, width: _kBackGestureWidth),
            barrier(left: null, width: _kBackGestureWidth),
            barrier(top: null, height: _kBackGestureWidth),
            barrier(bottom: null, height: _kBackGestureWidth),
          ],
        ),
      ),
    );
  }

  Widget barrier({
    double? left = 0,
    double? top = 0,
    double? right = 0,
    double? bottom = 0,
    double width = double.infinity,
    double height = double.infinity,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: GestureDetector(
        onTap: () {
          print('press barrier: ${[left, top, right, bottom]}');
          // Navigator.pop(context);
          setState(() {
            showAppBar = !showAppBar;
          });
        },
        child: SizedBox(
          width: width,
          height: height,
        ),
      ),
    );
  }

  Widget get gallery {
    return PhotoViewGallery(
      pageOptions: [
        for (final child in widget.children)
          widget.photoViewOption
              .copyWith(onTapUp: (context, _, __) => Navigator.pop(context))
              .toOriginalWithChild(child)
      ],
      loadingBuilder: widget.galleryOption.loadingBuilder,
      backgroundDecoration: widget.galleryOption.backgroundDecoration,
      gaplessPlayback: widget.galleryOption.gaplessPlayback,
      reverse: widget.galleryOption.reverse,
      pageController: widget.galleryOption.pageController,
      onPageChanged: (index) {
        // _curIndex = index;
        return widget.galleryOption.onPageChanged?.call(index);
      },
      scaleStateChangedCallback: widget.galleryOption.scaleStateChangedCallback,
      enableRotation: widget.galleryOption.enableRotation,
      scrollPhysics: widget.galleryOption.scrollPhysics,
      scrollDirection: widget.galleryOption.scrollDirection,
      customSize: widget.galleryOption.customSize,
    );
  }
}
