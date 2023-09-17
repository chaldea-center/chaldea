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

class CharaFigureMarker extends StatefulWidget {
  const CharaFigureMarker({super.key});

  @override
  State<CharaFigureMarker> createState() => _CharaFigureMarkerState();
}

class _CharaFigureMarkerState extends State<CharaFigureMarker> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 5, vsync: this);
  final manager = AtlasExplorerManager();

  List<int> allCharaIds = [];
  List<ExtraCharaFigure> repoData = [];

  @override
  void initState() {
    super.initState();
    manager.setAuth(null);
    loadCharas(false);
  }

  Future<void> loadCharas(bool refresh) async {
    final htmlText = await manager.navigateTo('/aa-fgo-public/JP/CharaFigure/', refresh: refresh);
    if (htmlText == null) {
      return;
    }
    final charaIds = RegExp(r'/CharaFigure/(\d+)/').allMatches(htmlText).map((e) => int.parse(e.group(1)!)).toSet();
    final existingCharas = <int>{for (final svt in db.gameData.servantsById.values) ..._listFigures(svt.extraAssets)};
    charaIds.removeAll(existingCharas);

    final repoList = await manager.api.getModel(
      HostsX.proxyWorker(
          'https://github.com/atlasacademy/fgo-game-data-api/raw/master/app/data/mappings/extra_charafigure.json',
          onlyCN: false),
      (data) => (data as List).map((e) => ExtraCharaFigure.fromJson(e)).toList(),
      expireAfter: refresh ? Duration.zero : null,
    );
    if (repoList != null) {
      repoData = repoList;
      charaIds.removeAll(<int>[for (final x in repoList) ...x.charaFigureIds]);
    }

    allCharaIds = charaIds.toList();

    EasyLoading.showToast('${allCharaIds.length} Unknown Figures');
    if (mounted) setState(() {});
  }

  int? parseId(String url) {
    final s = RegExp(r'/CharaFigure/(\d+)/').firstMatch(url)?.group(1);
    if (s != null) return int.parse(s);
    return null;
  }

  Set<int> _listFigures(ExtraAssets extraAssets) {
    final ids = <int?>{
      ...extraAssets.charaFigure.allUrls.map(parseId),
      for (final x in extraAssets.charaFigureMulti.values) ...x.allUrls.map(parseId),
    };
    return ids.whereType<int>().toSet();
  }

  String _charaIdToUrl(int id) => 'https://static.atlasacademy.io/JP/CharaFigure/$id/$id.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CharaFigure Marker'),
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
                  loadCharas(true);
                },
                child: const Text('Refresh List'),
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
    List<int> unknownIds = [], markedIds = [], nonSvtIds = [];
    for (final id in allCharaIds) {
      if (db.settings.misc.markedCharaFigureSvtIds.containsKey(id)) {
        markedIds.add(id);
      } else if (db.settings.misc.nonSvtCharaFigureIds.contains(id)) {
        nonSvtIds.add(id);
      } else {
        unknownIds.add(id);
      }
    }
    print('${unknownIds.length} unknownIds, ${nonSvtIds.length} nonSvtIds');
    return TabBarView(
      controller: _tabController,
      children: [
        buildGrid(allCharaIds.toList()),
        buildGrid(unknownIds),
        buildGrid(markedIds),
        buildGrid(nonSvtIds),
        buildRepo(),
      ],
    );
  }

  Widget buildGrid(List<int> ids) {
    ids.sort();
    return GridView.builder(
      itemCount: ids.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 120,
        mainAxisSpacing: 8,
        //  crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: 1024 / 1500,
      ),
      itemBuilder: (context, index) {
        final id = ids[index];
        final svt = db.gameData.servantsById[db.settings.misc.markedCharaFigureSvtIds[id]];
        BasicServant? entity = db.gameData.entities[id] ?? db.gameData.entities[id ~/ 10 * 10];
        return Column(
          children: [
            Expanded(
              flex: 2,
              child: CachedImage(
                imageUrl: _charaIdToUrl(id),
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
                      db.settings.misc.markedCharaFigureSvtIds.remove(id);
                      db.settings.misc.nonSvtCharaFigureIds.add(id);
                      setState(() {});
                    },
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.no_accounts,
                      color: Theme.of(context).hintColor,
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
                      db.settings.misc.markedCharaFigureSvtIds.remove(id);
                      db.settings.misc.nonSvtCharaFigureIds.remove(id);
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
      itemCount: repoData.length,
      itemBuilder: (context, index) {
        final figures = repoData[index];
        final svt = db.gameData.servantsById[figures.svtId];
        return SimpleAccordion(
          headerBuilder: (context, _) {
            return ListTile(
              dense: true,
              leading: svt?.iconBuilder(context: context) ?? Text(figures.svtId.toString()),
              title: Text(svt?.lName.l ?? figures.svtId.toString()),
              subtitle: Text('No.${svt?.collectionNo}  ${figures.svtId}'),
              trailing: Text(figures.charaFigureIds.length.toString()),
            );
          },
          contentBuilder: (context) {
            return SizedBox(
              height: 300,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final id in figures.charaFigureIds)
                    CachedImage(
                      imageUrl: _charaIdToUrl(id),
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

  Future<void> chooseSvt(int figureId) {
    return router.pushPage(ServantListPage(
      filterData: svtFilterData,
      showSecondaryFilter: true,
      onSelected: (svt) {
        db.settings.misc.markedCharaFigureSvtIds[figureId] = svt.id;
        db.settings.misc.nonSvtCharaFigureIds.remove(figureId);
        if (mounted) setState(() {});
      },
    ));
  }

  Future<void> exportData() async {
    EasyLoading.show();
    EasyLoading.dismiss();
    if (repoData.isEmpty) {
      EasyLoading.showError('repo data didn\'t load, manual merge required.');
      await Future.delayed(const Duration(seconds: 4));
    }
    Map<int, ExtraCharaFigure> destData = {
      for (final v in repoData) v.svtId: v,
    };
    for (final figureId in allCharaIds) {
      final svtId = db.settings.misc.markedCharaFigureSvtIds[figureId];
      if (svtId != null) {
        destData.putIfAbsent(svtId, () => ExtraCharaFigure(svtId: svtId)).charaFigureIds.add(figureId);
      }
    }
    for (final v in destData.values) {
      v.charaFigureIds = v.charaFigureIds.toSet().toList();
      v.charaFigureIds.sort();
    }
    destData = sortDict(destData);
    String output = const JsonEncoder.withIndent('  ').convert(destData.values.toList());
    output += '\n';
    await copyToClipboard(output, toast: true);
  }
}
