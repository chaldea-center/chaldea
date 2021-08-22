import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';
import 'package:chaldea/modules/summon/filter_page.dart';
import 'package:chaldea/modules/summon/summon_detail_page.dart';

class SummonListPage extends StatefulWidget {
  @override
  _SummonListPageState createState() => _SummonListPageState();
}

class _SummonListPageState extends SearchableListState<Summon, SummonListPage> {
  @override
  Iterable<Summon> get wholeData => db.gameData.summons.values;
  @override
  List<Summon> shownList = [];

  SummonFilterData get filterData => db.userData.summonFilter;

  Set<String> get plans => db.curUser.plannedSummons;

  @override
  void initState() {
    super.initState();
    filterData.reset();
    // filterData.reversed = Language.isJP || db.curUser.server == GameServer.jp;
  }

  @override
  Widget build(BuildContext context) {
    filterShownList();
    if (filterData.reversed) {
      shownList = shownList.reversed.toList();
    }
    shownList.sort((a, b) {
      if (a.isStory && !b.isStory) return -1;
      if (b.isStory && !a.isStory) return 1;
      return 0;
    });
    return scrollListener(
      useGrid: false,
      appBar: AppBar(
        title: Text(S.of(context).summon_title),
        leading: MasterBackButton(),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
        actions: [
          IconButton(
            icon: Icon(filterData.reversed
                ? Icons.keyboard_arrow_down
                : Icons.keyboard_arrow_up),
            tooltip: 'Reversed',
            onPressed: () {
              setState(() {
                filterData.reversed = !filterData.reversed;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_alt),
            tooltip: S.of(context).filter,
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
            icon: Icon(
                filterData.favorite ? Icons.favorite : Icons.favorite_outline),
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
  Widget listItemBuilder(Summon summon) {
    Widget title;
    Widget? subtitle;
    if (filterData.showBanner) {
      title = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 108),
        child: CachedImage(
          imageUrl: db.curUser.server == GameServer.cn
              ? summon.bannerUrl ?? summon.bannerUrlJp
              : summon.bannerUrlJp ?? summon.bannerUrl,
          placeholder: (ctx, url) => Text(summon.lName),
          cachedOption: CachedImageOption(
              errorWidget: (ctx, url, error) => Text(summon.lName)),
        ),
      );
    } else {
      title = AutoSizeText(
        summon.lName,
        maxLines: 2,
        maxFontSize: 14,
        style: TextStyle(color: summon.isOutdated() ? Colors.grey : null),
      );
      String? subtitleText;
      if (db.curUser.server == GameServer.cn) {
        subtitleText = summon.startTimeCn?.split(' ').first;
        if (subtitleText != null) {
          subtitleText = 'CN ' + subtitleText;
        }
      }
      if (subtitleText == null) {
        subtitleText = 'JP ' + (summon.startTimeJp?.split(' ').first ?? '???');
      }
      if (!summon.isStory) subtitle = Text(subtitleText);
    }
    return ListTile(
      title: title,
      subtitle: subtitle,
      contentPadding: filterData.showBanner
          ? EdgeInsets.only(right: 8)
          : EdgeInsets.only(left: 16, right: 8),
      minVerticalPadding: filterData.showBanner ? 0 : null,
      trailing: db.streamBuilder(
        (context) {
          final planned = db.curUser.plannedSummons.contains(summon.indexKey);
          return IconButton(
            icon: Icon(
              planned ? Icons.favorite : Icons.favorite_outline,
              color: planned ? Colors.redAccent : null,
            ),
            onPressed: () {
              if (planned) {
                db.curUser.plannedSummons.remove(summon.indexKey);
              } else {
                db.curUser.plannedSummons.add(summon.indexKey);
              }
              db.notifyDbUpdate();
            },
          );
        },
      ),
      onTap: () {
        SplitRoute.push(
          context,
          SummonDetailPage(summon: summon, summonList: shownList),
          popDetail: true,
        );
      },
    );
  }

  @override
  Widget gridItemBuilder(Summon datum) {
    throw UnimplementedError('GridView not designed');
  }

  @override
  String getSummary(Summon summon) {
    return Utils.getSearchAlphabets(summon.name, summon.nameJp, summon.nameEn)
        .join('\t');
  }

  @override
  bool filter(Summon summon) {
    if (filterData.favorite && !plans.contains(summon.indexKey)) return false;
    if (!filterData.showOutdated && summon.isOutdated() && !summon.isStory)
      return false;
    if (!filterData.category.singleValueFilter(summon.category.toString()))
      return false;
    return true;
  }
}
