// ignore_for_file: constant_identifier_names
part of ffo;

const int _LAND_0 = 0;
const int _BODY_BACK_1 = 1;
const int _HEAD_BACK_2 = 2;
const int _BODY_BACK2_3 = 3;
const int _BODY_MIDDLE_4 = 4;
const int _HEAD_FRONT_5 = 5;
const int _BODY_FRONT_6 = 6;
const int _LAND_FRONT_7 = 7;

String padSvtId(int id) {
  return id.toString().padLeft(3, '0');
}

//id,servant_id,direction,scale,head_x,head_y,body_x,body_y,head_x2,head_y2
class FFOPart {
  int id;
  int svtId;
  int direction;
  double scale;
  int headX;
  int headY;
  int bodyX;
  int bodyY;
  int headX2;
  int headY2;

  static int _toInt(dynamic v) {
    if (v is String) return int.parse(v);
    if (v is num) return v.toInt();
    throw FormatException('${v.runtimeType} v=$v is not a int value');
  }

  static double _toDouble(dynamic v) {
    if (v is String) return double.parse(v);
    if (v is num) return v.toDouble();
    throw FormatException('${v.runtimeType} v=$v is not a double value');
  }

  FFOPart.fromList(List row)
      : id = _toInt(row[0]),
        svtId = _toInt(row[1]),
        direction = _toInt(row[2]),
        scale = _toDouble(row[3]),
        headX = _toInt(row[4]),
        headY = _toInt(row[5]),
        bodyX = _toInt(row[6]),
        bodyY = _toInt(row[7]),
        headX2 = _toInt(row[8]),
        headY2 = _toInt(row[9]);
}

class FFOParams {
  FFOPart? headPart;
  FFOPart? bodyPart;
  FFOPart? landPart;
  final bool _clipOverflow; // not used
  bool cropNormalizedSize;

  final List<ui.Image?> images = List.filled(8, null, growable: false);

  StreamController<FFOParams> onChanged = StreamController.broadcast();

  FFOParams({
    this.headPart,
    this.bodyPart,
    this.landPart,
    bool clipOverflow = false,
    this.cropNormalizedSize = false,
  }) : _clipOverflow = clipOverflow {
    init();
  }

  Future<void> init() async {
    await _setPart(headPart, 0);
    await _setPart(bodyPart, 1);
    await _setPart(landPart, 2);
    onChanged.sink.add(this);
  }

  void dispose() {
    onChanged.close();
  }

  List<FFOPart?> get parts => [headPart, bodyPart, landPart];

  bool get isEmpty =>
      parts.every((e) => e == null) || images.every((e) => e == null);

  /// If [where] is null, set all parts
  Future<void> setPart(FFOPart? svt, [int? where]) async {
    if (where != null) {
      await _setPart(svt, where);
      onChanged.sink.add(this);
    } else {
      await setParts(head: svt, body: svt, land: svt);
    }
  }

  Future<void> setParts({FFOPart? head, FFOPart? body, FFOPart? land}) async {
    await _setPart(head, 0);
    await _setPart(body, 1);
    await _setPart(land, 2);
    onChanged.sink.add(this);
  }

  Future<void> _setPart(FFOPart? svt, int where) async {
    // wait the previous render completed
    if (svt == null) {
      switch (where) {
        case 0:
          headPart = null;
          images[_HEAD_FRONT_5] = null;
          images[_HEAD_BACK_2] = null;
          break;
        case 1:
          bodyPart = null;
          images[_BODY_FRONT_6] = null;
          images[_BODY_MIDDLE_4] = null;
          images[_BODY_BACK_1] = null;
          images[_BODY_BACK2_3] = null;
          break;
        case 2:
          landPart = null;
          images[_LAND_0] = null;
          images[_LAND_FRONT_7] = null;
          break;
        default:
          throw 'part=$where, not in 0,1,2';
      }
    } else {
      String strId = padSvtId(svt.svtId);
      switch (where) {
        case 0:
          headPart = svt;
          images[_HEAD_FRONT_5] = await _loadImage(
              join(_baseDir, 'Head', 'sv${strId}_head_front.png'));
          images[_HEAD_BACK_2] = await _loadImage(
              join(_baseDir, 'Head', 'sv${strId}_head_back.png'));
          break;
        case 1:
          bodyPart = svt;
          images[_BODY_FRONT_6] = await _loadImage(
              join(_baseDir, 'Body', 'sv${strId}_body_front.png'));
          images[_BODY_MIDDLE_4] = await _loadImage(
              join(_baseDir, 'Body', 'sv${strId}_body_middle.png'));
          images[_BODY_BACK_1] = await _loadImage(
              join(_baseDir, 'Body', 'sv${strId}_body_back.png'));
          images[_BODY_BACK2_3] = await _loadImage(
              join(_baseDir, 'Body', 'sv${strId}_body_back2.png'));
          break;
        case 2:
          landPart = svt;
          images[_LAND_0] =
          await _loadImage(join(_baseDir, 'Land', 'bg_$strId.png'));
          images[_LAND_FRONT_7] =
          await _loadImage(join(_baseDir, 'Land', 'bg_${strId}_front.png'));
          break;
        default:
          throw 'part=$where, not in 0,1,2';
      }
    }
  }

  void drawCanvas(Canvas canvas) {
    if (cropNormalizedSize) {
      canvas.clipRect(Rect.fromLTWH(0, 0, 512, 720));
      canvas.translate((512 - 1024) / 2, (720 - 1024) / 2);
    }

    double headScale = 1;
    if (headPart != null && bodyPart != null && headPart!.scale != 0) {
      headScale = bodyPart!.scale / headPart!.scale;
    }

    bool flip = false;
    if ((headPart?.direction == 0 && bodyPart?.direction == 2) ||
        (headPart?.direction == 2 && bodyPart?.direction == 0)) {
      flip = true;
    }

    int headX2 =
        (bodyPart?.headX2 == 0 ? bodyPart?.headX : bodyPart?.headX2) ?? 512;
    int headY2 =
        (bodyPart?.headY2 == 0 ? bodyPart?.headY : bodyPart?.headY2) ?? 512;

    // draw
    if (_clipOverflow) {
      canvas.clipRect(
          Rect.fromCenter(center: Offset(512, 512), width: 512, height: 720));
    }
    if (images[_LAND_0] != null) {
      canvas.drawImage(images[_LAND_0]!,
          Offset((1024 - 512) / 2, (1024 - 720) / 2), Paint());
    }
    if (images[_BODY_BACK_1] != null) {
      _drawImage(
        canvas: canvas,
        img: images[_BODY_BACK_1]!,
      );
    }
    if (images[_HEAD_BACK_2] != null) {
      _drawImage(
        canvas: canvas,
        img: images[_HEAD_BACK_2]!,
        flip: flip,
        scale: headScale,
        x: headX2 - 512,
        y: headY2 - 512,
      );
    }
    if (images[_BODY_BACK2_3] != null) {
      _drawImage(
        canvas: canvas,
        img: images[_BODY_BACK2_3]!,
      );
    }
    if (images[_BODY_MIDDLE_4] != null) {
      _drawImage(
        canvas: canvas,
        img: images[_BODY_MIDDLE_4]!,
      );
    }
    if (images[_HEAD_FRONT_5] != null) {
      _drawImage(
        canvas: canvas,
        img: images[_HEAD_FRONT_5]!,
        flip: flip,
        scale: headScale,
        x: headX2 - 512,
        y: headY2 - 512,
      );
    }

    if (images[_BODY_FRONT_6] != null) {
      _drawImage(
        canvas: canvas,
        img: images[_BODY_FRONT_6]!,
        // direction: headPart?.direction ?? 0,
      );
    }

    if (images[_LAND_FRONT_7] != null) {
      canvas.drawImage(images[_LAND_FRONT_7]!,
          Offset((1024 - 512) / 2, (1024 - 720) / 2), Paint());
    }
  }

  void _drawImage({
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

  Future<ui.Image?> _loadImage(String fp) async {
    final _f = File(fp);
    if (!_f.existsSync()) {
      // print('$fp not exist');
      return null;
    }
    final stream = FileImage(_f).resolve(ImageConfiguration.empty);
    final Completer<ui.Image?> completer = Completer();
    stream.addListener(ImageStreamListener((info, _) {
      completer.complete(info.image);
    }, onError: (e, s) {
      EasyLoading.showError(e.toString());
      logger.e('load ui.Image error', e, s);
      completer.complete(null);
    }));
    return completer.future;
  }

  Size get canvasSize =>
      cropNormalizedSize ? const Size(512, 720) : const Size(1024, 1024);

  Future<Uint8List?> toBinary() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
          Offset(0, 0), Offset(canvasSize.width, canvasSize.height)),
    );
    drawCanvas(canvas);
    final picture = recorder.endRecording();
    ui.Image img = await picture.toImage(
        canvasSize.width.toInt(), canvasSize.height.toInt());
    ByteData? data = (await img.toByteData(format: ui.ImageByteFormat.png));
    return data?.buffer.asUint8List();
  }

  /// save to temp file first, then open sheet
  Future showSaveShare({
    required BuildContext context,
    bool gallery = true,
    String? destFp,
    bool share = true,
    String? shareText,
  }) async {
    Uint8List? data = await toBinary();
    if (data == null) {
      EasyLoading.showError('Failed');
      return;
    }
    String fn = 'ffo-' + parts.map((e) => e?.svtId ?? 0).join('-') + '.png';
    String srcFp = join(db.paths.tempDir, fn); //tempFile
    File(srcFp)
      ..createSync(recursive: true)
      ..writeAsBytesSync(data);
    destFp ??= join(db.paths.appPath, 'ffo_output', fn);
    return ImageActions.showSaveShare(
      context: context,
      data: null,
      srcFp: srcFp,
      gallery: gallery,
      destFp: destFp,
      share: share,
      shareText: shareText ?? fn,
    );
  }

  Widget buildCard(BuildContext context, [tapToFullscreen = false]) {
    final image = FFOCardWidget(params: this, showSave: true);
    if (isEmpty) {
      return image;
    }
    return GestureDetector(
      child: image,
      onTap: tapToFullscreen
          ? () => Navigator.of(context).push(PageRouteBuilder(
        fullscreenDialog: true,
        opaque: false,
        pageBuilder: (context, _, __) => FullscreenImageViewer(
          children: [
            FFOCardWidget(
              params: this,
              showSave: true,
              enableZoom: true,
            )
          ],
        ),
      ))
          : null,
    );
  }
}

class FFOCardWidget extends StatefulWidget {
  final FFOParams params;
  final BoxFit fit;
  final bool showSave;
  final bool enableZoom;

  const FFOCardWidget({
    Key? key,
    required this.params,
    this.fit = BoxFit.contain,
    this.showSave = true,
    this.enableZoom = false,
  }) : super(key: key);

  @override
  _FFOCardWidgetState createState() => _FFOCardWidgetState();
}

class _FFOCardWidgetState extends State<FFOCardWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.params.onChanged.stream,
      builder: (context, snapshot) {
        Widget child = FittedBox(
          fit: widget.fit,
          child: CustomPaint(
            size: widget.params.canvasSize,
            painter: FFOPainter(widget.params),
          ),
        );
        if (widget.showSave) {
          child = GestureDetector(
            child: child,
            onLongPress: () => widget.params.showSaveShare(context: context),
          );
        }
        if (widget.enableZoom) {
          child = PhotoView.customChild(
            child: child,
            backgroundDecoration: BoxDecoration(color: Colors.transparent),
            minScale: PhotoViewComputedScale.contained * 0.25,
            initialScale: PhotoViewComputedScale.contained,
            // heroAttributes: PhotoViewHeroAttributes(tag: widget.params),
          );
        } else {
          // no Hero effect
          // child = Hero(tag: widget.params, child: child);
        }
        return child;
      },
    );
  }
}

class FFOPainter extends CustomPainter {
  FFOParams params;

  FFOPainter(this.params);

  List<ui.Image?>? _cachedImages;

  @override
  void paint(Canvas canvas, Size size) {
    params.drawCanvas(canvas);
    _cachedImages = List.of(params.images);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! FFOPainter) return true;
    if (oldDelegate.params.cropNormalizedSize != params.cropNormalizedSize ||
        oldDelegate.params._clipOverflow != params._clipOverflow ||
        oldDelegate.params.headPart != params.headPart ||
        oldDelegate.params.bodyPart != params.bodyPart ||
        oldDelegate.params.landPart != params.landPart) {
      return true;
    }
    for (var i = 0; i < params.images.length; i++) {
      if (_cachedImages == null || _cachedImages![i] != params.images[i]) {
        return true;
      }
    }
    return false;
  }
}
