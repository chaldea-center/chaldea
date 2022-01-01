import 'package:flutter/material.dart';

import '../../components/constants.dart';
import '../modules/root/window_manager.dart';
import 'delegate.dart';
import 'routes.dart';

class AppState extends ChangeNotifier {
  bool _showWindowManager = false;

  bool get showWindowManager => _showWindowManager;

  set showWindowManager(bool v) {
    _showWindowManager = v;
    notifyListeners();
  }
}

class RootAppRouterDelegate extends RouterDelegate<RouteConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteConfiguration> {
  final appState = AppState();

  RootAppRouterDelegate() {
    _children = [
      AppRouterDelegate(this),
    ];
    appState.addListener(notifyListeners);
  }

  late final List<AppRouterDelegate> _children;

  List<AppRouterDelegate> get children => List.unmodifiable(_children);
  int _activeIndex = 0;

  int get activeIndex => _activeIndex;

  set activeIndex(int index) {
    if (index >= 0 && index < _children.length) {
      _activeIndex = index;
      notifyListeners();
    }
  }

  int addDelegate() {
    _children.add(AppRouterDelegate(this));
    _activeIndex = _children.length - 1;
    notifyListeners();
    return _activeIndex;
  }

  int removeDelegate(int index) {
    assert(index >= 0 && index < _children.length);
    if (index < 0 || index >= _children.length) {
      return -1;
    }
    if (_children.length == 1) return -1;
    final active = activeDelegate;
    _children.removeAt(index);
    int newIndex = _children.indexOf(active);
    _activeIndex = newIndex >= 0 ? newIndex : 0;
    notifyListeners();
    return _activeIndex;
  }

  AppRouterDelegate get activeDelegate => _children[_activeIndex];

  @override
  RouteConfiguration? get currentConfiguration =>
      activeDelegate.currentConfiguration;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(child: WindowManager(delegate: this)),
      ],
      onPopPage: (route, result) {
        if (appState.showWindowManager) {
          if (!route.didPop(result)) return false;
          appState.showWindowManager = false;
          return true;
        }
        return activeDelegate.onPopPage(route, result);
      },
    );
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => kAppKey;

  @override
  Future<void> setInitialRoutePath(RouteConfiguration configuration) {
    // TODO: do init and gamedata check
    return super.setInitialRoutePath(configuration);
  }

  @override
  Future<void> setNewRoutePath(RouteConfiguration configuration) {
    return activeDelegate.setNewRoutePath(configuration);
  }

  @override
  Future<bool> popRoute() {
    return activeDelegate.popRoute();
  }
}
