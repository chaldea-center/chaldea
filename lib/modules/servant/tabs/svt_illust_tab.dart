import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chaldea/components/components.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: Column(
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
                  return Center(
                    child: GestureDetector(
                      onTap: () async {
                        int newIndex =
                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => FullScreenImageViewer(
                                      imgUrls: svt.info.illust
                                          .map((e) => e['url'])
                                          .toList(),
                                      initialPage: i,
                                    ),
                                fullscreenDialog: true));
                        setState(() {
                          _tabController.animateTo(newIndex);
                        });
                      },
                      child: CachedNetworkImage(
                        imageUrl: svt.info.illust[i]['url'],
                        placeholder: (context, s) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    ),
                  );
                })),
          )
        ],
      ),
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

class FullScreenImageViewer extends StatefulWidget {
  final List<String> imgUrls;
  final int initialPage;

  const FullScreenImageViewer({Key key, this.imgUrls, this.initialPage})
      : super(key: key);

  @override
  _FullScreenImageViewerState createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  int _curIndex;

  @override
  void initState() {
    super.initState();
    _curIndex = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      viewportFraction: 1.0,
      aspectRatio: MediaQuery.of(context).size.aspectRatio,
      initialPage: widget.initialPage,
      onPageChanged: (_newIndex) => _curIndex = _newIndex,
      items: widget.imgUrls
          .map((url) => GestureDetector(
                onTap: () => Navigator.of(context).pop(_curIndex),
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: url,
                    placeholder: (context, _) => CircularProgressIndicator(),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
