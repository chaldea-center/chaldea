import 'package:chaldea/_test_page.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:open_file/open_file.dart';

import '../../../models/db.dart';
import '../../app.dart';
import '../root/global_fab.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chaldea'),
        titleSpacing: 16,
      ),
      body: GridView.extent(
        maxCrossAxisExtent: 72,
        children: [
          IconButton(
            onPressed: () {
              router.push(url: '/servants', detail: false);
            },
            icon: const Icon(Icons.people_alt_outlined),
          ),
          IconButton(
            onPressed: () {
              testFunction(context);
            },
            icon: const Icon(Icons.adb),
          ),
          IconButton(
            onPressed: () {
              OpenFile.open(db2.paths.appPath);
            },
            icon: const Icon(Icons.folder),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (db2.settings.showWindowFab &&
        !(rootRouter.appState.showSidebar && SplitRoute.isSplit(null))) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        WindowManagerFab.createOverlay(router.navigatorKey.currentContext!);
      });
    }
    if (db2.settings.showDebugFab) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        DebugFab.createOverlay(router.navigatorKey.currentContext!);
      });
    }
  }
}
