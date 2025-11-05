import 'dart:async';

import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

String padInt(int v, [int width = 2]) {
  return v.toString().padLeft(width, '0');
}

mixin TimerItem {
  int get startedAt;
  int get endedAt;

  OngoingStatus get status {
    final now = DateTime.now().timestamp;
    return now > endedAt
        ? OngoingStatus.ended
        : now < startedAt
        ? OngoingStatus.notStarted
        : OngoingStatus.ongoing;
  }

  bool get defaultExpanded => true;

  // static List<TimerItem> group(List<T> items, Region region);

  Widget buildItem(BuildContext context, {bool expanded = false});

  bool shouldShow(TimerFilterData filterData) {
    return filterData.status.matchOne(status);
  }

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

enum TimerSortType { auto, startTime, endTime }

enum OngoingStatus { ended, ongoing, notStarted }

class TimerFilterData {
  final sortType = FilterRadioData.nonnull(TimerSortType.auto);
  final status = FilterGroupData<OngoingStatus>();

  List<T> getSorted<T extends TimerItem>(List<T> items) {
    items = items.where((e) => e.shouldShow(this)).toList();
    final now = DateTime.now().timestamp;
    switch (sortType.radioValue!) {
      case TimerSortType.auto:
        items.sortByList((e) => [e.status == OngoingStatus.ended ? 1 : -1, (now - e.endedAt).abs(), e.startedAt]);
        break;
      case TimerSortType.startTime:
        items.sort2((e) => e.startedAt);
        break;
      case TimerSortType.endTime:
        items.sort2((e) => e.endedAt);
        break;
    }
    return items;
  }
}

// widgets

class TimerTabBase<T extends TimerItem> extends StatelessWidget {
  final List<T> groups;
  final TimerFilterData filterData;
  final Region region;
  const TimerTabBase({super.key, required this.groups, required this.filterData, required this.region});

  @override
  Widget build(BuildContext context) {
    final shownGroups = filterData.getSorted(groups);
    if (shownGroups.isEmpty) {
      return Center(child: Text(S.current.empty_hint));
    }
    return ListView.separated(
      itemBuilder: (context, index) {
        final group = shownGroups[index];
        return group.buildItem(context, expanded: group.defaultExpanded);
      },
      separatorBuilder: (_, _) => const Divider(indent: 16, endIndent: 16),
      itemCount: shownGroups.length,
    );
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
  final bool fitted;
  final bool showFutureStartedAt;
  final int? maxDays;

  const CountDown({
    super.key,
    required this.endedAt,
    this.startedAt,
    this.endedAt2,
    this.startedAt2,
    this.duration = const Duration(milliseconds: 500),
    this.showSeconds = true,
    this.textAlign,
    this.fitted = true,
    this.showFutureStartedAt = true,
    this.maxDays = 99,
  });

  @override
  Widget build(BuildContext context) {
    DateTime endedAt = this.endedAt;
    if (endedAt.minute == 59 && endedAt.second == 59) {
      endedAt = endedAt.add(const Duration(seconds: 1));
    }
    Widget child = OnTimer(
      duration: duration,
      builder: (context) {
        final _now = DateTime.now();
        return Text.rich(
          TextSpan(
            children: [
              if (startedAt != null && startedAt!.isAfter(_now)) ...[
                TextSpan(text: '${S.current.not_started}\n', style: const TextStyle(fontSize: 12)),
                if (showFutureStartedAt) ...[
                  buildOne(context, startedAt!, null, color: Colors.blue),
                  const TextSpan(text: '\n'),
                ],
              ],
              if (endedAt.isBefore(_now)) TextSpan(text: '${S.current.ended}\n', style: const TextStyle(fontSize: 12)),
              buildOne(context, endedAt, startedAt),
              if (endedAt2 != null && endedAt2 != endedAt) ...[
                const TextSpan(text: '\n'),
                buildOne(context, endedAt2!, startedAt2),
              ],
            ],
          ),
          textScaler: const TextScaler.linear(0.9),
          textAlign: textAlign,
        );
      },
    );
    if (fitted) {
      child = FittedBox(fit: BoxFit.scaleDown, child: child);
    }
    return child;
  }

  TextSpan buildOne(BuildContext context, DateTime _endedAt, DateTime? _startedAt, {Color? color}) {
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
    if (maxDays != null && days > maxDays!) {
      text += "$maxDays+d";
    } else {
      if (days > 0) {
        text += "${days}d ";
      }
      text += "${padInt(hours)}:${padInt(minutes)}";
      if (showSeconds) {
        text += ":${padInt(seconds)}";
      }
    }
    if (color == null) {
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
