import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:photo_view/photo_view.dart';

import 'package:chaldea/app/api/hosts.dart';
import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/db.dart';
import 'package:chaldea/packages/packages.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'schema.dart';

class FfoCard extends StatefulWidget {
  final FFOParams params;
  final BoxFit fit;
  final bool showSave;
  final bool enableZoom;
  final bool showFullScreen;

  FfoCard({
    Key? key,
    required FFOParams params,
    this.fit = BoxFit.contain,
    this.showSave = false,
    this.enableZoom = false,
    this.showFullScreen = false,
  })  : assert(!enableZoom || !showFullScreen),
        params = params.copyWith(),
        super(key: key);

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
            ? () =>
                FFOUtil.showSaveShare(context: context, params: widget.params)
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
      String? localFp = await AtlasIconLoader.i.download(url);
      if (localFp == null) return null;
      provider = FileImage(File(localFp));
    }
    final stream = provider.resolve(ImageConfiguration.empty);
    final Completer<ui.Image?> completer = Completer();
    stream.addListener(ImageStreamListener((info, _) {
      completer.complete(info.image);
    }, onError: (e, s) async {
      // EasyLoading.showError(e.toString());
      logger.e('load Image error: $fn', e, s);
      completer.complete(null);
    }));
    return completer.future;
  }

  static void drawCanvas(
      Canvas canvas, FFOParams params, FfoCanvasImages images) {
    if (params.cropNormalizedSize) {
      canvas.clipRect(const Rect.fromLTWH(0, 0, 512, 720));
      canvas.translate((512 - 1024) / 2, (720 - 1024) / 2);
    }

    double headScale = 1;
    if (params.headPart != null &&
        params.bodyPart != null &&
        params.headPart!.scale != 0) {
      headScale = params.bodyPart!.scale / params.headPart!.scale;
    }

    bool flip = false;
    if ((params.headPart?.direction == 0 && params.bodyPart?.direction == 2) ||
        (params.headPart?.direction == 2 && params.bodyPart?.direction == 0)) {
      flip = true;
    }

    int headX2 = (params.bodyPart?.headX2 == 0
            ? params.bodyPart?.headX
            : params.bodyPart?.headX2) ??
        512;
    int headY2 = (params.bodyPart?.headY2 == 0
            ? params.bodyPart?.headY
            : params.bodyPart?.headY2) ??
        512;

    // draw
    if (params.clipOverflow) {
      canvas.clipRect(Rect.fromCenter(
          center: const Offset(512, 512), width: 512, height: 720));
    }
    if (images.bg_0 != null) {
      canvas.drawImage(
        images.bg_0!,
        const Offset((1024 - 512) / 2, (1024 - 720) / 2),
        Paint(),
      );
    }
    if (images.bodyBack_1 != null) {
      _drawImage(
        canvas: canvas,
        img: images.bodyBack_1!,
      );
    }
    if (images.headBack_2 != null) {
      _drawImage(
        canvas: canvas,
        img: images.headBack_2!,
        flip: flip,
        scale: headScale,
        x: headX2 - 512,
        y: headY2 - 512,
      );
    }
    if (images.bodyBack2_3 != null) {
      _drawImage(
        canvas: canvas,
        img: images.bodyBack2_3!,
      );
    }
    if (images.bodyMiddle_4 != null) {
      _drawImage(
        canvas: canvas,
        img: images.bodyMiddle_4!,
      );
    }
    if (images.headFront_5 != null) {
      _drawImage(
        canvas: canvas,
        img: images.headFront_5!,
        flip: flip,
        scale: headScale,
        x: headX2 - 512,
        y: headY2 - 512,
      );
    }

    if (images.bodyFront_6 != null) {
      _drawImage(
        canvas: canvas,
        img: images.bodyFront_6!,
        // direction: headPart?.direction ?? 0,
      );
    }

    if (images.bgFront_7 != null) {
      canvas.drawImage(images.bgFront_7!,
          const Offset((1024 - 512) / 2, (1024 - 720) / 2), Paint());
    }
  }

  static void _drawImage({
    required Canvas canvas,
    required ui.Image img,
    bool flip = false,
    double scale = 1,
    int x = 0,
    int y = 0,
  }) {
    double x2 = scale == 1 ? x.toDouble() : x - ((scale - 1) / 2 * img.width);
    double y2 = scale == 1 ? y.toDouble() : y - ((scale - 1) / 2 * img.height);
    int orgX = x;
    // render
    if (flip) {
      canvas.save();
      canvas.translate(img.width + orgX * 2, 0);
      canvas.scale(-1, 1);
    }
    if (scale == 1) {
      canvas.drawImage(img, Offset(x2, y2), Paint());
    } else {
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        Rect.fromLTWH(x2, y2, img.width * scale, img.height * scale),
        Paint(),
      );
    }
    if (flip) {
      canvas.restore();
    }
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
    bool gallery = true,
    String? destFp,
    bool share = true,
    String? shareText,
  }) async {
    Uint8List? data = await toBinary(params);
    if (data == null) {
      EasyLoading.showError(S.current.failed);
      return;
    }
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
          S.current.ffo_background
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
        extraHeaders: [SHeader(parts.join('\n'))]);
  }
}
