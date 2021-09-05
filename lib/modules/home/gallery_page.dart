import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/extras/updates.dart';
import 'package:chaldea/modules/home/subpage/account_page.dart';
import 'package:open_file/open_file.dart';
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
      if (db.appSetting.autoUpdateDataset) {
        await AutoUpdateUtil.patchGameData();
      }
      await Future.delayed(Duration(seconds: 2));
      await AutoUpdateUtil.checkAppUpdate(
          background: true, download: db.appSetting.autoUpdateApp);
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
          if (db.appSetting.showAccountAtHome)
            InkWell(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 36,
                  minWidth: 48,
                  maxWidth: 56,
                ),
                child: Center(
                  child: Text(
                    db.curUser.name,
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: 0.8,
                  ),
                ),
              ),
              onTap: () {
                SplitRoute.push(context, AccountPage());
              },
            ),
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
                constraints: BoxConstraints(
                    minHeight: AppInfo.isDesktop ? 0 : constraints.maxHeight),
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
              ...notifications,
              if (kDebugMode) buildTestInfoPad(),
            ],
          );
        },
      ),
    );
  }

  SharedPrefItem<bool> winAppPathMigration =
      SharedPrefItem('winAppPathMigrationAlert');

  List<Widget> get notifications {
    List<Widget> children = [];
    if (Platform.isWindows && winAppPathMigration.get() != false ||
        kDebugMode) {
      children.add(Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: winAppPathMigrationTile,
      ));
    }
    if (_showRateCard == true)
      children.add(Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: buildRateTile(),
      ));
    return children;
  }

  Widget get winAppPathMigrationTile {
    void _openPath(String? p) {
      if (p == null) {
        EasyLoading.showError('Path is empty');
        return;
      }
      if (Directory(p).existsSync()) {
        OpenFile.open(p);
      } else {
        EasyLoading.showInfo(LocalizedText.of(
            chs: '路径不存在: $p', jpn: 'パスが存在しません: $p', eng: 'Path not exist: $p'));
      }
    }

    return SimpleAccordion(
      headerBuilder: (context, _) => ListTile(
        leading: Icon(Icons.warning_amber_rounded,
            color: Theme.of(context).errorColor),
        horizontalTitleGap: 0,
        title: Text(LocalizedText.of(
            chs: 'Windows: 用户文件夹迁移',
            jpn: 'Windows: ユーザーフォルダの移行',
            eng: 'Windows: user data folder migration')),
      ),
      contentBuilder: (context) {
        final pa = db.paths.legacyWinAppPath;
        final pb = db.paths.appPath;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(LocalizedText.of(
                  chs: '自v1.5.4起，应用/用户数据储存位置已迁移，若需要请手动迁移其他旧数据。\n'
                      '旧路径：$pa\n新路径: $pb',
                  jpn:
                      'v1.5.4以降、アプリ/ユーザーデータの保存場所が移行されました。必要に応じて、他の古いデータを手動で移行してください。\n'
                      '古いパス：$pa\n新しいパス: $pb',
                  eng:
                      'Since v1.5.4, the storage location of application/user data has been migrated. If necessary, please manually migrate other old data\n'
                      'Legacy path：$pa\nNew path: $pb')),
            ),
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () => _openPath(db.paths.legacyWinAppPath),
                  child: Text(LocalizedText.of(
                      chs: '旧路径', jpn: '古いパス', eng: 'Legacy Path')),
                ),
                TextButton(
                  onPressed: () => _openPath(db.paths.appPath),
                  child: Text(LocalizedText.of(
                      chs: '新路径', jpn: '新しいパス', eng: 'New Path')),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      winAppPathMigration.set(false);
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
      canTapOnHeader: false,
      elevation: 0.5,
      topBorderSide: Divider.createBorderSide(context, width: 0.5),
      headerBuilder: (context, expanded) => ListTile(
        horizontalTitleGap: 0,
        leading: Icon(Icons.stars_rounded),
        title: Text(LocalizedText.of(
            chs: '走过路过给个评价反馈吧~', jpn: 'アプリを評価する', eng: 'Rating Chaldea')),
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
            title: Text('UUID'),
            subtitle: Text(AppInfo.uuid),
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
