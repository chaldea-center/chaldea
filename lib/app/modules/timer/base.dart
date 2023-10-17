import 'dart:async';

import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

String padInt(int v, [int width = 2]) {
  return v.toString().padLeft(width, '0');
}

mixin TimerItem {
  int get endedAt;
  Widget buildItem(BuildContext context, {bool expanded = false});

  String fmtDate(int v, {bool year = false, bool time = true, bool seconds = false}) {
    final date = v.sec2date();
    String text = [if (year) date.year, date.month, date.day].map(padInt).join('-');
    if (time) {
      text += ' ';
      text += [date.hour, date.minute, if (seconds) date.second].map(padInt).join(":");
    }
    return text;
  }
}

class CountDown extends StatelessWidget {
  final DateTime endedAt;
  final DateTime? startedAt;
  // such as shop close time
  final DateTime? endedAt2;
  final DateTime? startedAt2;

  final Duration duration;
  final bool showSeconds;
  final TextAlign? textAlign;

  const CountDown({
    super.key,
    required this.endedAt,
    this.startedAt,
    this.endedAt2,
    this.startedAt2,
    this.duration = const Duration(milliseconds: 500),
    this.showSeconds = true,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return OnTimer(
      duration: duration,
      builder: (context) {
        return Text.rich(
          TextSpan(children: [
            buildOne(context, endedAt, startedAt),
            if (endedAt2 != null) ...[
              const TextSpan(text: '\n'),
              buildOne(context, endedAt2!, startedAt2),
            ]
          ]),
          textScaleFactor: 0.9,
          textAlign: textAlign,
        );
      },
    );
  }

  TextSpan buildOne(BuildContext context, DateTime _endedAt, DateTime? _startedAt) {
    final now = DateTime.now();
    final left = _endedAt.difference(now);
    final outdated = left.isNegative;
    final delta = left.abs();
    String text = "";
    if (outdated) text += '-';
    final days = delta.inDays,
        hours = delta.inHours % Duration.hoursPerDay,
        minutes = delta.inMinutes % Duration.minutesPerHour,
        seconds = delta.inSeconds % Duration.secondsPerMinute;
    if (days > 0) {
      text += "${days}d ";
    }
    text += "${padInt(hours)}:${padInt(minutes)}";
    if (showSeconds) {
      text += ":${padInt(seconds)}";
    }
    Color? color;
    final themeData = Theme.of(context);
    if (_startedAt != null && _startedAt.isAfter(now)) {
      // start in future
      color = Colors.blue;
    } else if (outdated) {
      // closed
      color = themeData.disabledColor;
    } else if (left < const Duration(hours: 24 * 2)) {
      // close in 2 days
      color = themeData.colorScheme.error;
    } else {
      // ongoing
      color = Colors.green;
    }
    return TextSpan(
      text: text,
      style: TextStyle(
        // fontFamily: kMonoFont,
        color: color,
      ),
    );
  }
}

class OnTimer extends StatefulWidget {
  final Duration duration;
  final WidgetBuilder builder;

  const OnTimer({super.key, required this.duration, required this.builder});

  @override
  State<OnTimer> createState() => OnTimerState();
}

class OnTimerState extends State<OnTimer> {
  static final Map<int, (Timer, ChangeNotifier)> _timers = {};

  static void _addListener(Duration duration, VoidCallback cb) {
    final (_, change) = _timers.putIfAbsent(duration.inMicroseconds, () {
      final change = ChangeNotifier();
      final timer = Timer.periodic(duration, (timer) {
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        change.notifyListeners();
      });
      return (timer, change);
    });
    change.addListener(cb);
  }

  static void _removeListener(Duration duration, VoidCallback cb) {
    final key = duration.inMicroseconds;
    if (!_timers.containsKey(key)) return;
    final (timer, change) = _timers[duration.inMicroseconds]!;
    change.removeListener(cb);
    // ignore: invalid_use_of_protected_member
    if (!change.hasListeners) {
      timer.cancel();
      _timers.remove(duration.inMicroseconds);
    }
  }

  @override
  void initState() {
    super.initState();
    _addListener(widget.duration, update);
  }

  @override
  void didUpdateWidget(covariant OnTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _removeListener(oldWidget.duration, update);
      _addListener(widget.duration, update);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _removeListener(widget.duration, update);
  }

  void update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
