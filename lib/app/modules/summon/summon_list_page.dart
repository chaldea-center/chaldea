import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:chaldea/app/app.dart';
import 'package:chaldea/app/modules/common/filter_page_base.dart';
import 'package:chaldea/generated/l10n.dart';
import 'package:chaldea/models/models.dart';
import 'package:chaldea/packages/split_route/split_route.dart';
import 'package:chaldea/utils/utils.dart';
import 'package:chaldea/widgets/widgets.dart';
import 'filter_page.dart';
import 'gacha_prob_calc.dart';
import 'summon_detail_page.dart';

class SummonListPage extends StatefulWidget {
  SummonListPage({super.key});

  @override
  _SummonListPageState createState() => _SummonListPageState();
}

class _SummonListPageState extends State<SummonListPage> with SearchableListState<LimitedSummon, SummonListPage> {
  @override
  Iterable<LimitedSummon> get wholeData => db.gameData.wiki.summons.values;

  SummonFilterData get filterData => db.settings.summonFilterData;

  Set<String> get plans => db.curUser.summons;

  @override
  void initState() {
    super.initState();
    filterData.reset();
    filterData.reversed = db.curUser.region == Region.jp;
  }

  @override
  Widget build(BuildContext context) {
    filterShownList();
    shownList.sort2((a) => a.startTime.jp ?? 0);
    if (filterData.reversed) {
      final reversed = List.of(shownList.reversed);
      shownList
        ..clear()
        ..addAll(reversed);
    }
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        title: Text(S.current.summon),
        leading: const MasterBackButton(),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: [
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
                onChanged: (_) {
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
          IconButton(
            icon: Icon(filterData.favorite ? Icons.favorite : Icons.favorite_outline),
            tooltip: S.current.favorite,
            onPressed: () {
              setState(() {
                filterData.favorite = !filterData.favorite;
              });
            },
          ),
          searchIcon,
        ],
      ),
    );
  }

  @override
  PreferredSizeWidget get buttonBar {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: ButtonBar(
        alignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              router.pushPage(const GachaProbCalcPage());
            },
            child: Text(S.current.gacha_prob_calc),
          ),
        ],
      ),
    );
  }

  @override
  Widget listItemBuilder(LimitedSummon summon) {
    Widget title;
    Widget? subtitle;
    if (filterData.showBanner) {
      title = ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 108),
        child: CachedImage(
          imageUrl: summon.resolvedBanner.l,
          placeholder: (ctx, url) => Padding(
            padding: const EdgeInsetsDirectional.only(start: 16),
            child: Text(summon.lName, textScaleFactor: 0.9),
          ),
          cachedOption: CachedImageOption(errorWidget: (ctx, url, error) => Text(summon.lName)),
        ),
      );
      title = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          title,
          Text(
            summon.lName,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: summon.isOutdated() ? FontStyle.italic : null),
            textAlign: TextAlign.center,
          )
        ],
      );
    } else {
      title = AutoSizeText(
        summon.lName,
        maxLines: 2,
        maxFontSize: 14,
        style: TextStyle(color: summon.isOutdated() ? Colors.grey : null),
      );
      final region = db.curUser.region;
      Map<Region, int?> dates = {
        Region.jp: summon.startTime.jp,
        if (region != Region.jp) region: summon.startTime.ofRegion(region)
      };
      String subtitleText = dates.entries
          .where((e) => e.value != null)
          .map((e) => '${e.key.upper} ${e.value?.sec2date().toDateString()}')
          .join(' / ');
      subtitle = Text(subtitleText, textScaleFactor: 0.9);
    }
    return ListTile(
      title: title,
      subtitle: subtitle,
      contentPadding: filterData.showBanner ? EdgeInsets.zero : const EdgeInsetsDirectional.only(start: 16),
      minVerticalPadding: filterData.showBanner ? 0 : null,
      trailing: db.onUserData(
        (context, snapshot) {
          final planned = db.curUser.summons.contains(summon.id);
          return IconButton(
            icon: Icon(
              planned ? Icons.favorite : Icons.favorite_outline,
              color: planned ? Colors.redAccent : null,
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            onPressed: () {
              db.curUser.summons.toggle(summon.id);
              db.notifyUserdata();
            },
          );
        },
      ),
      onTap: () {
        summon.routeTo(
          child: SummonDetailPage(
            summon: summon,
            summonList: shownList.toList(),
          ),
          popDetails: true,
        );
      },
    );
  }

  @override
  Widget gridItemBuilder(LimitedSummon datum) {
    throw UnimplementedError('GridView not designed');
  }

  @override
  Iterable<String?> getSummary(LimitedSummon summon) sync* {
    yield* SearchUtil.getAllKeys(
      Transl.fromMapping(summon.id, summon.name, summon.id.toString()),
      dft: null,
    );
  }

  @override
  bool filter(LimitedSummon summon) {
    if (filterData.favorite && !plans.contains(summon.id)) return false;
    if (!filterData.showOutdated && summon.isOutdated()) {
      return false;
    }
    if (!filterData.category.matchOne(summon.type)) {
      return false;
    }
    return true;
  }
}
