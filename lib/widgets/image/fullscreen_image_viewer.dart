import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'image_viewer.dart';

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
                showSaveOnLongPress: widget.allowSave,
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
