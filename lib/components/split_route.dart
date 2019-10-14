///TODO: add transition animation and swipe support
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/blank_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const int kMasterRatio = 38; // percentage

bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.width >=
      (db.appData?.criticalWidth ?? 768);
}

class SplitRoute<T> extends TransitionRoute<T> with LocalHistoryRoute<T> {
  final WidgetBuilder builder;
  final RouteSettings settings;
  bool tablet;
  FocusScopeNode node = FocusScopeNode();

  SplitRoute({@required this.builder, RouteSettings settings})
      : settings = settings ?? RouteSettings(),
        super(settings: settings ?? RouteSettings());

  ///if [builder] is null, just pop without push
  static void popAndPush(BuildContext context,
      {WidgetBuilder builder, bool isDetail=true}) {
    Navigator.of(context).popUntil((route) => route.settings.isInitialRoute);
    if (builder != null) {
      Navigator.of(context)
          .push(SplitRoute(builder: builder, settings: RouteSettings(isInitialRoute: !isDetail)));
    }
  }

  static Widget createMasterPage(BuildContext context, Widget child) {
    if (!isTablet(context)) {
      return child;
    }
    return Row(
      children: <Widget>[
        Flexible(
            flex: kMasterRatio,
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.white70, width: 0.2))),
              child: child,
            )),
        Flexible(flex: 100 - kMasterRatio, child: BlankPage()),
      ],
    );
  }

  // DetailPage should not be created outside SplitRoute()
  Widget createDetailPage(BuildContext context, Widget child) {
    final fullWidth = MediaQuery.of(context).size.width,
        masterWidth = fullWidth * kMasterRatio / 100,
        detailWidth = fullWidth - masterWidth;
    Widget detail = Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          border: Border(left: BorderSide(width: 0))),
      child: FocusScope(
        node: node,
        child: tablet
            ? SizedBox(
                height: MediaQuery.of(context).size.height,
                width: detailWidth,
                child: child)
            : child,
      ),
    );
    return tablet ? Positioned(left: masterWidth, child: detail) : detail;
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() sync* {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    yield OverlayEntry(
        opaque: false,
        maintainState: true,
        builder: (context) {
          tablet = isTablet(context);
          return settings.isInitialRoute
              ? createMasterPage(context, builder(context))
              : createDetailPage(context, builder(context));
        });
  }

  @override
  bool didPop(T result) {
    final bool returnValue = super.didPop(result);
    assert(returnValue);
    if (finishedWhenPopped) {
      navigator.finalizeRoute(this);
    }
    return returnValue;
  }

  /// master-page: opaque(true), detail-page: transparent(false)
  @override
  bool get opaque => settings.isInitialRoute == true || tablet == false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 250);
}
