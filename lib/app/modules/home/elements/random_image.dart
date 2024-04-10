import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/widgets/widgets.dart';

class RandomImageSurprise extends StatefulWidget {
  final Duration duration;

  const RandomImageSurprise({super.key, this.duration = const Duration(seconds: 60)});

  @override
  State<RandomImageSurprise> createState() => _RandomImageSurpriseState();
}

class _RandomImageSurpriseState extends State<RandomImageSurprise> {
  DateTime lastUpdated = DateTime.now();
  (Servant? svt, String url)? cur;
  (Servant? svt, String url)? next;

  Duration get duration => widget.duration;

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: Random().nextInt(duration.inSeconds)), () {
      if (!mounted) return;
      final actualDuration = kIsWeb ? duration * 60 : duration * 2;
      _timer = Timer.periodic(actualDuration, (timer) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _timer = null;
  }

  Future<void> cacheNext() async {
    if (kIsWeb || next == null) return;
    final fp = await AtlasIconLoader.i.get(next!.$2);
    if (fp != null && mounted) {
      await precacheImage(FileImage(File(fp)), context);
    }
  }

  List<(Servant?, String)> getData() {
    List<(Servant?, String)> urls = [];
    for (final svt in db.gameData.servantsNoDup.values) {
      for (final url in svt.extra.aprilFoolAssets) {
        if (url.contains('/FGL/Figure/figure_') || url.contains('/FDS/Figure/figure_') || url.contains('/FGOPoker/')) {
          urls.add((svt, url));
          break;
        }
      }
    }
    for (final index in range(401, 405)) {
      urls.add((null, 'https://static.atlasacademy.io/JP/External/FGL/Figure/figure_$index.png'));
    }
    for (final index in range(501, 505).followedBy(range(601, 609))) {
      urls.add((null, 'https://static.atlasacademy.io/JP/External/FDS/Figure/figure_$index.png'));
    }

    return urls;
  }

  @override
  Widget build(BuildContext context) {
    if (cur == null || DateTime.now().difference(lastUpdated) > duration) {
      lastUpdated = DateTime.now();
      final allData = getData();
      if (allData.isNotEmpty) {
        if (next == null) {
          cur = allData[Random().nextInt(allData.length)];
        } else {
          cur = next;
        }
        next = allData[Random().nextInt(allData.length)];
        cacheNext();
      }
    }
    if (cur == null) return const SizedBox.shrink();
    const width = 256.0;
    final (svt, url) = cur!;
    return Opacity(
      opacity: 0.6,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1000),
        child: GestureDetector(
          onDoubleTap: svt?.routeTo,
          onLongPress: svt?.routeTo,
          child: CachedImage(
            key: Key(url),
            imageUrl: url,
            width: width,
            aspectRatio: 1,
            placeholder: (context, url) => const AspectRatio(
              aspectRatio: 1,
              child: SizedBox(width: width),
            ),
          ),
        ),
      ),
    );
  }
}
