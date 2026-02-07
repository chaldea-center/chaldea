import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/api/atlas.dart';
import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/tools/gamedata_loader.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/region_based.dart';
import 'package:chaldea/widgets/widgets.dart';
import '../../common/filter_page_base.dart';
import '../../mc/mc_multi_gacha.dart';
import '../filter_page.dart';
import 'gacha_banner.dart';

class GachaListPage extends StatefulWidget {
  final Region region;
  const GachaListPage({super.key, this.region = Region.jp});

  @override
  State<GachaListPage> createState() => _GachaListPageState();
}

class _GachaListPageState extends State<GachaListPage>
    with RegionBasedState<List<NiceGacha>, GachaListPage>, SearchableListState<NiceGacha, GachaListPage> {
  @override
  Iterable<NiceGacha> get wholeData => data ?? [];
  // List<NiceGacha> get gachas => data ?? [];
  final Map<int, List<NiceGacha>> _imageIdMap = {};
  final Set<NiceGacha> _selectedGachas = {};
  bool get shouldShowMultiChoice => region == Region.jp;

  SummonFilterData get filterData => db.settings.filters.gachaFilterData;

  @override
  void initState() {
    super.initState();
    region = widget.region;
    doFetchData();
    if (db.settings.autoResetFilter) {
      filterData.reset();
    }
  }

  @override
  Future<List<NiceGacha>?> fetchData(Region? r, {Duration? expireAfter}) async {
    r ??= Region.jp;
    _imageIdMap.clear();
    AtlasApi.cacheManager.clearFailed();
    List<NiceGacha>? results;
    if (r == Region.jp) {
      results = db.gameData.gachas.values.toList();
    } else {
      results = await AtlasApi.gachas(region: r, expireAfter: expireAfter);
    }
    if (results != null) {
      for (final gacha in results) {
        _imageIdMap.putIfAbsent(gacha.imageId, () => []).add(gacha);
      }
    }
    _selectedGachas.clear();

    return results;
  }

  @override
  bool filter(NiceGacha gacha) {
    if (region == Region.cn) {
      if (gacha.openedAt == gacha.closedAt && gacha.openedAt == 1911657599) return false;
    }
    if (!filterData.gachaType.matchOne(gacha.gachaType)) {
      return false;
    }
    if (!filterData.showOutdated &&
        (gacha.closedAt < DateTime.now().timestamp - kSecsPerDay * 365 * (region?.isJP == true ? 2 : 1))) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        title: AutoSizeText(S.current.raw_gacha_data, maxLines: 1),
        leading: const MasterBackButton(),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: [
          dropdownRegion(),
          IconButton(
            icon: FaIcon(
              filterData.reversed ? FontAwesomeIcons.arrowDownWideShort : FontAwesomeIcons.arrowUpWideShort,
              size: 20,
            ),
            tooltip: S.current.sort_order,
            onPressed: () {
              setState(() {
                filterData.reversed = !filterData.reversed;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: S.current.filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => SummonFilterPage(
                filterData: filterData,
                isRawGacha: true,
                onChanged: (_) {
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
          searchIcon,
        ],
      ),
    );
  }

  @override
  Widget buildScrollable({bool useGrid = false}) {
    return RefreshIndicator(
      child: buildBody(context),
      onRefresh: () async {
        if (region == Region.jp) {
          await GameDataLoader.instance.reloadAndUpdate();
          await doFetchData();
        } else {
          await doFetchData(expireAfter: Duration.zero);
        }
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget buildContent(BuildContext context, List<NiceGacha> gachas) {
    filterShownList();
    if (filterData.sortByClosed) {
      shownList.sortByList((a) => [a.closedAt, a.id]);
    } else {
      shownList.sortByList((a) => [a.openedAt, a.id]);
    }
    if (filterData.reversed) {
      final reversed = List.of(shownList.reversed);
      shownList
        ..clear()
        ..addAll(reversed);
    }
    return super.buildScrollable();
  }

  @override
  Widget listItemBuilder(NiceGacha gacha) {
    final String title = gacha.lName;
    String subtitle = '[${gacha.type}]${gacha.id}   ';
    subtitle += [gacha.openedAt, gacha.closedAt].map((e) => e.sec2date().toStringShort(omitSec: true)).join(' ~ ');
    final now = DateTime.now().timestamp;
    return SimpleAccordion(
      key: Key('gacha-${gacha.id}-${filterData.showBanner}'),
      expanded: filterData.showBanner,
      headerBuilder: (context, _) {
        Widget? trailing;
        if (shouldShowMultiChoice) {
          trailing = Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            value: _selectedGachas.contains(gacha),
            onChanged: (v) {
              setState(() {
                if (v != null && v && _selectedGachas.isEmpty && gacha.detailUrl.isNotEmpty) {
                  final prefix = gacha.detailUrlPrefix;
                  final related = wholeData.where(
                    (e) => (e.openedAt - gacha.openedAt).abs() < kSecsPerDay * 30 && e.detailUrl.startsWith(prefix),
                  );
                  _selectedGachas.addAll(related);
                  return;
                }
                _selectedGachas.toggle(gacha);
              });
            },
          );
        }
        return ListTile(
          dense: true,
          // selected: (_imageIdMap[gacha.imageId]?.length ?? 0) > 1,
          selected: gacha.openedAt <= now && now <= gacha.closedAt,
          // horizontalTitleGap: 8,
          // minLeadingWidth: 12,
          // leading: isLuckyBag ? const Icon(Icons.currency_yen, size: 16) : null,
          title: Text.rich(
            TextSpan(
              children: [
                if (gacha.type == GachaType.chargeStone.value)
                  const TextSpan(
                    text: '$kStarChar2 ',
                    style: TextStyle(color: Colors.red),
                  ),
                TextSpan(text: title),
              ],
            ),
            style: TextStyle(fontStyle: gacha.userAdded ? FontStyle.italic : null),
          ),
          subtitle: Text(subtitle),
          trailing: trailing,
          contentPadding: const EdgeInsetsDirectional.only(start: 16),
        );
      },
      contentBuilder: (context) {
        List<Widget> children = [GachaBanner(imageId: gacha.imageId, region: region ?? Region.jp)];
        final dupGachas = List<NiceGacha>.of(_imageIdMap[gacha.imageId] ?? []);
        dupGachas.remove(gacha);
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
        children.add(
          TextButton(
            onPressed: () => gacha.routeTo(region: region!),
            child: Text(S.current.details),
          ),
        );
        return Column(mainAxisSize: MainAxisSize.min, children: children);
      },
    );
  }

  @override
  PreferredSizeWidget? get buttonBar {
    if (!shouldShowMultiChoice) return null;
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: OverflowBar(
        alignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: kMinInteractiveDimension),
          ElevatedButton(
            onPressed: _selectedGachas.isEmpty
                ? null
                : () {
                    router.pushPage(MCSummonCreatePage(gachas: _selectedGachas.toList()));
                  },
            child: Text("${S.current.create_mooncell_summon}(${_selectedGachas.length})"),
          ),
          IconButton(
            onPressed: () {
              _selectedGachas.clear();
              setState(() {});
            },
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
    );
  }

  @override
  Widget gridItemBuilder(NiceGacha gacha) {
    throw UnimplementedError();
  }

  @override
  Iterable<String?> getSummary(NiceGacha gacha) sync* {
    yield gacha.id.toString();
    yield gacha.name;
    yield gacha.lName;
    yield switch (region) {
      Region.jp => SearchUtil.getJP(gacha.name),
      Region.cn => SearchUtil.getCN(gacha.name),
      Region.tw => SearchUtil.getCN(gacha.name),
      Region.na => SearchUtil.getEn(gacha.name),
      Region.kr => SearchUtil.getKr(gacha.name),
      _ => gacha.name,
    };
  }
}
