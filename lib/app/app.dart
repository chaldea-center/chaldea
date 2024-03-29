// App shared?

import 'package:flutter/material.dart';

import 'package:chaldea/app/routes/root_delegate.dart';
import 'routes/delegate.dart';

export 'routes/routes.dart';

final rootRouter = RootAppRouterDelegate();

AppRouterDelegate get router => rootRouter.appState.activeRouter;

mixin RouteInfo {
  String get route;
  void routeTo({Widget? child, bool popDetails = false}) {
    router.popDetailAndPush(url: route, child: child, popDetail: popDetails);
  }
}
