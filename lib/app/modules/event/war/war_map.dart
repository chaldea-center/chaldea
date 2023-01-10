import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:photo_view/photo_view.dart';

import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/img_util.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'map_filter.dart';

extension _SpotCenter on NiceSpot {
  Offset get offset => Offset(x.toDouble(), y.toDouble());
  // Offset get questOfs => Offset(questOfsX.toDouble(), questOfsY.toDouble());
  // Offset get imageOfs => Offset(imageOfsX.toDouble(), imageOfsY.toDouble());
  Offset get nameOfs => Offset(nameOfsX.toDouble(), nameOfsY.toDouble());
}

class WarMapPage extends StatefulWidget {
  final NiceWar war;
  final WarMap map;
  const WarMapPage({super.key, required this.war, required this.map});

  @override
  State<WarMapPage> createState() => _WarMapPageState();
}

class _WarMapPageState extends State<WarMapPage> {
  WarMap get map => widget.map;
  NiceWar get war => widget.war;
  final filterData = WarMapFilterData();

  final Map<String, ui.Image> _cachedImages = {};
  final Set<String> _tasks = {};
  final Map<int, int> _overwriteMapIds = {};

  Future<ui.Image?> loadImage(String? url) async {
    if (url == null || url.isEmpty || _tasks.contains(url)) {
      return SynchronousFuture(null);
    }
    final img = await ImageActions.resolveImage(MyCacheImage(url));
    _tasks.add(url);
    if (img != null) {
      _cachedImages[url] = img;
    }
    if (mounted) setState(() {});
    return img;
  }

  @override
  void initState() {
    super.initState();
    final _baseMapId = war.maps.first.id;
    for (final warAdd in war.warAdds) {
      if (warAdd.type == WarOverwriteType.baseMapId) {
        _overwriteMapIds[warAdd.overwriteId] = _baseMapId;
      }
    }

    for (final url in [map.mapImage, map.headerImage]) {
      loadImage(url);
    }
    for (final gimmick in map.mapGimmicks) {
      loadImage(gimmick.image).then((img) {
        if (img != null) filterData.validGimmickIds.add(gimmick.id);
      });
    }
    filterData.gimmick.options = map.mapGimmicks.map((e) => e.id).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${S.current.war_map} ${map.id}'),
        actions: [
          IconButton(
            onPressed: map.mapImageW == 0 || map.mapImageH == 0
                ? null
                : () async {
                    EasyLoading.show(status: 'Rendering...');
                    final bytes = await ImageUtil.recordCanvas(
                      width: map.mapImageW,
                      height: map.mapImageH,
                      paint: (canvas, size) {
                        final painter = getPainter(size);
                        painter.paint(canvas, size);
                      },
                    );
                    EasyLoading.dismiss();
                    if (bytes == null) {
                      EasyLoading.showError(S.current.error);
                      return;
                    }
                    if (!mounted) return;
                    ImageActions.showSaveShare(
                      context: context,
                      data: bytes,
                      destFp: joinPaths(db.paths.downloadDir,
                          'WarMap${map.id}-${DateTime.now().toSafeFileName()}.png'),
                    );
                  },
            icon: const Icon(Icons.save_outlined),
            tooltip: S.current.save,
          ),
          IconButton(
            onPressed: () {
              map.bgm.routeTo();
            },
            icon: const Icon(Icons.music_note),
            tooltip: map.bgm.tooltip,
          ),
          IconButton(
            onPressed: () {
              FilterPage.show(
                context: context,
                builder: (context) => WarMapFilter(
                  filterData: filterData,
                  war: widget.war,
                  map: map,
                  onChanged: (v) {
                    if (mounted) setState(() {});
                  },
                ),
              );
            },
            icon: const Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: buildMap(),
    );
  }

  bool isInMap(int mapId) {
    return (_overwriteMapIds[map.id] ?? map.id) ==
        (_overwriteMapIds[mapId] ?? mapId);
  }

  Map<int, NiceSpot> getSpots() {
    if (!filterData.showSpots) return {};
    Map<int, NiceSpot> spots = {};
    for (final spot in war.spots) {
      if (filterData.freeSpotsOnly && spot.quests.every((q) => !q.isAnyFree)) {
        continue;
      }
      if (isInMap(spot.mapId)) {
        spots[spot.id] = spot;
      }
    }
    return spots;
  }

  List<SpotRoad> getRoads(Map<int, NiceSpot> spots) {
    if (!filterData.showRoads) return [];
    return war.spotRoads.where((road) => isInMap(road.mapId)).toList();
  }

  _WarMapPainter getPainter(Size size) {
    final spots = getSpots();
    final roads = getRoads(spots);
    for (final spot in spots.values) {
      loadImage(spot.shownImage);
    }
    final gimmicks = [
      for (final gimmick in map.mapGimmicks)
        if (filterData.gimmick.options.contains(gimmick.id)) gimmick
    ];
    return _WarMapPainter(
      cachedImages: Map.of(_cachedImages),
      map: map,
      gimmicks: gimmicks,
      spots: spots,
      allSpots: {for (final spot in war.spots) spot.id: spot},
      roads: roads,
    );
  }

  Widget buildMap() {
    if (map.mapImageW <= 0 || map.mapImageH <= 0) {
      return Center(
        child: Text('Invalid Map Size: ${map.mapImageW}×${map.mapImageH}'),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = map.mapImageW / map.mapImageH;
        final Size size;
        if (constraints.maxWidth / constraints.maxHeight > ratio) {
          // use height
          size = Size(constraints.maxHeight * ratio, constraints.maxHeight);
        } else {
          size = Size(constraints.maxWidth, constraints.maxWidth / ratio);
        }
        return PhotoView.customChild(
          childSize: size,
          minScale: 1.0,
          backgroundDecoration:
              BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
          child: CustomPaint(
            size: size,
            painter: getPainter(size),
          ),
        );
      },
    );
  }

  Widget get buttonBar {
    return ButtonBar(
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            IconButton(
              onPressed: () {
                // setState(() {});
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        )
      ],
    );
  }
}

class _WarMapPainter extends CustomPainter {
  final Map<int, NiceSpot> spots;
  final Map<int, NiceSpot> allSpots;
  final List<SpotRoad> roads;
  final List<MapGimmick> gimmicks;
  final WarMap map;
  final Map<String, ui.Image> cachedImages;

  _WarMapPainter({
    required this.cachedImages,
    required this.map,
    required this.gimmicks,
    required this.spots,
    required this.allSpots,
    required this.roads,
  });

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _WarMapPainter) return true;
    if (oldDelegate.map != map ||
        oldDelegate.gimmicks != gimmicks ||
        oldDelegate.spots != spots ||
        oldDelegate.allSpots != allSpots ||
        oldDelegate.roads != roads ||
        oldDelegate.cachedImages.length != cachedImages.length) {
      return true;
    }
    for (final url in oldDelegate.cachedImages.keys) {
      if (oldDelegate.cachedImages[url] != cachedImages[url]) {
        return true;
      }
    }
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final painter = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;
    final bgScale = size.width / map.mapImageW;
    // resize to aspect ratio
    size = Size(size.width, size.width / map.mapImageW * map.mapImageH);
    // print('Canvas size: $size, scale=$bgScale');

    final bgImg = cachedImages[map.mapImage];
    if (bgImg != null) {
      canvas.drawImageRect(
        bgImg,
        Rect.fromLTWH(0, 0, bgImg.width.toDouble(), bgImg.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        painter,
      );
    }

    gimmicks.sort((a, b) {
      if (a.depthOffset != b.depthOffset) return a.depthOffset - b.depthOffset;
      return a.id - b.id;
    });

    for (final gimmick in gimmicks) {
      final img = cachedImages[gimmick.image];
      if (img == null) continue;
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        Rect.fromCenter(
          center: Offset(gimmick.x * bgScale, gimmick.y * bgScale),
          width: img.width * gimmick.scale / 1000 * bgScale,
          height: img.height * gimmick.scale / 1000 * bgScale,
        ),
        painter,
      );
    }
    // roads
    for (final road in roads) {
      final spot1 = allSpots[road.srcSpotId], spot2 = allSpots[road.dstSpotId];
      if (spot1 == null || spot2 == null) continue;
      canvas.drawLine(
        spot1.offset * bgScale,
        spot2.offset * bgScale,
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..strokeWidth = 16 * bgScale
          ..isAntiAlias = true,
      );
    }
    // spots
    const spotImageSize = 160;
    for (final spot in spots.values) {
      final img = cachedImages[spot.shownImage];
      if (img != null) {
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          Rect.fromCenter(
            center: (spot.offset - const Offset(0, 50)) * bgScale,
            width: spotImageSize / 2048 * size.width,
            height: spotImageSize / 2048 * size.width,
          ),
          painter,
        );
      }
    }
    for (final spot in spots.values) {
      final textTopCenter = (spot.offset - const Offset(0, 50)) * bgScale +
          Offset(0, (spotImageSize / 2 + 2) / 2048 * size.width) +
          spot.nameOfs * bgScale;
      final textPadding = Offset(14 * bgScale, 2 * bgScale);

      final tp = TextPainter(
        text: TextSpan(
          text: Transl.spotNames(spot.name).l,
          style: TextStyle(color: Colors.white, fontSize: 22 * bgScale),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout(maxWidth: spotImageSize * 2 / 2048 * size.width);
      // draw text background
      canvas.drawRRect(
        RRect.fromRectXY(
          Rect.fromCenter(
              center: textTopCenter + Offset(0, textPadding.dy + tp.height / 2),
              width: tp.width + textPadding.dx * 2,
              height: tp.height + textPadding.dy * 2),
          textPadding.dx,
          textPadding.dx,
        ),
        Paint()..color = Colors.black.withOpacity(0.8),
      );
      // draw text
      tp.paint(
        canvas,
        Offset(
          textTopCenter.dx - tp.width / 2,
          textTopCenter.dy + textPadding.dy,
        ),
      );
    }

    // top-right header
    final headerImage = cachedImages[map.headerImage];
    if (headerImage != null) {
      final h = size.width / 2 * headerImage.height / headerImage.width;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, h),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(size.width * 0.9, h * 2.5),
            Offset(size.width * 0.8, -h * 1.5),
            [
              Colors.cyan,
              Colors.transparent,
            ],
          ),
      );
      canvas.drawImageRect(
        headerImage,
        Rect.fromLTWH(
            0, 0, headerImage.width.toDouble(), headerImage.height.toDouble()),
        Rect.fromLTWH(size.width / 2, 0, size.width / 2, h),
        painter,
      );
    }
  }
}
