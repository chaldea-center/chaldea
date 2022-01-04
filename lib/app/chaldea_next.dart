import 'package:chaldea/modules/chaldea.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'app.dart';
import 'modules/root/global_fab.dart';
import 'routes/parser.dart';

class ChaldeaNext extends StatefulWidget {
  ChaldeaNext({Key? key}) : super(key: key);

  @override
  _ChaldeaNextState createState() => _ChaldeaNextState();
}

class _ChaldeaNextState extends State<ChaldeaNext> {
  final routeInformationParser = AppRouteInformationParser();
  final backButtonDispatcher = RootBackButtonDispatcher();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Chaldea',
      routeInformationParser: routeInformationParser,
      routerDelegate: rootRouter,
      backButtonDispatcher: backButtonDispatcher,
      debugShowCheckedModeBanner: false,
      theme: null,
      darkTheme: null,
      themeMode: ThemeMode.system,
      scrollBehavior: DraggableScrollBehavior(),
    );
  }

  bool showWindowFab = true;
  bool showDebugFab = true;

  @override
  void initState() {
    super.initState();
    if (showWindowFab && !rootRouter.appState.showSidebar) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        WindowManagerFab.createOverlay(router.navigatorKey.currentContext!);
      });
    }
    if (showDebugFab) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        DebugFab.createOverlay(router.navigatorKey.currentContext!);
      });
    }
  }
}
