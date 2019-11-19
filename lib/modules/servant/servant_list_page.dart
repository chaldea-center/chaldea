import 'package:chaldea/components/components.dart';

import 'servant_detail_page.dart';
import 'svt_filter_page.dart';

class ServantListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ServantListPageState();
}

class ServantListPageState extends State<ServantListPage> {
  SvtFilterData filterData;
  TextEditingController _inputController;
  ScrollController _scrollController;

  //temp, calculate once build() called.
  TextFilter __textFilter;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _scrollController = ScrollController();
    filterData = db.userData.svtFilter;
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void beforeFiltrate() {
    __textFilter = TextFilter(filterData.filterString);
  }

  bool filtrateServant(Servant svt) {
    // input text filter
    if (filterData.filterString.trim().isNotEmpty) {
      String srcString = [
        svt.no,
        svt.info.cv,
        svt.mcLink,
        svt.info.name,
        svt.info.illustName,
        svt.info.nicknames.join('\t')
      ].join('\t');
      if (!__textFilter.match(srcString)) {
        return false;
      }
    }
    // svt data filter
    // class name
    if (!filterData.className.singleValueFilter(svt.info.className, compares: {
      'Beast': (o, v) => v.startsWith(o),
      'Caster': (o, v) => v.contains(o)
    })) {
      return false;
    }
    // single value
    Map<FilterGroupData, String> singleValuePair = {
      filterData.rarity: svt.info.rarity.toString(),
      filterData.obtain: svt.info.obtain,
      filterData.npColor: svt.treasureDevice?.first?.color,
      filterData.npType: svt.treasureDevice?.first?.category,
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

  @override
  Widget build(BuildContext context) {
    //todo: hide/show floatingButton when scroll down/up
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).servant),
        leading: SplitViewBackButton(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.grey),
            child: Container(
                height: 45,
                padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: TextField(
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
      body: buildOverview(),
    );
  }

  Widget buildOverview() {
    List<Servant> shownList = [];
    beforeFiltrate();
    db.gameData.servants.forEach((no, svt) {
      if (!filterData.favorite || db.curPlan.servants[no]?.favorite == true) {
        if (filtrateServant(svt)) {
          shownList.add(svt);
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
          if (svt.info.className == 'Grand Caster') {
            return SvtFilterData.classesData.indexWhere((v) => v == 'Caster');
          } else if (svt.info.className.startsWith('Beast')) {
            return SvtFilterData.classesData.indexWhere((v) => v == 'Beast');
          } else {
            return SvtFilterData.classesData.indexWhere(
                (v) => v.startsWith(svt.info.className.substring(0, 5)));
          }
          break;
        default:
          return 0;
      }
    };

    shownList.sort((a, b) {
      int r = 0;
      for (var i = 0; i < filterData.sortKeys.length; i++) {
        final sortKey = filterData.sortKeys[i];
        r = r * 1000 +
            (_getSortValue(a, sortKey) - _getSortValue(b, sortKey)) *
                (filterData.sortDirections[i] ? 1000 : -1000);
      }
      return r;
    });
    return filterData.useGrid
        ? _buildGridView(shownList)
        : _buildListView(shownList);
  }

  Widget _buildListView(List<Servant> shownList) {
    return ListView.separated(
        physics: ScrollPhysics(),
        controller: _scrollController,
        separatorBuilder: (context, index) => Divider(height: 1, indent: 16),
        itemCount: shownList.length,
        itemBuilder: (context, index) {
          final svt = shownList[index];
          final plan = db.curPlan.servants[svt.no];
          String text = '';
          if (plan?.favorite == true) {
            text = '${plan.treasureDeviceLv}宝'
                '${plan.ascensionLv[0]}-'
                '${plan.skillLv[0][0]}/'
                '${plan.skillLv[1][0]}/'
                '${plan.skillLv[2][0]}';
          }
          return CustomTile(
            leading: SizedBox(
              width: 132 * 0.45,
              height: 144 * 0.45,
              child: Image(image: db.getIconFile(svt.icon)),
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

  Widget _buildGridView(List<Servant> shownList) {
    return GridView.count(
        crossAxisCount: 5,
        childAspectRatio: 1,
        controller: _scrollController,
        children: shownList.map((svt) {
          final plan = db.curPlan.servants[svt.no];
          String text;
          if (plan?.favorite == true) {
            text = '${plan.treasureDeviceLv}\n'
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
                image: Image(image: db.getIconFile(svt.icon)),
                text: text,
                fontSize: 11,
                alignment: AlignmentDirectional.bottomStart,
                padding: EdgeInsets.fromLTRB(4, 0, 8, 0),
                onTap: () {
                  SplitRoute.popAndPush(context,
                      builder: (context) => ServantDetailPage(svt));
                },
              ),
            ),
          );
        }).toList());
  }

  void buildFilterSheet(BuildContext context) {
    showSheet(
      context,
      builder: (sheetContext, setSheetState) => SvtFilterPage(
        parent: this,
        filterData: db.userData.svtFilter,
      ),
    );
  }
}
