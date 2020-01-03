import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaldea/components/components.dart';

import 'servant_detail_page.dart';
import 'servant_filter_page.dart';

class ServantListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ServantListPageState();
}

class ServantListPageState extends State<ServantListPage> {
  SvtFilterData filterData;
  TextEditingController _inputController = TextEditingController();
  FocusNode _inputFocusNode = FocusNode();
  ScrollController _scrollController = ScrollController();

  //temp, calculate once build() called.
  TextFilter __textFilter = TextFilter();

  @override
  void initState() {
    super.initState();
    filterData = db.userData.svtFilter;
    filterData.filterString = '';
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  void beforeFiltrate() {
    __textFilter.setFilter(filterData.filterString);
  }

  bool filtrateServant(Servant svt) {
    // input text filter
    if (filterData.filterString.trim().isNotEmpty) {
      List<String> searchStrings = [
        svt.no.toString(),
        svt.mcLink,
        ...svt.info.cv,
        svt.info.name,
        svt.info.nameJp,
        svt.info.illustrator,
        svt.info.illustName,
        ...svt.info.nicknames,
      ];
      svt?.treasureDevice?.forEach((td) {
        searchStrings.addAll([
          td.name,
          td.nameJp,
          td.upperName,
          td.upperNameJp,
          for (var e in td.effects) e.description
        ]);
      });
      svt?.activeSkills?.forEach((activeSkill) {
        activeSkill.forEach((skill) {
          searchStrings.addAll([
            skill.name,
            skill.nameJp,
            for (var e in skill.effects) e.description
          ]);
        });
      });
      if (!__textFilter.match(searchStrings.join('\t'))) {
        return false;
      }
    }
    if (filterData.hasDress) {
      if ((svt.itemCost?.dressName?.length ?? 0) <= 0) {
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
      filterData.npColor: getValueInList(svt.treasureDevice, 0)?.color,
      filterData.npType: getValueInList(svt.treasureDevice, 0)?.category,
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
              showFilterSheet(context);
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
      if (!filterData.favorite ||
          db.curUser.servants[no]?.curVal?.favorite == true) {
        if (filtrateServant(svt)) {
          shownList.add(svt);
        }
      }
    });
    shownList.sort((a, b) =>
        Servant.compare(a, b, filterData.sortKeys, filterData.sortReversed));
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
          final status = db.curUser.servants[svt.no];
          String statusText = '';
          if (status?.curVal?.favorite == true) {
            statusText = '${status.treasureDeviceLv}宝'
                '${status.curVal.ascension}-'
                '${status.curVal.skills[0]}/'
                '${status.curVal.skills[1]}/'
                '${status.curVal.skills[2]}';
          }
          return CustomTile(
            leading: Image(image: db.getIconImage(svt.icon), height: 65),
            title: AutoSizeText('${svt.info.name}', maxLines: 1),
            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AutoSizeText('${svt.info.nameJp}', maxLines: 1),
                      Text('No.${svt.no} ${svt.info.className}')
                    ],
                  ),
                ),
                Text(statusText),
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
    // make sure the floating button not cover svt icon
    if (shownList.length % 5 == 0) {
      shownList.add(null);
    }
    return GridView.count(
        crossAxisCount: 5,
        childAspectRatio: 1,
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        children: shownList.map((svt) {
          if (svt == null) {
            return Container();
          }
          final status = db.curUser.servants[svt.no];
          String statusText;
          if (status?.curVal?.favorite == true) {
            statusText = '${status.treasureDeviceLv}\n'
                '${status.curVal.ascension}-'
                '${status.curVal.skills[0]}/'
                '${status.curVal.skills[1]}/'
                '${status.curVal.skills[2]}';
          }
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              child: ImageWithText(
                image: Image(image: db.getIconImage(svt.icon)),
                text: statusText,
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

  void showFilterSheet(BuildContext context) {
    showSheet(
      context,
      builder: (sheetContext, setSheetState) => ServantFilterPage(
        parent: this,
        filterData: db.userData.svtFilter,
      ),
    );
  }
}
