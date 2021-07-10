import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';
import 'package:chaldea/widgets/searchable_list_page.dart';

import 'cmd_code_detail_page.dart';
import 'cmd_code_filter_page.dart';

class CmdCodeListPage extends StatefulWidget {
  CmdCodeListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CmdCodeListPageState();
}

class CmdCodeListPageState extends State<CmdCodeListPage>
    with SearchableListMixin<CommandCode, CmdCodeListPage> {
  Query __textFilter = Query();
  bool _showSearch = false;
  late TextEditingController _searchController;

  CmdCodeFilterData get filterData => db.userData.cmdCodeFilter;

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

  void onFilterChanged(CmdCodeFilterData data) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SearchableListPage<CommandCode>(
      data: db.gameData.cmdCodes.values.toList(),
      stringFilter: this.filter,
      compare: (a, b) => CommandCode.compare(a, b,
          keys: filterData.sortKeys, reversed: filterData.sortReversed),
      showSearchBar: _showSearch,
      appBarBuilder: (context, searchBar) => AppBar(
        leading: MasterBackButton(),
        title: Text(S.of(context).command_code),
        titleSpacing: 0,
        bottom: searchBar,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_alt),
            tooltip: S.of(context).filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => CmdCodeFilterPage(
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
      BuildContext context, CommandCode code, List<CommandCode> shownList) {
    return CustomTile(
      leading: db.getIconImage(code.icon, width: 56),
      title: AutoSizeText(code.localizedName, maxLines: 1),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!Language.isJP) AutoSizeText(code.nameJp, maxLines: 1),
          Text('No.${code.no}')
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      selected: SplitRoute.isSplit(context) && selected == code,
      onTap: () {
        SplitRoute.push(
          context: context,
          builder: (context, _) => CmdCodeDetailPage(
            code: code,
            onSwitch: (cur, reversed) => switchNext(cur, reversed, shownList),
          ),
          popDetail: true,
        );
        setState(() {
          selected = code;
        });
      },
    );
  }

  @override
  Widget gridItemBuilder(
      BuildContext context, CommandCode code, List<CommandCode> shownList) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
      child: GestureDetector(
        child: db.getIconImage(code.icon),
        onTap: () {
          SplitRoute.push(
            context: context,
            builder: (context, _) => CmdCodeDetailPage(
              code: code,
              onSwitch: (cur, reversed) => switchNext(cur, reversed, shownList),
            ),
            popDetail: true,
          );
          setState(() {
            selected = code;
          });
        },
      ),
    );
  }

  Map<CommandCode, String> searchMap = {};

  @override
  bool filter(String keyword, CommandCode code) {
    __textFilter.parse(keyword);

    if (keyword.isNotEmpty && searchMap[code] == null) {
      List<String> searchStrings = [
        code.no.toString(),
        code.mcLink,
        ...Utils.getSearchAlphabets(code.name, code.nameJp, code.nameEn),
        ...Utils.getSearchAlphabetsForList(code.illustrators,
            [code.illustratorsJp ?? ''], [code.illustratorsEn ?? '']),
        ...Utils.getSearchAlphabetsForList(code.characters),
        code.skill,
        code.skillEn ?? '',
        code.obtain,
      ];
      searchMap[code] = searchStrings.join('\t');
    }
    if (keyword.isNotEmpty) {
      if (!__textFilter.match(searchMap[code]!)) {
        return false;
      }
    }
    if (!filterData.rarity.singleValueFilter(code.rarity.toString())) {
      return false;
    }
    if (!filterData.category.singleValueFilter(code.category,
        defaultCompare: (o, v) => v?.contains(o))) {
      return false;
    }
    return true;
  }
}
