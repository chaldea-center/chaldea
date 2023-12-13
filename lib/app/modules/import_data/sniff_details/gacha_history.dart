import 'package:flutter/cupertino.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/builders.dart';
import 'package:chaldea/app/modules/common/filter_group.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/raw.dart';
import 'package:chaldea/models/gamedata/toplogin.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../summon/gacha/gacha_banner.dart';

class SniffGachaHistory extends StatefulWidget {
  final List<UserSvt> userSvt;
  final List<UserSvt> userSvtStorage;
  final List<UserSvtCollection> userSvtCollection;
  final List<UserGacha> records;
  final List<UserShop> userShops;
  final List<UserItem> userItems;
  final Region region;

  const SniffGachaHistory({
    super.key,
    required this.records,
    required this.userSvt,
    required this.userSvtStorage,
    required this.userSvtCollection,
    required this.region,
    required this.userShops,
    required this.userItems,
  });

  @override
  State<SniffGachaHistory> createState() => _SniffGachaHistoryState();
}

class _SniffGachaHistoryState extends State<SniffGachaHistory> {
  late List<UserGacha> records = widget.records.toList();
  final loading = ValueNotifier<bool>(false);
  final gachaType = FilterGroupData<GachaType>();

  Map<int, MstGacha> gachas = {};
  Map<int, MstGacha> cnGachas = {};
  final Map<int, List<MstGacha>> _imageIdMap = {};

  @override
  void initState() {
    super.initState();
    loadMstData();
  }

  Future<List<MstGacha>?> _fetchMst(Region region) async {
    String url =
        "https://git.atlasacademy.io/atlasacademy/fgo-game-data/raw/branch/${region.upper}/master/mstGacha.json";
    if (db.settings.proxy.worker) url = HostsX.proxyWorker(url);
    AtlasApi.cacheManager.clearFailed();
    final mstData = await AtlasApi.cacheManager.getModel<List<MstGacha>>(
      url,
      (data) => (data as List).map((e) => MstGacha.fromJson(Map.from(e))).toList(),
    );
    if (mstData == null && mounted) {
      SimpleCancelOkDialog(
        title: Text(S.current.error),
        content: const Text('Download Gacha Data failed, click Refresh to retry'),
        hideCancel: true,
      ).showDialog(context);
    }
    if (region == Region.cn) {
      final extra = await AtlasApi.cacheManager.getModel<List<MstGacha>>(
        "${HostsX.dataHost}/mstGachaCNExtra.json",
        (data) => (data as List).map((e) => MstGacha.fromJson(Map.from(e))).toList(),
      );
      if (extra != null) {
        mstData?.addAll(extra.map((e) => e..userAdded = true));
      }
    }
    return mstData;
  }

  Future<void> loadMstData() async {
    loading.value = true;
    _imageIdMap.clear();
    cnGachas.clear();
    final data = await _fetchMst(widget.region);
    if (data != null) {
      gachas = {
        for (final v in data) v.id: v,
      };
      if (widget.region == Region.tw) {
        // TW doesn't contain closed banners
        final dataCN = await _fetchMst(Region.cn);
        if (dataCN != null) {
          cnGachas = {
            for (final v in dataCN) v.id: v,
          };
        }
      }
      if (widget.region == Region.tw) {
        records.sort2((e) => e.gachaId <= 100 ? -1000000000000 + e.gachaId : -(e.createdAt ?? e.gachaId));
      } else {
        records.sort2((e) =>
            e.gachaId <= 100 ? -1000000000000 + e.gachaId : -(gachas[e.gachaId]?.openedAt ?? e.createdAt ?? e.gachaId));
      }
    }
    for (final gacha in [...gachas.values, ...cnGachas.values]) {
      if (gacha.imageId == 0) continue;
      _imageIdMap.putIfAbsent(gacha.imageId, () => []).add(gacha);
    }

    // records = records.reversed.toList();
    loading.value = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final shownRecords = records.where((record) {
      if (!gachaType.matchOne(gachas[record.gachaId]?.gachaType ?? GachaType.unknown)) {
        return false;
      }
      return true;
    }).toList();

    final totalSummonCount = Maths.sum(records.where((e) => !shouldIgnore(e)).map((e) => e.num));
    final allUserSvts = [...widget.userSvt, ...widget.userSvtStorage];

    final curAnonymous = widget.userItems.firstWhereOrNull((e) => e.itemId == Items.svtAnonymousId)?.num ?? 0;
    final anonymousShops = widget.userShops.where((e) => e.shopId ~/ 1000000 == 4).toList();
    final anonymousBuyCount = Maths.sum(anonymousShops.map((e) => e.num));

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.gacha),
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
          IconButton(
            onPressed: gachas.isEmpty ? loadMstData : null,
            icon: const Icon(Icons.refresh),
            tooltip: S.current.refresh,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverList.list(children: [
            TileGroup(
              header: S.current.statistics_title,
              footerWidget: SFooter.rich(TextSpan(text: S.current.gacha_svt_count_hint, children: [
                const TextSpan(text: '\n'),
                SharedBuilder.textButtonSpan(
                  context: context,
                  text: 'document',
                  onTap: () {
                    launch(ChaldeaUrl.doc('import_https/gacha_stat'));
                  },
                )
              ])),
              children: [
                ListTile(
                  dense: true,
                  title: Text(S.current.total),
                  trailing: Text('$totalSummonCount ${S.current.summon_pull_unit}'),
                ),
                ...<int>[5, 4].map((rarity) {
                  final countsOwned = countServantTDOwned(allUserSvts, rarity);
                  final countOwned = Maths.sum(countsOwned.values);
                  final countsAll = countServantTDAll(widget.userSvtCollection, rarity);
                  final countAll = Maths.sum(countsAll.values);

                  return ListTile(
                    dense: true,
                    title: Text('$kStarChar $rarity ${S.current.servant}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(text: '${S.current.item_own} $countOwned\n', children: [
                            TextSpan(
                              text: '${(countOwned / totalSummonCount * 100).toStringAsFixed(2)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ]),
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(width: 8),
                        Text.rich(
                          TextSpan(text: '${S.current.obtain} $countAll\n', children: [
                            TextSpan(
                              text: '${(countAll / totalSummonCount * 100).toStringAsFixed(2)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ]),
                          textAlign: TextAlign.end,
                        ),
                        Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                      ],
                    ),
                    onTap: () {
                      router.pushPage(_SvtTotalNumList(rarity: rarity, countsOwned: countsOwned, countsAll: countsAll));
                    },
                  );
                }),
              ],
            ),
            TileGroup(
              children: [
                ListTile(
                  dense: true,
                  title: Text(S.current.lucky_bag),
                  trailing: Text(getLuckyBagCount()),
                ),
                ListTile(
                  dense: true,
                  enabled: anonymousShops.isNotEmpty,
                  title: Text(Transl.itemNames('無記名霊基').l),
                  trailing: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('$curAnonymous+10×$anonymousBuyCount'),
                      Icon(DirectionalIcons.keyboard_arrow_forward(context)),
                    ],
                  ),
                  onTap: anonymousShops.isEmpty
                      ? null
                      : () {
                          router.pushPage(_UserShopList(userShops: anonymousShops, region: widget.region));
                        },
                )
              ],
            ),
            const Divider(height: 2, thickness: 1),
            const SizedBox(height: 8),
            Center(
              child: FilterGroup<GachaType>(
                combined: true,
                options: const [GachaType.payGacha, GachaType.chargeStone, GachaType.unknown],
                values: gachaType,
                optionBuilder: (v) => Text(v.shownName),
                onFilterChanged: (v, _) {
                  setState(() {});
                },
              ),
            ),
          ]),
          SliverList.separated(
            itemBuilder: (context, index) => buildGacha(context, index, shownRecords[index]),
            separatorBuilder: (context, index) => const SizedBox.shrink(),
            itemCount: shownRecords.length,
          ),
        ],
      ),
    );
  }

  Widget buildGacha(BuildContext context, int index, UserGacha record) {
    final gacha = gachas[record.gachaId];
    final cnGacha = cnGachas[record.gachaId];
    final url = getHtmlUrl(record.gachaId);
    String title = gacha?.name ?? record.gachaId.toString();
    if (gacha == null && widget.region == Region.cn && record.gachaId < 1000000 && record.gachaId > 10000) {
      title += ' 剧情池？';
    }
    String subtitle = '${record.gachaId}   ';
    if (gacha != null) {
      subtitle += [gacha.openedAt, gacha.closedAt].map((e) => e.sec2date().toDateString()).join(' ~ ');
    }
    if (record.createdAt != null) {
      subtitle += '\n(${record.createdAt!.sec2date().toDateString()})';
    }

    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          dense: true,
          selected: (_imageIdMap[gacha?.imageId]?.length ?? 0) > 1,
          title: Text.rich(
            TextSpan(children: [
              if (gachas[record.gachaId]?.gachaType == GachaType.chargeStone)
                const TextSpan(text: '$kStarChar2 ', style: TextStyle(color: Colors.red)),
              TextSpan(text: title),
            ]),
            style: TextStyle(fontStyle: gacha?.userAdded == true ? FontStyle.italic : null),
          ),
          subtitle: Text(subtitle),
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          trailing: Text(
            record.num.toString(),
            style: TextStyle(fontStyle: shouldIgnore(record) ? FontStyle.italic : null),
          ),
        );
      },
      contentBuilder: (context) {
        final _gacha = gacha ?? cnGacha;
        if (_gacha == null) return const Center(child: Text('\n....\n\n'));
        List<Widget> children = [];
        if (_gacha.imageId > 0) {
          children.add(GachaBanner(imageId: _gacha.imageId, region: widget.region));
        }
        if (gacha?.userAdded == true) {
          children.add(const Text('这是由用户标记的卡池，若存在错误请反馈。', textAlign: TextAlign.center));
        }
        final dupGachas = List<MstGacha>.of(_imageIdMap[_gacha.imageId] ?? []);
        dupGachas.remove(_gacha);
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
        if ((widget.region == Region.jp || widget.region == Region.na) && url != null) {
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

  String? getHtmlUrl(int gachaId) {
    // final page = gacha?.detailUrl;
    // if (page == null || page.trim().isEmpty) return null;
    if (const [1, 101].contains(gachaId)) return null;
    final gacha = gachas[gachaId];
    switch (widget.region) {
      case Region.jp:
        // return 'https://webview.fate-go.jp/webview$page';
        if (gacha != null && gacha.openedAt < 1640790000) {
          // ID50017991 2021-12-29 23:00+08
          return null;
        }
        return "https://static.atlasacademy.io/file/aa-fgo/GameData-uTvNN4iBTNInrYDa/JP/Banners/$gachaId/index.html";
      case Region.na:
        if (gacha != null && gacha.openedAt < 1641268800) {
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

  bool shouldIgnore(UserGacha record) {
    // 1-fp, 101-newbie
    return record.gachaId == 1;
  }

  Map<int, int> countServantTDOwned(List<UserSvt> servants, int rarity) {
    assert(rarity == 4 || rarity == 5);
    Map<int, int> counts = {};
    for (final userSvt in servants) {
      final svt = userSvt.dbSvt;
      if (svt == null || !svt.isUserSvt || svt.rarity != rarity) continue;
      if (rarity == 4) {
        if (svt.type == SvtType.heroine ||
            const [SvtObtain.eventReward, SvtObtain.friendPoint, SvtObtain.clearReward, SvtObtain.unavailable]
                .any((e) => svt.extra.obtains.contains(e))) {
          continue;
        }
      }
      counts.addNum(userSvt.svtId, userSvt.treasureDeviceLv1);
    }
    return counts;
  }

  Map<int, int> countServantTDAll(List<UserSvtCollection> servants, int rarity) {
    Map<int, int> counts = {};
    for (final userSvt in servants) {
      final svt = db.gameData.servantsById[userSvt.svtId];
      if (!userSvt.isOwned) continue;
      if (svt == null || !svt.isUserSvt || svt.rarity != rarity) continue;
      if (rarity == 4) {
        if (svt.type == SvtType.heroine ||
            const [SvtObtain.eventReward, SvtObtain.friendPoint, SvtObtain.clearReward, SvtObtain.unavailable]
                .any((e) => svt.extra.obtains.contains(e))) {
          continue;
        }
      }
      counts[userSvt.svtId] = userSvt.totalGetNum;
    }
    return counts;
  }

  String getLuckyBagCount() {
    bool hasUnknown = false;
    int count = 0;
    for (final record in records) {
      final gacha = gachas[record.gachaId];
      if (gacha == null) {
        hasUnknown = true;
      } else if (gacha.gachaType == GachaType.chargeStone) {
        count += 1;
      }
    }
    return hasUnknown ? '≥$count' : '=$count';
  }
}

class _UserShopList extends StatelessWidget {
  final List<UserShop> userShops;
  final Region region;
  const _UserShopList({required this.userShops, required this.region});

  @override
  Widget build(BuildContext context) {
    final userShops = this.userShops.toList()..sort2((e) => -e.updatedAt);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.shop),
      ),
      body: ListView.builder(
        itemCount: userShops.length,
        itemBuilder: (context, index) {
          final userShop = userShops[index];
          final time = userShop.updatedAt > 0 ? userShop.updatedAt : userShop.createdAt;
          return ListTile(
            title: Text('No.${userShop.shopId}  ×${userShop.num}'),
            subtitle: Text(time > 0 ? time.sec2date().toStringShort() : 'Unknown Time'),
            trailing: Icon(DirectionalIcons.keyboard_arrow_forward(context)),
            onTap: () {
              router.push(url: Routes.shopI(userShop.shopId), region: region);
            },
          );
        },
      ),
    );
  }
}

class _SvtTotalNumList extends StatefulWidget {
  final int rarity;
  final Map<int, int> countsOwned;
  final Map<int, int> countsAll;

  const _SvtTotalNumList({
    required this.rarity,
    required this.countsOwned,
    required this.countsAll,
  });

  @override
  State<_SvtTotalNumList> createState() => _SvtTotalNumListState();
}

class _SvtTotalNumListState extends State<_SvtTotalNumList> {
  bool diffOnly = false;
  @override
  Widget build(BuildContext context) {
    final svtIds = {...widget.countsOwned.keys, ...widget.countsAll.keys}.toList();
    svtIds.sort((a, b) {
      return SvtFilterData.compare(db.gameData.servantsById[a], db.gameData.servantsById[b],
          keys: [SvtCompare.className, SvtCompare.no], reversed: [false, false]);
    });
    List<Widget> children = [];
    for (final svtId in svtIds) {
      final owned = widget.countsOwned[svtId] ?? 0;
      final all = widget.countsAll[svtId] ?? 0;
      final equal = owned == all;
      if (diffOnly && equal) continue;

      Widget child = GameCardMixin.anyCardItemBuilder(
        context: context,
        id: svtId,
        text: '$owned\n$all',
        option: ImageWithTextOption(
          padding: const EdgeInsets.only(right: 6, bottom: 6),
          shadowColor: equal ? null : Colors.white,
          textStyle: equal ? null : const TextStyle(color: Colors.red),
        ),
        padding: const EdgeInsets.all(1.5),
      );
      if (!equal) {
        child = Container(color: Colors.red, child: child);
      }
      child = Padding(padding: const EdgeInsets.all(1.5), child: child);
      children.add(child);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('$kStarChar2${widget.rarity} ${S.current.statistics_title}'),
        actions: [
          Center(
            child: Text(
              [S.current.item_own, S.current.obtain].join('\n'),
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                diffOnly = !diffOnly;
              });
            },
            icon: const Icon(Icons.difference),
            tooltip: 'Difference Only',
          ),
        ],
      ),
      body: GridView.extent(
        maxCrossAxisExtent: 56,
        childAspectRatio: 132 / 144,
        children: children,
      ),
    );
  }
}
