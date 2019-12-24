import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import 'cmd_code_detail_page.dart';
import 'cmd_code_filter_page.dart';

class CmdCodeListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CmdCodeListPageState();
}

class CmdCodeListPageState extends State<CmdCodeListPage> {
  CmdCodeFilterData filterData;
  TextEditingController _inputController = TextEditingController();
  FocusNode _inputFocusNode = FocusNode();
  ScrollController _scrollController = ScrollController();

  TextFilter __textFilter = TextFilter();

  @override
  void initState() {
    super.initState();
    filterData = db.userData.cmdCodeFilter;
    filterData.filterString = '';
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
    __textFilter.setFilter(filterData.filterString);
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
    if (!filterData.obtain.singleValueFilter(code.obtain, compares: {
      CmdCodeFilterData.obtainData[1]: (o, v) =>
          v != CmdCodeFilterData.obtainData[0]
    })) {
      return false;
    }
    return true;
  }

  void onFilterChanged(CmdCodeFilterData data) {
    setState(() {
      filterData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).cmd_code_title),
        leading: SplitViewBackButton(),
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
            onPressed: () => showFilterSheet(context),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_upward),
          onPressed: () => _scrollController.jumpTo(0)),
      body: buildOverview(),
    );
  }

  Widget buildOverview() {
    List<CommandCode> shownList = [];
    beforeFiltrate();
    db.gameData.cmdCodes.forEach((no, code) {
      if (filtrateCmdCode(code)) {
        shownList.add(code);
      }
    });
    shownList.sort((a, b) => CommandCode.compare(
        a, b, filterData.sortKeys, filterData.sortReversed));
    return filterData.useGrid
        ? _buildGridView(shownList)
        : _buildListView(shownList);
  }

  Widget _buildListView(List<CommandCode> shownList) {
    return ListView.separated(
        physics: ScrollPhysics(),
        controller: _scrollController,
        separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
        itemCount: shownList.length,
        itemBuilder: (context, index) {
          final code = shownList[index];
          return CustomTile(
            leading: SizedBox(
              width: 132 * 0.45,
              height: 144 * 0.45,
              child: Image(image: db.getIconFile(code.icon)),
            ),
            title: AutoSizeText(code.name, maxLines: 1),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AutoSizeText(code.nameJp ?? code.name, maxLines: 1),
                Text('No.${code.no}')
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              SplitRoute.popAndPush(context,
                  builder: (context) => CmdCodeDetailPage(code: code));
            },
          );
        });
  }

  Widget _buildGridView(List<CommandCode> shownList) {
    return GridView.count(
        crossAxisCount: 5,
        childAspectRatio: 1,
        controller: _scrollController,
        children: shownList.map((code) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 1),
              child: ImageWithText(
                image: Image(image: db.getIconFile(code.icon)),
                alignment: AlignmentDirectional.bottomStart,
                onTap: () {
                  SplitRoute.popAndPush(context,
                      builder: (context) => CmdCodeDetailPage(code: code));
                },
              ),
            ),
          );
        }).toList());
  }

  void showFilterSheet(BuildContext context) {
    showSheet(
      context,
      size: 0.6,
      builder: (sheetContext, setSheetState) =>
          CmdCodeFilterPage(parent: this, filterData: filterData),
    );
  }
}
