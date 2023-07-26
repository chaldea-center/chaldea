import 'package:flutter/cupertino.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';

class SniffGachaHistory extends StatefulWidget {
  final List<UserGacha> records;
  final Region region;
  const SniffGachaHistory({super.key, required this.records, required this.region});

  @override
  State<SniffGachaHistory> createState() => _SniffGachaHistoryState();
}

class _SniffGachaHistoryState extends State<SniffGachaHistory> {
  late List<UserGacha> records = widget.records.toList();
  final loading = ValueNotifier<bool>(false);

  Map<int, MstGacha> gachas = {};

  @override
  void initState() {
    super.initState();
    loadMstData();
  }

  Future<void> loadMstData() async {
    loading.value = true;
    final data = await AtlasApi.cacheManager.getModel<List<MstGacha>>(
      "https://git.atlasacademy.io/atlasacademy/fgo-game-data/raw/branch/${widget.region.upper}/master/mstGacha.json",
      (data) => (data as List).map((e) => MstGacha.fromJson(e)).toList(),
    );
    if (data != null) {
      gachas = {
        for (final v in data) v.id: v,
      };
      records.sort2((e) => gachas[e.gachaId]?.openedAt ?? e.gachaId, reversed: true);
    }
    // records = records.reversed.toList();
    loading.value = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = Maths.sum(records.where((e) => !shouldIgnore(e)).map((e) => e.num));
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
          Center(child: Text('$totalCount   ')),
        ],
      ),
      body: ListView.separated(
        itemBuilder: (context, index) => buildGacha(context, index, records[index]),
        separatorBuilder: (context, index) => const SizedBox.shrink(),
        itemCount: records.length,
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
        return Container(
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
      },
    );
  }

  String? getUrl(UserGacha record, MstGacha? gacha) {
    // final page = gacha?.detailUrl;
    // if (page == null || page.trim().isEmpty) return null;
    if (const [1, 101].contains(record.gachaId)) return null;
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
    // fp & new user tutorial
    return record.gachaId == 1 || record.gachaId == 101;
  }
}
