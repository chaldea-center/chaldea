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

  const AppShell({
    super.key,
    required this.appState,
    required this.routerDelegate,
    this.active = false,
  });

  @override
  _AppShellState createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    final childBackButtonDispatcher = Router.of(context).backButtonDispatcher?.createChildBackButtonDispatcher();
    childBackButtonDispatcher?.takePriority();
    return Router(
      routerDelegate: widget.routerDelegate,
      backButtonDispatcher: childBackButtonDispatcher,
    );
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

  final List<_PageEntry> _history = [];

  List<Page> get pages => List.unmodifiable(_history.map((e) => e.page));

  @override
  RouteConfiguration? get currentConfiguration =>
      _history.isNotEmpty && _history.last.page.arguments is RouteConfiguration
          ? _history.last.page.arguments as RouteConfiguration
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
      _history.add(_PageEntry(RouteConfiguration.home().createPage(), Completer()));
    }

    return SizedBox(
      key: _uniqueKey,
      child: AppRouter(
        router: this,
        child: Navigator(
          key: navigatorKey,
          pages: pages,
          onPopPage: onPopPage,
        ),
      ),
    );
  }

  // only called when [Page] found
  bool onPopPage(Route route, dynamic result) {
    if (!route.didPop(result)) return false;
    assert(_history.any((p) => p.page == route.settings));
    bool handled = true;
    if (canPop()) {
      for (int index = _history.length - 1; index >= 0; index--) {
        if (_history[index].page == route.settings) {
          _history.removeAt(index).complete(result);
        }
      }
    } else {
      handled = false;
    }
    notifyListeners();
    return handled;
  }

  bool canPop() {
    return _history.length > 1;
  }

  void _doPop([dynamic result]) {
    _history.removeLast().complete(result);
  }

  void pop([dynamic result]) {
    if (canPop()) {
      _doPop(result);
    }
    notifyListeners();
  }

  void popAll() {
    while (canPop()) {
      _doPop();
    }
    notifyListeners();
  }

  void popUntil(bool Function(Page<dynamic> page) predicate) {
    while (canPop()) {
      final candidate = _history.last;
      if (predicate(candidate.page)) {
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
    final completer = Completer<T?>();
    _history.add(_PageEntry(page, completer));
    if (url != null && url.trim().trimChar('/').isNotEmpty) {
      urlHistory.add(url);
    }
    notifyListeners();
    final view = AppAnalysis.instance.startView(url ?? child?.runtimeType.toString());
    final result = await completer.future;
    AppAnalysis.instance.stopView(view);
    return result;
  }

  Future<T?> pushPage<T extends Object?>(
    Widget child, {
    dynamic arguments,
    bool? detail,
    bool popDetail = false,
  }) {
    return popDetailAndPush(
      child: child,
      arguments: arguments,
      detail: detail,
      popDetail: popDetail,
    );
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
    return push(
      url: url,
      child: child,
      arguments: arguments,
      detail: detail,
    );
  }

  // better to check current route is [master] before pop details
  // use `SplitRoute.isMaster`
  void popDetails() {
    while (canPop()) {
      final lastEntry = _history.last;
      final page = lastEntry.page;
      if (page is SplitPage && page.detail == true) {
        _history.remove(lastEntry);
        lastEntry.complete(null);
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
    BuildContext _context = [context, navigatorKey.currentContext, _parent.navigatorKey.currentContext]
        .firstWhere((e) => e != null && e.mounted)!;
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
    if (_history.isEmpty || _history.first.page.name != Routes.home) {
      _history.insert(0, _PageEntry.config(RouteConfiguration.home()));
    }
    if (configuration.url != _history.last.page.name) {
      _history.add(_PageEntry.config(configuration));
    }
    return SynchronousFuture(null);
  }
}

class _PageEntry<T> {
  final Page page;
  final Completer<T?> _completer;

  _PageEntry(this.page, [Completer<T?>? completer]) : _completer = completer ?? Completer();

  _PageEntry.config(RouteConfiguration config, [Completer<T?>? completer])
      : page = config.createPage(),
        _completer = completer ?? Completer();

  void complete([T? result]) {
    _completer.complete(result);
  }
}

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

  const _AppRouter({
    required this.router,
    required super.child,
  });

  @override
  bool updateShouldNotify(_AppRouter oldWidget) {
    return oldWidget.router != router;
  }
}
