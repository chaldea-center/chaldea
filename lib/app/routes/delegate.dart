import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:chaldea/models/gamedata/common.dart';
import 'package:chaldea/utils/extension.dart';
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
    final childBackButtonDispatcher = Router.of(context)
        .backButtonDispatcher
        ?.createChildBackButtonDispatcher();
    childBackButtonDispatcher?.takePriority();
    return Router(
      routerDelegate: widget.routerDelegate,
      backButtonDispatcher: childBackButtonDispatcher,
    );
  }
}

class AppRouterDelegate extends RouterDelegate<RouteConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteConfiguration> {
  static List<String> history = [];

  // final RootAppRouterDelegate _parent;
  final RootAppRouterDelegate _parent;

  AppRouterDelegate(this._parent) {
    addListener(_parent.notifyListeners);
  }

  final List<Page> _pages = [];

  List<Page> get pages => List.unmodifiable(_pages);

  @override
  RouteConfiguration? get currentConfiguration =>
      _pages.isNotEmpty && _pages.last.arguments is RouteConfiguration
          ? _pages.last.arguments as RouteConfiguration
          : null;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  UniqueKey _uniqueKey = UniqueKey();

  void forceRebuild() {
    _uniqueKey = UniqueKey();
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      _pages.add(RouteConfiguration.home().createPage());
    }
    return SizedBox(
      key: _uniqueKey,
      child: Navigator(
        key: navigatorKey,
        pages: List.of(_pages),
        onPopPage: onPopPage,
      ),
    );
  }

  Widget buildSpecific(BuildContext context, List<Page> pages) {
    _pages
      ..clear()
      ..addAll(pages);
    return build(context);
  }

  // only called when [Page] found
  bool onPopPage(Route route, dynamic result) {
    if (!route.didPop(result)) return false;
    if (canPop()) {
      _pages.removeLast();
    }
    notifyListeners();
    return true;
  }

  bool canPop() {
    return _pages.length > 1;
  }

  void popAll() {
    _pages.clear();
    notifyListeners();
  }

  void pushPage(
    Widget child, {
    dynamic arguments,
    bool? detail,
    bool popDetail = false,
  }) {
    popDetailAndPush(
      child: child,
      arguments: arguments,
      detail: detail,
      popDetail: popDetail,
    );
  }

  void pushBuilder({
    required WidgetBuilder builder,
    dynamic arguments,
    bool? detail,
    bool popDetail = false,
  }) {
    popDetailAndPush(
      child: Builder(builder: builder),
      arguments: arguments,
      detail: detail,
      popDetail: popDetail,
    );
  }

  void popDetailAndPush({
    String? url,
    Widget? child,
    dynamic arguments,
    bool? detail,
    bool popDetail = true,
  }) {
    if (popDetail) popDetails();
    push(
      url: url,
      child: child,
      arguments: arguments,
      detail: detail,
    );
  }

  void push({
    String? url,
    Widget? child,
    dynamic arguments,
    bool? detail,
    // bool popDetail = false,
    Region? region,
  }) {
    assert(url != null || child != null);
    // if (popDetail) popDetails();
    _pages.add(RouteConfiguration(
      url: url,
      child: child,
      detail: detail,
      arguments: arguments,
      region: region,
    ).createPage());
    if (url != null && url.trim().trimChar('/').isNotEmpty) {
      history.add(url);
    }
    notifyListeners();
  }

  // better to check current route is [master] before pop details
  // use `SplitRoute.isMaster`
  void popDetails() {
    while (canPop()) {
      final lastRoute = _pages.last;
      if (lastRoute is SplitPage && lastRoute.detail == true) {
        _pages.removeLast();
      } else {
        return;
      }
    }
  }

  void pop() {
    if (canPop()) {
      _pages.removeLast();
    }
  }

  void replace({
    String? url,
    Widget? child,
    dynamic arguments,
    bool? detail,
  }) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    assert(() {
      if (_pages.isEmpty && detail == true) {
        throw FlutterError('The bottom route should not be detail layout!\n'
            '${_pages.last.arguments}');
      }
      return true;
    }());
    push(url: url, child: child, arguments: arguments, detail: detail);
  }

  @override
  Future<void> setNewRoutePath(RouteConfiguration configuration) {
    if (Routes.masterRoutes.contains(configuration.first)) {
      configuration = configuration.copyWith(detail: false);
    }
    if (_pages.isEmpty || _pages.first.name != Routes.home) {
      _pages.insert(0, RouteConfiguration.home().createPage());
    }
    if (configuration.url != _pages.last.name) {
      _pages.add(configuration.createPage());
    }
    return SynchronousFuture(null);
  }
}
