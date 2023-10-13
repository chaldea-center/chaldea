import 'package:flutter/foundation.dart';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/userdata/version.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../models/db.dart';
import '../../app.dart';
import '../battle/battle_home.dart';
import '../root/global_fab.dart';
import '../timer/timer_home.dart';
import 'gallery_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin {
  int _curIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _curIndex,
        children: [
          checkValidState(GalleryPage()),
          checkValidState(BattleHomePage()),
          checkValidState(TimerHomePage()),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: themeData.unselectedWidgetColor,
        selectedItemColor: switch (themeData.brightness) {
          Brightness.light => themeData.colorScheme.primary,
          Brightness.dark => themeData.colorScheme.secondary,
        },
        currentIndex: _curIndex,
        items: [
          const BottomNavigationBarItem(icon: SafeArea(child: Icon(Icons.blur_on_sharp)), label: 'Chaldeas'),
          const BottomNavigationBarItem(icon: SafeArea(child: Icon(Icons.bubble_chart)), label: 'Laplace'),
          const BottomNavigationBarItem(icon: SafeArea(child: Icon(Icons.timer_outlined)), label: 'Timer'),
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

  Widget checkValidState(Widget child) {
    String? forceUpgradeVersion = db.runtimeData.remoteConfig?.forceUpgradeVersion;
    List<Widget> errors = [];
    if (!db.gameData.isValid) {
      errors.add(Positioned.fill(
        child: Container(
          color: Colors.black38,
          child: SimpleCancelOkDialog(
            title: Text(S.current.gamedata),
            content: Text(S.current.game_data_not_found),
            hideCancel: true,
            hideOk: true,
          ),
        ),
      ));
    }
    if (!kIsWeb && forceUpgradeVersion != null) {
      final version = const AppVersionConverter().fromJson(forceUpgradeVersion);
      if (AppInfo.version < version) {
        errors.add(Positioned.fill(
          child: Container(
            color: Colors.black38,
            child: Center(
              child: SimpleCancelOkDialog(
                scrollable: true,
                title: Text(S.current.update),
                content: Text(
                  "${S.current.forced_update}: $forceUpgradeVersion+\n"
                  "${S.current.current_version}: ${AppInfo.versionString}",
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                hideCancel: true,
                hideOk: true,
                actions: [
                  TextButton(
                    onPressed: () {
                      launch(ChaldeaUrl.doc("/releases"));
                    },
                    child: Text(S.current.details),
                  ),
                ],
              ),
            ),
          ),
        ));
      }
    }
    if (errors.isNotEmpty) {
      child = Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(child: child),
          ...errors,
        ],
      );
    }
    return child;
  }
}
