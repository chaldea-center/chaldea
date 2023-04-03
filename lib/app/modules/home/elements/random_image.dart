import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/widgets/widgets.dart';

class RandomImageSurprise extends StatefulWidget {
  final Duration duration;

  const RandomImageSurprise({super.key, this.duration = const Duration(seconds: 15)});

  @override
  State<RandomImageSurprise> createState() => _RandomImageSurpriseState();
}

class _RandomImageSurpriseState extends State<RandomImageSurprise> {
  DateTime lastUpdated = DateTime.now();
  MapEntry<Servant, String>? cur;
  MapEntry<Servant, String>? next;

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.duration * 2, (timer) {
      if (mounted) setState(() {});
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
    final fp = await AtlasIconLoader.i.get(next!.value);
    if (fp != null && mounted) {
      await precacheImage(FileImage(File(fp)), context);
    }
  }

  List<MapEntry<Servant, String>> getData() {
    List<MapEntry<Servant, String>> urls = [];
    for (final svt in db.gameData.servantsNoDup.values) {
      for (final url in svt.extra.aprilFoolAssets) {
        if (url.contains('/FGL/Figure/')) {
          urls.add(MapEntry(svt, url));
          break;
        }
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    if (cur == null || DateTime.now().difference(lastUpdated) > widget.duration) {
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
    return Opacity(
      opacity: 0.6,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1000),
        child: GestureDetector(
          onDoubleTap: cur?.key.routeTo,
          onLongPress: cur?.key.routeTo,
          child: CachedImage(
            key: Key(cur?.value ?? "no-url"),
            imageUrl: cur?.value,
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
