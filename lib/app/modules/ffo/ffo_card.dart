import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:photo_view/photo_view.dart';

import 'package:chaldea/app/api/hosts.dart';
import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../app.dart';
import 'part_list.dart';
import 'schema.dart';

class FfoCard extends StatefulWidget {
  final FFOParams params;
  final BoxFit fit;
  final bool showSave;
  final bool enableZoom;
  final bool showFullScreen;

  FfoCard({
    super.key,
    required FFOParams params,
    this.fit = BoxFit.contain,
    this.showSave = false,
    this.enableZoom = false,
    this.showFullScreen = false,
  })  : assert(!enableZoom || !showFullScreen),
        params = params.copyWith();

  @override
  State<FfoCard> createState() => _FfoCardState();
}

class _FfoCardState extends State<FfoCard> {
  final images = FfoCanvasImages();

  @override
  void initState() {
    super.initState();
    setPart(widget.params.headPart, FfoPartWhere.head);
    setPart(widget.params.bodyPart, FfoPartWhere.body);
    setPart(widget.params.bgPart, FfoPartWhere.bg);
  }

  @override
  void didUpdateWidget(covariant FfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.params.headPart != widget.params.headPart) {
      setPart(widget.params.headPart, FfoPartWhere.head);
    }
    if (oldWidget.params.bodyPart != widget.params.bodyPart) {
      setPart(widget.params.bodyPart, FfoPartWhere.body);
    }
    if (oldWidget.params.bgPart != widget.params.bgPart) {
      setPart(widget.params.bgPart, FfoPartWhere.bg);
    }
  }

  void setPart(FfoSvtPart? coord, FfoPartWhere where) async {
    await FFOUtil.setPart(images, null, where);
    if (mounted) setState(() {});
    await FFOUtil.setPart(images, coord, where);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget child = FittedBox(
      fit: widget.fit,
      child: CustomPaint(
        size: widget.params.canvasSize,
        painter: _FFOPainter(widget.params, images),
      ),
    );
    if (widget.showSave || widget.showFullScreen) {
      child = GestureDetector(
        onTap:
            widget.showFullScreen && !widget.params.isEmpty && !images.isEmpty
                ? () => Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (context, _, __) =>
                            FullscreenImageViewer(children: [
                          FfoCard(
                            params: widget.params,
                            showSave: true,
                            enableZoom: true,
                          )
                        ]),
                      ),
                    )
                : null,
        onLongPress: widget.showSave
            ? () async {
                final data = await FFOUtil.toBinary(widget.params);
                if (data == null) {
                  EasyLoading.showError(S.current.failed);
                  return;
                }
                if (mounted) {
                  FFOUtil.showSaveShare(
                      context: context, params: widget.params, data: data);
                }
              }
            : null,
        child: child,
      );
    }
    if (widget.enableZoom) {
      child = PhotoView.customChild(
        backgroundDecoration: const BoxDecoration(color: Colors.transparent),
        minScale: PhotoViewComputedScale.contained * 0.25,
        initialScale: PhotoViewComputedScale.contained,
        child: child,
        // heroAttributes: PhotoViewHeroAttributes(tag: widget.params),
      );
    } else {
      // no Hero effect
      // child = Hero(tag: widget.params, child: child);
    }
    return child;
  }
}

class _FFOPainter extends CustomPainter {
  FFOParams params;
  FfoCanvasImages images;

  _FFOPainter(this.params, this.images);

  List<ui.Image?>? _cachedImages;

  @override
  void paint(Canvas canvas, Size size) {
    FFOUtil.drawCanvas(canvas, params, images);
    _cachedImages = images.toList();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _FFOPainter) return true;
    if (oldDelegate.params.cropNormalizedSize != params.cropNormalizedSize ||
        oldDelegate.params.clipOverflow != params.clipOverflow ||
        oldDelegate.params.headPart != params.headPart ||
        oldDelegate.params.bodyPart != params.bodyPart ||
        oldDelegate.params.bgPart != params.bgPart) {
      return true;
    }
    final newImages = images.toList();
    for (var i = 0; i < newImages.length; i++) {
      if (_cachedImages == null || _cachedImages![i] != newImages[i]) {
        return true;
      }
    }
    return false;
  }
}

abstract class FFOUtil {
  static String get assetsRoot => '${Hosts.atlasAssetHost}/JP/FFO/';

  static String? imgUrl(String? path) {
    if (path == null) return null;
    return '$assetsRoot$path';
  }

  static String? borderedSprite(String? path) {
    if (path == null) return null;
    path = path.replaceFirstMapped(
        RegExp(r'/Sprite/icon_servant_(\d+)\.png'),
        (match) =>
            '/Sprite_bordered/icon_servant_${match.group(1)!}_bordered.png');
    return imgUrl(path);
  }

  static Future<void> setPart(
      FfoCanvasImages images, FfoSvtPart? coord, FfoPartWhere where) async {
    // wait the previous render completed
    if (coord == null) {
      switch (where) {
        case FfoPartWhere.head:
          images.headFront_5 = null;
          images.headBack_2 = null;
          break;
        case FfoPartWhere.body:
          images.bodyFront_6 = null;
          images.bodyMiddle_4 = null;
          images.bodyBack_1 = null;
          images.bodyBack2_3 = null;
          break;
        case FfoPartWhere.bg:
          images.bg_0 = null;
          images.bgFront_7 = null;
          break;
      }
    } else {
      final svt = FfoDB.i.servants[coord.collectionNo];
      switch (where) {
        case FfoPartWhere.head:
          images.headFront_5 = await _loadImage(svt?.headFront);
          images.headBack_2 = await _loadImage(svt?.headBack);
          break;
        case FfoPartWhere.body:
          images.bodyFront_6 = await _loadImage(svt?.bodyFront);
          images.bodyMiddle_4 = await _loadImage(svt?.bodyMiddle);
          images.bodyBack_1 = await _loadImage(svt?.bodyBack);
          images.bodyBack2_3 = await _loadImage(svt?.bodyBack2);
          break;
        case FfoPartWhere.bg:
          images.bg_0 = await _loadImage(svt?.bg);
          images.bgFront_7 = await _loadImage(svt?.bgFront);
          break;
      }
    }
  }

  static Future<ui.Image?> _loadImage(String? fn) async {
    if (fn == null || fn.isEmpty) return null;
    String url = FFOUtil.imgUrl(fn)!;
    ImageProvider provider;
    if (kIsWeb) {
      provider = CachedNetworkImageProvider(url);
    } else {
      String? localFp = await AtlasIconLoader.i.get(url);
      if (localFp == null) return null;
      provider = FileImage(File(localFp));
    }
    return ImageActions.resolveImage(provider);
  }

  static void drawCanvas(
      Canvas canvas, FFOParams params, FfoCanvasImages images) {
    const double w0 = 1024, h0 = 1024, w1 = 512, h1 = 720;
    final centerRect = Rect.fromCenter(
        center: const Offset(w0 / 2, h0 / 2), width: w1, height: h1);
    if (params.cropNormalizedSize) {
      canvas.save();
      canvas.translate(-(w0 - w1) / 2, -(h0 - h1) / 2);
    }
    bool clip = params.cropNormalizedSize || params.clipOverflow;
    if (clip) {
      canvas.save();
      canvas.clipRect(centerRect);
    }

    final body = params.bodyPart;
    final head = params.headPart;

    void _drawLand(ui.Image? img) {
      if (img == null) return;
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        centerRect,
        Paint(),
      );
    }

    void _drawBody(ui.Image? img) {
      if (img == null) return;
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        const Rect.fromLTWH(0, 0, w0, h0),
        Paint(),
      );
    }

    bool flipHead = (head?.direction == 0 && body?.direction == 2) ||
        (head?.direction == 2 && body?.direction == 0);

    void _drawHead(ui.Image? img, bool use2) {
      if (img == null) return;
      if (body == null || head == null) return _drawBody(img);
      canvas.save();
      if (body.headX2 == 0 && body.headY2 == 0) {
        use2 = false;
      }
      int headX = use2 ? body.headX2 : body.headX,
          headY = use2 ? body.headY2 : body.headY;
      canvas.translate(headX.toDouble(), headY.toDouble());
      if (flipHead) canvas.scale(-1, 1);
      double scale = body.scale / head.scale;

      canvas.drawImageRect(
        img,
        head.collectionNo == 402
            ? Rect.fromLTWH(0, -20, img.width.toDouble(), img.height.toDouble())
            : Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        Rect.fromCenter(
          center: const Offset(0, 0),
          width: w0 * scale,
          height: h0 * scale,
        ),
        Paint(),
      );
      canvas.restore();
    }

    _drawLand(images.bg_0);
    _drawBody(images.bodyBack_1);
    _drawHead(images.headBack_2, false);
    _drawBody(images.bodyBack2_3);
    _drawBody(images.bodyMiddle_4);
    _drawHead(images.headFront_5, true);
    _drawBody(images.bodyFront_6);
    _drawLand(images.bgFront_7);

    if (clip) canvas.restore();
    if (params.cropNormalizedSize) canvas.restore();
  }

  static Future<Uint8List?> toBinary(FFOParams params) async {
    final recorder = ui.PictureRecorder();
    final size = params.canvasSize;
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
    );
    final images = FfoCanvasImages();
    await FFOUtil.setPart(images, params.headPart, FfoPartWhere.head);
    await FFOUtil.setPart(images, params.bodyPart, FfoPartWhere.body);
    await FFOUtil.setPart(images, params.bgPart, FfoPartWhere.bg);
    drawCanvas(canvas, params, images);
    final picture = recorder.endRecording();
    ui.Image img =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    ByteData? data = (await img.toByteData(format: ui.ImageByteFormat.png));
    return data?.buffer.asUint8List();
  }

  /// save to temp file first, then open sheet
  static Future showSaveShare({
    required BuildContext context,
    required FFOParams params,
    required Uint8List data,
    bool gallery = true,
    String? destFp,
    bool share = true,
    String? shareText,
  }) {
    String fn =
        'ffo-${params.parts.map((e) => e?.collectionNo ?? 0).join('-')}.png';
    destFp ??= joinPaths(db.paths.appPath, 'ffo_output', fn);
    List<String> parts = [];
    for (int index = 0; index < 3; index++) {
      final part = params.parts[index];
      if (part != null) {
        String partName = [
          S.current.ffo_head,
          S.current.ffo_body,
          S.current.background
        ][index];
        parts.add('$partName: No.${part.collectionNo}-${part.svt?.shownName}');
      }
    }
    return ImageActions.showSaveShare(
      context: context,
      data: data,
      srcFp: null,
      gallery: gallery,
      destFp: destFp,
      share: share,
      shareText: shareText ?? fn,
      extraHeaders: [SHeader(parts.join('\n'))],
    );
  }
}

class PartChooser extends StatelessWidget {
  final FfoPartWhere where;
  final FfoSvtPart? part;
  final Widget? placeholder;
  final ValueChanged<FfoSvtPart?> onChanged;
  const PartChooser({
    super.key,
    required this.where,
    required this.part,
    this.placeholder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    String icon;
    switch (where) {
      case FfoPartWhere.head:
        icon = 'UI/icon_servant_head_on.png';
        break;
      case FfoPartWhere.body:
        icon = 'UI/icon_servant_body_on.png';
        break;
      case FfoPartWhere.bg:
        icon = 'UI/icon_servant_bg_on.png';
        break;
    }

    return InkWell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          (part?.svt?.icon == null && placeholder != null)
              ? SizedBox(height: 72, width: 72, child: placeholder)
              : db.getIconImage(FFOUtil.imgUrl(part?.svt?.icon), height: 72),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              db.getIconImage(FFOUtil.imgUrl(icon), width: 16),
              Text(where.shownName),
            ],
          ),
        ],
      ),
      onTap: () {
        router.pushPage(
          FfoPartListPage(
            where: where,
            onSelected: onChanged,
          ),
          detail: true,
        );
      },
    );
  }
}
