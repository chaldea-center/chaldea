import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:chaldea/components/master_detail_utils.dart';

class DetailRoute<T> extends TransitionRoute<T> with LocalHistoryRoute<T> {
  DetailRoute({@required this.builder, RouteSettings settings})
      : super(settings: settings);

  final WidgetBuilder builder;

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    return [
      OverlayEntry(builder: (context) {
        return Positioned(
            left: isTablet(context)
                ? MediaQuery.of(context).size.width *
                (kTabletMasterContainerRatio+0.05) /
                    100
                : 0,
            top: 0,
            child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: isTablet(context)
                    ? MediaQuery.of(context).size.width/100 *
                        (100 - kTabletMasterContainerRatio)
                    : MediaQuery.of(context).size.width,
                child: builder(context)));
      })
    ];
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

class MasterRoute<T> extends TransitionRoute<T> with LocalHistoryRoute<T> {
  MasterRoute({@required this.builder, RouteSettings settings})
      : super(settings: settings);

  final WidgetBuilder builder;

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    return [
      OverlayEntry(builder: (context) {
        // TODO: not finished.
        return Row(
          children: <Widget>[
            Flexible(
                flex: kTabletMasterContainerRatio,
                child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: isTablet(context)
                        ? MediaQuery.of(context).size.width/100 *
                        (100 - kTabletMasterContainerRatio)
                        : MediaQuery.of(context).size.width,
                    child: builder(context))),
            isTablet(context)
                ? Flexible(
                flex: 100 - kTabletMasterContainerRatio, child: Center())
                : Container(),
          ],
        );
      })
    ];
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
