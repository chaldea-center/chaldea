import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/modules/home/subpage/account_page.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/widgets/simple_accordion.dart';
import 'package:chaldea/widgets/tile_items.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../../packages/packages.dart';
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
          if (db2.settings.display.showAccountAtHome)
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
                      db2.curUser.name,
                      textScaleFactor: 0.8,
                    ),
                  ),
                ),
              ),
              onTap: () {
                SplitRoute.push(context, AccountPage());
              },
            ),
          if (!PlatformU.isMobile && db2.settings.carousel.enabled)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: S.current.tooltip_refresh_sliders,
              onPressed: () async {
                EasyLoading.showToast(
                    S.current.tooltip_refresh_sliders + ' ...');
                await AppNewsCarousel.resolveSliderImageUrls(true);
                if (mounted) setState(() {});
              },
            ),
        ],
      ),
      body: db2.settings.carousel.enabled
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
                  if (db2.settings.carousel.enabled)
                    AppNewsCarousel(maxWidth: constraints.maxWidth),
                  if (db2.settings.carousel.enabled)
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

  List<Widget> get notifications {
    List<Widget> children = [];

    final path = db2.paths.appPath.toLowerCase();
    if (PlatformU.isWindows &&
        (path.contains('appdata\\local\\temp') ||
            path.contains('c:\\program files'))) {
      children.add(SimpleAccordion(
        expanded: true,
        headerBuilder: (_, __) => ListTile(
          title: const Text('Invalid startup path!!!'),
          subtitle: Text(db2.paths.appPath),
        ),
        contentBuilder: (context) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Please extra zip to non-system path then start the app. "C:\\", "C:\\Program Files" are not allowed.',
            )),
      ));
    }

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
            trailing: Text(db2.gameData.version.text()),
          ),
        ]),
      ),
    );
  }
}
