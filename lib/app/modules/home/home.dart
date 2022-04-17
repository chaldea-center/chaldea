import 'package:flutter/material.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/method_channel/method_channel_chaldea.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/widgets/after_layout.dart';
import '../../../models/db.dart';
import '../../app.dart';
import '../root/global_fab.dart';
import 'gallery_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin {
  int _curIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        db.saveAll();
        if (PlatformU.isAndroid) {
          if (Navigator.of(context).canPop()) {
            return Future.value(true);
          } else {
            MethodChannelChaldeaNext.sendBackground();
            print('sendBackground');
            return Future.value(false);
          }
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _curIndex,
          children: [GalleryPage(), SettingsPage()],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _curIndex,
          items: [
            BottomNavigationBarItem(
                icon: const SafeArea(child: Icon(Icons.layers)),
                label: S.current.gallery_tab_name),
            BottomNavigationBarItem(
                icon: const SafeArea(child: Icon(Icons.settings)),
                label: S.current.settings_tab_name),
          ],
          onTap: (index) {
            // if (_curIndex != index) db2.saveData();
            setState(() => _curIndex = index);
          },
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (db.settings.showWindowFab &&
        !(rootRouter.appState.showSidebar && SplitRoute.isSplit(null))) {
      WindowManagerFab.createOverlay(router.navigatorKey.currentContext!);
    }
    if (db.settings.showDebugFab) {
      DebugFab.createOverlay(router.navigatorKey.currentContext!);
    }
  }
}
