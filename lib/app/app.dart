// App shared?
import 'package:chaldea/app/routes/root_delegate.dart';
import 'package:flutter/material.dart';

import 'routes/delegate.dart';

export 'routes/routes.dart';

final rootRouter = RootAppRouterDelegate();

AppRouterDelegate get router => rootRouter.appState.activeRouter;
