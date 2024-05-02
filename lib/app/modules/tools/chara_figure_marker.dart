import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/servant/servant_list.dart';
import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'aa_explorer_preview.dart';

class _DataSet<T> {
  final String title;
  final String indexPagePath;
  final RegExp regexp;
  final T Function(String imgId) imageIdParser;
  final String repoFilename;
  final ExtraCharaImageBase<T> Function(int svtId) constructor;
  final ExtraCharaImageBase<T> Function(Map e) fromJson;
  final Map<T, int> markedCharaSvtIds;
  final Set<T> nonSvtImageIds;
  final List<String> Function(ExtraAssets extraAssets) getExistUrls;
  final String Function(T imageId) toUrl;

  List<ExtraCharaImageBase<T>> repoData = [];
  List<T> allImageIds = [];

  _DataSet({
    required this.title,
    required this.indexPagePath,
    required this.regexp,
    required this.imageIdParser,
    required this.repoFilename,
    required this.constructor,
    required this.fromJson,
    required this.markedCharaSvtIds,
    required this.nonSvtImageIds,
    required this.getExistUrls,
    required this.toUrl,
  });
}

class CharaFigureMarker<T> extends StatefulWidget {
  final _DataSet<T> data;

  const CharaFigureMarker._(this.data, {super.key});

  static CharaFigureMarker<int> figure() {
    return CharaFigureMarker._(_DataSet<int>(
      title: "CharaFigure",
      indexPagePath: '/aa-fgo-public/JP/CharaFigure/',
      regexp: RegExp(r'/CharaFigure/(\d+)/'),
      imageIdParser: (v) => int.parse(v),
      repoFilename: 'extra_charafigure.json',
      constructor: (svtId) => ExtraCharaFigure(svtId: svtId),
      fromJson: (json) => ExtraCharaFigure.fromJson(Map.from(json)),
      markedCharaSvtIds: db.settings.misc.markedCharaFigureSvtIds,
      nonSvtImageIds: db.settings.misc.nonSvtCharaFigureIds,
      getExistUrls: (extraAssets) => [
        ...extraAssets.charaFigure.allUrls,
        for (final x in extraAssets.charaFigureMulti.values) ...x.allUrls,
      ],
      toUrl: (imageId) => 'https://static.atlasacademy.io/JP/CharaFigure/$imageId/$imageId.png',
    ));
  }

  static CharaFigureMarker<String> image() {
    return CharaFigureMarker._(_DataSet<String>(
      title: "CharaImage",
      indexPagePath: '/aa-fgo-public/JP/Image/',
      regexp: RegExp(r'JP/Image/([^/]+)/'),
      imageIdParser: (v) => v,
      repoFilename: 'extra_image.json',
      constructor: (svtId) => ExtraCharaImage(svtId: svtId),
      fromJson: (json) => ExtraCharaImage.fromJson(Map.from(json)),
      markedCharaSvtIds: db.settings.misc.markedCharaImageSvtIds,
      nonSvtImageIds: db.settings.misc.nonSvtCharaImageIds,
      getExistUrls: (extraAssets) => extraAssets.image.allUrls.toList(),
      toUrl: (imageId) => 'https://static.atlasacademy.io/JP/Image/$imageId/$imageId.png',
    ));
  }

  @override
  State<CharaFigureMarker<T>> createState() => _CharaFigureMarkerState<T>();
}

class _CharaFigureMarkerState<T> extends State<CharaFigureMarker<T>> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 5, vsync: this);
  final manager = AtlasExplorerManager();
  late final _DataSet<T> data = widget.data;

  @override
  void initState() {
    super.initState();
    manager.setAuth(null);
    loadImages(false);
  }

  Future<void> loadImages(bool refresh) async {
    final htmlText = await manager.navigateTo(data.indexPagePath, refresh: refresh);
    if (htmlText == null) {
      return;
    }
    final charaIds = data.regexp.allMatches(htmlText).map((e) => data.imageIdParser(e.group(1)!)).toSet();
    final existingCharas = <T?>{
      for (final svt in db.gameData.servantsById.values)
        ...data.getExistUrls(svt.extraAssets).map((e) {
          final m = data.regexp.firstMatch(e)?.group(1);
          if (m == null) return null;
          return data.imageIdParser(m);
        }),
    };
    charaIds.removeAll(existingCharas);

    final repoList = await manager.api.getModel(
      HostsX.proxyWorker(
          'https://github.com/atlasacademy/fgo-game-data-api/raw/master/app/data/mappings/${data.repoFilename}',
          onlyCN: false),
      (v) => (v as List).map((e) => data.fromJson(e)).toList(),
      expireAfter: refresh ? Duration.zero : null,
    );
    if (repoList != null) {
      data.repoData = repoList;
      charaIds.removeAll(<T>[for (final x in repoList) ...x.imageIds]);
    }

    data.allImageIds = charaIds.toList();

    EasyLoading.showToast('${data.allImageIds.length} Unknown ${data.title}');
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${data.title} Marker'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () async {
                  await manager.showAuthInput(context);
                  if (mounted) setState(() {});
                },
                child: const Text('Input Auth'),
              ),
              PopupMenuItem(
                onTap: () {
                  loadImages(true);
                },
                child: const Text('Refresh List'),
              ),
              PopupMenuItem(
                onTap: () {
                  router.showDialog(
                    builder: (context) => SimpleDialog(
                      title: const Text("Max Grid Width"),
                      children: [
                        for (final (text, size) in [('Large', 240), ('Medium', 180), ('Small', 120)])
                          ListTile(
                            title: Text(text),
                            subtitle: Text(size.toString()),
                            selected: gridMaxExtent == size,
                            onTap: () {
                              gridMaxExtent = size;
                              Navigator.pop(context);
                              if (mounted) setState(() {});
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                          )
                      ],
                    ),
                  );
                },
                child: const Text("Grid Size"),
              ),
              PopupMenuItem(
                onTap: exportData,
                child: const Text('Export Data'),
              ),
            ],
          ),
        ],
        bottom: FixedHeight.tabBar(TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unknown'),
            Tab(text: 'Marked'),
            Tab(text: 'Non-Svt'),
            Tab(text: 'Repo'),
          ],
        )),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    List<T> unknownIds = [], markedIds = [], nonSvtIds = [];
    for (final id in data.allImageIds) {
      if (data.markedCharaSvtIds.containsKey(id)) {
        markedIds.add(id);
      } else if (data.nonSvtImageIds.contains(id)) {
        nonSvtIds.add(id);
      } else {
        unknownIds.add(id);
      }
    }
    // print('${unknownIds.length} unknownIds, ${nonSvtIds.length} nonSvtIds');
    return TabBarView(
      controller: _tabController,
      children: [
        buildGrid(data.allImageIds.toList()),
        buildGrid(unknownIds),
        buildGrid(markedIds),
        buildGrid(nonSvtIds),
        buildRepo(),
      ],
    );
  }

  static int gridMaxExtent = 120;

  Widget buildGrid(List<T> ids) {
    ids.sort();
    if (ids.isNotEmpty && ids.first is int) {
      ids = ids.reversed.toList();
    }
    return GridView.builder(
      itemCount: ids.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: gridMaxExtent.toDouble(),
        mainAxisSpacing: 8,
        //  crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: 1024 / 1500,
      ),
      itemBuilder: (context, index) {
        final id = ids[index];
        final isNonSvt = data.nonSvtImageIds.contains(id);
        final svt = db.gameData.servantsById[data.markedCharaSvtIds[id]];
        BasicServant? entity;
        if (id is int) {
          entity = db.gameData.entities[id] ?? db.gameData.entities[id ~/ 10 * 10];
        }
        return Column(
          children: [
            Expanded(
              flex: 2,
              child: CachedImage(
                imageUrl: data.toUrl(id),
                viewFullOnTap: true,
                cachedOption: CachedImageOption(
                  errorWidget: (context, url, error) => Text(url),
                ),
              ),
            ),
            AutoSizeText(
              id.toString(),
              maxLines: 1,
              minFontSize: 6,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (entity != null)
              InkWell(
                onTap: entity.routeTo,
                child: Text(
                  '${entity.id}?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      data.markedCharaSvtIds.remove(id);
                      data.nonSvtImageIds.add(id);
                      setState(() {});
                    },
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.no_accounts,
                      color: isNonSvt ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor,
                      size: 16,
                    ),
                  ),
                  Flexible(
                    child: InkWell(
                      onTap: () => chooseSvt(id),
                      onLongPress: svt?.routeTo,
                      child: db.getIconImage(svt?.borderedIcon ?? Atlas.common.emptySvtIcon),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      data.markedCharaSvtIds.remove(id);
                      data.nonSvtImageIds.remove(id);
                      setState(() {});
                    },
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(context).hintColor,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1),
          ],
        );
      },
    );
  }

  Widget buildRepo() {
    return ListView.builder(
      itemCount: data.repoData.length,
      itemBuilder: (context, index) {
        final figures = data.repoData[index];
        final svt = db.gameData.servantsById[figures.svtId];
        return SimpleAccordion(
          headerBuilder: (context, _) {
            return ListTile(
              dense: true,
              leading: svt?.iconBuilder(context: context) ?? Text(figures.svtId.toString()),
              title: Text(svt?.lName.l ?? figures.svtId.toString()),
              subtitle: Text('No.${svt?.collectionNo}  ${figures.svtId}'),
              trailing: Text(figures.imageIds.length.toString()),
            );
          },
          contentBuilder: (context) {
            return SizedBox(
              height: 300,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final id in figures.imageIds)
                    CachedImage(
                      imageUrl: data.toUrl(id),
                      viewFullOnTap: true,
                    )
                ],
              ),
            );
          },
        );
      },
    );
  }

  final svtFilterData = SvtFilterData(useGrid: true);

  Future<void> chooseSvt(T figureId) {
    return router.pushPage(ServantListPage(
      filterData: svtFilterData,
      showSecondaryFilter: true,
      onSelected: (svt) {
        data.markedCharaSvtIds[figureId] = svt.id;
        data.nonSvtImageIds.remove(figureId);
        if (mounted) setState(() {});
      },
    ));
  }

  Future<void> exportData() async {
    // EasyLoading.show();
    EasyLoading.dismiss();
    if (data.repoData.isEmpty) {
      EasyLoading.showError('repo data didn\'t load, manual merge required.');
      await Future.delayed(const Duration(seconds: 4));
    }
    Map<int, ExtraCharaImageBase<T>> destData = {
      for (final v in data.repoData) v.svtId: v,
    };
    for (final imageId in data.allImageIds) {
      final svtId = data.markedCharaSvtIds[imageId];
      if (svtId != null) {
        destData.putIfAbsent(svtId, () => data.constructor(svtId)).imageIds.add(imageId);
      }
    }
    for (final v in destData.values) {
      final imageIds = v.imageIds.toSet().toList();
      imageIds.sort();
      v.imageIds
        ..clear()
        ..addAll(imageIds);
    }
    final values = destData.values.toList();
    values.sort2((e) => e.svtId);
    String output = const JsonEncoder.withIndent('  ').convert(values);
    output += '\n';
    await copyToClipboard(output, toast: true);
  }
}
