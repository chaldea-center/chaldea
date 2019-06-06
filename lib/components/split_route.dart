import 'package:chaldea/modules/blank_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const kTabletMasterContainerRatio = 38; // percentage

bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.width >= 768.0;
}

class SplitRoute<T> extends TransitionRoute<T> with LocalHistoryRoute<T> {
  SplitRoute({@required this.builder, RouteSettings settings})
      : super(settings: settings);

  final WidgetBuilder builder;

  //if builder==null, just pop no push
  static void popAndPush(BuildContext context,
      {WidgetBuilder builder, RouteSettings settings}) {
    Navigator.of(context).popUntil((route) => route.settings.isInitialRoute);
    if (builder != null) {
      Navigator.of(context)
          .push(SplitRoute(builder: builder, settings: settings));
    }
  }

  static Widget createMasterPage(BuildContext context, Widget child) {
    final tablet = isTablet(context);
    return Row(
      children: <Widget>[
        Flexible(
            flex: kTabletMasterContainerRatio,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  border: Border(right: BorderSide(width: tablet ? 0.0 : 0.0))),
              child: child,
            )),
        tablet
            ? Flexible(
                flex: 100 - kTabletMasterContainerRatio, child: BlankPage())
            : Container(),
      ],
    );
  }

  static Widget createDetailPage(BuildContext context, Widget child) {
    final tablet = isTablet(context);
    FocusScopeNode node = FocusScopeNode();
    FocusScope.of(context).setFirstFocus(node);
    return Positioned(
        left: tablet
            ? MediaQuery.of(context).size.width *
                kTabletMasterContainerRatio /
                100
            : 0,
        top: 0,
        child: Container(
          decoration:
              BoxDecoration(border: Border(left: BorderSide(width: 0.0))),
          child: FocusScope(
            node: node,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: tablet
                  ? MediaQuery.of(context).size.width *
                      (1 - kTabletMasterContainerRatio / 100)
                  : MediaQuery.of(context).size.width,
              child: child,
            ),
          ),
        ));
  }

  @override
  Iterable<OverlayEntry> createOverlayEntries() sync* {
    yield OverlayEntry(
        opaque: false,
        maintainState: true,
        builder: (context) {
          return settings.isInitialRoute
              ? createMasterPage(context, builder(context))
              : createDetailPage(context, builder(context));
        });
  }

  @override
  void install(OverlayEntry insertionPoint) {
    super.install(insertionPoint);
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

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 250);
}
