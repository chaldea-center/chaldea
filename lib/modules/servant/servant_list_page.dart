import 'package:chaldea/components/components.dart';
import 'package:chaldea/components/custom_tile.dart';
import 'package:chaldea/components/tile_items.dart';
import 'package:chaldea/modules/servant/servant_detail.dart';
import 'package:chaldea/modules/servant/svt_filter_page.dart';
import 'package:flutter/material.dart';

class ServantListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ServantListPageState();
}

class ServantListPageState extends State<ServantListPage> {
  SvtFilterData filterData;
  TextEditingController _inputController;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _scrollController = ScrollController();
    filterData = db.appData.svtFilter;
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool filtrateServant(SvtFilterData _filterData, Servant svt) {
    // input text filter
    if (filterData.filterString.trim().isNotEmpty) {
      TextFilter textFilter = TextFilter(filterData.filterString);
      String srcString = [
        svt.no,
        svt.info.cv,
        svt.mcLink,
        svt.info.name,
        svt.info.illustName,
        svt.info.nicknames.join('\t')
      ].join('\t');
      if (!textFilter.match(srcString)) {
        return false;
      }
    }
    // svt data filter
    // class name
    if (!filterData.className.singleValueFilter(svt.info.className,
        compares: {'Beast': (o, v) => v.startsWith(o)})) {
      return false;
    }
    // single value
    Map<FilterGroupData, String> singleValuePair = {
      filterData.rarity: svt.info.rarity.toString(),
      filterData.obtain: svt.info.obtain,
      filterData.npColor: svt.nobelPhantasm?.first?.color,
      filterData.npType: svt.nobelPhantasm?.first?.category,
      filterData.attribute: svt.info.attribute,
    };
    for (var entry in singleValuePair.entries) {
      if (!entry.key.singleValueFilter(entry.value)) {
        return false;
      }
    }
    //alignments
    if (!filterData.alignment1.listValueFilter(svt.info.alignments) ||
        !filterData.alignment2.listValueFilter(svt.info.alignments)) {
      return false;
    }
    // gender
    if (!filterData.gender.singleValueFilter(svt.info.gender, compares: {
      '其他': (optionKey, value) =>
          value != SvtFilterData.genderData[0] &&
          value != SvtFilterData.genderData[1]
    })) {
      return false;
    }
    // trait
    if (!filterData.trait.listValueFilter(svt.info.traits, compares: {
      '魔性': (o, v) => v.startsWith(o),
      '超巨大': (o, v) => v.startsWith(o),
      '天地(拟似除外)': (o, v) => v == '天地从者',
      '拟似/亚从者': (o, v) => v.contains('拟似从者') || v.contains('亚从者'),
      'EA不特攻': (o, v) => !svt.info.isWeakToEA,
      '无特殊特性': (o, v) => svt.info.traits.isEmpty,
    })) {
      return false;
    }
    // traitSpecial
    final a = SvtFilterData.traitSpecialData;
    if (filterData.traitSpecial.options.containsValue(true) &&
        !(filterData.traitSpecial.options[a[0]] == true &&
            !svt.info.isWeakToEA) &&
        !(filterData.traitSpecial.options[a[1]] == true &&
            svt.info.traits.isEmpty)) {
      return false;
    }
    return true;
  }

  void onFilterChanged(SvtFilterData data) {
    setState(() {
      filterData = data;
    });
  }

  Widget _buildListView(List<Servant> shownSvtList) {
    return ListView.separated(
        physics: ScrollPhysics(),
        controller: _scrollController,
        separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
        itemCount: shownSvtList.length,
        itemBuilder: (context, index) {
          final svt = shownSvtList[index];
          final plan = db.curPlan.servants[svt.no];
          String text = '';
          if (plan?.favorite == true) {
            text = '${plan.npLv}宝'
                '${plan.ascensionLv[0]}-'
                '${plan.skillLv[0][0]}/'
                '${plan.skillLv[1][0]}/'
                '${plan.skillLv[2][0]}';
          }
          return CustomTile(
            leading: SizedBox(
              width: 132 * 0.45,
              height: 144 * 0.45,
              child: Image.file(db.getIconFile(svt.icon)),
            ),
            title: Text('${svt.mcLink}'),
            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Text(svt.info.className),
                ),
                Text(text),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              SplitRoute.popAndPush(context,
                  builder: (context) => ServantDetailPage(svt));
            },
          );
        });
  }

  Widget _buildGridView(List<Servant> shownSvtList) {
    return GridView.count(
        crossAxisCount: 5,
        childAspectRatio: 1,
        controller: _scrollController,
        children: shownSvtList.map((svt) {
          final plan = db.curPlan.servants[svt.no];
          String text;
          if (plan?.favorite == true) {
            text = '${plan.npLv}\n'
                '${plan.ascensionLv[0]}-'
                '${plan.skillLv[0][0]}/'
                '${plan.skillLv[1][0]}/'
                '${plan.skillLv[2][0]}';
          }
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 1,
              ),
              child: ImageWithText(
                image: Image.file(db.getIconFile(svt.icon)),
                text: text,
                alignment: AlignmentDirectional.bottomStart,
                padding: EdgeInsets.fromLTRB(4, 0, 8, -4),
                onTap: () {
                  SplitRoute.popAndPush(context,
                      builder: (context) => ServantDetailPage(svt));
                },
              ),
            ),
          );
        }).toList());
  }

  Widget buildSvtOverview() {
    List<Servant> shownSvtList = [];
    db.gameData.servants.forEach((no, svt) {
      if (!filterData.favorite || db.curPlan.servants[no]?.favorite == true) {
        if (filtrateServant(filterData, svt)) {
          shownSvtList.add(svt);
        }
      }
    });
    //sort
    final _getSortValue = (Servant svt, String key) {
      switch (key) {
        case '序号':
          return svt.no;
        case '星级':
          return svt.info.rarity;
        case '职阶':
          return SvtFilterData.classesData.indexWhere(
              (v) => v.startsWith(svt.info.className.substring(0, 5)));
        default:
          return 0;
      }
    };

    shownSvtList.sort((a, b) {
      return (_getSortValue(a, filterData.sortKeys[0]) -
                  _getSortValue(b, filterData.sortKeys[0])) *
              (filterData.sortDirections[0] ? 1000 : -1000) +
          (_getSortValue(a, filterData.sortKeys[1]) -
                  _getSortValue(b, filterData.sortKeys[1])) *
              (filterData.sortDirections[1] ? 1 : -1);
    });
    return filterData.useGrid
        ? _buildGridView(shownSvtList)
        : _buildListView(shownSvtList);
  }

  @override
  Widget build(BuildContext context) {
    //todo: hide/show floatingButton when scroll down/up
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).servant),
        leading: BackButton(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.grey),
            child: Container(
                height: 45.0,
                padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                child: TextField(
                  controller: _inputController,
                  style: TextStyle(fontSize: 13.0),
                  decoration: InputDecoration(
                      filled: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              width: 0.0, style: BorderStyle.none),
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0))),
                      fillColor: Colors.white,
                      hintText: 'Seach',
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20.0,
                      ),
                      suffixIcon: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.clear,
                          size: 20.0,
                        ),
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
              icon: Icon(
                  filterData.favorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                setState(() {
                  filterData.favorite = !filterData.favorite;
                });
              }),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              buildFilterSheet(context);
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_upward),
          onPressed: () {
            _scrollController.jumpTo(0);
          }),
      body: buildSvtOverview(),
    );
  }

  void buildFilterSheet(BuildContext context) {
    showSheet(
      context,
      builder: (sheetContext, setSheetState) => SvtFilterPage(
        parent: this,
        filterData: db.appData.svtFilter,
      ),
    );
  }
}
