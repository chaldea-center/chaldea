import 'dart:async';

import 'package:chaldea/components/components.dart';
import 'package:flutter/scheduler.dart';

class FrameRateLayer extends StatefulWidget {
  const FrameRateLayer({Key? key}) : super(key: key);

  static GlobalKey<_FrameRateLayerState> globalKey = GlobalKey();
  static OverlayEntry? _instance;

  static void createOverlay(BuildContext context) {
    _instance?.remove();
    _instance = OverlayEntry(
      builder: (context) => FrameRateLayer(key: globalKey),
    );
    Overlay.of(context)?.insert(_instance!);
  }

  static void removeOverlay() {
    _instance?.remove();
    _instance = null;
  }

  @override
  _FrameRateLayerState createState() => _FrameRateLayerState();
}

const _sampleNum = 30;
List<int> _durations = List.generate(_sampleNum, (index) => 0);
DateTime? _lastTime;
int _count = 0;
double fps = 0.0;

void _registerFrameCallback(Duration timeStamp) {
  if (!db.runtimeData.showFps) return;
  final now = DateTime.now();
  if (_lastTime != null) {
    _durations[_count % _sampleNum] = now.difference(_lastTime!).inMilliseconds;
    fps = 1000 / _durations.fold<int>(0, (p, e) => p + e) * _sampleNum;
  }
  _lastTime = now;
  _count += 1;
}

class _FrameRateLayerState extends State<FrameRateLayer> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      if (_lastTime == null) {
        SchedulerBinding.instance!
            .addPersistentFrameCallback(_registerFrameCallback);
      }
    });
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: MediaQuery.of(context).padding.top,
      child: IgnorePointer(
        child: Text(
          fps.toStringAsFixed(2).padLeft(6) + ' ',
          style: const TextStyle(
            backgroundColor: Colors.black26,
            color: Colors.white70,
            fontFamily: kMonoFont,
          ),
        ),
      ),
    );
  }
}
