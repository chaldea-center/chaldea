import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chaldea/components/components.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtIllustTab extends SvtTabBaseWidget {
  SvtIllustTab(
      {Key key, ServantDetailPageState parent, Servant svt, ServantPlan plan})
      : super(key: key, parent: parent, svt: svt, plan: plan);

  @override
  _SvtIllustTabState createState() =>
      _SvtIllustTabState(parent: parent, svt: svt, plan: plan);
}

class _SvtIllustTabState extends SvtTabBaseState<SvtIllustTab>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  TabController _tabController;

  _SvtIllustTabState(
      {ServantDetailPageState parent, Servant svt, ServantPlan plan})
      : super(parent: parent, svt: svt, plan: plan);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: svt.info.illust.length, vsync: this);
    db.checkNetwork().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: svt.info.illust
                .map((v) => Tab(
                child: Text(
                  v['name'],
                  style: TextStyle(color: Colors.black87),
                )))
                .toList()),
        Expanded(
          child: TabBarView(
              controller: _tabController,
              children: List.generate(svt.info.illust.length, (i) {
                final url = svt.info.illust[i]['url'];
                return MyCachedImage(
                  url: url,
                  enableDownload: db.enableDownload,
                  imageBuilder: (context, url) => GestureDetector(
                    onTap: () async {
                      int newIndex =
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FullScreenImageSlider(
                            imgUrls: svt.info.illust
                                .map((e) => e['url'])
                                .toList(),
                            initialPage: i,
                            enableDownload: db.enableDownload,
                          ),
                          fullscreenDialog: true));
                      setState(() {
                        _tabController.animateTo(newIndex);
                      });
                    },
                    child: CachedNetworkImage(
                      imageUrl: url,
                      placeholder: MyCachedImage.defaultPlaceholder,
                    ),
                  ),
                );
              })),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}

class FullScreenImageSlider extends StatefulWidget {
  final List<String> imgUrls;
  final int initialPage;
  final bool enableDownload;

  const FullScreenImageSlider(
      {Key key, this.imgUrls, this.initialPage, this.enableDownload = true})
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(_curIndex);
          return false;
        },
        child: CarouselSlider(
          enableInfiniteScroll: false,
          viewportFraction: 1.0,
          aspectRatio: MediaQuery.of(context).size.aspectRatio,
          initialPage: widget.initialPage,
          onPageChanged: (_newIndex) => _curIndex = _newIndex,
          items: widget.imgUrls
              .map(
                (url) => GestureDetector(
                onTap: () => Navigator.of(context).pop(_curIndex),
                child: MyCachedImage(
                  url: url,
                  enableDownload: widget.enableDownload,
                  imageBuilder: (context, url) => CachedNetworkImage(
                    imageUrl: url,
                    placeholder: MyCachedImage.defaultPlaceholder,
                  ),
                )),
          )
              .toList(),
        )),);
  }
}

class MyCachedImage extends StatefulWidget {
  final String url;
  final bool enableDownload;
  final Widget Function(BuildContext context, String url) imageBuilder;

  static get defaultPlaceholder {
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

  const MyCachedImage(
      {Key key, this.url, this.enableDownload = true, this.imageBuilder})
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
        : cached == true || widget.enableDownload == true
            ? widget.imageBuilder(context, widget.url)
            : Center(
                child: Text('Mobile network downloading disabled.'),
              );
  }
}
