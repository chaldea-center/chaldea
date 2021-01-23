import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';
import 'package:chaldea/modules/shared/filter_page.dart';

import 'cmd_code_detail_page.dart';
import 'cmd_code_filter_page.dart';

class CmdCodeListPage extends StatefulWidget {
  CmdCodeListPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CmdCodeListPageState();
}

class CmdCodeListPageState extends State<CmdCodeListPage>
    with DefaultScrollBarMixin {
  CmdCodeFilterData filterData;
  List<CommandCode> shownList = [];
  TextEditingController _inputController = TextEditingController();
  FocusNode _inputFocusNode = FocusNode();
  ScrollController _scrollController;

  Query __textFilter = Query();

  @override
  void initState() {
    super.initState();
    filterData = db.userData.cmdCodeFilter;
    filterData.filterString = '';
    _scrollController = ScrollController();
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

  bool filtrateCmdCode(CommandCode code) {
    if (filterData.filterString.isNotEmpty) {
      List<String> searchStrings = [
        code.no.toString(),
        code.name,
        code.nameJp,
        code.mcLink,
        code.obtain,
        ...code.illustrators,
        ...code.characters,
        code.skill,
        ...code.characters
      ];
      if (!__textFilter.match(searchStrings.join('\t'))) {
        return false;
      }
    }
    if (!filterData.rarity.singleValueFilter(code.rarity.toString())) {
      return false;
    }
    if (!filterData.category
        .singleValueFilter(code.category, compare: (o, v) => v.contains(o))) {
      return false;
    }
    return true;
  }

  bool onFilterChanged(CmdCodeFilterData data) {
    if (mounted) {
      setState(() {
        filterData = data;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).command_code),
        leading: MasterBackButton(),
        bottom: PreferredSize(
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
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      fillColor: Colors.white,
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search, size: 20),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _inputController.clear());
                            filterData.filterString = '';
                          });
                        },
                      )),
                  onChanged: (s) {
                    setState(() {
                      filterData.filterString = s;
                    });
                  },
                  onSubmitted: (s) {
                    FocusScope.of(context).unfocus();
                  },
                )),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            tooltip: S.of(context).filter,
            onPressed: () => FilterPage.show(
              context: context,
              builder: (context) => CmdCodeFilterPage(
                  filterData: filterData, onChanged: onFilterChanged),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_upward),
          onPressed: () => _scrollController.jumpTo(0)),
      body: buildOverview(),
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
    shownList.sort((a, b) => CommandCode.compare(
        a, b, filterData.sortKeys, filterData.sortReversed));
    return wrapDefaultScrollBar(
      controller: _scrollController,
      child: filterData.useGrid ? _buildGridView() : _buildListView(),
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
            leading: Image(image: db.getIconImage(code.icon), height: 65),
            title: AutoSizeText(code.localizedName, maxLines: 1),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (!MyLocale.isJP)
                  AutoSizeText(code.nameJp ?? code.name, maxLines: 1),
                Text('No.${code.no}')
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              SplitRoute.push(
                context: context,
                builder: (context, _) =>
                    CmdCodeDetailPage(code: code, onSwitch: switchNext),
                popDetail: true,
              );
            },
          );
        });
  }

  Widget _buildGridView() {
    if (shownList.length % 5 == 0) {
      shownList.add(null);
    }
    return GridView.count(
        crossAxisCount: 5,
        childAspectRatio: 1,
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        children: shownList.map((code) {
          if (code == null) {
            return Container();
          }
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              child: GestureDetector(
                child: Image(image: db.getIconImage(code.icon)),
                onTap: () {
                  SplitRoute.push(
                    context: context,
                    builder: (context, _) =>
                        CmdCodeDetailPage(code: code, onSwitch: switchNext),
                    popDetail: true,
                  );
                },
              ),
            ),
          );
        }).toList());
  }

  CommandCode switchNext(int cur, bool next) {
    if (shownList.length <= 0) return null;
    for (int i = 0; i < shownList.length; i++) {
      if (shownList[i].no == cur) {
        int nextIndex = i + (next ? 1 : -1);
        if (nextIndex < shownList.length && nextIndex >= 0) {
          return shownList[nextIndex];
        } else {
          // if reach the end/head of list, return null
          return null;
        }
      }
    }
    // if not found in list, return the first one
    return shownList[0];
  }
}
