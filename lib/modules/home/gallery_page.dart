import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/event/event_list_page.dart';
import 'package:chaldea/modules/home/subpage/edit_gallery_page.dart';
import 'package:chaldea/modules/item/item_list_page.dart';
import 'package:chaldea/modules/servant/servant_list_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  Map<String, GalleryItem> kAllGalleryItems;

  Future<Null> resolveSliderImageUrls({bool reload = false}) async {
    final url = 'https://fgo.wiki/w/模板:自动取值轮播';
    String tryDecodeUrl(String url) {
      String url2;
      if (url.toLowerCase().startsWith(RegExp(r'http|fgo.wiki'))) {
        url2 = url;
      } else if (url.toLowerCase().startsWith('//fgo.wiki')) {
        url2 = 'https:' + url;
      } else {
        url2 = 'https://fgo.wiki' + (url.startsWith('/') ? '' : '/') + url;
      }
      try {
        url2 = Uri.decodeComponent(url2);
      } catch (e) {
        // print('decode url failed:\n $e');
      } finally {
        // print('url: "$url2"');
      }
      return url2;
    }

    if (db.userData.sliderUrls.isEmpty || reload) {
      db.userData.sliderUrls.clear();
      try {
        print('http GET from "$url" .....');
        var response = await http.get(url);
        print('----------- recieved http response ------------');
        var body = parser.parse(response.body);
        dom.Element element = body.getElementById('transImageBox');
        for (var linkNode in element.getElementsByTagName('a')) {
          String link = tryDecodeUrl(linkNode.attributes['href']);
          var imgNodes = linkNode.getElementsByTagName('img');
          if (imgNodes.isNotEmpty) {
            var imgUrl = tryDecodeUrl(imgNodes.first.attributes['src']);
            print('------resolved slider url------');
            db.userData.sliderUrls[imgUrl] = link;
            print('imgUrl= "$imgUrl"\nhref  = "$link"');
          }
        }
        setState(() {});
        db.saveData();
      } catch (e) {
        print('http error: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    resolveSliderImageUrls();
    kAllGalleryItems = {
      GalleryItem.servant: GalleryItem(
          name: GalleryItem.servant,
          titleBuilder: (context) => S.of(context).servant_title,
          icon: Icons.people,
          builder: (context) => ServantListPage()),
      GalleryItem.item: GalleryItem(
          name: GalleryItem.item,
          titleBuilder: (context) => S.of(context).item_title,
          icon: Icons.category,
          builder: (context) => ItemListPage()),
      GalleryItem.event: GalleryItem(
          name: GalleryItem.event,
          titleBuilder: (context) => S.of(context).event_title,
          icon: Icons.event_available,
          builder: (context) => EventListPage()),
      GalleryItem.more: GalleryItem(
          name: GalleryItem.more,
          titleBuilder: (context) => S.of(context).more,
          icon: Icons.add,
          builder: (context) => EditGalleryPage(galleries: kAllGalleryItems),
          isDetail: true)
    };
  }

  List<Widget> _getAllGalleries(BuildContext context) {
    List<Widget> _galleryItems = [];
    kAllGalleryItems.forEach((name, item) {
      if ((db.userData.galleries[name] ?? true) || name == GalleryItem.more) {
        _galleryItems.add(FlatButton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Icon(item.icon,
                        size: 40, color: Theme.of(context).primaryColor)),
              ),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AutoSizeText(
                    item.titleBuilder(context),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
          onPressed: () {
            SplitRoute.popAndPush(context,
                builder: item.builder, isDetail: item.isDetail);
          },
        ));
      }
    });
    return _galleryItems;
  }

  List<Widget> _getSliderPages() {
    List<Widget> sliders = [];
    db.userData.sliderUrls.forEach((imgUrl, link) {
      sliders.add(GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              child: AlertDialog(
                title: Text('Jump to Mooncell?'),
                content: Text(
                  link,
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(S.of(context).cancel)),
                  FlatButton(
                      onPressed: () async {
                        if (await canLaunch(link)) {
                          launch(link);
                          Navigator.of(context).pop();
                        } else {
                          throw 'Could not launch $link';
                        }
                      },
                      child: Text(S.of(context).ok))
                ],
              ));
        },
        child: CachedNetworkImage(
          imageUrl: imgUrl,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ));
    });
    return sliders;
  }

  @override
  Widget build(BuildContext context) {
    var sliderPages = _getSliderPages();
    return Scaffold(
        appBar: AppBar(
          title: Text("Chaldea"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () async {
                  await resolveSliderImageUrls(reload: true);
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Homepage sliders have been updated.')));
                }),
          ],
        ),
        body: ListView(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 8 / 3,
              child: Swiper(
                itemBuilder: (BuildContext context, int index) =>
                    sliderPages[index],
                itemCount: sliderPages.length,
                autoplay: !kDebugMode && sliderPages.length > 1,
                pagination: SwiperPagination(margin: const EdgeInsets.all(1)),
                autoplayDelay: 5000,
              ),
            ),
            GridView.count(
              crossAxisCount: 4,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              childAspectRatio: 1,
              children: _getAllGalleries(context),
            ),
            buildTestInfoPad()
          ],
        ));
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
              title: Text('Assets version'),
              trailing: Text(getAssetsVersion()),
            ),
          ]),
        ));
  }

  String getAssetsVersion() {
    final file = db.getLocalFile('VERSION', rel: db.userData.gameDataPath);
    return file.existsSync()
        ? file.readAsStringSync()
        : 'VERSION file not exist.';
  }
}
