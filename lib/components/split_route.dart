// @dart=2.12
import 'package:chaldea/modules/blank_page.dart';
import 'package:flutter/material.dart';

const int kSplitMasterRatio = 38;

typedef Widget SplitLayoutBuilder(BuildContext context, SplitLayout layout);

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
/// TODO: add animation, swipe support
class SplitRoute<T extends Object?> extends TransitionRoute<T>
    with LocalHistoryRoute<T> {
  SplitRoute({
    required this.builder,
    this.detail = true,
    this.masterRatio = kSplitMasterRatio,
    RouteSettings? settings,
  })  : assert(masterRatio > 0 && masterRatio < 100),
        super(settings: settings);

  /// Expose BuildContext and SplitLayout to builder
  final SplitLayoutBuilder builder;

  /// whether to use detail layout if in split mode
  final bool detail;

  /// Master page ratio of full-width, between 0~100
  final int masterRatio;

  /// define your own builder for right space of master page
  static WidgetBuilder defaultMasterFillPageBuilder = (context) => BlankPage();

  /// GlobalKey to access state
  final GlobalKey<_SplitRouteScopeState<T>> _scopeKey = GlobalKey();

  static Future<T?>? push<T extends Object?>({
    required BuildContext context,
    required SplitLayoutBuilder builder,
    bool popDetail = false,
    bool detail = true,
    int masterRatio = kSplitMasterRatio,
    RouteSettings? settings,
  }) {
    final navigator = Navigator.of(context);
    if (popDetail) {
      pop(context, true);
    }
    return navigator.push(SplitRoute(
        builder: builder,
        detail: detail,
        masterRatio: masterRatio,
        settings: settings));
  }

  /// Pop all top detail routes
  static void pop(BuildContext context, [bool popDetails = false]) {
    // whether to store all values returned by routes?
    if (popDetails) {
      Navigator.of(context).popUntil((route) =>
          !(route is SplitRoute) || (route is SplitRoute && !route.detail));
    } else {
      Navigator.of(context).pop();
    }
  }

  /// check current size to use split view or not
  static bool isSplit(BuildContext context) {
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

  @override
  Iterable<OverlayEntry> createOverlayEntries() sync* {
    yield OverlayEntry(builder: (context) {
      final layout = getLayout(context);
      final scope = _SplitRouteScope(key: _scopeKey, route: this);
      if (layout == SplitLayout.detail) {
        final size = MediaQuery.of(context).size;
        return Positioned(
          left: size.width * masterRatio / 100,
          top: 0,
          child: SizedBox(
            height: size.height,
            width: size.width * (100 - masterRatio) / 100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  border: Border(
                      left: Divider.createBorderSide(context,
                          width: 1, color: Colors.grey))),
              child: scope,
            ),
          ),
        );
      } else if (layout == SplitLayout.master) {
        return createMasterWidget(
            context: context, child: scope, masterRatio: masterRatio);
      } else {
        return scope;
      }
    });
  }

  /// create master widget without scope wrapped
  static Widget createMasterWidget({
    required BuildContext context,
    required Widget child,
    int masterRatio = kSplitMasterRatio,
  }) {
    return Row(
      children: <Widget>[
        Flexible(
          flex: masterRatio,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: Divider.createBorderSide(context, width: 0.2),
              ),
            ),
            child: child,
          ),
        ),
        if (isSplit(context))
          Flexible(
            flex: 100 - masterRatio,
            child: defaultMasterFillPageBuilder(context),
          ),
      ],
    );
  }

  /// ensure focus when [didAdd], [didPush] or [scopeState.initSate]
  /// [scopeState.didUpdateWidget] only set focus when has primary focus
  void _ensureFocus() {
    if (_scopeKey.currentState != null) {
      navigator!.focusScopeNode
          .setFirstFocus(_scopeKey.currentState!.focusScopeNode);
    }
  }

  @override
  void didAdd() {
    super.didAdd();
    _ensureFocus();
  }

  @override
  TickerFuture didPush() {
    _ensureFocus();
    return super.didPush();
  }

  @override
  bool didPop(T? result) {
    final bool returnValue = super.didPop(result);
    assert(returnValue);
    if (finishedWhenPopped) {
      navigator!.finalizeRoute(this);
    }
    return returnValue;
  }

  @override
  void didPopNext(Route nextRoute) {
    super.didPopNext(nextRoute);
    // TODO: no effect
    // if (_scopeKey.currentState != null) {
    //   _scopeKey.currentState!.focusScopeNode.children
    //       .forEach((node) => node.unfocus());
    // }
  }

  /// make route transparent for detail page
  @override
  bool get opaque => !detail;

  @override
  Duration get transitionDuration => Duration(milliseconds: 250);
}

class _SplitRouteScope<T extends Object?> extends StatefulWidget {
  final SplitRoute<T> route;

  const _SplitRouteScope({Key? key, required this.route}) : super(key: key);

  @override
  _SplitRouteScopeState<T> createState() => _SplitRouteScopeState<T>();
}

class _SplitRouteScopeState<T extends Object?> extends State<_SplitRouteScope> {
  FocusScopeNode focusScopeNode =
      FocusScopeNode(debugLabel: '$_SplitRouteScopeState Focus Scope');

  @override
  void initState() {
    super.initState();
    if (widget.route.isCurrent) {
      widget.route.navigator!.focusScopeNode.setFirstFocus(focusScopeNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: widget.route.builder(context, widget.route.getLayout(context)),
      node: focusScopeNode,
    );
  }

  /// Only set focus for app-wide *Primary* focus node
  @override
  void didUpdateWidget(covariant _SplitRouteScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (focusScopeNode.hasPrimaryFocus) {
      // widget.route._ensureFocus();
      widget.route.navigator!.focusScopeNode.setFirstFocus(focusScopeNode);
    }
  }

  @override
  void dispose() {
    super.dispose();
    focusScopeNode.dispose();
  }
}

/// BackButton used on master page which will pop all top detail routes
/// if [onPressed] is omitted.
/// Use original [BackButton] in detail page which only pop current detail route
class MasterBackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;

  MasterBackButton({Key? key, this.color, this.onPressed})
      : super(key: key);

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
