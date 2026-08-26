import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/constants.dart';

class FrameRateLayer extends StatefulWidget {
  static bool showFps = false;

  const FrameRateLayer({super.key});

  static GlobalKey<_FrameRateLayerState> globalKey = GlobalKey();
  static OverlayEntry? _instance;

  static void createOverlay(BuildContext context) {
    // The root navigator context sits above its own Overlay, so
    // `Overlay.maybeOf(rootCtx)` returns null. Use the active sub-navigator
    // context and target the root overlay instead.
    context = router.navigatorKey.currentContext ?? context;
    _instance?.remove();
    _instance = OverlayEntry(builder: (context) => FrameRateLayer(key: globalKey));
    Overlay.maybeOf(context, rootOverlay: true)?.insert(_instance!);
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
  if (!FrameRateLayer.showFps) return;
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
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (_lastTime == null) {
        SchedulerBinding.instance.addPersistentFrameCallback(_registerFrameCallback);
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
    final size = MediaQuery.maybeOf(context)?.size;
    return PositionedDirectional(
      start: 0,
      top: MediaQuery.of(context).padding.top,
      // Wrap in a Material so the Text inherits a sane DefaultTextStyle:
      // entries in the root overlay sit above any Scaffold, and EasyLoading
      // 4.x propagates MaterialApp's fallback _errorTextStyle (48px, yellow
      // double underline) to everything below the root Navigator.
      // The Material must be INSIDE the Positioned: Material introduces its
      // own RenderObject, which would otherwise sit between the Overlay's
      // Stack and the Positioned and break the ParentData chain.
      child: Material(
        type: MaterialType.transparency,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.black26),
            child: Text(
              [
                if (size != null && !PlatformU.isMobile) '${size.width.toInt()}×${size.height.toInt()}',
                fps.toStringAsFixed(2).padLeft(6),
              ].join(' '),
              style: const TextStyle(
                // backgroundColor: Colors.black26,
                color: Colors.white70,
                fontFamily: kMonoFont,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
