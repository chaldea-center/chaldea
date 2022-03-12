import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/extras/icon_cache_manager.dart';
import 'package:chaldea/modules/extras/updates.dart';
import 'package:chaldea/modules/home/subpage/account_page.dart';

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
      if (kDebugMode || AppInfo.isDebugDevice) return;
      if (db.appSetting.autoUpdateDataset) {
        await AutoUpdateUtil.patchGameData();
      }
      await Future.delayed(const Duration(seconds: 2));
      await AutoUpdateUtil.checkAppUpdate(
          background: true, download: db.appSetting.autoUpdateApp);
      final _iconCache = IconCacheManager();
      _iconCache.start(interval: const Duration(seconds: 1));
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
          if (!PlatformU.isMobile && db.userData.carouselSetting.enabled)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: S.of(context).tooltip_refresh_sliders,
              onPressed: () async {
                EasyLoading.showToast(
                    S.current.tooltip_refresh_sliders + ' ...');
                await AppNewsCarousel.resolveSliderImageUrls(true);
                if (mounted) setState(() {});
              },
            ),
        ],
      ),
      body: db.userData.carouselSetting.enabled
          ? RefreshIndicator(
              child: body,
              onRefresh: () async {
                await AppNewsCarousel.resolveSliderImageUrls(true);
                if (mounted) setState(() {});
              },
            )
          : body,
    );
  }

  Widget get body {
    return LayoutBuilder(
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
    final path = db.paths.appPath.toLowerCase();
    if (PlatformU.isWindows &&
        (path.contains('appdata\\local\\temp') ||
            path.contains('c:\\program files'))) {
      children.add(SimpleAccordion(
        expanded: true,
        headerBuilder: (_, __) => ListTile(
          title: Text(LocalizedText.of(
            chs: '无效启动路径!!!',
            jpn: '起動パスが無効です!!!',
            eng: 'Invalid startup path!!!',
          )),
          subtitle: Text(db.paths.appPath),
        ),
        contentBuilder: (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              LocalizedText.of(
                chs: '请解压至非系统目录后运行！例如"C:\\", "C:\\Program Files"等均无效。',
                jpn:
                    'システム以外のディレクトリに解凍して実行してください。"C:\\"、"C:\\Program Files"は許可されていません。',
                eng:
                    'Please extra zip to non-system path then start the app. "C:\\", "C:\\Program Files" are not allowed.',
              ),
            )),
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
            eng: 'macOS: required at least 10.14 in future',
            kor: 'macOS: 미래에는 10.14 이후가 필요')),
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
                kor: '불편한 점이 있으시다면 개발자에게 문의해주시길 바랍니다',
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
