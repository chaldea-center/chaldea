import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/app_info.dart';
import 'package:chaldea/packages/json_viewer/json_viewer.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

import '../../../../generated/l10n.dart';
import 'layout.dart';
import 'source.dart';

const _debugExamples = <({int id, int form, String note})>[
  (id: 1098297000, form: 0, note: '1024 wide, face 280×256, starts at P2'),
  (id: 1064300, form: 0, note: '1024 wide, face height 322'),
  (id: 1065000, form: 0, note: '2048 wide, default face size'),
  (id: 10017910, form: 1, note: 'Form path, face 309×256'),
  (id: 1064000, form: 1, note: 'Form + 2048 wide + face height 284'),
  (id: 11023000, form: 1, note: 'Full 2048×2048 base figure'),
];

class CustomCharaFigureIntro extends StatefulWidget {
  const CustomCharaFigureIntro({super.key});

  @override
  State<CustomCharaFigureIntro> createState() => _CustomCharaFigureIntroState();
}

class _CustomCharaFigureIntroState extends State<CustomCharaFigureIntro> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.current.custom_chara_figure)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Card(
            child: Padding(padding: const EdgeInsets.all(16), child: Text(S.current.custom_chara_figure_intro)),
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
          FilledButton(
            onPressed: () {
              final source = CharaFigureSource.tryParse(controller.text);
              if (source == null) {
                EasyLoading.showError(S.current.invalid_input);
                return;
              }
              router.pushPage(CustomCharaFigurePage(source: source));
            },
            child: Text('Parse'),
            // icon: const Icon(Icons.arrow_circle_right_outlined),
          ),
          if (AppInfo.isDebugOn) ...[
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('Special examples', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Card(
              child: Column(
                children: [
                  for (int index = 0; index < _debugExamples.length; index++) ...[
                    ListTile(
                      dense: true,
                      title: Text(
                        _debugExamples[index].form == 0
                            ? '${_debugExamples[index].id}'
                            : '${_debugExamples[index].id} · Form ${_debugExamples[index].form}',
                      ),
                      subtitle: Text(_debugExamples[index].note),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        final example = _debugExamples[index];
                        router.pushPage(
                          CustomCharaFigurePage(
                            source: CharaFigureSource(region: Region.jp, id: example.id, form: example.form),
                          ),
                        );
                      },
                    ),
                    if (index < _debugExamples.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CustomCharaFigurePage extends StatefulWidget {
  final CharaFigureSource source;
  const CustomCharaFigurePage({super.key, required this.source});

  @override
  State<CustomCharaFigurePage> createState() => _CustomCharaFigurePageState();
}

class _CustomCharaFigurePageState extends State<CustomCharaFigurePage> {
  late CharaFigureSource source = widget.source;

  final painterKey = GlobalKey<_CharaFigureImageState>();

  @override
  void initState() {
    super.initState();
    loadScripts();
  }

  Future<void> loadScripts({bool refresh = false}) async {
    final requestedId = source.id;
    try {
      if (refresh) source.reset();
      final unavailableForm = await source.loadScripts(refresh: refresh);
      if (refresh) {
        await Future.wait([
          ImageActions.evictImageUrl(source.mergedUrl),
          ImageActions.evictImageUrl(source.nonMergedUrl),
        ]);
      }
      if (!mounted || source.id != requestedId) return;
      setState(() {});
      if (unavailableForm != null) {
        EasyLoading.showInfo('Form $unavailableForm Not Found, use Form ${source.form}');
      }
    } catch (e, s) {
      logger.e('load CharaFigure failed', e, s);
      if (!mounted) return;
      setState(() {});
      EasyLoading.showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${S.current.card_asset_chara_figure} ${source.id}'),
        actions: [
          if (source.scripts.length > 1)
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: source.script?.form,
                items: [
                  for (final item in source.scripts)
                    DropdownMenuItem(value: item.form, child: Text('Form ${item.form}')),
                ],
                onChanged: selectForm,
              ),
            ),
          IconButton(onPressed: export, icon: const Icon(Icons.save_alt)),
          PopupMenuButton<_CharaFigureAction>(
            onSelected: onAction,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _CharaFigureAction.info,
                child: ListTile(leading: Icon(Icons.info_outline), title: Text('Info')),
              ),
              PopupMenuItem(
                value: _CharaFigureAction.refresh,
                child: ListTile(leading: Icon(Icons.refresh), title: Text('Refresh')),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: source.figureWidth / source.baseFigureHeight,
                child: Padding(
                  padding: const EdgeInsets.all(36),
                  child: CharaFigureImage(
                    key: painterKey,
                    source: source,
                    script: source.script,
                    face: source.face,
                    baseFigureHeight: source.baseFigureHeight,
                    assetRevision: source.assetRevision,
                    onInfoChanged: onFigureInfoChanged,
                  ),
                ),
              ),
            ),
          ),
          if (source.isBaseFigureHeightDetected == false)
            ListTile(
              dense: true,
              title: const Text('Base height'),
              trailing: DropdownButton<int>(
                value: source.baseFigureHeight,
                items: const [
                  DropdownMenuItem(value: 768, child: Text('768')),
                  DropdownMenuItem(value: 2048, child: Text('2048')),
                ],
                onChanged: selectBaseFigureHeight,
              ),
            ),
          kDefaultDivider,
          SafeArea(
            child: SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                itemCount: source.faceCount + 1,
                itemBuilder: buildFace,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? buildFace(BuildContext context, int index) {
    Widget child;
    if (index == 0) {
      child = Center(child: AutoSizeText(S.current.general_default, maxLines: 1, minFontSize: 6));
    } else {
      child = CharaFigureImage(
        source: source,
        script: source.script,
        face: index,
        faceOnly: true,
        baseFigureHeight: source.baseFigureHeight,
        assetRevision: source.assetRevision,
      );
    }
    child = AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: source.face == index ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
          ),
        ),
        child: Padding(padding: const EdgeInsets.all(2), child: child),
      ),
    );
    child = InkWell(
      onTap: () {
        setState(() {
          source.face = index;
        });
      },
      child: child,
    );
    return child;
  }

  void onFigureInfoChanged(CharaFigureInfo info) {
    if (!mounted) return;
    setState(() {
      source.figureWidth = info.imageWidth;
      source.faceCount = info.faceCount;
      source.baseFigureHeight = info.baseFigureHeight;
      source.isBaseFigureHeightDetected = info.isBaseFigureHeightDetected;
      if (source.face > source.faceCount) source.face = 0;
    });
  }

  void selectForm(int? form) {
    if (form == null || form == source.script?.form) return;
    final nextScript = source.scripts.firstWhereOrNull((item) => item.form == form);
    if (nextScript == null) return;
    setState(() {
      source.form = form;
      source.reset();
      source.script = nextScript;
    });
  }

  void selectBaseFigureHeight(int? height) {
    if (height == null || height == source.baseFigureHeight) return;
    setState(() {
      source.baseFigureHeight = height;
      source.faceCount = 0;
      source.face = 0;
    });
  }

  void onAction(_CharaFigureAction action) {
    switch (action) {
      case _CharaFigureAction.info:
        showInfo();
        return;
      case _CharaFigureAction.refresh:
        loadScripts(refresh: true);
        return;
    }
  }

  void showInfo() {
    SimpleConfirmDialog(
      scrollable: true,
      showCancel: false,
      title: Text(source.id.toString()),
      content: Column(
        mainAxisSize: .min,
        children: [
          ListTile(
            dense: true,
            title: Text(
              [
                'form:  ${source.form}',
                'faces: ${source.face}/${source.faceCount}',
                'faceSize: ${source.script?.getFaceSize().join('×')}',
                'size: ${source.figureWidth}×${source.baseFigureHeight}',
              ].join('\n'),
            ),
          ),
          const Divider(),
          ListTile(
            dense: true,
            title: const Text('Base Image'),
            // subtitle: Text(Uri.parse(source.nonMergedUrl).path),
            onTap: () => FullscreenImageViewer.show(context: context, urls: [source.nonMergedUrl]),
          ),
          ListTile(
            dense: true,
            title: const Text('Merged Image'),
            // subtitle: Text(Uri.parse(source.mergedUrl).path),
            onTap: () => FullscreenImageViewer.show(context: context, urls: [source.mergedUrl]),
          ),
          if (AppInfo.isDebugOn)
            ListTile(
              dense: true,
              title: const Text('Folder'),
              subtitle: Text(source.explorerFolderUrl),
              onTap: () => launch(source.explorerFolderUrl),
            ),
          const Divider(),
          JsonViewer(source.script?.toJson(), defaultOpen: true),
        ],
      ),
    ).showDialog(context);
  }

  void export() async {
    final data = await painterKey.currentState?.export();
    if (data == null) {
      EasyLoading.showError(S.current.failed);
      return;
    }
    if (!mounted) return;
    if (context.mounted) {
      final fp = source.script == null
          ? null
          : joinPaths(
              db.paths.downloadDir,
              'custom_chara_figure_${source.script?.id}-form${source.script?.form}-${source.face}.png',
            );
      ImageActions.showSaveShare(context: context, data: data, destFp: fp);
    }
  }
}

enum _CharaFigureAction { info, refresh }

@immutable
class CharaFigureInfo {
  final int imageWidth;
  final int faceCount;
  final int baseFigureHeight;
  final bool isBaseFigureHeightDetected;

  const CharaFigureInfo({
    required this.imageWidth,
    required this.faceCount,
    required this.baseFigureHeight,
    required this.isBaseFigureHeightDetected,
  });
}

class CharaFigureImage extends StatefulWidget {
  final CharaFigureSource source;
  final SvtScript? script;
  final int? face;
  final bool faceOnly;
  final int baseFigureHeight;
  final int assetRevision;
  final ValueChanged<CharaFigureInfo>? onInfoChanged;

  const CharaFigureImage({
    super.key,
    required this.source,
    required this.script,
    this.face,
    this.faceOnly = false,
    required this.baseFigureHeight,
    required this.assetRevision,
    this.onInfoChanged,
  });

  @override
  State<CharaFigureImage> createState() => _CharaFigureImageState();
}

class _CharaFigureImageState extends State<CharaFigureImage> {
  ui.Image? image;
  int? detectedBaseImageHeight;
  int loadSerial = 0;

  Future<void> load() async {
    final serial = ++loadSerial;
    final imageCandidates = widget.source.imageCandidates;
    image = null;
    ui.Image? nextImage;
    int? nextBaseImageHeight;
    for (final url in imageCandidates) {
      nextImage = await ImageActions.resolveImageUrl(url);
      if (nextImage != null) break;
    }
    if (widget.onInfoChanged != null) {
      final baseImage = await ImageActions.resolveImageUrl(widget.source.nonMergedUrl);
      nextBaseImageHeight = baseImage?.height;
    }
    if (!mounted || serial != loadSerial) return;
    setState(() {
      image = nextImage;
      detectedBaseImageHeight = nextBaseImageHeight;
    });
    await reportInfo(serial, nextImage, widget.script);
  }

  int get effectiveBaseFigureHeight {
    final detectedHeight = detectedBaseImageHeight;
    if (detectedHeight == null) return widget.baseFigureHeight;
    if (detectedHeight == CharaFigureLayout.pageHeight) {
      return CharaFigureLayout.defaultBaseFigureHeight;
    }
    return detectedHeight;
  }

  Future<void> reportInfo(int serial, ui.Image? image, SvtScript? script) async {
    final callback = widget.onInfoChanged;
    if (callback == null || image == null) return;

    int faceCount = 0;
    if (script != null) {
      final layout = CharaFigureLayout(
        imageWidth: image.width,
        imageHeight: image.height,
        faceSize: script.getFaceSize(),
        baseFigureHeight: effectiveBaseFigureHeight,
      );
      faceCount = layout.faceRects.length;
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (data != null) {
          faceCount = layout.availableFaceCount(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
        }
      } catch (e, s) {
        logger.e('read CharaFigure pixels failed', e, s);
      }
    }
    if (!mounted || serial != loadSerial) return;
    callback(
      CharaFigureInfo(
        imageWidth: image.width,
        faceCount: faceCount,
        baseFigureHeight: effectiveBaseFigureHeight,
        isBaseFigureHeightDetected: detectedBaseImageHeight != null,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    loadSerial++;
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CharaFigureImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.source != oldWidget.source || widget.assetRevision != oldWidget.assetRevision) {
      load();
    } else if (widget.script != oldWidget.script || widget.baseFigureHeight != oldWidget.baseFigureHeight) {
      reportInfo(loadSerial, image, widget.script);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CharaFigurePainter(
        figure: image,
        face: widget.face,
        script: widget.script,
        faceOnly: widget.faceOnly,
        baseFigureHeight: widget.baseFigureHeight,
      ),
      size: Size.infinite,
    );
  }

  Future<Uint8List?> export() async {
    final image = this.image;
    final script = widget.script;
    if (image == null || script == null) return null;
    return ImageUtil.recordCanvas(
      width: image.width,
      height: widget.baseFigureHeight,
      paint: CharaFigurePainter(
        figure: image,
        face: widget.face,
        script: script,
        faceOnly: widget.faceOnly,
        applyOffset: false,
        baseFigureHeight: widget.baseFigureHeight,
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
  final int baseFigureHeight;

  CharaFigurePainter({
    required this.figure,
    required this.face,
    required this.script,
    required this.faceOnly,
    this.applyOffset = true,
    this.baseFigureHeight = CharaFigureLayout.defaultBaseFigureHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // print('size=$size');
    final figure = this.figure;
    final script = this.script;
    int? face = this.face;
    if (figure == null) return;

    if (size.isInfinite || size.width <= 0) {
      // should not reach here
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
    final layout = CharaFigureLayout(
      imageWidth: figure.width,
      imageHeight: figure.height,
      faceSize: script.getFaceSize(),
      baseFigureHeight: baseFigureHeight,
    );
    final dstScale = size.width / layout.outputSize.width;
    int offsetX = 0, offsetY = 0;
    if (applyOffset) {
      offsetX = script.offsetX;
      offsetY = script.offsetY;
    }
    canvas.saveLayer(Rect.largest, Paint());
    if (!faceOnly) {
      final destRect = Rect.fromLTWH(
        -offsetX * dstScale,
        -offsetY * dstScale,
        layout.outputSize.width * dstScale,
        layout.outputSize.height * dstScale,
      );
      canvas.save();
      canvas.clipRect(destRect.deflate(dstScale));
      canvas.drawImageRect(
        figure,
        Rect.fromLTWH(0, 0, figure.width.toDouble(), baseFigureHeight.toDouble()),
        destRect,
        Paint(),
      );
      canvas.restore();
    }

    if (face == null || face <= 0 || face > layout.faceRects.length) {
      canvas.restore();
      return;
    }
    final srcRect = layout.faceRects[face - 1];
    final safeSrcRect = srcRect.deflate(1);
    if (!faceOnly) {
      final destRect = Rect.fromLTWH(
        (script.faceX - offsetX) * dstScale,
        (script.faceY - offsetY) * dstScale,
        layout.faceWidth * dstScale,
        layout.faceHeight * dstScale,
      );
      final safeDestRect = destRect.deflate(dstScale);
      canvas.drawRect(safeDestRect, Paint()..blendMode = BlendMode.clear);
      canvas.drawImageRect(figure, safeSrcRect, safeDestRect, Paint());
    } else {
      final fittedSizes = applyBoxFit(BoxFit.contain, srcRect.size, size);
      final destRect = Alignment.center.inscribe(fittedSizes.destination, Offset.zero & size);
      final thumbnailScale = destRect.width / srcRect.width;
      canvas.drawImageRect(figure, safeSrcRect, destRect.deflate(thumbnailScale), Paint());
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CharaFigurePainter oldDelegate) {
    return figure != oldDelegate.figure ||
        face != oldDelegate.face ||
        script != oldDelegate.script ||
        faceOnly != oldDelegate.faceOnly ||
        applyOffset != oldDelegate.applyOffset ||
        baseFigureHeight != oldDelegate.baseFigureHeight;
  }
}
