// App shared?
import 'package:chaldea/app/routes/root_delegate.dart';

import 'routes/delegate.dart';

final rootRouter = RootAppRouterDelegate();

AppRouterDelegate get router => rootRouter.activeDelegate;
