import 'package:flutter/material.dart';

import 'package:chaldea/app/modules/import_data/home_import_page.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/widgets/widgets.dart';
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
    return Scaffold(
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
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (db.userData.previousVersion == 2) {
      showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return SimpleCancelOkDialog(
            title: const Text('From Chaldea v1?'),
            content: const Text(
                'Please go to **Import-v1 backup** to restore v1 data'),
            onTapOk: () {
              router.pushPage(ImportPageHome());
            },
          );
        },
      );
    }
    if (mounted) {
      if (db.settings.display.showWindowFab &&
          !(rootRouter.appState.showSidebar && SplitRoute.isSplit(null))) {
        WindowManagerFab.createOverlay(context);
      }
      if (db.settings.showDebugFab) {
        DebugFab.createOverlay(context);
      }
    }
  }
}
