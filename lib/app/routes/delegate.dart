import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';

import 'package:chaldea/models/gamedata/common.dart';
import 'package:chaldea/packages/analysis/analysis.dart';
import 'package:chaldea/utils/extension.dart';
import '../../packages/split_route/split_route.dart';
import 'root_delegate.dart';
import 'routes.dart';

class AppShell extends StatefulWidget {
  final AppState appState;
  final AppRouterDelegate routerDelegate;
  final bool active;

  const AppShell({super.key, required this.appState, required this.routerDelegate, this.active = false});

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    final childBackButtonDispatcher = Router.of(context).backButtonDispatcher?.createChildBackButtonDispatcher();
    childBackButtonDispatcher?.takePriority();
    return Router(routerDelegate: widget.routerDelegate, backButtonDispatcher: childBackButtonDispatcher);
  }
}

class AppRouterDelegate extends RouterDelegate<RouteConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteConfiguration> {
  static List<String> urlHistory = [];

  // final RootAppRouterDelegate _parent;
  final RootAppRouterDelegate _parent;

  AppRouterDelegate(this._parent) {
    addListener(_parent.notifyListeners);
  }

  final List<SplitPage> _history = [];

  List<Page> get pages => List.unmodifiable(_history);

  int get index => _parent.appState.children.indexOf(this);

  @override
  RouteConfiguration? get currentConfiguration => _history.isNotEmpty && _history.last.arguments is RouteConfiguration
      ? _history.last.arguments as RouteConfiguration
      : null;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  UniqueKey _uniqueKey = UniqueKey();

  void forceRebuild() {
    _uniqueKey = UniqueKey();
  }

  @override
  Widget build(BuildContext context) {
    if (_history.isEmpty) {
      _history.add(RouteConfiguration.home().createPage());
    }

    return SizedBox(
      key: _uniqueKey,
      child: AppRouter(
        router: this,
        child: Navigator(
          key: navigatorKey,
          pages: pages,
          // onPopPage: onPopPage,
          onDidRemovePage: onPopPage,
        ),
      ),
    );
  }

  // only called when [Page] found
  void onPopPage(Page page) {
    if (canPop()) {
      for (int index = _history.length - 1; index >= 0; index--) {
        if (_history[index] == page) {
          _history.removeAt(index);
          break;
        }
      }
    }
    notifyListeners();
  }

  bool canPop() {
    return _history.length > 1;
  }

  void _doPop([dynamic result]) {
    _history.removeLast().complete(result);
  }

  void clearHistory() {
    _history.clear();
  }

  void pop([dynamic result]) {
    if (canPop()) {
      _doPop(result);
    }
    notifyListeners();
  }

  void popAll() {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
    notifyListeners();
  }

  void popUntil(bool Function(Page<dynamic> page) predicate) {
    while (canPop()) {
      final candidate = _history.last;
      if (predicate(candidate)) {
        return;
      }
      pop();
    }
  }

  Future<T?> push<T extends Object?>({
    String? url,
    Widget? child,
    dynamic arguments,
    bool? detail,
    // bool popDetail = false,
    Region? region,
  }) async {
    assert(url != null || child != null);
    // if (popDetail) popDetails();
    final page = RouteConfiguration(
      url: url,
      child: child,
      detail: detail,
      arguments: arguments,
      region: region,
    ).createPage();
    _history.add(page);
    if (url != null && url.trim().trimChar('/').isNotEmpty) {
      urlHistory.add(url);
    }
    notifyListeners();
    final view = AppAnalysis.instance.startView(url ?? child?.runtimeType.toString());
    final result = await page.completer.future;
    AppAnalysis.instance.stopView(view);
    return result;
  }

  Future<T?> pushPage<T extends Object?>(Widget child, {dynamic arguments, bool? detail, bool popDetail = false}) {
    return popDetailAndPush(child: child, arguments: arguments, detail: detail, popDetail: popDetail);
  }

  Future<T?> pushBuilder<T extends Object?>({
    required WidgetBuilder builder,
    dynamic arguments,
    bool? detail,
    bool popDetail = false,
  }) {
    return popDetailAndPush(
      child: Builder(builder: builder),
      arguments: arguments,
      detail: detail,
      popDetail: popDetail,
    );
  }

  Future<T?> popDetailAndPush<T extends Object?>({
    BuildContext? context,
    String? url,
    Widget? child,
    dynamic arguments,
    bool? detail,
    bool? popDetail,
  }) {
    if (popDetail == null && context != null && context.mounted) {
      popDetail = !SplitRoute.isDetail(context);
    }
    if (popDetail ?? true) popDetails();
    return push(url: url, child: child, arguments: arguments, detail: detail);
  }

  // better to check current route is [master] before pop details
  // use `SplitRoute.isMaster`
  void popDetails() {
    while (canPop()) {
      final page = _history.last;
      if (page.detail == true) {
        _history.remove(page);
        page.complete(null);
      } else {
        return;
      }
    }
  }

  Future<T?> showDialog<T>({
    BuildContext? context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = false,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) {
    BuildContext _context = [
      context,
      navigatorKey.currentContext,
      _parent.navigatorKey.currentContext,
    ].firstWhere((e) => e != null && e.mounted)!;
    return material.showDialog(
      context: _context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
    );
  }

  @override
  Future<void> setNewRoutePath(RouteConfiguration configuration) {
    if (Routes.masterRoutes.contains(configuration.first)) {
      configuration = configuration.copyWith(detail: false);
    }
    if (_history.isEmpty || _history.first.name != Routes.home) {
      _history.insert(0, RouteConfiguration.home().createPage());
    }
    final url = configuration.url;
    if (url != _history.last.name) {
      // skip android widget callback
      if (url != null && url.startsWith('/CALLBACK') && url.contains('appWidgetId')) {
        return SynchronousFuture(null);
      }
      _history.add(configuration.createPage());
    }
    return SynchronousFuture(null);
  }
}

// @Deprecated('message')
// class _PageEntry<T> {
//   final Page page;
//   final Completer<T?> _completer;

//   _PageEntry(this.page, [Completer<T?>? completer]) : _completer = completer ?? Completer();

//   _PageEntry.config(RouteConfiguration config, [Completer<T?>? completer])
//       : page = config.createPage(),
//         _completer = completer ?? Completer();

//   void complete([T? result]) {
//     _completer.complete(result);
//   }
// }

class AppRouter extends StatelessWidget {
  final AppRouterDelegate router;
  final Widget child;
  const AppRouter({super.key, required this.child, required this.router});

  @override
  Widget build(BuildContext context) {
    return _AppRouter(router: router, child: child);
  }

  static AppRouterDelegate? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AppRouter>()?.router;
  }
}

class _AppRouter extends InheritedWidget {
  final AppRouterDelegate router;

  const _AppRouter({required this.router, required super.child});

  @override
  bool updateShouldNotify(_AppRouter oldWidget) {
    return oldWidget.router != router;
  }
}
