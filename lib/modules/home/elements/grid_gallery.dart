import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import 'gallery_item.dart';

class GridGallery extends StatefulWidget {
  final double? maxWidth;

  const GridGallery({Key? key, this.maxWidth}) : super(key: key);

  @override
  _GridGalleryState createState() => _GridGalleryState();
}

class _GridGalleryState extends State<GridGallery> {
  @override
  void initState() {
    super.initState();
    db.userData.galleries.removeWhere(
        (key, value) => GalleryItem.allItems.every((item) => item.name != key));
  }

  @override
  Widget build(BuildContext context) {
    int crossCount;
    if (widget.maxWidth != null &&
        widget.maxWidth! > 0 &&
        widget.maxWidth != double.infinity) {
      crossCount = widget.maxWidth! ~/ 80;
      crossCount = fixValidRange(crossCount, 2, 8);
    } else {
      crossCount = 4;
    }

    Widget grid = GridView.count(
      padding: EdgeInsets.all(8),
      crossAxisCount: crossCount,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      childAspectRatio: 1,
      children: _getShownGalleries(context),
    );
    if (db.gameData.version.length < 2) {
      grid = GestureDetector(
        onTap: () {
          SimpleCancelOkDialog(
            title: Text('Gamedata Error'),
            content: Text(S.current.reload_default_gamedata),
            onTapOk: () async {
              await db.loadZipAssets(kDatasetAssetKey);
              db.loadGameData();
              db.notifyAppUpdate();
            },
          ).showDialog(context);
        },
        child: AbsorbPointer(
          child: Opacity(
            opacity: 0.5,
            child: grid,
          ),
        ),
      );
    }
    return grid;
  }

  List<Widget> _getShownGalleries(BuildContext context) {
    List<Widget> _galleryItems = [];
    GalleryItem.allItems.forEach((item) {
      if (db.userData.galleries[item.name] == false &&
          !GalleryItem.persistentPages.contains(item)) {
        return;
      }
      _galleryItems.add(InkWell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: item.buildIcon(context),
              ),
            ),
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.topCenter,
                child: AutoSizeText(
                  item.titleBuilder(),
                  style: TextStyle(fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                  maxFontSize: 14,
                ),
              ),
            )
          ],
        ),
        onTap: () {
          if (item.page != null) {
            SplitRoute.push(
              context,
              item.page!,
              detail: item.isDetail,
              popDetail: true,
            ).then((value) => db.saveUserData());
          }
        },
      ));
    });
    return _galleryItems;
  }
}
