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

import 'package:flutter/cupertino.dart' show CupertinoRouteTransitionMixin;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../utils/constants.dart' show kAppKey;
import '../mob_stat.dart';

part 'master_back_button.dart';

// ignore_for_file: unnecessary_null_comparison

const int _kSplitMasterRatio = 38;
const double _kSplitDividerWidth = 0.5;
const Duration kSplitRouteDuration = Duration(milliseconds: 400);

typedef SplitPageBuilder = Widget Function(
    BuildContext context, SplitLayout layout);

/// Layout type for [SplitRoute] when build widget
enum SplitLayout {
  /// don't use master-detail layout, build widget directly
  none,

  /// use master layout in split mode: MainWidget(left)+BlankPage(right)
  master,

  /// use detail layout in split mode: transparent route and only take right space
  detail
}

/// Master-Detail Layout Route for large aspect ratio screen.
class SplitRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin<T> {
  /// Expose BuildContext and SplitLayout to builder
  final SplitPageBuilder builder;

  /// whether to use detail layout if in split mode
  /// if null, don't use split view
  bool? _detail;

  bool? get detail => _detail;

  set detail(bool? detail) {
    if (detail == _detail) return;
    _detail = detail;
    changedInternalState();
  }

  bool get master => _detail == false;

  /// Master page ratio of full-width, between 0~100
  final int masterRatio;

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
    RouteSettings? settings,
    required this.builder,
    bool? detail = false,
    this.masterRatio = _kSplitMasterRatio,
    this.transitionDuration = kSplitRouteDuration,
    Duration? reverseTransitionDuration,
    bool? opaque,
    this.maintainState = true,
    this.title,
    bool fullscreenDialog = false,
  })  : assert(builder != null),
        assert(masterRatio > 0 && masterRatio < 100),
        assert(maintainState != null),
        assert(fullscreenDialog != null),
        _detail = detail,
        reverseTransitionDuration =
            reverseTransitionDuration ?? transitionDuration,
        opaque = opaque ?? detail != true,
        super(settings: settings, fullscreenDialog: fullscreenDialog);

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
        child = createMasterWidget(
            context: context, child: builder(context, layout));
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
    if (!isCurrent &&
        _last == false &&
        _current == true &&
        _nextRouteCache != null) {
      SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
        didChangeNext(_nextRouteCache!);
        _nextRouteCache!.didChangePrevious(this);
      });
      return Offstage(child: child);
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
          final left = size.width * masterRatio / 100 + _kSplitDividerWidth;
          scope = Positioned(
            left: left,
            top: 0,
            child: SizedBox(
              height: size.height,
              width: size.width - left,
              child: scope,
            ),
          );
        }
        return scope;
      },
      opaque: _modalScope.opaque,
      maintainState: _modalScope.maintainState,
    );
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    _nextRouteCache = nextRoute;
    if (isSplit(null) && nextRoute is SplitRoute && nextRoute.detail == true) {
      return false;
    }
    return super.canTransitionTo(nextRoute);
  }

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    if (isSplit(null) &&
        previousRoute is SplitRoute &&
        previousRoute.detail == true) {
      return false;
    }
    return super.canTransitionFrom(previousRoute);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return ClipRect(
      child: super.buildTransitions(
        context,
        animation,
        secondaryAnimation,
        child,
      ),
    );
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
    return Row(
      children: <Widget>[
        Flexible(flex: masterRatio, child: child),
        Flexible(
          flex: 100 - masterRatio,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: Divider.createBorderSide(context,
                    width: _kSplitDividerWidth,
                    color: Theme.of(context).dividerColor),
              ),
            ),
            child:
                defaultMasterFillPageBuilder?.call(context) ?? const Scaffold(),
          ),
        ),
      ],
    );
  }

  // static bool _isSplitCache = false;

  /// Check current size to use split view or not.
  /// When the height is too small, split view is disabled.
  static bool isSplit(BuildContext? context) {
    context ??= kAppKey.currentContext;
    if (context == null) return false;
    final size = MediaQuery.of(context).size;
    return size.width > size.height && size.width >= 720 && size.height > 320;
  }

  SplitLayout getLayout(BuildContext context) {
    if (detail == null || !isSplit(context)) return SplitLayout.none;
    return detail! ? SplitLayout.detail : SplitLayout.master;
  }

  /// Pop all top detail routes
  ///
  /// return the number of popped pages
  static int popDetailRoutes(BuildContext context) {
    // whether to store all values returned by routes?
    assert(() {
      final curRoute = SplitRoute.of(context);
      if (curRoute == null || curRoute.detail == true) {
        throw StateError(
            'DO NOT call popDetails outside SplitRoute or inside detail page');
      }
      return true;
    }());
    int n = 0;
    Navigator.of(context).popUntil((route) {
      bool isDetail = route is SplitRoute && route.detail == true;
      if (isDetail) {
        n += 1;
      }
      return !isDetail;
    });
    return n;
  }

  /// if there is any detail view and need to pop detail,
  /// don't show pop and push animation
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

    return navigator.push(SplitRoute(
      builder: builder,
      detail: detail,
      masterRatio: masterRatio,
      transitionDuration: (detail == true && popDetail && n > 0)
          ? const Duration()
          : kSplitRouteDuration,
      reverseTransitionDuration: kSplitRouteDuration,
      settings: settings,
      title: title,
    ));
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
    String pageName = page.runtimeType.toString();
    MobStat.pageStart(pageName);
    return pushBuilder<T>(
      context: context,
      builder: (context, _) => page,
      detail: detail,
      popDetail: popDetail,
      rootNavigator: rootNavigator,
      settings: settings,
    ).then<T?>((value) {
      MobStat.pageEnd(pageName);
      return value;
    });
  }

  static SplitRoute<T2>? of<T2 extends Object?>(BuildContext context) {
    final route = ModalRoute.of<T2>(context);
    if (route is SplitRoute<T2>) return route;
  }
}
