import 'dart:math' show min;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'config.dart';

typedef Widget UriImageWidgetBuilder(BuildContext context, String url);

class FullScreenImageSlider extends StatefulWidget {
  final List<String> imgUrls;
  final int initialPage;
  final bool enableDownload;
  final UriImageWidgetBuilder placeholder;

  const FullScreenImageSlider(
      {Key key,
      this.imgUrls,
      this.initialPage,
      this.enableDownload,
      this.placeholder})
      : super(key: key);

  @override
  _FullScreenImageSliderState createState() => _FullScreenImageSliderState();
}

class _FullScreenImageSliderState extends State<FullScreenImageSlider> {
  int _curIndex;

  @override
  void initState() {
    super.initState();
    _curIndex = widget.initialPage;
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop(_curIndex);
            return false;
          },
          child: Swiper(
            itemBuilder: (BuildContext context, int index) => GestureDetector(
                onTap: () => Navigator.of(context).pop(_curIndex),
                child: MyCachedImage(
                  url: widget.imgUrls[index],
                  enableDownload: widget.enableDownload,
                  imageBuilder: (context, url) => CachedNetworkImage(
                    imageUrl: url,
                    placeholder: MyCachedImage.defaultIndicatorBuilder,
                    errorWidget: (context, url, error) => Center(
                      child: Text('Error loading network image.\n$error'),
                    ),
                  ),
                  placeholder: widget.placeholder,
                )),
            itemCount: widget.imgUrls.length,
            autoplay: false,
            loop: false,
            index: _curIndex,
            onIndexChanged: (newIndex) => _curIndex = newIndex,
          )),
    );
  }
}

class MyCachedImage extends StatefulWidget {
  final String url;
  final bool enableDownload;
  final UriImageWidgetBuilder imageBuilder;
  final UriImageWidgetBuilder placeholder;

  static get defaultIndicatorBuilder {
    return (BuildContext context, String url) => LayoutBuilder(
          builder: (context, constraints) {
            final width = 0.3 *
                min(constraints.biggest.width, constraints.biggest.height);
            return Center(
                child: SizedBox(
              width: width,
              height: width,
              child: CircularProgressIndicator(),
            ));
          },
        );
  }

  const MyCachedImage(
      {Key key,
      this.url,
      this.enableDownload,
      this.imageBuilder,
      this.placeholder})
      : super(key: key);

  @override
  _MyCachedImageState createState() => _MyCachedImageState();
}

class _MyCachedImageState extends State<MyCachedImage> {
  final manager = DefaultCacheManager();
  bool cached;

  @override
  void initState() {
    super.initState();
    manager.getFileFromCache(widget.url).then((info) {
      if (mounted) {
        setState(() {
          cached = info != null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return cached == null
        ? Container()
        : cached == true ||
                (widget.enableDownload ?? db.runtimeData.enableDownload ?? true)
            ? widget.imageBuilder(context, widget.url)
            : widget.placeholder == null
                ? Center(child: Text('Downloading disabled.'))
                : widget.placeholder(context, widget.url);
  }
}
