import 'package:flutter/cupertino.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SniffGachaHistory extends StatefulWidget {
  final List<UserSvt> userSvt;
  final List<UserSvt> userSvtStorage;
  final List<UserGacha> records;
  final Region region;

  const SniffGachaHistory(
      {super.key, required this.records, required this.userSvt, required this.userSvtStorage, required this.region});

  @override
  State<SniffGachaHistory> createState() => _SniffGachaHistoryState();
}

class _SniffGachaHistoryState extends State<SniffGachaHistory> {
  late List<UserGacha> records = widget.records.toList();
  final loading = ValueNotifier<bool>(false);

  Map<int, MstGacha> gachas = {};
  final Map<int, List<MstGacha>> _imageIdMap = {};

  @override
  void initState() {
    super.initState();
    loadMstData();
  }

  Future<List<MstGacha>?> _fetchMst(Region region) {
    return AtlasApi.cacheManager.getModel<List<MstGacha>>(
      "https://git.atlasacademy.io/atlasacademy/fgo-game-data/raw/branch/${region.upper}/master/mstGacha.json",
      (data) => (data as List).map((e) => MstGacha.fromJson(e)).toList(),
    );
  }

  Future<void> loadMstData() async {
    loading.value = true;
    _imageIdMap.clear();
    final data = await _fetchMst(widget.region);
    if (data != null) {
      gachas = {
        for (final v in data) v.id: v,
      };
      if (widget.region == Region.tw) {
        // TW doesn't contain closed banners
        final dataCN = await _fetchMst(Region.cn);
        if (dataCN != null) {
          for (final v in dataCN) {
            gachas.putIfAbsent(v.id, () => v);
          }
        }
      }
      records.sort2((e) => e.gachaId <= 101 ? -1000000000000 + e.gachaId : -(gachas[e.gachaId]?.openedAt ?? e.gachaId));
    }
    for (final gacha in gachas.values) {
      _imageIdMap.putIfAbsent(gacha.imageId, () => []).add(gacha);
    }

    // records = records.reversed.toList();
    loading.value = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final totalSummonCount = Maths.sum(records.where((e) => !shouldIgnore(e)).map((e) => e.num));
    final tdCount = countServantTD([...widget.userSvt, ...widget.userSvtStorage], 5);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gacha Statistics"),
        actions: [
          ValueListenableBuilder(
            valueListenable: loading,
            builder: (context, v, _) => v
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CupertinoActivityIndicator(radius: 8),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverList.list(children: [
            TileGroup(
              header: S.current.statistics_title,
              children: [
                ListTile(
                  dense: true,
                  title: Text(S.current.total),
                  trailing: Text('$totalSummonCount ${S.current.summon_pull_unit}'),
                ),
                ListTile(
                  dense: true,
                  title: Text('$kStarChar 5 ${S.current.servant}'),
                  subtitle: Text(S.current.gacha_svt_count_hint),
                  trailing: Text(
                    [
                      tdCount,
                      '${(tdCount / totalSummonCount * 100).toStringAsFixed(2)}%',
                    ].join('\n'),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            )
          ]),
          SliverList.separated(
            itemBuilder: (context, index) => buildGacha(context, index, records[index]),
            separatorBuilder: (context, index) => const SizedBox.shrink(),
            itemCount: records.length,
          ),
        ],
      ),
    );
  }

  Widget buildGacha(BuildContext context, int index, UserGacha record) {
    final gacha = gachas[record.gachaId];
    // final url = getUrl(record, gacha);
    String title = gacha?.name ?? record.gachaId.toString();
    String subtitle = '${record.gachaId}   ';
    if (gacha != null) {
      subtitle += [gacha.openedAt, gacha.closedAt].map((e) => e.sec2date().toDateString()).join(' ~ ');
    }

    // https://static.atlasacademy.io/file/aa-fgo-extract-jp/SummonBanners/DownloadSummonBanner/DownloadSummonBannerAtlas1/img_summon_81278.png
    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          dense: true,
          // selected: (_imageIdMap[gacha?.imageId]?.length ?? 0) > 1,
          title: Text(title),
          subtitle: Text(subtitle),
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                record.num.toString(),
                style: TextStyle(fontStyle: shouldIgnore(record) ? FontStyle.italic : null),
              ),
              // IconButton(
              //   onPressed: url == null ? null : () => launch(url, external: false),
              //   icon: const Icon(Icons.link),
              // )
            ],
          ),
        );
      },
      contentBuilder: (context) {
        if (gacha == null) return const Center(child: Text('\n....\n\n'));
        Widget child = Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider("https://data-cn.chaldea.center/public/image/summon_bg.jpg"),
              fit: BoxFit.cover,
              alignment: Alignment(0.0, -0.6),
            ),
          ),
          child: CachedImage(
            imageUrl:
                "https://static.atlasacademy.io/${widget.region.upper}/SummonBanners/img_summon_${gacha.imageId}.png",
            showSaveOnLongPress: true,
            placeholder: (context, url) => const AspectRatio(aspectRatio: 1344 / 576),
            cachedOption: CachedImageOption(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              errorWidget: (context, url, error) => const AspectRatio(aspectRatio: 1344 / 576),
            ),
          ),
        );
        final dupGachas = List<MstGacha>.of(_imageIdMap[gacha.imageId] ?? []);
        dupGachas.remove(gacha);
        if (dupGachas.isNotEmpty) {
          child = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text.rich(
                  TextSpan(
                    text: '${S.current.gacha_image_overridden_hint}:\n',
                    style: Theme.of(context).textTheme.bodySmall,
                    children: [
                      for (final v in dupGachas)
                        TextSpan(children: [
                          TextSpan(
                            text: ' ${v.name} ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: v.openedAt.sec2date().toDateString()),
                        ])
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          );
        }
        return child;
      },
    );
  }

  String? getHtmlUrl(UserGacha record, MstGacha? gacha) {
    // final page = gacha?.detailUrl;
    // if (page == null || page.trim().isEmpty) return null;
    if (const [1].contains(record.gachaId)) return null;
    switch (widget.region) {
      case Region.jp:
        // return 'https://webview.fate-go.jp/webview$page';
        return "https://static.atlasacademy.io/file/aa-fgo/GameData-uTvNN4iBTNInrYDa/JP/Banners/${record.gachaId}/index.html";
      case Region.na:
        return "https://static.atlasacademy.io/file/aa-fgo/GameData-uTvNN4iBTNInrYDa/NA/Banners/${record.gachaId}/index.html";
      case Region.cn:
      case Region.tw:
      case Region.kr:
        return null;
    }
  }

  bool shouldIgnore(UserGacha record) {
    // 1-fp, 101-newbie
    return record.gachaId == 1;
  }

  int countServantTD(List<UserSvt> servants, int rarity) {
    int count = 0;
    for (final svt in servants) {
      final dbSvt = svt.dbSvt;
      if (dbSvt != null && dbSvt.isUserSvt && dbSvt.rarity == rarity) {
        count += svt.treasureDeviceLv1;
      }
    }
    return count;
  }
}
