import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/extras/updates.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';

import 'elements/grid_gallery.dart';
import 'elements/news_carousel.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    Future.delayed(Duration(seconds: 2)).then((_) async {
      if (!Platform.isWindows) {
        await rateMyApp.init();
        _showRateCard = rateMyApp.shouldOpenDialog || kDebugMode;
        if (mounted) setState(() {});
      }
      if (kDebugMode) return;
      if (db.userData.autoUpdateDataset) {
        await AutoUpdateUtil.patchGameData();
      }
      await Future.delayed(Duration(seconds: 2));
      await AutoUpdateUtil.checkAppUpdate(
          background: true, download: db.userData.autoUpdateApp);
    }).onError((e, s) {
      logger.e('init app extras', e, s);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
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
            onPressed: () async {
              await AppNewsCarousel.resolveSliderImageUrls(true);
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            controller: _scrollController,
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    AppNewsCarousel(maxWidth: constraints.maxWidth),
                    const Divider(height: 0.5, thickness: 0.5),
                    GridGallery(maxWidth: constraints.maxWidth),
                  ],
                ),
              ),
              ListTile(
                subtitle: Center(
                    child: AutoSizeText(
                  '~~~~~ ⁽⁽ଘ(ˊᵕˋ)ଓ⁾⁾* ~~~~~',
                  maxLines: 1,
                )),
              ),
              if (_showRateCard == true)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: buildRateTile(),
                ),
              if (kDebugMode) buildTestInfoPad(),
            ],
          );
        },
      ),
    );
  }

  /// Notifications
  bool? _showRateCard;
  final RateMyApp rateMyApp = RateMyApp(
    minDays: 15,
    minLaunches: 50,
    remindDays: 75,
    remindLaunches: 100,
    appStoreIdentifier: '1548713491',
    googlePlayIdentifier: 'cc.narumi.chaldea',
  );

  Widget buildRateTile() {
    return SimpleAccordion(
      canTapOnHeader: false,
      elevation: 0.5,
      topBorderSide: Divider.createBorderSide(context, width: 0.5),
      headerBuilder: (context, expanded) => ListTile(
        horizontalTitleGap: 0,
        leading: Icon(Icons.stars_rounded),
        title: Text(LocalizedText.of(
            chs: '走过路过给个评分吧', jpn: 'アプリを評価する', eng: 'Rating Chaldea')),
        subtitle: expanded
            ? AutoSizeText(
                LocalizedText.of(
                    chs: '评分、评价、反馈建议等均欢迎~',
                    jpn: '評価またはレビューがかかりましょう',
                    eng: 'Take a minute to rate/review'),
                maxLines: 1,
              )
            : Text(' '),
      ),
      contentBuilder: (context) => ButtonBar(
        alignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed);
              setState(() {
                _showRateCard = false;
              });
            },
            child: Text(LocalizedText.of(chs: '取消', jpn: '後で', eng: 'DISMISS'),
                style: TextStyle(color: Theme.of(context).disabledColor)),
          ),
          TextButton(
            onPressed: () async {
              rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);
              launch(Platform.isAndroid
                  ? kGooglePlayLink
                  : Platform.isIOS || Platform.isMacOS
                      ? kAppStoreLink
                      : kGooglePlayLink);
              setState(() {
                _showRateCard = false;
              });
            },
            child: Text(LocalizedText.of(chs: '评分', jpn: '評価', eng: 'RATE')),
          ),
        ],
      ),
    );
  }

  /// TEST
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
      ),
    );
  }
}
