// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Changes of original [__ModalRoute]
///
/// 1. add [__ModalRoute.hideBarrier]
///   - don't insert barrier overlay if hide
///   - make [__ModalRoute._modalBarrier] nullable
/// 2. add [__ModalRoute.overlayScopeBuilder]
///   - build the modalScope inside [__ModalRoute.createOverlayEntries]
///   - modify the behaviour of overlay, like wrap [Positioned]
///
/// Override them to modify

// ignore_for_file: unnecessary_null_comparison, unused_element
part of split_route;

class _DismissModalAction extends DismissAction {
  _DismissModalAction(this.context);

  final BuildContext context;

  @override
  bool isEnabled(DismissIntent intent) {
    final __ModalRoute<dynamic> route = __ModalRoute.of<dynamic>(context)!;
    return route.barrierDismissible;
  }

  @override
  Object invoke(DismissIntent intent) {
    return Navigator.of(context).maybePop();
  }
}

class _ModalScopeStatus extends InheritedWidget {
  const _ModalScopeStatus({
    Key? key,
    required this.isCurrent,
    required this.canPop,
    required this.route,
    required Widget child,
  })  : assert(isCurrent != null),
        assert(canPop != null),
        assert(route != null),
        assert(child != null),
        super(key: key, child: child);

  final bool isCurrent;
  final bool canPop;
  final Route<dynamic> route;

  @override
  bool updateShouldNotify(_ModalScopeStatus old) {
    return isCurrent != old.isCurrent ||
        canPop != old.canPop ||
        route != old.route;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(FlagProperty('isCurrent',
        value: isCurrent, ifTrue: 'active', ifFalse: 'inactive'));
    description.add(FlagProperty('canPop', value: canPop, ifTrue: 'can pop'));
  }
}

class _ModalScope<T> extends StatefulWidget {
  const _ModalScope({
    Key? key,
    required this.route,
  }) : super(key: key);

  final __ModalRoute<T> route;

  @override
  _ModalScopeState<T> createState() => _ModalScopeState<T>();
}

class _ModalScopeState<T> extends State<_ModalScope<T>> {
  Widget? _page;

  // This is the combination of the two animations for the route.
  late Listenable _listenable;

  /// The node this scope will use for its root [FocusScope] widget.
  final FocusScopeNode focusScopeNode =
      FocusScopeNode(debugLabel: '$_ModalScopeState Focus Scope');
  final ScrollController primaryScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final List<Listenable> animations = <Listenable>[
      if (widget.route.animation != null) widget.route.animation!,
      if (widget.route.secondaryAnimation != null)
        widget.route.secondaryAnimation!,
    ];
    _listenable = Listenable.merge(animations);
    if (widget.route.isCurrent) {
      widget.route.navigator!.focusScopeNode.setFirstFocus(focusScopeNode);
    }
  }

  @override
  void didUpdateWidget(_ModalScope<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.route == oldWidget.route);
    if (widget.route.isCurrent) {
      widget.route.navigator!.focusScopeNode.setFirstFocus(focusScopeNode);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _page = null;
  }

  void _forceRebuildPage() {
    setState(() {
      _page = null;
    });
  }

  @override
  void dispose() {
    focusScopeNode.dispose();
    super.dispose();
  }

  bool get _shouldIgnoreFocusRequest {
    return widget.route.animation?.status == AnimationStatus.reverse ||
        (widget.route.navigator?.userGestureInProgress ?? false);
  }

  // This should be called to wrap any changes to route.isCurrent, route.canPop,
  // and route.offstage.
  void _routeSetState(VoidCallback fn) {
    if (widget.route.isCurrent && !_shouldIgnoreFocusRequest) {
      widget.route.navigator!.focusScopeNode.setFirstFocus(focusScopeNode);
    }
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.route.restorationScopeId,
      builder: (BuildContext context, Widget? child) {
        assert(child != null);
        return RestorationScope(
          restorationId: widget.route.restorationScopeId.value,
          child: child!,
        );
      },
      child: _ModalScopeStatus(
        route: widget.route,
        isCurrent: widget.route.isCurrent,
        // _routeSetState is called if this updates
        canPop: widget.route.canPop,
        // _routeSetState is called if this updates
        child: Offstage(
          offstage: widget.route.offstage,
          // _routeSetState is called if this updates
          child: PageStorage(
            bucket: widget.route._storageBucket, // immutable
            child: Builder(
              builder: (BuildContext context) {
                return Actions(
                  actions: <Type, Action<Intent>>{
                    DismissIntent: _DismissModalAction(context),
                  },
                  child: PrimaryScrollController(
                    controller: primaryScrollController,
                    child: FocusScope(
                      node: focusScopeNode, // immutable
                      child: RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: _listenable, // immutable
                          builder: (BuildContext context, Widget? child) {
                            return widget.route.buildTransitions(
                              context,
                              widget.route.animation!,
                              widget.route.secondaryAnimation!,
                              AnimatedBuilder(
                                animation: widget.route.navigator
                                        ?.userGestureInProgressNotifier ??
                                    ValueNotifier<bool>(false),
                                builder: (BuildContext context, Widget? child) {
                                  final bool ignoreEvents =
                                      _shouldIgnoreFocusRequest;
                                  focusScopeNode.canRequestFocus =
                                      !ignoreEvents;
                                  return IgnorePointer(
                                    ignoring: ignoreEvents,
                                    child: child,
                                  );
                                },
                                child: child,
                              ),
                            );
                          },
                          child: _page ??= RepaintBoundary(
                            key: widget.route._subtreeKey, // immutable
                            child: Builder(
                              builder: (BuildContext context) {
                                return widget.route.buildPage(
                                  context,
                                  widget.route.animation!,
                                  widget.route.secondaryAnimation!,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom fields: []
abstract class __ModalRoute<T> extends TransitionRoute<T>
    with LocalHistoryRoute<T> {
  /// modified: added
  bool hideBarrier = false;

  /// modified: added
  Widget overlayScopeBuilder(BuildContext context, WidgetBuilder scopeBuilder) {
    return scopeBuilder(context);
  }

  __ModalRoute({
    RouteSettings? settings,
    this.filter,
  }) : super(settings: settings);

  final ui.ImageFilter? filter;

  @optionalTypeArgs
  static __ModalRoute<T>? of<T extends Object?>(BuildContext context) {
    final _ModalScopeStatus? widget =
        context.dependOnInheritedWidgetOfExactType<_ModalScopeStatus>();
    return widget?.route as __ModalRoute<T>?;
  }

  @protected
  void setState(VoidCallback fn) {
    if (_scopeKey.currentState != null) {
      _scopeKey.currentState!._routeSetState(fn);
    } else {
      fn();
    }
  }

  static RoutePredicate withName(String name) {
    return (Route<dynamic> route) {
      return !route.willHandlePopInternally &&
          route is __ModalRoute &&
          route.settings.name == name;
    };
  }

  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation);

  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }

  @override
  void install() {
    super.install();
    _animationProxy = ProxyAnimation(super.animation);
    _secondaryAnimationProxy = ProxyAnimation(super.secondaryAnimation);
  }

  @override
  TickerFuture didPush() {
    if (_scopeKey.currentState != null) {
      navigator!.focusScopeNode
          .setFirstFocus(_scopeKey.currentState!.focusScopeNode);
    }
    return super.didPush();
  }

  @override
  void didAdd() {
    if (_scopeKey.currentState != null) {
      navigator!.focusScopeNode
          .setFirstFocus(_scopeKey.currentState!.focusScopeNode);
    }
    super.didAdd();
  }

  bool get barrierDismissible;

  bool get semanticsDismissible => true;

  Color? get barrierColor;

  String? get barrierLabel;

  Curve get barrierCurve => Curves.ease;

  bool get maintainState;

  bool get offstage => _offstage;
  bool _offstage = false;

  set offstage(bool value) {
    if (_offstage == value) return;
    setState(() {
      _offstage = value;
    });
    _animationProxy!.parent =
        _offstage ? kAlwaysCompleteAnimation : super.animation;
    _secondaryAnimationProxy!.parent =
        _offstage ? kAlwaysDismissedAnimation : super.secondaryAnimation;
    changedInternalState();
  }

  BuildContext? get subtreeContext => _subtreeKey.currentContext;

  @override
  Animation<double>? get animation => _animationProxy;
  ProxyAnimation? _animationProxy;

  @override
  Animation<double>? get secondaryAnimation => _secondaryAnimationProxy;
  ProxyAnimation? _secondaryAnimationProxy;

  final List<WillPopCallback> _willPopCallbacks = <WillPopCallback>[];

  @override
  Future<RoutePopDisposition> willPop() async {
    final _ModalScopeState<T>? scope = _scopeKey.currentState;
    assert(scope != null);
    for (final WillPopCallback callback
        in List<WillPopCallback>.from(_willPopCallbacks)) {
      if (await callback() != true) return RoutePopDisposition.doNotPop;
    }
    return super.willPop();
  }

  void addScopedWillPopCallback(WillPopCallback callback) {
    assert(_scopeKey.currentState != null,
        'Tried to add a willPop callback to a route that is not currently in the tree.');
    _willPopCallbacks.add(callback);
  }

  void removeScopedWillPopCallback(WillPopCallback callback) {
    assert(_scopeKey.currentState != null,
        'Tried to remove a willPop callback from a route that is not currently in the tree.');
    _willPopCallbacks.remove(callback);
  }

  @protected
  bool get hasScopedWillPopCallback {
    return _willPopCallbacks.isNotEmpty;
  }

  @override
  void didChangePrevious(Route<dynamic>? previousRoute) {
    super.didChangePrevious(previousRoute);
    changedInternalState();
  }

  @override
  void changedInternalState() {
    super.changedInternalState();
    setState(() {
      /* internal state already changed */
    });
    _modalBarrier?.markNeedsBuild();
    _modalScope.maintainState = maintainState;
  }

  @override
  void changedExternalState() {
    super.changedExternalState();
    _modalBarrier?.markNeedsBuild();
    if (_scopeKey.currentState != null)
      _scopeKey.currentState!._forceRebuildPage();
  }

  bool get canPop => hasActiveRouteBelow || willHandlePopInternally;

  // Internals

  final GlobalKey<_ModalScopeState<T>> _scopeKey =
      GlobalKey<_ModalScopeState<T>>();
  final GlobalKey _subtreeKey = GlobalKey();
  final PageStorageBucket _storageBucket = PageStorageBucket();

  // one of the builders
  /// modified: make nullable
  OverlayEntry? _modalBarrier;

  Widget _buildModalBarrier(BuildContext context) {
    Widget barrier;
    if (barrierColor != null && barrierColor!.alpha != 0 && !offstage) {
      // changedInternalState is called if barrierColor or offstage updates
      assert(barrierColor != barrierColor!.withOpacity(0.0));
      final Animation<Color?> color = animation!.drive(
        ColorTween(
          begin: barrierColor!.withOpacity(0.0),
          end:
              barrierColor, // changedInternalState is called if barrierColor updates
        ).chain(CurveTween(
            curve:
                barrierCurve)), // changedInternalState is called if barrierCurve updates
      );
      barrier = AnimatedModalBarrier(
        color: color,
        dismissible: barrierDismissible,
        // changedInternalState is called if barrierDismissible updates
        semanticsLabel: barrierLabel,
        // changedInternalState is called if barrierLabel updates
        barrierSemanticsDismissible: semanticsDismissible,
      );
    } else {
      barrier = ModalBarrier(
        dismissible: barrierDismissible,
        // changedInternalState is called if barrierDismissible updates
        semanticsLabel: barrierLabel,
        // changedInternalState is called if barrierLabel updates
        barrierSemanticsDismissible: semanticsDismissible,
      );
    }
    if (filter != null) {
      barrier = BackdropFilter(
        filter: filter!,
        child: barrier,
      );
    }
    barrier = IgnorePointer(
      ignoring: animation!.status ==
              AnimationStatus
                  .reverse || // changedInternalState is called when animation.status updates
          animation!.status == AnimationStatus.dismissed,
      // dismissed is possible when doing a manual pop gesture
      child: barrier,
    );
    if (semanticsDismissible && barrierDismissible) {
      // To be sorted after the _modalScope.
      barrier = Semantics(
        sortKey: const OrdinalSortKey(1.0),
        child: barrier,
      );
    }
    return barrier;
  }

  // We cache the part of the modal scope that doesn't change from frame to
  // frame so that we minimize the amount of building that happens.
  Widget? _modalScopeCache;

  // one of the builders
  Widget _buildModalScope(BuildContext context) {
    // To be sorted before the _modalBarrier.
    return _modalScopeCache ??= Semantics(
      sortKey: const OrdinalSortKey(0.0),
      child: _ModalScope<T>(
        key: _scopeKey,
        route: this,
        // _ModalScope calls buildTransitions() and buildChild(), defined above
      ),
    );
  }

  late OverlayEntry _modalScope;

  @override
  Iterable<OverlayEntry> createOverlayEntries() sync* {
    /// modified
    if (!hideBarrier) {
      yield _modalBarrier = OverlayEntry(builder: _buildModalBarrier);
    }
    yield _modalScope = OverlayEntry(
      builder: (context) => overlayScopeBuilder(context, _buildModalScope),
      maintainState: maintainState,
    );
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'ModalRoute')}($settings, animation: unknown in custom modal route)';
}
