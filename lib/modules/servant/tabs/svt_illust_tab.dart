import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaldea/components/components.dart';

import '../servant_detail_page.dart';
import 'svt_tab_base.dart';

class SvtIllustTab extends SvtTabBaseWidget {
  SvtIllustTab(
      {Key key,
      ServantDetailPageState parent,
      Servant svt,
      ServantStatus status})
      : super(key: key, parent: parent, svt: svt, status: status);

  @override
  _SvtIllustTabState createState() =>
      _SvtIllustTabState(parent: parent, svt: svt, plan: status);
}

class _SvtIllustTabState extends SvtTabBaseState<SvtIllustTab>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  _SvtIllustTabState(
      {ServantDetailPageState parent, Servant svt, ServantStatus plan})
      : super(parent: parent, svt: svt, status: plan);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: svt.info.illust.length, vsync: this);
    db.checkNetwork();
  }

  UriImageWidgetBuilder getPlaceholder() {
    String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
    return (context, url) => Image(
          image: db.getIconImage('${capitalize(svt.info.className)}${[
            '黑',
            '铜',
            '铜',
            '银',
            '金',
            '金'
          ][svt.info.rarity]}卡背'),
        );
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
                    child: Text(v['name'],
                        style: TextStyle(color: Colors.black87))))
                .toList()),
        Expanded(
          child: TabBarView(
              controller: _tabController,
              children: List.generate(svt.info.illust.length, (i) {
                final url = svt.info.illust[i]['url'];
                return MyCachedImage(
                  url: url,
                  imageBuilder: (context, url) => GestureDetector(
                    onTap: () async {
                      int newIndex =
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => FullScreenImageSlider(
                                    imgUrls: svt.info.illust
                                        .map((e) => e['url'])
                                        .toList(),
                                    initialPage: i,
                                    enableDownload:
                                        db.runtimeData.enableDownload,
                                    placeholder: getPlaceholder(),
                                  ),
                              fullscreenDialog: true));
                      setState(() {
                        _tabController.animateTo(newIndex);
                      });
                    },
                    child: CachedNetworkImage(
                      imageUrl: url,
                      placeholder: MyCachedImage.defaultIndicatorBuilder,
                    ),
                  ),
                  placeholder: getPlaceholder(),
                );
              })),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
