// App shared?
import 'package:chaldea/app/routes/root_delegate.dart';
import 'package:flutter/material.dart';

import '../packages/mob_stat.dart';
import 'routes/delegate.dart';

final rootRouter = RootAppRouterDelegate();

AppRouterDelegate get router => rootRouter.appState.activeRouter;

abstract class StateX<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    MobStat.pageStart(widget.runtimeType.toString());
  }

  @override
  void dispose() {
    super.dispose();
    MobStat.pageEnd(widget.runtimeType.toString());
  }
}
