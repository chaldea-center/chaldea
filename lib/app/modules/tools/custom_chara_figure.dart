import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../../generated/l10n.dart';

class CustomCharaFigureIntro extends HookWidget {
  const CustomCharaFigureIntro({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: Text(S.current.custom_chara_figure)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(S.current.custom_chara_figure_intro),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(4),
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ID/URL',
                hintText: '/CharaFigure/98005000/',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              final text = controller.text;
              final asset = AssetURL.parseRegion(text);
              final figureId = int.tryParse(text) ?? asset.getCharaFigureId(text);
              if (figureId == null) {
                EasyLoading.showError(S.current.invalid_input);
                return;
              }
              router.pushPage(CustomCharaFigurePage(figure: asset.charaFigureId(figureId)));
            },
            icon: const Icon(Icons.arrow_circle_right_outlined),
          )
        ],
      ),
    );
  }
}

class CustomCharaFigurePage extends StatefulWidget {
  final String figure;
  const CustomCharaFigurePage({super.key, required this.figure});

  @override
  State<CustomCharaFigurePage> createState() => _CustomCharaFigurePageState();
}

class _CustomCharaFigurePageState extends State<CustomCharaFigurePage> {
  int face = 0;
  SvtScript? script;
  int? figureId;

  final painterKey = GlobalKey<_CharaFigureImageState>();

  @override
  void initState() {
    super.initState();
    final region = Region.fromUrl(widget.figure) ?? Region.jp;
    figureId = AssetURL.i.getCharaFigureId(widget.figure);
    if (figureId != null) {
      AtlasApi.svtScript(figureId!, region: region).then((value) {
        if (mounted) {
          setState(() {
            script = value?.getOrNull(0);
            if (script == null) {
              EasyLoading.showInfo('Not Found');
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.card_asset_chara_figure),
        actions: [
          IconButton(
            onPressed: export,
            icon: const Icon(Icons.save_alt),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1024 / 768,
                child: Padding(
                  padding: const EdgeInsets.all(36),
                  child: CharaFigureImage(key: painterKey, figureUrl: widget.figure, face: face),
                ),
              ),
            ),
          ),
          kDefaultDivider,
          SafeArea(
            child: SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                // itemCount: script?.,
                itemBuilder: buildFace,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget? buildFace(BuildContext context, int index) {
    Widget child;
    if (index == 0) {
      child = Center(
        child: AutoSizeText(
          S.current.general_default,
          maxLines: 1,
          minFontSize: 6,
        ),
      );
    } else {
      child = CharaFigureImage(
        figureUrl: widget.figure,
        face: index,
        faceOnly: true,
      );
    }
    child = AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
            border: Border.all(
          width: 2,
          color: face == index ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
        )),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: child,
        ),
      ),
    );
    child = InkWell(
      onTap: () {
        setState(() {
          face = index;
        });
      },
      child: child,
    );
    return child;
  }

  void export() async {
    final data = await painterKey.currentState?.export();
    if (data == null) {
      EasyLoading.showError(S.current.failed);
      return;
    }
    if (!mounted) return;
    if (context.mounted) {
      final fp = script == null ? null : joinPaths(db.paths.downloadDir, 'custom_chara_figure_${script?.id}-$face.png');
      ImageActions.showSaveShare(context: context, data: data, destFp: fp);
    }
  }
}

class CharaFigureImage extends StatefulWidget {
  final String? figureUrl;
  final int? figureId;
  final int? face;
  final Region? region;
  final bool faceOnly;

  const CharaFigureImage({super.key, required String this.figureUrl, this.face, this.faceOnly = false})
      : figureId = null,
        region = null;

  const CharaFigureImage.id({
    super.key,
    required int this.figureId,
    this.region = Region.jp,
    this.face,
    this.faceOnly = false,
  }) : figureUrl = null;

  @override
  State<CharaFigureImage> createState() => _CharaFigureImageState();
}

class _CharaFigureImageState extends State<CharaFigureImage> {
  ui.Image? image;

  SvtScript? script;
  int? figureId;
  Region region = Region.jp;
  String? figureUrl;

  Future<void> load() async {
    // image = null;
    // script = null;
    // figureId = null;
    region = widget.region ?? Region.fromUrl(widget.figureUrl ?? "") ?? Region.jp;
    if (widget.figureId != null) {
      figureId = widget.figureId!;
    } else {
      final match = RegExp(r'/CharaFigure/(\d+)/').firstMatch(widget.figureUrl ?? "");
      if (match != null) {
        figureId = int.parse(match.group(1)!);
      }
    }
    if (figureId != null) {
      figureUrl = '${HostsX.atlasAsset.kGlobal}/$region/CharaFigure/$figureId/${figureId}_merged.png';
    }
    if (mounted) setState(() {});
    if (figureUrl == null) return;
    final curFigure = figureUrl!;
    final curFigureId = figureId;

    await Future.wait([
      ImageActions.resolveImageUrl(curFigure).then((img) {
        if (curFigure == figureUrl) image = img;
      }),
      if (figureId != null)
        AtlasApi.svtScript(figureId!).then((scripts) {
          final script = scripts?.getOrNull(0);
          if (curFigureId == figureId) this.script = script;
        }),
    ]);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CharaFigureImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.figureUrl != oldWidget.figureUrl ||
        widget.figureId != oldWidget.figureId ||
        widget.face != oldWidget.face ||
        widget.faceOnly != oldWidget.faceOnly ||
        widget.region != oldWidget.region) {
      load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CharaFigurePainter(
        figure: image,
        face: widget.face,
        script: script,
        faceOnly: widget.faceOnly,
      ),
      size: Size.infinite,
    );
  }

  Future<Uint8List?> export() async {
    if (script == null) return null;
    return ImageUtil.recordCanvas(
      width: 1024,
      height: script!.isHeight1024 ? 1024 : 768,
      paint: CharaFigurePainter(
        figure: image,
        face: widget.face,
        script: script,
        faceOnly: widget.faceOnly,
        applyOffset: false,
      ).paint,
    );
  }
}

class CharaFigurePainter extends CustomPainter {
  final ui.Image? figure;
  final int? face;
  final SvtScript? script;
  final bool faceOnly;
  final bool applyOffset;

  CharaFigurePainter({
    required this.figure,
    required this.face,
    required this.script,
    required this.faceOnly,
    this.applyOffset = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // print('size=$size');
    final figure = this.figure;
    final script = this.script;
    int? face = this.face;
    if (figure == null) return;

    if (size.isInfinite || size.width <= 0) {
      if (!faceOnly) canvas.drawImage(figure, Offset.zero, Paint());
      return;
    }
    if (script == null) {
      if (!faceOnly) {
        canvas.drawImageRect(
          figure,
          Rect.fromLTWH(0, 0, figure.width.toDouble(), figure.height.toDouble()),
          Rect.fromLTWH(0, 0, size.width, size.width * figure.height / figure.width),
          Paint(),
        );
      }
      return;
    }
    // 1024x1024(768+256),256x256
    final _faceSize = script.extendData?.faceSize; // TODO: handle [w, h]
    int faceSize = _faceSize is int ? _faceSize : 256;
    int width = 1024, height = faceSize == 256 ? 1024 - 256 : 1024;
    final double dstScale = size.width / width;
    final double srcScale = figure.width / width;
    // main figure
    int offsetX = 0, offsetY = 0;
    if (applyOffset) {
      offsetX = script.offsetX;
      offsetY = script.offsetY;
    }
    canvas.saveLayer(Rect.largest, Paint());
    if (!faceOnly) {
      draw(
        canvas,
        figure,
        Rect.fromLTWH(0, 0, width * srcScale, height * srcScale),
        Rect.fromLTWH(-offsetX * dstScale, -offsetY * dstScale, width * dstScale, height * dstScale),
        dstScale,
      );
    }

    int colCount = width ~/ faceSize;
    int rowCount = (figure.height / figure.width * width - height) ~/ faceSize;
    // if (face > colCount * rowCount) {
    //   face = (face - 1) % (colCount * rowCount) + 1;
    // }
    if (face == null || colCount <= 0 || rowCount <= 0 || face <= 0 || face >= colCount * rowCount) {
      canvas.restore();
      return;
    }
    int row = (face - 1) ~/ colCount;
    int col = (face - 1) % colCount;
    if (!faceOnly) {
      final destRect = Rect.fromLTWH((script.faceX - offsetX) * dstScale, (script.faceY - offsetY) * dstScale,
          faceSize * dstScale, faceSize * dstScale);
      canvas.drawRect(destRect.deflate(dstScale * 2), Paint()..blendMode = BlendMode.clear);
      draw(
        canvas,
        figure,
        Rect.fromLTWH((col * faceSize) * srcScale, (height + faceSize * row) * srcScale, faceSize * srcScale,
            faceSize * srcScale),
        destRect,
        dstScale,
      );
    } else {
      draw(
        canvas,
        figure,
        Rect.fromLTWH((col * faceSize) * srcScale, (height + faceSize * row) * srcScale, faceSize * srcScale,
            faceSize * srcScale),
        Rect.fromLTWH(0, 0, size.width, size.height),
        dstScale,
      );
    }
    canvas.restore();
  }

  void draw(Canvas canvas, ui.Image image, Rect src, Rect dst, double? deflate, {Paint? paint}) {
    canvas.save();
    if (deflate != null) canvas.clipRect(dst.deflate(deflate));
    canvas.drawImageRect(
      image,
      src,
      dst,
      paint ?? Paint(),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CharaFigurePainter oldDelegate) {
    return figure != oldDelegate.figure ||
        face != oldDelegate.face ||
        script != oldDelegate.script ||
        faceOnly != oldDelegate.faceOnly ||
        applyOffset != oldDelegate.applyOffset;
  }
}
