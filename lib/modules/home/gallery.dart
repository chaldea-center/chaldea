import 'package:chaldea/components/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Gallery extends StatefulWidget {
  @override
  GalleryState createState() => GalleryState();
}

class GalleryState extends State<Gallery> {
  String selectedItem;
  List kGalleries;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Chaldea"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.accessibility),
              onPressed: () {
                db.onDataChange(locale:Locale('en', ''));
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
              crossAxisCount:isTablet(context)?
                  (MediaQuery.of(context).size.width / 768.0 * 3).floor():4,
              physics: ScrollPhysics(),
              shrinkWrap: true,
              childAspectRatio: 1.0,
              children: <Widget>[
              ],
            ),
            Text('widget width=${MediaQuery.of(context).size.width}'),
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

