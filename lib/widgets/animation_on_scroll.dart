import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class UserScrollListener extends StatefulWidget {
  final Widget Function(BuildContext context, AnimationController controller)
      builder;
  final bool Function(UserScrollNotification userScroll)? shouldAnimate;

  const UserScrollListener(
      {Key? key, required this.builder, this.shouldAnimate})
      : super(key: key);

  @override
  _UserScrollListenerState createState() => _UserScrollListenerState();
}

class _UserScrollListenerState extends State<UserScrollListener>
    with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<UserScrollNotification>(
      onNotification: onNotification,
      child: widget.builder(context, controller),
    );
  }

  bool onNotification(UserScrollNotification userScroll) {
    if (shouldAnimate(userScroll)) {
      switch (userScroll.direction) {
        case ScrollDirection.forward:
          controller.forward();
          break;
        case ScrollDirection.reverse:
          controller.reverse();
          break;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }

  bool shouldAnimate(UserScrollNotification userScroll) {
    if (userScroll.depth != 0) return false;
    if (userScroll.metrics.maxScrollExtent ==
        userScroll.metrics.minScrollExtent) return false;
    if ((controller.status == AnimationStatus.forward ||
        controller.status == AnimationStatus.reverse)) return false;
    if (widget.shouldAnimate != null) {
      return widget.shouldAnimate!(userScroll);
    }
    return true;
  }
}
