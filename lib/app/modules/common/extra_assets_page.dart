import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/tools/icon_cache_manager.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/logger.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/utils/wiki.dart';
import 'package:chaldea/widgets/widgets.dart';

class ExtraAssetsPage extends StatelessWidget {
  final ExtraAssets assets;
  final List<String> aprilFoolAssets;
  final List<String> mcSprites;
  final List<String> fandomSprites;
  final bool scrollable;
  final Iterable<String> Function(ExtraAssetsUrl urls)? getUrls;

  const ExtraAssetsPage({
    super.key,
    required this.assets,
    this.aprilFoolAssets = const [],
    this.mcSprites = const [],
    this.fandomSprites = const [],
    this.scrollable = true,
    this.getUrls,
  });

  Iterable<String> _getUrls(ExtraAssetsUrl urls) {
    if (getUrls != null) return getUrls!(urls);
    return urls.allUrls;
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget?>[
      _oneGroup(
        S.current.illustration,
        [
          ..._getUrls(assets.charaGraph),
          ..._getUrls(assets.charaGraphEx),
          ..._getUrls(assets.charaGraphChange),
          ...aprilFoolAssets
        ],
        300,
        showMerge: true,
      ),
      _oneGroup(
          S.current.card_asset_face,
          [
            ..._getUrls(assets.faces),
            ..._getUrls(assets.facesChange),
          ],
          80),
      _oneGroup(S.current.card_asset_status, _getUrls(assets.status), 120),
      _oneGroup(S.current.card_asset_command, _getUrls(assets.commands), 120),
      _oneGroup(
        S.current.card_asset_narrow_figure,
        [
          ..._getUrls(assets.narrowFigure),
          ..._getUrls(assets.narrowFigureChange),
        ],
        300,
      ),
      _oneGroup(
        S.current.card_asset_chara_figure,
        _getUrls(assets.charaFigure),
        300,
        expanded: false,
      ),
      _oneGroup(
        'Forms',
        [
          for (final form in assets.charaFigureForm.values) ..._getUrls(form),
        ],
        300,
        expanded: false,
      ),
      _oneGroup(
        'Characters',
        [
          for (final form in assets.charaFigureMulti.values) ..._getUrls(form),
        ],
        300,
        expanded: false,
      ),
      _oneGroup('equipFace', _getUrls(assets.equipFace), 50),
      _oneGroup('${S.current.sprites} (Mooncell)',
          mcSprites.map(WikiTool.mcFileUrl), 300,
          expanded: false),
      _oneGroup('${S.current.sprites} (Fandom)',
          fandomSprites.map(WikiTool.fandomFileUrl), 300,
          expanded: false),
      spriteViewer(),
    ].whereType<Widget>().toList();
    if (scrollable) {
      return ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 0, 48),
        children: children,
      );
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 0, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      );
    }
  }

  Widget? _oneGroup(
    String title,
    Iterable<String> urls,
    double height, {
    bool expanded = true,
    bool showMerge = true,
  }) {
    final _urls = urls.toList();
    if (_urls.isEmpty) return null;
    return SimpleAccordion(
      expanded: expanded,
      headerBuilder: (context, expanded) => Row(
        children: [
          Expanded(child: Text(title)),
          if (showMerge && expanded && _urls.length > 1)
            IconButton(
              onPressed: () {
                router.pushPage(MergeImagePage(imageUrls: _urls.toList()));
              },
              icon: Icon(Icons.ios_share, color: Theme.of(context).hintColor),
              tooltip: S.current.share,
              iconSize: 20,
            )
        ],
      ),
      expandElevation: 0,
      contentBuilder: (context) => SizedBox(
        height: height,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: _urls.length,
            itemBuilder: (context, index) => CachedImage(
              imageUrl: _urls[index],
              onTap: () {
                FullscreenImageViewer.show(
                    context: context, urls: _urls, initialPage: index);
              },
              showSaveOnLongPress: true,
            ),
            separatorBuilder: (context, index) => const SizedBox(width: 8),
          ),
        ),
      ),
    );
  }

  Widget? spriteViewer() {
    if (assets.spriteModel.allUrls.isEmpty) return null;
    Map<String, List<int>> ascensionModels = {};
    Map<String, List<int>> costumeModels = {};
    final reg = RegExp(r'(?:/Servants/)(\d+)(?:/)');
    assets.spriteModel.ascension?.forEach((key, value) {
      final id = reg.firstMatch(value)?.group(1);
      if (id == null) return;
      ascensionModels.putIfAbsent(id, () => []).add(key);
    });
    assets.spriteModel.costume?.forEach((key, value) {
      final id = reg.firstMatch(value)?.group(1);
      if (id == null) return;
      costumeModels.putIfAbsent(id, () => []).add(key);
    });

    Widget _tile(String title, String key) {
      return ListTile(
        dense: true,
        title: Text('ꔷ $title'),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () => launch('https://katboi01.github.io/FateViewer/?id=$key',
            external: true),
      );
    }

    List<Widget> children = [];
    ascensionModels.forEach((key, ascensions) {
      children.add(
          _tile('${S.current.ascension_short} ${ascensions.join("&")}', key));
    });
    costumeModels.forEach((key, costumeIds) {
      children.add(_tile(
          costumeIds
              .map((e) => db.gameData.costumesById[e]?.lName.l ?? 'Costume $e')
              .join('& '),
          key));
    });

    return SimpleAccordion(
      headerBuilder: (context, _) =>
          Text('${S.current.sprites} (katboi01\'s Fate Viewer)'),
      expandElevation: 0,
      contentBuilder: (context) =>
          Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class MergeImagePage extends StatefulWidget {
  final String? title;
  final List<String> imageUrls;

  const MergeImagePage({super.key, this.title, required this.imageUrls});

  @override
  State<MergeImagePage> createState() => _MergeImagePageState();
}

class _MergeImagePageState extends State<MergeImagePage> {
  Uint8List? imgBytes;
  Size? size;
  dynamic status;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      load().catchError((e, s) {
        logger.e('merge images failed', e, s);
        update(e);
      });
    });
  }

  void update(String? s) {
    status = s;
    if (mounted) setState(() {});
  }

  Future<void> load() async {
    if (widget.imageUrls.isEmpty) return;
    imgBytes = null;
    size = null;
    update(null);
    List<ui.Image> images = [];
    final imagesUrls = widget.imageUrls.toList();
    for (int index = 0; index < imagesUrls.length; index++) {
      update('Reading $index/${imagesUrls.length}...');
      String url = imagesUrls[index];
      ImageProvider? provider;
      if (AtlasIconLoader.i.shouldCacheImage(url)) {
        final fp = await AtlasIconLoader.i.get(url);
        if (fp != null) {
          provider = FileImage(File(fp));
        }
      } else {
        url = CachedImage.proxyMooncellImage(url);
        provider = CachedNetworkImageProvider(url,
            cacheManager: ImageViewerCacheManager());
      }
      if (provider == null) continue;
      final uiImg = await ImageActions.resolveImage(provider);
      if (uiImg != null) images.add(uiImg);
    }
    if (images.isEmpty) {
      update('No image loaded');
      return;
    }

    double w = Maths.max(images.map((e) => e.width)).toDouble(),
        h = Maths.max(images.map((e) => e.height)).toDouble();
    int colCount = sqrt(images.length).ceil();
    int rowCount = (images.length / colCount).ceil();

    final canvasSize =
        size = Size(w * colCount.toDouble(), h * rowCount.toDouble());

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
          const Offset(0, 0), Offset(canvasSize.width, canvasSize.height)),
    );
    for (int row = 0; row < rowCount; row++) {
      for (int col = 0; col < colCount; col++) {
        int index = row * colCount + col;
        final img = images.getOrNull(index);
        if (img == null) continue;
        update('Drawing $index/${images.length}...');
        await Future.delayed(const Duration(milliseconds: 50));
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          Rect.fromLTWH(
              col * w, row * h, img.width.toDouble(), img.height.toDouble()),
          Paint()
            ..filterQuality = FilterQuality.high
            ..isAntiAlias = true,
        );
      }
    }
    final picture = recorder.endRecording();
    update('Rendering...');
    await Future.delayed(const Duration(milliseconds: 50));
    ui.Image img = await picture.toImage(
        canvasSize.width.toInt(), canvasSize.height.toInt());
    imgBytes = (await img.toByteData(format: ui.ImageByteFormat.png))
        ?.buffer
        .asUint8List();
    update('done');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Merge Images'),
      ),
      body: Column(
        children: [
          Expanded(
            child: imgBytes != null
                ? PhotoView(
                    backgroundDecoration:
                        const BoxDecoration(color: Colors.transparent),
                    imageProvider: MemoryImage(imgBytes!),
                    filterQuality: FilterQuality.high,
                    minScale: PhotoViewComputedScale.contained * 0.4,
                  )
                : Center(child: Text(status?.toString() ?? '...')),
          ),
          if (size != null)
            Text(
              '${size!.width.toInt()}×${size!.height.toInt()}',
              textAlign: TextAlign.center,
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: buttonBar,
            ),
          )
        ],
      ),
    );
  }

  Widget get buttonBar {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      children: [
        ElevatedButton(
          onPressed: imgBytes == null
              ? null
              : () {
                  ImageActions.showSaveShare(
                    context: context,
                    data: imgBytes,
                    destFp: joinPaths(db.paths.downloadDir,
                        'merged-${DateTime.now().toString().replaceAll(':', '-')}.png'),
                  );
                },
          child: Text('${S.current.save}/${S.current.share}'),
        ),
      ],
    );
  }
}
