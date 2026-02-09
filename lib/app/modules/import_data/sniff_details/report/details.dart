import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/app/modules/servant/filter.dart';
import 'package:chaldea/app/modules/summon/gacha/gacha_banner.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/gamedata/mst_data.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/utils/constants.dart';
import 'package:chaldea/utils/extension.dart';
import 'package:chaldea/utils/url.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'report_data.dart';

class UserGachaListPage extends StatelessWidget {
  final FgoAnnualReportData report;
  final List<UserGachaEntity> userGachas;
  final String? title;

  const UserGachaListPage({super.key, required this.report, required this.userGachas, this.title});

  @override
  Widget build(BuildContext context) {
    Map<int, List<MstGacha>> imageIdMap = {};
    for (final gacha in report.mstGachas.values) {
      imageIdMap.putIfAbsent(gacha.imageId, () => []).add(gacha);
    }
    return Scaffold(
      appBar: AppBar(title: Text(title ?? S.current.gacha)),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final userGacha = userGachas[index];
          return UserGachaAccordion(
            userGacha: userGacha,
            gacha: report.mstGachas[userGacha.gachaId],
            region: report.region,
            imageIdMap: imageIdMap,
          );
        },
        itemCount: userGachas.length,
      ),
    );
  }
}

class UserGachaAccordion extends StatelessWidget {
  final UserGachaEntity userGacha;
  final MstGacha? gacha;
  final Region region;
  final Map<int, List<MstGacha>> imageIdMap; // <imageId, gachaIds>

  const UserGachaAccordion({
    super.key,
    required this.userGacha,
    required this.gacha,
    required this.region,
    this.imageIdMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    final url = getHtmlUrl(userGacha.gachaId);
    final gacha = this.gacha;
    String title = gacha?.name ?? userGacha.gachaId.toString();
    if (gacha == null && region == Region.cn && userGacha.gachaId < 1000000 && userGacha.gachaId > 10000) {
      title += ' 剧情池？';
    }
    String subtitle = '${userGacha.gachaId}   ';
    if (gacha != null) {
      subtitle += [gacha.openedAt, gacha.closedAt].map((e) => e.sec2date().toDateString()).join(' ~ ');
    }
    if (userGacha.createdAt != null) {
      subtitle += '\n(${userGacha.createdAt!.sec2date().toDateString()})';
    }

    return SimpleAccordion(
      headerBuilder: (context, _) {
        return ListTile(
          dense: true,
          title: Text.rich(
            TextSpan(
              children: [
                if (gacha?.gachaType == GachaType.chargeStone)
                  const TextSpan(
                    text: '$kStarChar2 ',
                    style: TextStyle(color: Colors.red),
                  ),
                TextSpan(text: title),
              ],
            ),
            style: TextStyle(fontStyle: gacha?.userAdded == true ? FontStyle.italic : null),
          ),
          subtitle: Text(subtitle),
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
          trailing: Text(
            userGacha.num.toString(),
            style: TextStyle(fontStyle: shouldIgnore(userGacha) ? FontStyle.italic : null),
          ),
        );
      },
      contentBuilder: (context) {
        final _gacha = gacha;
        if (_gacha == null) return const Center(child: Text('\n....\n\n'));
        List<Widget> children = [];
        if (_gacha.imageId > 0) {
          children.add(GachaBanner(imageId: _gacha.imageId, region: region));
        }
        if (gacha?.userAdded == true) {
          children.add(const Text('这是由用户标记的卡池，若存在错误请反馈。', textAlign: TextAlign.center));
        }
        final dupGachas = List<MstGacha>.of(imageIdMap[_gacha.imageId] ?? []);
        dupGachas.remove(_gacha);
        if (dupGachas.isNotEmpty) {
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text.rich(
                TextSpan(
                  text: '${S.current.gacha_image_overridden_hint}:\n',
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    for (final v in dupGachas)
                      TextSpan(
                        children: [
                          TextSpan(
                            text: ' ${v.name} ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: v.openedAt.sec2date().toDateString()),
                        ],
                      ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        if ((region == Region.jp || region == Region.na) && url != null) {
          children.add(
            IconButton(onPressed: () => launch(url, external: false), icon: const Icon(Icons.open_in_browser)),
          );
        }
        return Column(mainAxisSize: MainAxisSize.min, children: children);
      },
    );
  }

  String? getHtmlUrl(int gachaId) {
    // final page = gacha?.detailUrl;
    // if (page == null || page.trim().isEmpty) return null;
    if (const [1, 101].contains(gachaId)) return null;
    final gacha = this.gacha;
    switch (region) {
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

  bool shouldIgnore(UserGachaEntity record) {
    // 1/2/3-fp, 101-newbie
    if (gacha?.gachaType == GachaType.freeGacha) return true;
    return record.gachaId < 100;
  }
}

class UserShopAnonymousListPage extends StatelessWidget {
  final List<UserShopEntity> shops;
  const UserShopAnonymousListPage({super.key, required this.shops});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Transl.enums(ShopType.svtAnonymous, (e) => e.shopType).l)),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final shop = shops[index];
          return ListTile(
            dense: true,
            title: Text('${S.current.shop} ${shop.shopId}'),
            trailing: Text('×${shop.num}'),
            onTap: () => router.push(url: Routes.shopI(shop.shopId)),
          );
        },
        itemCount: shops.length,
      ),
    );
  }
}

class UserSvtFiltratedPage extends StatefulWidget {
  final Widget? title;
  final List<UserServantEntity> userSvts;
  final String Function(UserServantEntity userSvt)? getUserSvtStatus;
  final List<UserServantCollectionEntity> userSvtCollections;
  final String Function(UserServantCollectionEntity collection)? getCollectionStatus;

  const UserSvtFiltratedPage.userSvt({super.key, this.title, this.userSvts = const [], this.getUserSvtStatus})
    : userSvtCollections = const [],
      getCollectionStatus = null;

  const UserSvtFiltratedPage.collection({
    super.key,
    this.title,
    this.userSvtCollections = const [],
    this.getCollectionStatus,
  }) : userSvts = const [],
       getUserSvtStatus = null;

  @override
  State<UserSvtFiltratedPage> createState() => _UserSvtFiltratedPageState();
}

class _UserSvtFiltratedPageState extends State<UserSvtFiltratedPage> {
  static SvtFilterData filterData = SvtFilterData(sortKeys: SvtCompare.kRarityFirstKeys);

  List<UserServantEntity> getShownUserSvts() {
    bool filter(UserServantEntity userSvt) {
      final svt = db.gameData.servantsById[userSvt.svtId];
      if (svt != null && !ServantFilterPage.filter(filterData, svt)) {
        return false;
      }
      return true;
    }

    int compareUserSvt(UserServantEntity a, UserServantEntity b) {
      return SvtFilterData.compareId(a.svtId, b.svtId, keys: filterData.sortKeys, reversed: filterData.sortReversed);
    }

    final userSvts = widget.userSvts.where(filter).toList();
    userSvts.sort(compareUserSvt);
    return userSvts;
  }

  List<UserServantCollectionEntity> getShownCollections() {
    bool filter(UserServantCollectionEntity userSvt) {
      final svt = db.gameData.servantsById[userSvt.svtId];
      if (svt != null && !ServantFilterPage.filter(filterData, svt)) {
        return false;
      }
      return true;
    }

    int compareUserSvt(UserServantCollectionEntity a, UserServantCollectionEntity b) {
      return SvtFilterData.compareId(a.svtId, b.svtId, keys: filterData.sortKeys, reversed: filterData.sortReversed);
    }

    final collections = widget.userSvtCollections.where(filter).toList();
    collections.sort(compareUserSvt);
    return collections;
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (widget.userSvts.isNotEmpty) {
      body = buildGrid(getShownUserSvts(), buildUserSvt);
    } else {
      body = buildGrid(getShownCollections(), buildCollection);
    }
    return Scaffold(
      appBar: AppBar(
        title: widget.title ?? Text(S.current.servant),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => ServantFilterPage(
                filterData: filterData,
                onChanged: (_) {
                  if (mounted) {
                    setState(() {});
                  }
                },
                showPlans: false,
                planMode: false,
              ),
            ),
          ),
        ],
      ),
      body: body,
    );
  }

  Widget buildGrid<T>(List<T> entities, Widget Function(T entity) builder) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 64,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        childAspectRatio: 132 / 144,
      ),
      itemBuilder: (context, index) => builder(entities[index]),
      itemCount: entities.length,
    );
  }

  Widget buildUserSvt(UserServantEntity userSvt) {
    final svt = db.gameData.servantsById[userSvt.svtId];
    final status = widget.getUserSvtStatus?.call(userSvt);
    Widget child;
    if (svt == null) {
      child = Text(['${userSvt.svtId}', ?status].join('\n'));
    } else {
      child = svt.iconBuilder(
        context: context,
        text: status,
        option: ImageWithTextOption(padding: EdgeInsets.fromLTRB(4, 0, 4, 2), fontSize: 12),
      );
    }
    return child;
  }

  Widget buildCollection(UserServantCollectionEntity collection) {
    final svt = db.gameData.servantsById[collection.svtId];
    final status = widget.getCollectionStatus?.call(collection);
    Widget child;
    if (svt == null) {
      child = Text(['${collection.svtId}', ?status].join('\n'));
    } else {
      child = svt.iconBuilder(
        context: context,
        text: status,
        option: ImageWithTextOption(padding: EdgeInsets.fromLTRB(4, 0, 4, 2), fontSize: 12),
      );
    }
    return child;
  }
}
