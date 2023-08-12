import 'package:cached_network_image/cached_network_image.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';

class GachaListPage extends StatefulWidget {
  final Region region;
  const GachaListPage({super.key, this.region = Region.jp});

  @override
  State<GachaListPage> createState() => _GachaListPageState();
}

class _GachaListPageState extends State<GachaListPage> with RegionBasedState<List<MstGacha>, GachaListPage> {
  List<MstGacha> get gachas => data ?? [];
  final Map<int, List<MstGacha>> _imageIdMap = {};

  // filters
  final type = FilterGroupData<GachaType>();

  @override
  void initState() {
    super.initState();
    region = widget.region;
    doFetchData();
  }

  @override
  Future<List<MstGacha>?> fetchData(Region? r) async {
    r ??= Region.jp;
    _imageIdMap.clear();
    AtlasApi.cacheManager.clearFailed();
    final results = await AtlasApi.mstData(
      'mstGacha',
      (json) => (json as List).map((e) => MstGacha.fromJson(Map.from(e))).toList(),
      region: r,
    );
    for (final gacha in gachas) {
      _imageIdMap.putIfAbsent(gacha.imageId, () => []).add(gacha);
    }

    return results;
  }

  bool filter(MstGacha gacha) {
    if (region == Region.cn) {
      if (gacha.openedAt == gacha.closedAt && gacha.openedAt == 1911657599) return false;
    }
    final gachaType = gacha.gachaType;
    if (type.isNotEmpty) {
      if (!type.matchOne(gachaType)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gacha List'),
        actions: [dropdownRegion()],
      ),
      body: buildBody(context),
    );
  }

  Widget buildButtonBar() {
    final validTypes = {for (final gacha in gachas) gacha.gachaType}.toList();
    validTypes.sort2((e) => e.index);
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        FilterGroup<GachaType>(
          combined: true,
          options: validTypes,
          values: type,
          optionBuilder: (v) => Text(v.shownName),
          onFilterChanged: (v, _) {
            setState(() {});
          },
        ),
      ],
    );
  }

  @override
  Widget buildContent(BuildContext context, List<MstGacha> gachas) {
    gachas = gachas.where(filter).toList();
    gachas.sort2((e) => e.id == 1 ? double.negativeInfinity : -e.openedAt);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) => buildGacha(context, gachas[index]),
            separatorBuilder: (context, index) => const Divider(height: 8),
            itemCount: gachas.length,
          ),
        ),
        SafeArea(child: buildButtonBar()),
      ],
    );
  }

  Widget buildGacha(BuildContext context, MstGacha gacha) {
    final url = getHtmlUrl(gacha);
    String title = gacha.name;
    String subtitle = '[${gacha.type}]${gacha.id}   ';
    subtitle += [gacha.openedAt, gacha.closedAt].map((e) => e.sec2date().toStringShort(omitSec: true)).join(' ~ ');
    final now = DateTime.now().timestamp;
    final isLuckyBag = gacha.type == GachaType.chargeStone.id;
    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          dense: true,
          // selected: (_imageIdMap[gacha.imageId]?.length ?? 0) > 1,
          selected: gacha.openedAt <= now && now <= gacha.closedAt,
          // horizontalTitleGap: 8,
          // minLeadingWidth: 12,
          // leading: isLuckyBag ? const Icon(Icons.currency_yen, size: 16) : null,
          title: Row(
            children: [
              if (isLuckyBag)
                const Padding(
                  padding: EdgeInsetsDirectional.only(end: 4),
                  child: Icon(Icons.currency_yen, size: 16),
                ),
              Expanded(child: Text(title)),
            ],
          ),
          subtitle: Text(subtitle),
          contentPadding:
              isLuckyBag ? const EdgeInsetsDirectional.only(start: 16) : const EdgeInsetsDirectional.only(start: 16),
        );
      },
      contentBuilder: (context) {
        List<Widget> children = [
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider("https://data-cn.chaldea.center/public/image/summon_bg.jpg"),
                fit: BoxFit.cover,
                alignment: Alignment(0.0, -0.6),
              ),
            ),
            child: CachedImage(
              imageUrl: "https://static.atlasacademy.io/${region!.upper}/SummonBanners/img_summon_${gacha.imageId}.png",
              showSaveOnLongPress: true,
              placeholder: (context, url) => const AspectRatio(aspectRatio: 1344 / 576),
              cachedOption: CachedImageOption(
                fit: BoxFit.contain,
                alignment: Alignment.center,
                errorWidget: (context, url, error) => const AspectRatio(aspectRatio: 1344 / 576),
              ),
            ),
          ),
        ];
        final dupGachas = List<MstGacha>.of(_imageIdMap[gacha.imageId] ?? []);
        dupGachas.remove(gacha);
        if (dupGachas.isNotEmpty) {
          children.add(Padding(
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
          ));
        }
        if ((region == Region.jp || region == Region.na) && url != null) {
          children.add(IconButton(
            onPressed: () => launch(url, external: false),
            icon: const Icon(Icons.open_in_browser),
          ));
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      },
    );
  }

  String? getHtmlUrl(MstGacha gacha) {
    // final page = gacha?.detailUrl;
    // if (page == null || page.trim().isEmpty) return null;
    if (const [1, 101].contains(gacha.id)) return null;
    final gachaId = gacha.id;
    switch (region ?? Region.jp) {
      case Region.jp:
        // return 'https://webview.fate-go.jp/webview$page';
        if (gacha.openedAt < 1640790000) {
          // ID50017991 2021-12-29 23:00+08
          return null;
        }
        return "https://static.atlasacademy.io/file/aa-fgo/GameData-uTvNN4iBTNInrYDa/JP/Banners/$gachaId/index.html";
      case Region.na:
        if (gacha.openedAt < 1641268800) {
          // 50010611: 2022-01-04 12:00+08
          return null;
        }
        return "https://static.atlasacademy.io/file/aa-fgo/GameData-uTvNN4iBTNInrYDa/NA/Banners/$gachaId/index.html";
      case Region.cn:
      case Region.tw:
      case Region.kr:
        return null;
    }
  }
}
