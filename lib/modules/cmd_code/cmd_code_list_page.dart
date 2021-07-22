import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

import 'cmd_code_detail_page.dart';
import 'cmd_code_filter_page.dart';

class CmdCodeListPage extends StatefulWidget {
  CmdCodeListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CmdCodeListPageState();
}

class CmdCodeListPageState
    extends SearchableListState<CommandCode, CmdCodeListPage> {
  @override
  Iterable<CommandCode> get wholeData => db.gameData.cmdCodes.values;

  Query __textFilter = Query();

  CmdCodeFilterData get filterData => db.userData.cmdCodeFilter;

  void onFilterChanged(CmdCodeFilterData data) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    filterShownList(
      compare: (a, b) => CommandCode.compare(a, b,
          keys: filterData.sortKeys, reversed: filterData.sortReversed),
    );
    return scrollListener(
      useGrid: filterData.useGrid,
      appBar: AppBar(
        leading: MasterBackButton(),
        title: Text(S.current.command_code),
        titleSpacing: 0,
        bottom: showSearchBar ? searchBar : null,
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
          searchIcon,
        ],
      ),
    );
  }

  @override
  Widget listItemBuilder(CommandCode code) {
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
          context,
          CmdCodeDetailPage(
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
  Widget gridItemBuilder(CommandCode code) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: GestureDetector(
        child: db.getIconImage(code.icon),
        onTap: () {
          SplitRoute.push(
            context,
            CmdCodeDetailPage(
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
      searchMap[code] = searchStrings.toSet().join('\t');
    }
    if (keyword.isNotEmpty) {
      __textFilter.parse(keyword);
      return __textFilter.match(searchMap[code]!);
    }

    /// In search mode, filters are ignored
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
