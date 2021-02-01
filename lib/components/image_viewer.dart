// @dart=2.12
import 'dart:math' show min;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';

import 'config.dart';

typedef Widget UriImageWidgetBuilder(BuildContext context, String url);

class FullScreenImageSlider extends StatefulWidget {
  final List<String> imgUrls;
  final int initialPage;
  final bool? enableDownload;
  final UriImageWidgetBuilder? placeholder;

  const FullScreenImageSlider(
      {Key? key,
      required this.imgUrls,
      this.initialPage = 0,
      this.enableDownload,
      this.placeholder})
      : super(key: key);

  @override
  _FullScreenImageSliderState createState() => _FullScreenImageSliderState();
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
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          await resetSystemUI();
          Navigator.of(context).pop(_curIndex);
          return false;
        },
        child: GFCarousel(
          items: List.generate(
            widget.imgUrls.length,
            (index) => GestureDetector(
              onTap: () async {
                await resetSystemUI();
                Navigator.of(context).pop(_curIndex);
              },
              child: CachedImageWidget(
                url: widget.imgUrls[index],
                enableDownload: widget.enableDownload,
                imageBuilder: (context, url) => CachedNetworkImage(
                  imageUrl: url,
                  placeholder: CachedImageWidget.defaultIndicatorBuilder,
                  errorWidget: (context, url, error) => Center(
                    child: Text('Error loading network image.\n$error'),
                  ),
                ),
                placeholder: widget.placeholder,
              ),
            ),
          ),
          autoPlay: false,
          viewportFraction: 1.0,
          height: MediaQuery.of(context).size.height,
          enableInfiniteScroll: false,
          initialPage: _curIndex,
          onPageChanged: (v) => _curIndex = v,
        ),
      ),
    );
  }
}

class CachedImageWidget extends StatefulWidget {
  final String url;
  final bool? enableDownload;
  final UriImageWidgetBuilder imageBuilder;
  final UriImageWidgetBuilder? placeholder;

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
              ),
            );
          },
        );
  }

  const CachedImageWidget(
      {Key? key,
      required this.url,
      this.enableDownload,
      required this.imageBuilder,
      this.placeholder})
      : super(key: key);

  @override
  _CachedImageWidgetState createState() => _CachedImageWidgetState();
}

class _CachedImageWidgetState extends State<CachedImageWidget> {
  final manager = DefaultCacheManager(); //singleton
  bool? cached;

  @override
  void initState() {
    super.initState();
    manager.getFileFromCache(widget.url).then((info) {
      if (mounted) {
        setState(() {
          cached = info != null; // ignore: unnecessary_null_comparison
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return cached == null
        ? Container()
        : cached == true ||
                (widget.enableDownload ?? db.runtimeData.enableDownload)
            ? widget.imageBuilder(context, widget.url)
            : widget.placeholder == null
                ? Center(child: Text('Downloading disabled.'))
                : widget.placeholder!(context, widget.url);
  }
}
