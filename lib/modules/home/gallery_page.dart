import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/extras/updates.dart';
import 'package:chaldea/modules/home/subpage/account_page.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:url_launcher/url_launcher.dart';

import 'elements/grid_gallery.dart';
import 'elements/news_carousel.dart';

class GalleryPage extends StatefulWidget {
  GalleryPage({Key? key}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    Future.delayed(const Duration(seconds: 2)).then((_) async {
      if (!PlatformU.isWindows) {
        await rateMyApp.init();
        _showRateCard = rateMyApp.shouldOpenDialog || kDebugMode;
        if (mounted) setState(() {});
      }
      if (kDebugMode) return;
      if (db.appSetting.autoUpdateDataset) {
        await AutoUpdateUtil.patchGameData();
      }
      await Future.delayed(const Duration(seconds: 2));
      await AutoUpdateUtil.checkAppUpdate(
          background: true, download: db.appSetting.autoUpdateApp);
    }).onError((e, s) async {
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
        title: const Text(kAppName),
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        actions: <Widget>[
          if (db.appSetting.showAccountAtHome)
            InkWell(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 36,
                  minWidth: 48,
                  maxWidth: 64,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      db.curUser.name,
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 0.8,
                    ),
                  ),
                ),
              ),
              onTap: () {
                SplitRoute.push(context, AccountPage());
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
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
                constraints: BoxConstraints(
                    minHeight:
                        PlatformU.isDesktopOrWeb ? 0 : constraints.maxHeight),
                child: Column(
                  children: [
                    if (db.userData.carouselSetting.enabled)
                      AppNewsCarousel(maxWidth: constraints.maxWidth),
                    if (db.userData.carouselSetting.enabled)
                      const Divider(height: 0.5, thickness: 0.5),
                    GridGallery(maxWidth: constraints.maxWidth),
                  ],
                ),
              ),
              const ListTile(
                subtitle: Center(
                    child: AutoSizeText(
                  '~~~~~ ⁽⁽ଘ(ˊᵕˋ)ଓ⁾⁾* ~~~~~',
                  maxLines: 1,
                )),
              ),
              ...notifications,
              if (kDebugMode) buildTestInfoPad(),
            ],
          );
        },
      ),
    );
  }

  SharedPrefItem<bool> mac1014Alert = SharedPrefItem('mac1014Alert');

  List<Widget> get notifications {
    List<Widget> children = [];

    if (PlatformU.isMacOS && mac1014Alert.get() != false || kDebugMode) {
      children.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: _macIncompatibleWarning,
      ));
    }
    if (_showRateCard == true) {
      children.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: buildRateTile(),
      ));
    }
    return children;
  }

  Widget get _macIncompatibleWarning {
    return SimpleAccordion(
      headerBuilder: (context, _) => ListTile(
        leading: Icon(Icons.warning_amber_rounded,
            color: Theme.of(context).errorColor),
        contentPadding: const EdgeInsets.only(left: 8),
        horizontalTitleGap: 0,
        title: Text(LocalizedText.of(
            chs: 'macOS: 未来只支持10.14及之后系统',
            jpn: 'macOS: 将来、10.14以降が必要',
            eng: 'macOS: required at least 10.14 in future')),
      ),
      contentBuilder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTile(
              subtitle: Text(LocalizedText.of(
                chs: '如有问题，请联系开发者',
                jpn: 'ご不明な点がございましたら、開発者にお問い合わせください',
                eng: 'Contact developer if any question',
              )),
            ),
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      mac1014Alert.set(false);
                    });
                  },
                  child: Text(
                    S.current.ignore,
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
                ),
              ],
            )
          ],
        );
      },
      expanded: true,
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
      // canTapOnHeader: false,
      elevation: 0.5,
      topBorderSide: Divider.createBorderSide(context, width: 0.5),
      headerBuilder: (context, expanded) => ListTile(
        horizontalTitleGap: 0,
        leading: const Icon(Icons.stars_rounded),
        contentPadding: const EdgeInsets.only(left: 8),
        title: Text(LocalizedText.of(
            chs: '走过路过给个评价反馈吧~', jpn: 'アプリを評価する', eng: 'Rating Chaldea')),
        subtitle: AutoSizeText(
          LocalizedText.of(
              chs: '欢迎评分、评价、反馈、建议~',
              jpn: '評価またはレビューがかかりましょう',
              eng: 'Take a minute to rate/review'),
          maxLines: 1,
          style: expanded ? null : const TextStyle(color: Colors.transparent),
        ),
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
              launch(PlatformU.isAndroid
                  ? kGooglePlayLink
                  : PlatformU.isIOS || PlatformU.isMacOS
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
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: divideTiles(<Widget>[
          const ListTile(
            title: Center(
              child: Text('Test Info Pad', style: TextStyle(fontSize: 18)),
            ),
          ),
          ListTile(
            title: const Text('UUID'),
            subtitle: Text(AppInfo.uuid),
          ),
          ListTile(
            title: const Text('Screen size'),
            trailing: Text(MediaQuery.of(context).size.toString()),
          ),
          ListTile(
            title: const Text('Dataset version'),
            trailing: Text(db.gameData.version),
          ),
        ]),
      ),
    );
  }
}
