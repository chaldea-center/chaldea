// App shared?

import 'package:chaldea/app/routes/root_delegate.dart';
import 'routes/delegate.dart';

export 'routes/routes.dart';

final rootRouter = RootAppRouterDelegate();

AppRouterDelegate get router => rootRouter.appState.activeRouter;

mixin RouteInfo {
  String get route;
  void routeTo() {
    router.push(url: route);
  }
}
