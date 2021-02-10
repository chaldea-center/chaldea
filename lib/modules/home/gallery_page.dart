import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/cmd_code/cmd_code_list_page.dart';
import 'package:chaldea/modules/craft/craft_list_page.dart';
import 'package:chaldea/modules/drop_calculator/drop_calculator_page.dart';
import 'package:chaldea/modules/event/events_page.dart';
import 'package:chaldea/modules/extras/ap_calc_page.dart';
import 'package:chaldea/modules/extras/mystic_code_page.dart';
import 'package:chaldea/modules/home/subpage/edit_gallery_page.dart';
import 'package:chaldea/modules/item/item_list_page.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';
import 'package:chaldea/modules/statistics/game_statistics_page.dart';
import 'package:flutter/foundation.dart';
import 'package:getwidget/getwidget.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> with AfterLayoutMixin {
  @override
  void afterFirstLayout(BuildContext context) {
    if (db.userData.sliderUpdateTime?.isNotEmpty != true ||
        db.userData.sliderUrls?.isEmpty == true) {
      resolveSliderImageUrls();
    } else {
      DateTime lastTime = DateTime.parse(db.userData.sliderUpdateTime),
          now = DateTime.now();
      int dt = now.millisecondsSinceEpoch - lastTime.millisecondsSinceEpoch;
      if (dt > 24 * 3600 * 1000) {
        // more than 1 day
        resolveSliderImageUrls();
      }
    }
    checkAppUpdate();
  }

  Future<Null> resolveSliderImageUrls() async {
    final srcUrl =
        'https://fgo.wiki/w/%E6%A8%A1%E6%9D%BF:%E8%87%AA%E5%8A%A8%E5%8F%96%E5%80%BC%E8%BD%AE%E6%92%AD';
    String tryDecodeUrl(String url) {
      String url2;
      if (url.toLowerCase().startsWith(RegExp(r'http|fgo.wiki'))) {
        url2 = url;
      } else if (url.toLowerCase().startsWith('//fgo.wiki')) {
        url2 = 'https:' + url;
      } else {
        url2 = 'https://fgo.wiki' + (url.startsWith('/') ? '' : '/') + url;
      }
      return url2;
    }

    try {
      print('http GET from "$srcUrl" .....');
      var response = await http.get(srcUrl);
      print('----------- recieved http response ------------');
      var body = parser.parse(response.body);
      db.userData.sliderUrls.clear();
      dom.Element element = body.getElementById('transImageBox');
      for (var linkNode in element.getElementsByTagName('a')) {
        String link = tryDecodeUrl(linkNode.attributes['href']);
        var imgNodes = linkNode.getElementsByTagName('img');
        if (imgNodes.isNotEmpty) {
          var imgUrl = tryDecodeUrl(imgNodes.first.attributes['src']);
          print('------resolved slider url------');
          db.userData.sliderUrls[imgUrl] = link;
          db.userData.sliderUpdateTime = DateTime.now().toString();
          print('imgUrl= "$imgUrl"\nhref  = "$link"');
        }
      }
      setState(() {});
      db.saveUserData();
      EasyLoading.showToast('Slides have been updated.');
    } catch (e) {
      print('Error refresh slides:\n$e');
      EasyLoading.showToast('Error refresh slides:\n$e');
    }
  }

  Map<String, GalleryItem> get kAllGalleryItems {
    return {
      GalleryItem.servant: GalleryItem(
        name: GalleryItem.servant,
        title: S.of(context).servant_title,
        icon: Icons.people,
        builder: (context, _) => ServantListPage(),
      ),
      GalleryItem.craft_essence: GalleryItem(
        name: GalleryItem.craft_essence,
        title: S.of(context).craft_essence,
        icon: Icons.extension,
        builder: (context, _) => CraftListPage(),
      ),
      GalleryItem.cmd_code: GalleryItem(
        name: GalleryItem.cmd_code,
        title: S.of(context).cmd_code_title,
        icon: Icons.stars,
        builder: (context, _) => CmdCodeListPage(),
      ),
      GalleryItem.item: GalleryItem(
        name: GalleryItem.item,
        title: S.of(context).item_title,
        icon: Icons.category,
        builder: (context, _) => ItemListPage(),
      ),
      GalleryItem.event: GalleryItem(
        name: GalleryItem.event,
        title: S.of(context).event_title,
        icon: Icons.event_available,
        builder: (context, _) => EventListPage(),
      ),
      GalleryItem.plan: GalleryItem(
        name: GalleryItem.plan,
        title: S.of(context).plan_title,
        icon: Icons.analytics,
        builder: (context, _) => ServantListPage(planMode: true),
        isDetail: false,
      ),
      GalleryItem.drop_calculator: GalleryItem(
        name: GalleryItem.drop_calculator,
        title: S.of(context).drop_calculator_short,
        icon: Icons.pin_drop,
        builder: (context, _) => DropCalculatorPage(),
        isDetail: true,
      ),
      GalleryItem.mystic_code: GalleryItem(
        name: GalleryItem.mystic_code,
        title: S.of(context).mystic_code,
        icon: Icons.toys,
        builder: (context, _) => MysticCodePage(),
        isDetail: true,
      ),
      // GalleryItem.calculator: GalleryItem(
      //   name: GalleryItem.calculator,
      //   title: S.of(context).calculator,
      //   icon: Icons.keyboard,
      //   builder: (context, _) => DamageCalcPage(),
      //   isDetail: true,
      // ),
      if (kDebugMode_)
        GalleryItem.ap_cal: GalleryItem(
          name: GalleryItem.ap_cal,
          title: S.of(context).ap_calc_title,
          icon: Icons.directions_run,
          builder: (context, _) => APCalcPage(),
          isDetail: true,
        ),
      GalleryItem.statistics: GalleryItem(
        name: GalleryItem.statistics,
        title: S.of(context).statistics_title,
        icon: Icons.analytics,
        builder: (context, _) => GameStatisticsPage(),
        isDetail: true,
      ),
      GalleryItem.more: GalleryItem(
        name: GalleryItem.more,
        title: S.of(context).more,
        icon: Icons.add,
        builder: (context, _) => EditGalleryPage(galleries: kAllGalleryItems),
        //fail
        isDetail: true,
      ),
      // if (kDebugMode_)
      //   'Test': GalleryItem(
      //     name: 'Test',
      //     title: 'Test',
      //     icon: Icons.adb,
      //     builder: (context, _) => TestPage(),
      //     isDetail: false,
      //   ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(kAppName),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              tooltip: S.of(context).tooltip_refresh_sliders,
              onPressed: () => resolveSliderImageUrls(),
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            _buildCarousel(),
            GridView.count(
              crossAxisCount: SplitRoute.isSplit(context) ? 4 : 4,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              childAspectRatio: 1,
              children: _getShownGalleries(context),
            ),
            if(kDebugMode)
              buildTestInfoPad(),
          ],
        ));
  }

  Widget _buildCarousel() {
    final sliderPages = _getSliderPages();
    return sliderPages.isEmpty
        ? AspectRatio(
            aspectRatio: 8 / 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: Divider.createBorderSide(context, width: 0.5),
                ),
              ),
            ),
          )
        : GFCarousel(
            items: sliderPages,
            aspectRatio: 8.0 / 3.0,
            pagination: true,
            autoPlay: sliderPages.length > 1,
            autoPlayInterval: Duration(seconds: 5),
            viewportFraction: 1.0,
          );
  }

  List<Widget> _getShownGalleries(BuildContext context) {
    List<Widget> _galleryItems = [];
    kAllGalleryItems.forEach((name, item) {
      if ((db.userData.galleries[name] ?? true) || name == GalleryItem.more) {
        _galleryItems.add(TextButton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Icon(item.icon, size: 40)),
              ),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AutoSizeText(
                    item.title,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.normal),
                    textAlign: TextAlign.center,
                    maxFontSize: 14,
                  ),
                ),
              )
            ],
          ),
          onPressed: () {
            if (item.builder != null) {
              SplitRoute.push(
                context: context,
                builder: item.builder,
                detail: item.isDetail,
                popDetail: true,
              );
            }
          },
        ));
      }
    });
    return _galleryItems;
  }

  List<Widget> _getSliderPages() {
    List<Widget> sliders = [];
    if (db.userData.sliderUrls.isEmpty) {
      resolveSliderImageUrls();
      return sliders;
    }
    final urls = db.userData.sliderUrls;
    urls.forEach((imgUrl, link) {
      sliders.add(GestureDetector(
        onTap: () => jumpToExternalLinkAlert(url: link, name: 'Mooncell'),
        child: CachedImage(
          imageUrl: imgUrl,
          connectivity: db.connectivity,
          downloadEnabled: true,
          errorWidget: (context, url, error) => Container(),
        ),
      ));
    });
    return sliders;
  }

  Widget buildTestInfoPad() {
    return Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: divideTiles(<Widget>[
            ListTile(
              title: Center(
                child: Text('Test Info Pad', style: TextStyle(fontSize: 18)),
              ),
            ),
            ListTile(
              title: Text('Screen size'),
              trailing: Text(MediaQuery.of(context).size.toString()),
            ),
            ListTile(
              title: Text('Dataset version'),
              trailing: Text(db.gameData.version),
            ),
          ]),
        ));
  }
}
