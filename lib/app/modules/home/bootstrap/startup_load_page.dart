import 'dart:math' show Random;

import 'package:flutter/foundation.dart';

import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/network.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/utils/img_util.dart';
import 'package:chaldea/widgets/widgets.dart';

class StartupLoadingPage extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFailed;
  StartupLoadingPage({super.key, required this.onSuccess, required this.onFailed});

  @override
  State<StartupLoadingPage> createState() => _StartupLoadingPageState();
}

class _StartupLoadingPageState extends State<StartupLoadingPage> {
  final _loader = GameDataLoader.instance;
  String? hint;
  DateTime startTime = DateTime.now();

  bool onlineUpdate =
      network.available && !kDebugMode && db.settings.autoUpdateData && (db.settings.updateDataBeforeStart || kIsWeb);
  bool needBackgroundUpdate = !kIsWeb && db.settings.autoUpdateData;

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  Future _updateData() async {
    startTime = DateTime.now();
    Future.delayed(const Duration(seconds: 32), () {
      if (mounted) setState(() {});
    });
    GameData? data = await _loader.reload(
      offline: !onlineUpdate,
      silent: true,
      connectTimeout: onlineUpdate ? const Duration(seconds: 5) : null,
    );
    if (onlineUpdate && data == null) {
      hint = 'Loading local cache...';
      needBackgroundUpdate = false;
      if (mounted) setState(() {});
      data = await _loader.reload(offline: true, silent: true);
    }
    if (data != null) {
      db.gameData = data;
      widget.onSuccess.call();
      // rootRouter.appState.dataReady = true;
      if (needBackgroundUpdate && network.available && kReleaseMode) {
        await Future.delayed(const Duration(seconds: 3));
        await _loader.reload(silent: true);
      }
    } else {
      widget.onFailed.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget img = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ImageUtil.getChaldeaBackground(context),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Center(child: img)),
        const SizedBox(height: 12),
        ValueListenableBuilder<int>(
          valueListenable: _loader.downloading,
          builder: ((context, value, child) {
            bool showHint = onlineUpdate && value > 0 && DateTime.now().difference(startTime).inSeconds > 30;
            showHint = showHint || hint != null;
            return Text.rich(
              TextSpan(
                children: showHint
                    ? [
                        TextSpan(text: hint ?? 'Updating '),
                        CenterWidgetSpan(
                          child: IconButton(
                            onPressed: () {
                              _loader.interrupt();
                              setState(() {});
                            },
                            color: Theme.of(context).colorScheme.primaryContainer,
                            icon: const Icon(Icons.clear),
                            iconSize: 12,
                          ),
                        ),
                      ]
                    : [const TextSpan(text: '  ')],
              ),
              textAlign: TextAlign.center,
            );
          }),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<double?>(
          valueListenable: _loader.progress,
          builder: (context, value, child) {
            return _AnimatedProgressIndicator(value: value ?? 0, imageSize: 48);
          },
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
              Positioned(
                left: (constraints.maxWidth * widget.value - widget.imageSize / 2).clamp2(
                  0,
                  constraints.maxWidth - widget.imageSize,
                ),
                bottom: -widget.imageSize * 0.3,
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
