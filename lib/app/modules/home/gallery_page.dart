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
import 'elements/random_image.dart';
import 'subpage/account_page.dart';

class GalleryPage extends StatefulWidget {
  GalleryPage({super.key});

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(kAppName),
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        toolbarHeight: kToolbarHeight,
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
                          textScaler: const TextScaler.linear(0.8),
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
                EasyLoading.showToast('${S.current.tooltip_refresh_sliders} ...');
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
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: PlatformU.isDesktopOrWeb ? 0 : constraints.maxHeight),
              child: Column(
                children: [
                  if (db.settings.carousel.enabled) AppNewsCarousel(maxWidth: constraints.maxWidth),
                  if (db.settings.carousel.enabled) const Divider(height: 0.5, thickness: 0.5),
                  GridGallery(
                    isHome: true,
                    maxWidth: constraints.maxWidth,
                  ),
                  if (dataVersion != null && dataVersion.timestamp > db.gameData.version.timestamp)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _dataUpdate(),
                    ),
                ],
              ),
            ),
            const RandomImageSurprise(),
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
            final data = await showEasyLoading(() => GameDataLoader.instance.reload(offline: true));
            if (data == null) {
              EasyLoading.showError(S.current.failed);
              return;
            }
            EasyLoading.showSuccess('${S.current.success}\n${data.version.text()}');
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
            textScaler: const TextScaler.linear(0.8),
          ),
        ),
      ],
    );
  }

  List<Widget> get notifications {
    List<Widget> children = [];

    if (PlatformU.isWindows && !db.paths.isAppPathValid) {
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
              child: Text(S.current.test_info_pad, style: const TextStyle(fontSize: 18)),
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
            trailing: Text(db.gameData.version.text(), textAlign: TextAlign.end),
          ),
        ]),
      ),
    );
  }
}
