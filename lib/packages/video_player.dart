import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:video_player/video_player.dart';

import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/packages/platform/platform.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/utils/url.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'logger.dart';

const _kDefaultAspectRatio = 1344 / 576;

// ArgumentError("video file not opened yet")
extension VideoPlayerControllerX on VideoPlayerController {
  Future<void> playOrPause() {
    return value.isPlaying ? pause() : play();
  }
}

class MyVideoPlayer extends StatefulWidget {
  final VideoPlayerController? controller;
  final String? url;
  final bool autoPlay;
  final double initAspectRatio;
  // progress indicator
  final EdgeInsets indicatorPadding;
  final double indicatorHeight;
  final bool indicatorBelow;
  final Widget Function(BuildContext context, String? url, dynamic reason) onFailed;

  const MyVideoPlayer({
    super.key,
    required VideoPlayerController this.controller,
    this.autoPlay = true,
    this.initAspectRatio = _kDefaultAspectRatio,
    this.indicatorPadding = const EdgeInsets.only(top: 5.0, bottom: 3.0),
    this.indicatorHeight = 4.0,
    this.indicatorBelow = true,
    this.onFailed = defaultFailedBuilder,
  }) : url = null;

  const MyVideoPlayer.url({
    super.key,
    required String this.url,
    this.autoPlay = true,
    this.initAspectRatio = _kDefaultAspectRatio,
    this.indicatorPadding = const EdgeInsets.only(top: 5.0, bottom: 3.0),
    this.indicatorHeight = 4.0,
    this.indicatorBelow = true,
    this.onFailed = defaultFailedBuilder,
  }) : controller = null;

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();

  static Widget defaultFailedBuilder(BuildContext context, String? url, dynamic error) {
    String? name;
    if (url != null) {
      final segs = Uri.tryParse(url)?.pathSegments;
      if (segs != null && segs.isNotEmpty) name = segs.last;
    }
    String errorStr = error?.toString() ?? 'Error';
    name ??= String.fromCharCodes(errorStr.runes.take(50));
    return Text.rich(TextSpan(children: [
      const TextSpan(text: 'Video  ', style: TextStyle(fontWeight: FontWeight.bold)),
      SharedBuilder.textButtonSpan(
        context: context,
        text: '▶ $name',
        style: TextStyle(color: Theme.of(context).colorScheme.secondaryContainer),
        onTap: () {
          if (url != null) launch(url);
        },
      )
    ]));
  }
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  VideoPlayerController? _fallbackController;

  VideoPlayerController? get effectiveController => widget.controller ?? _fallbackController;

  bool _loading = false;
  dynamic error;

  @override
  void initState() {
    super.initState();
    _initController(widget.url);
    widget.controller?.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller?.removeListener(update);
    _fallbackController?.dispose();
    _fallbackController = null;
  }

  @override
  void didUpdateWidget(covariant MyVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url && widget.url != null) {
      _initController(widget.url);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller
        ?..removeListener(update)
        ..pause();
      widget.controller?.removeListener(update);
      widget.controller?.play();
    }
  }

  Future<void> _initController(String? url) async {
    if (url == null) return;
    if (PlatformU.isLinux) {
      error = 'Linux not supported yet';
      return;
    }
    _fallbackController?.dispose();
    _fallbackController = null;
    _loading = true;
    error = null;
    if (mounted) setState(() {});
    final fp = kIsWeb ? null : await AtlasIconLoader.i.get(url);
    if (!mounted) return;
    if (fp != null) {
      _fallbackController =
          VideoPlayerController.file(File(fp), videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    } else {
      _fallbackController =
          VideoPlayerController.networkUrl(Uri.parse(url), videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    }
    try {
      await _fallbackController!.initialize();
      _fallbackController!.addListener(update);
      if (widget.autoPlay) _fallbackController!.play();
    } catch (e, s) {
      logger.e('init video player failed, $url', e, s);
      error = e;
    } finally {
      _loading = false;
      if (mounted) setState(() {});
    }
  }

  void update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = effectiveController;
    if (controller == null) {
      if (_loading) {
        return AspectRatio(
          aspectRatio: widget.initAspectRatio,
          child: const Center(child: CircularProgressIndicator.adaptive()),
        );
      } else {
        return widget.onFailed(context, widget.url, error);
      }
    }

    Widget progressIndicator = VideoProgressIndicator(
      controller,
      allowScrubbing: true,
      padding: widget.indicatorPadding,
    );
    Widget player = VideoPlayer(controller);

    final themeData = Theme.of(context);
    progressIndicator = Theme(
      data: themeData.copyWith(
          progressIndicatorTheme: themeData.progressIndicatorTheme.copyWith(linearMinHeight: widget.indicatorHeight)),
      child: progressIndicator,
    );

    Widget stack = Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: widget.indicatorBelow
              ? EdgeInsets.only(bottom: widget.indicatorHeight + widget.indicatorPadding.bottom)
              : EdgeInsets.zero,
          child: AspectRatio(
            aspectRatio: controller.value.isInitialized ? controller.value.aspectRatio : widget.initAspectRatio,
            child: player,
          ),
        ),
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 50),
            reverseDuration: const Duration(milliseconds: 200),
            child: !controller.value.isPlaying && controller.value.position == Duration.zero
                ? Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 100.0,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onDoubleTap: () {
              controller.playOrPause();
            },
            onTap: () {
              controller.playOrPause();
            },
          ),
        ),
        progressIndicator
      ],
    );
    return stack;
  }
}

class VideoPlayPage extends StatefulWidget {
  final String? title;
  final String url;
  const VideoPlayPage({super.key, required this.url, this.title});

  @override
  State<VideoPlayPage> createState() => _VideoPlayPageState();
}

class _VideoPlayPageState extends State<VideoPlayPage> {
  Key playerKey = UniqueKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Video Player'),
        actions: [
          if (!kIsWeb)
            IconButton(
              onPressed: () {
                SimpleCancelOkDialog(
                  title: Text(S.current.refresh),
                  onTapOk: () async {
                    await AtlasIconLoader.i.deleteFromDisk(widget.url);
                    playerKey = UniqueKey();
                    if (mounted) setState(() {});
                  },
                ).showDialog(context);
              },
              icon: const Icon(Icons.refresh),
              tooltip: S.current.refresh,
            ),
          IconButton(
            onPressed: () {
              launch(widget.url, external: true);
            },
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: Center(
        child: MyVideoPlayer.url(key: playerKey, url: widget.url),
      ),
    );
  }
}
