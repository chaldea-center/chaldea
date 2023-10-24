import 'dart:async';

import 'package:flutter/material.dart';

class TimerUpdate extends StatelessWidget {
  static final Map<int, (Timer, ValueNotifier<DateTime>)> _map = {};

  static ValueNotifier<DateTime> _register(Duration duration) {
    final key = duration.inMicroseconds;
    final existed = _map[key];
    if (existed != null) {
      return existed.$2;
    }
    final notifier = ValueNotifier(DateTime.now());
    final timer = Timer.periodic(duration, (timer) {
      notifier.value = DateTime.now();
    });
    _map[key] = (timer, notifier);
    return notifier;
  }

  final ValueNotifier<DateTime> notifier;
  final Widget Function(BuildContext context, DateTime time) builder;

  TimerUpdate({super.key, Duration duration = const Duration(milliseconds: 500), required this.builder})
      : notifier = _register(duration);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, value, child) => builder(context, value),
    );
  }
}
