import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/simple_accordion.dart';
import 'package:chaldea/widgets/tile_items.dart';
import '../../../packages/packages.dart';
import 'elements/grid_gallery.dart';
import 'elements/news_carousel.dart';
import 'subpage/account_page.dart';

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
      await Future.delayed(const Duration(seconds: 2));
      // await AutoUpdateUtil.checkAppUpdate(
      //     background: true, download: db.appSetting.autoUpdateApp);
      // final _iconCache = IconCacheManager();
      // _iconCache.start(interval: const Duration(seconds: 1));
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
          if (db.settings.display.showAccountAtHome)
            InkWell(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 36,
                  minWidth: 48,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: db.onUserData((context, snapshot) => Text(
                          db.curUser.name,
                          textScaleFactor: 0.8,
                        )),
                  ),
                ),
              ),
              onTap: () {
                router.push(child: AccountPage());
              },
            ),
          if (!PlatformU.isMobile && db.settings.carousel.enabled)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: S.current.tooltip_refresh_sliders,
              onPressed: () async {
                EasyLoading.showToast(
                    '${S.current.tooltip_refresh_sliders} ...');
                await AppNewsCarousel.resolveSliderImageUrls(true);
                if (mounted) setState(() {});
              },
            ),
        ],
      ),
      body: db.settings.carousel.enabled
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
        final dataVersion = db.runtimeData.upgradableDataVersion;
        return ListView(
          controller: _scrollController,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight:
                      PlatformU.isDesktopOrWeb ? 0 : constraints.maxHeight),
              child: Column(
                children: [
                  if (db.settings.carousel.enabled)
                    AppNewsCarousel(maxWidth: constraints.maxWidth),
                  if (db.settings.carousel.enabled)
                    const Divider(height: 0.5, thickness: 0.5),
                  GridGallery(maxWidth: constraints.maxWidth),
                  if (dataVersion != null &&
                          dataVersion.timestamp >
                              db.gameData.version.timestamp ||
                      kDebugMode)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _dataUpdate(),
                    ),
                ],
              ),
            ),
            const ListTile(
              subtitle: Center(
                  child: AutoSizeText(
                '~~~~~ · ~~~~~',
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

  Widget _dataUpdate() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        InkWell(
          onTap: () async {
            EasyLoading.show(maskType: EasyLoadingMaskType.clear);
            final data = await GameDataLoader.instance.reload(offline: true);
            if (data == null) {
              EasyLoading.showError(S.current.failed);
              return;
            }
            EasyLoading.showSuccess(
                '${S.current.success}\n${data.version.text()}');
            db.gameData = data;
            if (mounted) setState(() {});
          },
          child: Text.rich(
            TextSpan(text: '${S.current.new_data_available}  ', children: [
              TextSpan(
                text: S.current.update,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              )
            ]),
            textScaleFactor: 0.8,
          ),
        ),
      ],
    );
  }

  List<Widget> get notifications {
    List<Widget> children = [];

    final path = db.paths.appPath.toLowerCase();
    if (PlatformU.isWindows &&
        (path.contains(r'appdata\local\temp') ||
            path.contains(r'c:\program files'))) {
      children.add(SimpleAccordion(
        expanded: true,
        headerBuilder: (_, __) => ListTile(
          title: Text(S.current.invalid_startup_path),
          subtitle: Text(db.paths.appPath),
        ),
        contentBuilder: (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(S.current.invalid_startup_path_info)),
      ));
    }

    children.add(SimpleAccordion(headerBuilder: (context, _) {
      return ListTile(
        leading: const Icon(Icons.translate),
        horizontalTitleGap: 0,
        title: Text(M.of(cn: '帮助改善翻译', na: 'Help Translation')),
      );
    }, contentBuilder: (context) {
      String url = 'https://docs.chaldea.center/translation.html';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(M.of(
                cn: '真的很缺很缺很缺>_<\n'
                    'UI文本、游戏文本仍需进一步完善翻译，对5种语言均有一定需求(按需求排序):\n'
                    '- 日语/繁中/韩语/英语/简中\n'
                    '如果您能够并希望帮助改善翻译，请通过以下地址联系！',
                na: 'WANTED! WANTED! WANTED! >_<\n'
                    'UI and game texts still need to be improved, all 5 languages are wanted(sort by demand):\n'
                    '- Japanese/Traditional Chinese/Korean/English/Simplified Chinese\n'
                    'If you are glad to help with it, please contact me through the following link.')),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: () {
                launch(url);
              },
              child: Text(url),
            ),
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: () {
                  launch(url);
                },
                child: const Text('Docs'),
              )
            ],
          )
        ],
      );
    }));

    return children;
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
          ListTile(
            title: Center(
              child: Text(S.current.test_info_pad,
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
          ListTile(
            title: const Text('UUID'),
            subtitle: Text(AppInfo.uuid),
          ),
          ListTile(
            title: Text(S.current.screen_size),
            trailing: Text(MediaQuery.of(context).size.toString()),
          ),
          ListTile(
            title: Text(S.current.dataset_version),
            trailing:
                Text(db.gameData.version.text(), textAlign: TextAlign.end),
          ),
        ]),
      ),
    );
  }
}
