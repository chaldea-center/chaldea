import 'dart:async';
import 'dart:math' show Random;

import 'package:flutter/foundation.dart';

import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/network.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/utils/img_util.dart';
import 'package:chaldea/utils/task_observer.dart';
import 'package:chaldea/widgets/widgets.dart';

class StartupLoadingPage extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFailed;
  StartupLoadingPage({super.key, required this.onSuccess, required this.onFailed});

  @override
  State<StartupLoadingPage> createState() => _StartupLoadingPageState();
}

class _StartupLoadingPageState extends State<StartupLoadingPage> with WidgetsBindingObserver {
  final _loader = GameDataLoader.instance;
  String? hint;
  DateTime startTime = DateTime.now();
  DateTime _lastActivity = DateTime.now();
  Timer? _watchdog;
  bool _foreground = true;
  bool _stalled = false;
  bool _recovering = false;
  bool _finished = false;
  bool _showUpdatingHint = false;
  int _generation = 0;

  bool onlineUpdate =
      network.available &&
      !kDebugMode &&
      db.settings.network.autoUpdateData &&
      (db.settings.network.updateDataBeforeStart || kIsWeb);
  bool needBackgroundUpdate = !kIsWeb && db.settings.network.autoUpdateData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _loader.activity.addListener(_activityChanged);
    _loader.progress.addListener(_activityChanged);
    _loader.downloading.addListener(_activityChanged);
    _watchdog = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finished || !_foreground || _recovering) return;
      final stalled = DateTime.now().difference(_lastActivity) >= const Duration(seconds: 60);
      if (stalled && !_stalled) {
        TaskObserver.record(
          'bootstrap.no_progress',
          TaskTimingKind.wall,
          DateTime.now().difference(_lastActivity).inMicroseconds,
        );
      }
      final updating =
          onlineUpdate && _loader.downloading.value > 0 && DateTime.now().difference(startTime).inSeconds > 30;
      if (_stalled != stalled || _showUpdatingHint != updating) {
        setState(() {
          _stalled = stalled;
          _showUpdatingHint = updating;
        });
      }
    });
    _updateData();
  }

  void _activityChanged() {
    _lastActivity = DateTime.now();
    if (mounted && _stalled) setState(() => _stalled = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _activityChanged();
  }

  @override
  void dispose() {
    _generation++;
    _watchdog?.cancel();
    _loader.activity.removeListener(_activityChanged);
    _loader.progress.removeListener(_activityChanged);
    _loader.downloading.removeListener(_activityChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _current(int generation) => mounted && generation == _generation;

  Future<void> _recover({required bool offline}) async {
    if (_recovering || _finished) return;
    _generation++; // Invalidate the old caller before its cancellation completes.
    setState(() {
      _recovering = true;
      _stalled = false;
      hint = null;
      needBackgroundUpdate = false;
    });
    try {
      await _loader.interrupt();
      if (!mounted) return;
      setState(() => _recovering = false);
      await _updateData(offline: offline);
    } finally {
      if (mounted && _recovering) setState(() => _recovering = false);
    }
  }

  Future<void> _updateData({bool? offline}) async {
    final generation = ++_generation;
    final loadOffline = offline ?? !onlineUpdate;
    onlineUpdate = !loadOffline;
    _lastActivity = startTime = DateTime.now();
    _showUpdatingHint = false;
    final span = TaskObserver.start('bootstrap.ready', phase: true, detail: 'online=$onlineUpdate');
    var ready = false;
    try {
      GameData? data = await _loader.reload(
        offline: loadOffline,
        silent: true,
        automatic: true,
        connectTimeout: loadOffline ? null : const Duration(seconds: 5),
      );
      if (!_current(generation)) return;
      if (!loadOffline && data == null) {
        hint = 'Loading local data...';
        needBackgroundUpdate = false;
        setState(() {});
        data = await TaskObserver.wall(
          'bootstrap.offline_fallback',
          () => _loader.reload(offline: true, silent: true, automatic: true),
          phase: true,
        );
        if (!_current(generation)) return;
      }
      _finished = true;
      _watchdog?.cancel();
      if (data != null) {
        db.gameData = data;
        ready = true;
        span.finish();
        widget.onSuccess.call();
        if (needBackgroundUpdate && network.available && kReleaseMode) {
          await Future<void>.delayed(const Duration(seconds: 3));
          if (!_loader.loading) {
            await TaskObserver.wall(
              'bootstrap.background_update',
              () => _loader.reload(silent: true, automatic: true),
              phase: true,
            );
          }
        }
      } else {
        widget.onFailed.call();
      }
    } finally {
      span.finish(failed: !ready);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget img = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ImageUtil.getChaldeaBackground(context),
    );
    final showRecovery = !_finished && (_stalled || _recovering);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Center(child: img)),
        const SizedBox(height: 12),
        if (showRecovery)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _recovering ? 'Finishing current work...' : 'No progress. Keep waiting or reload.',
                  textAlign: TextAlign.center,
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  children: [
                    TextButton(
                      onPressed: _recovering ? null : () => _recover(offline: false),
                      child: const Text('Retry'),
                    ),
                    TextButton(
                      onPressed: _recovering ? null : () => _recover(offline: true),
                      child: const Text('Load Offline'),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          ValueListenableBuilder<int>(
            valueListenable: _loader.downloading,
            builder: (context, value, child) {
              final showHint = hint != null || _showUpdatingHint;
              return Text(showHint ? (hint ?? 'Updating') : '  ', textAlign: TextAlign.center);
            },
          ),
        const SizedBox(height: 8),
        ValueListenableBuilder<double?>(
          valueListenable: _loader.progress,
          builder: (context, value, child) => _AnimatedProgressIndicator(value: value ?? 0, imageSize: 48),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _AnimatedProgressIndicator extends StatefulWidget {
  final double value;
  final double imageSize;

  const _AnimatedProgressIndicator({required this.value, this.imageSize = 32.0});

  @override
  State<_AnimatedProgressIndicator> createState() => _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<_AnimatedProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final charaId = Random().nextInt(12) + 1;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -0.2,
      end: 0.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.imageSize + 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: widget.value,
                  color: Theme.of(context).primaryColorLight,
                  backgroundColor: Colors.transparent,
                ),
              ),
              AnimatedPositioned(
                left: (constraints.maxWidth * widget.value - widget.imageSize / 2).clamp2(
                  0,
                  constraints.maxWidth - widget.imageSize,
                ),
                bottom: -widget.imageSize * 0.3,
                duration: const Duration(milliseconds: 50),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(angle: _animation.value, alignment: Alignment(0, 0.67), child: child);
                  },
                  child: _buildCacheImage(
                    url: "https://fes.fate-go.jp/2025/assets/img/chara/chara_$charaId.png",
                    width: widget.imageSize,
                    height: widget.imageSize,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _buildCacheImage({required String url, double? width, double? height}) {
  return CachedImage(
    imageUrl: url,
    cachedOption: CachedImageOption(
      cacheCheck: (_) => true,
      placeholder: (context, url) => const SizedBox.shrink(),
      errorWidget: (context, url, error) => const SizedBox.shrink(),
    ),
    width: width,
    height: height,
  );
}
