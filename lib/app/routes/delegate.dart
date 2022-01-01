import 'package:chaldea/app/routes/root_delegate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'routes.dart';

class AppRouterDelegate extends RouterDelegate<RouteConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteConfiguration> {
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
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      _pages.add(RouteConfiguration.home().createPage());
    }
    return Navigator(
      key: navigatorKey,
      pages: List.of(_pages),
      onPopPage: onPopPage,
    );
  }

  bool onPopPage(Route route, dynamic result) {
    if (!route.didPop(result)) return false;
    if (canPop()) {
      _pages.removeLast();
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  bool canPop() {
    return _pages.length > 1;
  }

  @override
  Future<bool> popRoute() {
    if (canPop()) {
      _pages.removeLast();
      notifyListeners();
      return Future.value(true);
    }
    // send to background in android
    return Future.value(false);
  }

  void push({String? url, Widget? child, dynamic arguments, bool? detail}) {
    assert(url != null || child != null);
    _pages.add(RouteConfiguration(
      url: url,
      child: child,
      detail: detail,
      arguments: arguments,
    ).createPage());
    notifyListeners();
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
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

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
