/// Modify the [ModalRoute] and mixin [CupertinoRouteTransitionMixin]
/// to support Master-Detail view: non-barrier and swipe back support
///
/// Swipe back not supported for master route if there is any detail route
///
/// Tracking updates if framework updated:
/// Files:
///  - package:flutter/src/widgets/routes.dart
///  - package:flutter/src/widgets/pages.dart
///  - package:flutter/src/cupertino/route.dart
/// Version:
///  • Flutter version 2.1.0-13.0.pre.574
///  • Framework revision 02efffc134, 2021-04-10 03:49:01 -0400
///  • Engine revision 8863afff16
///  • Dart version 2.13.0 (build 2.13.0-222.0.dev)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:chaldea/app/routes/delegate.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/widgets/inherit_selection_area.dart';
import '../../utils/constants.dart' show kAppKey;
import '../logger.dart';

import 'package:flutter/cupertino.dart'
    show CupertinoFullscreenDialogTransition, CupertinoPageTransition, CupertinoRouteTransitionMixin;

part 'master_back_button.dart';

// ignore_for_file: unnecessary_null_comparison

const int _kSplitMasterRatio = 38;
const double _kSplitDividerWidth = 0.5;
const Duration kSplitRouteDuration = Duration(milliseconds: 400);

typedef SplitPageBuilder = Widget Function(BuildContext context, SplitLayout layout);

/// Layout type for [SplitRoute] when build widget
enum SplitLayout {
  /// don't use master-detail layout, build widget directly
  none,

  /// use master layout in split mode: MainWidget(left)+BlankPage(right)
  master,

  /// use detail layout in split mode: transparent route and only take right space
  detail,
}

/// Master-Detail Layout Route for large aspect ratio screen.
class SplitRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin<T> {
  static bool enableSplitView = true;

  static int _defaultMasterRatio = _kSplitMasterRatio;
  static int get defaultMasterRatio => _defaultMasterRatio;
  static set defaultMasterRatio(int? v) => _defaultMasterRatio = v == null ? _kSplitMasterRatio : v.clamp(30, 60);

  /// Expose BuildContext and SplitLayout to builder
  final SplitPageBuilder builder;

  /// whether to use detail layout if in split mode
  /// if null, don't use split view
  bool? _detail;

  bool? get detail => _detail;

  set detail(bool? v) {
    if (v == _detail) return;
    _detail = v;
    // changedInternalState();
    changedExternalState();
  }

  bool get master => _detail == false;

  /// Master page ratio of full-width, between 0~100
  final int? _masterRatio;
  int get masterRatio => _masterRatio ?? defaultMasterRatio;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final bool opaque;

  @override
  final bool maintainState;

  @override
  final String? title;

  SplitRoute({
    super.settings,
    required this.builder,
    bool? detail = false,
    int? masterRatio,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    bool? opaque,
    this.maintainState = true,
    this.title,
    super.fullscreenDialog = false,
  }) : assert(builder != null),
       assert(masterRatio == null || masterRatio > 0 && masterRatio < 100),
       assert(maintainState != null),
       assert(fullscreenDialog != null),
       _detail = detail,
       _masterRatio = masterRatio,
       transitionDuration = transitionDuration ?? kSplitRouteDuration,
       reverseTransitionDuration = reverseTransitionDuration ?? transitionDuration ?? kSplitRouteDuration,
       opaque = opaque ?? detail != true;

  /// define your own builder for right space of master page
  static WidgetBuilder? defaultMasterFillPageBuilder;

  bool? _lastSplitCache;
  TransitionRoute? _nextRouteCache;

  /// when switch layout from single view to master-detail view,
  /// update route to remove the secondaryAnimation
  @override
  Widget buildContent(BuildContext context) {
    Widget child;
    final layout = getLayout(context);
    switch (layout) {
      case SplitLayout.master:
        child = createMasterWidget(context: context, child: builder(context, layout), masterRatio: masterRatio);
        break;
      case SplitLayout.detail:
        child = builder(context, layout);
        break;
      case SplitLayout.none:
        child = builder(context, layout);
        break;
    }

    bool? _last = _lastSplitCache;
    bool _current = _lastSplitCache = isSplit(context);
    if (!isCurrent && _last == false && _current && _nextRouteCache != null) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        didChangeNext(_nextRouteCache!);
        _nextRouteCache!.didChangePrevious(this);
        // force rebuilding both modal and scope
        changedExternalState();
      });
      return Offstage(child: child);
    }
    if (db.settings.globalSelection) {
      child = InheritSelectionArea(child: child);
    }
    return child;
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() sync* {
    final entries = super.createOverlayEntries().toList();
    final _modalBarrier = entries[0], _modalScope = entries[1];

    if (detail != true) {
      yield _modalBarrier;
    }
    yield OverlayEntry(
      builder: (context) {
        Widget scope = _modalScope.builder(context);
        final layout = getLayout(context);
        if (layout == SplitLayout.detail) {
          final size = MediaQuery.of(context).size;
          final start = size.width * masterRatio / 100 + _kSplitDividerWidth;
          scope = PositionedDirectional(
            start: start,
            top: 0,
            child: SizedBox(height: size.height, width: size.width - start, child: scope),
          );
        }
        return scope;
      },
      opaque: _modalScope.opaque,
      maintainState: _modalScope.maintainState,
    );
  }

  static bool get isPopGestureAlwaysDisabled {
    if (kIsWeb || !PlatformU.isTargetMobile) return true;
    return false;
  }

  static bool get shouldPopGestureEnabled {
    if (isPopGestureAlwaysDisabled) return false;
    if (!db.settings.enableEdgeSwipePopGesture) return false;
    return true;
  }

  @override
  bool get popGestureEnabled {
    if (!shouldPopGestureEnabled) return false;
    return super.popGestureEnabled;
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    _nextRouteCache = nextRoute;
    if (isSplit(navigator?.context) && nextRoute is SplitRoute && nextRoute.detail == true) {
      return false;
    }
    return super.canTransitionTo(nextRoute);
  }

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    if (isSplit(navigator?.context) && previousRoute is SplitRoute && previousRoute.detail == true) {
      return false;
    }
    return super.canTransitionFrom(previousRoute);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!shouldPopGestureEnabled) {
      const bool linearTransition = false;
      if (fullscreenDialog) {
        child = CupertinoFullscreenDialogTransition(
          primaryRouteAnimation: animation,
          secondaryRouteAnimation: secondaryAnimation,
          linearTransition: linearTransition,
          child: child,
        );
      } else {
        child = CupertinoPageTransition(
          primaryRouteAnimation: animation,
          secondaryRouteAnimation: secondaryAnimation,
          linearTransition: linearTransition,
          child: child,
        );
      }
    } else {
      child = super.buildTransitions(context, animation, secondaryAnimation, child);
    }
    return ClipRect(child: child);
  }

  /// create master widget without scope wrapped
  static Widget createMasterWidget({
    required BuildContext context,
    required Widget child,
    int masterRatio = _kSplitMasterRatio,
  }) {
    if (!isSplit(context)) {
      return child;
    }
    final ltr = Directionality.maybeOf(context);
    return Row(
      children: <Widget>[
        Flexible(
          flex: masterRatio,
          child: MediaQuery.removePadding(
            context: context,
            removeLeft: ltr == TextDirection.rtl,
            removeRight: ltr == TextDirection.ltr,
            child: child,
          ),
        ),
        Flexible(
          flex: 100 - masterRatio,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: Divider.createBorderSide(
                  context,
                  width: _kSplitDividerWidth,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: defaultMasterFillPageBuilder?.call(context) ?? const Scaffold(),
          ),
        ),
      ],
    );
  }

  // static bool _isSplitCache = false;

  /// Check current size to use split view or not.
  /// When the height is too small, split view is disabled.
  static bool isSplit(BuildContext? context) {
    if (!enableSplitView) return false;
    if (context != null) {
      context = AppRouter.of(context)?.navigatorKey.currentContext ?? context;
    }
    context ??= kAppKey.currentContext;
    if (context == null) return false;
    final size = MediaQuery.of(context).size;
    return size.width > size.height && size.width >= 720 && size.height > 320;
  }

  SplitLayout getLayout(BuildContext context) {
    if (!enableSplitView) return SplitLayout.none;
    if (detail == null || !isSplit(context)) return SplitLayout.none;
    return detail! ? SplitLayout.detail : SplitLayout.master;
  }

  /// Pop all top detail routes
  ///
  /// return the number of popped pages
  static int popDetailRoutes(BuildContext context) {
    // whether to store all values returned by routes?
    final curRoute = SplitRoute.of(context);
    final isMaster = curRoute?.detail == false;
    assert(() {
      if (!isMaster) {
        throw StateError('DO NOT call popDetails outside SplitRoute or inside detail page');
      }
      return true;
    }());
    if (!isMaster) return 0;

    int n = 0;
    try {
      Navigator.of(context).popUntil((route) {
        bool isDetail = route is SplitRoute && route.detail == true;
        if (isDetail) {
          n += 1;
        }
        return !isDetail;
      });
    } on StateError catch (e, s) {
      logger.e('failed to popUntil', e, s);
    }

    return n;
  }

  static Future<T?> pushBuilder<T extends Object?>({
    required BuildContext context,
    required SplitPageBuilder builder,
    bool popDetail = false,
    bool? detail = true,
    int masterRatio = _kSplitMasterRatio,
    String? title,
    bool rootNavigator = false,
    RouteSettings? settings,
  }) {
    final navigator = Navigator.of(context, rootNavigator: rootNavigator);
    int n = 0;
    if (popDetail) {
      assert(() {
        final route = SplitRoute.of(context);
        if (route != null && route.detail == true) {
          throw StateError('DO NOT call pop detail in detail page');
        }
        return true;
      }());
      n = popDetailRoutes(context);
    }

    return navigator.push(
      SplitRoute(
        builder: builder,
        detail: detail,
        masterRatio: masterRatio,
        transitionDuration: (detail == true && popDetail && n > 0) ? const Duration() : kSplitRouteDuration,
        reverseTransitionDuration: kSplitRouteDuration,
        settings: settings,
        title: title,
      ),
    );
  }

  /// A simple form of [pushBuilder]
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget page, {
    bool? detail = true,
    bool popDetail = false,
    bool rootNavigator = false,
    RouteSettings? settings,
  }) {
    assert(() {
      settings ??= RouteSettings(name: page.runtimeType.toString());
      return true;
    }());
    return pushBuilder<T>(
      context: context,
      builder: (context, _) => page,
      detail: detail,
      popDetail: popDetail,
      rootNavigator: rootNavigator,
      settings: settings,
    );
  }

  static SplitRoute<T2>? of<T2 extends Object?>(BuildContext context) {
    final route = ModalRoute.of<T2>(context);
    if (route is SplitRoute<T2>) return route;
    return null;
  }

  static bool isDetail(BuildContext context) {
    return of(context)?.detail == true;
  }

  static bool isMaster(BuildContext context) {
    return of(context)?.detail == false;
  }
}
