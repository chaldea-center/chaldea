import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';
import 'package:chaldea/widgets/searchable_list_page.dart';

import 'craft_detail_page.dart';
import 'craft_filter_page.dart';

class CraftListPage extends StatefulWidget {
  CraftListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CraftListPageState();
}

class CraftListPageState extends State<CraftListPage>
    with SearchableListMixin<CraftEssence, CraftListPage> {
  Query __textFilter = Query();
  bool _showSearch = false;
  late TextEditingController _searchController;

  //temp, calculate once build() called.
  int __binAtkHpType = 0;

  CraftFilterData get filterData => db.userData.craftFilter;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void onFilterChanged(CraftFilterData data) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SearchableListPage<CraftEssence>(
      data: db.gameData.crafts.values.toList(),
      stringFilter: this.filter,
      compare: (a, b) => CraftEssence.compare(a, b,
          keys: filterData.sortKeys, reversed: filterData.sortReversed),
      showSearchBar: _showSearch,
      appBarBuilder: (context, searchBar) => AppBar(
        leading: MasterBackButton(),
        title: Text(S.of(context).craft_essence),
        titleSpacing: 0,
        bottom: searchBar,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_alt),
            tooltip: S.of(context).filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => CraftFilterPage(
                  filterData: filterData, onChanged: onFilterChanged),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchController.text = '';
              });
            },
            icon: Icon(Icons.search),
            tooltip: S.current.search,
          ),
        ],
      ),
      useGrid: filterData.useGrid,
      listItemBuilder: listItemBuilder,
      gridItemBuilder: gridItemBuilder,
      topHintBuilder: SearchableListPage.defaultHintBuilder,
      bottomHintBuilder: SearchableListPage.defaultHintBuilder,
      textEditingController: _searchController,
    );
  }

  @override
  Widget listItemBuilder(
      BuildContext context, CraftEssence ce, List<CraftEssence> shownList) {
    String additionalText = '';
    switch (filterData.sortKeys.first) {
      case CraftCompare.atk:
        additionalText = '  ATK ${ce.atkMax}';
        break;
      case CraftCompare.hp:
        additionalText = '  HP ${ce.hpMax}';
        break;
      default:
        break;
    }
    return CustomTile(
      leading: db.getIconImage(ce.icon, width: 56),
      title: AutoSizeText(ce.localizedName, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!Language.isJP) AutoSizeText(ce.nameJp, maxLines: 1),
          Text('No.${ce.no.toString().padRight(4)}  $additionalText'),
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      selected: SplitRoute.isSplit(context) && selected == ce,
      onTap: () {
        SplitRoute.push(
          context: context,
          builder: (context, _) => CraftDetailPage(
            ce: ce,
            onSwitch: (cur, reversed) => switchNext(cur, reversed, shownList),
          ),
          popDetail: true,
        );
        setState(() {
          selected = ce;
        });
      },
    );
  }

  @override
  Widget gridItemBuilder(
      BuildContext context, CraftEssence ce, List<CraftEssence> shownList) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      child: GestureDetector(
        child: db.getIconImage(ce.icon),
        onTap: () {
          SplitRoute.push(
            context: context,
            builder: (context, _) => CraftDetailPage(
              ce: ce,
              onSwitch: (cur, reversed) => switchNext(cur, reversed, shownList),
            ),
            popDetail: true,
          );
          setState(() {
            selected = ce;
          });
        },
      ),
    );
  }

  void beforeFiltrate() {
    __binAtkHpType = 0;
    for (int i = 0; i < CraftFilterData.atkHpTypeData.length; i++) {
      if (filterData.atkHpType.options[CraftFilterData.atkHpTypeData[i]] ==
          true) {
        __binAtkHpType += 1 << i;
      }
    }
  }

  Map<CraftEssence, String> searchMap = {};

  @override
  bool filter(String keyword, CraftEssence ce) {
    __textFilter.parse(keyword);
    beforeFiltrate();
    if (keyword.isNotEmpty && searchMap[ce] == null) {
      List<String> searchStrings = [
        ce.no.toString(),
        ce.mcLink,
        ...Utils.getSearchAlphabets(ce.name, ce.nameJp, ce.nameEn),
        ...Utils.getSearchAlphabetsForList(ce.illustrators,
            [ce.illustratorsJp ?? ''], [ce.illustratorsEn ?? '']),
        ...Utils.getSearchAlphabetsForList(ce.characters),
        ce.skill,
        ce.skillMax ?? '',
        ce.skillEn ?? '',
        ce.skillMaxEn ?? '',
        ...ce.eventSkills,
      ];
      searchMap[ce] = searchStrings.join('\t');
    }
    if (keyword.isNotEmpty) {
      if (!__textFilter.match(searchMap[ce]!)) {
        return false;
      }
    }
    if (!filterData.rarity.singleValueFilter(ce.rarity.toString())) {
      return false;
    }

    if (!filterData.category.singleValueFilter(ce.category,
        defaultCompare: (o, v) => v?.contains(o) ?? false)) {
      return false;
    }
    if (__binAtkHpType > 0 &&
        ((1 << ((ce.hpMax > 0 ? 1 : 0) + (ce.atkMax > 0 ? 2 : 0))) &
                __binAtkHpType) ==
            0) {
      return false;
    }
    if (!filterData.status
        .singleValueFilter((db.curUser.crafts[ce.no] ?? 0).toString())) {
      return false;
    }
    return true;
  }
}
