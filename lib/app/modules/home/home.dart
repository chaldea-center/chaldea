import 'package:flutter/foundation.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../models/db.dart';
import '../../app.dart';
import '../battle/battle_home.dart';
import '../root/global_fab.dart';
import 'gallery_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin {
  int _curIndex = 0;
  bool get showBattle =>
      kDebugMode ||
      AppInfo.isDebugDevice ||
      db.runtimeData.enableDebugTools ||
      (kIsWeb && kPlatformMethods.href.contains('battle.'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _curIndex.clamp(0, showBattle ? 2 : 1),
        children: [
          GalleryPage(),
          if (showBattle) BattleHomePage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _curIndex,
        items: [
          BottomNavigationBarItem(icon: const SafeArea(child: Icon(Icons.layers)), label: S.current.gallery_tab_name),
          if (showBattle)
            const BottomNavigationBarItem(icon: SafeArea(child: Icon(Icons.blur_on_sharp)), label: 'Chaldeas'),
          BottomNavigationBarItem(
              icon: const SafeArea(child: Icon(Icons.settings)), label: S.current.settings_tab_name),
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
    if (mounted) {
      if (db.settings.display.showWindowFab && !(rootRouter.appState.showSidebar && SplitRoute.isSplit(null))) {
        WindowManagerFab.createOverlay(context);
      }
      if (db.settings.showDebugFab) {
        DebugFab.createOverlay(context);
      }
    }
  }
}
