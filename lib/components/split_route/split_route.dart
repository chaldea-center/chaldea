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

// ignore_for_file: unnecessary_null_comparison

library split_route;

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart'
    show CupertinoFullscreenDialogTransition;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart'
    hide PageRoute, PageRouteBuilder, ModalRoute;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

part 'cupertino_transition.dart';

part 'modal_route.dart';

part 'page_route.dart';

const int kSplitMasterRatio = 38;
const double _kSplitDividerWidth = 0.5;

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
class SplitRoute<T> extends __PageRoute<T>
    with __CupertinoRouteTransitionMixin<T> {
  /// Expose BuildContext and SplitLayout to builder
  final SplitPageBuilder builder;

  /// whether to use detail layout if in split mode
  final bool detail;

  /// Master page ratio of full-width, between 0~100
  final int masterRatio;

  /// define your own builder for right space of master page
  static WidgetBuilder defaultMasterFillPageBuilder = (context) => Container();

  SplitRoute({
    required this.builder,
    this.detail = false,
    bool? opaque,
    this.masterRatio = kSplitMasterRatio,
    this.title,
    this.transitionDuration = const Duration(milliseconds: 400),
    Duration? reverseTransitionDuration,
    RouteSettings? settings,
    this.maintainState = true,
    bool fullscreenDialog = false,
  })
      : assert(builder != null),
        assert(masterRatio > 0 && masterRatio < 100),
        assert(maintainState != null),
        assert(fullscreenDialog != null),
        opaque = opaque ?? !detail,
        reverseTransitionDuration =
            reverseTransitionDuration ?? transitionDuration,
        super(settings: settings, fullscreenDialog: fullscreenDialog);

  @override
  bool get hideBarrier => detail;

  @override
  final bool maintainState;

  @override
  String? title;

  @override
  bool opaque;

  @override
  Duration transitionDuration;

  @override
  Duration reverseTransitionDuration;

  /// wrap master page here
  @override
  Widget buildContent(BuildContext context) {
    super.reverseTransitionDuration;
    final layout = getLayout(context);
    switch (layout) {
      case SplitLayout.master:
        return createMasterWidget(
            context: context, child: builder(context, layout));
      case SplitLayout.detail:
        return builder(context, layout);
      case SplitLayout.none:
        return builder(context, layout);
    }
  }

  /// create master widget without scope wrapped
  static Widget createMasterWidget({
    required BuildContext context,
    required Widget child,
    int masterRatio = kSplitMasterRatio,
  }) {
    return Row(
      children: <Widget>[
        Flexible(flex: masterRatio, child: child),
        if (isSplit(context))
          Flexible(
            flex: 100 - masterRatio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  left: Divider.createBorderSide(context,
                      width: _kSplitDividerWidth, color: Colors.blue),
                ),
              ),
              child: defaultMasterFillPageBuilder(context),
            ),
          ),
      ],
    );
  }

  /// wrap detail page in [Positioned] here
  ///
  /// a space width [_kSplitDividerWidth] is reversed for divider
  @override
  Widget overlayScopeBuilder(BuildContext context, WidgetBuilder scopeBuilder) {
    Widget scope = scopeBuilder(context);
    if (getLayout(context) == SplitLayout.detail) {
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
  }

  /// check current size to use split view or not
  static bool isSplit(BuildContext? context) {
    if (context == null) return false;
    final size = MediaQuery.of(context).size;
    return size.width > size.height && size.width >= 768;
  }

  SplitLayout getLayout(BuildContext context) {
    return isSplit(context)
        ? detail
            ? SplitLayout.detail
            : SplitLayout.master
        : SplitLayout.none;
  }

  /// Pop all top detail routes
  ///
  /// return the number of popped pages
  static int pop(BuildContext context, [bool popDetails = false]) {
    // whether to store all values returned by routes?
    if (popDetails) {
      int n = 0;
      Navigator.of(context).popUntil((route) {
        bool isDetail = route is SplitRoute && route.detail;
        if (isDetail) {
          n += 1;
        }
        return !isDetail;
      });
      return n;
    } else {
      Navigator.of(context).maybePop();
      return 1; // maybe 0 route popped
    }
  }

  /// if there is any detail view and need to pop detail,
  /// don't show pop and push animation
  static Future<T?> push<T extends Object?>({
    required BuildContext context,
    required SplitPageBuilder builder,
    bool popDetail = false,
    bool detail = true,
    int masterRatio = kSplitMasterRatio,
    String? title,
    RouteSettings? settings,
  }) {
    final navigator = Navigator.of(context);
    int n = 0;
    if (popDetail) {
      n = pop(context, true);
    }

    return navigator.push(SplitRoute(
      builder: builder,
      detail: detail,
      masterRatio: masterRatio,
      transitionDuration: (detail && popDetail && n > 0)
          ? Duration()
          : Duration(milliseconds: 400),
      reverseTransitionDuration: Duration(milliseconds: 400),
      settings: settings,
      title: title,
    ));
  }
}

/// BackButton used on master page which will pop all top detail routes
/// if [onPressed] is omitted.
/// Use original [BackButton] in detail page which only pop current detail route
class MasterBackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;

  MasterBackButton({Key? key, this.color, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackButton(
      color: color,
      onPressed: () {
        SplitRoute.pop(context, true);
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}
