import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/animation/animate_on_scroll.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

import 'cmd_code_detail_page.dart';
import 'cmd_code_filter_page.dart';

class CmdCodeListPage extends StatefulWidget {
  CmdCodeListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CmdCodeListPageState();
}

class CmdCodeListPageState extends State<CmdCodeListPage> {
  CmdCodeFilterData get filterData => db.userData.cmdCodeFilter;

  /// if null, insert an empty container for gridview
  List<CommandCode> shownList = [];

  bool _showSearch = false;
  late TextEditingController _inputController;
  late ScrollController _scrollController;
  late FocusNode _inputFocusNode;

  Query __textFilter = Query();
  int? _selectedNo;

  @override
  void initState() {
    super.initState();
    filterData.filterString = '';
    _inputController = TextEditingController();
    _scrollController = ScrollController();
    _inputFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void beforeFiltrate() {
    filterData.filterString = filterData.filterString.trim();
    __textFilter.parse(filterData.filterString);
  }

  Map<CommandCode, String> searchMap = {};

  bool filtrateCmdCode(CommandCode code) {
    if (!searchMap.containsKey(code)) {
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
    if (filterData.filterString.isNotEmpty) {
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

  void onFilterChanged(CmdCodeFilterData data) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserScrollListener(
      builder: (context, controller) => Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).command_code),
          leading: MasterBackButton(),
          titleSpacing: 0,
          bottom: _showSearch ? _searchBar : null,
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
                  if (!_showSearch)
                    filterData.filterString = _inputController.text = '';
                });
              },
              icon: Icon(Icons.search),
              tooltip: 'Search',
            ),
          ],
        ),
        floatingActionButton: ScaleTransition(
          scale: controller,
          child: FloatingActionButton(
            child: Icon(Icons.arrow_upward),
            onPressed: () => _scrollController.animateTo(0,
                duration: Duration(milliseconds: 600), curve: Curves.easeOut),
          ),
        ),
        body: buildOverview(),
      ),
    );
  }

  final _onSearchTimer = DelayedTimer(Duration(milliseconds: 250));

  PreferredSizeWidget get _searchBar {
    return PreferredSize(
      preferredSize: Size.fromHeight(45),
      child: Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.grey),
        child: Container(
            height: 45,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextField(
              focusNode: _inputFocusNode,
              controller: _inputController,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 0, style: BorderStyle.none),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, size: 20),
                  suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _inputController.text = '';
                        filterData.filterString = '';
                      });
                    },
                  )),
              onChanged: (s) {
                _onSearchTimer.delayed(() {
                  if (mounted)
                    setState(() {
                      filterData.filterString = s;
                    });
                });
              },
              onSubmitted: (s) {
                FocusScope.of(context).unfocus();
              },
            )),
      ),
    );
  }

  Widget buildOverview() {
    shownList.clear();
    beforeFiltrate();
    db.gameData.cmdCodes.forEach((no, code) {
      if (filtrateCmdCode(code)) {
        shownList.add(code);
      }
    });
    shownList.sort((a, b) => CommandCode.compare(a, b,
        keys: filterData.sortKeys, reversed: filterData.sortReversed));
    return Scrollbar(
      controller: _scrollController,
      child: filterData.display.isRadioVal('Grid')
          ? _buildGridView()
          : _buildListView(),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
        controller: _scrollController,
        separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
        itemCount: shownList.length + (shownList.isEmpty ? 1 : 2),
        itemBuilder: (context, index) {
          if (index == 0 || index == shownList.length + 1) {
            return CustomTile(
              contentPadding:
                  index == 0 ? null : EdgeInsets.only(top: 8, bottom: 50),
              subtitle: Center(
                child: Text(
                  S.of(context).search_result_count(shownList.length),
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            );
          }
          final code = shownList[index - 1];
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
            selected: SplitRoute.isSplit(context) && _selectedNo == code.no,
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (context, _) =>
                    CmdCodeDetailPage(code: code, onSwitch: switchNext),
                popDetail: true,
              );
              setState(() {
                _selectedNo = code.no;
              });
            },
          );
        });
  }

  Widget _buildGridView() {
    List<Widget> children = [];
    for (var code in shownList) {
      children.add(AspectRatio(
        aspectRatio: 132 / 144,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: GestureDetector(
            child: db.getIconImage(code.icon),
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (context, _) =>
                    CmdCodeDetailPage(code: code, onSwitch: switchNext),
                popDetail: true,
              );
              setState(() {
                _selectedNo = code.no;
              });
            },
          ),
        ),
      ));
    }
    if (children.length % 5 == 0) {
      children.add(Container());
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossCount = constraints.maxWidth ~/ 72;
        return GridView.count(
          crossAxisCount: crossCount,
          childAspectRatio: 130 / 144,
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          children: children,
        );
      },
    );
  }

  CommandCode? switchNext(CommandCode cur, bool next) {
    void _setSelected(CommandCode _code) {
      setState(() {
        _selectedNo = _code.no;
      });
    }

    if (shownList.isEmpty) return null;
    if (shownList.contains(cur)) {
      CommandCode? nextCode =
          Utils.findNextOrPrevious<CommandCode>(shownList, cur, next);
      if (nextCode != null) {
        _setSelected(nextCode);
      }
      return nextCode;
    } else {
      _setSelected(shownList.first);
      return shownList.first;
    }
  }
}
