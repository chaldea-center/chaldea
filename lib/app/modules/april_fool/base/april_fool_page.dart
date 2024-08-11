import 'dart:math';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/api/api.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'svt_list.dart';

const kExternalAsset = 'https://static.atlasacademy.io/JP/External';

class AprilFoolSvtData {
  int id;
  String icon;
  List<String> assets = [];
  List<String> graphs = [];
  Servant? svt;

  String? curGraph;

  AprilFoolSvtData(this.id, this.icon);

  String get name => svt?.lName.l ?? '$id';
}

class AprilFoolPageData {
  int maxUserSvtCollectionNo = 9999;
  Size size = const Size(512, 724);
  double iconAspectRatio = 1;

  List<AAFileManifest> files = [];
  List<AprilFoolSvtData> servants = [];
  List<String> backgrounds = [];

  AprilFoolSvtData? curSvt;
  String? curBg;

  String Function(AprilFoolPageData data) getFilename = (data) {
    return 'april-fool-${data.curSvt?.id}.png';
  };
}

mixin AprilFoolPageMixin<T extends StatefulWidget> on State<T> {
  AprilFoolPageData data = AprilFoolPageData();

  String get manifestUrl;

  @override
  void initState() {
    super.initState();
    loadManifest(manifestUrl, false);
  }

  Future<void> loadManifest(String manifestUrl, bool refresh) async {
    final files = await showEasyLoading(() => AtlasApi.cacheManager.getModel(
          manifestUrl,
          (data) => (data as List).map((e) => AAFileManifest.fromJson(e)).toList(),
          expireAfter: refresh ? Duration.zero : const Duration(days: 30),
        ));
    if (files == null || files.isEmpty) return;
    data.files = files;
    await parseManifest(files, data);
    if (mounted) setState(() {});
  }

  Future<void> parseManifest(List<AAFileManifest> files, AprilFoolPageData data);

  AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text(S.current.refresh),
              onTap: () {
                loadManifest(manifestUrl, true);
              },
            )
          ],
        )
      ],
    );
  }

  final ScrollController _svtScrollController = ScrollController();

  Widget buildSvtSelector() {
    return SizedBox(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              controller: _svtScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 2),
              itemBuilder: (context, index) {
                final svt = data.servants[index];
                Widget child = CachedImage(
                  imageUrl: svt.icon,
                  aspectRatio: data.iconAspectRatio,
                  showSaveOnLongPress: true,
                  onTap: () {
                    if (data.curSvt == svt) {
                      data.curSvt = null;
                    } else {
                      data.curSvt = svt;
                      svt.curGraph ??= svt.graphs.firstOrNull;
                    }
                    setState(() {});
                  },
                );
                child = Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: data.curSvt == svt ? Theme.of(context).colorScheme.primary : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: child,
                );
                return child;
              },
              itemCount: data.servants.length,
            ),
          ),
          IconButton(
            onPressed: () {
              router.pushPage(AprilFoolSvtListPage(
                servants: data.servants,
                onSelected: (svt) {
                  data.curSvt = svt;
                  if (mounted) {
                    setState(() {});
                    final index = data.servants.indexOf(svt);
                    if (index >= 0 &&
                        _svtScrollController.hasClients &&
                        _svtScrollController.position.hasContentDimensions) {
                      final position = _svtScrollController.position;
                      final newPos = position.minScrollExtent +
                          (position.maxScrollExtent - position.minScrollExtent) * index / data.servants.length;
                      _svtScrollController.animateTo(newPos,
                          duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
                    }
                  }
                },
              ));
            },
            icon: const Icon(Icons.person_search),
          ),
        ],
      ),
    );
  }

  Widget buildSvtGraphSelector() {
    if (data.servants.every((e) => e.graphs.length <= 1)) return const SizedBox.shrink();
    final svt = data.curSvt;
    final listView = ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 2),
      itemCount: svt?.graphs.length ?? 0,
      itemBuilder: (context, index) {
        final graph = svt!.graphs[index];
        Widget child = CachedImage(
          imageUrl: graph,
          aspectRatio: data.size.aspectRatio,
          showSaveOnLongPress: true,
          onTap: () {
            setState(() {
              svt.curGraph = svt.curGraph == graph ? null : graph;
            });
          },
        );
        child = Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            border: Border.all(
              width: 4,
              color: svt.curGraph == graph ? Theme.of(context).colorScheme.primary : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: child,
        );
        return child;
      },
    );
    return SizedBox(height: 72, child: Center(child: listView));
  }

  Widget buildBgSelector() {
    final listView = ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 2),
      itemCount: data.backgrounds.length,
      itemBuilder: (context, index) {
        final bg = data.backgrounds[index];
        Widget child = CachedImage(
          imageUrl: bg,
          aspectRatio: data.size.aspectRatio,
          showSaveOnLongPress: true,
          onTap: () {
            setState(() {
              data.curBg = data.curBg == bg ? null : bg;
            });
          },
        );
        child = Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            border: Border.all(
              width: 4,
              color: data.curBg == bg ? Theme.of(context).colorScheme.primary : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: child,
        );
        return child;
      },
    );
    return SizedBox(height: 72, child: Center(child: listView));
  }

  Widget buildButtonBar() {
    // final svt = data.curSvt?.svt;
    Widget child = OverflowBar(
      alignment: MainAxisAlignment.center,
      children: [
        // svt?.iconBuilder(context: context, width: 24) ?? const SizedBox(width: 24),
        // const SizedBox(width: 16),
        ElevatedButton(onPressed: exportImage, child: Text(S.current.general_export)),
      ],
    );
    return SafeArea(child: child);
  }

  Future<void> exportImage() async {
    final loader = ImageLoader();
    final chara = data.curSvt?.curGraph, bg = data.curBg;
    await Future.wait([loader.loadImage(bg), loader.loadImage(chara)]);

    final imageData = await ImageUtil.recordCanvas(
      width: data.size.width,
      height: data.size.height,
      paint: AprilFoolGraphPainter(
        loader: loader,
        chara: chara,
        bg: bg,
      ).paint,
    );
    if (imageData == null) {
      EasyLoading.showError(S.current.error);
      return;
    }
    if (!mounted) return;
    return ImageActions.showSaveShare(
      context: context,
      data: imageData,
      defaultFilename: data.getFilename(data),
    );
  }
}

class AprilFoolGraph extends StatelessWidget {
  final String? chara;
  final String? bg;
  final Size size;

  const AprilFoolGraph({super.key, required this.chara, required this.bg, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageLoaderWidget(builder: (context, loader) {
      return AspectRatio(
        aspectRatio: size.aspectRatio,
        child: CustomPaint(
          painter: AprilFoolGraphPainter(
            loader: loader,
            chara: chara,
            bg: bg,
          ),
          size: size,
        ),
      );
    });
  }
}

class AprilFoolGraphPainter extends CustomPainter {
  final String? chara;
  final String? bg;
  final ImageLoader loader;
  final int cacheKey;

  AprilFoolGraphPainter({
    required this.chara,
    required this.bg,
    required this.loader,
  }) : cacheKey = loader.cacheKey;

  Paint getPaint() => Paint()..filterQuality = FilterQuality.high;

  @override
  void paint(Canvas canvas, Size size) {
    final _paint = getPaint();

    // canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    void drawImage(String? url) {
      final img = loader.getImage(url);
      if (img == null) return;
      final w = img.width.toDouble(), h = img.height.toDouble();
      final scale = max(size.width / w, size.height / h);
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, w, h),
        Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: w * scale, height: h * scale),
        _paint,
      );
    }

    drawImage(bg);
    drawImage(chara);
  }

  @override
  bool shouldRepaint(AprilFoolGraphPainter oldDelegate) {
    return true;
    // return oldDelegate.chara != chara || oldDelegate.bg != bg || oldDelegate.loader.cacheKey != loader.cacheKey;
  }
}
