import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/home/subpage/edit_gallery_page.dart';
import 'package:chaldea/modules/item/item_page.dart';
import 'package:chaldea/modules/servant/servant_overview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Gallery extends StatefulWidget {
  @override
  GalleryState createState() => GalleryState();
}

class GalleryState extends State<Gallery> {
  String selectedItem;
  Map<String, GalleryItem> kAllGalleryItems;
  List<String> shownGalleryItems;

  @override
  void initState() {
    super.initState();
    // here db.data has not fully loaded. (loading)
    if (db.data.galleries == null) {
      // set default value
      print('why galleries=null ????');
      db.data.galleries = {};
    }
  }

  void _getAllGalleries(BuildContext context) {
    GalleryItem.allItems = {
      GalleryItem.servant: GalleryItem(
          title: S.of(context).servant_title,
          icon: Icons.people,
          routeName: '/servant',
          builder: (context) => ServantPage()),
      GalleryItem.item: GalleryItem(
          title: S.of(context).item_title,
          icon: Icons.category,
          routeName: '/item',
          builder: (context) => ItemPage()),
      GalleryItem.more: GalleryItem(
          title: S.of(context).more,
          icon: Icons.add,
          routeName: '/more',
          builder: (context) => EditGalleryPage())
    };
    db.data.galleries = GalleryItem.allItems.map((key, item) {
      return MapEntry<String, bool>(key, db.data.galleries[key] ?? false);
    });
    db.data.galleries[GalleryItem.more] = true;
  }

  @override
  Widget build(BuildContext context) {
    _getAllGalleries(context);
    List<Widget> gridItems = [];
    db.data.galleries.forEach((v, isShown) {
      if (isShown || v == GalleryItem.more) {
        final item = GalleryItem.allItems[v];
        gridItems.add(DecoratedBox(
          decoration: BoxDecoration(),
          child: FlatButton(
            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Icon(
                        item.icon,
                        size: 45.0,
                        color: Theme.of(context).primaryColor,
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.title,
                        style: TextStyle(fontSize: 15.0),
                      )
                    ],
                  ),
                )
              ],
            ),
            onPressed: () {
//              Navigator.of(context).push(MaterialPageRoute(builder: item.builder));
//              return;
              SplitRoute.popAndPush(context,
                  builder: item.builder,
                  settings: RouteSettings(
                      name: item.routeName,
                      isInitialRoute: item.isInitialRoute ?? false));
            },
          ),
        ));
      }
    });

    return Scaffold(
        appBar: AppBar(
          title: Text("Chaldea"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.accessibility),
              onPressed: () {
                db.onDataChange(locale: Locale('en', ''));
              },
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 8.0 / 3.0,
              child: Slider(<String>[
                "https://fgo.wiki/images/7/7d/Saber_Wars%E5%A4%8D%E5%88%BB.png",
                "https://fgo.wiki/images/e/ec/%E5%94%A0%E5%94%A0%E5%8F%A8%E5%8F%A8%E5%B8%9D%E9%83%BD%E5%9C%A3%E6%9D%AF%E5%A5%87%E8%B0%AD%E5%A4%8D%E5%88%BB_jp.png",
              ]),
            ),
            GridView.count(
              crossAxisCount: isTablet(context)
                  ? (MediaQuery.of(context).size.width / 768.0 * 3).floor()
                  : 4,
              physics: ScrollPhysics(),
              shrinkWrap: true,
              childAspectRatio: 1.0,
              children: gridItems,
            ),
          ],
        ));
  }
}

class Slider extends StatefulWidget {
  final List<String> imgUrls;

  //<String>[
  // "https://fgo.wiki/images/e/ec/%E5%94%A0%E5%94%A0%E5%8F%A8%E5%8F%A8%E5%B8%9D%E9%83%BD%E5%9C%A3%E6%9D%AF%E5%A5%87%E8%B0%AD%E5%A4%8D%E5%88%BB_jp.png",
  // "https://fgo.wiki/images/7/7d/Saber_Wars%E5%A4%8D%E5%88%BB.png"
  //]
  const Slider(this.imgUrls);

  @override
  State<StatefulWidget> createState() => _SliderState();
}

class _SliderState extends State<Slider> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (null == widget.imgUrls) return null;
    return Swiper(
      itemBuilder: (BuildContext context, int index) {
        return CachedNetworkImage(
          imageUrl: widget.imgUrls[index],
          placeholder: (context, url) => Center(
                child: CircularProgressIndicator(),
              ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        );
      },
      itemCount: widget.imgUrls.length,
      autoplay: true,
      pagination: SwiperPagination(margin: const EdgeInsets.all(1.0)),
      autoplayDelay: 5000,
    );
  }
}
